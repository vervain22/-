
import bootstrap
import copy,math
from persistent_lane_state import LaneState as LaneMemory
from lane_timing import EVIDENCE_TTL

ACTIVE=('READY','TILT_LOCKED','TWIST_LOCKED')
LATERAL={'LANE_LEFT':-1,'LANE_RIGHT':1,'TURN_LEFT':-1,'TURN_RIGHT':1}
CAMERA_GRACE=.3
CAMERA_HARD_AGE=.8
INTERSECTION_CAMERA_HARD_AGE=1.2
REQUEST_WAIT=3.
CAMERA_RECOVERY_LIMIT=3.


def fresh(row,now,end_key,max_age=.5):
    stamp=row.get('source_timestamp');end=row.get(end_key)
    return (isinstance(stamp,(int,float)) and isinstance(end,(int,float))
            and math.isfinite(stamp) and math.isfinite(end) and 0<=now-stamp<=max_age
            and now<=end)


def decision_light(result,now):

    light=result.get('hdmi',{})
    if light.get('valid') is True and fresh(light,now,'expires_at'):
        return light
    capture=result.get('capture_timestamp')
    display=result.get('hdmi_display_signal',{})
    packet=result.get('hdmi_display_objects',{})
    if (result.get('scene') not in ('INTERSECTION','NIGHT') or result.get('enabled',{}).get('signal') is False
            or not isinstance(capture,(int,float)) or not math.isfinite(capture)
            or not 0<=now-capture<=.5 or display.get('conflict')):
        return light
    states=display.get('states',[])
    cls=2 if states==['红'] else 5 if states==['黄'] else None
    limit=packet.get('hold_seconds',0)
    if cls is None or not isinstance(limit,(int,float)) or not 0<limit<=.8:return light
    stamps=[r.get('last_detected_at') for r in packet.get('detections',[])
            if r.get('class_id')==cls]
    stamps=[t for t in stamps if isinstance(t,(int,float)) and math.isfinite(t)
            and t<=capture and 0<=now-t<=limit]
    if not stamps:return light
    stamp=max(stamps)
    return dict(valid=True,state='RED' if cls==2 else 'YELLOW',source_timestamp=stamp,
                expires_at=stamp+limit,decision_max_age=limit,reason='BOUNDED_DISPLAY_COLOR_HOLD')


def current_light(light,now):
    return light.get('valid') is True and fresh(light,now,'expires_at',light.get('decision_max_age',.5))


