import copy,math
def finite(x):return isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x)
class LaneState:
    authoritative=True
    def __init__(self):self.capture_epoch=None;self.clear()
    def clear(self):
        self.rows={s:dict(image_side=s,candidate_type='NONE',temporal_type='NONE',
            source_timestamp=None,source_ns=None,confirmed=False,
            support_method='INITIAL_NO_LINE_STATE',persistent=True) for s in ('left','right')}
        self.watermark=-float('inf')
    def observe(self,result,now):
        epoch=result.get('capture_epoch')
        if epoch!=self.capture_epoch:self.clear();self.capture_epoch=epoch
        lane=result.get('lane',{});stamp=lane.get('source_timestamp');end=lane.get('valid_until')
        capture=result.get('capture_timestamp')
        
        if (result.get('scene')!='LANE_CHANGE' or lane.get('source')!='HDMI'
            or lane.get('current') is not True or not all(finite(v) for v in (now,stamp,end,capture))
            or not 0<=now-capture<=.5 or not 0<=now-stamp<=.8 or now>end or stamp>capture
            or stamp<=self.watermark):return
        self.watermark=stamp
        for a in lane.get('sides',[]):
            side=a.get('image_side');kind=a.get('candidate_type');reason=a.get('reason','')
            if side not in ('left','right'):continue
            if any(x in reason for x in ('CONFLICT','OCCLUDED','AMBIGUOUS','MISMATCH')):continue
            if a.get('line_presence')=='NOT_DETECTED' and kind=='UNKNOWN':kind='NONE'
            if kind not in ('DASHED','SOLID','NONE'):continue
            self.rows[side]=dict(image_side=side,candidate_type=kind,temporal_type=kind,
                source_timestamp=stamp,source_ns=lane.get('source_ns'),confirmed=False,
                support_method='SHARED_LAST_VALID_STATE',persistent=True)
    def get(self,side,now):return copy.deepcopy(self.rows.get(side))
    def snapshot(self,now):return copy.deepcopy(self.rows)
