


import copy,math,time
from dataclasses import dataclass,asdict
import numpy as np
from near_boundary import Config
from lane_timing import OBSERVATION_GAP

@dataclass(frozen=True)
class CrossConfig:
    max_gap:int=24
    max_slope_change:float=.15
    max_fit_error:float=1.5
    max_mutual_error:float=6.
    min_outward_slope:float=.1
    max_slope:float=4.

RULES=CrossConfig()

def compare(a,b,config=Config(),rules=RULES):
    if a['image_side']!=b['image_side'] or a['model_candidate']!=b['model_candidate']:
        return False,dict(reason='SIDE_OR_TYPE_CHANGED')
    pa={y:x for f in a['observed_fragments'] for x,y in f};pb={y:x for f in b['observed_fragments'] for x,y in f};common=pa.keys()&pb.keys()
    if len(common)>=config.common_rows:
        error=float(np.quantile([abs(pa[y]-pb[y]) for y in common],.9))
        return error<=config.match_distance,dict(reason='DIRECT_OBSERVED_OVERLAP',common_rows=len(common),error90=error,limit=config.match_distance,passed=error<=config.match_distance)
    detail=dict(reason='CROSS_STROKE_UNSUPPORTED',common_rows=len(common),rules=asdict(rules))
    if a['model_candidate']!='DASHED':return False,dict(detail,failed_gate='NOT_DASHED')
    if len(a['observed_fragments'])!=1 or len(b['observed_fragments'])!=1:return False,dict(detail,failed_gate='FRAGMENT_COUNT')
    if common and max(abs(pa[y]-pb[y]) for y in common)>rules.max_mutual_error:return False,dict(detail,failed_gate='SMALL_OVERLAP_POSITION')
    arrays=[];fits=[]
    for item in [a,b]:
        p=np.array(item['observed_fragments'][0],dtype=float)
        if len(p)<config.min_rows or p.shape[1]!=2 or not np.isfinite(p).all():return False,dict(detail,failed_gate='INVALID_FRAGMENT')
        p=p[np.argsort(p[:,1])]
        if not np.all(np.diff(p[:,1])==1) or p[0,1]<config.near_top or p[-1,1]>=360:return False,dict(detail,failed_gate='NONCONTIGUOUS_OR_OUTSIDE_NEAR')
        fit=np.polyfit(p[:,1]-320,p[:,0],1)
        outward=fit[0] if a['image_side']=='right' else -fit[0]
        if not rules.min_outward_slope<=outward<=rules.max_slope:return False,dict(detail,failed_gate='SLOPE_RANGE',measured_slope=float(outward))
        if np.quantile(abs(np.polyval(fit,p[:,1]-320)-p[:,0]),.9)>rules.max_fit_error:return False,dict(detail,failed_gate='FIT_RESIDUAL')
        arrays.append(p);fits.append(fit)
    gap=max(0,max(p[0,1] for p in arrays)-min(p[-1,1] for p in arrays)-1)
    spans=[p[-1,1]-p[0,1]+1 for p in arrays]
    detail['gap_rows']=int(gap)
    if gap>min(rules.max_gap,*spans):return False,dict(detail,failed_gate='GAP_EXCEEDS_STROKE_SPAN',allowed_gap=float(min(rules.max_gap,*spans)))
    if abs(fits[0][0]-fits[1][0])>rules.max_slope_change:return False,dict(detail,failed_gate='SLOPE_CHANGE',slope_change=float(abs(fits[0][0]-fits[1][0])))
    
    
    errors=[float(np.quantile(abs(np.polyval(fits[1-i],p[:,1]-320)-p[:,0]),.9)) for i,p in enumerate(arrays)]
    detail['mutual_errors90']=errors
    ok=max(errors)<=rules.max_mutual_error
    detail['reason']='BOUNDED_DASH_TANGENT_AGREEMENT' if ok else 'MUTUAL_POSITION_DISAGREEMENT'
    return ok,detail

class CrossSegmentStability:
    def __init__(self,config=Config()):self.config=config;self.reset()
    def reset(self):self.previous={};self.last=None
    def process(self,observation,stamp,now,clock=time.perf_counter):
        started=clock();age=now-stamp
        if not math.isfinite(stamp) or not math.isfinite(now) or not 0<=age<=self.config.ttl or self.last is not None and stamp<=self.last:
            self.reset();return dict(status='INVALID_SOURCE',sides=[],driving_permission='UNKNOWN')
        gap_reset=self.last is not None and stamp-self.last>OBSERVATION_GAP
        if gap_reset:self.reset()
        current=copy.deepcopy(observation);new={}
        for a in current['sides']:
            a.update(consecutive_frames=0,stable_prediction=False,near_type_prediction='UNKNOWN',
                temporal_reset_reason='CURRENT_CANDIDATE_UNKNOWN',previous_source_timestamp=self.last)
            if a['model_candidate']=='UNKNOWN':continue
            old=self.previous.get(a['image_side']);matches=False
            if old and old['model_candidate']==a['model_candidate']:
                matches,detail=compare(a,old,self.config)
                a['temporal_match']=detail
            a['temporal_reset_reason']=('CONTINUED' if matches else 'GEOMETRY_MISMATCH' if old and old['model_candidate']==a['model_candidate'] else 'TYPE_CHANGED' if old else 'OBSERVATION_GAP' if gap_reset else 'NO_PREVIOUS_KNOWN_SIDE')
            n=old['consecutive_frames']+1 if matches else 1
            a.update(consecutive_frames=n,stable_prediction=n>=self.config.confirmations,
                near_type_prediction=a['model_candidate'] if n>=self.config.confirmations else 'UNKNOWN',confirmed=False)
            new[a['image_side']]=copy.deepcopy(a)
        elapsed=clock()-started
        if not math.isfinite(elapsed) or elapsed<0 or age+elapsed>self.config.ttl:
            self.reset();return dict(status='EXPIRED_DURING_PROCESSING',sides=[],driving_permission='UNKNOWN')
        self.previous=new;self.last=stamp
        current.update(status='PROVISIONAL_MODEL_PREDICTIONS',source_timestamp=stamp,expires_at=stamp+self.config.ttl,driving_permission='UNKNOWN')
        return current
