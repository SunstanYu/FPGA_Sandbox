///////////////////////////////////////
/// DE1-SoC Cellular Automata Sandbox Controller
/// 须与 DE1_SoC_Computer.v 中材质/画布分区一致:
///   MAT_SAND=1, MAT_WATER=2, MAT_WALL=3, MAT_FIRE=4, MAT_SMOKE=5
///   逻辑行 y < 200 为画布; y>=200 为底栏(五槽 Wall/Water/Sand/Fire/Smoke)
/// compile with:
/// gcc hps_control.c -o hps_control -O2
/// run with:
/// sudo ./hps_control
///////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>

// --- Lightweight AXI 桥基地址 ---
#define HW_REGS_BASE 0xff200000
#define HW_REGS_SPAN 0x00005000

// --- 严格匹配你在 Qsys 中的偏移地址 ---
#define BRUSH_WE_OFFSET  0x00000000
#define BRUSH_MAT_OFFSET 0x00000010
#define BRUSH_Y_OFFSET   0x00000020
#define BRUSH_X_OFFSET   0x00000030

// --- 物理引擎物质定义 (必须和 Verilog 一致) ---
#define MAT_EMPTY 0
#define MAT_SAND  1
#define MAT_WATER 2
#define MAT_WALL  3
#define MAT_FIRE  4
#define MAT_SMOKE 5

// 与 Verilog CANVAS_H 一致：底栏占网格 y=200..239
#define CANVAS_H 200

// 画笔大小 (正方形边长)
#define BRUSH_SIZE 4

const char *material_names[] = {
	"EMPTY (Eraser)", "SAND", "WATER", "WALL", "FIRE", "SMOKE"
};

// 底栏从左到右 5 槽对应材质 (与 VGA sel_tool 映射一致)
static const int toolbar_slot_mat[5] = {
	MAT_WALL, MAT_WATER, MAT_SAND, MAT_FIRE, MAT_SMOKE
};

// 全局 PIO 指针
volatile unsigned int *brush_we_ptr  = NULL;
volatile unsigned int *brush_mat_ptr = NULL;
volatile unsigned int *brush_y_ptr   = NULL;
volatile unsigned int *brush_x_ptr   = NULL;

// 同步“当前笔刷”到 FPGA，底栏选中高亮依赖 brush_mat 输出
static void fpga_set_brush_material(unsigned int mat) {
	*brush_mat_ptr = mat;
}

// 将物质块写入 FPGA (支持一次性画一个方块)
void paint_to_fpga(int cx, int cy, int material)
{
	int half = BRUSH_SIZE / 2;
	int x, y;
	for (y = cy - half; y <= cy + half; y++) {
		for (x = cx - half; x <= cx + half; x++) {
			if (x >= 0 && x < 320 && y >= 0 && y < CANVAS_H) {
				*(brush_x_ptr)   = (unsigned int)x;
				*(brush_y_ptr)   = (unsigned int)y;
				*(brush_mat_ptr) = (unsigned int)material;
				*(brush_we_ptr)  = 1;
				*(brush_we_ptr)  = 0;
			}
		}
	}
}

