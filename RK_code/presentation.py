
import bootstrap
import copy,math
from functools import lru_cache
import cv2,numpy as np
from PIL import Image,ImageDraw
from dashboard import FONTS,WORDS,REASONS
from lane_record import build
from lane_timing import EVIDENCE_TTL,DISPLAY_TTL
from modes import LABELS
from overlay_style import rectangle as translucent_rectangle
from lane_display import consume as consume_lane_display,draw as draw_lane_display

@lru_cache(maxsize=16)
def strip(width,height,lines):

    im=Image.new('RGB',(width,height),'#172330');d=ImageDraw.Draw(im)
    for x,y,s,size,color in lines:d.text((x,y),s,font=FONTS[size],fill=color)
    return np.asarray(im)[:,:,::-1].copy()

@lru_cache(maxsize=4)
def camera_view_badge(text):
    im=Image.new('RGB',(94,36),'white');d=ImageDraw.Draw(im);font=FONTS[24]
    left,top,right,bottom=d.textbbox((0,0),text,font=font)
    x=(94-(right-left))//2-left;y=(36-(bottom-top))//2-top
    d.text((x,y),text,font=font,fill='black')
    return np.asarray(im)[:,:,::-1].copy()

def camera_view_label(state):
    request=state.get('lane_change')
    if request and request.get('side') in ('left','right'):
        return '左侧' if request['side']=='left' else '右侧'
    return '后方' if state.get('intent')=='REVERSE' else '前方'

def current(stamp,end,now,display_stamp,max_age=.5):
    return all(isinstance(v,(int,float)) and math.isfinite(v) for v in (stamp,end,now,display_stamp)) and 0<=now-stamp<=max_age and now<=end and stamp<=display_stamp and 0<=now-display_stamp<=.5

def assemble(packets,signal,lane,geometry,now,display_stamp):
    hp=packets.get('hdmi')
    hv=bool(hp and current(hp['source_timestamp'],hp['source_timestamp']+.5,now,display_stamp))
    objects=[]
    if hv:
        for row in hp.get('reference_objects',[]):
            box=row.get('box',[]);cls=row.get('class_id')
            if cls not in (0,1,2,3,4,5) or len(box)!=4:continue
            if not all(isinstance(v,(int,float)) and math.isfinite(v) for v in box):continue
            if not 0<=box[0]<box[2]<=640 or not 0<=box[1]<box[3]<=360:continue
            
            if cls not in (0,1) and not 160<=(box[0]+box[2])/2<=480:continue
            objects.append(copy.deepcopy(row))
    hdmi_objects=dict(valid=hv,detections=objects,backend='reference_localization_fpga_same_frame_color',
        source_timestamp=hp['source_timestamp'] if hp else 0,
        expires_at=hp['source_timestamp']+.5 if hp else 0,decision_permission=False)
    p=packets.get('camera');valid=bool(p and current(p['source_timestamp'],p['source_timestamp']+.5,now,display_stamp))
    camera=dict(valid=valid,detections=copy.deepcopy(p['detections']) if valid else [],
        observed_targets=copy.deepcopy(p['detections']) if p else [],
        source_timestamp=p['source_timestamp'] if p else 0,expires_at=p['source_timestamp']+.5 if p else 0,
        reason='ok' if valid else 'waiting_or_expired',rendered_detections=[])
    rendered=[]
    for r in geometry.get('rows',[]):
        
        
        if (current(r['geometry_timestamp'],r['geometry_expires_at'],now,display_stamp)
            and 0<=now-r['geometry_timestamp']<=.25 and 0<=now-r['detection_timestamp']<=.8
            and (not valid or r['detection_ns']==p['source_ns'])):rendered.append(copy.deepcopy(r))
    if valid and not p['detections']:rendered=[]
    if valid:
        for i,r in enumerate(p['detections']):
            if not any(t['detection_ns']==p['source_ns'] and t['detection_index']==i for t in rendered):
                rendered.append(dict(r,mode='DETECT',geometry_expires_at=p['source_timestamp']+.5,
                    detection_ns=p['source_ns'],detection_index=i))
    camera['rendered_detections']=rendered
    light=copy.deepcopy(signal)
    light_diagnostic=dict(state=signal.get('state'),valid=signal.get('valid'),reason=signal.get('reason'),
        source_timestamp=signal.get('source_timestamp'),track_count=len(signal.get('tracks',[])),
        max_hits=max((r.get('hits',0) for r in signal.get('tracks',[])),default=0))
    if not current(light.get('source_timestamp'),light.get('expires_at'),now,display_stamp):
        light.update(valid=False,state='UNKNOWN',reason='waiting_or_expired',tracks=[])
    elif not light.get('valid'):
        
        
        light['state']='UNKNOWN'
    lane_record=build(lane or {},now,source='HDMI')
    
    
    display_packet=packets.get('lane_display')
    model_display=consume_lane_display(display_packet,now,display_stamp)
    display_source=(dict(source_ns=display_packet['source_ns'],source_timestamp=display_packet['source_timestamp'],
        expires_at=display_packet['source_timestamp']+DISPLAY_TTL,
        published_timestamp=display_packet['published_timestamp']) if display_packet else None)
    if not current(lane_record.get('source_timestamp'),lane_record.get('valid_until'),now,display_stamp,max_age=EVIDENCE_TTL):
        lane_record.update(current=False,reason='WAITING_OR_EXPIRED',sides=[])
    return dict(published_at=now,capture_timestamp=display_stamp,camera=camera,hdmi=light,hdmi_objects=hdmi_objects,lane=lane_record,
        diagnostics=dict(light=light_diagnostic,lane_status=(lane or {}).get('evidence',{}).get('status'),
            lane_source_age=now-(lane or {}).get('source_timestamp',now)),
        lane_model_display=model_display,lane_model_display_source=display_source,
        diagnostic_only=True,vehicle_permission=False,distance_estimation=False,alarm=False)

