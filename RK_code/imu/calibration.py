
import math
from pose import Pose
from gestures import Gestures


class Controller:
    def __init__(self):
        self.pose = Pose()
        self.g = Gestures()
        self.active = False

    def command(self, neutral):
        self.active = neutral is True
        self.g.request_neutral()
        if self.active:
            self.pose.reset()

    def stop_preserving_calibration(self):
        
        
        calibrated = (self.active and self.pose.bias is not None
                      and self.g.phase in ('READY','TILT_LOCKED','TWIST_LOCKED'))
        self.g.request_neutral()
        if calibrated:
            self.g.center = (0.0, 0.0)
            self.g.phase = 'TILT_LOCKED'
        else:
            self.active = False

    def update(self, now, sample):
        if not self.active:
            return dict(phase='WAIT_HAND_NEUTRAL', requested_motion='STOP', event=None)
        p = self.pose.update(now, sample)
        if p['status'] != 'READY':
            return dict(phase='HAND_CALIBRATING', requested_motion='STOP', event=None,
                        calibration_progress_s=p['progress_s'], calibration_reason=p['reason'])
        if 'gyro_corrected_dps' not in p:
            
            self.g.center = (0.0, 0.0)
            self.g.phase = 'READY'
            return self.g.result('NEUTRAL_SET')
        gyro, norm = p['gyro_corrected_dps'], p['norm_g']
        yaw = sum(a*b for a,b in zip(gyro,sample['accel_g']))/norm
        tilt = math.sqrt(max(0,sum(x*x for x in gyro)-yaw*yaw))
        return self.g.update(now,p['roll_deg'],p['pitch_deg'],yaw,max(map(abs,gyro)),norm,tilt)
