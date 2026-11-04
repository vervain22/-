




import copy,math,time
from dataclasses import dataclass,asdict
import numpy as np
import cv2
from paint_evidence import prepare,intervals
from endpoints import inspect
from lane_timing import EVIDENCE_TTL,OBSERVATION_GAP,CONFIRMATIONS

@dataclass(frozen=True)
class Config:
    near_top:int=264
    nearest_row:int=276
    min_rows:int=12
    min_solid_rows:int=30
    exclusive_support:float=.8
    min_paint_support:float=.8
    tie_margin:float=8.
    match_distance:float=12.
    common_rows:int=6
    confirmations:int=CONFIRMATIONS
    ttl:float=EVIDENCE_TTL

def _unknown(side,reason,**extra):
    return dict(image_side=side,model_candidate='UNKNOWN',near_type_prediction='UNKNOWN',
        reason=reason,observed_fragments=[],confirmed=False,**extra)

def prepare_geometry(image,classes,base,config=Config()):

    if image.shape!=(360,640,3) or image.dtype!=np.uint8:raise ValueError('Expected native BGR640x360')
    if not (0<=config.near_top<config.nearest_row<360 and config.min_rows>=8
        and config.min_solid_rows>=config.min_rows and .5<config.exclusive_support<=1
        and .5<config.min_paint_support<=1 and config.confirmations>=2
        and 0<config.ttl<=EVIDENCE_TTL and config.common_rows>=3 and config.match_distance>0 and config.tie_margin>0):raise ValueError('Invalid near config')
    dashed=np.zeros((360,640),bool);solid=dashed.copy()
    for k,m in classes.items():
        if k not in ['0','1','2','3'] or m.shape!=(360,640) or np.any((m != 0) & (m != 1)):raise ValueError('Invalid native class mask')
        if int(k)%2:solid|=m.astype(bool)
        else:dashed|=m.astype(bool)
    all_observed=dashed|solid;options={'left':[],'right':[]};edge_options={'left':[],'right':[]};nearest={'left':-1,'right':-1}
    for i,b in enumerate(base['boundaries']):
        side=b.get('image_side')
        if side not in options:continue
        pts=np.array([p for f in b['observed_fragments'] for p in f],dtype=int)
        if pts.ndim!=2 or pts.shape[1]!=2 or not len(pts):raise ValueError('Invalid boundary points')
        pts=pts[np.argsort(pts[:,1])]
        if len(np.unique(pts[:,1]))!=len(pts) or (pts<0).any() or (pts[:,0]>=640).any() or (pts[:,1]>=360).any():raise ValueError('Invalid native observation')
        if not all_observed[pts[:,1],pts[:,0]].all():raise ValueError('Invented observation pixels')
        nearest[side]=max(nearest[side],int(pts[-1,1]))
        
        
        
        if (len(pts)>=2*config.min_rows
                and config.near_top-config.min_rows<=pts[-1,1]<config.nearest_row):
            full_runs=np.split(pts,np.flatnonzero(np.diff(pts[:,1])>1)+1)
            for r in full_runs:
                edge=r[r[:,1]>=config.near_top-2*config.min_rows]
                if (len(r)>=2*config.min_rows and len(edge)>=config.min_rows
                        and config.near_top-config.min_rows<=r[-1,1]<config.nearest_row
                        and b['pattern_reason']!='AMBIGUOUS_GEOMETRY'):
                    xmid=float(np.median(edge[:,0]))
                    if (side=='left' and xmid<300) or (side=='right' and xmid>340):
                        edge_options[side].append(dict(parent_boundary=i,points=edge,full_points=pts,
                            geometry_ambiguous=False,selection_mode='ROI_EDGE_OBSERVED_STROKE',wide_corridor=b.get('bounded_wide_corridor',False)))
        
        near=pts[pts[:,1]>=config.near_top]
        if not len(near):continue
        runs=np.split(near,np.flatnonzero(np.diff(near[:,1])>1)+1)
        valid=[r for r in runs if len(r)>=config.min_rows and r[-1,1]>=config.nearest_row]
        if not valid:continue
        p=max(valid,key=lambda r:r[-1,1]);xs,ys=p[:,0],p[:,1]
        if side=='left' and np.median(xs)>=300 or side=='right' and np.median(xs)<=340:continue
        item=dict(parent_boundary=i,points=p,full_points=pts,geometry_ambiguous=b['pattern_reason']=='AMBIGUOUS_GEOMETRY',wide_corridor=b.get('bounded_wide_corridor',False))
        options[side].append(item)
    plans=[]
    for side,items in options.items():
        if not items:
            
            items=[v for v in edge_options[side] if int(v['points'][-1,1])>=nearest[side]]
        if not items:plans.append(dict(unknown=_unknown(side,'NO_USABLE_NEAR_STROKE')));continue
        
        
        lo=max(v['points'][0,1] for v in items);hi=min(v['points'][-1,1] for v in items)
        if lo>hi:plans.append(dict(unknown=_unknown(side,'BOUNDARIES_NOT_COMPARABLE_AT_COMMON_ROW')));continue
        def xpos(v):return int(v['points'][v['points'][:,1]==hi,0][0])
        items.sort(key=lambda v:abs(xpos(v)-320))
        if len(items)>1 and abs(abs(xpos(items[1])-320)-abs(xpos(items[0])-320))<config.tie_margin:
            plans.append(dict(unknown=_unknown(side,'COMPETING_NEAR_BOUNDARIES')));continue
        v=items[0];p=v['points'];xs,ys=p[:,0],p[:,1];d=dashed[ys,xs];s=solid[ys,xs]
        fractions=dict(DASHED=float((d&~s).mean()),SOLID=float((s&~d).mean()))
        kind=max(fractions,key=fractions.get);candidate=kind;reason='SINGLE_NEAR_STROKE_MODEL_PRIOR'
        
        
        fp=v['full_points']
        
        
        stroke=[r for r in np.split(fp,np.flatnonzero(np.diff(fp[:,1])>1)+1)
                if r[0,1]<=ys[0] and r[-1,1]>=ys[-1]][0]
        plans.append(dict(side=side,v=v,p=p,xs=xs,ys=ys,fractions=fractions,kind=kind,
            candidate=candidate,reason=reason,stroke=stroke,hi=hi,comparison_x=xpos(v)))
    return dict(image=image,classes=classes,base=base,config=config,plans=plans,dashed=dashed,solid=solid)


