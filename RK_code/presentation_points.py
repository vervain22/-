from night_candidates import draw as draw_night_candidates
from native_canvas import base_canvas
from action_history import draw_panel as draw_action_history
from paint_points import draw as draw_paint_points

import bootstrap
import copy,math
from functools import lru_cache
import cv2,numpy as np
from PIL import Image,ImageDraw
from dashboard import FONTS,WORDS,REASONS
REASONS.update(MANEUVER_TYPE_MISMATCH='请重复同类同向动作确认，反向动作取消',TURN_EXECUTED_SIMULATION='模拟转向已执行')
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

@lru_cache(maxsize=202)
def camera_label_mask(label):
    font=FONTS[17]
    box=font.getbbox(label)
    mask=Image.new('L',(box[2]-box[0]+8,box[3]-box[1]+6),0)
    ImageDraw.Draw(mask).text((4-box[0],3-box[1]),label,font=font,fill=255)
    return np.asarray(mask).copy()

def draw_camera_label(out,row,x,y,color):
    
    person=row.get('class_id')==0 or row.get('label') in ('person','行人')
    score=float(row.get('score',0))
    percent=int(round(max(0,min(1,score if math.isfinite(score) else 0))*100))
    mask=camera_label_mask(('行人' if person else '车辆')+f' {percent}%')
    h,w=mask.shape
    x=max(640,min(1280-w,x));y=max(396,min(720-h,y-h))
    translucent_rectangle(out,(x,y),(x+w-1,y+h-1),color,-1)
    patch=out[y:y+h,x:x+w]
    alpha=mask[:,:,None].astype(np.uint16)
    patch[:]=((patch.astype(np.uint16)*(255-alpha)+255*alpha+127)//255).astype(np.uint8)

def fit_text(text,width,size=17):
    if FONTS[size].getlength(text)<=width:return text
    while text and FONTS[size].getlength(text+'…')>width:text=text[:-1]
    return text+'…'

@lru_cache(maxsize=32)
def hdmi_reminder_panel(messages):
    """底部提示逐行居中，白底黑色文字。"""
    width=608
    lines=tuple(fit_text(text,width-24) for text in messages)
    height=12+26*len(lines)
    im=Image.new('RGB',(width,height),'white');draw=ImageDraw.Draw(im)
    for index,text in enumerate(lines):
        box=draw.textbbox((0,0),text,font=FONTS[17])
        x=(width-(box[2]-box[0]))/2-box[0]
        y=6+index*26+(26-(box[3]-box[1]))/2-box[1]
        draw.text((x,y),text,font=FONTS[17],fill='black')
    return np.asarray(im)[:,:,::-1].copy()


def footer(out,result,state):
    
    request=state.get('lane_change')
    decision=state.get('decision',{})
    status=decision.get('status','STOP')
    color={'BLOCK':'#ff7777','WAIT':'#ffcb66','ALLOW_SIMULATED':'#77daac'}.get(status,'#a8bbcf')
    imu=result.get('imu') or {};phase=imu.get('phase','DISABLED')
    ready={'READY':'就绪','TILT_LOCKED':'请回正','TWIST_LOCKED':'请回拧',
        'NEUTRAL_REQUIRED':'归零中','HAND_CALIBRATING':'校准中',
        'WAIT_HAND_NEUTRAL':'待校准','LINK_TIMEOUT':'传感器超时',
        'LINK_ERROR':'传感器断开','FAULT':'动作异常','DISABLED':'未启用',
        'WAIT_ACK':'等待确认','WAIT_SENSOR':'等待传感器'}.get(phase,'请回正')
    intent=WORDS.get(state.get('intent'),'停止')
    if request:
        intent=('左' if request['side']=='left' else '右')+('转' if request.get('kind')=='TURN' else '变道')
    row1=WORDS[state['scene']]+'  |  车道：'+WORDS[state['virtual_lane']]+'  |  意图：'+intent
    execution='  |  执行：'+WORDS.get(state.get('executed'),'停止')
    execution_x=12+int(math.ceil(FONTS[17].getlength(row1)))
    camera=result.get('camera',{})
    targets=camera.get('detections',[]) if camera.get('valid') else []
    risk=('有人车' if targets else '无人车') if camera.get('valid') else '等待识别'
    if state['scene']=='LANE_CHANGE':
        memory=state.get('lane_boundary_memory',{})
        kinds=[{'DASHED':'虚线','SOLID':'实线','NONE':'无'}.get((memory.get(side) or {}).get('candidate_type'),'无') for side in ('left','right')]
        evidence=f'左线：{kinds[0]}   右线：{kinds[1]}   |   '+camera_view_label(state)+'：'+risk
    else:
        signal=result.get('hdmi_display_signal',{}).get('text',WORDS.get(result.get('hdmi',{}).get('state'),'未知'))
        night_rows=result.get('night_light_candidates',{}).get('rows',[])
        if state['scene']=='NIGHT' and night_rows:
            signal+=' · '+ '/'.join(dict.fromkeys({'RED':'红','YELLOW':'黄','GREEN':'绿'}[row['color']] for row in night_rows))+'候选(仅提醒)'
        evidence='灯色：'+signal+'   |   '+camera_view_label(state)+'：'+risk
    reasons=decision.get('reasons',[])
    feedback='；'.join(REASONS.get(r,WORDS.get(r,r)) for r in reasons[:2])
    if request:
        direction='左' if request['side']=='left' else '右'
        gate=request.get('gate',{})
        condition='可确认' if gate.get('status')=='ALLOW_SIMULATED' else '；'.join(REASONS.get(r,r) for r in gate.get('reasons',[])[:1])
        feedback=direction+('转' if request.get('kind')=='TURN' else '变道')+'申请 · '+condition
        color='#ff7777' if gate.get('status')=='BLOCK' else '#ffcb66'
    
    if phase=='HAND_CALIBRATING':
        feedback=f"保持水平静止 · 校准 {imu.get('calibration_progress_s',0):.1f}/2秒"
    elif phase in ('WAIT_HAND_NEUTRAL','FAULT','LINK_TIMEOUT','LINK_ERROR','DISABLED','WAIT_SENSOR'):
        feedback='请水平握持，按住UBOOT满2秒校准' if phase=='WAIT_HAND_NEUTRAL' else ready+'；请检查模块并重新校准'
    elif not feedback:feedback='UBOOT短按切换场景 · 按住2秒校准'
    mpu='MPU：'+ready
    evidence_x=12+int(math.ceil(FONTS[17].getlength(mpu)))
    
    
    
    text_width=640;map_width=300
    group_left=0
    
    right_group_left=640+(640-600)//2
    map_left=right_group_left+300
    out[720:816]=strip(1280,96,())
    out[720:816,group_left:group_left+text_width]=strip(text_width,96,(
        (12,4,row1,17,'#e6edf5'),
        (execution_x,4,execution,17,'#77daac' if state.get('executed')!='STOP' else '#a8bbcf'),
        (12,36,mpu,17,'#8ac8ff'),
        (evidence_x,36,fit_text('  |  '+evidence,text_width-16-evidence_x),17,'#e6edf5'),
        (12,68,fit_text(feedback,text_width-28),17,color)))
    
    out[720:816,right_group_left:right_group_left+300]=draw_action_history(tuple(tuple(row) for row in result.get('action_history',())))

    title='虚拟车道 · 模拟示意'
    title_x=int((300-FONTS[17].getlength(title))/2)
    panel=strip(300,96,((title_x,2,title,17,'#8ac8ff'),
        (38,29,'左',17,'#e6edf5'),(138,29,'中',17,'#e6edf5'),(238,29,'右',17,'#e6edf5'))).copy()
    for x in (100,200):cv2.line(panel,(x,29),(x,95),(100,100,100),2)
    cx=50+100*state['virtual_lane_index']
    cv2.rectangle(panel,(cx-14,58),(cx+14,91),(70,210,120) if state['executed']!='STOP' else (150,150,150),-1)
    dx,dy={0:(0,-20),90:(20,0),180:(0,20),270:(-20,0)}[state.get('heading_deg',0)]
    cv2.arrowedLine(panel,(cx,75),(cx+dx,75+dy),(0,0,255) if state['scene'] in ('INTERSECTION','NIGHT') else (255,255,255),3,cv2.LINE_AA,tipLength=.45)
    out[720:816,map_left:map_left+map_width]=panel


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
    hdmi,camera=images;out=base_canvas(hdmi,camera)
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
        draw_paint_points(out,a['observed_fragments'],color)
    for r in result['camera']['rendered_detections']:
        x1,y1,x2,y2=np.rint(r['box']).astype(int);color=(255,255,0) if r['mode']=='TRACK' else (0,180,255)
        translucent_rectangle(out,(640+x1,360+y1),(640+x2,360+y2),color,2)
        draw_camera_label(out,r,640+x1,360+max(38,y1-3),color)
    titles=[(0,0,'HDMI 原图'),(640,0,'HDMI 识别叠加'),(0,360,'摄像头 原图'),(640,360,'摄像头 识别叠加 · 模拟视角')]
    for x,y,title in titles:out[y:y+30,x:x+640]=strip(640,30,((8,3,title,17,'#e6edf5'),))
    if result.get('lane_model_display'):
        out[30:54,640:1280]=strip(640,24,((8,1,'模型分割：左虚青 / 左实红 / 右虚绿 / 右实紫；下方另列决策证据',15,'#e6edf5'),))
    draw_night_candidates(out,result.get('night_light_candidates',{}))
    from visual_alerts import border
    alerts=result.get('visual_alerts',{})
    if alerts.get('camera_border_on',alerts.get('camera_target')):border(out[360:720,640:1280])
    if alerts.get('hdmi_red_forward_intent') or alerts.get('hdmi_lane_rejection') or alerts.get('night_candidate_border_on'):border(out[:360,640:1280])
    lane_request=state.get('lane_change')
    if lane_request and lane_request['blink_on']:
        left=lane_request['side']=='left'
        start=(706,180) if left else (1214,180)
        end=(656,180) if left else (1264,180)
        cv2.arrowedLine(out,start,end,(0,190,255),10,tipLength=.5)
    
    out[400:436,656:750]=camera_view_badge(camera_view_label(state))
    reminders=result.get('adas_advisories',{}).get('messages',[])
    if reminders:
        panel=hdmi_reminder_panel(tuple(reminders))
        height,width=panel.shape[:2]
        left=640+(640-width)//2
        out[356-height:356,left:left+width]=panel
    footer(out,result,state)
    return out

def warmup():
    
    for label in ('左','右'):
        for kind in ('未知/过期','未知候选','虚线候选','实线候选','虚线持续预测','实线持续预测','虚线（保持）','实线（保持）','虚线候选（保持）','实线候选（保持）','虚线连续（保持）','实线连续（保持）'):
            strip(280,30,((0,6,label+'线型：'+kind,17,'#e6edf5'),))
