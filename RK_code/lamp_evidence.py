
import math
import numpy as np

def merge_lamps(rows):





    out=[]
    for row in sorted(rows,key=lambda r:-r['score']):
        if row['class_id'] not in (2,3,4,5):continue
        a=np.asarray(row['box'],dtype=float)
        if a.shape!=(4,) or not np.isfinite(a).all() or np.any(a[2:]<=a[:2]):
            raise ValueError('invalid lamp box')
        for group in out:
            b=np.asarray(group['box'],dtype=float)
            inter=np.maximum(0,np.minimum(a[2:],b[2:])-np.maximum(a[:2],b[:2])).prod()
            aa=np.prod(a[2:]-a[:2]);bb=np.prod(b[2:]-b[:2])
            close=np.all(np.abs((a[:2]+a[2:]-b[:2]-b[2:])/2)<=.25*np.minimum(a[2:]-a[:2],b[2:]-b[:2]))
            if close and (inter/(aa+bb-inter)>=.65 or inter/min(aa,bb)>=.9):
                group['members'].append(dict(row));break
        else:out.append(dict(row,members=[dict(row)]))
    return out
def evidence(counts,box):
    if counts.shape!=(180,640,3):raise ValueError('color shape')
    if len(box)!=4 or not all(math.isfinite(v) for v in box):raise ValueError('box')
    x0,y0,x1,y1=box
    if not 0<=x0<x1<=640 or not 0<=y0<y1<=360:raise ValueError('box bounds')
    if y1>180:return dict(status='outside_color_coverage',totals=None)
    
    
    a,b,c,d=math.floor(x0),math.floor(y0),math.ceil(x1),math.ceil(y1)
    totals=counts[b:d,a:c].sum(axis=(0,1),dtype=np.uint64).tolist()
    peak=max(totals);names=('red','green','yellow')
    winners=[names[i] for i,v in enumerate(totals) if v==peak]
    return dict(status=winners[0] if peak and len(winners)==1 else 'no_color' if not peak else 'conflict',
                totals=totals,cells=[a,b,c,d])
