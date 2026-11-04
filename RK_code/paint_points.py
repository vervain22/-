
import cv2,numpy as np
OFFSETS=np.asarray(((0,0),(-1,0),(1,0),(0,-1),(0,1)),dtype=np.int64)
def draw(image,fragments,color):
 points=[p for fragment in fragments for p in fragment]
 if not points:return
 if len(points)<16:
  for x,y in points:cv2.circle(image,(int(x)+640,int(y)),1,color,-1)
  return
 values=np.asarray(points,dtype=np.float64)
 if values.ndim!=2 or values.shape[1]!=2 or not np.isfinite(values).all():raise ValueError('invalid paint points')
 values=values.astype(np.int64);values[:,0]+=640
 h,w=image.shape[:2]
 for start in range(0,len(values),1024):
  q=(values[start:start+1024,None,:]+OFFSETS).reshape(-1,2)
  keep=(q[:,0]>=0)&(q[:,0]<w)&(q[:,1]>=0)&(q[:,1]<h)
  q=q[keep];image[q[:,1],q[:,0]]=color
