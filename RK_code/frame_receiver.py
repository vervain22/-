




from pathlib import Path
import numpy as np


_values=np.arange(4096,dtype=np.uint16)
_COLOR_LUT=np.stack((_values&15,(_values>>4)&15,(_values>>8)&15),axis=1)
_VALID_LUT=(_COLOR_LUT.max(axis=1)<=9)&(_COLOR_LUT.sum(axis=1)<=9)
_COLOR_LUT.flags.writeable=False;_VALID_LUT.flags.writeable=False

def _color_data(color,width,height):
    flat=np.ascontiguousarray(color,dtype=np.uint16).reshape(-1)
    cover=width*(height//2)
    if int(flat[cover])!=0xcf61 or int(flat[cover+1]) not in (1,2):
        raise ValueError('not a paired frame')
    fid=int(flat[cover+2]) | (int(flat[cover+3])<<16)
    if tuple(map(int,flat[cover+4:cover+6]))!=(width,height//2):
        raise ValueError('color coverage mismatch')
    if tuple(map(int,flat[-4:]))!=(0x61cf,fid&65535,fid>>16,0xa55a):
        raise ValueError('incomplete/invalid frame or mismatched trailer')
    
    expected=np.array([(fid>>(k*4))&15 for k in range(8)],np.uint16)
    if flat.size%8:raise ValueError('unaligned tag layout')
    good=((flat>>12).reshape(-1,8)==expected).reshape(-1)
    good[cover:cover+6]=True;good[-4:]=True
    if not good.all():raise ValueError('mixed frame identity')
    codes=flat[:cover]&4095
    if not _VALID_LUT[codes].all():raise ValueError('invalid 3x3 color counts')
    return fid,np.take(_COLOR_LUT,codes,axis=0).reshape(height//2,width,3)

def decode_pairs(words,width=640,height=360):
    a=np.asarray(words,dtype=np.uint32).reshape(height,width)
    fid,counts=_color_data((a>>16).astype(np.uint16),width,height)
    return fid,(a&65535).astype(np.uint16),counts

def decode_dma_inputs(raw):

    if len(raw)!=1280*720*2:raise ValueError('incorrect DMA frame length')
    plane=np.frombuffer(raw,dtype='<u2').reshape(720,1280)
    pairs=plane[:360].reshape(360,640,2)
    fid,counts=_color_data(pairs[:,:,1],640,360)
    return fid,pairs[:,:,0].copy(),plane[360:,:640].copy(),counts


def decode_dma_features(raw):





    if len(raw)!=1280*720*2:raise ValueError('incorrect DMA frame length')
    plane=np.frombuffer(raw,dtype='<u2').reshape(720,1280)
    pairs=plane[:360].reshape(360,640,2)
    flat=np.ascontiguousarray(pairs[:,:,1]).reshape(-1);cover=640*180
    fid,counts=_color_data(flat,640,360)
    hdmi=pairs[:,:,0].copy();camera=plane[360:,:640].copy()
    if int(flat[cover+1])==1:return fid,hdmi,camera,counts,None
    low=flat[cover:]&4095;low[:6]=0;low[-4:]=0
    if np.any(low>7):raise ValueError('reserved lane feature bits set')
    feature=np.zeros((360,640),np.uint8);feature[180:]=low.reshape(180,640)
    if np.any(feature[:,:13]) or np.any(feature[:,-13:]):raise ValueError('lane feature coverage invalid')
    return fid,hdmi,camera,counts,feature

def decode_dma(raw):
    fid,hdmi,camera,counts=decode_dma_inputs(raw)
    
    quad=np.frombuffer(raw,dtype='<u2').reshape(720,1280).copy()
    quad[:360,:640]=hdmi;quad[:360,640:]=hdmi
    return fid,quad,counts

def read_snapshot(path):
    
    
    return decode_dma(Path(path).read_bytes())

if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('raw');p.add_argument('--save-prefix',default='received')
    args=p.parse_args()
    fid,quad,counts=read_snapshot(args.raw)
    np.savez_compressed(args.save_prefix+'.npz',frame_id=fid,image_rgb565=quad,color_counts=counts)
    print(f'VALID frame_id={fid} counts={counts.shape} saved={args.save_prefix}.npz')
