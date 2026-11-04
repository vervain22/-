
import copy,math
from hybrid_signal import iou

class LightBoxHold:
    def __init__(self,seconds=.6):
        self.seconds=seconds;self.generation=None;self.last=None;self.rows=[]
    def update(self,result,now):
        generation=(result.get('scene'),result.get('mode_epoch'))
        if generation!=self.generation:
            self.rows=[];self.last=None;self.generation=generation
        capture=result.get('capture_timestamp')
        source_ok=isinstance(capture,(int,float)) and math.isfinite(capture) and 0<=now-capture<=.5
        packet=result.get('hdmi_objects',{});stamp=packet.get('source_timestamp')
        if not source_ok or result.get('enabled',{}).get('signal') is False:
            self.rows=[];self.last=None
        else:
            if self.last is not None and isinstance(stamp,(int,float)) and stamp<self.last:
                self.rows=[];self.last=None
            self.rows=[r for r in self.rows if 0<=now-r['last_detected_at']<=self.seconds]
            if (packet.get('valid') and isinstance(stamp,(int,float)) and math.isfinite(stamp)
                    and 0<=now-stamp<=.5 and stamp<=capture and stamp!=self.last):
                self.last=stamp
                new=[]
                for row in sorted(packet.get('detections',[]),key=lambda r:r.get('score',0),reverse=True):
                    if row.get('class_id') not in (2,3,4,5):continue
                    if any(iou(row['box'],r['box'])>.3 for r in new):continue
                    new.append(dict(copy.deepcopy(row),last_detected_at=stamp))
                if new:
                    
                    
                    
                    self.rows=new
        visual=[]
        
        if packet.get('valid') and source_ok:
            visual=[copy.deepcopy(r) for r in packet.get('detections',[]) if r.get('class_id') in (0,1)]
        for r in self.rows:
            row=copy.deepcopy(r);row['visual_hold']=row['last_detected_at']!=stamp or not packet.get('valid')
            row['visual_age_s']=now-row['last_detected_at'];visual.append(row)
        result['hdmi_display_objects']=dict(detections=visual,visual_only=True,hold_seconds=self.seconds)
        result['hdmi_display_signal']=display_signal(result)
        return result


def display_signal(result):

    if result.get('enabled',{}).get('signal') is False:
        return dict(text='未启用',states=[],visual_only=True)
    rows=[r for r in result.get('hdmi_display_objects',{}).get('detections',[]) if r.get('class_id') in (2,3,4,5)]
    states=[label for cls,label in ((2,'红'),(5,'黄'),(3,'绿'),(4,'未亮')) if any(r['class_id']==cls for r in rows)]
    if not states:return dict(text='未知',states=[],visual_only=True)
    colors={r['class_id'] for r in rows if r['class_id']!=4}
    held=any(r.get('visual_hold') for r in rows)
    light=result.get('hdmi',{})
    confirmed=(light.get('valid') is True and len(colors)==1
        and light.get('state')=={2:'RED',3:'GREEN',5:'YELLOW'}.get(next(iter(colors))))
    if (light.get('conflict_hold') and light.get('valid') is True
            and light.get('reason')=='RED_GREEN_CONFLICT_KEEP_PREVIOUS'):
        label={'RED':'红','GREEN':'绿','YELLOW':'黄'}.get(light.get('state'))
        if label:
            return dict(text=label+'（红绿冲突，沿用前态）',states=[label],raw_states=states,
                held=True,conflict=True,conflict_hold=True,visual_only=True)
    suffix='冲突' if len(colors)>1 else '保持' if held else '待确认' if not confirmed else ''
    text='/'.join(states)+('（'+suffix+'）' if suffix else '')
    return dict(text=text,states=states,held=held,conflict=len(colors)>1,visual_only=True)
