
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
from decision import fresh
FONT_PATHS=['C:/Windows/Fonts/msyh.ttc','/usr/share/fonts/truetype/wqy/wqy-microhei.ttc','/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc','/usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf']
FONT=next((p for p in FONT_PATHS if Path(p).exists()),None)
def font(size):return ImageFont.truetype(FONT,size) if FONT else ImageFont.load_default()
FONTS={s:font(s) for s in (15,17,20,24,28)}
WORDS={'NIGHT':'夜间模式','STOP':'停止','FORWARD':'前进','REVERSE':'后退','LEFT':'左','RIGHT':'右','CENTER':'中',
 'FRONT':'前方','REAR':'后方','LEFT_REAR':'左后方','RIGHT_REAR':'右后方',
 'GREEN':'绿','RED':'红','YELLOW':'黄','UNKNOWN':'未知','DASHED':'虚线','SOLID':'实线','CLEAR':'测试无冲突','HIGH':'高风险',
 'ALLOW_SIMULATED':'允许模拟执行','WAIT':'等待证据','BLOCK':'拦截','INTERSECTION':'路口场景','LANE_CHANGE':'变道场景','CAMERA_RISK':'摄像头风险场景',
 'SCRIPTED':'测试数据 · 仅验证逻辑','REPLAY':'历史结果回放 · 不执行','MONITOR':'当前观察 · 不执行'}
REASONS={'NEW_REQUEST_REQUIRED':'条件已恢复，请重新给出驾驶手势','REQUEST_EVIDENCE_TIMEOUT':'本次请求等待超时，请重新给出手势','INITIAL_STOP':'默认停止；先回中使能','RETURN_TO_NEUTRAL_REQUIRED':'需要回中后再次操作',
 'CAMERA_MISSING_OR_EXPIRED':'摄像头识别缺失或过期','CAMERA_RISK_UNASSESSED':'目标风险尚未评估',
 'CAMERA_HIGH_RISK':'摄像头高风险拦截','SIGNAL_RED':'红灯拦截','SIGNAL_YELLOW':'黄灯不新放行',
 'SIGNAL_MISSING_OR_EXPIRED':'灯色结果缺失或过期','SIGNAL_UNKNOWN_OR_UNQUALIFIED':'灯色未知或未验收',
 'VIRTUAL_ROAD_EDGE':'已到虚拟道路边缘','SOLID_MODEL_CANDIDATE':'实线候选：保守拦截',
 'LANE_SOURCE_MISSING_OR_EXPIRED':'对应来源车道结果缺失或过期','LANE_TYPE_NOT_STABLE':'线型仍不稳定',
 'EGO_BOUNDARY_NOT_QUALIFIED':'尚未确认自车相邻边界','OBSERVATION_ONLY_NOT_ACCEPTED_FOR_EXECUTION':'观察结果尚未用于执行',
 'LATERAL_REQUEST_REQUIRES_FORWARD':'横向动作需先处于前进', 'CONFIGURATION_STOP_REQUIRES_NEUTRAL':'场景已切换，先回中',
 'EXPLICIT_STOP':'主动停车','DUPLICATE_EVENT':'忽略重复事件','INVALID_OR_EXPIRED_EVENT':'输入无效或已过期',
 'CLOCK_MOVED_BACKWARD':'时钟回退，已停车'}
REASONS.update(CAMERA_FRESH_EVIDENCE_RECOVERED='摄像头新鲜无人车结果已更新，恢复直行',LANE_REQUEST_AWAIT_CONFIRMATION='已申请，等待同向手势确认',
 LANE_REQUEST_CANCELLED='已取消变道，转向灯收回',
 LANE_CHANGE_EXECUTED_SIMULATION='已执行一次模拟变道',
 RETURN_TO_NEUTRAL_REQUIRED='先回水平解锁',
 LANE_REQUEST_WRONG_SCENE='当前不是变道场景')


