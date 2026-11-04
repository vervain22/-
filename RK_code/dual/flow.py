
from compare import cv2,np

def advance(previous,gray,tracks):
    blocks=[];owners=[];offset=0
    for track in tracks:
        x1,y1,x2,y2=np.asarray(track.box).round().astype(int)
        
        
        left=max(0,x1-8);top=max(0,y1-8)
        right=min(gray.shape[1],x2+8);bottom=min(gray.shape[0],y2+8)
        if right<=left or bottom<=top:continue
        crop=previous[top:bottom,left:right];mask=np.zeros_like(crop)
        mask[max(0,y1-3-top):min(bottom-top,y2+3-top),max(0,x1-3-left):min(right-left,x2+3-left)]=255
        pts=cv2.goodFeaturesToTrack(crop,15,.02,2,mask=mask)
        if pts is None or len(pts)<3:continue
        pts+=np.asarray([left,top],dtype=np.float32)
        blocks.append(pts);owners.append((track,offset,offset+len(pts)));offset+=len(pts)
    if not blocks:return
    points=np.concatenate(blocks)
    nxt,status,_=cv2.calcOpticalFlowPyrLK(previous,gray,points,None)
    if nxt is None or status is None:return
    back,bs,_=cv2.calcOpticalFlowPyrLK(gray,previous,nxt,None)
    if back is None or bs is None:return
    valid=(status.ravel()!=0)&(bs.ravel()!=0)&(np.linalg.norm(back-points,axis=2).ravel()<1.5)
    for track,start,end in owners:
        good=valid[start:end]
        if good.sum()<3:continue
        dx,dy=np.median((nxt-points)[start:end][good,0],axis=0)
        if abs(dx)>30 or abs(dy)>30:track.last_detection=-float('inf');continue
        box=np.asarray(track.box)+[dx,dy,dx,dy]
        box[[0,2]]=np.clip(box[[0,2]],0,gray.shape[1]);box[[1,3]]=np.clip(box[[1,3]],0,gray.shape[0])
        track.box=box.tolist()