def policy(action,result,scene,lane_index,now,demo_lane_mapping=False,lane_memory=None,camera_role='FRONT'):

    if action=='STOP':return dict(status='STOP',reasons=['EXPLICIT_STOP'],alarm=False)
    blocks=[];waits=[]
    camera=result.get('camera',{})
    if scene in ('LANE_CHANGE','INTERSECTION','NIGHT') and action=='FORWARD' and camera_role=='SIDE_REAR':
        pass 
    elif camera.get('valid') is not True or not isinstance(camera.get('detections'),list) or not fresh(camera,now,'expires_at'):
        waits.append('CAMERA_MISSING_OR_EXPIRED')
    else:
        
        if any(d.get('label') in ('person','car','bus','truck','motorcycle','bicycle') for d in camera.get('detections',[])):
            blocks.append('CAMERA_TARGET_PRESENT')
    if scene in ('INTERSECTION','NIGHT') and action!='REVERSE':
        light=decision_light(result,now)
        
        if current_light(light,now) and light.get('state') in ('RED','YELLOW'):
            blocks.append('SIGNAL_'+light['state'])
    if action.startswith('LANE_'):
        if scene not in ('LANE_CHANGE','INTERSECTION','NIGHT'):blocks.append('LANE_REQUEST_WRONG_SCENE')
        side='left' if action=='LANE_LEFT' else 'right'
        if not 0<=lane_index+LATERAL[action]<=2:blocks.append('VIRTUAL_ROAD_EDGE')
        if scene in ('INTERSECTION','NIGHT'):
            return dict(status='BLOCK' if blocks else 'WAIT' if waits else 'ALLOW_SIMULATED',
                        reasons=blocks+waits or ['MODEL_BASED_SIMULATION_ONLY'],alarm=bool(blocks))
        lane=result.get('lane',{})
        boundary=next((s for s in lane.get('sides',[]) if s.get('image_side')==side),{})
        no_line=(demo_lane_mapping and lane.get('source')=='HDMI' and lane.get('current') is True
            and fresh(lane,now,'valid_until',max_age=EVIDENCE_TTL)
            and boundary.get('line_presence')=='NOT_DETECTED' and boundary.get('candidate_type')=='UNKNOWN')
        remembered=lane_memory.get(side,now) if lane_memory is not None and demo_lane_mapping else None
        if lane_memory is not None and getattr(lane_memory,'authoritative',False) and demo_lane_mapping:
            if remembered is None:waits.append('LANE_STATE_NOT_OBSERVED')
            elif remembered['candidate_type']=='SOLID':blocks.append('SOLID_MODEL_CANDIDATE')
        elif no_line:
            pass 
        elif remembered is not None:
            if remembered['candidate_type']=='SOLID':blocks.append('SOLID_MODEL_CANDIDATE')
            
        elif (lane.get('current') is not True or not fresh(lane,now,'valid_until',max_age=EVIDENCE_TTL)
                or demo_lane_mapping and lane.get('source')!='HDMI'):
            waits.append('LANE_SOURCE_MISSING_OR_EXPIRED')
        else:
            boundary=next((s for s in lane.get('sides',[]) if s.get('image_side')==side),{})
            if boundary.get('candidate_type')=='SOLID':blocks.append('SOLID_MODEL_CANDIDATE')
            elif boundary.get('candidate_type')!='DASHED' or boundary.get('temporal_type')!='DASHED':waits.append('LANE_TYPE_NOT_STABLE')
            
            if boundary.get('confirmed') is not True and not demo_lane_mapping:waits.append('EGO_BOUNDARY_NOT_QUALIFIED')
    return dict(status='BLOCK' if blocks else 'WAIT' if waits else 'ALLOW_SIMULATED',
                reasons=blocks+waits or ['MODEL_BASED_SIMULATION_ONLY'],alarm=bool(blocks))


