
import ctypes
import gc
import time
from collections import deque
from pathlib import Path


class MemoryGuard:
    def __init__(self, interval=30):
        self.interval = interval
        self.last = time.monotonic()
        self.rows = deque(maxlen=40)
        try:
            self.trim = ctypes.CDLL(None).malloc_trim
            self.trim.argtypes = [ctypes.c_size_t]
            self.trim.restype = ctypes.c_int
        except (AttributeError, OSError):
            self.trim = None

    @staticmethod
    def status():
        keys = ('VmRSS', 'RssAnon', 'RssFile', 'RssShmem', 'VmHWM')
        try:
            return {k: int(v.split()[0]) for k, v in
                    (line.split(':', 1) for line in Path('/proc/self/status').read_text().splitlines()
                     if ':' in line) if k in keys}
        except OSError:
            return {}

    def poll(self):
        now = time.monotonic()
        if now - self.last < self.interval:
            return None
        self.last = now
        before = self.status()
        start = time.perf_counter()
        collected = gc.collect()
        trimmed = self.trim(0) if self.trim else None
        row = dict(timestamp=time.time(), before_kb=before, after_kb=self.status(),
                   gc_collected=collected, malloc_trim=trimmed,
                   maintenance_seconds=time.perf_counter()-start)
        self.rows.append(row)
        return dict(samples=list(self.rows),interval_seconds=self.interval)
