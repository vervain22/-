
#include "../includes/pcie_dma_read_test.h"
#include <iostream>
#include <chrono>
#include <cstdint>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cerrno>
#include <sys/stat.h>
#include <vector>
#include <opencv2/opencv.hpp>
using namespace std;





//=========================================================================
// 函数声明
//=========================================================================
int open_pci_driver(void);
void cmd_operation(int fd, unsigned char cmd, COMMAND_OPERATION *cmd_op);
int nano_delay(long delay);
void rgb565_to_rgb888(const uint16_t* image565, uint8_t* image888, size_t num_pixels);
void rgb565_to_bgr888(const uint16_t* image565, uint8_t* image888, size_t num_pixels);
bool wait_for_frame_flag(int fd, IMAGE_OPERATION& ready_frame);
bool write_bgr_raw_frame(const cv::Mat& img);
bool write_bgr_raw_frame_from_rgb565(const uint16_t* image565);
bool write_rgb565_raw_frame_from_rgb565(const uint16_t* image565);
int read_positive_env(const char* name, int fallback);
int read_nonnegative_env(const char* name, int fallback);


//=========================================================================
// 全局变量定义
//=========================================================================
int pci_driver_fd;
COMMAND_OPERATION command_operation;

DMA_OPERATION dma_operation;  //读写之前需操作这个结构体设置好对应的参数
IMAGE_OPERATION image_operation;
uint8_t* image_buf_temp = (uint8_t*)malloc(IMAGE_WIDTH * IMAGE_HEIGHT * 2);
uint8_t* image_buf_888 = (uint8_t*)malloc(IMAGE_WIDTH * IMAGE_HEIGHT * 3);


static const char* NPU_FRAME_PATH = "/dev/shm/fpga_current_frame.jpg";
static const char* NPU_FRAME_TMP_PATH = "/dev/shm/fpga_current_frame.tmp.jpg";
static const char* NPU_FRAME_DIR = "/dev/shm";
static const char* NPU_RAW_FRAME_PATH = "/dev/shm/fpga_current_frame_1280x720.rgb565";
static const char* NPU_RAW_FRAME_TMP_PATH = "/dev/shm/fpga_current_frame_1280x720.tmp.rgb565";
static const int NPU_RAW_WIDTH = 1280;
static const int NPU_RAW_HEIGHT = 720;
static int npu_frame_save_interval = 30;  // Keep low-rate JPEG output for debugging/fallback.
static int npu_raw_save_interval = 1;     // Raw RGB565 output for the NPU script. Use env to tune.
static int frame_settle_us = 0;           // FPGA now emits stable full frames; keep this at 0 for FPS.
/**************************************************************************
** 函数名称:    open_pci_driver
** 函数功能:    打开pcie驱动文件
** 输入参数:    无
** 输出参数:    无
** 返回参数:    文件描述符
****************************************************************************/
int open_pci_driver(void)
{
	int fd;
	
	fd = open(PCIE_DRIVER_FILE_PATH, O_RDWR);
	
	if(fd < 0)
	{
		perror("open fail\n");
		return -1;
	}
	return fd;
}