def _distant_occlusion_allows_local_solid(kind,fractions,p,endpoint,paint,covered):





    if kind!='SOLID' or fractions['SOLID']<.95 or len(p)<60:return False
    ends=endpoint.get('ends',[])
    if any(e['status'] in ('PAINT_END_CAUSE_UNRESOLVED','GAP_THEN_PAINT_RESUMPTION') for e in ends):return False
    blocked=[e for e in ends if e['status']=='OCCLUDED']
    if not blocked:return False
    for e in blocked:
        edge=e.get('edge_point');points=e.get('inspected_points')
        if (e.get('direction')!=-1 or not edge or not points
                or edge[1]>=p[0,1]-12 or max(q[1] for q in points)>=p[0,1]-12):return False
    xs,ys=p[:,0],p[:,1]
    support=paint[ys,xs]>0
    if support.mean()<.95:return False
    gaps=np.diff(np.r_[False,~support,False].astype(np.int8))
    starts=np.flatnonzero(gaps==1);stops=np.flatnonzero(gaps==-1)
    if len(starts) and np.max(stops-starts)>2:return False
    
    
    corridor=cv2.dilate(covered,np.ones((25,15),np.uint8))
    return not corridor[ys,xs].any()


def observe(image,classes,base,objects,config=Config(),image_prepared=None,image_hsv=None,geometry=None):
    if objects is None:raise ValueError('Same-frame object mask required')
    context=prepare_geometry(image,classes,base,config) if geometry is None else geometry
    if (context['image'] is not image or context['classes'] is not classes
            or context['base'] is not base or context['config']!=config):
        raise ValueError('Mismatched same-source geometry context')
    prepared=prepare(image,objects,image_prepared=image_prepared);_,paint,covered=prepared
    output=[]
    for plan in context['plans']:
        if 'unknown' in plan:output.append(copy.deepcopy(plan['unknown']));continue
        side,v,p,xs,ys,fractions,kind,candidate,reason,stroke,hi=[plan[k] for k in
            ('side','v','p','xs','ys','fractions','kind','candidate','reason','stroke','hi')]
        dashed,solid=context['dashed'],context['solid'];d=dashed[ys,xs];s=solid[ys,xs]
        endpoint=inspect(image,objects,[stroke.tolist()],prepared,image_hsv=image_hsv)
        statuses=[e['status'] for e in endpoint['ends']]
        local_solid_only=_distant_occlusion_allows_local_solid(kind,fractions,p,endpoint,paint,covered) if 'OCCLUDED' in statuses else False
        if v['geometry_ambiguous']:candidate='UNKNOWN';reason='AMBIGUOUS_GEOMETRY'
        elif covered[ys,xs].any() or ('OCCLUDED' in statuses and not local_solid_only):candidate='UNKNOWN';reason='OCCLUDED_NEAR_STROKE_OR_CONTEXT'
        elif float((paint[ys,xs]>0).mean())<(.95 if v.get('selection_mode') or v.get('wide_corridor') else config.min_paint_support):candidate='UNKNOWN';reason='INSUFFICIENT_SOURCE_PAINT'
        elif fractions[kind]<(.95 if v.get('selection_mode') or v.get('wide_corridor') else config.exclusive_support):
            if not v.get('selection_mode') and not v.get('wide_corridor') and float(d.mean())>=config.exclusive_support and any(e.get('strict_gap_resumption') for e in endpoint['ends']):
                candidate='DASHED';reason='SOURCE_GAP_AND_RESUMPTION_RESOLVES_TYPE_OVERLAP'
            else:candidate='UNKNOWN';reason='MODEL_TYPE_CONFLICT_OR_WEAK_EXCLUSIVE_SUPPORT'
        elif kind=='DASHED' and not any(e in ['PAINT_END_CAUSE_UNRESOLVED','GAP_THEN_PAINT_RESUMPTION'] for e in statuses):
            candidate='UNKNOWN';reason='DASHED_PRIOR_WITHOUT_VISIBLE_NEAR_PAINT_END'
        elif kind=='SOLID' and (len(p)<config.min_solid_rows or any(e in ['PAINT_END_CAUSE_UNRESOLVED','GAP_THEN_PAINT_RESUMPTION'] for e in statuses)):
            candidate='UNKNOWN';reason='SOLID_PRIOR_TOO_SHORT_OR_VISIBLE_PAINT_END'
        elif local_solid_only:reason='LOCAL_SOLID_WITH_DISTANT_ENDPOINT_OCCLUSION'
        output.append(dict(image_side=side,parent_boundary=v['parent_boundary'],model_candidate=candidate,
            near_type_prediction='UNKNOWN',reason=reason,exclusive_support=fractions,
            ambiguous_fraction=float((d&s).mean()),paint_support=float((paint[ys,xs]>0).mean()),
            y_range=[int(ys[0]),int(ys[-1])],comparison_row=int(hi),comparison_x=plan['comparison_x'],
            observed_fragments=[p.tolist()],endpoint_context=endpoint,confirmed=False,
            distant_occlusion_ignored_for_local_solid=bool(local_solid_only and candidate=='SOLID'),
            selection_mode=v.get('selection_mode','BOUNDED_WIDE_NEAR_STROKE' if v.get('wide_corridor') else 'NORMAL_NEAR_STROKE'),
            scope='NEAR_MODEL_PRIOR_NOT_SHAPE_PROOF_OR_CONFIRMED_EGO_BOUNDARY'))
    return dict(sides=output,config=asdict(config),driving_permission='UNKNOWN',current_lane='UNKNOWN')

class NearStability:
    def __init__(self,config=Config()):self.config=config;self.reset()
    def reset(self):self.previous={};self.last=None
    def process(self,observation,stamp,now,clock=time.perf_counter):
        started=clock();age=now-stamp
        if not math.isfinite(stamp) or not math.isfinite(now) or not 0<=age<=self.config.ttl or self.last is not None and stamp<=self.last:
            self.reset();return dict(status='INVALID_SOURCE',sides=[],driving_permission='UNKNOWN')
        if self.last is not None and stamp-self.last>OBSERVATION_GAP:self.reset()
        current=copy.deepcopy(observation);new={}
        for a in current['sides']:
            a.update(consecutive_frames=0,stable_prediction=False,near_type_prediction='UNKNOWN')
            if a['model_candidate']=='UNKNOWN':continue
            old=self.previous.get(a['image_side']);matches=False
            if old and old['model_candidate']==a['model_candidate']:
                pa={y:x for f in a['observed_fragments'] for x,y in f};pb={y:x for f in old['observed_fragments'] for x,y in f};ys=pa.keys()&pb.keys()
                matches=len(ys)>=self.config.common_rows and np.quantile([abs(pa[y]-pb[y]) for y in ys],.9)<=self.config.match_distance
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
