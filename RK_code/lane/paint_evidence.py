





from dataclasses import asdict, dataclass

import cv2
import numpy as np


@dataclass(frozen=True)
class Config:
    contrast: int = 12
    min_paint_rows: int = 3
    min_gap_rows: int = 5
    min_span_rows: int = 30
    max_gap_rows: int = 60


def intervals(rows):
    rows = np.asarray(rows)
    return [(int(a[0]), int(a[-1])) for a in np.split(rows, np.where(np.diff(rows) > 1)[0] + 1) if len(a)]


def _middle_pair_sum(values):
    
    
    values=list(values)
    for j,k in [(1,2),(4,5),(0,2),(3,5),(0,1),(3,4),
                (2,5),(0,3),(1,4),(2,4),(1,3),(2,3)]:
        a,b=values[j],values[k]
        values[j],values[k]=np.minimum(a,b),np.maximum(a,b)
    
    return values[2].astype(np.int16)+values[3]


def prepare_image(image, config=Config()):
    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    return _prepare_hsv(hsv, config)


def prepare_context(image, config=Config()):

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    return _prepare_hsv(hsv, config), hsv


def _prepare_hsv(hsv, config):
    hue,saturation,value8=cv2.split(hsv)
    value=value8.astype(np.int16)
    padded = np.pad(value8, ((0, 0), (12, 12)), mode='edge')
    
    
    
    values = [padded[:, 12 + dx:12 + dx + hsv.shape[1]]
              for dx in (-12, -10, -8, 8, 10, 12)]
    middle_sum = _middle_pair_sum(values)
    contrast_ok=2*value-middle_sum>=2*config.contrast
    
    
    
    adaptive_white = ((saturation < 110) & (value >= 65) & contrast_ok)
    chromatic = adaptive_white | (
        (hue >= 15) & (hue <= 40) &
        (saturation >= 70) & (value8 >= 100))
    paint = (chromatic & contrast_ok).astype(np.uint8)
    paint |= _bounded_wide_paint(hsv, config)
    paint[:, :13] = 0
    paint[:, -13:] = 0
    
    
    near = cv2.dilate(paint, np.ones((1, 3), np.uint8))
    return paint, near


def _bounded_wide_paint(hsv, config):






    hue,saturation,value=cv2.split(hsv)
    road=cv2.morphologyEx(value,cv2.MORPH_OPEN,np.ones((1,65),np.uint8))
    ridge=value.astype(np.int16)-road.astype(np.int16)>=config.contrast
    colour=((saturation<110)&(value>=65))|((hue>=15)&(hue<=40)&(saturation>=70)&(value>=100))
    mask=(ridge&colour).astype(np.int8)
    edges=np.diff(np.pad(mask,((0,0),(1,1))),axis=1)
    ys,starts=np.where(edges==1);end_ys,ends=np.where(edges==-1)
    assert np.array_equal(ys,end_ys)
    out=np.zeros(value.shape,np.uint8)
    widths=ends-starts
    valid=(widths>=12)&(widths<=48)&(starts>=13)&(ends<=value.shape[1]-13)
    ys,starts,ends,widths=[a[valid] for a in (ys,starts,ends,widths)]
    if not len(ys):return out
    
    
    columns=starts[:,None]+np.arange(48)
    samples=value[ys[:,None],np.minimum(columns,value.shape[1]-1)].astype(np.int16)
    inside=np.arange(48)[None,:]<widths[:,None]
    samples[~inside]=256;samples.sort(axis=1)
    quartile=(widths-1)*.25;lo=quartile.astype(int);fraction=quartile-lo
    index=np.arange(len(ys));centre=samples[index,lo]*(1-fraction)+samples[index,np.minimum(lo+1,47)]*fraction
    left=np.median(value[ys[:,None],starts[:,None]-np.array([2,4,6])],axis=1)
    right=np.median(value[ys[:,None],ends[:,None]+np.array([1,3,5])],axis=1)
    accepted=(centre-left>=config.contrast)&(centre-right>=config.contrast)
    selected=inside&accepted[:,None]
    out[np.broadcast_to(ys[:,None],columns.shape)[selected],columns[selected]]=1
    return out


