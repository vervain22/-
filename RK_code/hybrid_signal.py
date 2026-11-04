



import copy,math
import cv2,numpy as np
COLORS={2:'RED',3:'GREEN',4:'UNKNOWN',5:'YELLOW'}

def iou(a,b):
    a=np.asarray(a);b=np.asarray(b);size=np.maximum(0,np.minimum(a[2:],b[2:])-np.maximum(a[:2],b[:2]))
    intersection=float(np.prod(size));area=lambda x:float(np.prod(np.maximum(0,x[2:]-x[:2])))
    return intersection/max(1e-6,area(a)+area(b)-intersection)

def eligible(rows,min_score=.25):
    out=[]
    for r in rows:
        b=np.asarray(r.get('box'),dtype=float);s=r.get('score',0)
        if b.shape!=(4,) or not np.isfinite(b).all() or not math.isfinite(s) or not min_score<=s<=1:continue
        if (b[2:]<=b[:2]).any() or (b[:2]<0).any() or b[2]>640 or b[3]>360:continue
        if not 160<=(b[0]+b[2])/2<=480:continue
        out.append(copy.deepcopy(r))
    return out

def reference_candidates(rows):
    
    
    rows=eligible([r for r in rows if r.get('class_id') in COLORS],min_score=0.)
    result=[]
    for a in rows:
        suppress=False
        for b in rows:
            if a is b or a['class_id']==b['class_id'] or 4 in (a['class_id'],b['class_id']):continue
            if iou(a['box'],b['box'])>=.65 and b['score']>=.5 and b['score']-a['score']>=.2:
                if all(c['class_id']==b['class_id'] or iou(c['box'],b['box'])<.65 or b['score']-c['score']>=.2 for c in rows):suppress=True
        if not suppress:result.append(dict(a,raw=COLORS[a['class_id']],backend='reference',reason='reference_class'))
    return result

