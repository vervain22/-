import cv2
import numpy as np
COLORS={2:"RED",3:"GREEN",5:"YELLOW"}
def compact_color(image, box):
    x, y, z, w = np.asarray(box).round().astype(int)
    roi = image[y:w, x:z]
    if not roi.size:
        return dict(raw='UNKNOWN', components=[])
    h, s, v = cv2.split(cv2.cvtColor(roi, cv2.COLOR_BGR2HSV))
    masks = {'RED': (h <= 10) | (h >= 170), 'GREEN': (h >= 38) & (h <= 96), 'YELLOW': (h >= 12) & (h <= 37)}
    components = []
    support = {}
    for color, mask in masks.items():
        mask = (mask & (s >= 80) & (v >= 140)).astype(np.uint8)
        count, labels, stats, _ = cv2.connectedComponentsWithStats(mask, 8)
        support[color] = 0
        for k in range(1, count):
            bx, by, bw, bh, area = map(int, stats[k])
            fill = area / (bw * bh)
            if area < 6 or not 0.5 <= bw / bh <= 2 or fill < 0.55:
                continue
            contours, hierarchy = cv2.findContours((labels == k).astype(np.uint8), cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)
            holes = sum((cv2.contourArea(c) for c, t in zip(contours, hierarchy[0]) if t[3] >= 0))
            if holes > max(2, area * 0.12):
                continue
            support[color] = max(support[color], area)
            components.append(dict(color=color, area=area, fill=fill, box=list(map(int, [x + bx, y + by, x + bx + bw, y + by + bh]))))
    ranked = sorted(support, key=support.get, reverse=True)
    first, second = ranked[:2]
    valid = support[first] >= 6 and support[first] >= 3 * max(1, support[second])
    return dict(raw=first if valid else 'UNKNOWN', components=components, support=support)

def review(image, candidate):

    if candidate['cls'] not in COLORS:
        return dict(accepted=False, reason='unlit_or_other_class')
    box = np.asarray(candidate['box'], dtype=float)
    if box.shape != (4,) or not np.isfinite(box).all() or (not np.isfinite([candidate['obj'], candidate['class_prob']]).all()):
        return dict(accepted=False, reason='invalid_numeric_input')
    if (box[:2] < 0).any() or box[2] > image.shape[1] or box[3] > image.shape[0] or (box[2:] <= box[:2]).any():
        return dict(accepted=False, reason='invalid_box')
    if not (0.02 <= candidate['obj'] < 0.25 and candidate['class_prob'] >= 0.8):
        return dict(accepted=False, reason='weak_score_gate')
    x1, y1, x2, y2 = candidate['box']
    w, h = (x2 - x1, y2 - y1)
    if min(w, h) < 5 or max(w, h) > 160 or (not 0.3 <= w / h <= 6):
        return dict(accepted=False, reason='implausible_housing_geometry')
    color = compact_color(image, candidate['box'])
    if color['raw'] != COLORS[candidate['cls']]:
        return dict(accepted=False, reason='color_not_verified', color=color)
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    support = []
    for component in color['components']:
        if component['color'] != color['raw']:
            continue
        a, b, c, d = component['box']
        pad = max(2, round(max(c - a, d - b) * 0.5))
        a0, b0 = (max(0, a - pad), max(0, b - pad))
        c0, d0 = (min(image.shape[1], c + pad), min(image.shape[0], d + pad))
        ring = np.ones((d0 - b0, c0 - a0), bool)
        ring[b - b0:d - b0, a - a0:c - a0] = False
        pixels = hsv[b0:d0, a0:c0, 2][ring]
        dark = float(np.mean(pixels < 110)) if pixels.size else 0.0
        support.append(dict(dark_ring_fraction=dark, component=component))
    accepted = any((s['dark_ring_fraction'] >= 0.35 for s in support))
    return dict(accepted=accepted, reason='compact_light_dark_housing' if accepted else 'no_dark_housing', color=color, housing=support)
