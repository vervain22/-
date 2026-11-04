
import threading
import traceback
import time
from pipeline import read_pair,usable,cv2,np

TRACK_TTL=.8
GEOMETRY_TTL=.25


def seed_points(gray,box):
    x1,y1,x2,y2=np.rint(box).astype(int)
    x1=max(0,x1); y1=max(0,y1); x2=min(gray.shape[1],x2); y2=min(gray.shape[0],y2)
    if x2-x1<8 or y2-y1<8:return None
    pts=cv2.goodFeaturesToTrack(gray[y1:y2,x1:x2],24,.02,3)
    if pts is None or len(pts)<4:return None
    return pts+np.asarray([x1,y1],np.float32)


def appearance(gray,box):
    x1,y1,x2,y2=np.rint(box).astype(int)
    if x1<0 or y1<0 or x2>gray.shape[1] or y2>gray.shape[0] or x2-x1<8 or y2-y1<8:return None
    return cv2.resize(gray[y1:y2,x1:x2],(24,24)).astype(np.float32)


class Tracker:
    def __init__(self):
        self.tracks=[]; self.previous=None; self.last_stamp=None; self.last_ns=None
        self.packet_ns=None; self.barrier=-float('inf')

    def reset(self,stamp=None):
        self.tracks=[]; self.previous=None; self.last_stamp=None; self.last_ns=None
        if stamp is not None:self.barrier=stamp

    def advance(self,gray):
        if not self.tracks or self.previous is None:return
        points=np.concatenate([t['points'] for t in self.tracks])
        
        flat=points[:,0]; left=max(0,int(np.floor(flat[:,0].min()))-48)
        top=max(0,int(np.floor(flat[:,1].min()))-48)
        right=min(gray.shape[1],int(np.ceil(flat[:,0].max()))+49)
        bottom=min(gray.shape[0],int(np.ceil(flat[:,1].max()))+49)
        origin=np.asarray([left,top],np.float32); local=points-origin
        before=self.previous[top:bottom,left:right]; current=gray[top:bottom,left:right]
        nxt,ok,_=cv2.calcOpticalFlowPyrLK(before,current,local,None,winSize=(21,21),maxLevel=2)
        if nxt is None or ok is None:self.tracks=[]; return
        back,bok,_=cv2.calcOpticalFlowPyrLK(current,before,nxt,None,winSize=(21,21),maxLevel=2)
        if back is None or bok is None:self.tracks=[]; return
        nxt+=origin; back+=origin
        valid=(ok.ravel()!=0)&(bok.ravel()!=0)&(np.linalg.norm(back-points,axis=2).ravel()<1.)
        retained=[]; offset=0
        for track in self.tracks:
            n=len(track['points']); chosen=valid[offset:offset+n]
            a=points[offset:offset+n][chosen]; b=nxt[offset:offset+n][chosen]; offset+=n
            if len(a)<4 or len(a)<n*.6:continue
            delta=(b-a)[:,0]; shift=np.median(delta,axis=0)
            if np.max(np.abs(shift))>40 or np.median(np.linalg.norm(delta-shift,axis=1))>2.5:continue
            box=np.asarray(track['box'])+np.tile(shift,2)
            old=appearance(self.previous,track['box']); new=appearance(gray,box)
            if old is None or new is None or np.std(old)<6 or np.std(new)<6:continue
            corr=float(np.corrcoef(old.ravel(),new.ravel())[0,1])
            if not np.isfinite(corr) or corr<.75 or float(np.mean(np.abs(old-new)))>35:continue
            
            anchor=track['anchor']
            anchor_corr=float(np.corrcoef(anchor.ravel(),new.ravel())[0,1])
            if not np.isfinite(anchor_corr) or anchor_corr<.65:continue
            pts=seed_points(gray,box)
            if pts is None:continue
            retained.append(dict(track,box=box.tolist(),points=pts,quality=min(corr,anchor_corr)))
        self.tracks=retained

    def update(self,image,stamp,ns,packet,source_image):
        gray=cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
        if self.last_stamp is not None and (stamp<=self.last_stamp or stamp-self.last_stamp>.25):
            if ns==self.last_ns:return self.rows(stamp)
            self.reset(stamp)
        if self.previous is not None and float(np.mean(cv2.absdiff(gray,self.previous)))>28:self.reset(stamp)
        new=bool(packet and packet['source_ns']!=self.packet_ns)
        if new:
            self.packet_ns=packet['source_ns']
            if usable(packet,time.time(),stamp) and packet['source_timestamp']>=self.barrier and not packet['detections']:
                self.tracks=[]
            elif (usable(packet,time.time(),stamp) and packet['source_timestamp']>=self.barrier
                    and source_image is not None):
                source_gray=cv2.cvtColor(source_image,cv2.COLOR_BGR2GRAY)
                self.tracks=[]
                for index,row in enumerate(packet['detections'][:12]):
                    pts=seed_points(source_gray,row['box']); anchor=appearance(source_gray,row['box'])
                    if pts is None or anchor is None or np.std(anchor)<6:continue
                    self.tracks.append(dict(row,points=pts,anchor=anchor,quality=1.,detection_index=index,
                        detection_timestamp=packet['source_timestamp'],detection_ns=packet['source_ns']))
                self.previous=source_gray
        self.tracks=[t for t in self.tracks if 0<=stamp-t['detection_timestamp']<=TRACK_TTL]
        if self.previous is not None:self.advance(gray)
        self.previous=gray; self.last_stamp=stamp; self.last_ns=ns
        return self.rows(stamp)

    def rows(self,stamp):
        return [dict(box=t['box'],class_id=t['class_id'],label=t['label'],score=t['score'],
            detection_timestamp=t['detection_timestamp'],geometry_timestamp=stamp,
            detection_ns=t['detection_ns'],detection_index=t['detection_index'],
            geometry_expires_at=min(stamp+GEOMETRY_TTL,t['detection_timestamp']+TRACK_TTL),
            quality=t['quality'],mode='DETECT+FLOW' if stamp-t['detection_timestamp']<=.5 else 'TRACK')
            for t in self.tracks]