/**************************************************************************
** 函数名称:    cmd_operation
** 函数功能:    命令解析函数
** 输入参数:    fd:驱动文件描述符
**			cmd:操作指令
**			*cmd_op:相关信息和数据结构体
** 输出参数:    无
** 返回参数:    无
****************************************************************************/
void cmd_operation(int fd, unsigned char cmd, COMMAND_OPERATION *cmd_op)
{
	unsigned int w_data = 0;
	unsigned int r_data = 0;
	unsigned int i = 0;
	unsigned int j = 0;
	unsigned int cnt = 0;
	unsigned long temp_bar_len;
	int value = 0;
	char pci_info[20][20];
	char unit[5][10] = {"B", "KB", "MB", "GB", "TB"};
	void *vaddr1, *vaddr2;
	switch(cmd)
	{
		case info_num:
			cmd_op->delay = 0;
			read(fd, cmd_op, sizeof(COMMAND_OPERATION));								/* 读取pcie信息 */
			sprintf(pci_info[cnt++], "%04x", cmd_op->get_pci_dev_info.vendor_id);
			sprintf(pci_info[cnt++], "%04x", cmd_op->get_pci_dev_info.device_id);
			if(cmd_op->cap_info.cap_status == 1)
			{
				strcpy(pci_info[cnt++],  "Up");
				printf("PCIe link successful\n");
				printf("PCIe link successful\n");
			}
			else
			{
				strcpy(pci_info[cnt++],  "Down");
				printf("PCIe link failure !!!\n");
				printf("PCIe link failure !!!\n");
			}
			sprintf(pci_info[cnt++], "Gen%x", cmd_op->get_pci_dev_info.link_speed);
			sprintf(pci_info[cnt++], "x%x", cmd_op->get_pci_dev_info.link_width);
			strcpy(pci_info[cnt++],  "No");
			for(i = 0; i <= 5; i++)
			{
				sprintf(pci_info[cnt++], "%08lx", cmd_op->get_pci_dev_info.bar[i].bar_base);
			}
			for(i = 0; i <= 5; i++)
			{
				value = 0;
				temp_bar_len = cmd_op->get_pci_dev_info.bar[i].bar_len;
				while(temp_bar_len >= 1024)
				{
					temp_bar_len = temp_bar_len / 1024;
					value++;
				}
				sprintf(pci_info[cnt++], "%lu%s", temp_bar_len, unit[value]);
			}
			sprintf(pci_info[cnt++], "%d", cmd_op->get_pci_dev_info.mps);
			sprintf(pci_info[cnt++], "%d", cmd_op->get_pci_dev_info.mrrs);
			
		break;

		
		case performance_num:
		
		break;
		default:
		break;
	}

}
/**************************************************************************
** 函数名称:    nano_delay
** 函数功能:纳秒延时
** 输入参数:delay：延时长度
** 输出参数:    无
** 返回参数:    无
****************************************************************************/
int nano_delay(long delay)
{
    struct timespec req, rem;
    long nano_delay = delay;
    int ret = 0;
    while(nano_delay > 0)
    {
        rem.tv_sec = 0;
        rem.tv_nsec = 0;
        req.tv_sec = 0;
        req.tv_nsec = nano_delay;
        if(ret = (nanosleep(&req, &rem) == -1))
        {
            printf("nanosleep failed !!!\n");                
        }
        nano_delay = rem.tv_nsec;
    };
    
    return ret;
}


/**************************************************************************
** 函数名称:rgb565_to_rgb888
** 函数功能:将rgb565图像转为rgb888图像
** 输入参数:
** 输出参数:    无
** 返回参数:    无
****************************************************************************/

void rgb565_to_rgb888(const uint16_t* image565, uint8_t* image888, size_t num_pixels) {
    for (size_t i = 0; i < num_pixels; ++i) {
        uint16_t pixel = image565[i];
        uint8_t r = ((pixel >> 11) & 0x1F) << 3;
        uint8_t g = ((pixel >> 5 ) & 0x3F) << 2;
        uint8_t b = (pixel & 0x1F) << 3;

        image888[3*i]     = r;
        image888[3*i + 1] = g;
        image888[3*i + 2] = b;
    }
}

void rgb565_to_bgr888(const uint16_t* image565, uint8_t* image888, size_t num_pixels) {
    for (size_t i = 0; i < num_pixels; ++i) {
        uint16_t pixel = image565[i];
        uint8_t r = ((pixel >> 11) & 0x1F) << 3;
        uint8_t g = ((pixel >> 5 ) & 0x3F) << 2;
        uint8_t b = (pixel & 0x1F) << 3;

        image888[3*i]     = b;
        image888[3*i + 1] = g;
        image888[3*i + 2] = r;
    }
}

bool write_bgr_raw_frame(const cv::Mat& img) {
    if (img.cols != IMAGE_WIDTH || img.rows != IMAGE_HEIGHT ||
        img.type() != CV_8UC3 || !img.isContinuous()) {
        return false;
    }
    FILE* fp = std::fopen(NPU_RAW_FRAME_TMP_PATH, "wb");
    if (!fp) {
        return false;
    }

    const size_t bytes = img.total() * img.elemSize();
    const size_t written = std::fwrite(img.data, 1, bytes, fp);
    std::fclose(fp);

    if (written != bytes) {
        return false;
    }
    return std::rename(NPU_RAW_FRAME_TMP_PATH, NPU_RAW_FRAME_PATH) == 0;
}

