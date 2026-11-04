
import math
from collections import deque
from statistics import mean, pstdev


class Gestures:
    def __init__(self):
        self.motion = 'STOP'
        self.center = None
        self.last = None
        self.request_neutral()

    def request_neutral(self):
        self.last = None
        self.roll_error = self.pitch_error = None
        self.motion = 'STOP'
        self.center = None
        self.window = deque(maxlen=100)
        self.phase = 'NEUTRAL_REQUIRED'
        self.pending = None
        self.pending_since = None
        self.yaw = 0.0
        self.twist_started = None
        self.twist_quiet = None
        self.lock_since = None
        self.quiet_since = None
        self.stop_since = None
        self.bad_accel_since = None

    def fault(self, reason):
        self.request_neutral()
        self.phase = 'FAULT'
        return self.result('STOP_FAULT', reason)

    def result(self, event=None, reason=None):
        return dict(phase=self.phase, requested_motion=self.motion, event=event,
                    reason=reason, relative_twist_deg=self.yaw,
                    roll_error_deg=self.roll_error,pitch_error_deg=self.pitch_error,
                    rearm_ready=self.phase=='READY',
                    vehicle_control_enabled=False)

    def update(self, now, roll, pitch, yaw_rate, gyro_max, norm, tilt_rate):
        vals = (now, roll, pitch, yaw_rate, gyro_max, norm, tilt_rate)
        if not all(math.isfinite(v) for v in vals):
            self.last = None
            return self.fault('non_finite')
        dt = None if self.last is None else now-self.last
        self.last = now
        if dt is not None and not 0 < dt <= .1:
            return self.fault('sample_gap_or_clock')
        if self.phase == 'FAULT':
            return self.result(reason='explicit_neutral_required')
        
        
        
        if not .75 <= norm <= 1.30:
            self.bad_accel_since = self.bad_accel_since if self.bad_accel_since is not None else now
            self.pending = None
            self.window.clear()
            if now-self.bad_accel_since >= .2:
                return self.fault('acceleration_out_of_range')
            self.twist_started = None
            self.yaw = 0
            if self.phase == 'TWIST_LOCKED':
                
                
                self.motion = 'STOP'
                self.phase = 'TILT_LOCKED'
                self.quiet_since = None
                self.twist_quiet = None
                return self.result('STOP', 'TWIST_ACCELERATION_REARM')
            return self.result(reason='transient_acceleration_gestures_inhibited')
        self.bad_accel_since = None
        if self.center is None:
            
            quiet = abs(roll) < 15 and abs(pitch) < 15 and gyro_max < 8
            if not quiet:
                self.window.clear()
            else:
                self.window.append((now, roll, pitch))
            if self.window and now-self.window[0][0] >= .5:
                if max(pstdev(x[i] for x in self.window) for i in (1, 2)) < 1.5:
                    self.center = (mean(x[1] for x in self.window), mean(x[2] for x in self.window))
                    self.phase = 'READY'
                    return self.result('NEUTRAL_SET')
                self.window.clear()
            return self.result()
        r, p = roll-self.center[0], pitch-self.center[1]
        self.roll_error,self.pitch_error=r,p
        neutral = abs(r) < 7 and abs(p) < 5 and gyro_max < 8
        if self.phase == 'TWIST_LOCKED':
            stopping = (p < -15 and self.motion == 'FORWARD') or (p > 15 and self.motion == 'REVERSE')
            self.stop_since = (self.stop_since if self.stop_since is not None else now) if stopping else None
            if self.stop_since is not None and now-self.stop_since >= .15:
                self.motion = 'STOP'
                self.stop_since = None
                return self.result('STOP')
            self.yaw += yaw_rate*(dt or 0)
            
            returned = abs(self.yaw) < 8 and neutral
            self.quiet_since = (self.quiet_since if self.quiet_since is not None else now) if returned else None
            if self.quiet_since is not None and now-self.quiet_since >= .4:
                self.phase = 'READY'
                self.yaw = 0
                self.twist_started = None
                self.pending = None
            elif now-self.lock_since > 8:
                
                
                
                
                self.motion = 'STOP'
                self.phase = 'TILT_LOCKED'
                self.quiet_since = None
                self.pending = None
                self.twist_started = None
                self.twist_quiet = None
                self.yaw = 0.0
                return self.result('STOP', 'TWIST_RETURN_TIMEOUT_REARM')
            return self.result()
        if self.phase == 'TILT_LOCKED':
            self.quiet_since = (self.quiet_since if self.quiet_since is not None else now) if neutral else None
            if self.quiet_since is not None and now-self.quiet_since >= .3:
                self.phase = 'READY'
                self.pending = None
            return self.result()
        
        
        
        level = abs(p) < 15 and abs(r) < 15
        yaw_dominant = abs(yaw_rate) > 1.5*tilt_rate
        if self.twist_started is None and level and yaw_dominant and abs(yaw_rate) > 8:
            self.twist_started = now
            self.yaw = 0
        if self.twist_started is not None:
            self.yaw += yaw_rate*(dt or 0)
            self.twist_quiet = (self.twist_quiet if self.twist_quiet is not None else now) if neutral else None
            if (self.twist_quiet is not None and now-self.twist_quiet > .4) or now-self.twist_started > 3:
                self.twist_started = None
                self.yaw = 0
                self.twist_quiet = None
        stopping = (p < -15 and self.motion == 'FORWARD') or (p > 15 and self.motion == 'REVERSE')
        candidate = None
        if stopping:
            candidate = 'STOP'
        elif abs(p) >= 15 and abs(r) < 10 and abs(yaw_rate) < 20:
            candidate = 'FORWARD' if p > 0 else 'REVERSE'
        elif abs(r) >= 20 and abs(p) < 10 and abs(yaw_rate) < 20:
            candidate = 'LANE_RIGHT' if r > 0 else 'LANE_LEFT'
        elif level and yaw_dominant and abs(yaw_rate) >= 40:
            candidate = 'TURN_RIGHT' if yaw_rate < 0 else 'TURN_LEFT'
        if candidate != self.pending:
            self.pending, self.pending_since = candidate, now
        if candidate is None:
            return self.result()
        twist = candidate.startswith('TURN_')
        dwell = .1 if twist else .15
        elapsed = now-(self.twist_started if twist and self.twist_started is not None else self.pending_since)
        if elapsed < dwell or twist and abs(self.yaw) < 12:
            return self.result()
        event = candidate
        if candidate in ('STOP', 'FORWARD', 'REVERSE'):
            
            self.motion = candidate
        elif self.motion != 'FORWARD':
            event = 'REJECT_' + candidate
        self.phase = 'TWIST_LOCKED' if twist else 'TILT_LOCKED'
        if not twist:
            self.twist_started = None
            self.yaw = 0
        self.lock_since, self.quiet_since = now, None
        return self.result(event)
