
import numpy as np
def candidates(raw,colors):
 obj=1/(1+np.exp(-raw[:,4]))
 ids=np.argwhere((obj>=.02)&(obj<.25))
 if not len(ids):return ids,np.empty(0,dtype=np.int64),np.empty(0,dtype=raw.dtype),obj
 logits=raw[ids[:,0],5:11,ids[:,1],ids[:,2]]
 classes=logits.argmax(axis=1);cp=1/(1+np.exp(-logits.max(axis=1)))
 keep=(cp>=.8)&np.isin(classes,list(colors))
 return ids[keep],classes[keep],cp[keep],obj
