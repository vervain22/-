CXX ?= g++
CXXFLAGS ?= -O2 -std=c++17 -fPIC
OUT := ../lib
OPENCV := $(shell pkg-config --cflags --libs opencv4)
all: $(OUT)/bounded_display.so $(OUT)/libnative_canvas.so $(OUT)/native_decode.so $(OUT)/native_fd.so $(OUT)/reference_runtime.so
$(OUT):
	mkdir -p $@
$(OUT)/bounded_display.so: native_display.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared $< -o $@ $(OPENCV) -lX11 -lXext -lXrender
$(OUT)/libnative_canvas.so: native_canvas.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared $< -o $@
$(OUT)/native_decode.so: native_decode.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared $< -o $@
$(OUT)/native_fd.so: native_fd.cpp native_decode.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared $< -o $@
$(OUT)/reference_runtime.so: reference/adapter.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -shared -Ireference/includes -Ireference/sources $< -o $@ $(OPENCV) -L$(OUT) -lrknnrt -Wl,-rpath,'$$ORIGIN'
.PHONY: all