class CameraWorker:
    def __init__(self,npu,hub):
        self.npu=npu; self.hub=hub; self.latest=dict(rows=[],source_timestamp=0)
        self.error=None; self.stopped=threading.Event()
        self.thread=threading.Thread(target=self.run,daemon=True); self.thread.start()

    def run(self):
        tracker=Tracker(); previous_ns=None; generation=None; mode_generation=None
        try:
            while not self.stopped.is_set():
                if self.stopped.wait(.06):break
                scene,mode_epoch=self.npu.scene_snapshot()
                if mode_generation!=mode_epoch:
                    tracker=Tracker();previous_ns=None;mode_generation=mode_epoch
                    self.latest=dict(rows=[],source_timestamp=0)
                try:_,camera,stamp,ns=read_pair(self.hub)
                except (OSError,ValueError):
                    tracker.reset(time.time()); self.latest=dict(rows=[],source_timestamp=0)
                    self.stopped.wait(.02); continue
                if generation is not None and generation!=self.hub.generation:tracker.reset(stamp)
                generation=self.hub.generation
                if ns==previous_ns:self.stopped.wait(.005); continue
                previous_ns=ns; packet=self.npu.snapshot()[0]['camera']
                source=self.hub.camera_source(packet['source_ns']) if packet else None
                begin=time.perf_counter(); rows=tracker.update(camera,stamp,ns,packet,source)
                if self.npu.scene_snapshot()==(scene,mode_epoch):
                    self.latest=dict(rows=rows,source_timestamp=stamp,source_ns=ns,mode_epoch=mode_epoch,
                        tracking_seconds=time.perf_counter()-begin)
        except BaseException as exc:
            self.error=traceback.format_exc(); self.latest=dict(rows=[],source_timestamp=0)

    def close(self):
        self.stopped.set(); self.thread.join(timeout=3)
        if self.thread.is_alive():raise RuntimeError('Camera tracker shutdown timed out')
