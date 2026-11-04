
from compare import cv2,np


def evaluate(image,box,appearance,original=None):
    from signal_core import evidence,UNKNOWN,COLORS
    if original is None:original=evidence(image,box)
    if original['reason'] in ('blue_sign_candidate','conflicting_colors') or appearance['kind']!='lamp_head':
        return original
    cores=[c for c in appearance.get('cores',[]) if .55<=c['aspect']<=1.9 and (c['fill']>=.65 or c.get('round_compact',False))]
    if not cores:cores=appearance.get('chromatic_cores',[])
    
    
    if not cores:return original
    core=max(cores,key=lambda c:c['area'])
    x,y=np.maximum(0,np.floor(box[:2]).astype(int));xx,yy=np.minimum(image.shape[1::-1],np.ceil(box[2:]).astype(int))
    roi=image[y:yy,x:xx]
    if not roi.size:return dict(raw=UNKNOWN,reason='empty',components=[])
    a,b,c,d=core['box'];pad=max(1,int(np.ceil(max(c-a,d-b)*.5)))
    a,b,c,d=max(0,a-pad),max(0,b-pad),min(xx-x,c+pad),min(yy-y,d+pad)
    support=np.zeros(roi.shape[:2],bool);support[b:d,a:c]=True
    hsv=cv2.cvtColor(roi,cv2.COLOR_BGR2HSV);hue,sat,value=cv2.split(hsv)
    blue,green,red=[channel.astype(float) for channel in cv2.split(roi)]
    background=float(np.percentile(value,25))
    bright=support&(value>=max(125,background+24))&(sat>=35)
    masks=[bright&((hue<=12)|(hue>=168))&(red-np.maximum(green,blue)>=12),
           bright&(hue>=38)&(hue<=96)&(green-red>=16)&(green-blue>=-8),
           bright&(hue>=15)&(hue<=36)&(np.minimum(red,green)-blue>=18)]
    votes={color:int(np.count_nonzero(mask)) for color,mask in zip(COLORS,masks)}
    connected={}
    for color,mask in zip(COLORS,masks):
        count,_,stats,_=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
        connected[color]=max((int(s[cv2.CC_STAT_AREA]) for s in stats[1:]),default=0)
    binding=dict(core_box=[int(x+a),int(y+b),int(x+c),int(y+d)],votes=votes,
                 connected=connected,background=background)
    ordered=sorted(COLORS,key=lambda k:votes[k],reverse=True);winner,runner=ordered[:2]
    if votes[winner]>=6 and connected[winner]>=4:
        if 1.6<=appearance.get('ratio',0)<=4.8 and winner!='GREEN':
            
            
            other=(hue>=38)&(hue<=96)&(green-red>=16)&(green-blue>=-8)&(sat>=35)&(value>=max(140,background+24))
            other[:int(roi.shape[0]*.5)]=False
            other[:,:int(roi.shape[1]*.1)]=False
            other[:,int(np.ceil(roi.shape[1]*.9)):]=False
            _,_,other_stats,_=cv2.connectedComponentsWithStats(other.astype(np.uint8),8)
            if np.count_nonzero(other)>=6 and max((int(s[cv2.CC_STAT_AREA]) for s in other_stats[1:]),default=0)>=4:
                return dict(raw=UNKNOWN,reason='conflicting_colors',components=original['components'],binding=binding)
        
        
        if original['raw'] not in (UNKNOWN,winner) and 'GREEN' in (original['raw'],winner):
            return dict(raw=UNKNOWN,reason='conflicting_colors',components=original['components'],binding=binding)
        if votes[runner]>=2 and votes[runner]>=votes[winner]*.35:
            return dict(raw=UNKNOWN,reason='conflicting_colors',components=[],binding=binding)
        return dict(raw=winner,reason='core_bound_color',components=[dict(color=winner,
            area=votes[winner],box=binding['core_box'],evidence_method='core_bound_bright_pixels')],binding=binding)
    
    
    local=[item for item in original['components']
           if x+a<=(item['box'][0]+item['box'][2])/2<=x+c
           and y+b<=(item['box'][1]+item['box'][3])/2<=y+d]
    colors={item['color'] for item in local}
    if len(colors)>1:return dict(raw=UNKNOWN,reason='conflicting_colors',components=local,binding=binding)
    if original['raw']!='UNKNOWN' and original['raw'] in colors:
        return dict(raw=original['raw'],reason='core_bound_legacy_blob',components=local,binding=binding)
    return dict(raw=UNKNOWN,reason='no_supported_core_color',components=local,binding=binding)
