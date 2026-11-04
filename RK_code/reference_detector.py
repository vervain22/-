
import ctypes,hashlib,time,os
from pathlib import Path
import numpy as np
from weak_review import review,COLORS
from weak_scan import candidates as scan_candidates
ROOT=Path(__file__).resolve().parent
MODEL_SHA='62296449866eefb1391015cce7592007bd0fb35a6062cc510c72953bd4dd7db4'
NAMES=('zebra','person','red','green','black','yellow')
class ReferenceDetector:
    def __init__(self):
        path=ROOT/'reference/best_rk3568.rknn'
        if hashlib.sha256(path.read_bytes()).hexdigest()!=MODEL_SHA:raise ValueError('reference model SHA')
        self.lib=ctypes.CDLL(os.environ.get('ADAS_REFERENCE_PROFILE_LIB',str(ROOT/'lib/reference_runtime.so')))
        if hasattr(self.lib,'reference_stage_ms'):
            self.lib.reference_stage_ms.argtypes=[ctypes.c_int]
            self.lib.reference_stage_ms.restype=ctypes.c_double
        self.lib.reference_head.argtypes=[ctypes.c_int]
        self.lib.reference_head.restype=ctypes.POINTER(ctypes.c_float)
        self.lib.reference_error.restype=ctypes.c_char_p
        self.lib.reference_init.argtypes=[ctypes.c_char_p]
        self.lib.reference_detect.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_void_p,ctypes.c_int]
        if self.lib.reference_init(str(path).encode()):raise RuntimeError(self.lib.reference_error().decode())
    def detect(self,image,on_strong=None):
        if image.shape!=(360,640,3) or image.dtype!=np.uint8:raise ValueError('640x360 uint8 required')
        image=np.ascontiguousarray(image);out=np.empty((256,6),np.float32);start=time.perf_counter()
        count=self.lib.reference_detect(image.ctypes.data,640,360,out.ctypes.data,256)
        native_finished=time.perf_counter()
        if count<0:raise RuntimeError(self.lib.reference_error().decode())
        strong=[dict(class_id=int(r[0]),label=NAMES[int(r[0])],score=float(r[1]),box=r[2:].astype(float).tolist()) for r in out[:count]]
        if on_strong is not None:on_strong(strong)
        weak_start=time.perf_counter();weak=[];proposed=0
        anchors=(((5.64062,12.39062),(7.85547,18.5),(10.71875,28.14062)),((63.5,9.07812),(15.92188,41.3125),(25.48438,69.9375)),((218.375,16.32812),(49.90625,100.3125),(612.5,90.0)))
        for head,stride in enumerate((8,16,32)):
            g=640//stride;ptr=self.lib.reference_head(head)
            if not ptr:raise RuntimeError('missing reference raw head')
            raw=np.ctypeslib.as_array(ptr,shape=(33*g*g,)).reshape(3,11,g,g)
            ids,selected_classes,selected_cp,obj=scan_candidates(raw,COLORS)
            for (a,y,x),cls,prob in zip(ids,selected_classes,selected_cp):
                proposed+=1
                v=1/(1+np.exp(-raw[a,:4,y,x]));cx=(v[0]*2-.5+x)*stride;cy=(v[1]*2-.5+y)*stride-140
                w,h=(v[2:4]*2)**2*np.array(anchors[head][a]);box=[float(np.clip(cx-w/2,0,639)),float(np.clip(cy-h/2,0,359)),float(np.clip(cx+w/2,0,639)),float(np.clip(cy+h/2,0,359))]
                c=dict(cls=int(cls),obj=float(obj[a,y,x]),class_prob=float(prob),box=box)
                weak.append(c)
        scan_finished=time.perf_counter()
        def overlap(a,b):
            a=np.array(a);b=np.array(b);inter=np.maximum(0,np.minimum(a[2:],b[2:])-np.maximum(a[:2],b[:2])).prod()
            return inter/max(1e-9,np.prod(a[2:]-a[:2])+np.prod(b[2:]-b[:2])-inter)
        accepted=[];reviewed=0
        for c in sorted(weak,key=lambda c:-c['obj']*c['class_prob']):
            if any(r['class_id']==c['cls'] and overlap(r['box'],c['box'])>.4 for r in strong+accepted):continue
            reviewed+=1
            evidence=review(image,c)
            if evidence['accepted']:
                accepted.append(dict(class_id=c['cls'],label=NAMES[c['cls']],score=c['obj']*c['class_prob'],box=c['box'],weak_review=True,objectness=c['obj'],class_probability=c['class_prob'],review_reason=evidence['reason']))
        self.last_profile=dict(weak_proposed=proposed,weak_reviewed=reviewed,weak_accepted=len(accepted),weak_seconds=time.perf_counter()-weak_start, native_seconds=native_finished-start, strong_decode_seconds=weak_start-native_finished, weak_scan_seconds=scan_finished-weak_start, weak_review_seconds=time.perf_counter()-scan_finished)
        if hasattr(self.lib,'reference_stage_ms'):
            self.last_profile['native_stage_ms']={k:self.lib.reference_stage_ms(i) for i,k in enumerate(('preprocess','inference_io','decode','total'))}
        return strong+accepted,time.perf_counter()-start
    def close(self):self.lib.reference_close()
