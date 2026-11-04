from night_candidates import detect as detect_night_candidates

import bootstrap
import traceback
import copy,hashlib,json,threading,time
from concurrent.futures import ThreadPoolExecutor,Future
from pathlib import Path
import cv2,numpy as np
from pipeline import read_pair,TTL
from detector import Detector,SIGNAL_CLASSES,windows
from decoder import decode,class_masks
from type_arbitration import resolve as resolve_type_conflicts
from association import route
from near_boundary import observe,prepare_geometry
from paint_evidence import prepare_context
from lane_display import encode as encode_lane_display
from cross_stability import CrossSegmentStability
from lane_timing import EVIDENCE_TTL,DISPLAY_TTL
from reference_detector import ReferenceDetector
from hybrid_signal import Focus,reference_candidates
from nav_screen import PROFILES,filter_screen_lights
from lane_aux import rk_context as fpga_paint_context



from modes import SCENES,SCHEDULES
SCHEDULE=('hdmi','lane','hdmi','camera') 

class LaneModel:
    def __init__(self):
        from rknnlite.api import RKNNLite
        root=bootstrap.ROOT/'lane';model=root/'yolo11_lane_384x640_fp16.rknn'
        manifest=json.loads((root/'rknn_manifest.json').read_text())
        if hashlib.sha256(model.read_bytes()).hexdigest()!=manifest['rknn_sha256']:
            raise ValueError('Lane model hash mismatch')
        self.net=RKNNLite()
        try:
            if self.net.load_rknn(str(model)) or self.net.init_runtime():raise RuntimeError('Lane RKNN initialization')
        except BaseException:self.net.release();raise
    def infer(self,image):
        tensor=cv2.copyMakeBorder(image,12,12,0,0,cv2.BORDER_CONSTANT,value=(114,114,114))[:,:,::-1]
        outputs=self.net.inference(inputs=[np.ascontiguousarray(tensor[None])],data_format=['nhwc'])
        if outputs is None:raise RuntimeError('Missing lane outputs')
        return outputs
    def close(self):self.net.release()

def object_mask(rows):
    mask=np.zeros((360,640),np.uint8)
    for row in rows:
        x1,y1,x2,y2=row['box']
        x1,y1=int(np.floor(x1)),int(np.floor(y1));x2,y2=int(np.ceil(x2)),int(np.ceil(y2))
        mask[max(0,y1):min(360,y2),max(0,x1):min(640,x2)]=1
    return mask

class LaneCPU:
    supports_early_display=True
    supports_paint_features=True
    def __init__(self):self.tracker=CrossSegmentStability();self.previous_epoch=None
    @staticmethod
    def prepare(image,features=None):
        start=time.perf_counter()
        prepared,hsv=prepare_context(image) if features is None else fpga_paint_context(image,features)
        return dict(paint=prepared,hsv=hsv,seconds=time.perf_counter()-start,
            backend='rk_original' if features is None else 'fpga_lower_half_paint')
    def process(self,image,outputs,objects,stamp,ns,epoch,image_context=None,display_sink=None):
        started=time.perf_counter()
        if self.previous_epoch!=epoch:self.tracker.reset()
        self.previous_epoch=epoch
        items=decode(outputs);decoded_at=time.perf_counter()
        classes=class_masks(items);model_display=encode_lane_display(classes)
        
        raw_lane_mask=np.logical_or.reduce(list(classes.values())) if classes else np.zeros((360,640),bool)
        if display_sink is not None:
            display_sink(dict(source_timestamp=stamp,source_ns=ns,model_display=model_display,
                decoded_timestamp=time.time(),decision_permission=False))
        _,association=route(classes)
        classes,type_arbitration=resolve_type_conflicts(items,classes)
        associated_at=time.perf_counter()
        context=self.prepare(image) if image_context is None else image_context.result()
        prepared,hsv=context['paint'],context['hsv']
        prepared_at=time.perf_counter()
        geometry=prepare_geometry(image,classes,association);geometry_at=time.perf_counter()
        
        
        objects=objects.result() if hasattr(objects,'result') else objects
        objects_at=time.perf_counter()
        observation=observe(image,classes,association,object_mask(objects),image_prepared=prepared,image_hsv=hsv,geometry=geometry)
        observed_at=time.perf_counter()
        evidence=self.tracker.process(observation,stamp,time.time())
        obstruction=object_mask(objects)
        for a in evidence.get('sides',[]):
            sl=slice(0,320) if a['image_side']=='left' else slice(320,640)
            absent=(not np.any(raw_lane_mask[:,sl]) and not np.any(obstruction[240:,sl])
                and a.get('model_candidate')=='UNKNOWN' and a.get('reason')=='NO_USABLE_NEAR_STROKE')
            a['line_presence']='NOT_DETECTED' if absent else 'DETECTED_OR_UNCERTAIN'
        if time.time()-stamp>EVIDENCE_TTL:self.tracker.reset()
        return dict(image_source='HDMI',source_timestamp=stamp,source_ns=ns,object_source_ns=ns,
            object_detection_valid=True,object_rows=objects,evidence=evidence,model_display=model_display,type_arbitration=type_arbitration,
            source_array_sha256=hashlib.sha256(image.tobytes()).hexdigest(),
            finished_timestamp=time.time(),driving_permission='UNKNOWN',
            cpu_decode_seconds=decoded_at-started,cpu_association_seconds=associated_at-decoded_at,
            cpu_paint_seconds=context['seconds'],cpu_context_wait_seconds=prepared_at-associated_at,
            paint_backend=context.get('backend','rk_original'),
            cpu_geometry_seconds=geometry_at-prepared_at,
            cpu_observe_seconds=observed_at-objects_at,
            cpu_prepare_seconds=geometry_at-started,object_wait_seconds=objects_at-geometry_at,
            cpu_evidence_seconds=time.perf_counter()-objects_at)

