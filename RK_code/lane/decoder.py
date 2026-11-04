
import cv2
import numpy as np

def decode(outputs,conf=.25,iou=.5):
    if len(outputs)!=2:raise ValueError('Expected detections and prototypes')
    det,proto=[np.asarray(o,dtype=np.float32) for o in outputs]
    if det.shape!=(1,40,5040) or proto.shape!=(1,32,96,160):raise ValueError('Unexpected output layout')
    if not np.isfinite(det).all() or not np.isfinite(proto).all():raise ValueError('Nonfinite model output')
    if not 0<conf<1 or not 0<iou<1:raise ValueError('Invalid thresholds')
    rows=det[0].T;cls=rows[:,4:8].argmax(1);scores=rows[np.arange(len(rows)),4+cls]
    idx=np.flatnonzero(scores>conf);idx=idx[np.argsort(-scores[idx],kind='stable')][:30000]
    boxes=np.empty((len(rows),4),np.float32)
    boxes[:,:2]=rows[:,:2]-rows[:,2:4]/2;boxes[:,2:]=rows[:,:2]+rows[:,2:4]/2
    selected=[]
    while len(idx) and len(selected)<300:
        k=int(idx[0]);selected.append(k);rest=idx[1:]
        lo=np.maximum(boxes[k,:2],boxes[rest,:2]);hi=np.minimum(boxes[k,2:],boxes[rest,2:])
        wh=np.maximum(hi-lo,0);intersection=wh[:,0]*wh[:,1]
        size=np.maximum(boxes[rest,2:]-boxes[rest,:2],0);area=size[:,0]*size[:,1]
        own=np.maximum(boxes[k,2:]-boxes[k,:2],0);overlap=intersection/(area+own.prod()-intersection+1e-7)
        idx=rest[~((cls[rest]==cls[k])&(overlap>iou))]
    if not selected:return []
    
    
    logits=np.einsum('nc,cp->np',rows[selected,8:],proto[0].reshape(32,-1),optimize=False).reshape(-1,96,160)
    yy=np.arange(360)[:,None];xx=np.arange(640)[None,:];result=[]
    for k,logit in zip(selected,logits):
        box=boxes[k].copy();box[[1,3]]-=12;box[[0,2]]=np.clip(box[[0,2]],0,640);box[[1,3]]=np.clip(box[[1,3]],0,360)
        
        
        mask=(cv2.resize(logit[3:93],(640,360),interpolation=cv2.INTER_LINEAR)>0)
        mask&=(xx>=box[0])&(xx<box[2])&(yy>=box[1])&(yy<box[3])
        if mask.any():result.append(dict(cls=int(cls[k]),score=float(scores[k]),box=box.tolist(),mask=mask.astype(np.uint8)))
    return result

def class_masks(instances):
    result={}
    for item in instances:
        key=str(item['cls']);result.setdefault(key,np.zeros((360,640),np.uint8))[:] |= item['mask']
    return result
