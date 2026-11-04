
import copy,json,math,os,select,subprocess,sys,threading,time
from pathlib import Path


class Lease:
    def __init__(self):
        self.epoch=0;self.seq=-1;self.row=None;self.armed=False;self.faulted=False;self.reason='WAIT_SENSOR'

    def command(self,neutral):
        self.epoch+=1;self.row=None;self.armed=bool(neutral);self.faulted=False;self.reason='WAIT_ACK'
        return dict(epoch=self.epoch,neutral=bool(neutral))

    def fail(self,reason):
        if self.faulted:return  
        self.faulted=True;self.armed=False;self.reason=reason

    def feed(self,row,now):
        if row['epoch']!=self.epoch:return
        stamp=row['sample_time'];seq=row['seq']
        if not isinstance(seq,int) or isinstance(seq,bool) or seq<=self.seq:
            self.fail('BAD_SEQUENCE');return
        if not isinstance(stamp,(int,float)) or not math.isfinite(stamp) or not 0<=now-stamp<=.2:
            self.fail('EXPIRED_SAMPLE');return
        self.seq=seq;self.row=copy.deepcopy(row)
        if row['gesture']['phase']=='FAULT':self.fail(row['gesture'].get('reason') or 'SENSOR_FAULT')

    def snapshot(self,now):
        if self.row and not 0<=now-self.row['sample_time']<=.2:self.fail('LINK_TIMEOUT')
        base=dict(connected=False,phase=self.reason,requested_motion='STOP',rearm_ready=False,
                  roll_error_deg=None,pitch_error_deg=None,relative_twist_deg=0,epoch=self.epoch,
                  simulated_view='FRONT',vehicle_control_enabled=False)
        base['last_gesture']=None
        base['request']=None
        if self.faulted or self.row is None:return base
        g=copy.deepcopy(self.row['gesture']);base.update(g,connected=True)
        if not self.armed:
            base.update(requested_motion='STOP',rearm_ready=False)
            if g['phase'] in ('READY','TILT_LOCKED','TWIST_LOCKED'):base['phase']='WAIT_HAND_NEUTRAL'
        elif g['phase'] not in ('READY','TILT_LOCKED','TWIST_LOCKED'):
            base['requested_motion']='STOP'
        motion=base['requested_motion'];base['simulated_view']='REAR' if motion=='REVERSE' else 'FRONT'
        action=self.row.get('action')
        if (self.armed and g['phase'] in ('READY','TILT_LOCKED','TWIST_LOCKED') and action
                and isinstance(action.get('timestamp'),(int,float)) and math.isfinite(action['timestamp'])
                and 0<=now-action['timestamp']<=.5):
            base['request']=dict(name=action['name'],stamp=action['timestamp'],epoch=self.epoch,
                                 age_s=now-action['timestamp'])
        
        if action and isinstance(action.get('timestamp'),(int,float)) and math.isfinite(action['timestamp']) and 0<=now-action['timestamp']:
            base['last_gesture']=dict(name=action['name'],age_s=now-action['timestamp'],history_only=True)
        if self.armed and motion=='FORWARD' and action and 0<=now-action['timestamp']<=2:
            base['simulated_view']={'LANE_LEFT':'LEFT_REAR','LANE_RIGHT':'RIGHT_REAR','TURN_LEFT':'LEFT','TURN_RIGHT':'RIGHT'}.get(action['name'],'FRONT')
        return base


class ImuLink:
    def __init__(self,command=None):
        self.lock=threading.Lock();self.lease=Lease();self.stopped=threading.Event();self.error=None
        self.process=subprocess.Popen(command or ['sudo','-n',sys.executable,'-u',str(Path(__file__).parent/'imu/helper.py')],
            stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,bufsize=0)
        os.set_blocking(self.process.stdin.fileno(),False)
        os.set_blocking(self.process.stderr.fileno(),False)
        self.thread=threading.Thread(target=self.run,daemon=True);self.thread.start()

    def reset(self,neutral=False,preserve_calibration=False):
        with self.lock:
            healthy = (self.lease.snapshot(time.monotonic()).get('phase') in
                       ('READY','TILT_LOCKED','TWIST_LOCKED') and not self.lease.faulted)
            cmd=self.lease.command(neutral or (preserve_calibration and healthy))
            cmd['preserve_calibration']=bool(preserve_calibration and healthy)
            try:
                data=(json.dumps(cmd)+'\n').encode()
                if os.write(self.process.stdin.fileno(),data)!=len(data):raise RuntimeError('partial command')
            except (OSError,RuntimeError) as exc:self.lease.fail('COMMAND_FAILED');self.error=str(exc)

    def snapshot(self):
        with self.lock:return dict(self.lease.snapshot(time.monotonic()),link_error=self.error)

    def run(self):
        pending=b''
        try:
            while not self.stopped.is_set():
                ready,_,_=select.select([self.process.stdout],[],[],.02)
                if ready:
                    data=os.read(self.process.stdout.fileno(),65536)
                    if not data:raise RuntimeError('sensor helper exited')
                    pending+=data
                    if len(pending)>262144:raise RuntimeError('sensor packet overflow')
                    with self.lock:
                        while b'\n' in pending:
                            line,pending=pending.split(b'\n',1)
                            self.lease.feed(json.loads(line),time.monotonic())
                if self.process.poll() is not None:raise RuntimeError('sensor helper exited')
                
                with self.lock:self.lease.snapshot(time.monotonic())
        except BaseException as exc:
            self.error=str(exc)
            try:
                detail=os.read(self.process.stderr.fileno(),32768).decode(errors='replace').strip()
                if detail:self.error+=': '+detail
            except (OSError,BlockingIOError):pass
            print('MPU link error: '+self.error,file=sys.stderr,flush=True)
            with self.lock:self.lease.fail('LINK_ERROR')

    def close(self):
        self.stopped.set()
        with self.lock:self.lease.fail('CLOSED')
        self.process.stdin.close()
        try:self.process.wait(timeout=1)
        except subprocess.TimeoutExpired:
            
            
            
            self.error=self.error or 'helper read still blocked after EOF'
        self.thread.join(timeout=1)
        if not self.thread.is_alive() and self.process.poll() is not None:
            self.process.stdout.close();self.process.stderr.close()
