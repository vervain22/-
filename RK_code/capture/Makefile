
# 生成可执行文件的名称
Target = app
# 编译器改为g++
CXX = g++
# 存放中间文件的路径
build_dir = build
# 存放源文件的文件夹
src_dir = sources
# 存放头文件的文件夹
inc_dir = includes

# 源文件（*.cpp）
sources = $(foreach dir,$(src_dir),$(wildcard $(dir)/*.cpp))
# 目标文件（*.o）
objects = $(patsubst %.cpp,$(build_dir)/%.o,$(notdir $(sources)))
# 头文件
includes = $(foreach dir,$(inc_dir),$(wildcard $(dir)/*.h))

# 编译参数
# 指定头文件的路径
CXXFLAGS = $(patsubst %, -I%, $(inc_dir))

# 获取 GTK+ 2.0 和 OpenCV 的编译标志和链接库

GTK_CFLAGS = $(shell pkg-config --cflags gtk+-2.0 gmodule-export-2.0)
GTK_LIBS = $(shell pkg-config --libs gtk+-2.0 gmodule-export-2.0)
OPENCV_CFLAGS = $(shell pkg-config --cflags opencv4 2>/dev/null || pkg-config --cflags opencv)
OPENCV_LIBS = $(shell pkg-config --libs opencv4 2>/dev/null || pkg-config --libs opencv)

# 合并所有编译标志和链接库
CXXFLAGS += $(GTK_CFLAGS) $(OPENCV_CFLAGS)
LDFLAGS = $(GTK_LIBS) $(OPENCV_LIBS)

# 链接过程

$(build_dir)/$(Target) : $(objects) | create_build
	$(CXX) $^ -o $@ $(LDFLAGS)

# 编译工程
$(build_dir)/%.o : $(src_dir)/%.cpp $(includes) | create_build
	$(CXX) -c $(CXXFLAGS) $< -o $@

# 伪目标
.PHONY: clean check create_build cp

# 清理构建目录
clean:
	rm -rf $(build_dir)

# 调试用：检查变量值
check:
	@echo "CXXFLAGS: $(CXXFLAGS)"
	@echo "LDFLAGS: $(LDFLAGS)"
	@echo "Current directory: $(CURDIR)"
	@echo "Source directory: $(src_dir)"
	@echo "Source files: $(sources)"
	@echo "Object files: $(objects)"

# 创建构建目录
create_build:
	@mkdir -p $(build_dir)

# 复制可执行文件到当前目录
cp:
	cp ./build/app ./
