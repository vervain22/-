
import threading
class SignalWorker:
    def __init__(self,npu,raw,logger):
        self.npu=npu;self.error=None;self.stopped=threading.Event()
        self.latest=dict(valid=False,state='UNKNOWN',tracks=[],reason='initializing')
        self.thread=threading.Thread(target=self.run,daemon=True);self.thread.start()
    def run(self):
        while not self.stopped.wait(.01):
            scene,epoch=self.npu.scene_snapshot();packets,_=self.npu.snapshot();p=packets.get('hdmi')
            if scene not in ('INTERSECTION','NIGHT') or not p or p.get('mode_epoch')!=epoch:
                self.latest=dict(valid=False,state='UNKNOWN',tracks=[],reason='mode_disabled_or_switching',mode_epoch=epoch)
            else:self.latest=dict(p.get('signal',{}),mode_epoch=epoch)
    def close(self):self.stopped.set();self.thread.join(timeout=2)
