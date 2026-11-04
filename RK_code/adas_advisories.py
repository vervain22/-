
import math

def fresh(row, now):
    t=row.get('source_timestamp')
    return bool(row.get('valid') and isinstance(t,(int,float)) and math.isfinite(t)
                and 0 <= now-t <= .5 and now <= row.get('expires_at',t+.5))

def boxes(row, cls):
    return [d['box'] for d in row.get('detections',[]) if d.get('class_id')==cls
            and len(d.get('box',[]))==4 and all(isinstance(x,(int,float)) and math.isfinite(x) for x in d['box'])
            and d['box'][0]<d['box'][2] and d['box'][1]<d['box'][3]]

def same_lamp(a,b):
    if a is None or b is None:return False
    return abs((a[0]+a[2]-b[0]-b[2])/2)<=max(20,a[2]-a[0],b[2]-b[0]) and abs((a[1]+a[3]-b[1]-b[3])/2)<=max(20,a[3]-a[1],b[3]-b[1])

class Advisories:
    def __init__(self):
        self.key=None;self.reset()
    def reset(self):
        self.red=None;self.green_start=None;self.green_hits=0;self.green_until=0
        self.signal_stamp=None;self.object_stamp=None;self.cross_start=None;self.cross_hits=0;self.cross_until=0
    def update(self,result,state,now):
        key=(result.get('scene'),result.get('mode_epoch'),result.get('capture_epoch'))
        if key!=self.key:self.reset();self.key=key
        messages=[];codes=[]
        if state.get('scene') in ('INTERSECTION','NIGHT'):
            h=result.get('hdmi',{});o=result.get('hdmi_objects',{})
            if fresh(h,now) and fresh(o,now) and h.get('source_timestamp')==o.get('source_timestamp'):
                stamp=h['source_timestamp']
                if stamp!=self.signal_stamp:
                    self.signal_stamp=stamp;color=h.get('state')
                    rs=boxes(o,2);gs=boxes(o,3)
                    
                    if color=='RED' and rs and not gs:
                        self.red=(stamp,rs[0]);self.green_start=None;self.green_hits=0;self.green_until=0
                    elif color=='GREEN' and gs and not rs and self.red and 0<=stamp-self.red[0]<=6 and any(same_lamp(self.red[1],b) for b in gs):
                        if self.green_start is None:self.green_start=stamp
                        self.green_hits+=1
                        if self.green_hits>=2 and stamp-self.green_start>=.25:
                            if state.get('intent')=='STOP' and state.get('executed')=='STOP':self.green_until=now+3
                            self.red=None;self.green_start=None;self.green_hits=0
                    else:self.green_start=None;self.green_hits=0
            
            if fresh(h,now) and h.get('state') in ('RED','YELLOW'):self.green_until=0
            if fresh(o,now) and (boxes(o,2) or boxes(o,5)):self.green_until=0
            if state.get('intent')!='STOP' or state.get('executed')!='STOP':self.green_until=0
            if now<self.green_until:messages.append('绿灯，可起步');codes.append('GREEN_START')
            if fresh(o,now):
                stamp=o['source_timestamp']
                if stamp!=self.object_stamp:
                    self.object_stamp=stamp
                    people=boxes(o,1);crossings=boxes(o,0)
                    overlap=any(z[0]<= (p[0]+p[2])/2 <=z[2] and z[1]<=p[3]<=z[3] for p in people for z in crossings)
                    if overlap:
                        if self.cross_start is None or stamp-self.cross_start>1:self.cross_start=stamp;self.cross_hits=0
                        self.cross_hits+=1
                        if self.cross_hits>=2 and stamp-self.cross_start>=.15:self.cross_until=stamp+.6
                    else:self.cross_start=None;self.cross_hits=0;self.cross_until=0
            if now<self.cross_until:messages.append('人行横道有行人，请注意');codes.append('CROSSWALK_PERSON')
        req=state.get('lane_change');cam=result.get('camera',{})
        if req and fresh(cam,now) and cam.get('detections'):
            side='左' if req['side']=='left' else '右'
            feedback=state.get('lane_change_feedback') or {}
            blocked=feedback.get('status')=='BLOCK' and 'CAMERA_TARGET_PRESENT' in feedback.get('reasons',[])
            messages.append(side+'侧有人车，'+('拒绝执行，保留申请' if blocked else '注意盲区，确认时将拦截'))
            codes.append('BLIND_BLOCK' if blocked else 'BLIND_CAUTION')
        out=dict(messages=messages,codes=codes,advisory_only=True)
        result['adas_advisories']=out
        return out
