
import math
from compare import cv2,np


def find(roi):
    h,w=roi.shape[:2]
    if not 1.6<=h/w<=4.8:return []
    hue,sat,value=cv2.split(cv2.cvtColor(roi,cv2.COLOR_BGR2HSV))
    blue,green,red=[c.astype(float) for c in cv2.split(roi)]
    background=float(np.percentile(value,25))
    bright=(sat>=35)&(value>=max(125,background+24))
    masks=[bright&((hue<=12)|(hue>=168))&(red-np.maximum(green,blue)>=12),
           bright&(hue>=38)&(hue<=96)&(green-red>=16)&(green-blue>=-8),
           bright&(hue>=15)&(hue<=36)&(np.minimum(red,green)-blue>=18)]
    result=[]
    for color,mask in zip(('RED','GREEN','YELLOW'),masks):
        
        
        white=(sat<35)&(np.minimum(np.minimum(blue,green),red)>=max(125,background+24))
        n,labels,stats,_=cv2.connectedComponentsWithStats((mask|white).astype(np.uint8),8)
        for i in range(1,n):
            if np.count_nonzero(mask&(labels==i))<6:continue
            x,y,cw,ch,area=map(int,stats[i]);aspect=cw/ch;fill=area/(cw*ch)
            cx=(x+cw/2)/w;cy=(y+ch/2)/h
            slot={'RED':.05<=cy<=.48,'YELLOW':.30<=cy<=.70,'GREEN':.52<=cy<=.95}[color]
            if not (area>=8 and min(cw,ch)>=3 and .65<=aspect<=1.5 and fill>=.60
                    and .12<=cx<=.88 and .22<=cw/w<=.90 and slot
                    and x>=1 and y>=1 and x+cw<=w-1 and y+ch<=h-1):continue
            contours,hierarchy=cv2.findContours((labels==i).astype(np.uint8),cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
            
            if hierarchy is None or any(e[3]>=0 for e in hierarchy[0]):continue
            perimeter=cv2.arcLength(contours[0],True)
            roundness=min(1.,4*math.pi*area/(perimeter*perimeter)) if perimeter else 0.
            if roundness<.65:continue
            result.append(dict(color=color,area=area,aspect=aspect,fill=fill,
                               roundness=roundness,box=[x,y,x+cw,y+ch]))
    
    return result if len({c['color'] for c in result})<=1 else []
