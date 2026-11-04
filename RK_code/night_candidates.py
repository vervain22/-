"""夜间高亮色块候选，仅用于显示和提醒。"""
from functools import lru_cache
import math
import cv2
import numpy as np

COLORS = {'RED': (0, 0, 255), 'YELLOW': (0, 255, 255), 'GREEN': (0, 255, 0)}
NAMES = {'RED': 'red(候选)', 'YELLOW': 'yellow(候选)', 'GREEN': 'green(候选)'}
MAX_AGE = .8


def detect(image):
    if image is None or image.shape != (360, 640, 3) or image.dtype != np.uint8:
        return []
    # 只观察画面顶部25%高度、中央50%宽度，不更改原模型的输入。
    hsv = cv2.cvtColor(image[:90, 160:480], cv2.COLOR_BGR2HSV)
    hue, saturation, value = cv2.split(hsv)
    bright = (saturation >= 75) & (value >= 190)
    masks = {
        'RED': bright & ((hue <= 12) | (hue >= 168)),
        'YELLOW': bright & (hue >= 13) & (hue <= 38),
        'GREEN': bright & (hue >= 39) & (hue <= 100),
    }
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    rows = []
    for color, selected in masks.items():
        mask = selected.astype(np.uint8)
        # 合并相邻发光像素，原始彩色像素数量仍作为过滤依据。
        joined = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        count, labels, stats, centers = cv2.connectedComponentsWithStats(joined, connectivity=8)
        for index in range(1, count):
            x, y, width, height, area = (int(v) for v in stats[index])
            pixels = int(np.count_nonzero(mask[y:y+height, x:x+width] &
                                         (labels[y:y+height, x:x+width] == index)))
            if (pixels < 3 or not 2 <= width <= 48 or not 2 <= height <= 60
                    or not .2 <= width/height <= 5 or pixels/(width*height) < .12):
                continue
            patch = value[y:y+height, x:x+width]
            selected_patch = selected[y:y+height, x:x+width]
            rows.append(dict(box=[max(160, x+158), max(0, y-2),
                                  min(480, x+width+162), min(90, y+height+2)],
                             color=color, label=NAMES[color], pixels=pixels,
                             mean_brightness=round(float(patch[selected_patch].mean()), 1),
                             visual_only=True, decision_permission=False))
    # 避免大量灯饰候选遮满画面，优先保留较集中的高亮色块。
    return sorted(rows, key=lambda row: row['pixels'], reverse=True)[:12]


def attach(result, packet, now):
    stamp = packet.get('source_timestamp') if packet else None
    capture = result.get('capture_timestamp')
    valid = (result.get('scene') == 'NIGHT' and packet is not None
             and packet.get('mode_epoch') == result.get('mode_epoch')
             and all(isinstance(v, (int, float)) and math.isfinite(v) for v in (stamp, capture))
             and 0 <= now-stamp <= MAX_AGE and 0 <= now-capture <= .5 and stamp <= capture)
    result['night_light_candidates'] = dict(valid=bool(valid),
        rows=list(packet.get('night_candidates', [])) if valid else [],
        source_timestamp=stamp, source_ns=packet.get('source_ns') if packet else None,
        expires_at=stamp+MAX_AGE if isinstance(stamp, (int,float)) and math.isfinite(stamp) else 0,
        roi=[160, 0, 480, 90], visual_only=True, decision_permission=False)


@lru_cache(maxsize=3)
def text_mask(color):
    from PIL import Image, ImageDraw
    from dashboard import FONTS
    font = FONTS[17]
    left, top, right, bottom = font.getbbox(NAMES[color])
    mask = Image.new('L', (right-left+8, bottom-top+6), 0)
    ImageDraw.Draw(mask).text((4-left, 3-top), NAMES[color], font=font, fill=255)
    return np.asarray(mask)


def draw(canvas, evidence):
    if not evidence.get('valid'):
        return
    from overlay_style import rectangle
    for row in evidence.get('rows', []):
        color = COLORS[row['color']]
        x1, y1, x2, y2 = row['box']
        rectangle(canvas, (640+x1, y1), (640+x2, y2), color, 2)
        mask = text_mask(row['color'])
        height, width = mask.shape
        x = max(640, min(1280-width, 640+x1))
        y = max(30, min(360-height, y1-height-2))
        rectangle(canvas, (x,y), (x+width-1,y+height-1), color, -1)
        patch = canvas[y:y+height, x:x+width]
        alpha = mask[:, :, None].astype(np.uint16)
        patch[:] = ((patch.astype(np.uint16)*(255-alpha)+255*alpha+127)//255).astype(np.uint8)
