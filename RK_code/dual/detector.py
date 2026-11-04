





import hashlib,json,time
from pathlib import Path
import cv2
import numpy as np

ROOT=Path(__file__).resolve().parent
MODEL=ROOT/'models/official_yolov8n_rk3568_fp16.rknn'
MANIFEST=ROOT/'models/model_manifest.json'
ONNX_SHA='0c8716701f471067932b797eeb67c8e5db47c693c2557c881d7679ec12e21bc5'
MODEL_SHA=json.loads(MANIFEST.read_text())['rknn_sha256'] if MANIFEST.exists() else None
CLASSES={0:'person',2:'car',3:'motorcycle',5:'bus',7:'truck'}
SIGNAL_CLASSES={9:'traffic light'}

def letterbox(image):
    h,w=image.shape[:2];scale=min(640/w,640/h)
    nw,nh=round(w*scale),round(h*scale);left,top=(640-nw)//2,(640-nh)//2
    canvas=np.zeros((640,640,3),np.uint8)
    resized=image if (nw,nh)==(w,h) else cv2.resize(image,(nw,nh))
    canvas[top:top+nh,left:left+nw]=cv2.cvtColor(resized,cv2.COLOR_BGR2RGB)
    return canvas[None],scale,left,top

def decode(outputs,shape,scale,left,top,threshold=.25,classes=None):
    target_classes=CLASSES if classes is None else classes
    if len(outputs)!=9:raise ValueError(f'Expected nine official outputs, got {len(outputs)}')
    boxes=[];scores=[];labels=[]
    for branch,grid in enumerate([80,40,20]):
        logits,confidence,summary=[np.asarray(x) for x in outputs[branch*3:branch*3+3]]
        for a,channels in [(logits,64),(confidence,80),(summary,1)]:
            if a.shape!=(1,channels,grid,grid) or not np.isfinite(a).all():
                raise ValueError(f'Invalid output shape/values: {a.shape}')
        if confidence.min()<-.001 or confidence.max()>1.001:raise ValueError('Expected sigmoid class probabilities')
        
        
        
        
        target_max=confidence[0,list(target_classes)].max(axis=0)
        yy,xx=np.nonzero(target_max>=threshold)
        if len(yy)==0:continue
        selected=confidence[0][:,yy,xx]
        classes=selected.argmax(axis=0)
        values=selected.max(axis=0)
        target=np.isin(classes,list(target_classes))
        yy,xx,classes,values=yy[target],xx[target],classes[target],values[target]
        if len(yy)==0:continue
        
        d=logits.reshape(4,16,grid,grid)[:,:,yy,xx].astype(np.float32)
        d=np.exp(d-d.max(axis=1,keepdims=True));d/=d.sum(axis=1,keepdims=True)
        distance=(d*np.arange(16)[None,:,None]).sum(axis=1)
        xy=np.stack([xx+.5-distance[0],yy+.5-distance[1],xx+.5+distance[2],yy+.5+distance[3]],axis=1)*(640/grid)
        boxes.extend(xy.tolist());scores.extend(values.astype(float).tolist())
        labels.extend(classes.astype(int).tolist())
    keep=[]
    for label in sorted(set(labels)):
        indices=[i for i,c in enumerate(labels) if c==label]
        local=cv2.dnn.NMSBoxes([[boxes[i][0],boxes[i][1],boxes[i][2]-boxes[i][0],boxes[i][3]-boxes[i][1]] for i in indices],
                              [scores[i] for i in indices],threshold,.45)
        keep.extend(indices[int(i)] for i in np.asarray(local).reshape(-1))
    h,w=shape[:2];result=[]
    for i in np.asarray(keep).reshape(-1):
        b=(np.asarray(boxes[int(i)])-[left,top,left,top])/scale
        b[[0,2]]=np.clip(b[[0,2]],0,w);b[[1,3]]=np.clip(b[[1,3]],0,h)
        if b[2]<=b[0] or b[3]<=b[1]:continue
        result.append(dict(box=b.tolist(),score=scores[int(i)],class_id=labels[int(i)],label=target_classes[labels[int(i)]]))
    return result

def windows(strategy):
    if strategy=='full':return [(0,0,640,360)]
    if strategy=='upper_center':return [(128,0,512,216)]
    if strategy=='tiles':return [(x,y,x+256,y+192) for y in (0,168) for x in (0,192,384)]
    raise ValueError(strategy)

def merge(rows):
    if not rows:return []
    indices=cv2.dnn.NMSBoxes([[b[0],b[1],b[2]-b[0],b[3]-b[1]] for b in (r['box'] for r in rows)],
        [r['score'] for r in rows],.25,.45)
    return [rows[int(i)] for i in np.asarray(indices).reshape(-1)]

class Detector:
    def __init__(self,model=MODEL):
        from rknnlite.api import RKNNLite
        metadata=json.loads(MANIFEST.read_text())
        if metadata['onnx_sha256']!=ONNX_SHA or metadata['target']!='rk3568' or metadata['quantized']:
            raise ValueError('Unexpected official model manifest')
        if hashlib.sha256(Path(model).read_bytes()).hexdigest()!=MODEL_SHA:raise ValueError('Model hash mismatch')
        self.rknn=RKNNLite()
        try:
            rc=self.rknn.load_rknn(str(model))
            if rc:raise RuntimeError(f'load_rknn={rc}')
            rc=self.rknn.init_runtime()
            if rc:raise RuntimeError(f'init_runtime={rc}')
        except BaseException:self.rknn.release();raise

    def detect(self,image,classes=None):
        begin=time.perf_counter()
        tensor,scale,left,top=letterbox(image)
        start=time.perf_counter();outputs=self.rknn.inference(inputs=[tensor]);finished=time.perf_counter();elapsed=finished-start
        if outputs is None:raise RuntimeError('RKNN inference returned no outputs')
        rows=decode(outputs,image.shape,scale,left,top,classes=classes)
        self.last_profile=dict(preprocess_seconds=start-begin,decode_seconds=time.perf_counter()-finished)
        return rows,elapsed

    def regions(self,image,strategy):
        rows=[];elapsed=0.
        for tile,(x1,y1,x2,y2) in enumerate(windows(strategy)):
            found,seconds=self.detect(image[y1:y2,x1:x2]);elapsed+=seconds
            for r in found:rows.append(dict(r,box=(np.asarray(r['box'])+[x1,y1,x1,y1]).tolist(),source_tile=tile))
        return merge(rows),elapsed

    def close(self):self.rknn.release()
