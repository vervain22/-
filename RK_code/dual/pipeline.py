
from pathlib import Path
import os
import threading
import time
from detector import Detector, CLASSES, SIGNAL_CLASSES, windows, cv2, np

RAW=Path('/dev/shm/fpga_current_frame_1280x720.rgb565')
TTL=.5


def read_pair(path=RAW):
    if hasattr(path,'read_pair'):return path.read_pair()
    with Path(path).open('rb') as stream:
        before=os.fstat(stream.fileno()); raw=stream.read(1843201); after=os.fstat(stream.fileno())
    if len(raw)!=1843200 or before.st_mtime_ns!=after.st_mtime_ns:
        raise ValueError('invalid_frame')
    if not -.1<=time.time()-after.st_mtime<=TTL:
        raise ValueError('stale_frame')
    pixels=np.frombuffer(raw,np.uint8).reshape(720,1280,2)[:,:640]
    image=cv2.cvtColor(pixels,cv2.COLOR_BGR5652BGR)
    return image[:360],image[360:],after.st_mtime,after.st_mtime_ns


def usable(packet,now,frame_stamp):
    return bool(packet and -.1<=now-packet['source_timestamp']<=TTL
                and -.1<=now-frame_stamp<=TTL and packet['source_timestamp']<=frame_stamp)


class Worker:
    def __init__(self,raw=RAW,factory=Detector):
        self.raw=raw; self.factory=factory
        self.lock=threading.Lock(); self.results={'camera':None,'hdmi':None}
        self.hdmi_barrier=-float('inf'); self.hdmi_epoch=0; self.generation=0
        self.signal_status=None; self.last_hdmi_source=None
        self.hdmi_skipped=0
        self.error=None; self.ready=threading.Event(); self.stopped=threading.Event()
        self.thread=threading.Thread(target=self.run,daemon=True); self.thread.start()

    def snapshot(self):
        with self.lock:return self.results.copy(),self.generation

    def invalidate_hdmi(self,stamp):
        with self.lock:
            self.hdmi_barrier=stamp; self.hdmi_epoch+=1
            self.results['hdmi']=None

    def signal_feedback(self,status):
        with self.lock:self.signal_status=status

    def run(self):
        model=None; schedule=('camera','camera','hdmi'); slot=0
        last_ns={'camera':None,'hdmi':None}; last_stamp=None
        try:
            model=self.factory(); self.ready.set()
            while not self.stopped.is_set():
                channel=schedule[slot]
                
                
                
                if channel=='hdmi':
                    with self.lock:status=self.signal_status
                    now=time.time()
                    if (status and status.get('valid') and now<=status.get('expires_at',0)
                            and now<status.get('redetect_after',0)):
                        self.hdmi_skipped+=1
                        slot=(slot+1)%len(schedule)
                        continue
                started=time.perf_counter()
                try:hdmi,camera,stamp,ns=read_pair(self.raw)
                except (OSError,ValueError):
                    with self.lock:
                        if any(v is not None for v in self.results.values()):self.generation+=1
                        self.results={'camera':None,'hdmi':None}
                    last_ns={'camera':None,'hdmi':None}; last_stamp=None
                    self.stopped.wait(.02); continue
                read_seconds=time.perf_counter()-started
                if last_stamp is not None and (stamp<last_stamp or stamp-last_stamp>TTL):
                    with self.lock:
                        self.generation+=1; self.results={'camera':None,'hdmi':None}
                    last_ns={'camera':None,'hdmi':None}
                last_stamp=stamp
                if last_ns[channel]==ns:
                    slot=(slot+1)%len(schedule)
                    self.stopped.wait(.005); continue
                last_ns[channel]=ns
                begin=time.perf_counter()
                if channel=='camera':
                    region=[0,0,640,360]; scanned=None
                    image=camera; classes=CLASSES
                else:
                    scanned=-1
                    region=windows('upper_center')[0]
                    x1,y1,x2,y2=region; image=hdmi[y1:y2,x1:x2]; classes=SIGNAL_CLASSES
                input_age=time.time()-stamp
                with self.lock:job_epoch=self.hdmi_epoch
                found,npu=model.detect(image,classes=classes)
                if channel=='hdmi':
                    x1,y1,_,_=region
                    found=[dict(row,box=(np.asarray(row['box'])+[x1,y1,x1,y1]).tolist()) for row in found]
                finished=time.time()
                packet=dict(channel=channel,source_timestamp=stamp,source_ns=ns,
                    finished_timestamp=finished,detections=found,region=list(region),tile=scanned,
                    input_age=input_age,read_seconds=read_seconds,npu_seconds=npu,
                    detector_profile=dict(getattr(model,'last_profile',{})),
                    total_seconds=time.perf_counter()-begin,age_at_completion=finished-stamp)
                with self.lock:
                    if channel!='hdmi' or (stamp>=self.hdmi_barrier and job_epoch==self.hdmi_epoch):
                        self.results[channel]=packet
                        if channel=='hdmi':self.last_hdmi_source=stamp
                slot=(slot+1)%len(schedule)
        except BaseException as exc:
            with self.lock:
                self.results={'camera':None,'hdmi':None}; self.generation+=1
            self.error=repr(exc); self.ready.set()
        finally:
            if model is not None:model.close()

    def close(self):
        self.stopped.set(); self.thread.join(timeout=5)
        if self.thread.is_alive():raise RuntimeError('NPU shutdown timed out')
