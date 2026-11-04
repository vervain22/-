
import numpy as np
import cv2
from paint_evidence import prepare


def _wide_paint_background(image,raw_paint,covered,local,ys,xs):

    ly,lx=local[:,1],local[:,0]
    if min(float((raw_paint[ly,lx-10]>0).mean()),float((raw_paint[ly,lx+10]>0).mean()))<.5:return None
    oy=np.repeat(ys,2);ox=(xs[:,None]+np.array([-10,10])).reshape(-1)
    if covered[oy,ox].any():return None
    outside=[]
    for direction in (-10,10):
        valid=raw_paint[ys,xs+direction]==0
        if valid.mean()<.8:return None
        outside.append(np.median(image[ys[valid],xs[valid]+direction],axis=0))
    edge=np.diff(np.pad((raw_paint[ly]>0).astype(np.int8),((0,0),(1,1))),axis=1)
    rows,lo=np.where(edge==1);end_rows,hi=np.where(edge==-1);hi=hi-1
    assert np.array_equal(rows,end_rows)
    selected=(lo-1<=lx[rows])&(lx[rows]<=hi+1)&(hi-lo+1>=12)&(hi-lo+1<=48)
    rows,lo,hi=rows[selected],lo[selected],hi[selected]
    if not np.array_equal(rows,np.arange(len(local))):return None
    px=np.concatenate((lo[:,None]-np.array([2,4,6]),hi[:,None]+np.array([2,4,6])),axis=1)
    if (px<0).any() or (px>=640).any() or raw_paint[ly[:,None],px].any() or covered[ly[:,None],px].any():return None
    pixels=image[ly[:,None],px].reshape(len(local),2,3,3)
    backgrounds=np.median(pixels,axis=2)
    coordinates=np.stack((px,np.broadcast_to(ly[:,None],px.shape)),axis=-1).tolist()
    return np.median(backgrounds,axis=0),coordinates,np.asarray(outside)


def inspect(image,objects,fragments,prepared=None,image_hsv=None):
    if image is None:return dict(checked=False,reason='SOURCE_CONTEXT_MISSING',ends=[])
    if objects is None:objects=np.zeros((360,640),np.uint8)
    if prepared is None:prepared=prepare(image,objects)
    _,near,covered=prepared
    points=np.array([p for f in fragments for p in f],dtype=int)
    points=points[np.argsort(points[:,1])];ends=[]
    hsv=cv2.cvtColor(image,cv2.COLOR_BGR2HSV) if image_hsv is None else image_hsv
    if hsv.shape!=image.shape or hsv.dtype!=np.uint8:raise ValueError('Invalid same-source HSV context')
    for direction in [-1,1]:
        edge=points[0] if direction==-1 else points[-1]
        local=points[points[:,1]<=edge[1]+12] if direction==-1 else points[points[:,1]>=edge[1]-12]
        record=dict(direction=direction,status='UNAVAILABLE',edge_point=edge.tolist())
        if len(local)<8:ends.append(record);continue
        fit=np.polyfit(local[:,1]-edge[1],local[:,0],1)
        if np.quantile(abs(np.polyval(fit,local[:,1]-edge[1])-local[:,0]),.9)>2:
            record['status']='CURVED_OR_UNSTABLE';ends.append(record);continue
        context=points[points[:,1]<=edge[1]+24] if direction==-1 else points[points[:,1]>=edge[1]-24]
        if len(context)>len(local) and np.quantile(abs(np.polyval(fit,context[:,1]-edge[1])-context[:,0]),.9)>3:
            record['status']='CURVED_OR_UNSTABLE';ends.append(record);continue
        ys=edge[1]+direction*np.arange(3,13);xs=np.rint(np.polyval(fit,ys-edge[1])).astype(int)
        if np.any(ys<0) or np.any(ys>=360) or np.any(xs<13) or np.any(xs>=627):ends.append(record);continue
        record['inspected_points']=np.column_stack([xs,ys]).tolist()
        if covered[ys,xs].any():record['status']='OCCLUDED';ends.append(record);continue
        
        offsets=np.array([-10,10])[:,None]
        
        
        
        
        if (np.any(local[:,0]<10) or np.any(local[:,0]>=image.shape[1]-10)
                or np.any(local[:,1]<0) or np.any(local[:,1]>=image.shape[0])):
            record['reason']='SOURCE_CONTEXT_OUT_OF_BOUNDS';ends.append(record);continue
        lateral=np.median(image[ys[None,:],xs[None,:]+offsets],axis=1)
        inside=np.median(image[local[None,:,1],local[None,:,0]+offsets],axis=1)
        change=float(np.sqrt(np.mean((np.mean(lateral,axis=0)-np.mean(inside,axis=0))**2)))
        fraction=float((near[ys,xs]>0).mean())
        if change>35:
            corrected=_wide_paint_background(image,prepared[0],covered,local,ys,xs)
            if corrected is not None:
                background,coordinates,outside=corrected
                record.update(background_sampling='OUTSIDE_BOUNDED_SOURCE_PAINT',original_background_change=change,background_sample_points=coordinates)
                change=float(np.sqrt(np.mean((np.mean(outside,axis=0)-np.mean(background,axis=0))**2)))
        if change>35:status='SCENE_CHANGE'
        elif fraction<=.2:status='VISIBLE_PAINT_END'
        elif fraction>=.8:status='PAINT_CONTINUES'
        else:status='AMBIGUOUS'
        record.update(status=status,paint_fraction=fraction,background_change=change,
                      inspected_points=np.column_stack([xs,ys]).tolist())
        if status=='VISIBLE_PAINT_END':
            
            
            extra_y=edge[1]+direction*np.arange(13,61)
            extra_x=np.rint(np.polyval(fit,extra_y-edge[1])).astype(int)
            valid=(extra_y>=0)&(extra_y<360)&(extra_x>=13)&(extra_x<627)
            ey,ex=extra_y[valid],extra_x[valid]
            color=hsv[local[:,1],local[:,0]]
            yellow=float(((color[:,0]>=15)&(color[:,0]<=40)&(color[:,1]>=70)).mean())>=.5
            blocked=np.flatnonzero(covered[ey,ex])
            if len(blocked):ey,ex=ey[:blocked[0]],ex[:blocked[0]]
            color=hsv[ey,ex]
            pixel_yellow=(color[:,0]>=15)&(color[:,0]<=40)&(color[:,1]>=70)
            supported=(near[ey,ex]!=0)&(pixel_yellow==yellow)
            resumed=bool(np.any(supported[:-2]&supported[1:-1]&supported[2:])) if len(supported)>=3 else False
            transitions=np.diff(np.r_[False,supported,False].astype(np.int8))
            starts=np.flatnonzero(transitions==1);stops=np.flatnonzero(transitions==-1)
            longest=int(np.max(stops-starts)) if len(starts) else 0
            record['resumption_run']=longest
            record['strict_gap_resumption']=bool(fraction==0 and change<=15 and longest>=6)
            record['paint_resumes']=resumed
            record['status']='GAP_THEN_PAINT_RESUMPTION' if resumed else 'PAINT_END_CAUSE_UNRESOLVED'
        ends.append(record)
    return dict(checked=True,ends=ends,clear_end=any(e['status']=='GAP_THEN_PAINT_RESUMPTION' for e in ends))
