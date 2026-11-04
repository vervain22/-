import ctypes
from pathlib import Path
import cv2
class NativeDisplay:
 def __init__(self):
  self.lib=ctypes.CDLL(str(Path(__file__).resolve().parent/'lib/bounded_display.so'))
  self.lib.nd_show.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int]
  self.lib.nd_threads(1);self.opened=False;self.fullscreen=True
 def install(self):
  self.original={name:getattr(cv2,name) for name in ('namedWindow','resizeWindow','moveWindow','setWindowProperty','imshow','waitKey','destroyAllWindows')}
  cv2.namedWindow=lambda *a:None;cv2.resizeWindow=lambda *a:None;cv2.moveWindow=lambda *a:None
  cv2.setWindowProperty=self.property;cv2.imshow=self.show;cv2.waitKey=lambda _:self.lib.nd_poll();cv2.destroyAllWindows=self.close
 def property(self,name,prop,value):
  if prop==cv2.WND_PROP_FULLSCREEN:
   self.fullscreen=value==cv2.WINDOW_FULLSCREEN
   if self.opened:self.lib.nd_fullscreen(int(self.fullscreen))
 def show(self,name,frame):
  if frame.dtype.name!='uint8' or frame.ndim!=3 or frame.shape[2]!=3 or frame.strides[2]!=1 or frame.strides[1]!=3:raise ValueError('native display requires interleaved BGR8')
  if not self.opened:
   code=self.lib.nd_open(frame.shape[1],frame.shape[0])
   if code:raise RuntimeError('bounded XRender initialization '+str(code))
   self.opened=True;self.lib.nd_fullscreen(int(self.fullscreen))
  if self.lib.nd_show(frame.ctypes.data,frame.shape[1],frame.shape[0],frame.strides[0]):raise RuntimeError('bounded XRender upload failed')
 def close(self):
  self.lib.nd_close();self.opened=False
 def uninstall(self):
  self.close()
  for name,value in self.original.items():setattr(cv2,name,value)
