
import json,math,os,select,sys,time
from calibration import Controller
from sensor import LinuxI2C,configure,identify,read_sample


def checked_update(controller,now,sample,elapsed):
    if elapsed>.1:
        
        
        return Controller(),dict(phase='FAULT',reason='READ_OVER_100MS',
                                 requested_motion='STOP',event=None)
    return controller,controller.update(now,sample)


def run():
    device=None
    try:
        device=LinuxI2C(5,0x69);identify(device);configure(device)
        controller=Controller();epoch=seq=0
        pending=b'';last_publish=0;action=None;deadline=time.monotonic()
        while True:
            
            readable,_,_=select.select([0],[],[],0)
            commands=[]
            if readable:
                data=os.read(0,4096)
                if not data:break
                pending+=data
                if len(pending)>8192:raise RuntimeError('command overflow')
                while b'\n' in pending:
                    line,pending=pending.split(b'\n',1);commands.append(json.loads(line))
            for cmd in commands:
                if cmd['epoch']<=epoch:continue
                epoch=cmd['epoch']
                if cmd.get('preserve_calibration'):controller.stop_preserving_calibration()
                else:controller.command(cmd['neutral'])
                action=None
            time.sleep(max(0,deadline-time.monotonic()))
            before=time.monotonic();sample=read_sample(device);now=time.monotonic()
            controller,result=checked_update(controller,now,sample,now-before)
            if result['phase']=='FAULT':action=None
            result.update(norm_g=math.sqrt(sum(v*v for v in sample['accel_g'])),
                          read_ms=(now-before)*1000,
                          raw_gyro_dps=sample['gyro_dps'],accel_g=sample['accel_g'])
            event=result.get('event')
            if event and event!='NEUTRAL_SET':action=dict(name=event,timestamp=now)
            if event or result['phase']=='FAULT' or now-last_publish>=.03:
                seq+=1
                print(json.dumps(dict(seq=seq,epoch=epoch,sample_time=now,gesture=result,action=action),allow_nan=False),flush=True)
                last_publish=now
            deadline=max(deadline+.01,now)
    finally:
        if device is not None:device.close()


if __name__=='__main__':run()
