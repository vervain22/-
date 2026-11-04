
import copy

class SampleBuffer:
    def __init__(self,limit=8,max_bytes=64*1024*1024):
        if limit<1 or max_bytes<1:raise ValueError('Invalid sample bounds')
        self.limit=limit;self.max_bytes=max_bytes;self.bytes=0;self.rows=[];self.dropped=0

    def append(self,display,result,debug):
        row,(image,outputs)=debug
        size=display.nbytes+image.nbytes+sum(value.nbytes for value in outputs)
        if len(self.rows)>=self.limit or self.bytes+size>self.max_bytes:
            self.dropped+=1;return False
        
        saved=(copy.deepcopy(row),(image.copy(),[value.copy() for value in outputs]))
        self.rows.append((display.copy(),copy.deepcopy(result),saved));self.bytes+=size
        return True

    def flush(self,out,sink):
        for index,(display,result,debug) in enumerate(self.rows):sink(out,index,display,result,debug)
        return len(self.rows)
