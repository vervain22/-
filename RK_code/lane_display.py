
import math
from lane_timing import DISPLAY_TTL
import cv2,numpy as np

COLORS={'0':(255,220,0),'1':(0,0,255),'2':(0,255,0),'3':(255,0,255)}

def encode(classes):
    result=[]
    for kind,mask in classes.items():
        contours,_=cv2.findContours(mask.astype(np.uint8),cv2.RETR_LIST,cv2.CHAIN_APPROX_SIMPLE)
        result.append(dict(class_id=kind,contours=[c[:,0,:].tolist() for c in contours if len(c)>=3]))
    return result

def consume(row,now,display_stamp):
    stamp=(row or {}).get('source_timestamp')
    if not all(isinstance(v,(int,float)) and math.isfinite(v) for v in (stamp,now,display_stamp)):return []
    if not 0<=now-stamp<=DISPLAY_TTL or not stamp<=display_stamp<=now or now-display_stamp>.5:return []
    return (row or {}).get('model_display',[])


_cached_rows=None
_cached_pixels=[]
_BLEND={kind:((np.arange(256,dtype=np.float64)[:,None]*.4+
              np.asarray(color,dtype=np.float64)[None,:]*.6).astype(np.uint8))
        for kind,color in COLORS.items()}

def _prepare(rows):
    prepared=[];mask=np.zeros((360,640),np.uint8)
    for row in rows:
        kind=row['class_id']
        if kind not in COLORS:raise ValueError('Invalid lane display class')
        mask.fill(0)
        contours=[np.asarray(c,dtype=np.int32).reshape(-1,1,2) for c in row['contours']]
        for contour in contours:
            if (contour<0).any() or (contour[:,:,0]>=640).any() or (contour[:,:,1]>=360).any():raise ValueError('Invalid native contour')
        cv2.drawContours(mask,contours,-1,1,cv2.FILLED)
        prepared.append((kind,np.nonzero(mask)))
    return prepared

def draw(image,rows):
    global _cached_rows,_cached_pixels
    if not rows:return
    if rows is not _cached_rows:
        pixels=_prepare(rows)
        _cached_rows=rows;_cached_pixels=pixels
    for kind,(ys,xs) in _cached_pixels:
        values=image[ys,xs]
        image[ys,xs]=_BLEND[kind][values,np.arange(3)]
