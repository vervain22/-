
import math
from collections import deque
from statistics import mean, pstdev


def angles(accel):
    x, y, z = accel
    return (math.degrees(math.atan2(y, z)),
            math.degrees(math.atan2(-x, math.hypot(y, z))))


def wrap(angle):
    return (angle + 180) % 360 - 180


class Pose:
    def __init__(self, calibration_seconds=2.0):
        self.duration = calibration_seconds
        self.reset()

    def reset(self):
        self.window = deque(maxlen=500)
        self.last = None
        self.bias = None
        self.origin = None
        self.roll = self.pitch = 0.0

    def update(self, now, sample):
        values = sample['accel_g'] + sample['gyro_dps']
        if not math.isfinite(now) or any(not math.isfinite(v) for v in values):
            self.reset()
            raise ValueError('Non-finite sensor data or clock')
        dt = None if self.last is None else now - self.last
        if dt is not None and not 0 < dt <= 0.1:
            self.reset()
        self.last = now
        accel, gyro = sample['accel_g'], sample['gyro_dps']
        norm = math.sqrt(sum(v*v for v in accel))
        ar, ap = angles(accel)
        if self.bias is None:
            
            
            stationary = (0.85 <= norm <= 1.15 and accel[2] > 0.7
                          and max(abs(v) for v in gyro) < 5)
            reason = 'KEEP_STILL' if stationary else ('KEEP_LEVEL' if accel[2] <= 0.7 else 'MOTION_OR_ACCELERATION')
            if not stationary:
                self.window.clear()
            if stationary:
                self.window.append((now, accel, gyro))
            if self.window and now - self.window[0][0] >= self.duration:
                acc_std = max(pstdev(x[1][i] for x in self.window) for i in range(3))
                gyro_std = max(pstdev(x[2][i] for x in self.window) for i in range(3))
                if acc_std < 0.025 and gyro_std < 1.2:
                    self.bias = [mean(x[2][i] for x in self.window) for i in range(3)]
                    self.origin = angles([mean(x[1][i] for x in self.window) for i in range(3)])
                    self.roll, self.pitch = self.origin
                else:
                    self.window.clear()
                    reason = 'EXCESS_VARIATION'
            return dict(reason=reason, status='READY' if self.bias is not None else 'CALIBRATING',
                        progress_s=now-self.window[0][0] if self.window else 0,
                        norm_g=norm, control_enabled=False)
        corrected = [v-b for v, b in zip(gyro, self.bias)]
        self.roll = wrap(self.roll + corrected[0] * dt)
        self.pitch = wrap(self.pitch + corrected[1] * dt)
        
        if 0.85 <= norm <= 1.15:
            weight = 1 - math.exp(-dt / 0.5)
            self.roll = wrap(self.roll + weight * wrap(ar-self.roll))
            self.pitch = wrap(self.pitch + weight * wrap(ap-self.pitch))
        return dict(status='READY', roll_deg=wrap(self.roll-self.origin[0]),
                    pitch_deg=wrap(self.pitch-self.origin[1]),
                    gyro_corrected_dps=corrected, norm_g=norm,
                    gyro_bias_dps=self.bias, absolute_yaw_available=False,
                    control_enabled=False)
