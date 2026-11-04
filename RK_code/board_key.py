
import argparse, json, os, queue, select, struct, subprocess, sys, threading, time

DEVICE = '/dev/input/by-path/platform-adc-keys-event'

class Gesture:
    def __init__(self):
        self.pressed = None
        self.last_release = -float('inf')
        self.blocked = False
        self.desynced = False
        self.last_action = None
        self.held_seconds = None
        self.long_fired = False
        self.down_monotonic = None
    def poll(self, now):
        
        self.last_action = None
        if self.pressed is None or self.blocked or self.desynced or self.long_fired:
            return False
        held = now-self.down_monotonic
        if held < 0:
            self.blocked = True
            return False
        if held >= 2:
            self.long_fired = True
            self.held_seconds = held
            self.last_action = 'RECENTER'
            return True
        return False
    def feed(self, kind, code, value, stamp, now, monotonic=None):
        self.last_action = None
        if kind == 0 and code == 3:  
            self.pressed = None
            self.down_monotonic = None
            self.desynced = True
            return False
        if kind == 0 and code == 0:
            self.desynced = False
            return False
        if self.desynced:
            return False
        if kind != 1 or code != 115:
            return False
        if not 0 <= now-stamp <= .5:
            self.pressed = None
            self.blocked = True
            return False
        if value == 1:
            if self.pressed is not None or stamp-self.last_release < .15:
                self.blocked = True
            if not self.blocked:
                self.pressed = stamp
                self.down_monotonic = now if monotonic is None else monotonic
                self.long_fired = False
        elif value == 0:
            held = stamp-self.pressed if self.pressed is not None else -1
            self.pressed = None
            self.last_release = stamp
            
            accepted = not self.blocked and not self.long_fired and .08 <= held < 2
            self.held_seconds = held
            self.last_action = 'NEXT_SCENE' if accepted else None
            self.blocked = False
            self.down_monotonic = None
            return accepted
        return False  

def helper(device):
    fd = os.open(device, os.O_RDONLY | os.O_NONBLOCK)
    event = struct.Struct('@llHHi')
    
    import fcntl
    name = bytearray(256)
    fcntl.ioctl(fd, 0x81004506, name)  
    if name.split(b'\0')[0] != b'adc-keys':
        os.close(fd)
        raise RuntimeError('Expected adc-keys input device')
    print(json.dumps(dict(ready=True, device=device, exclusive=False)), flush=True)
    pending = b''
    try:
        while True:
            ready, _, _ = select.select([fd, 0], [], [], 1)
            if 0 in ready and not os.read(0, 1):
                break  
            if fd not in ready:
                continue
            data = os.read(fd, 4096)
            if not data:
                raise RuntimeError('Input device disconnected')
            pending += data
            while len(pending) >= event.size:
                sec, usec, kind, code, value = event.unpack(pending[:event.size])
                pending = pending[event.size:]
                if kind == 1 or (kind == 0 and code in (0, 3)):
                    print(json.dumps(dict(kind=kind, code=code, value=value, timestamp=sec+usec/1e6)), flush=True)
    finally:
        os.close(fd)

class BoardKey:
    def __init__(self, device=DEVICE):
        self.events = queue.Queue(maxsize=8)
        self.error = None
        self.ready = threading.Event()
        self.stopped = threading.Event()
        self.process = subprocess.Popen(['sudo', '-n', sys.executable, '-u', os.path.abspath(__file__),
                                         '--reader', '--device', device], stdin=subprocess.PIPE,
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.thread = threading.Thread(target=self.run, daemon=True)
        self.thread.start()
    def run(self):
        gesture = Gesture()
        pending = b''
        try:
            while not self.stopped.is_set():
                ready, _, _ = select.select([self.process.stdout], [], [], .1)
                if not ready:
                    if self.process.poll() is not None:
                        raise RuntimeError('Key reader exited: '+self.process.stderr.read()[-500:])
                else:
                    data = os.read(self.process.stdout.fileno(), 4096)
                    if not data:
                        raise RuntimeError('Key reader disconnected: '+self.process.stderr.read()[-500:])
                    pending += data
                while b'\n' in pending:
                    line, pending = pending.split(b'\n', 1)
                    row = json.loads(line)
                    if row.get('ready'):
                        self.ready.set()
                    elif gesture.feed(row['kind'], row['code'], row['value'], row['timestamp'], time.time(), time.monotonic()):
                        self.events.put_nowait(dict(timestamp=row['timestamp'], action=gesture.last_action, held_seconds=gesture.held_seconds))
                
                if gesture.poll(time.monotonic()):
                    self.events.put_nowait(dict(timestamp=time.time(),action=gesture.last_action,held_seconds=gesture.held_seconds))
        except BaseException as exc:
            self.error = type(exc).__name__+': '+str(exc)
            while not self.events.empty():
                self.events.get_nowait()
        finally:
            self.ready.set()
    def drain(self):
        rows = []
        while True:
            try:
                row = self.events.get_nowait()
            except queue.Empty:
                return rows
            if 0 <= time.time()-row['timestamp'] <= .5:
                rows.append(row)
    def close(self):
        self.stopped.set()
        if self.process.stdin:
            self.process.stdin.close()
        self.process.wait(timeout=3)
        self.thread.join(timeout=2)
        if self.thread.is_alive():
            raise RuntimeError('Key reader shutdown timed out')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--reader', action='store_true')
    parser.add_argument('--device', default=DEVICE)
    args = parser.parse_args()
    if not args.reader:
        parser.error('This is an internal read-only input helper')
    helper(args.device)