class VirtualDrive:
    def __init__(self):
        self.generation=None;self.watermark=-float('inf');self.last_now=None
        self.reset()

    def reset(self):
        self.motion='STOP';self.lane=1;self.heading=0;self.last_request=None
        self.lane_memory=LaneMemory()
        self.signal_prohibition=None
        self.signal_resume_intent=None
        self.empty_camera=None
        self.pending=None
        self.lane_request=None
        self.lane_feedback=None
        self.lane_rejection_alert=None
        self.camera_recovery=None
        self.feedback=dict(status='STOP',reasons=['INITIAL_STOP'],alarm=False)

    def movement_policy(self,action,result,now):
        
        
        decision=policy(action,result,result['scene'],self.lane,now,
                        demo_lane_mapping=result['scene']=='LANE_CHANGE',lane_memory=self.lane_memory,
                        camera_role='SIDE_REAR' if self.lane_request else 'FRONT')
        return decision

    def lane_gesture(self,action,result,now,intent):
        if result['scene'] not in ('LANE_CHANGE','INTERSECTION','NIGHT') or (action.startswith('TURN_') and result['scene'] not in ('INTERSECTION','NIGHT')):
            self.lane_feedback=dict(status='BLOCK',reasons=['LANE_REQUEST_WRONG_SCENE'],alarm=False)
            return
        if self.lane_request:
            if not self.lane_request['neutral_seen']:
                self.lane_feedback=dict(status='WAIT',reasons=['RETURN_TO_NEUTRAL_REQUIRED'],alarm=False)
                return
            if LATERAL[self.lane_request['action']]!=LATERAL[action]:
                self.lane_request=None
                self.lane_feedback=dict(status='STOP',reasons=['LANE_REQUEST_CANCELLED'],alarm=False)
                return
            if self.lane_request['action']!=action:
                self.lane_feedback=dict(status='WAIT',reasons=['MANEUVER_TYPE_MISMATCH'],alarm=False)
                return
            gate=self.movement_policy(action,result,now)
            self.lane_request['neutral_seen']=False
            if intent!='FORWARD':
                gate=dict(status='WAIT',reasons=['LATERAL_REQUEST_REQUIRES_FORWARD']+gate['reasons'],alarm=gate['alarm'])
            self.lane_feedback=gate
            reasons=set(gate['reasons'])
            if gate['status']=='BLOCK' and reasons & {'SOLID_MODEL_CANDIDATE','CAMERA_TARGET_PRESENT','SIGNAL_RED','SIGNAL_YELLOW'}:
                self.lane_rejection_alert=dict(started_at=now,expires_at=now+2.1,cycles=3,period_s=.7,
                    targets=['hdmi'],
                    reasons=gate['reasons'][:])
            if gate['status']=='ALLOW_SIMULATED':
                
                
                self.motion='FORWARD'
                self.camera_recovery=None
                if action.startswith('TURN_'):self.heading=(self.heading+90*LATERAL[action])%360
                else:self.lane+=LATERAL[action]
                remembered_through=self.lane_memory.watermark
                self.lane_memory.clear()
                self.lane_memory.watermark=remembered_through
                self.lane_request=None
                self.lane_feedback=dict(status='ALLOW_SIMULATED',reasons=['TURN_EXECUTED_SIMULATION' if action.startswith('TURN_') else 'LANE_CHANGE_EXECUTED_SIMULATION'],alarm=False)
        elif intent!='FORWARD':
            self.lane_feedback=dict(status='WAIT',reasons=['LATERAL_REQUEST_REQUIRES_FORWARD'],alarm=False)
        else:
            self.lane_request=dict(action=action,requested_at=now,neutral_seen=False)
            self.lane_feedback=dict(status='WAIT',reasons=['LANE_REQUEST_AWAIT_CONFIRMATION'],alarm=False)

    def remember_signal_stop(self,action,decision):
        reasons=decision['reasons']
        if (action=='FORWARD' and any(r in ('SIGNAL_RED','SIGNAL_YELLOW') for r in reasons)
                and all(r.startswith('SIGNAL_') or r=='CAMERA_MISSING_OR_EXPIRED' for r in reasons)):
            self.signal_resume_intent=action

    def ongoing_policy(self,result,now):
        decision=self.movement_policy(self.motion,result,now)
        
        
        if decision['reasons']!=['CAMERA_MISSING_OR_EXPIRED']:return decision
        c=result.get('camera',{});old=self.empty_camera;capture=result.get('capture_timestamp')
        intersection=result['scene'] in ('INTERSECTION','NIGHT')
        same_or_newer=(isinstance(c.get('source_timestamp'),(int,float)) and old
                       and c['source_timestamp']>=old['source_timestamp'])
        compatible=(same_or_newer and not c.get('observed_targets')) if intersection else (
            old and c.get('source_timestamp')==old['source_timestamp'] and c.get('expires_at')==old['expires_at'])
        if (old and c.get('valid') is False and c.get('reason')=='waiting_or_expired'
                and compatible and c.get('detections')==[]
                and isinstance(capture,(int,float)) and math.isfinite(capture)
                and 0<=now-capture<=.5 and old['source_timestamp']<=capture
                and 0<=now-old['source_timestamp']<=(INTERSECTION_CAMERA_HARD_AGE if intersection else CAMERA_HARD_AGE)
                and now<=old['expires_at']+(.7 if intersection else CAMERA_GRACE)):
            return dict(status='ALLOW_SIMULATED',reasons=['CAMERA_UPDATE_GRACE','MODEL_BASED_SIMULATION_ONLY'],alarm=False)
        return decision

    def update(self,result,imu,now):
        if not isinstance(now,(int,float)) or not math.isfinite(now):raise ValueError('finite clock required')
        generation=(result['scene'],result['mode_epoch'],(imu or {}).get('epoch'))
        rollback=self.last_now is not None and now<self.last_now
        if generation!=self.generation:
            self.reset();self.watermark=-float('inf');self.generation=generation
        elif rollback:self.reset()
        self.last_now=now
        light=decision_light(result,now)
        self.signal_prohibition=None
        if result['scene'] in ('INTERSECTION','NIGHT') and current_light(light,now):
            if light.get('state') in ('RED','YELLOW'):self.signal_prohibition=light['state']
            elif light.get('state')=='GREEN':self.signal_prohibition=None
        c=result.get('camera',{})
        if c.get('valid') is True and fresh(c,now,'expires_at') and isinstance(c.get('detections'),list):
            self.empty_camera=copy.deepcopy(c) if not c['detections'] else None
        elif self.empty_camera and not (result['scene'] in ('INTERSECTION','NIGHT')
                and c.get('reason')=='waiting_or_expired' and not c.get('observed_targets')
                and c.get('detections')==[] and isinstance(c.get('source_timestamp'),(int,float))
                and c['source_timestamp']>=self.empty_camera['source_timestamp']) and (c.get('source_timestamp')!=self.empty_camera['source_timestamp']
                or c.get('reason')!='waiting_or_expired' or c.get('detections')!=[]):
            self.empty_camera=None
        healthy=bool(imu and imu.get('connected') and imu.get('phase') in ACTIVE)
        
        
        
        
        memory_blocked=bool(imu and (not imu.get('connected') or imu.get('phase') in
            ('HAND_CALIBRATING','NEUTRAL_REQUIRED','FAULT','LINK_TIMEOUT','LINK_ERROR','WAIT_ACK')))
        if memory_blocked:self.lane_memory.clear()
        else:self.lane_memory.observe(result,now)
        request=(imu or {}).get('request')
        if not healthy:
            self.camera_recovery=None
            self.last_request=None
            self.signal_resume_intent=None
            self.pending=None
            self.motion='STOP';self.feedback=dict(status='STOP',reasons=['INPUT_NOT_READY'],alarm=False)
        else:
            if self.lane_request and imu.get('phase')=='READY' and imu.get('rearm_ready') is True:
                self.lane_request['neutral_seen']=True
            
            if imu.get('requested_motion')=='STOP':
                self.camera_recovery=None
                self.lane_request=None;self.lane_feedback=None
                self.signal_resume_intent=None
                self.motion='STOP'
                if self.pending:
                    self.pending=None;self.feedback=dict(status='STOP',reasons=['EXPLICIT_STOP'],alarm=False)
            if request and not rollback:
                stamp=request.get('stamp');age=request.get('age_s')
                valid=(request.get('epoch')==imu.get('epoch') and isinstance(stamp,(int,float))
                       and math.isfinite(stamp) and isinstance(age,(int,float))
                       and math.isfinite(age) and 0<=age<=.5)
                if valid and stamp>self.watermark:
                    self.watermark=stamp
                    self.pending=None
                    action=request['name'];self.last_request=action;self.signal_resume_intent=None
                    if action in LATERAL:
                        self.lane_gesture(action,result,now,imu.get('requested_motion'))
                    elif action in ('FORWARD','REVERSE','STOP') or action in LATERAL:
                        self.camera_recovery=None
                        if action!='FORWARD':self.lane_request=None
                        self.lane_feedback=None
                        decision=self.movement_policy(action,result,now)
                        if action in LATERAL and self.motion!='FORWARD':
                            decision=dict(status='BLOCK',reasons=['LATERAL_REQUEST_REQUIRES_FORWARD']+decision['reasons'],alarm=True)
                        self.feedback=decision
                        self.remember_signal_stop(action,decision)
                        if decision['status']=='WAIT' and action in ('FORWARD','REVERSE'):
                            self.pending=dict(action=action,expires_at=now+REQUEST_WAIT-age,stamp=stamp)
                        if decision['status']=='ALLOW_SIMULATED':
                            if action.startswith('LANE_'):self.lane+=LATERAL[action]
                            elif action.startswith('TURN_'):self.heading=(self.heading+90*LATERAL[action])%360
                            else:self.motion=action
                        else:self.motion='STOP'
                    else:
                        self.camera_recovery=None
                        self.motion='STOP';self.feedback=dict(status='BLOCK',reasons=['GESTURE_REJECTED'],alarm=True)
            if self.pending:
                pending=self.pending
                if now>pending['expires_at'] or imu.get('requested_motion')!=pending['action']:
                    self.pending=None
                    self.feedback=dict(status='WAIT',reasons=['REQUEST_EVIDENCE_TIMEOUT'],alarm=False)
                else:
                    
                    decision=self.movement_policy(pending['action'],result,now)
                    self.feedback=decision
                    if decision['status']=='ALLOW_SIMULATED':
                        self.motion=pending['action'];self.pending=None
                    elif decision['status']=='BLOCK':
                        self.remember_signal_stop(pending['action'],decision);self.pending=None
            
            
            if self.motion!='STOP':
                ongoing=self.ongoing_policy(result,now)
                self.feedback=ongoing
                if ongoing['status']!='ALLOW_SIMULATED':
                    capture=result.get('capture_timestamp')
                    if (result['scene'] in ('LANE_CHANGE','INTERSECTION','NIGHT') and self.motion=='FORWARD'
                            and ongoing['reasons']==['CAMERA_MISSING_OR_EXPIRED']
                            and c.get('reason')=='waiting_or_expired'
                            and not c.get('observed_targets')
                            and isinstance(capture,(int,float)) and math.isfinite(capture)
                            and 0<=now-capture<=.5
                            and isinstance(c.get('source_timestamp'),(int,float))
                            and math.isfinite(c['source_timestamp'])):
                        self.camera_recovery=dict(expires_at=now+CAMERA_RECOVERY_LIMIT,
                            previous_source_timestamp=c['source_timestamp'])
                    else:self.camera_recovery=None
                    self.remember_signal_stop(self.motion,ongoing);self.motion='STOP'
            if self.camera_recovery:
                recovery=self.camera_recovery
                if (result['scene'] not in ('LANE_CHANGE','INTERSECTION','NIGHT') or imu.get('requested_motion')!='FORWARD'
                        or c.get('observed_targets')
                        or now>recovery['expires_at']):
                    self.camera_recovery=None
                else:
                    decision=self.movement_policy('FORWARD',result,now)
                    if decision['status']=='BLOCK':
                        
                        self.camera_recovery=None;self.feedback=decision
                    elif decision['status']=='ALLOW_SIMULATED':
                        capture=result.get('capture_timestamp')
                        if (c['source_timestamp']>recovery['previous_source_timestamp']
                                and isinstance(capture,(int,float)) and math.isfinite(capture)
                                and 0<=now-capture<=.5 and c['source_timestamp']<=capture):
                            self.motion='FORWARD';self.camera_recovery=None
                            self.feedback=dict(status='ALLOW_SIMULATED',
                                reasons=['CAMERA_FRESH_EVIDENCE_RECOVERED'],alarm=False)
            
            
            if self.signal_resume_intent:
                action=self.signal_resume_intent
                if rollback or imu.get('requested_motion')!=action:
                    self.signal_resume_intent=None
                else:
                    decision=self.movement_policy(action,result,now)
                    if 'CAMERA_TARGET_PRESENT' in decision['reasons']:
                        self.signal_resume_intent=None;self.feedback=decision
                    elif result['scene'] in ('INTERSECTION','NIGHT') and not (current_light(light,now) and light.get('state') in ('RED','YELLOW','GREEN')):
                        self.feedback=decision
                        if decision['status']=='ALLOW_SIMULATED':
                            self.motion=action;self.signal_resume_intent=None
        risk=policy('FORWARD',result,'CAMERA_RISK',self.lane,now)
        gate=self.movement_policy((imu or {}).get('requested_motion','STOP'),result,now)
        shown=copy.deepcopy(self.feedback)
        if (healthy and self.motion=='STOP' and self.pending is None and self.feedback['status'] in ('WAIT','BLOCK')
                and (imu or {}).get('requested_motion') in ('FORWARD','REVERSE')
                and (self.last_request in ('FORWARD','REVERSE') or
                     (self.lane_request is None and self.last_request in LATERAL))):
            
            shown=(dict(status='STOP',reasons=['NEW_REQUEST_REQUIRED'],alarm=False)
                   if gate['status']=='ALLOW_SIMULATED' else copy.deepcopy(gate))
        diagnostics=dict(scene=result['scene'],mode_epoch=result['mode_epoch'],imu_epoch=(imu or {}).get('epoch'),
            healthy=healthy,request=copy.deepcopy(request),request_watermark=self.watermark if math.isfinite(self.watermark) else None,
            signal_state=result.get('hdmi',{}).get('state'),signal_valid=result.get('hdmi',{}).get('valid'),
            signal_timestamp=result.get('hdmi',{}).get('source_timestamp'),signal_reason=result.get('hdmi',{}).get('reason'),
            camera_valid=c.get('valid'),current_gate=copy.deepcopy(gate),stop_history=copy.deepcopy(self.feedback),
            new_request_required=shown['reasons']==['NEW_REQUEST_REQUIRED'],signal_prohibition=self.signal_prohibition,signal_resume_intent=self.signal_resume_intent)
        if not healthy:
            self.lane_request=None;self.lane_feedback=None
        if not self.lane_request:self.lane_rejection_alert=None
        lane_change=None
        if self.lane_request:
            a=self.lane_request['action'];side='left' if LATERAL[a]<0 else 'right'
            lane_change=dict(phase='REQUESTED',side=side,action=a,kind='TURN' if a.startswith('TURN_') else 'LANE',
                neutral_seen=self.lane_request['neutral_seen'],
                blink_on=int(max(0,now-self.lane_request['requested_at'])*2)%2==0,
                gate=self.movement_policy(a,result,now),
                mapping='DEMO_IMAGE_SIDE_TO_VIRTUAL_BOUNDARY',physical_view_is_simulated=True)
        
        
        
        if (self.lane_feedback and healthy and shown['status'] not in ('BLOCK','WAIT')
                and 'NEW_REQUEST_REQUIRED' not in shown['reasons']):
            shown=copy.deepcopy(self.lane_feedback)
        if lane_change:
            g=lane_change['gate']
            shown=dict(status='BLOCK' if g['status']=='BLOCK' else 'WAIT',
                reasons=['LANE_REQUEST_AWAIT_CONFIRMATION']+g['reasons'],alarm=g['alarm'])
        return dict(mode='LIVE_SIMULATION',scene=result['scene'],lane_source='HDMI',decision_diagnostics=diagnostics,
            camera_role='SIDE_REAR' if lane_change else 'FRONT',
            lane_change=lane_change,lane_change_feedback=copy.deepcopy(self.lane_feedback),
            lane_rejection_alert=copy.deepcopy(self.lane_rejection_alert),
            lane_boundary_memory=self.lane_memory.snapshot(now),
            camera_recovery=(dict(remaining_s=max(0,self.camera_recovery['expires_at']-now)) if self.camera_recovery else None),
            virtual_lane_index=self.lane,virtual_lane=('LEFT','CENTER','RIGHT')[self.lane],
            intent=(imu or {}).get('requested_motion','STOP'),executed=self.motion,
            simulated_view=(('LEFT_REAR' if lane_change['side']=='left' else 'RIGHT_REAR') if lane_change else (imu or {}).get('simulated_view','FRONT')),neutral_armed=healthy,
            heading_deg=self.heading,last_request=self.last_request,
            decision=shown,last_feedback=copy.deepcopy(self.feedback),current_gate=gate,
            pending_request=(dict(action=self.pending['action'],remaining_s=max(0,self.pending['expires_at']-now)) if self.pending else None),
            camera_update_grace='CAMERA_UPDATE_GRACE' in self.feedback['reasons'],
            alarm=self.feedback['alarm'] or risk['alarm'] or bool(self.lane_feedback and self.lane_feedback['alarm']),hardware_actuation=False,
            simulation_only=True,lane_execution_qualified=False)


def attach_simulation(result,drive,imu,now):
    result['imu']=copy.deepcopy(imu);result['imu_connected']=bool(imu and imu.get('connected'))
    state=drive.update(result,imu,now)
    result.update(vehicle_permission=False,diagnostic_only=True,simulation_only=True,alarm=state['alarm'])
    return state
