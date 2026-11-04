
import ctypes,os
from pathlib import Path
import numpy as np
_path=Path(os.environ.get('ADAS_NATIVE_DECODE',str((Path(__file__).resolve().parent/'lib/native_decode.so'))))
_lib=ctypes.CDLL(str(_path.resolve()))
_lib.decode_bgr.argtypes=[ctypes.c_void_p,ctypes.c_size_t]+[ctypes.c_void_p]*5
_lib.decode_bgr.restype=ctypes.c_int
_errors={1:'incorrect DMA frame length',2:'not a paired frame',3:'color coverage mismatch',4:'incomplete/invalid frame or mismatched trailer',5:'mixed frame identity',6:'invalid 3x3 color counts',7:'reserved lane feature bits set',8:'lane feature coverage invalid'}
def decode_bgr(raw):
    if not isinstance(raw,bytes):raise TypeError('owned immutable bytes required')
    hdmi=np.empty((360,640,3),np.uint8);camera=np.empty_like(hdmi)
    counts=np.empty((180,640,3),np.uint16);features=np.empty((360,640),np.uint8)
    fid=ctypes.c_uint32()
    code=_lib.decode_bgr(ctypes.c_char_p(raw),len(raw),hdmi.ctypes.data,camera.ctypes.data,counts.ctypes.data,features.ctypes.data,ctypes.byref(fid))
    if code not in (0,100):raise ValueError(_errors.get(code,'native decoder failure'))
    return fid.value,hdmi,camera,counts,None if code==100 else features
