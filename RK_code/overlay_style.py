
import cv2
TRANSPARENCY=.40
OPACITY=1.-TRANSPARENCY
ALERT_TRANSPARENCY=0.
ALERT_OPACITY=1.-ALERT_TRANSPARENCY

def rectangle(image,start,end,color,thickness=2):

    x1,y1=map(int,start);x2,y2=map(int,end)
    pad=max(1,thickness)
    left,top=max(0,min(x1,x2)-pad),max(0,min(y1,y2)-pad)
    right,bottom=min(image.shape[1],max(x1,x2)+pad+1),min(image.shape[0],max(y1,y2)+pad+1)
    if right<=left or bottom<=top:return
    view=image[top:bottom,left:right];layer=view.copy()
    cv2.rectangle(layer,(x1-left,y1-top),(x2-left,y2-top),color,thickness)
    cv2.addWeighted(view,TRANSPARENCY,layer,OPACITY,0,dst=view)
