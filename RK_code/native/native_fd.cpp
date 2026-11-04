#include "native_decode.cpp"
#include <array>
#include <unistd.h>
#include <sys/stat.h>
#include <cerrno>
extern "C" int decode_fd(int fd,uint8_t* hdmi,uint8_t* camera,
 uint16_t* counts,uint8_t* features,uint32_t* identity) {
    constexpr size_t size=1280*720*2;
    struct stat st;
    if(fstat(fd,&st)<0)return 9;
    if(st.st_size!=size)return 1;
    if(lseek(fd,0,SEEK_SET)<0)return 9;
    // Private to the calling thread; raw storage is never published to readers.
    static thread_local std::array<uint8_t,size> storage;
    size_t offset=0;
    while(offset<size) {
        auto n=read(fd,storage.data()+offset,size-offset);
        if(n<0 && errno==EINTR)continue;
        if(n<0)return 9;
        if(n==0)return 1;
        offset+=size_t(n);
    }
    return decode_bgr(storage.data(),size,hdmi,camera,counts,features,identity);
}
