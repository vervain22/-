
import collections
import threading
import time
from pathlib import Path
from pipeline import read_pair,TTL


class FrameHub:
    def __init__(self,path):
        self.path=Path(path); self.lock=threading.Lock(); self.latest=None
        self.history=collections.deque(maxlen=12); self.error='initializing'; self.generation=0
        self.stopped=threading.Event(); self.reads=0; self.last_read_seconds=0
        self.thread=threading.Thread(target=self.run,daemon=True); self.thread.start()

    def run(self):
        while not self.stopped.is_set():
            try:
                stat=self.path.stat()
                with self.lock:previous=self.latest
                if previous and stat.st_mtime_ns==previous[3]:
                    if not -.1<=time.time()-previous[2]<=TTL:raise ValueError('stale_frame')
                    self.stopped.wait(.005); continue
                begin=time.perf_counter(); frame=read_pair(self.path)
                elapsed=time.perf_counter()-begin
                
                frame[0].flags.writeable=False; frame[1].flags.writeable=False
                with self.lock:
                    if previous and (frame[2]<=previous[2] or frame[2]-previous[2]>TTL):
                        self.history.clear(); self.generation+=1
                    self.latest=frame; self.history.append(frame); self.error=None
                    self.reads+=1; self.last_read_seconds=elapsed
            except (OSError,ValueError) as exc:
                with self.lock:
                    if self.latest is not None:self.generation+=1
                    self.latest=None; self.history.clear(); self.error=str(exc)
            self.stopped.wait(.005)

    def read_pair(self):
        with self.lock:frame=self.latest; error=self.error
        if frame is None:raise ValueError(error or 'missing_frame')
        if not -.1<=time.time()-frame[2]<=TTL:raise ValueError('stale_frame')
        return frame

    def camera_source(self,ns):
        with self.lock:
            for frame in reversed(self.history):
                if frame[3]==ns:return frame[1]
        return None

    def close(self):
        self.stopped.set(); self.thread.join(timeout=3)
        if self.thread.is_alive():raise RuntimeError('Frame reader shutdown timed out')
