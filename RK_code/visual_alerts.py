
import math
import cv2
from overlay_style import ALERT_OPACITY,ALERT_TRANSPARENCY
RISK_CLASSES={'person','car','bus','truck','motorcycle','bicycle'}

def alert_flags(result,state,now):
    capture=result.get('capture_timestamp')
    source_ok=isinstance(capture,(int,float)) and math.isfinite(capture) and 0<=now-capture<=.5
    c=result.get('camera',{});stamp=c.get('source_timestamp');end=c.get('expires_at')
    fresh=(source_ok and c.get('valid') is True and all(isinstance(x,(int,float)) and math.isfinite(x) for x in (stamp,end))
        and 0<=now-stamp<=.5 and now<=end and stamp<=capture)
    camera=fresh and any(r.get('label') in RISK_CLASSES for r in c.get('detections',[]))
    red=source_ok and result.get('enabled',{}).get('signal',True) and any(r.get('class_id')==2 for r in result.get('hdmi_display_objects',{}).get('detections',[]))
    light=result.get('hdmi',{})
    if light.get('valid') is True and light.get('conflict_hold'):
        red=source_ok and result.get('enabled',{}).get('signal',True) and light.get('state')=='RED'
    rejection=state.get('lane_rejection_alert')
    flash_hdmi=False;flash=None
    if rejection and state.get('scene') in ('LANE_CHANGE','INTERSECTION','NIGHT') and state.get('lane_change'):
        elapsed=now-rejection['started_at'];period=rejection['period_s']
        active=0<=elapsed<period*rejection['cycles']
        on=active and elapsed%period<period/2
        flash_hdmi=on
        flash=dict(active=active,on=on,cycles=rejection['cycles'],targets=['hdmi'],
            started_at=rejection['started_at'],expires_at=rejection['expires_at'])
    night=result.get('night_light_candidates',{})
    night_warning=bool(source_ok and result.get('scene')=='NIGHT' and night.get('valid')
                       and any(row.get('color') in ('RED','YELLOW') for row in night.get('rows',[])))
    camera_on=bool(camera and int(now/.35)%2==0)
    return dict(night_candidate_warning=night_warning,night_candidate_border_on=bool(night_warning and int(now/.35)%2==0),camera_lane_rejection=False,hdmi_lane_rejection=bool(flash_hdmi),
        lane_rejection_flash=flash,camera_target=bool(camera),camera_border_on=camera_on,
        hdmi_red_forward_intent=bool(red and state.get('intent')=='FORWARD'),
        visual_only=True,alpha=ALERT_OPACITY,transparency=ALERT_TRANSPARENCY,border_px=10)


def border(image):

    if ALERT_OPACITY==0:return
    h,w=image.shape[:2];n=min(10,h//2,w//2)
    for view in (image[:n],image[h-n:],image[n:h-n,:n],image[n:h-n,w-n:]):
        color=view.copy();color[:]=(0,0,255)
        view[:]=cv2.addWeighted(view,ALERT_TRANSPARENCY,color,ALERT_OPACITY,0)