int main(void)
{
	int fd;
	if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
		printf("ERROR: could not open \"/dev/mem\"...\n");
		return (1);
	}

	void *h2p_lw_virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE),
		MAP_SHARED, fd, HW_REGS_BASE);
	if (h2p_lw_virtual_base == MAP_FAILED) {
		printf("ERROR: mmap failed...\n");
		close(fd);
		return (1);
	}

	brush_we_ptr  = (unsigned int *)(h2p_lw_virtual_base + BRUSH_WE_OFFSET);
	brush_mat_ptr = (unsigned int *)(h2p_lw_virtual_base + BRUSH_MAT_OFFSET);
	brush_y_ptr   = (unsigned int *)(h2p_lw_virtual_base + BRUSH_Y_OFFSET);
	brush_x_ptr   = (unsigned int *)(h2p_lw_virtual_base + BRUSH_X_OFFSET);

	int mouse_fd = open("/dev/input/mice", O_RDONLY | O_NONBLOCK);
	if (mouse_fd < 0) {
		printf("ERROR: could not open /dev/input/mice (Did you use sudo?)\n");
		return 1;
	}

	int mx = 320;
	int my = 240;
	int current_mat_idx = MAT_WALL;
	int prev_right = 0;
	int prev_middle = 0;

	fpga_set_brush_material((unsigned int)current_mat_idx);

	unsigned char mbuf[3];
	int mouse_acc = 0;

	printf("\n==================================\n");
	printf("  FPGA PHYSICS SANDBOX ACTIVATED! \n");
	printf("==================================\n");
	printf("Controls:\n");
	printf(" - LEFT MOUSE (canvas): Paint Material\n");
	printf(" - LEFT MOUSE (bottom bar): Pick slot (Wall/Water/Sand/Fire/Smoke)\n");
	printf(" - RIGHT MOUSE: Cycle Material\n");
	printf(" - MIDDLE MOUSE: Clear canvas (y<%d)\n\n", CANVAS_H);
	printf(">>> CURRENT BRUSH: [%s] <<<\n", material_names[current_mat_idx]);

	while (1) {
		ssize_t n = read(mouse_fd, mbuf + mouse_acc, (size_t)(3 - mouse_acc));
		if (n > 0) {
			mouse_acc += (int)n;
			if (mouse_acc >= 3) {
				int left   = mbuf[0] & 0x1;
				int right  = mbuf[0] & 0x2;
				int middle = mbuf[0] & 0x4;
				signed char dx = (signed char)mbuf[1];
				signed char dy = (signed char)mbuf[2];
				mouse_acc = 0;

				if (middle && !prev_middle) {
					int cx, cy;
					printf("\n[!!!] NUCLEAR WIPE (canvas only) [!!!]\n");
					for (cy = 0; cy < CANVAS_H; cy++) {
						for (cx = 0; cx < 320; cx++) {
							*(brush_x_ptr)   = (unsigned int)cx;
							*(brush_y_ptr)   = (unsigned int)cy;
							*(brush_mat_ptr) = (unsigned int)MAT_EMPTY;
							*(brush_we_ptr)  = 1;
							*(brush_we_ptr)  = 0;
						}
					}
					printf(">>> CANVAS CLEARED! <<<\n\n");
				}
				prev_middle = middle;

				if (dx != 0 || dy != 0) {
					mx += dx;
					my -= dy;
					if (mx < 0) mx = 0;
					if (mx > 639) mx = 639;
					if (my < 0) my = 0;
					if (my > 479) my = 479;
				}

				if (right && !prev_right) {
					current_mat_idx++;
					if (current_mat_idx > 5)
						current_mat_idx = 0;
					fpga_set_brush_material((unsigned int)current_mat_idx);
					printf(">>> SWITCHED BRUSH TO: [%s] <<<\n",
						material_names[current_mat_idx]);
				}
				prev_right = right;

				if (left) {
					int grid_x = mx / 2;
					int grid_y = my / 2;
					if (grid_y >= CANVAS_H) {
						int slot = grid_x / (320 / 5);
						if (slot < 0) slot = 0;
						if (slot > 4) slot = 4;
						int newm = toolbar_slot_mat[slot];
						if (newm != current_mat_idx) {
							current_mat_idx = newm;
							fpga_set_brush_material((unsigned int)current_mat_idx);
							printf(">>> TOOLBAR: [%s] <<<\n",
								material_names[current_mat_idx]);
						}
					} else {
						paint_to_fpga(grid_x, grid_y, current_mat_idx);
					}
				}
			}
		}
		usleep(1000);
	}

	close(mouse_fd);
	munmap(h2p_lw_virtual_base, HW_REGS_SPAN);
	close(fd);
	return 0;
}
