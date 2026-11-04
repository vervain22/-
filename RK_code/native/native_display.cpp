#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/extensions/XShm.h>
#include <X11/extensions/Xrender.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <cstring>
#include <chrono>
#include <X11/keysym.h>
#include <algorithm>
#include <deque>
#include <vector>
static double costs[2];
static Atom completion_marker=0;static unsigned long submitted=0,completed=0,max_pending=0;static std::deque<std::pair<unsigned long,std::chrono::steady_clock::time_point>> pending;
static std::deque<double> completion_delays;
extern "C" double nd_progress(int k){if(k==0)return submitted;if(k==1)return completed;if(k==2)return max_pending;if(k==3)return submitted-completed;if(completion_delays.empty())return 0;auto v=completion_delays;std::sort(v.begin(),v.end());if(k==4)return v[v.size()/2];if(k==5)return v[std::min(v.size()-1,(size_t)(v.size()*.95))];return v.back();}


extern "C" double nd_cost(int k){return costs[k];}
extern "C" void nd_threads(int n){cv::setNumThreads(n);}
static XImage*alt_im=nullptr;static XShmSegmentInfo alt_sh={};static bool alt_attached=false;static bool busy[2]={false,false};static int next_slot=0,completion_type=0;
static Atom wm_delete=0;static int last_key=-1;static int target_w=1280,target_h=720,fitted_h=720;static Pixmap backpix=0;static int back_w=0,back_h=0;static Pixmap pix=0; static Picture source_picture=0,target_picture=0; static int fitted_width=0;
static Display*d=nullptr; static Window w; static GC gc; static XImage*im=nullptr; static XShmSegmentInfo sh; static bool attached=false;
extern "C" void nd_close(){
 if(!d)return;
 XSync(d,False);if(alt_attached)XShmDetach(d,&alt_sh);if(attached)XShmDetach(d,&sh);XSync(d,False);
 if(im){im->data=nullptr;XDestroyImage(im);im=nullptr;}
 if(alt_im){alt_im->data=nullptr;XDestroyImage(alt_im);alt_im=nullptr;}if(alt_sh.shmaddr && alt_sh.shmaddr!=(char*)-1)shmdt(alt_sh.shmaddr);if(alt_sh.shmid>=0)shmctl(alt_sh.shmid,IPC_RMID,nullptr);alt_sh={};alt_sh.shmid=-1;alt_attached=false;busy[0]=busy[1]=false;next_slot=0;
 if(sh.shmaddr && sh.shmaddr!=(char*)-1)shmdt(sh.shmaddr);
 if(sh.shmid>=0)shmctl(sh.shmid,IPC_RMID,nullptr);
 if(source_picture)XRenderFreePicture(d,source_picture);
 if(target_picture)XRenderFreePicture(d,target_picture);
 if(backpix)XFreePixmap(d,backpix);if(pix)XFreePixmap(d,pix);if(w)XDestroyWindow(d,w);
 XCloseDisplay(d);d=nullptr;attached=false;backpix=0;back_w=back_h=0;pix=0;source_picture=target_picture=0;w=0;sh={};sh.shmid=-1;last_key=-1;
}
static void fit(){
 if(!backpix || back_w!=target_w || back_h!=target_h){
  if(target_picture)XRenderFreePicture(d,target_picture);
  if(backpix)XFreePixmap(d,backpix);
  backpix=XCreatePixmap(d,w,target_w,target_h,DefaultDepth(d,DefaultScreen(d)));
  target_picture=XRenderCreatePicture(d,backpix,XRenderFindVisualFormat(d,DefaultVisual(d,DefaultScreen(d))),0,nullptr);
  back_w=target_w;back_h=target_h;
 }

 double scale=std::min((double)target_w/im->width,(double)target_h/im->height);
 fitted_width=(int)(im->width*scale+0.5);fitted_h=(int)(im->height*scale+0.5);
 XTransform transform={{{XDoubleToFixed(1.0/scale),0,0},{0,XDoubleToFixed(1.0/scale),0},{0,0,XDoubleToFixed(1)}}};
 XRenderSetPictureTransform(d,source_picture,&transform);
}
static void events(){while(XPending(d)){
 XEvent e;XNextEvent(d,&e);if(e.type==ClientMessage && e.xclient.message_type==completion_marker){auto id=(unsigned long)e.xclient.data.l[0];completed=std::max(completed,id);auto now=std::chrono::steady_clock::now();while(!pending.empty() && pending.front().first<=id){if(completion_delays.size()>=4096)completion_delays.pop_front();completion_delays.push_back(std::chrono::duration<double>(now-pending.front().second).count());pending.pop_front();}continue;}if(e.type==completion_type){auto*c=(XShmCompletionEvent*)&e;if(c->shmseg==sh.shmseg)busy[0]=false;if(c->shmseg==alt_sh.shmseg)busy[1]=false;continue;}
 if(e.type==ClientMessage && (Atom)e.xclient.data.l[0]==wm_delete)last_key=27;
 if(e.type==KeyPress){KeySym key=XLookupKeysym(&e.xkey,0);if(key==XK_Escape)last_key=27;else if(key>=32&&key<=126)last_key=(int)key;}
 if(e.type==ConfigureNotify && e.xconfigure.width>0 && e.xconfigure.height>0){target_w=e.xconfigure.width;target_h=e.xconfigure.height;if(im&&source_picture)fit();}
}}
extern "C" void nd_drain(){if(d){XSync(d,False);events();}}
extern "C" int nd_poll(){if(!d)return -1;events();int key=last_key;last_key=-1;return key;}
extern "C" void nd_fullscreen(int enabled){if(!d)return;XEvent monitor={};monitor.type=ClientMessage;monitor.xclient.window=w;monitor.xclient.message_type=XInternAtom(d,"_NET_WM_FULLSCREEN_MONITORS",False);monitor.xclient.format=32;monitor.xclient.data.l[4]=1;XSendEvent(d,DefaultRootWindow(d),False,SubstructureNotifyMask|SubstructureRedirectMask,&monitor);XEvent e={};e.type=ClientMessage;e.xclient.window=w;e.xclient.message_type=XInternAtom(d,"_NET_WM_STATE",False);e.xclient.format=32;e.xclient.data.l[0]=enabled?1:0;e.xclient.data.l[1]=XInternAtom(d,"_NET_WM_STATE_FULLSCREEN",False);XSendEvent(d,DefaultRootWindow(d),False,SubstructureNotifyMask|SubstructureRedirectMask,&e);XFlush(d);}
extern "C" int nd_open(int width,int height){if(d)nd_close();submitted=completed=max_pending=0;pending.clear();completion_delays.clear();sh={};sh.shmid=-1;alt_sh={};alt_sh.shmid=-1;target_w=1280;target_h=720;d=XOpenDisplay(nullptr);if(!d)return -1;int s=DefaultScreen(d);if(!XShmQueryExtension(d)){nd_close();return -2;}Visual*v=DefaultVisual(d,s);if(v->red_mask!=0xff0000||v->green_mask!=0xff00||v->blue_mask!=0xff){nd_close();return -3;}int event_base,error_base;if(!XRenderQueryExtension(d,&event_base,&error_base)){nd_close();return -8;}w=XCreateSimpleWindow(d,RootWindow(d,s),0,0,1280,720,0,0,0);XStoreName(d,w,"Smart Traffic");unsigned long monitors[4]={0,0,0,0};XChangeProperty(d,w,XInternAtom(d,"_NET_WM_FULLSCREEN_MONITORS",False),XA_CARDINAL,32,PropModeReplace,(unsigned char*)monitors,4);Atom fs=XInternAtom(d,"_NET_WM_STATE_FULLSCREEN",False),state=XInternAtom(d,"_NET_WM_STATE",False);XChangeProperty(d,w,state,XA_ATOM,32,PropModeReplace,(unsigned char*)&fs,1);XSelectInput(d,w,KeyPressMask|StructureNotifyMask|ExposureMask);completion_marker=XInternAtom(d,"ADAS_RENDER_COMPLETED",False);wm_delete=XInternAtom(d,"WM_DELETE_WINDOW",False);XSetWMProtocols(d,w,&wm_delete,1);gc=DefaultGC(d,s);im=XShmCreateImage(d,v,DefaultDepth(d,s),ZPixmap,nullptr,&sh,width,height);if(!im||im->bits_per_pixel!=32){nd_close();return -4;}sh.shmid=shmget(IPC_PRIVATE,im->bytes_per_line*height,IPC_CREAT|0600);if(sh.shmid<0){nd_close();return -5;}sh.shmaddr=(char*)shmat(sh.shmid,nullptr,0);if(sh.shmaddr==(char*)-1){nd_close();return -6;}sh.readOnly=False;im->data=sh.shmaddr;if(!XShmAttach(d,&sh)){nd_close();return -7;}attached=true;completion_type=XShmGetEventBase(d)+ShmCompletion;alt_im=XShmCreateImage(d,v,DefaultDepth(d,s),ZPixmap,nullptr,&alt_sh,width,height);if(!alt_im){nd_close();return -9;}alt_sh.shmid=shmget(IPC_PRIVATE,alt_im->bytes_per_line*height,IPC_CREAT|0600);if(alt_sh.shmid<0){nd_close();return -10;}alt_sh.shmaddr=(char*)shmat(alt_sh.shmid,nullptr,0);if(alt_sh.shmaddr==(char*)-1){nd_close();return -11;}alt_sh.readOnly=False;alt_im->data=alt_sh.shmaddr;if(!XShmAttach(d,&alt_sh)){nd_close();return -12;}alt_attached=true;XSync(d,False);shmctl(alt_sh.shmid,IPC_RMID,nullptr);shmctl(sh.shmid,IPC_RMID,nullptr);pix=XCreatePixmap(d,w,width,height,DefaultDepth(d,s));auto format=XRenderFindVisualFormat(d,v);source_picture=XRenderCreatePicture(d,pix,format,0,nullptr);fit();XRenderSetPictureFilter(d,source_picture,FilterBilinear,nullptr,0);XMapRaised(d,w);XSync(d,False);return 0;}
extern "C" int nd_show(unsigned char*src,int width,int height,int stride){if(!d||!im||width!=im->width||height!=im->height)return -1;events();if(submitted-completed>=2){XSync(d,False);events();if(submitted-completed>=2)return -13;}int slot=next_slot;next_slot=1-next_slot;if(busy[slot]){XSync(d,False);events();busy[0]=busy[1]=false;}XImage*upload=slot?alt_im:im;cv::Mat bgr(height,width,CV_8UC3,src,stride),bgra(height,width,CV_8UC4,upload->data,upload->bytes_per_line);auto t=std::chrono::steady_clock::now();cv::cvtColor(bgr,bgra,cv::COLOR_BGR2BGRA);auto u=std::chrono::steady_clock::now();costs[0]=std::chrono::duration<double>(u-t).count();XShmPutImage(d,pix,gc,upload,0,0,0,0,width,height,True);busy[slot]=true;XRenderColor black={0,0,0,65535};XRenderFillRectangle(d,PictOpSrc,target_picture,&black,0,0,target_w,target_h);XRenderComposite(d,PictOpSrc,source_picture,None,target_picture,0,0,0,0,(target_w-fitted_width)/2,(target_h-fitted_h)/2,fitted_width,fitted_h);XCopyArea(d,backpix,w,gc,0,0,target_w,target_h,0,0);XEvent mark={};mark.xclient.type=ClientMessage;mark.xclient.display=d;mark.xclient.window=w;mark.xclient.message_type=completion_marker;mark.xclient.format=32;mark.xclient.data.l[0]=++submitted;pending.push_back({submitted,t});max_pending=std::max(max_pending,submitted-completed);XSendEvent(d,w,False,NoEventMask,&mark);XFlush(d);costs[1]=std::chrono::duration<double>(std::chrono::steady_clock::now()-u).count();events();return 0;}


extern "C" unsigned long nd_pixel(int x,int y){XImage*snap=XGetImage(d,w,x,y,1,1,AllPlanes,ZPixmap);if(!snap)return 0xffffffff;auto p=XGetPixel(snap,0,0);XDestroyImage(snap);return p;}
