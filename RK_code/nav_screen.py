
import copy
import cv2
import numpy as np
PROFILES=('off','material3_lower_left')


MATERIAL3=np.array([[0,180],[400,190],[400,360],[0,360]],dtype=np.float32)
LIGHT_CLASSES={2,3,4,5}

def filter_screen_lights(rows,profile='off'):
    if profile not in PROFILES:raise ValueError(profile)
    if profile=='off':return copy.deepcopy(rows),[]
    kept=[];excluded=[]
    for item in rows:
        box=np.asarray(item.get('box',[]),dtype=float)
        overlap=0.
        if item.get('class_id') in LIGHT_CLASSES and box.shape==(4,) and np.isfinite(box).all():
            x,y,z,w=box
            if 0<=x<z<=640 and 0<=y<w<=360:
                rect=np.array([[x,y],[z,y],[z,w],[x,w]],dtype=np.float32)
                area,_=cv2.intersectConvexConvex(MATERIAL3,rect)
                overlap=max(0.,float(area))/((z-x)*(w-y))
        if overlap>=.8:
            excluded.append(dict(copy.deepcopy(item),exclusion_reason='MATERIAL3_NAVIGATION_SCREEN',screen_overlap=overlap))
        else:kept.append(copy.deepcopy(item))
    return kept,excluded
