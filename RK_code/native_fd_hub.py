
import os,time,threading
import cv2,numpy as np
from demand_hub import DemandHub
from pipeline import TTL
from native_fd_receiver import decode_fd
class NativeFDHub(DemandHub):
    def __init__(self,path):
        self.colored=None;self.painted=None;self.last_fid=None;self.last_new=0
        self.prefetch=threading.Event();self.prefetch.set();self.consumed_ns=None
        super().__init__(path)
    def run(self):
        
        
        while not self.stopped.is_set():
            if not self.prefetch.wait(.05):continue
            self.prefetch.clear()
            if self.stopped.is_set():break
            with self.lock:
                frame=self.latest;consumed=self.consumed_ns
            
            
            if frame is not None and frame[3]!=consumed and 0<=time.time()-frame[2]<=TTL:continue
            try:self.refresh()
            except (OSError,ValueError):pass
    def read_pair(self):
        try:
            frame=super().read_pair()
            with self.lock:self.consumed_ns=frame[3]
            return frame
        finally:
            
            
            self.prefetch.set()
    def refresh(self):
        with self.refresh_lock:
            try:
                begin=time.perf_counter()
                with self.path.open('rb') as f:
                    stat=os.fstat(f.fileno())
                    with self.lock:previous=self.latest
                    if previous is not None and stat.st_mtime_ns==previous[3]:
                        if not -.1<=time.time()-previous[2]<=TTL:raise ValueError('stale_frame')
                        if time.time()-self.last_new>TTL:raise ValueError('stale_hardware_frame')
                        return previous
                    decoded=decode_fd(f.fileno())
                fid,hdmi,camera,counts,features=decoded;now=time.time()
                if not -.1<=now-stat.st_mtime<=TTL:raise ValueError('stale_frame')
                if fid==self.last_fid:
                    if now-self.last_new>TTL:raise ValueError('stale_hardware_frame')
                    with self.lock:
                        if self.latest is not None:return self.latest
                convert=lambda a:cv2.cvtColor(a.view(np.uint8).reshape(360,640,2),cv2.COLOR_BGR5652BGR)
                frame=(hdmi,camera,stat.st_mtime,stat.st_mtime_ns)
                for x in (frame[0],frame[1],counts):x.flags.writeable=False
                if features is not None:features.flags.writeable=False
                with self.lock:
                    if self.last_fid is not None and (fid<self.last_fid or now-self.last_new>TTL):
                        self.history.clear();self.generation+=1
                    self.last_fid=fid;self.last_new=now
                    self.latest=frame;self.colored=(*frame,counts,fid)
                    self.painted=(*frame,counts,fid,features)
                    self.history.append(frame);self.error=None;self.reads+=1
                    self.last_read_seconds=time.perf_counter()-begin
                return frame
            except (OSError,ValueError) as exc:
                with self.lock:
                    if self.latest is not None:self.generation+=1
                    self.latest=None;self.colored=None;self.painted=None;self.history.clear();self.error=str(exc)
                raise
    def inference_colored(self):
        self.refresh()
        
        
        with self.lock:
            if self.colored is None:raise ValueError(self.error)
            return self.colored
    def inference_painted(self):
        self.refresh()
        with self.lock:
            if self.painted is None:raise ValueError(self.error)
            return self.painted
