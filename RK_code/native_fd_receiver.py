
import ctypes
from pathlib import Path
import numpy as np
from native_receiver import _errors
_lib=ctypes.CDLL(str((Path(__file__).resolve().parent/'lib/native_fd.so').resolve()))
_lib.decode_fd.argtypes=[ctypes.c_int]+[ctypes.c_void_p]*5
_lib.decode_fd.restype=ctypes.c_int
def decode_fd(fd):
    hdmi=np.empty((360,640,3),np.uint8);camera=np.empty_like(hdmi)
    counts=np.empty((180,640,3),np.uint16);features=np.empty((360,640),np.uint8);fid=ctypes.c_uint32()
    code=_lib.decode_fd(fd,hdmi.ctypes.data,camera.ctypes.data,counts.ctypes.data,features.ctypes.data,ctypes.byref(fid))
    if code==9:raise OSError('native frame read failed')
    if code not in (0,100):raise ValueError(_errors.get(code,'native fd decoder failure'))
    return fid.value,hdmi,camera,counts,None if code==100 else features
