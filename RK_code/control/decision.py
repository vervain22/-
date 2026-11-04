
import copy,math
from lane_timing import EVIDENCE_TTL
from collections import deque

VIEWS={'FORWARD':'FRONT','REVERSE':'REAR','CHANGE_LEFT':'LEFT_REAR','CHANGE_RIGHT':'RIGHT_REAR','TURN_LEFT':'LEFT','TURN_RIGHT':'RIGHT'}
ACTIONS={'NEUTRAL','FORWARD','BACKWARD','CHANGE_LEFT','CHANGE_RIGHT','TURN_LEFT','TURN_RIGHT','STOP','RESET','SCENE_INTERSECTION','SCENE_LANE_CHANGE','SCENE_CAMERA_RISK'}

def fresh(entry,now,max_age=.5):
    if not entry or entry.get('available') is not True:return False
    stamp=entry.get('source_timestamp');end=entry.get('valid_until')
    return (isinstance(stamp,(int,float)) and isinstance(end,(int,float)) and math.isfinite(stamp)
        and math.isfinite(end) and 0<=now-stamp<=max_age and now<=min(end,stamp+max_age))

def evaluate(action,env,now,scene,lane_index,mode,lane_source='HDMI'):
    reasons=[];blocks=[];waits=[]
    if action=='STOP':return dict(status='STOP',reasons=[],alarm=False)
    camera=env.get('camera',{});signal=env.get('signal',{});lanes=env.get('lanes',{})
    if not fresh(camera,now):waits.append('CAMERA_MISSING_OR_EXPIRED')
    elif camera.get('risk')=='HIGH':blocks.append('CAMERA_HIGH_RISK')
    elif camera.get('risk')!='CLEAR' or camera.get('qualified') is not True:waits.append('CAMERA_RISK_UNASSESSED')
    if scene in ('INTERSECTION','NIGHT') and action!='REVERSE':
        if not fresh(signal,now):waits.append('SIGNAL_MISSING_OR_EXPIRED')
        elif signal.get('state') in ('RED','YELLOW'):blocks.append('SIGNAL_'+signal['state'])
        elif signal.get('state')!='GREEN' or signal.get('qualified') is not True:waits.append('SIGNAL_UNKNOWN_OR_UNQUALIFIED')
    if action in ('CHANGE_LEFT','CHANGE_RIGHT'):
        side='left' if action=='CHANGE_LEFT' else 'right'
        if lane_index==0 and side=='left' or lane_index==2 and side=='right':blocks.append('VIRTUAL_ROAD_EDGE')
        if not fresh(lanes,now,max_age=EVIDENCE_TTL) or lanes.get('source')!=lane_source:waits.append('LANE_SOURCE_MISSING_OR_EXPIRED')
        else:
            boundary=lanes.get(side,{})
            if boundary.get('candidate')=='SOLID':blocks.append('SOLID_MODEL_CANDIDATE')
            elif boundary.get('stable')!='DASHED':waits.append('LANE_TYPE_NOT_STABLE')
            elif boundary.get('qualified') is not True:waits.append('EGO_BOUNDARY_NOT_QUALIFIED')
    
    
    if mode!='SCRIPTED':waits.append('OBSERVATION_ONLY_NOT_ACCEPTED_FOR_EXECUTION')
    reasons.extend(waits);reasons.extend(blocks)
    return dict(status='WAIT' if waits else 'BLOCK' if blocks else 'ALLOW_SIMULATED',reasons=reasons,alarm=bool(blocks))

