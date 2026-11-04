#include <opencv2/opencv.hpp>
#include "ztu/cv.hpp"
#include "ztu/rk/ez_rknn.hpp"
#include "ztu/nn/yolov5_ztopt_3out_postprocess.hpp"
#include <memory>
#include <chrono>
static double stage_ms[4]={};
using ProfileClock=std::chrono::steady_clock;
extern "C" double reference_stage_ms(int i){return i>=0 && i<4?stage_ms[i]:-1;}
#include <string>
static std::unique_ptr<ztu::rk::EzRknn> net;
static std::string error;
static std::vector<float*> heads;
extern "C" const float* reference_head(int index){return index>=0 && index<static_cast<int>(heads.size())?heads[index]:nullptr;}
extern "C" const char* reference_error(){return error.c_str();}
extern "C" int reference_init(const char* model){
 try{net=std::make_unique<ztu::rk::EzRknn>(model,ztu::rk::EzRknn::Layout::CHW2HWC);return 0;}
 catch(const std::exception&e){error=e.what();net.reset();return -1;}
}
extern "C" void reference_close(){net.reset();}
extern "C" int reference_detect(unsigned char* bgr,int width,int height,float* out,int capacity){
 try{
  if(!net || !bgr || width!=640 || height!=360 || capacity<1)throw std::runtime_error("Invalid reference input");
  auto t0=ProfileClock::now();
  cv::Mat image(height,width,CV_8UC3,bgr);
  int mw=net->input_attrs[0].dims[2],mh=net->input_attrs[0].dims[1];
  auto param=ztu::cv::calculateResize(width,height,mw,mh);
  auto resized=ztu::cv::resize(image,param);cv::cvtColor(resized,resized,cv::COLOR_BGR2RGB);
  auto t1=ProfileClock::now();
  auto outputs=net->inference(resized.data);heads=outputs;ztu::nn::object_detect_result_list detections;
  auto t2=ProfileClock::now();
  ztu::nn::yolov5_ztopt_3out_postprocess::postprocess(const_cast<const float**>(outputs.data()),.25,.4,&detections,mw,mh,6);
  if(detections.results.size()>static_cast<size_t>(capacity))throw std::runtime_error("Reference output capacity exceeded");
  int count=0;
  for(const auto&d:detections.results){
   auto a=ztu::cv::reverseMapPoint(d.box.left,d.box.top,param),b=ztu::cv::reverseMapPoint(d.box.right,d.box.bottom,param);
   float* p=out+6*count++;p[0]=d.cls_id;p[1]=d.prop;p[2]=a.first;p[3]=a.second;p[4]=b.first;p[5]=b.second;
  }
  auto t3=ProfileClock::now();
  stage_ms[0]=std::chrono::duration<double,std::milli>(t1-t0).count();
  stage_ms[1]=std::chrono::duration<double,std::milli>(t2-t1).count();
  stage_ms[2]=std::chrono::duration<double,std::milli>(t3-t2).count();
  stage_ms[3]=std::chrono::duration<double,std::milli>(t3-t0).count();
  return count;
 }catch(const std::exception&e){error=e.what();return -1;}
}