def render(state,env,mode,now,images=(None,None),freshness=(False,False),note=''):
    im=Image.new('RGB',(1280,720),'#101925');d=ImageDraw.Draw(im)
    def text(x,y,s,size=17,color='#e6edf5'):d.text((x,y),s,font=FONTS[size],fill=color)
    text(18,12,'智慧交通 · 驾驶请求与环境决策原型',24)
    text(650,16,WORDS[mode],20,'#ffcb66' if mode=='SCRIPTED' else '#8ac8ff')
    for idx,(x,title) in enumerate([(18,'HDMI道路画面'),(502,'摄像头画面')]):
        text(x,62,title,20);text(x+230,65,'源图新鲜' if freshness[idx] else '未提供当前源图',15,'#77daac' if freshness[idx] else '#ffcb66')
        d.rounded_rectangle((x,98,x+470,362),radius=8,fill='#1b2a3a')
        if images[idx] is not None:
            rgb=Image.fromarray(images[idx][:,:,::-1]).resize((470,264));im.paste(rgb,(x,98))
        else:text(x+35,206,'测试无实拍' if mode=='SCRIPTED' else '当前时刻无配对源图',20,'#8196ad')
    lanes=env.get('lanes',{});lane_text=[]
    for side,label in [('left','左'),('right','右')]:
        a=lanes.get(side,{}) if fresh(lanes,now) else {}
        lane_text.append(label+'：候选'+WORDS.get(a.get('candidate','UNKNOWN'),'未知')+'/持续'+WORDS.get(a.get('stable','UNKNOWN'),'未知'))
    text(18,375,'  '.join(lane_text),15,'#a8bbcf')
    text(502,376,'摄像头模拟视角：'+WORDS.get(state['simulated_view'],state['simulated_view']),20,'#8ac8ff')
    d.rounded_rectangle((18,402,566,660),radius=8,fill='#1b2a3a')
    text(35,412,'虚拟三车道（独立示意，不是图像配准）',17)
    for x in (190,360):d.line((x,453,x,650),fill='#8797aa',width=3)
    for x,label in [(108,'左'),(278,'中'),(448,'右')]:text(x-10,451,label,17)
    cx=108+170*state['virtual_lane_index'];color='#61d5a3' if state['executed']!='STOP' else '#88a3bf'
    d.rounded_rectangle((cx-29,514,cx+29,608),radius=12,fill=color)
    d.rectangle((cx-19,527,cx+19,550),fill='#223e53');text(cx-20,575,'虚拟',15,'#142638')
    text(600,423,'调试输入（后续接陀螺仪事件）',20)
    for i,line in enumerate(['0 回中  W/S 前倾/后倾','A/D 左右变道  Q/E 左右转','空格 停车  1 路口  2 变道','测试素材：C 清楚  R 红灯  Y 黄灯','L/B 左/右实线  H 风险  M 缺失','测试素材按键仅测试数据模式有效']):text(600,462+i*28,line,17,'#a8bbcf')
    d.rounded_rectangle((990,60,1262,660),radius=8,fill='#1b2a3a')
    text(1006,76,WORDS[state['scene']],24)
    lines=[('虚拟行驶',WORDS[state['executed']]),('虚拟车道',WORDS[state['virtual_lane']]),('输入使能','已回中' if state['neutral_armed'] else '需回中'),
        ('本次状态',WORDS.get(state['decision']['status'],state['decision']['status'])),('灯色观察',WORDS.get(env.get('signal',{}).get('state','UNKNOWN'),'未知') if fresh(env.get('signal'),now) else '过期/缺失'),
        ('风险观察',WORDS.get(env.get('camera',{}).get('risk','UNKNOWN'),'未知') if fresh(env.get('camera'),now) else '过期/缺失'),('检测目标',str(len(env.get('camera',{}).get('targets',[]))) if fresh(env.get('camera'),now) else '无有效结果')]
    for i,(a,b) in enumerate(lines):text(1006,122+i*36,a+'：'+b,17)
    text(1006,386,'最近请求反馈',20,'#ffcb66')
    reasons=state['last_feedback'].get('reasons',[]) or ['ALLOW_SIMULATED']
    for i,reason in enumerate(reasons[:5]):
        message=REASONS.get(reason,WORDS.get(reason,reason))
        
        for j in range(0,len(message),13):text(1006,422+i*42+(j//13)*18,message[j:j+13],15,'#ffcb66')
    text(18,682,'仅虚拟车辆；无真实执行输出。固定摄像头仅切换模拟视角标签。'+note,15,'#8fa6bf')
    return np.asarray(im)[:,:,::-1].copy()

REASONS.update(CAMERA_UPDATE_GRACE='识别更新短暂等待，限时维持模拟行驶',CAMERA_TARGET_PRESENT='检出行人/车辆：模拟避险停车',LANE_REQUEST_WRONG_SCENE='请在变道场景发起变道',MODEL_BASED_SIMULATION_ONLY='模型结果仅用于模拟',INPUT_NOT_READY='输入未就绪/已停止',GESTURE_REJECTED='手势请求被拒绝')

REASONS.update(SIGNAL_RED_LATCHED='已确认红灯拦截，等待确认绿灯',SIGNAL_YELLOW_LATCHED='已确认黄灯拦截，等待确认绿灯')