def lamp_color(image,box):
    x,y,z,w=np.asarray(box).round().astype(int);roi=image[max(0,y):min(360,w),max(0,x):min(640,z)]
    if roi.size==0:return dict(raw='UNKNOWN',reason='empty_box',components=[])
    h,s,v=cv2.split(cv2.cvtColor(roi,cv2.COLOR_BGR2HSV));lit=(s>=80)&(v>=100)
    if np.count_nonzero((h>=100)&(h<=135)&(s>=100))>=max(6,roi.shape[0]*roi.shape[1]*.08):
        return dict(raw='UNKNOWN',reason='blue_sign',components=[])
    masks={'RED':lit&((h<=7)|(h>=170)), 'YELLOW':lit&(h>=12)&(h<=37), 'GREEN':lit&(h>=38)&(h<=96)}
    components=[];support={}
    minimum=max(6,int(roi.shape[0]*roi.shape[1]*.01))
    for color,mask in masks.items():
        count,labels,stats,_=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
        best=0
        for k in range(1,count):
            bx,by,bw,bh,area=map(int,stats[k]);blob=(labels==k).astype(np.uint8)
            contours,hierarchy=cv2.findContours(blob,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
            outer=max((c for c,hier in zip(contours,hierarchy[0] if hierarchy is not None else []) if hier[3]<0),key=cv2.contourArea,default=None)
            perimeter=cv2.arcLength(cv2.convexHull(outer),True) if outer is not None else 0
            circularity=min(1.,4*math.pi*area/(perimeter*perimeter)) if perimeter else 0
            fill=area/(bw*bh)
            dark_holes=[]
            for c,hier in zip(contours,hierarchy[0] if hierarchy is not None else []):
                if hier[3]<0 or cv2.contourArea(c)<3:continue
                inside=np.zeros_like(blob);cv2.drawContours(inside,[c],-1,1,-1)
                pixels=v[(inside>0)&(blob==0)]
                
                if pixels.size and float(np.median(pixels))<180:dark_holes.append(cv2.contourArea(c))
            digit_like=len(dark_holes)>=2 or sum(dark_holes)>max(6,area*.15)
            if area>=minimum and .4<=bw/bh<=2.5 and fill>=.45 and circularity>=.5 and not digit_like:
                best=max(best,area);components.append(dict(color=color,area=area,circularity=circularity,fill=fill,box=list(map(int,[x+bx,y+by,x+bx+bw,y+by+bh]))))
        support[color]=best
    ranked=sorted(support,key=support.get,reverse=True);first,second=ranked[:2];peak=support[first]
    ambiguous=int(np.count_nonzero(lit&(h>=8)&(h<=11)))
    
    
    valid=peak>=minimum and peak>=3*max(1,support[second]) and ambiguous<=max(3,peak*.4)
    return dict(raw=first if valid else 'UNKNOWN',reason='dominant_compact_lamp' if valid else 'weak_or_conflicting_lamp',components=components,support=support,ambiguous_pixels=ambiguous)

def fallback_candidates(image,rows):
    from geometry import describe
    from signal_core import evidence as original_evidence
    from core_color import evaluate
    out=[]
    for r in eligible(rows):
        b=r['box'];aspect=(b[3]-b[1])/(b[2]-b[0])
        if not .6<=aspect<=5:continue
        appearance=describe(image,b)
        if appearance['kind']!='lamp_head':continue
        original=original_evidence(image,b)
        if original['reason']=='blue_sign_candidate':continue
        bound=evaluate(image,b,appearance,original=original)
        orange=lamp_color(image,b)
        
        
        if bound['raw']=='UNKNOWN' and orange['raw']=='YELLOW':
            color='YELLOW';reason='orange_body_supplement'
        else:color=bound['raw'];reason=bound['reason']
        out.append(dict(r,raw=color,backend='official_fallback',reason=reason,color_evidence=dict(bound=bound,orange=orange),appearance=appearance))
    return out

class Focus:
    def __init__(self):
        self.last=None;self.previous=None;self.color=None;self.hits=0;self.identity=0
        self.confirmed_before_conflict=None
    def reset(self):
        self.previous=None;self.color=None;self.hits=0;self.confirmed_before_conflict=None
    def update(self,rows,stamp,now):
        output=dict(state='UNKNOWN',valid=False,reason='NO_FOCUS_SIGNAL',tracks=[],source_timestamp=stamp,expires_at=stamp+.5,diagnostic_only=True,vehicle_permission=False)
        if not math.isfinite(stamp) or not -.1<=now-stamp<=.5 or self.last is not None and stamp<=self.last:
            self.reset();output['reason']='SOURCE_EXPIRED_OR_REPEATED';return output
        if self.last is not None and stamp-self.last>.5:self.reset()
        self.last=stamp
        if not rows:self.reset();return output
        def rank(r):return abs(sum(r['box'][::2])/2/640-.5)-(.25 if self.previous is not None and iou(r['box'],self.previous)>.3 else 0)
        chosen=min(rows,key=rank)
        same=self.previous is not None and iou(chosen['box'],self.previous)>.3
        if not same:self.identity+=1
        colors={r['raw'] for r in rows}
        conflict=len(colors)>1
        self.hits=self.hits+1 if same and self.color==chosen['raw'] and not conflict else 1
        self.previous=chosen['box'];self.color=chosen['raw']
        immediate_red=not conflict and chosen['raw']=='RED'
        
        
        current_fpga=(chosen.get('backend')=='fpga_same_frame'
                      and chosen.get('current_color_confirmed') is True)
        confirmed=not conflict and (immediate_red or current_fpga or self.hits>=2) and chosen['raw'] in ('RED','GREEN','YELLOW')
        if conflict:self.hits=0
        reason='IMMEDIATE_RED_SCREEN_FOCUS' if immediate_red and self.hits<2 else 'FOCUS_GROUP_CONFLICT' if conflict else 'DARK_OR_UNCERTAIN_SIGNAL' if chosen['raw']=='UNKNOWN' else 'CURRENT_FPGA_COLOR' if confirmed and current_fpga else 'CONFIRMED_SCREEN_FOCUS' if confirmed else 'CONFIRMING_NEW_STATE_OR_GROUP'
        for r in rows:
            output['tracks'].append(dict(r,id=self.identity if r is chosen else -1,selected=r is chosen,valid=confirmed and r is chosen,stable=chosen['raw'] if confirmed and r is chosen else 'UNKNOWN',hits=self.hits if r is chosen else 1))
        output.update(state=chosen['raw'] if confirmed else 'UNKNOWN',valid=confirmed,reason=reason,backend=chosen['backend'])
        if confirmed:
            self.confirmed_before_conflict=dict(state=chosen['raw'],source_timestamp=stamp)
        
        
        if {'RED','GREEN'}.issubset(colors) and self.confirmed_before_conflict is not None:
            prior=self.confirmed_before_conflict
            output.update(state=prior['state'],valid=True,reason='RED_GREEN_CONFLICT_KEEP_PREVIOUS',
                conflict_hold=True,conflict_colors=sorted(colors),
                retained_state_source_timestamp=prior['source_timestamp'])
        return output
