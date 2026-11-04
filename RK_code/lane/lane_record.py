




import copy,math
from lane_timing import EVIDENCE_TTL,CONFIRMATIONS

def build(row,now,source='HDMI',view='FRONT',view_is_simulated=False):
    if source not in ('HDMI','CAMERA'):raise ValueError('Explicit HDMI or CAMERA source required')
    if view not in ('FRONT','REAR','LEFT','RIGHT','LEFT_REAR','RIGHT_REAR'):raise ValueError('Invalid view label')
    e=row.get('evidence',{});stamp=row.get('source_timestamp',float('nan'));ns=row.get('source_ns')
    result=dict(schema='lane-observation-v1',source=source,view_label=view,
        view_is_simulated=bool(view_is_simulated),coordinate_space='native_640x360_image_sides',
        source_ns=ns,source_timestamp=stamp,valid_until=None,current=False,
        reason='INVALID_SOURCE',sides=[],current_lane='UNKNOWN',driving_permission='UNKNOWN')
    if not isinstance(stamp,(float,int)) or not isinstance(now,(float,int)) or not math.isfinite(stamp) or not math.isfinite(now):return result
    result['valid_until']=stamp+EVIDENCE_TTL
    declared_end=e.get('expires_at')
    if declared_end is not None:
        if not isinstance(declared_end,(int,float)) or not math.isfinite(declared_end):return result
        result['valid_until']=min(result['valid_until'],declared_end)
    if not isinstance(ns,int) or isinstance(ns,bool) or ns<=0:return result
    if row.get('object_source_ns')!=ns or row.get('object_detection_valid') is not True:
        result['reason']='OBJECT_SOURCE_NOT_VERIFIED';return result
    if not 0<=now-stamp<=EVIDENCE_TTL or now>result['valid_until']:
        result['reason']='EXPIRED_OR_FUTURE_SOURCE';return result
    if e.get('status')!='PROVISIONAL_MODEL_PREDICTIONS':
        result['reason']=e.get('status','MISSING_EVIDENCE');return result
    if e.get('source_timestamp')!=stamp:
        result['reason']='EVIDENCE_SOURCE_MISMATCH';return result
    sides=e.get('sides',[])
    if len(sides)!=2 or {a.get('image_side') for a in sides}!={'left','right'}:
        result['reason']='INVALID_SIDE_SET';return result
    result.update(current=True,reason='CURRENT_OBSERVATIONS')
    for a in sides:
        kind=a.get('model_candidate','UNKNOWN');n=a.get('consecutive_frames',0)
        if kind not in ('DASHED','SOLID','UNKNOWN'):kind='UNKNOWN'
        supported=kind!='UNKNOWN' and isinstance(n,int) and n>=CONFIRMATIONS and a.get('stable_prediction') is True and a.get('near_type_prediction')==kind
        result['sides'].append(dict(image_side=a['image_side'],candidate_type=kind,
            temporal_type=kind if supported else 'UNKNOWN',
            state='TEMPORALLY_SUPPORTED_MODEL_PRIOR' if supported else 'CURRENT_MODEL_CANDIDATE' if kind!='UNKNOWN' else 'INSUFFICIENT_EVIDENCE',
            reason=a.get('reason','MISSING_REASON'),consecutive_frames=n,
            line_presence=a.get('line_presence','DETECTED_OR_UNCERTAIN'),
            selection_mode=a.get('selection_mode','NORMAL_NEAR_STROKE'),
            temporal_reset_reason=a.get('temporal_reset_reason'),
            temporal_match=copy.deepcopy(a.get('temporal_match')),
            previous_source_timestamp=a.get('previous_source_timestamp'),
            observed_fragments=copy.deepcopy(a.get('observed_fragments',[])) if kind!='UNKNOWN' else [],
            confirmed=False,lane_change_permission='UNKNOWN'))
    return result
