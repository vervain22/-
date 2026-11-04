





from pathlib import Path
import sys
import numpy as np
import cv2
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'lane'))
import paint_evidence as legacy

def thresholds():
    v=np.arange(256,dtype=np.int64)
    sd=np.zeros(256,np.int64);hd=sd.copy()
    sd[1:]=np.rint((255*4096)/v[1:]).astype(np.int64)
    hd[1:]=np.rint((30*4096)/v[1:]).astype(np.int64)
    wm=np.zeros(256,np.int64);ym=np.full(256,255,np.int64)
    rm=ym.copy();gm=ym.copy()
    wm[1:]=((110*4096-2049)//sd[1:])
    ym[1:]=(70*4096-2048+sd[1:]-1)//sd[1:]
    rm[1:]=(15*4096-2048+hd[1:]-1)//hd[1:]
    gm[1:]=2*v[1:]-(41*4096-2049)//hd[1:]
    return tuple(np.clip(a,0,255).astype(np.uint8) for a in (wm,ym,rm,gm))

WHITE_MAX,YELLOW_MIN,RED_HUE_MIN,GREEN_HUE_MIN=thresholds()

def colour(image):
    b,g,r=[image[:,:,i].astype(np.int16) for i in range(3)]
    value=np.maximum(np.maximum(r,g),b)
    delta=value-np.minimum(np.minimum(r,g),b)
    white=(value>=65)&(delta<=WHITE_MAX[value])
    yellow_hue=((r>=g)&(r>=b)&(g>=b)&(g-b>=RED_HUE_MIN[delta])) | (
        (g>r)&(g>=b)&(r>=b)&(r-b>=GREEN_HUE_MIN[delta]))
    yellow=(value>=100)&(delta>=YELLOW_MIN[value])&yellow_hue
    return white,yellow,value.astype(np.uint8)

def feature_map(image,lower_only=True):
    if image.shape!=(360,640,3) or image.dtype!=np.uint8:raise ValueError('native640x360 BGR required')
    white,yellow,value=colour(image)
    p=np.pad(value,((0,0),(12,12)),mode='edge')
    samples=[p[:,12+dx:12+dx+640] for dx in (-12,-10,-8,8,10,12)]
    contrast=2*value.astype(np.int16)-legacy._middle_pair_sum(samples)>=24
    features=white.astype(np.uint8)|(yellow.astype(np.uint8)<<1)|(contrast.astype(np.uint8)<<2)
    features[:,:13]=0;features[:,-13:]=0
    if lower_only:features[:180]=0
    return features

def rk_context(image,features,hsv=None):




    if features.shape!=(360,640) or features.dtype!=np.uint8 or np.any(features>7):raise ValueError('bad features')
    if np.any(features[:180]) or np.any(features[:,:13]) or np.any(features[:,-13:]):raise ValueError('invalid coverage')
    hsv=cv2.cvtColor(image,cv2.COLOR_BGR2HSV) if hsv is None else hsv
    hue,sat,val=cv2.split(hsv)
    
    upper=hsv[:180];p=np.pad(upper[:,:,2],((0,0),(12,12)),mode='edge')
    middle=legacy._middle_pair_sum([p[:,12+d:12+d+640] for d in (-12,-10,-8,8,10,12)])
    contrast=2*upper[:,:,2].astype(np.int16)-middle>=24
    chromatic=((sat[:180]<110)&(val[:180]>=65))|((hue[:180]>=15)&(hue[:180]<=40)&(sat[:180]>=70)&(val[:180]>=100))
    paint=np.zeros((360,640),np.uint8);paint[:180]=(contrast&chromatic).astype(np.uint8)
    paint[180:]=(((features[180:]&3)!=0)&((features[180:]&4)!=0)).astype(np.uint8)
    paint |= legacy._bounded_wide_paint(hsv,legacy.Config())
    paint[:,:13]=0;paint[:,-13:]=0
    return (paint,cv2.dilate(paint,np.ones((1,3),np.uint8))),hsv