class Engine:
    def __init__(self,mode='OBSERVATION',scene='LANE_CHANGE',lane_source='HDMI'):
        if mode not in ('SCRIPTED','OBSERVATION'):raise ValueError('Explicit mode required')
        if scene not in ('INTERSECTION','LANE_CHANGE','CAMERA_RISK','NIGHT') or lane_source not in ('HDMI','CAMERA'):raise ValueError('Invalid scene/source')
        self.mode=mode;self.scene=scene;self.lane_source=lane_source;self.seen=deque(maxlen=64);self.last_now=None;self.reset()
    def reset(self):
        self.intent='STOP';self.executed='STOP';self.lane_index=1;self.armed=False;self.view='FRONT';self.last_feedback=dict(status='STOP',reasons=['INITIAL_STOP'])
    def update(self,now,env,event=None):
        if not isinstance(now,(int,float)) or not math.isfinite(now):raise ValueError('Finite clock required')
        if self.last_now is not None and now<self.last_now:
            self.reset();self.last_feedback=dict(status='WAIT',reasons=['CLOCK_MOVED_BACKWARD']);event=None
        self.last_now=now;requested=None;event_status=None
        if event:
            ident=event.get('id');stamp=event.get('timestamp');action=event.get('action')
            valid=(isinstance(ident,int) and not isinstance(ident,bool) and isinstance(stamp,(int,float))
                and math.isfinite(stamp) and 0<=now-stamp<=.5 and action in ACTIONS)
            if not valid:
                self.intent=self.executed='STOP';self.armed=False;event_status=dict(status='WAIT',reasons=['INVALID_OR_EXPIRED_EVENT'])
            elif ident in self.seen:event_status=dict(status='IGNORED',reasons=['DUPLICATE_EVENT'])
            else:
                self.seen.append(ident)
                if action=='NEUTRAL':self.armed=True
                elif action in ('RESET','SCENE_INTERSECTION','SCENE_LANE_CHANGE','SCENE_CAMERA_RISK'):
                    self.reset()
                    if action.startswith('SCENE_'):self.scene=action[6:]
                    event_status=dict(status='STOP',reasons=['CONFIGURATION_STOP_REQUIRES_NEUTRAL'])
                elif action=='STOP':
                    self.intent=self.executed='STOP';self.armed=False;event_status=dict(status='STOP',reasons=['EXPLICIT_STOP'])
                elif not self.armed:event_status=dict(status='IGNORED',reasons=['RETURN_TO_NEUTRAL_REQUIRED'])
                else:
                    self.armed=False
                    if action in ('FORWARD','BACKWARD'):
                        requested=('STOP' if self.executed=='REVERSE' else 'FORWARD') if action=='FORWARD' else ('STOP' if self.executed=='FORWARD' else 'REVERSE')
                        self.intent=requested
                    else:requested=action
        action=requested or self.intent
        self.view=VIEWS.get(action,self.view)
        decision=evaluate(action,env,now,self.scene,self.lane_index,self.mode,self.lane_source)
        if action in ('CHANGE_LEFT','CHANGE_RIGHT','TURN_LEFT','TURN_RIGHT') and self.executed!='FORWARD':
            decision=dict(status='WAIT' if decision['status']=='WAIT' else 'BLOCK',reasons=decision['reasons']+['LATERAL_REQUEST_REQUIRES_FORWARD'],alarm=decision['alarm'])
        if decision['status']=='ALLOW_SIMULATED':
            if action=='CHANGE_LEFT':self.lane_index-=1
            elif action=='CHANGE_RIGHT':self.lane_index+=1
            elif action in ('FORWARD','REVERSE'):self.executed=action
            if action.startswith(('CHANGE_','TURN_')):self.intent=self.executed
        elif decision['status']=='STOP':self.executed='STOP'
        else:
            self.intent=self.executed='STOP';self.armed=False
        if requested is not None or decision['status'] in ('WAIT','BLOCK'):self.last_feedback=copy.deepcopy(decision)
        if event_status is not None:self.last_feedback=event_status
        camera=env.get('camera',{})
        return dict(mode=self.mode,scene=self.scene,lane_source=self.lane_source,virtual_lane_index=self.lane_index,
            virtual_lane=('LEFT','CENTER','RIGHT')[self.lane_index],intent=self.intent,executed=self.executed,
            simulated_view=self.view,neutral_armed=self.armed,decision=decision,last_feedback=copy.deepcopy(self.last_feedback),
            alarm=decision['alarm'] or fresh(camera,now) and camera.get('risk')=='HIGH',
            hardware_actuation=False)
