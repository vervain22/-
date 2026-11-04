
import copy,math
from lane_record import build

def packet(available=False,stamp=0,end=0,**kwargs):
    return dict(available=available,source_timestamp=stamp,valid_until=end,**kwargs)

def environment(now,lane_row=None,dual=None,lane_source='HDMI'):
    env=dict(signal=packet(state='UNKNOWN',qualified=False),camera=packet(risk='UNKNOWN',targets=[],qualified=False),
        lanes=packet(source=lane_source,left={},right={}))
    
    if lane_row and lane_row.get('image_source','HDMI')==lane_source:
        obs=build(lane_row,now,source=lane_source)
        env['lanes']=packet(obs['current'],obs['source_timestamp'],obs['valid_until'] or 0,source=lane_source,
            **{a['image_side']:dict(candidate=a['candidate_type'],stable=a['temporal_type'],qualified=False,reason=a['reason']) for a in obs['sides']})
    if dual:
        h=dual.get('hdmi',{});c=dual.get('camera',{})
        hs=h.get('source_timestamp',0);cs=c.get('source_timestamp',0)
        env['signal']=packet(h.get('valid') is True,hs,h.get('expires_at',0),state=h.get('state','UNKNOWN'),qualified=False)
        
        
        targets=copy.deepcopy(c.get('detections',[])) if c.get('valid') is True else []
        env['camera']=packet(c.get('valid') is True,cs,c.get('expires_at',0),risk='UNKNOWN',targets=targets,qualified=False)
    return env

def scripted(now,case='clear'):
    if case not in ('clear','red','yellow','solid_left','solid_right','risk','missing'):raise ValueError('Unknown scripted fixture')
    fresh=dict(available=True,source_timestamp=now,valid_until=now+.5)
    env=dict(signal=dict(fresh,state='GREEN',qualified=True),camera=dict(fresh,risk='CLEAR',targets=[],qualified=True),
        lanes=dict(fresh,source='HDMI',left=dict(candidate='DASHED',stable='DASHED',qualified=True),right=dict(candidate='DASHED',stable='DASHED',qualified=True)))
    if case in ('red','yellow'):env['signal']['state']=case.upper()
    if case.startswith('solid_'):env['lanes'][case[6:]]=dict(candidate='SOLID',stable='SOLID',qualified=True)
    if case=='risk':env['camera']['risk']='HIGH'
    if case=='missing':env['camera']['available']=False
    return env
