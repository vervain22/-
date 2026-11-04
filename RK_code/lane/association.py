
import cv2
import numpy as np


def _line(yy, xx, max_width=40):
    
    
    lower = yy >= 162
    yy, xx = yy[lower], xx[lower]
    rows, starts, counts = np.unique(yy, return_index=True, return_counts=True)
    if len(rows) < 6 or rows[-1] - rows[0] < 5:
        return None
    short = len(rows) < 8 or rows[-1] - rows[0] < 10
    widths = xx[starts+counts-1] - xx[starts]
    if short and np.any(widths > 12):
        return None
    if np.any(xx[starts+counts-1] - xx[starts] > max_width):
        return None
    centers = (xx[starts+(counts-1)//2].astype(float) + xx[starts+counts//2])/2
    p = np.polyfit(rows - 270, centers, 1)
    if short and np.max(abs(np.polyval(p, rows - 270) - centers)) > 1.5:
        return None
    if np.quantile(abs(np.polyval(p, rows - 270) - centers), .9) > 4:
        return None
    
    ends = []
    for select in [rows <= rows[0] + 25, rows >= rows[-1] - 25]:
        if select.sum() < (4 if short else 8):
            return None
        ends.append(np.polyfit(rows[select] - 270, np.asarray(centers)[select], 1))
    return dict(lo=int(rows[0]), hi=int(rows[-1]), ends=ends, short=short,
                rows=rows, lower=xx[starts], upper=xx[starts+counts-1])


def _compatible(far, near):
    gap = near['lo'] - far['hi']
    if not 1 <= gap <= 70:
        return False
    if far['short']:
        
        
        
        if near['short'] or near['hi']-near['lo']+1 < 25:
            return False
        projected = np.polyval(near['ends'][0], far['rows']-270)
        supported = (projected >= far['lower']-2) & (projected <= far['upper']+2)
        return bool(supported.mean() >= .8)
    if near['short']:
        return False
    fp, np_ = far['ends'][1], near['ends'][0]
    if abs(fp[0] - np_[0]) > .45:
        return False
    
    ys = np.asarray([far['hi'], near['lo']]) - 270
    return bool(np.max(abs(np.polyval(fp, ys) - np.polyval(np_, ys))) <= 12)


def route(classes):
    nodes = []
    for key, mask in classes.items():
        if key not in ['0', '1', '2', '3'] or mask.shape != (360, 640) or np.any((mask != 0) & (mask != 1)):
            raise ValueError('Invalid lane classes')
        native=mask.astype(np.uint8)
        ox,oy,bw,bh=cv2.boundingRect(native)
        if not bw or not bh:continue
        
        
        end_x,end_y=ox+bw,oy+bh;ox-=ox%2;oy-=oy%2
        count, labels, stats, _ = cv2.connectedComponentsWithStats(native[oy:end_y,ox:end_x], 8)
        for k in range(1, count):
            x, y, w, h, _ = stats[k]
            
            ry, rx = np.where(labels[y:y+h, x:x+w] == k)
            yy, xx = ry+y+oy, rx+x+ox
            near = yy >= 270
            side, reason = 'UNKNOWN', 'NO_NEAR_OBSERVATIONS'
            if near.sum() >= 10:
                center = float(np.median(xx[near]))
                q10,q90 = np.quantile(xx[near], [.1,.9])
                span = float(q90-q10)
                if span <= 100:
                    side = 'left' if center < 300 else 'right' if center > 340 else 'UNKNOWN'
                    reason = 'NEAR_IMAGE_POSITION' if side != 'UNKNOWN' else 'CENTRE_AMBIGUOUS'
                else:
                    reason = 'NEAR_SPAN_AMBIGUOUS'
            line = _line(yy, xx)
            bounded_wide = False
            if line is None and reason=='NEAR_SPAN_AMBIGUOUS':
                rows, starts, counts = np.unique(yy, return_index=True, return_counts=True)
                widths = xx[starts+counts-1]-xx[starts]
                
                
                if (len(rows)>=30 and 40<widths.max()<=48
                        and np.all(counts==widths+1)):
                    line = _line(yy,xx,max_width=48)
                    bounded_wide = line is not None
            if reason=='NO_NEAR_OBSERVATIONS' and line is not None and not line['short']:
                
                
                
                gap=270-line['hi'];span=line['hi']-line['lo']+1
                projected=float(np.polyval(line['ends'][1],0))
                if 0<=gap<=span and 0<=projected<640:
                    if projected>340 and xx.min()>340 and line['ends'][1][0]>.1:
                        side,reason='right','BOUNDED_REFERENCE_ROW_PROJECTION'
                    elif projected<300 and xx.max()<300 and line['ends'][1][0]<-.1:
                        side,reason='left','BOUNDED_REFERENCE_ROW_PROJECTION'
            
            
            if reason == 'NEAR_SPAN_AMBIGUOUS' and line is not None:
                side = 'left' if center < 300 else 'right' if center > 340 else 'UNKNOWN'
                reason = 'THIN_DIAGONAL_NEAR_POSITION' if side != 'UNKNOWN' else 'CENTRE_AMBIGUOUS'
            ident = len(nodes)
            nodes.append(dict(key=key, yy=yy, xx=xx, line=line, side=side,
                              reason=reason, anchor=ident if side != 'UNKNOWN' else None,
                              parent=None, ident=ident, duplicate_of=None, bounded_wide=bounded_wide))
            nodes[-1].update(code=yy*640+xx,bounds=(int(yy.min()),int(yy.max()),int(xx.min()),int(xx.max())))

    
    
    
    representatives = []
    for n in sorted(nodes, key=lambda n: (-len(n['xx']), n['ident'])):
        code=n['code'];ny0,ny1,nx0,nx1=n['bounds']
        for m in representatives:
            my0,my1,mx0,mx1=m['bounds']
            if ny1<my0 or my1<ny0 or nx1<mx0 or mx1<nx0:
                continue
            intersection = len(np.intersect1d(code, m['code'], assume_unique=True))
            iou = intersection/(len(code)+len(m['xx'])-intersection)
            if iou >= .7:
                n['duplicate_of'] = m['ident']
                break
        if n['duplicate_of'] is None:
            representatives.append(n)

    
    
    eligible = [n for n in representatives if n['line'] is not None]
    possible = {}
    for n in eligible:
        if n['reason'] not in ('NO_NEAR_OBSERVATIONS', 'NEAR_IMAGE_POSITION', 'THIN_DIAGONAL_NEAR_POSITION', 'BOUNDED_REFERENCE_ROW_PROJECTION'):
            continue
        possible[n['ident']] = [m for m in eligible
                               if (not n['line']['short'] or int(n['key']) % 2 == int(m['key']) % 2)
                               and _compatible(n['line'], m['line'])]
    
    for n in sorted(eligible, key=lambda n: n['line']['hi'], reverse=True):
        if n['ident'] not in possible:
            continue
        options = possible[n['ident']]
        if options:
            
            
            
            closest = min(options, key=lambda m: m['line']['lo'])
            options = [m for m in options if m['line']['lo'] <= closest['line']['hi']
                       and m['line']['hi'] >= closest['line']['lo']]
        if len(options) != 1:
            if len(options) > 1:
                n['reason'] = 'MULTIPLE_GEOMETRIC_CONTINUATIONS'
            continue
        parent = options[0]
        if n['line']['short']:
            competitors = [m for m in eligible if m['ident'] != n['ident']
                           and m['line']['short']
                           and min(m['line']['hi'],n['line']['hi']) >= max(m['line']['lo'],n['line']['lo'])
                           and any(p['ident']==parent['ident'] for p in possible.get(m['ident'], []))]
            if competitors:
                n['reason'] = 'COMPETING_SHORT_OBSERVATIONS'
                continue
        if parent['anchor'] is None:
            continue
        if n['side'] != 'UNKNOWN' and n['side'] != parent['side']:
            continue
        n.update(side=parent['side'], reason='UNIQUE_OBSERVED_SEGMENT_CHAIN',
                 anchor=parent['anchor'], parent=parent['ident'])

    for n in nodes:
        if n['duplicate_of'] is not None:
            m = nodes[n['duplicate_of']]
            n.update(side=m['side'], anchor=m['anchor'], parent=m['parent'],
                     reason='DUPLICATE_GEOMETRY_SAME_OBSERVATION')

    routed, items = {}, []
    raw = np.zeros((360, 640), np.uint8)
    for m in classes.values():
        raw |= m
    for n in nodes:
        dest = None
        if n['side'] != 'UNKNOWN':
            dest = str((0 if n['side'] == 'left' else 2) + int(n['key']) % 2)
            routed.setdefault(dest, np.zeros_like(raw))[n['yy'], n['xx']] = 1
        items.append(dict(component_id=n['ident'], model_class=int(n['key']),
                          provisional_image_side=n['side'], routed_class=int(dest) if dest else None,
                          pixels=int(len(n['xx'])), reason=n['reason'], anchor_id=n['anchor'],
                          bounded_wide_corridor=n['bounded_wide'],
                          parent_id=n['parent'], duplicate_of=n['duplicate_of'], reassigned=dest is not None and dest != n['key']))
    for m in routed.values():
        assert not np.any((m > 0) & (raw == 0))
    boundaries = []
    for anchor in sorted({n['anchor'] for n in nodes if n['anchor'] is not None}):
        group = [n for n in nodes if n['anchor'] == anchor]
        yy = np.concatenate([n['yy'] for n in group])
        xx = np.concatenate([n['xx'] for n in group])
        
        
        
        keep = yy >= 162
        code = np.unique(yy[keep]*640 + xx[keep])
        if not len(code):
            continue
        row_y, starts, counts = np.unique(code//640, return_index=True, return_counts=True)
        widths=code[starts+counts-1] % 640-code[starts] % 640
        wide=bool(any(n['bounded_wide'] for n in group)
            and np.max(widths)<=48 and np.all(counts==widths+1))
        ambiguous = bool(np.any(widths > (48 if wide else 40)))
        points = np.column_stack((code[starts+(counts-1)//2] % 640, row_y))
        fragments = [v.tolist() for v in np.split(points, np.flatnonzero(np.diff(points[:, 1]) > 1)+1)]
        boundaries.append(dict(anchor_id=anchor, image_side=group[0]['side'],
                               component_ids=[n['ident'] for n in group], bounded_wide_corridor=wide,
                               observed_fragments=fragments,
                               pattern_reason='AMBIGUOUS_GEOMETRY' if ambiguous else 'OBSERVED_SEGMENT_CHAIN'))
    return routed, dict(components=items, boundaries=boundaries, scope='Observed segments linked by unique local endpoint geometry to near-image side. No gap pixels added. Not confirmed ego lane or line type.')
