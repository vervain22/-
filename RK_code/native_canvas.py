
import ctypes
from pathlib import Path
import numpy as np
lib=ctypes.CDLL(str(Path(__file__).resolve().parent/'lib/libnative_canvas.so'))
lib.canvas_fill.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p,ctypes.c_int]
def base_canvas(hdmi,camera):
    images=[]
    for image in (hdmi,camera):
        if image is not None:
            if image.shape!=(360,640,3) or image.dtype!=np.uint8:raise ValueError('canvas expects 640x360 BGR8')
            if image.strides[1:]!=(3,1) or image.strides[0]<1920:image=np.ascontiguousarray(image)
        images.append(image)
    out=np.empty((816,1280,3),np.uint8)
    h,c=images
    rc=lib.canvas_fill(out.ctypes.data,out.strides[0],h.ctypes.data if h is not None else None,h.strides[0] if h is not None else 0,c.ctypes.data if c is not None else None,c.strides[0] if c is not None else 0)
    if rc:raise RuntimeError('native canvas '+str(rc))
    return out