bool write_bgr_raw_frame_from_rgb565(const uint16_t* image565) {
    static std::vector<uint8_t> raw_buf(NPU_RAW_WIDTH * NPU_RAW_HEIGHT * 3);

    for (int y = 0; y < IMAGE_HEIGHT; ++y) {
        const uint16_t* src_row = image565 + y * IMAGE_WIDTH;
        uint8_t* dst = raw_buf.data() + y * NPU_RAW_WIDTH * 3;
        for (int x = 0; x < IMAGE_WIDTH; ++x) {
            uint16_t pixel = src_row[x];
            uint8_t r = ((pixel >> 11) & 0x1F) << 3;
            uint8_t g = ((pixel >> 5) & 0x3F) << 2;
            uint8_t b = (pixel & 0x1F) << 3;
            dst[3 * x] = b;
            dst[3 * x + 1] = g;
            dst[3 * x + 2] = r;
        }
    }

    FILE* fp = std::fopen(NPU_RAW_FRAME_TMP_PATH, "wb");
    if (!fp) {
        return false;
    }

    const size_t bytes = raw_buf.size();
    const size_t written = std::fwrite(raw_buf.data(), 1, bytes, fp);
    std::fclose(fp);

    if (written != bytes) {
        return false;
    }
    return std::rename(NPU_RAW_FRAME_TMP_PATH, NPU_RAW_FRAME_PATH) == 0;
}


bool write_rgb565_raw_frame_from_rgb565(const uint16_t* image565) {
    FILE* fp = std::fopen(NPU_RAW_FRAME_TMP_PATH, "wb");
    if (!fp) {
        return false;
    }

    const size_t bytes = IMAGE_BYTES;
    const size_t written = std::fwrite(image565, 1, bytes, fp);
    std::fclose(fp);

    if (written != bytes) {
        return false;
    }
    return std::rename(NPU_RAW_FRAME_TMP_PATH, NPU_RAW_FRAME_PATH) == 0;
}

int read_positive_env(const char* name, int fallback) {
    const char* value = getenv(name);
    if (!value || value[0] == '\0') {
        return fallback;
    }

    int parsed = atoi(value);
    return parsed > 0 ? parsed : fallback;
}

int read_nonnegative_env(const char* name, int fallback) {
    const char* value = getenv(name);
    if (!value || value[0] == '\0') {
        return fallback;
    }

    int parsed = atoi(value);
    return parsed >= 0 ? parsed : fallback;
}


bool wait_for_frame_flag(int fd, IMAGE_OPERATION& ready_frame) {
    IMAGE_OPERATION op;
    memset(&op, 0, sizeof(op));

    // Bound the wait by elapsed time, not an arbitrary poll count.  A freshly
    // started stream must wait for a source frame, DDR and PCIe transmission.
    const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(2);
    while (std::chrono::steady_clock::now() < deadline) {
        if (ioctl(fd, PCI_GET_IMAGE_FLAG_CMD, &op) < 0) {
            perror("PCI_GET_IMAGE_FLAG_CMD failed");
            return false;
        }

        if (op.frame_flag != 0 &&
            (op.frame_flag & IMAGE_FRAME_FLAG_MASK) != IMAGE_FRAME_FLAG_MAGIC) {
            return false;
        }

        if (op.frame_flag != 0 && op.slot < 2 &&
            (((op.frame_flag & IMAGE_FRAME_SLOT_MASK) != 0) == (op.slot != 0))) {
            ready_frame = op;
            return true;
        }

        usleep(100);
    }

    fprintf(stderr, "wait frame flag timeout\n");
    return false;
}