def render(images,result,state,now):
    hdmi,camera=images;out=np.zeros((816,1280,3),np.uint8)
    if hdmi is not None:out[:360,:640]=hdmi;out[:360,640:]=hdmi
    if camera is not None:out[360:720,:640]=camera;out[360:720,640:]=camera
    draw_lane_display(out[:360,640:],result.get('lane_model_display',[]))
    
    
    reference_colors={0:(255,0,0),1:(255,0,255),2:(0,0,255),3:(0,255,0),4:(0,0,0),5:(0,255,255)}
    for r in result.get('hdmi_display_objects',result.get('hdmi_objects',{})).get('detections',[]):
        x1,y1,x2,y2=np.rint(r['box']).astype(int)
        color=reference_colors[r['class_id']]
        translucent_rectangle(out,(x1+640,y1),(x2+640,y2),color,2)
        label=f"{r['label']} {int(r['score']*100)}%"+(" HOLD" if r.get("visual_hold") else "")
        (w,h),_=cv2.getTextSize(label,cv2.FONT_HERSHEY_SIMPLEX,.5,1)
        y=max(h+5,y1)
        translucent_rectangle(out,(x1+640,y-h-5),(min(1279,x1+640+w),y),color,-1)
        cv2.putText(out,label,(x1+640,y-5),cv2.FONT_HERSHEY_SIMPLEX,.5,(255,255,255),1)
    for a in result['lane']['sides']:
        color=(0,220,0) if a['candidate_type']=='DASHED' else (0,70,255)
        for fragment in a['observed_fragments']:
            for x,y in fragment:cv2.circle(out,(int(x)+640,int(y)),1,color,-1)
    for r in result['camera']['rendered_detections']:
        x1,y1,x2,y2=np.rint(r['box']).astype(int);color=(255,255,0) if r['mode']=='TRACK' else (0,180,255)
        translucent_rectangle(out,(640+x1,360+y1),(640+x2,360+y2),color,2)
        label=f"{r['label']} {r['mode']} {r['score']:.2f}"
        (w,h),_=cv2.getTextSize(label,cv2.FONT_HERSHEY_SIMPLEX,.4,1)
        y=360+max(38,y1-3)
        translucent_rectangle(out,(640+x1,y-h-3),(min(1279,640+x1+w),y+2),color,-1)
        cv2.putText(out,label,(640+x1,y),cv2.FONT_HERSHEY_SIMPLEX,.4,(255,255,255),1)
    titles=[(0,0,'HDMI 原图'),(640,0,'HDMI 识别叠加'),(0,360,'摄像头 原图'),(640,360,'摄像头 识别叠加 · 模拟视角')]
    for x,y,title in titles:out[y:y+30,x:x+640]=strip(640,30,((8,3,title,17,'#e6edf5'),))
    if result.get('lane_model_display'):
        out[30:54,640:1280]=strip(640,24,((8,1,'模型分割：左虚青 / 左实红 / 右虚绿 / 右实紫；下方另列决策证据',15,'#e6edf5'),))
    from visual_alerts import border
    alerts=result.get('visual_alerts',{})
    if alerts.get('camera_border_on',alerts.get('camera_target')):border(out[360:720,640:1280])
    if alerts.get('hdmi_red_forward_intent') or alerts.get('hdmi_lane_rejection'):border(out[:360,640:1280])
    lane_request=state.get('lane_change')
    if lane_request and lane_request['blink_on']:
        left=lane_request['side']=='left'
        start=(706,180) if left else (1214,180)
        end=(656,180) if left else (1264,180)
        cv2.arrowedLine(out,start,end,(0,190,255),10,tipLength=.5)
    
    out[400:436,656:750]=camera_view_badge(camera_view_label(state))
    source_ok=current(result.get('capture_timestamp'),(result.get('capture_timestamp') or 0)+.5,now,result.get('capture_timestamp'))
    
    
    out[720:750]=strip(1280,30,((10,6,('源图新鲜' if source_ok else '源图缺失/过期')+' | 灯色：'+result.get('hdmi_display_signal',{}).get('text',WORDS.get(result['hdmi']['state'],'未知')),17,'#e6edf5'),))
    
    for side,label,x in [('left','左',440),('right','右',730)]:
        row=state.get('lane_boundary_memory',{}).get(side)
        kind={'DASHED':'虚线','SOLID':'实线','NONE':'无'}.get((row or {}).get('candidate_type'),'无')
        out[720:750,x:x+280]=strip(280,30,((0,6,label+'线型：'+kind,17,'#e6edf5'),))
    key_hint='键盘调试' if result.get('board_key')=='keyboard_only' else 'UBOOT场景键'
    imu=result.get('imu')
    intent=WORDS.get(state.get('intent'),'停止')
    lines=[(10,1,'实时模拟 | '+WORDS[state['scene']]+' | 虚拟车道：'+WORDS[state['virtual_lane']]+' | 驾驶意图：'+intent+(' | 直行执行：' if state['scene']=='LANE_CHANGE' else ' | 决策执行：')+WORDS[state['executed']]+' | '+('变道反馈：' if state.get('lane_change') or state.get('lane_change_feedback') else '')+WORDS.get(state['decision']['status'],state['decision']['status']),17,'#e6edf5')]
    phase=(imu or {}).get('phase','DISABLED')
    label={'HAND_CALIBRATING':'水平静置校准中','WAIT_HAND_NEUTRAL':'保持水平，按住UBOOT满2秒开始校准',
           'NEUTRAL_REQUIRED':'保持水平，正在归零','READY':'已回正，可操作','TILT_LOCKED':'请回水平后再操作',
           'TWIST_LOCKED':'请拧回原方向并保持水平','FAULT':'动作异常，停车后长按归零',
           'LINK_TIMEOUT':'传感器超时，已停车，需重新归零','LINK_ERROR':'传感器断开，已停车',
           'WAIT_ACK':'等待归零/切换确认','WAIT_SENSOR':'等待传感器','DISABLED':'MPU未启用'}.get(phase,phase)
    offset=''
    if phase=='HAND_CALIBRATING':
        reason={'KEEP_STILL':'请保持稳定','KEEP_LEVEL':'请元件面向上并保持水平',
                'MOTION_OR_ACCELERATION':'请停止晃动','EXCESS_VARIATION':'波动偏大，请支撑手腕'}.get(imu.get('calibration_reason'),'请保持稳定')
        offset=f" {imu.get('calibration_progress_s',0):.1f}/3秒 {reason}"
    if imu and imu.get('roll_error_deg') is not None:
        offset=f" | 左右偏角{imu['roll_error_deg']:+.1f}° 前后偏角{imu['pitch_error_deg']:+.1f}°"
    lines.append((10,23,'MPU：'+label+offset+' | UBOOT短按切场景/按住2秒校准',15,'#8ac8ff'))
    reasons=state['last_feedback'].get('reasons',[])
    recent=(imu or {}).get('last_gesture')
    if recent:
        gesture_names={'LANE_RIGHT':'右变道','LANE_LEFT':'左变道','TURN_RIGHT':'右转','TURN_LEFT':'左转',
                       'FORWARD':'前进','REVERSE':'后退','STOP':'停车'}
        name=recent['name']
        if name.startswith('REJECT_'):name='请求被拒绝：'+gesture_names.get(name[7:],name[7:])
        else:name=gesture_names.get(name,name)
        feedback='最近手势：'+name+f"（{recent['age_s']:.0f}秒前）"+' | '+WORDS.get(state['decision']['status'],state['decision']['status'])+'：'+('；'.join(REASONS.get(r,r) for r in state['decision']['reasons'][:2]))
    else:feedback='提示：'+('；'.join(REASONS.get(r,r) for r in reasons)[:76] or '仅显示识别结果')
    gate=state.get('current_gate')
    if gate:
        pending=state.get('pending_request')
        prefix=(f"请求等待证据（剩余{pending['remaining_s']:.1f}秒）" if pending else
                '已停车，请回正后重新前倾' if 'NEW_REQUEST_REQUIRED' in state['decision']['reasons'] else
                '上次请求：'+WORDS.get(state['last_feedback']['status'],state['last_feedback']['status']))
        condition=('条件具备，需新手势' if gate['status']=='ALLOW_SIMULATED' and state['executed']=='STOP' and not pending else
                   '条件具备' if gate['status']=='ALLOW_SIMULATED' else
                   '；'.join(REASONS.get(r,r) for r in gate['reasons'][:2]))
        feedback=prefix+' | 当前：'+condition
    if lane_request:
        direction='左' if lane_request['side']=='left' else '右'
        gate=lane_request['gate']
        condition=('证据具备' if gate['status']=='ALLOW_SIMULATED' else
            '；'.join(REASONS.get(r,r) for r in gate['reasons'][:2]))
        feedback=direction+'变道申请 | '+condition+' | 回正后同向确认、反向取消'
    elif state.get('lane_change_feedback'):
        feedback='；'.join(REASONS.get(r,r) for r in state['lane_change_feedback']['reasons'][:2])
    lines.append((10,45,feedback+' [R校准 ESC退出]',15,'#ffcb66'))
    out[750:]=strip(1280,66,tuple(lines))
    
    panel=strip(290,66,((8,0,'虚拟三车道 · 仅模拟',15,'#8ac8ff'),
        (20,20,'左',15,'#e6edf5'),(110,20,'中',15,'#e6edf5'),(200,20,'右',15,'#e6edf5'))).copy()
    for x in (90,180):cv2.line(panel,(x,22),(x,65),(100,100,100),1)
    cx=28+90*state['virtual_lane_index']
    cv2.rectangle(panel,(cx-9,42),(cx+9,62),(70,210,120) if state['executed']!='STOP' else (150,150,150),-1)
    heading=state.get('heading_deg',0);dx,dy={0:(0,-12),90:(12,0),180:(0,12),270:(-12,0)}[heading]
    cv2.arrowedLine(panel,(cx,52),(cx+dx,52+dy),(255,255,255),1,tipLength=.4)
    out[750:816,990:1280]=panel
    return out

def warmup():
    
    for label in ('左','右'):
        for kind in ('未知/过期','未知候选','虚线候选','实线候选','虚线持续预测','实线持续预测','虚线（保持）','实线（保持）','虚线候选（保持）','实线候选（保持）','虚线连续（保持）','实线连续（保持）'):
            strip(280,30,((0,6,label+'线型：'+kind,17,'#e6edf5'),))
