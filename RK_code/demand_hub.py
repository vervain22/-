
import threading,time
from pipeline import read_pair,TTL
from frame_hub import FrameHub

class DemandHub(FrameHub):
    def __init__(self,path):
        self.refresh_lock=threading.Lock()
        super().__init__(path)

    def refresh(self):
        
        with self.refresh_lock:
            try:
                stat=self.path.stat()
                with self.lock:previous=self.latest
                if previous and stat.st_mtime_ns==previous[3]:
                    if not 0<=time.time()-previous[2]<=TTL:raise ValueError('stale_frame')
                    return previous
                begin=time.perf_counter();frame=read_pair(self.path)
                frame[0].flags.writeable=False;frame[1].flags.writeable=False
                with self.lock:
                    if previous and (frame[2]<=previous[2] or frame[2]-previous[2]>TTL):
                        self.history.clear();self.generation+=1
                    self.latest=frame;self.history.append(frame);self.error=None
                    self.reads+=1;self.last_read_seconds=time.perf_counter()-begin
                return frame
            except (OSError,ValueError) as exc:
                with self.lock:
                    if self.latest is not None:self.generation+=1
                    self.latest=None;self.history.clear();self.error=str(exc)
                raise

    def inference_pair(self):return self.refresh()

    def run(self):
        while not self.stopped.is_set():
            try:self.refresh()
            except (OSError,ValueError):pass
            self.stopped.wait(.005)
