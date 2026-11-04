#include <cstdint>
#include <cstddef>
// No global frame storage: every call writes only its caller-owned outputs.
static uint16_t word(const uint8_t* p, size_t i) {
    return uint16_t(p[i*2]) | (uint16_t(p[i*2+1])<<8);
}
static void bgr(uint16_t v,uint8_t* out) {
    out[0]=uint8_t((v&31)<<3);out[1]=uint8_t(((v>>5)&63)<<2);out[2]=uint8_t((v>>11)<<3);
}
extern "C" int decode_bgr(const uint8_t* raw,size_t n,uint8_t* hdmi,
 uint8_t* camera,uint16_t* counts,uint8_t* features,uint32_t* identity) {
    constexpr size_t W=640,H=360,N=W*H,C=W*180;
    if(n!=1280*720*2)return 1;
    auto color=[&](size_t i){return word(raw,2*i+1);};
    const auto version=color(C+1);
    if(color(C)!=0xcf61 || (version!=1 && version!=2))return 2;
    const uint32_t fid=uint32_t(color(C+2))|(uint32_t(color(C+3))<<16);
    if(color(C+4)!=W || color(C+5)!=180)return 3;
    if(color(N-4)!=0x61cf || color(N-3)!=(fid&65535) || color(N-2)!=(fid>>16) || color(N-1)!=0xa55a)return 4;
    for(size_t i=0;i<N;++i) {
        uint16_t c=color(i);
        const bool metadata=(i>=C && i<C+6) || i>=N-4;
        if(!metadata && (c>>12)!=((fid>>((i%8)*4))&15))return 5;
        if(i<C) {
            unsigned r=c&15,g=(c>>4)&15,b=(c>>8)&15;
            if(r>9 || g>9 || b>9 || r+g+b>9)return 6;
            counts[i*3]=uint8_t(r);counts[i*3+1]=uint8_t(g);counts[i*3+2]=uint8_t(b);
        }
        uint8_t f=0;
        if(version==2 && i>=C && !metadata) {
            unsigned low=c&4095;
            if(low>7)return 7;
            if((i%W<13 || i%W>=W-13) && low)return 8;
            f=uint8_t(low);
        }
        features[i]=f;
        bgr(word(raw,2*i),hdmi+i*3);
        bgr(word(raw,360*1280+(i/W)*1280+i%W),camera+i*3);
    }
    *identity=fid;
    return version==1?100:0;
}
