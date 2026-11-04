


import numpy as np

def resolve(instances,classes,min_score=.5,min_margin=.15):
    if not .25<min_score<1 or not 0<min_margin<1:raise ValueError('Invalid score bounds')
    score=[np.zeros((360,640),np.float32) for _ in range(2)]
    for item in instances:
        cls=item['cls'];value=item['score'];mask=np.asarray(item['mask'])
        if cls not in (0,1,2,3) or mask.shape!=(360,640) or not np.isfinite(value) or not 0<=value<=1:raise ValueError('Invalid instance')
        active=mask.astype(bool);np.maximum(score[cls%2],np.where(active,value,0),out=score[cls%2])
    overlap=(score[0]>0)&(score[1]>0)
    win_d=overlap&(score[0]>=min_score)&(score[0]-score[1]>=min_margin)
    win_s=overlap&(score[1]>=min_score)&(score[1]-score[0]>=min_margin)
    out={key:value.copy() for key,value in classes.items()}
    for key,mask in out.items():mask[win_d if int(key)%2 else win_s]=0
    return out,dict(overlap_pixels=int(overlap.sum()),resolved_dashed=int(win_d.sum()),resolved_solid=int(win_s.sum()),unresolved=int((overlap&~win_d&~win_s).sum()),min_score=min_score,min_margin=min_margin,experimental=True)