def prepare(image, objects, config=Config(), image_prepared=None):
    if image.ndim != 3 or image.shape[2] != 3 or image.dtype != np.uint8 or min(image.shape[:2]) < 32:
        raise ValueError('Expected uint8 BGR image at least 32x32')
    if objects.shape != image.shape[:2] or np.any((objects != 0) & (objects != 1)):
        raise ValueError('Expected same-size binary object mask')
    if not (0 < config.contrast <= 255 and config.min_paint_rows >= 3 and
            1 <= config.min_gap_rows <= config.max_gap_rows and config.min_span_rows >= 10):
        raise ValueError('Invalid configuration')
    paint, near = prepare_image(image, config) if image_prepared is None else image_prepared
    occluded = cv2.dilate(objects.astype(np.uint8), np.ones((3, 7), np.uint8))
    return paint, near, occluded


def analyze(image, result, objects, config=Config()):
    paint, near, occluded = prepare(image, objects, config)
    boundaries = []
    for boundary in result['boundaries']:
        points = np.asarray(sorted([p for f in boundary['observed_fragments'] for p in f], key=lambda p: p[1]))
        ys = points[:, 1].astype(int)
        if len(np.unique(ys)) != len(ys):
            raise ValueError('Overlapping boundary observations')
        rows = np.arange(ys.min(), ys.max() + 1)
        xs = np.rint(np.interp(rows, ys, points[:, 0])).astype(int)
        valid = (xs >= 13) & (xs < image.shape[1] - 13)
        safe = np.clip(xs, 0, image.shape[1] - 1)
        observed = np.isin(rows, ys)
        visible_paint = near[rows, safe] > 0
        covered = occluded[rows, safe] > 0
        supported = observed & visible_paint & ~covered
        runs = [r for r in intervals(rows[supported]) if r[1] - r[0] + 1 >= config.min_paint_rows]
        candidate = 'UNKNOWN'
        reason = 'INSUFFICIENT_REPEATED_IMAGE_PAINT'
        gaps = []
        if not valid.all():
            reason = 'EDGE_CONTEXT_UNAVAILABLE'
        elif covered.any():
            reason = 'OCCLUDED_INTERVAL'
        elif len(runs) >= 3 and runs[-1][1] - runs[0][0] + 1 >= config.min_span_rows:
            for a, b in zip(runs, runs[1:]):
                lo, hi = a[1] + 1, b[0] - 1
                selected = (rows >= lo) & (rows <= hi)
                if config.min_gap_rows <= hi - lo + 1 <= config.max_gap_rows and visible_paint[selected].mean() <= .25:
                    gaps.append((lo, hi))
            if len(gaps) >= 2 and len(gaps) == len(runs) - 1:
                candidate, reason = 'DASHED', 'REPEATED_LOCAL_CONTRAST_PAINT'
            else:
                reason = 'IMAGE_GAPS_NOT_CLEAR'
        if boundary['pattern_reason'] == 'AMBIGUOUS_GEOMETRY':
            eligibility = 'GEOMETRY_REVIEW_REQUIRED'
        else:
            eligibility = 'UNVALIDATED_IMAGE_EVIDENCE'
        boundaries.append(dict(track_id=boundary.get('track_id'), image_pattern_candidate=candidate,
            reason=reason, eligibility=eligibility, image_paint_runs=runs, clear_image_gaps=gaps,
            supported_model_rows=int(supported.sum()), model_observed_rows=len(ys),
            absolute_brightness_support=boundary['evidence']['paint_support'],
            local_contrast_support=float(supported.sum() / len(ys)),
            confirmed=False, line_type=boundary['line_type']))
    return dict(boundaries=boundaries, config=asdict(config),
        scope='IMAGE_EVIDENCE_ONLY_NOT_VALIDATED_LINE_TYPE', current_lane='UNKNOWN', driving_permission='UNKNOWN'), paint
