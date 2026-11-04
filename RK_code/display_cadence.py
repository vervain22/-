
import time
class DisplayCadence:
    def __init__(self,hz,clock=time.monotonic):
        if hz<=0:raise ValueError('positive rate required')
        self.period=1./hz;self.clock=clock;self.deadline=clock()+self.period
    def wait(self,stop):
        now=self.clock()
        if now<self.deadline:stop.wait(self.deadline-now)
        now=self.clock()
        self.deadline=max(self.deadline+self.period,now+self.period)
