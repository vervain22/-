
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
for name in ('dual','lane','control'):
    sys.path.insert(0,str(ROOT/name))

def runtime():
    import ctypes
    path=ROOT/'lib/librknnrt.so'
    if not path.is_file():raise FileNotFoundError(path)
    original=ctypes.CDLL
    def load(name,*args,**kwargs):
        return original(str(path) if str(name).endswith('librknnrt.so') else name,*args,**kwargs)
    ctypes.CDLL=load
    ctypes.cdll.LoadLibrary=lambda name:load(name)
