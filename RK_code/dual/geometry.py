
from compare import cv2,np

def describe(image,box):
    x1,y1=np.floor(box[:2]).astype(int);x2,y2=np.ceil(box[2:]).astype(int)
    x1,y1=max(0,x1),max(0,y1);x2,y2=min(image.shape[1],x2),min(image.shape[0],y2)
    roi=image[y1:y2,x1:x2]
    if roi.size==0:return dict(kind='unsupported',reason='empty',quality=0.)
    h,w=roi.shape[:2];ratio=h/w
    
    
    inner=np.min(roi,axis=2).astype(float)
    low=float(np.median(inner));high=float(np.percentile(inner,95))
    threshold=low+.65*(high-low)
    mask=((inner>=threshold)&(inner>=low+18)).astype(np.uint8)
    
    
    hole_support=0;hole_areas=[]
    for fraction in (.5,.65):
        core=((inner>=low+fraction*(high-low))&(inner>=low+18)).astype(np.uint8)
        contours,hierarchy=cv2.findContours(core,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
        found=[]
        if hierarchy is not None:
            for contour,entry in zip(contours,hierarchy[0]):
                parent=int(entry[3]);area=float(cv2.contourArea(contour))
                if parent<0 or area<3:continue
                _,_,pw,ph=cv2.boundingRect(contours[parent])
                if pw>=3 and ph>=4 and .25<=pw/ph<=1.4:found.append(area)
        hole_areas.append(found);hole_support+=bool(found)
    digit_like=hole_support==2
    count,labels,stats,_=cv2.connectedComponentsWithStats(mask,8)
    cores=[]
    for i in range(1,count):
        x,y,cw,ch,area=map(int,stats[i])
        fill=area/(cw*ch);aspect=cw/ch
        if area>=3:
            
            
            
            round_compact=False
            if (area>=16 and .75<=aspect<=1.33 and .60<=fill<.65
                    and x>=1 and y>=1 and x+cw<=w-1 and y+ch<=h-1):
                import math
                contours,hierarchy=cv2.findContours((labels==i).astype(np.uint8),cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
                if hierarchy is not None and all(e[3]<0 for e in hierarchy[0]):
                    perimeter=cv2.arcLength(contours[0],True)
                    round_compact=bool(perimeter and 4*math.pi*area/perimeter**2>=.75)
            cores.append(dict(area=area,aspect=aspect,fill=fill,box=[x,y,x+cw,y+ch],round_compact=round_compact))
    compact=[c for c in cores if .55<=c['aspect']<=1.9 and (c['fill']>=.65 or c['round_compact'])]
    dominant=max(cores,key=lambda c:c['area'],default=None)
    has_compact=bool(compact)
    compact=[c for c in compact if c is dominant]
    vertical=1.6<=ratio<=4.8
    horizontal=.18<=ratio<=.65
    colored=[]
    if vertical and not compact and not digit_like:
        from chromatic_core import find
        colored=find(roi)
    color_support=False
    if horizontal:
        from signal_core import evidence
        color=evidence(image,box)
        color_support=color['raw']!='UNKNOWN' and any(c['area']>=3 for c in color['components'])
    kind='lamp_head' if (vertical and (compact or colored)) or (horizontal and color_support) else 'unsupported'
    if digit_like:kind='countdown_like'
    
    
    
    possible_head=vertical and (has_compact or bool(colored)) and not digit_like and (high-low>=18 or bool(colored))
    return dict(kind=kind,possible_head=bool(possible_head),reason='persistent_hollow_core' if digit_like else ('housing_and_compact_core' if kind=='lamp_head' else 'no_housing_core_support'),
                quality=float(max((c['fill'] for c in compact+colored),default=.65 if color_support else 0.)),
                ratio=float(ratio),cores=cores,chromatic_cores=colored,contrast=high-low,hole_areas=hole_areas)
