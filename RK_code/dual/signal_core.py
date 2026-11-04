
from dataclasses import dataclass, field
import math
import time
from compare import cv2,np

UNKNOWN='UNKNOWN'
COLORS=('RED','GREEN','YELLOW')


def evidence(image,box):
    h,w=image.shape[:2]
    b=np.asarray(box,dtype=float)
    if b.shape!=(4,) or not np.isfinite(b).all() or b[2]<=b[0] or b[3]<=b[1]:
        return dict(raw=UNKNOWN,reason='invalid_box',components=[])
    x1,y1=np.maximum(0,np.floor(b[:2]).astype(int)-1)
    x2,y2=np.minimum([w,h],np.ceil(b[2:]).astype(int)+1)
    if x2<=x1 or y2<=y1:
        return dict(raw=UNKNOWN,reason='empty',components=[])
    roi=image[y1:y2,x1:x2]
    if roi.size==0:
        return dict(raw=UNKNOWN,reason='empty',components=[])
    
    blue,green,red=[x.astype(np.float32) for x in cv2.split(roi)]
    hsv=cv2.cvtColor(roi,cv2.COLOR_BGR2HSV)
    hue,sat,value=cv2.split(hsv)
    
    
    blue_patch=(hue>=100)&(hue<=135)&(sat>=100)&(value>=70)&(blue-green>=12)
    if np.count_nonzero(blue_patch)>=max(6,roi.shape[0]*roi.shape[1]*.08):
        return dict(raw=UNKNOWN,reason='blue_sign_candidate',components=[])
    masks=[((hue<=12)|(hue>=168)) & (sat>=35) & (red>=70) &
           (red-np.maximum(green,blue)>=12),
           (hue>=38)&(hue<=96)&(sat>=40)&(green>=70)&
           (green-red>=12)&(green-blue>=4),
           (hue>=15)&(hue<=36)&(sat>=45)&(value>=90)&
           (np.minimum(red,green)-blue>=18)]
    components=[]
    bw,bh=b[2]-b[0],b[3]-b[1]
    tiny_vertical=3<=bw<=10 and 7<=bh<=32 and 1.6<=bh/bw<=4.8
    ix1,iy1=np.maximum([0,0],np.ceil(b[:2]-[x1,y1]).astype(int))
    ix2,iy2=np.minimum([roi.shape[1],roi.shape[0]],np.floor(b[2:]-[x1,y1]).astype(int))
    housing=value[iy1:iy2,ix1:ix2]
    housing_dark=float(np.percentile(housing,25)) if housing.size else 255.
    for color,mask in zip(COLORS,masks):
        count,labels,stats,_=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
        for index in range(1,count):
            x,y,cw,ch,area=map(int,stats[index])
            aspect=cw/ch
            fill=area/(cw*ch)
            if area<2 or not .36<=aspect<=2.8 or fill<(.35 if tiny_vertical else .5):
                continue
            component=(labels==index).astype(np.uint8)
            contours,_=cv2.findContours(component,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
            perimeter=cv2.arcLength(contours[0],True) if contours else 0
            circularity=min(1.,4*math.pi*area/(perimeter*perimeter)) if perimeter else 0.
            
            if area>=8 and circularity<.46:
                continue
            peak=float(np.percentile(value[labels==index],85))
            background=float(np.median(value))
            
            
            
            cx=(x1+x+cw/2-b[0])/bw;cy=(y1+y+ch/2-b[1])/bh
            slot_ok={'RED':.05<=cy<=.48,'YELLOW':.30<=cy<=.70,'GREEN':.52<=cy<=.95}[color]
            
            
            small_core=(tiny_vertical and color=='RED'
                and .12<=cx<=.88 and slot_ok and 2<=area<=max(3,bw*bh*.22)
                and .5<=aspect<=2 and fill>=.35 and peak>=75 and peak>=housing_dark+24)
            ordinary=fill>=.5 and peak>=background+8 and peak>=105 and (area>=8 or peak>=125)
            if not (ordinary or small_core):
                continue
            components.append(dict(color=color,area=area,fill=fill,
                circularity=circularity,peak=peak,background=background,
                evidence_method='standard' if ordinary else 'small_head_local_contrast',
                housing_background=housing_dark,
                box=[int(x1+x),int(y1+y),int(x1+x+cw),int(y1+y+ch)]))
    if not components:
        return dict(raw=UNKNOWN,reason='no_supported_blob',components=[])
    scores={c:sum(x['area'] for x in components if x['color']==c) for c in COLORS}
    ordered=sorted(scores,key=scores.get,reverse=True)
    if scores[ordered[1]]>=2 and scores[ordered[1]]>=scores[ordered[0]]*.35:
        return dict(raw=UNKNOWN,reason='conflicting_colors',components=components)
    return dict(raw=ordered[0],reason='compact_color_blob',components=components)


@dataclass
class Temporal:
    stable:str=UNKNOWN
    candidate:str=UNKNOWN
    count:int=0
    since:float=0.
    last:float|None=None
    
    max_gap:float=.5

    def reset(self):
        self.stable=self.candidate=UNKNOWN
        self.count=0
        self.since=0.
        self.last=None

    def update(self,raw,timestamp):
        if not math.isfinite(timestamp):
            self.reset()
            return UNKNOWN,False
        if self.last is not None and timestamp<=self.last:
            if timestamp<self.last:
                self.reset()
            return self.stable,False
        if self.last is not None and timestamp-self.last>self.max_gap:
            self.reset()
        self.last=timestamp
        if raw==UNKNOWN:
            self.stable=self.candidate=UNKNOWN
            self.count=0
            return UNKNOWN,False
        if raw!=self.stable:
            self.stable=UNKNOWN
        if self.candidate!=raw:
            self.candidate=raw
            self.count=1
            self.since=timestamp
        else:
            self.count+=1
        required=3 if raw=='GREEN' else 2
        duration=.25 if raw=='GREEN' else .07
        if self.count>=required and timestamp-self.since>=duration:
            self.stable=raw
        return self.stable,self.stable==raw


def iou(a,b):
    x1,y1=np.maximum(a[:2],b[:2]); x2,y2=np.minimum(a[2:],b[2:])
    intersection=max(0.,x2-x1)*max(0.,y2-y1)
    area=lambda r:max(0.,r[2]-r[0])*max(0.,r[3]-r[1])
    return intersection/max(1e-6,area(a)+area(b)-intersection)


@dataclass
class Track:
    id:int
    box:list
    last_detection:float
    hits:int=1
    score:float=0.
    temporal:Temporal=field(default_factory=Temporal)


class Signals:
    def __init__(self,max_gap=.5,geometry_ttl=.8):
        self.tracks=[]
        self.next_id=1
        self.last=None
        self.previous=None
        self.selected_id=None
        self.max_gap=max_gap
        self.geometry_ttl=geometry_ttl
        self.last_observation=None

    def reset(self):
        self.tracks=[]
        self.previous=None
        self.last=None
        self.selected_id=None
        self.last_observation=None

    def update(self,image,detections,timestamp,detection_timestamp=None):
        profile_start=time.perf_counter();self.last_profile=None
        if not isinstance(image,np.ndarray) or image.ndim!=3 or image.shape[2]!=3 or image.size==0 or image.dtype!=np.uint8:
            self.reset()
            return dict(state=UNKNOWN,valid=False,reason='invalid_image',tracks=[])
        if not math.isfinite(timestamp):
            self.reset()
            return dict(state=UNKNOWN,valid=False,reason='invalid_timestamp',tracks=[])
        if self.last is not None and timestamp<=self.last:
            if timestamp<self.last:
                self.reset()
            return dict(state=UNKNOWN,valid=False,reason='repeated_or_reversed_frame',tracks=[])
        if self.previous is not None and self.previous.shape!=image.shape[:2]:
            self.reset()
        gray=cv2.cvtColor(image,cv2.COLOR_BGR2GRAY)
        reset_reason=None
        if self.last is not None and timestamp-self.last>self.max_gap:
            self.reset();reset_reason='source_gap'
        if self.previous is not None:
            change=float(np.mean(cv2.absdiff(gray,self.previous)))
            if change>28:
                self.reset();reset_reason='scene_change'
        
        
        self.tracks=[t for t in self.tracks if timestamp-t.last_detection<=self.geometry_ttl+.5]
        observation=timestamp if detection_timestamp is None else detection_timestamp
        if (not math.isfinite(observation) or not -.1<=timestamp-observation<=.5
                or (self.last_observation is not None and observation<=self.last_observation)):
            detections=[]
        elif detections:
            self.last_observation=observation
        flow_start=time.perf_counter()
        if self.previous is not None and self.tracks:
            from flow import advance
            advance(self.previous,gray,self.tracks)
        flow_end=time.perf_counter()
        available=set(range(len(self.tracks)))
        for detection in sorted(detections,key=lambda d:d['score'],reverse=True):
            box=np.asarray(detection['box'],dtype=float)
            if box.shape!=(4,) or not np.isfinite(box).all() or box[2]<=box[0] or box[3]<=box[1] or not math.isfinite(detection['score']):
                continue
            box[[0,2]]=np.clip(box[[0,2]],0,image.shape[1])
            box[[1,3]]=np.clip(box[[1,3]],0,image.shape[0])
            if box[2]<=box[0] or box[3]<=box[1]:
                continue
            eligible=[j for j in available if 0<observation-self.tracks[j].last_detection<=self.geometry_ttl]
            match=max(eligible,key=lambda j:iou(box,self.tracks[j].box),default=None)
            if match is not None and iou(box,self.tracks[match].box)>=.2:
                track=self.tracks[match];available.remove(match)
                track.box=box.tolist();track.hits+=1;track.last_detection=observation
                track.score=detection['score']
            else:
                self.tracks.append(Track(self.next_id,box.tolist(),observation,score=detection['score'],temporal=Temporal(max_gap=self.max_gap)))
                self.next_id+=1
        association_end=time.perf_counter()
        rows=[]
        from geometry import describe
        for track in self.tracks:
            if timestamp-track.last_detection>self.geometry_ttl:
                
                
                
                
                
                track.temporal.reset()
                continue
            from core_color import evaluate
            
            
            
            initial=evidence(image,track.box)
            if initial['reason']=='blue_sign_candidate':
                appearance=dict(kind='unsupported',possible_head=False,
                                reason='blue_sign_precheck',quality=0.)
                color=initial
            else:
                appearance=describe(image,track.box)
                color=evaluate(image,track.box,appearance,original=initial)
            if appearance['kind']!='lamp_head' and color['reason']!='blue_sign_candidate':
                color=dict(raw=UNKNOWN,reason='unsupported_head_shape',components=color['components'])
            stable,confirmed=track.temporal.update(color['raw'],timestamp)
            
            cx=(track.box[0]+track.box[2])/2/image.shape[1]
            cy=(track.box[1]+track.box[3])/2/image.shape[0]
            in_search_area=.2<=cx<=.8 and .03<=cy<=.6
            confirmed=confirmed and track.hits>=2 and in_search_area
            rows.append(dict(id=track.id,box=track.box,score=track.score,hits=track.hits,
                detection_age=timestamp-track.last_detection,raw=color['raw'],
                stable=stable,valid=confirmed,reason=color['reason'],
                components=color['components'],appearance=appearance,
                color_binding=color.get('binding'),in_search_area=in_search_area))
        color_end=time.perf_counter()
        candidates=[r for r in rows if r['in_search_area'] and r['appearance']['kind']=='lamp_head'
                    and r['reason']!='blue_sign_candidate']
        def rank(r):
            b=r['box'];cx=(b[0]+b[2])/2/image.shape[1]
            size=min(1.,math.sqrt((b[2]-b[0])*(b[3]-b[1]))/(image.shape[0]*.1))
            return .35*size+.25*(1-abs(cx-.5)*2)+.2*r['score']+.2*r['appearance']['quality']+(.12 if r['id']==self.selected_id else 0.)
        anchor=max(candidates,key=rank,default=None)
        selected=[]
        if anchor is not None:
            a=anchor['box'];ah=a[3]-a[1];aw=a[2]-a[0]
            companions=[r for r in rows if r['in_search_area'] and r['reason']!='blue_sign_candidate'
                        and (r in candidates or (r['hits']>=2 and r['appearance'].get('possible_head',False)))]
            for r in companions:
                b=r['box'];bh=b[3]-b[1];bw=b[2]-b[0]
                if .5<=bh/ah<=2 and .5<=bw/aw<=2 and abs((a[1]+a[3]-b[1]-b[3])/2)<=max(ah,bh)*.8 and abs((a[0]+a[2]-b[0]-b[2])/2)<=max(ah,bh)*6:
                    selected.append(r)
            self.selected_id=anchor['id']
        else:
            self.selected_id=None
        for r in rows:r['selected']=r in selected
        valid=[r for r in selected if r['valid']]
        
        
        raw_colors={r['raw'] for r in selected if r['raw']!=UNKNOWN}
        states={r['stable'] for r in valid}
        if len(raw_colors)>1 or len(states)>1 or any(r['reason']=='conflicting_colors' for r in selected):
            state,reason=UNKNOWN,'conflicting_lights'
        elif not states:
            state,reason=UNKNOWN,reset_reason or 'no_confirmed_light'
        else:
            state,reason=next(iter(states)),'consistent_confirmed_candidates'
        if state!=UNKNOWN and any(r['raw']==UNKNOWN and r['hits']>=2 for r in selected):
            state,reason=UNKNOWN,'unresolved_other_candidate'
        if anchor is not None and any(r not in selected and r['hits']>=2 and rank(anchor)-rank(r)<.08 for r in candidates):
            state,reason=UNKNOWN,'ambiguous_group_selection'
        self.previous=gray;self.last=timestamp
        self.last_profile=dict(preparation_seconds=flow_start-profile_start,
            flow_seconds=flow_end-flow_start,association_seconds=association_end-flow_end,
            color_shape_seconds=color_end-association_end,group_seconds=time.perf_counter()-color_end)
        return dict(state=state,valid=state!=UNKNOWN,reason=reason,
                    valid_until=timestamp+self.max_gap,tracks=rows,diagnostic_only=True,
                    selected_anchor=self.selected_id,selected_ids=[r['id'] for r in selected],
                    vehicle_permission=False)