int main(void) {
    pci_driver_fd = open_pci_driver();
    if (pci_driver_fd < 0) {
        printf("PCIe Device Open Fail !!!\n");
        return -1;
    }

    if (!image_buf_temp || !image_buf_888) {
        fprintf(stderr, "image buffer malloc failed\n");
        close(pci_driver_fd);
        return -1;
    }
    mkdir(NPU_FRAME_DIR, 0755);

    uint16_t* image_buf = reinterpret_cast<uint16_t*>(image_buf_temp);
    cmd_operation(pci_driver_fd, info_num, &command_operation);
    printf("The tandem load base address is [ Bar0 ]\n");

    char input[10];
    bool continuous_capture = false;
    bool dma_mapped = false;
    unsigned int last_frame_flag = 0;
    unsigned int last_frame_slot = 0;
    bool show_window = false;
    const char* show_env = getenv("PCIE_SHOW_WINDOW");
    if (show_env && strcmp(show_env, "1") == 0) {
        show_window = true;
    }
    npu_raw_save_interval = read_positive_env("PCIE_NPU_RAW_INTERVAL", npu_raw_save_interval);
    npu_frame_save_interval = read_positive_env("PCIE_NPU_JPG_INTERVAL", npu_frame_save_interval);
    frame_settle_us = read_nonnegative_env("PCIE_FRAME_SETTLE_US", frame_settle_us);
    const int max_frames = read_nonnegative_env("PCIE_MAX_FRAMES", 0);
    printf("NPU raw output interval: %d frame(s), JPG interval: %d frame(s), frame settle: %d us, max frames: %d\n",
           npu_raw_save_interval, npu_frame_save_interval, frame_settle_us, max_frames);

    if (show_window) {
        cv::namedWindow("Converted Image", cv::WINDOW_NORMAL);
        cv::resizeWindow("Converted Image", 800, 600);
    }

    int frame_count = 0;
    unsigned long saved_frame_count = 0;
    double total_time = 0.0;
    auto start_time = std::chrono::high_resolution_clock::now();
    auto last_print_time = start_time;

    while (1) {
        if (!continuous_capture) {
            printf("input y to start continuous capture, q to quit: ");
            if (fgets(input, sizeof(input), stdin) == NULL) {
                printf("\nstdin closed, exiting capture loop.\n");
                break;
            }
            input[strcspn(input, "\n")] = '\0';

            if (strcmp(input, "y") == 0) {
                memset(&dma_operation, 0, sizeof(dma_operation));
                dma_operation.current_len = IMAGE_DMA_DWORDS;
                dma_operation.offset_addr = 0;

                if (ioctl(pci_driver_fd, PCI_MAP_ADDR_CMD, &dma_operation) < 0) {
                    perror("PCI_MAP_ADDR_CMD failed");
                    continue;
                }
                dma_mapped = true;

                if (ioctl(pci_driver_fd, PCI_DMA_WRITE_ADDR_CMD, &dma_operation) < 0) {
                    perror("PCI_DMA_WRITE_ADDR_CMD failed");
                    ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
                    dma_mapped = false;
                    continue;
                }

                if (ioctl(pci_driver_fd, PCI_IMAGE_TRANS_FLAG, &dma_operation) < 0) {
                    perror("PCI_IMAGE_TRANS_FLAG failed");
                    ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
                    dma_mapped = false;
                    continue;
                }

                last_frame_flag = 0;
                last_frame_slot = 0;
                continuous_capture = true;
                frame_count = 0;
                total_time = 0.0;
                start_time = std::chrono::high_resolution_clock::now();
                last_print_time = start_time;
                printf("FPGA active image transfer started\n");
            } else if (strcmp(input, "q") == 0) {
                break;
            }
            continue;
        }

        auto frame_start = std::chrono::high_resolution_clock::now();

        IMAGE_OPERATION ready_frame;
        memset(&ready_frame, 0, sizeof(ready_frame));
        if (!wait_for_frame_flag(pci_driver_fd, ready_frame)) {
            fprintf(stderr, "frame flag timeout, stop reading this frame\n");
            ioctl(pci_driver_fd, PCI_IMAGE_STOP_FLAG, &dma_operation);
            continuous_capture = false;
            continue;
        }
        if (frame_settle_us > 0) {
            usleep(frame_settle_us);
        }

        image_operation = ready_frame;
        image_operation.user_buf = (unsigned long)image_buf_temp;
        image_operation.bytes = IMAGE_BYTES;
        if (ioctl(pci_driver_fd, PCI_READ_IMAGE_FROM_KERNEL_CMD, &image_operation) < 0) {
            if (errno == EAGAIN)
                continue;
            perror("PCI_READ_IMAGE_FROM_KERNEL_CMD failed");
            ioctl(pci_driver_fd, PCI_IMAGE_STOP_FLAG, &dma_operation);
            if (dma_mapped) {
                ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
                dma_mapped = false;
            }
            continuous_capture = false;
            continue;
        }
        last_frame_flag = image_operation.frame_flag;
        last_frame_slot = image_operation.slot;

        if (npu_raw_save_interval > 0 &&
            (saved_frame_count % npu_raw_save_interval) == 0) {
            write_rgb565_raw_frame_from_rgb565(image_buf);
        }
        if (show_window || (npu_frame_save_interval > 0 &&
            (saved_frame_count % npu_frame_save_interval) == 0)) {
            rgb565_to_bgr888(image_buf, image_buf_888, IMAGE_WIDTH * IMAGE_HEIGHT);
            cv::Mat img(IMAGE_HEIGHT, IMAGE_WIDTH, CV_8UC3, image_buf_888);
            if (show_window) {
                cv::imshow("Converted Image", img);
            }
            if (npu_frame_save_interval > 0 &&
                (saved_frame_count % npu_frame_save_interval) == 0 &&
                cv::imwrite(NPU_FRAME_TMP_PATH, img)) {
                std::rename(NPU_FRAME_TMP_PATH, NPU_FRAME_PATH);
            }
        }
        saved_frame_count++;

        // A bounded run is useful for bring-up and guarantees that the host
        // sends the normal stop/ACK sequence before the process exits.  The
        // default remains unlimited (0), so normal capture frame rate is
        // unchanged.
        if (max_frames > 0 && saved_frame_count >= (unsigned long)max_frames) {
            ioctl(pci_driver_fd, PCI_IMAGE_STOP_FLAG, &dma_operation);
            if (dma_mapped) {
                ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
                dma_mapped = false;
            }
            continuous_capture = false;
            printf("\nreached PCIE_MAX_FRAMES=%d\n", max_frames);
            break;
        }

        auto frame_end = std::chrono::high_resolution_clock::now();
        double frame_time = std::chrono::duration<double>(frame_end - frame_start).count();
        total_time += frame_time;
        frame_count++;

        auto current_time = std::chrono::high_resolution_clock::now();
        if (std::chrono::duration<double>(current_time - last_print_time).count() >= 1.0) {
            double avg_fps = frame_count / total_time;
            double instant_fps = 1.0 / frame_time;
            printf("\ravg fps: %.2f | instant fps: %.2f | slot: %u | frame flag: 0x%08x",
                   avg_fps, instant_fps, last_frame_slot, last_frame_flag);
            fflush(stdout);
            frame_count = 0;
            total_time = 0.0;
            last_print_time = current_time;
        }

        if (show_window) {
            int key = cv::waitKey(1);
            if (key == 'q' || key == 'Q') {
                break;
            } else if (key == 's' || key == 'S') {
                ioctl(pci_driver_fd, PCI_IMAGE_STOP_FLAG, &dma_operation);
                if (dma_mapped) {
                    ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
                    dma_mapped = false;
                }
                continuous_capture = false;
                printf("\ncapture stopped\n");
            }
        }
    }

    if (dma_mapped) {
        ioctl(pci_driver_fd, PCI_IMAGE_STOP_FLAG, &dma_operation);
        ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);
    }

    cv::destroyAllWindows();
    close(pci_driver_fd);
    printf("\nExit main\n");
    return 0;
}