class Worker:
    def __init__(self,hub,detector_factory=Detector,lane_factory=LaneModel,cpu_factory=LaneCPU,scene='INTERSECTION',reference_factory=ReferenceDetector,nav_profile='off'):
        if scene not in SCENES:raise ValueError(scene)
        self.scene=scene;self.mode_epoch=0
        self.hub=hub;self.detector_factory=detector_factory;self.lane_factory=lane_factory;self.cpu_factory=cpu_factory
        if nav_profile not in PROFILES:raise ValueError(nav_profile)
        self.nav_profile=nav_profile
        self.reference_factory=reference_factory
        self.lock=threading.Lock();self.results=dict(camera=None,hdmi=None);self.lane=None
        self.generation=0;self.hdmi_epoch=0;self.hdmi_barrier=-float('inf')
        self.error=None;self.ready=threading.Event();self.stopped=threading.Event()
        self.jobs=[];self.lane_jobs=[];self.lane_skipped_busy=0;self.lane_rejected_epoch=0;self.pending_count=0;self.lane_debug=None
        self.thread=threading.Thread(target=self.run,daemon=True);self.thread.start()
    def scene_snapshot(self):
        with self.lock:return self.scene,self.mode_epoch
    def set_scene(self,scene):
        if scene not in SCENES:raise ValueError(scene)
        with self.lock:
            if self.scene==scene:return False
            self.scene=scene;self.mode_epoch+=1
            self.generation+=1;self.hdmi_epoch+=1
            self.results=dict(camera=None,hdmi=None);self.lane=None;self.lane_debug=None
            return True
    def snapshot(self):
        with self.lock:return self.results.copy(),self.generation
    def lane_snapshot(self):
        with self.lock:return self.lane
    def publish_lane_display(self,row,epoch,hub_epoch,mode_epoch):
        
        
        with self.lock:
            if (self.stopped.is_set() or epoch!=(self.generation,self.hdmi_epoch)
                or hub_epoch!=self.hub.generation or mode_epoch!=self.mode_epoch
                or self.scene!='LANE_CHANGE'):return False
            stamp=row['source_timestamp'];now=time.time()
            if not 0<=now-stamp<=DISPLAY_TTL:return False
            self.results['lane_display']=dict(row,mode_epoch=mode_epoch,published_timestamp=now)
            return True
    def invalidate_hdmi(self,stamp):
        with self.lock:
            self.hdmi_epoch+=1;self.hdmi_barrier=stamp;self.results['hdmi']=None;self.lane=None
    def signal_feedback(self,status):pass 
    def invalidate_all(self):
        with self.lock:
            self.results=dict(camera=None,hdmi=None);self.lane=None
            self.generation+=1;self.hdmi_epoch+=1
    def lane_done(self,future,epoch,hub_epoch,debug,mode_epoch):
        try:
            row=future.result()
            row['published_timestamp']=time.time();row['mode_epoch']=mode_epoch
            with self.lock:
                accepted=epoch==(self.generation,self.hdmi_epoch) and hub_epoch==self.hub.generation
                if accepted:
                    self.lane=row;self.lane_debug=(row,debug)
                else:self.lane_rejected_epoch+=1
                self.lane_jobs.append(dict(source_ns=row['source_ns'],source_timestamp=row['source_timestamp'],
                    finished_timestamp=row.get('finished_timestamp'),published_timestamp=row['published_timestamp'],
                    accepted_epoch=accepted,status=row.get('evidence',{}).get('status'),
                    cpu={k:v for k,v in row.items() if k.startswith('cpu_') or k=='object_wait_seconds'},
                    candidates=[dict(side=r['image_side'],candidate=r['model_candidate'],
                        count=r.get('consecutive_frames',0)) for r in row.get('evidence',{}).get('sides',[])]))
                self.lane_jobs=self.lane_jobs[-600:]
        except BaseException as exc:
            self.error=traceback.format_exc();self.invalidate_all()
        finally:self.pending_count=0
    def interleave_camera(self,model,epoch,hub_epoch,mode_epoch,last_ns):





        with self.lock:
            if (self.scene!='LANE_CHANGE' or self.mode_epoch!=mode_epoch
                    or epoch!=(self.generation,self.hdmi_epoch)):return
        refresh=getattr(self.hub,'inference_pair',None)
        try:
            _,camera,stamp,ns=refresh() if refresh else read_pair(self.hub)
        except (OSError,ValueError):
            self.invalidate_all();return
        if self.hub.generation!=hub_epoch:
            self.invalidate_all();return
        if last_ns.get('camera')==ns:return
        begin=time.perf_counter();input_age=time.time()-stamp
        found,npu=model.detect(camera)
        finished=time.time()
        packet=dict(channel='camera',source_timestamp=stamp,source_ns=ns,detections=found,
                    region=[0,0,640,360],npu_seconds=npu,finished_timestamp=finished,mode_epoch=mode_epoch)
        with self.lock:
            accepted=(not self.stopped.is_set() and self.scene=='LANE_CHANGE'
                and self.mode_epoch==mode_epoch and epoch==(self.generation,self.hdmi_epoch)
                and self.hub.generation==hub_epoch)
            if accepted:self.results['camera']=packet
        if accepted:last_ns['camera']=ns
        self.jobs.append(dict(channel='camera',scene='LANE_CHANGE',mode_epoch=mode_epoch,
            source_ns=ns,source_timestamp=stamp,seconds=time.perf_counter()-begin,
            completed_age=finished-stamp,input_age=input_age,detections=found,
            interleaved=True,accepted=accepted,profile=dict(getattr(model,'last_profile',{}))))
        self.jobs=self.jobs[-600:]

    def run(self):
        model=lane_net=reference=None;focus=Focus();previous_signal_gray=None;future=None;pool=ThreadPoolExecutor(max_workers=1)
        last_ns={k:None for k in SCHEDULE};slot=0;previous_generation=None;previous_mode=None
        try:
            model=self.detector_factory();lane_net=self.lane_factory();reference=self.reference_factory();cpu=self.cpu_factory();self.ready.set()
            while not self.stopped.is_set():
                if future is not None and future.done():
                    future.result();future=None
                if self.error:raise RuntimeError(self.error)
                
                
                if future is not None:
                    with self.lock:
                        schedule_now=SCHEDULES[self.scene]
                        next_channel=schedule_now[slot % len(schedule_now)]
                    if next_channel!='camera':
                        self.stopped.wait(.005);continue
                try:
                    refresh=getattr(self.hub,'inference_pair',None)
                    colored=getattr(self.hub,'inference_colored',None)
                    painted=getattr(self.hub,'inference_painted',None)
                    paint_features=None
                    if painted:
                        hdmi,camera,stamp,ns,color_counts,hardware_fid,paint_features=painted()
                    elif colored:
                        hdmi,camera,stamp,ns,color_counts,hardware_fid=colored()
                    else:
                        hdmi,camera,stamp,ns=refresh() if refresh else read_pair(self.hub)
                        color_counts=None;hardware_fid=None
                except (OSError,ValueError):
                    if previous_generation is not None:self.invalidate_all();previous_generation=None
                    focus=Focus();previous_signal_gray=None
                    last_ns={k:None for k in SCHEDULE};self.stopped.wait(.02);continue
                hub_epoch=self.hub.generation
                if previous_generation is not None and hub_epoch!=previous_generation:
                    self.invalidate_all();focus=Focus();previous_signal_gray=None
                previous_generation=hub_epoch
                with self.lock:
                    scene=self.scene;mode_epoch=self.mode_epoch
                    if previous_mode!=mode_epoch:
                        focus=Focus();previous_signal_gray=None
                        slot=0;last_ns={k:None for k in SCHEDULE};previous_mode=mode_epoch
                    schedule=SCHEDULES[scene]
                    channel=schedule[slot];slot=(slot+1)%len(schedule)
                    epoch=(self.generation,self.hdmi_epoch)
                if last_ns[channel]==ns:self.stopped.wait(.005);continue
                if channel=='lane' and future is not None:self.lane_skipped_busy+=1;continue
                last_ns[channel]=ns
                started=time.perf_counter();input_age=time.time()-stamp
                if channel=='lane':
                    
                    
                    
                    
                    
                    prepare=getattr(cpu,'prepare',None)
                    prepare_args=(hdmi,paint_features) if getattr(cpu,'supports_paint_features',False) else (hdmi,)
                    context=pool.submit(prepare,*prepare_args) if prepare else None
                    outputs=lane_net.infer(hdmi);lane_inferred=time.perf_counter();object_result=Future();self.pending_count=1
                    kwargs=dict(image_context=context) if context is not None else {}
                    if getattr(cpu,'supports_early_display',False):
                        kwargs['display_sink']=lambda row,e=epoch,h=hub_epoch,m=mode_epoch:self.publish_lane_display(row,e,h,m)
                    future=pool.submit(cpu.process,hdmi,outputs,object_result,stamp,ns,epoch,**kwargs)
                    future.add_done_callback(lambda f,e=epoch,h=hub_epoch,d=(hdmi,outputs),m=mode_epoch:self.lane_done(f,e,h,d,m))
                    try:
                        
                        
                        priority_started=time.perf_counter()
                        self.interleave_camera(model,epoch,hub_epoch,mode_epoch,last_ns)
                        object_started=time.perf_counter()
                        objects,object_npu=model.detect(hdmi);object_finished=time.perf_counter();object_result.set_result(objects)
                    except BaseException as exc:
                        object_result.set_exception(exc);raise
                else:
                    region=[0,0,640,360];signal_result=None
                    if channel=='hdmi':
                        gray=cv2.cvtColor(hdmi,cv2.COLOR_BGR2GRAY)
                        if previous_signal_gray is not None and float(np.mean(cv2.absdiff(gray,previous_signal_gray)))>28:focus=Focus()
                        previous_signal_gray=gray
                        ref_raw,npu=reference.detect(hdmi)
                        ref_raw,screen_excluded=filter_screen_lights(ref_raw,self.nav_profile)
                        if color_counts is None:
                            raise ValueError('same-frame FPGA evidence required')
                        from fpga_signal import candidates as fpga_candidates
                        candidates=fpga_candidates(ref_raw,color_counts,hardware_fid)
                        backend='fpga_same_frame';fallback_raw=[]
                        
                        
                        ref_raw=[r for r in ref_raw if r['class_id'] not in (2,3,4,5)]+candidates
                        signal_result=focus.update(candidates,stamp,time.time())
                        signal_result.update(mode_epoch=mode_epoch,reference_raw=ref_raw,fallback_raw=fallback_raw,
                            selected_backend=backend,source_ns=ns,nav_profile=self.nav_profile,screen_excluded=screen_excluded)
                        found=candidates
                    else:found,npu=model.detect(camera)
                    packet=dict(channel=channel,source_timestamp=stamp,source_ns=ns,detections=found,
                        region=region,npu_seconds=npu,finished_timestamp=time.time(),mode_epoch=mode_epoch)
                    if signal_result is not None:
                        packet['night_candidates']=detect_night_candidates(hdmi) if scene=='NIGHT' else []
                        packet['hardware_frame_id']=hardware_fid
                        packet['signal']=signal_result
                        packet['reference_objects']=ref_raw
                        packet['weak_review_profile']=dict(getattr(reference,'last_profile',{}))
                    with self.lock:
                        if epoch[0]==self.generation and (channel!='hdmi' or epoch[1]==self.hdmi_epoch and stamp>=self.hdmi_barrier):
                            self.results[channel]=packet
                self.jobs.append(dict(channel=channel,scene=scene,mode_epoch=mode_epoch,source_ns=ns,source_timestamp=stamp,
                    seconds=time.perf_counter()-started,completed_age=time.time()-stamp,input_age=input_age,
                    detections=objects if channel=='lane' else found))
                self.jobs[-1]['profile']=dict(getattr(reference if channel=='hdmi' else model,'last_profile',{}))
                if channel=='lane':self.jobs[-1].update(lane_infer_seconds=lane_inferred-started,
                    camera_priority_seconds=object_started-priority_started,
                    object_total_seconds=object_finished-object_started,object_npu_seconds=object_npu)
                self.jobs=self.jobs[-600:]
        except BaseException as exc:self.error=traceback.format_exc();self.ready.set();self.invalidate_all()
        finally:
            pool.shutdown(wait=True)
            if lane_net is not None:lane_net.close()
            if reference is not None:reference.close()
            if model is not None:model.close()
            self.pending_count=0
    def close(self):
        self.stopped.set();self.thread.join(timeout=15)
        if self.thread.is_alive():raise RuntimeError('Unified inference shutdown timed out')
