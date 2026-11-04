#include <cstring>
#include <cstdint>
extern "C" int canvas_fill(unsigned char*out,int out_stride,
 const unsigned char*hdmi,int hdmi_stride,const unsigned char*camera,int camera_stride){
 if(!out||out_stride<1280*3||(hdmi&&hdmi_stride<640*3)||(camera&&camera_stride<640*3))return -1;
 for(int channel=0;channel<2;++channel){
  const unsigned char*src=channel?camera:hdmi;int stride=channel?camera_stride:hdmi_stride;
  for(int y=0;y<360;++y){
   unsigned char*row=out+(channel*360+y)*out_stride;
   if(src){std::memcpy(row,src+y*stride,640*3);std::memcpy(row+640*3,row,640*3);}
   else std::memset(row,0,1280*3);
  }
 }
 for(int y=720;y<816;++y)std::memset(out+y*out_stride,0,1280*3);
 return 0;
}