int old_line_by_line_main(void) {
    pci_driver_fd = open_pci_driver();
    uint16_t* image_buf = reinterpret_cast<uint16_t*>(image_buf_temp);
    if (pci_driver_fd) {
        cmd_operation(pci_driver_fd, info_num, &command_operation);
        printf("The tandem load base address is [ Bar0 ]\n");
    } else {
        printf("PCIe Device Open Fail !!!\n");
        return -1;
    }

    char input[10];
    bool continuous_capture = false;
    cv::namedWindow("Converted Image", cv::WINDOW_NORMAL);
    cv::resizeWindow("Converted Image", 800, 600);

    // 帧率计算相关变量
    int frame_count = 0;
    double total_time = 0.0;
    auto start_time = std::chrono::high_resolution_clock::now();
    auto last_print_time = start_time;

    while (1) {
        if (!continuous_capture) {
            printf("输入y开始连续采集，q退出: ");
            if (fgets(input, sizeof(input), stdin) == NULL) {
                printf("\nstdin closed, exiting capture loop.\n");
                break;
            }
            input[strcspn(input, "\n")] = '\0';
            
            if (strcmp(input, "y") == 0) {
                continuous_capture = true;
                // 重置帧率计数器
                frame_count = 0;
                total_time = 0.0;
                start_time = std::chrono::high_resolution_clock::now();
                last_print_time = start_time;
            } else if (strcmp(input, "q") == 0) {
                break;
            }
            continue;
        }

        auto frame_start = std::chrono::high_resolution_clock::now();

        // 连续采集模式
        dma_operation.current_len = (IMAGE_WIDTH * 2) / 4;
        dma_operation.offset_addr = 0;
        memset(dma_operation.data.write_buf, 0, DMA_MAX_PACKET_SIZE);
        memset(dma_operation.data.read_buf, 0, DMA_MAX_PACKET_SIZE);
        
        ioctl(pci_driver_fd, PCI_MAP_ADDR_CMD, &dma_operation);
        for (int i = 0; i < IMAGE_HEIGHT; i++) {
            memset(dma_operation.data.read_buf, 0, DMA_MAX_PACKET_SIZE);
            ioctl(pci_driver_fd, PCI_DMA_WRITE_CMD, &dma_operation);
            //nano_delay(1000);
			for (int k = 0;k<5000;k++);
            ioctl(pci_driver_fd, PCI_READ_FROM_KERNEL_CMD, &dma_operation);
            memcpy(image_buf_temp + i * IMAGE_WIDTH * 2,
                   dma_operation.data.read_buf, IMAGE_WIDTH * 2);
        }
        // 计算帧时间
        auto frame_end = std::chrono::high_resolution_clock::now();
        double frame_time = std::chrono::duration<double>(frame_end - frame_start).count();
        total_time += frame_time;
        frame_count++;
        ioctl(pci_driver_fd, PCI_UMAP_ADDR_CMD, &dma_operation);

        rgb565_to_rgb888(image_buf, image_buf_888, IMAGE_WIDTH * IMAGE_HEIGHT);
        
        cv::Mat img(IMAGE_HEIGHT, IMAGE_WIDTH, CV_8UC3, image_buf_888);
        cv::cvtColor(img, img, cv::COLOR_RGB2BGR);
        cv::imshow("Converted Image", img);

        

        // 每1秒打印一次帧率信息
        auto current_time = std::chrono::high_resolution_clock::now();
        if (std::chrono::duration<double>(current_time - last_print_time).count() >= 1.0) {
            double avg_fps = frame_count / total_time;
            double instant_fps = 1.0 / frame_time;
            
            printf("\r平均帧率: %.2f FPS | 瞬时帧率: %.2f FPS | 总帧数: %d", 
                  avg_fps, instant_fps, frame_count);
            fflush(stdout);  // 立即刷新输出
            
            // 重置统计周期
            frame_count = 0;
            total_time = 0.0;
            last_print_time = current_time;
        }

        // 检查按键（10ms超时）
        int key = cv::waitKey(10);
        if (key == 'q' || key == 'Q') {
            break;
        } else if (key == 's' || key == 'S') {  // 可添加暂停功能
            continuous_capture = false;
            printf("\n采集已暂停\n");
        }
    }

    cv::destroyAllWindows();
    close(pci_driver_fd);
    printf("\nExit main\n");
    return 0;
}
