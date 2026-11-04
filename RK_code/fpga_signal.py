
from lamp_evidence import merge_lamps,evidence
COLORS={'red':'RED','green':'GREEN','yellow':'YELLOW'}
def candidates(rows,counts,fid):
    focused=[r for r in rows if r['class_id'] in (2,3,4,5) and 160<=(r['box'][0]+r['box'][2])/2<=480]
    out=[]
    for r in merge_lamps(focused):
        ev=evidence(counts,r['box']);raw=COLORS.get(ev['status'],'UNKNOWN')
        totals=sorted(ev.get('totals') or [0,0,0],reverse=True)
        supported=raw!='UNKNOWN' and totals[0]>=6 and totals[0]>=3*max(1,totals[1])
        if not supported:raw='UNKNOWN'
        cls={'RED':2,'GREEN':3,'YELLOW':5}.get(raw,4)
        out.append(dict(r,class_id=cls,label=raw.lower(),raw=raw,backend='fpga_same_frame',
                        model_label=r['label'],reason='fpga_'+ev['status'],fpga=ev,hardware_frame_id=fid,
                        current_color_confirmed=supported))
    return out
