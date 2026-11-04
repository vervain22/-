"""驾驶动作与告警的九项滚动记录。"""
from collections import deque
from functools import lru_cache

COLORS = {
    'execute': '#77daac', 'signal': '#ffdb66', 'block': '#ff7777',
}
ACTION_NAMES = {
    'FORWARD': '前进', 'REVERSE': '后退', 'STOP': '停车',
    'LANE_LEFT': '左变道', 'LANE_RIGHT': '右变道',
    'TURN_LEFT': '左转向', 'TURN_RIGHT': '右转向',
}


def cancel_name(action):
    return '取消转向' if action.startswith('TURN_') else '取消变道'


class ActionHistory:
    def __init__(self):
        self.entries = deque(maxlen=9)
        self.previous = None
        self.request_token = None

    def append(self, text, kind):
        self.entries.append((text, kind))

    def update(self, result, state, now):
        previous = self.previous or {}
        req = state.get('lane_change') or {}
        old_req = previous.get('request') or {}
        scene = (state.get('scene'), result.get('mode_epoch'))
        changed_scene = bool(previous) and scene != previous['scene']
        action = req.get('action')
        old_action = old_req.get('action')
        diag = state.get('decision_diagnostics') or {}
        raw_request = diag.get('request') or {}
        token = (raw_request.get('epoch'), raw_request.get('stamp'))
        new_input = (raw_request.get('stamp') is not None
                     and raw_request.get('stamp') == diag.get('request_watermark')
                     and token != self.request_token)
        if new_input:
            self.request_token = token
        current_input = raw_request.get('name') if new_input else None
        if changed_scene:
            if old_action:
                self.append(cancel_name(old_action), 'signal')
            old_action = None
        if action and not old_action:
            self.append(('左' if req.get('side') == 'left' else '右') + '转向灯', 'signal')
        feedback = state.get('lane_change_feedback') or {}
        reasons = feedback.get('reasons', [])
        completed = (not changed_scene and bool(previous) and
                     any(r in reasons for r in ('TURN_EXECUTED_SIMULATION', 'LANE_CHANGE_EXECUTED_SIMULATION')) and
                     (state.get('heading_deg') != previous['heading'] or
                      state.get('virtual_lane_index') != previous['lane']))
        if old_action and not action and not changed_scene:
            if completed:
                self.append(ACTION_NAMES[old_action], 'execute')
            else:
                self.append(cancel_name(old_action), 'signal')
        rejection = (state.get('lane_rejection_alert') or {}).get('started_at')
        new_rejection = rejection is not None and rejection != previous.get('rejection')
        decision = state.get('decision') or {}
        # 侧方目标只在二次确认被拒时记录，申请阶段不记作截停。
        rejected = (new_rejection or
                    (action and current_input == action and feedback.get('status') == 'BLOCK'))
        motion = state.get('executed', 'STOP')
        old_motion = previous.get('motion', 'STOP')
        block = None
        if action and rejected:
            block = '转向拦截' if action.startswith('TURN_') else '变道拦截'
        # 只记录摄像头目标导致的前进到停车边沿，目标持续或告警闪烁不重复记录。
        elif (not changed_scene and old_motion == 'FORWARD' and motion == 'STOP'
              and 'CAMERA_TARGET_PRESENT' in decision.get('reasons', [])):
            block = '人车截停'
        if block and (block != previous.get('block') or new_input or new_rejection):
            self.append(block, 'block')
        if motion != old_motion and motion in ('FORWARD', 'REVERSE', 'STOP'):
            self.append(ACTION_NAMES[motion], 'execute')
        self.previous = dict(scene=scene, request=dict(req), heading=state.get('heading_deg'),
                             lane=state.get('virtual_lane_index'), motion=motion,
                             block=block, rejection=rejection)
        result['action_history'] = list(self.entries)
        return result['action_history']


@lru_cache(maxsize=64)
def draw_panel(entries, width=300, height=96):
    """首行从左到右写入，满九项后整体前移。"""
    from PIL import Image, ImageDraw
    import numpy as np
    from dashboard import FONTS, font
    cell_font = font(14)
    im = Image.new('RGB', (width, height), '#172330')
    draw = ImageDraw.Draw(im)
    draw.text((8, 0), '动作轨迹记录', font=FONTS[17], fill='#e6edf5')
    left = 24
    cell_width = (width - left - 3) // 3
    for y in (23, 46, 69, 92):
        draw.line((left-2, y, width-4, y), fill='#708399', width=2)
    for row in range(3):
        y = 25 + row * 23
        if row:
            # 使用图元绘制白色粗箭头，不依赖字体包含箭头字形。
            cy = y + 8
            draw.line((3, cy, 16, cy), fill='white', width=3)
            draw.polygon(((12, cy-5), (19, cy), (12, cy+5)), fill='white')
        for column in range(3):
            index = row * 3 + column
            if column:
                draw.line((left + column*cell_width - 3, y+1,
                           left + column*cell_width - 3, y+17), fill='#708399', width=2)
            if index >= len(entries):
                continue
            text, kind = entries[index]
            while text and cell_font.getlength(text) > cell_width-5:
                text = text[:-1]
            draw.text((left + column*cell_width, y), text, font=cell_font,
                      fill=COLORS.get(kind, '#e6edf5'))
    return np.asarray(im)[:, :, ::-1].copy()
