module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	input						CLOCK_50,
	input						CLOCK2_50,
	input						CLOCK3_50,
	input						CLOCK4_50,

	// ADC
	inout						ADC_CS_N,
	output					ADC_DIN,
	input						ADC_DOUT,
	output					ADC_SCLK,

	// Audio
	input						AUD_ADCDAT,
	inout						AUD_ADCLRCK,
	inout						AUD_BCLK,
	output					AUD_DACDAT,
	inout						AUD_DACLRCK,
	output					AUD_XCK,

	// SDRAM
	output 		[12: 0]	DRAM_ADDR,
	output		[ 1: 0]	DRAM_BA,
	output					DRAM_CAS_N,
	output					DRAM_CKE,
	output					DRAM_CLK,
	output					DRAM_CS_N,
	inout			[15: 0]	DRAM_DQ,
	output					DRAM_LDQM,
	output					DRAM_RAS_N,
	output					DRAM_UDQM,
	output					DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	output					FPGA_I2C_SCLK,
	inout						FPGA_I2C_SDAT,

	// 40-pin headers
	inout			[35: 0]	GPIO_0,
	inout			[35: 0]	GPIO_1,

	// Seven Segment Displays
	output		[ 6: 0]	HEX0,
	output		[ 6: 0]	HEX1,
	output		[ 6: 0]	HEX2,
	output		[ 6: 0]	HEX3,
	output		[ 6: 0]	HEX4,
	output		[ 6: 0]	HEX5,

	// IR
	input						IRDA_RXD,
	output					IRDA_TXD,

	// Pushbuttons
	input			[ 3: 0]	KEY,

	// LEDs
	output		[ 9: 0]	LEDR,

	// PS2 Ports
	inout						PS2_CLK,
	inout						PS2_DAT,
	inout						PS2_CLK2,
	inout						PS2_DAT2,

	// Slider Switches
	input			[ 9: 0]	SW,

	// Video-In
	input						TD_CLK27,
	input			[ 7: 0]	TD_DATA,
	input						TD_HS,
	output					TD_RESET_N,
	input						TD_VS,

	// VGA
	output		[ 7: 0]	VGA_B,
	output					VGA_BLANK_N,
	output					VGA_CLK,
	output		[ 7: 0]	VGA_G,
	output					VGA_HS,
	output		[ 7: 0]	VGA_R,
	output					VGA_SYNC_N,
	output					VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM
	output		[14: 0]	HPS_DDR3_ADDR,
	output		[ 2: 0] HPS_DDR3_BA,
	output					HPS_DDR3_CAS_N,
	output					HPS_DDR3_CKE,
	output					HPS_DDR3_CK_N,
	output					HPS_DDR3_CK_P,
	output					HPS_DDR3_CS_N,
	output		[ 3: 0]	HPS_DDR3_DM,
	inout			[31: 0]	HPS_DDR3_DQ,
	inout			[ 3: 0]	HPS_DDR3_DQS_N,
	inout			[ 3: 0]	HPS_DDR3_DQS_P,
	output					HPS_DDR3_ODT,
	output					HPS_DDR3_RAS_N,
	output					HPS_DDR3_RESET_N,
	input						HPS_DDR3_RZQ,
	output					HPS_DDR3_WE_N,

	// Ethernet
	output					HPS_ENET_GTX_CLK,
	inout						HPS_ENET_INT_N,
	output					HPS_ENET_MDC,
	inout						HPS_ENET_MDIO,
	input						HPS_ENET_RX_CLK,
	input			[ 3: 0]	HPS_ENET_RX_DATA,
	input						HPS_ENET_RX_DV,
	output		[ 3: 0]	HPS_ENET_TX_DATA,
	output					HPS_ENET_TX_EN,

	// Flash
	inout			[ 3: 0]	HPS_FLASH_DATA,
	output					HPS_FLASH_DCLK,
	output					HPS_FLASH_NCSO,

	// Accelerometer
	inout						HPS_GSENSOR_INT,

	// General Purpose I/O
	inout			[ 1: 0]	HPS_GPIO,

	// I2C
	inout						HPS_I2C_CONTROL,
	inout						HPS_I2C1_SCLK,
	inout						HPS_I2C1_SDAT,
	inout						HPS_I2C2_SCLK,
	inout						HPS_I2C2_SDAT,

	// Pushbutton
	inout						HPS_KEY,

	// LED
	inout						HPS_LED,

	// SD Card
	output					HPS_SD_CLK,
	inout						HPS_SD_CMD,
	inout			[ 3: 0]	HPS_SD_DATA,

	// SPI
	output					HPS_SPIM_CLK,
	input						HPS_SPIM_MISO,
	output					HPS_SPIM_MOSI,
	inout						HPS_SPIM_SS,

	// UART
	input						HPS_UART_RX,
	output					HPS_UART_TX,

	// USB
	inout						HPS_CONV_USB_N,
	input						HPS_USB_CLKOUT,
	inout			[ 7: 0]	HPS_USB_DATA,
	input						HPS_USB_DIR,
	input						HPS_USB_NXT,
	output					HPS_USB_STP
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;

// VGA clock and reset lines
wire vga_pll_lock ;
wire vga_pll ;
wire vga_reset = ~KEY[0];

// M10k memory clock
wire M10k_pll ;
wire M10k_pll_locked ;
wire sys_reset_n = KEY[0];

// Wires for connecting VGA driver to memory
wire [9:0] next_x ;
wire [9:0] next_y ;

// Sandbox HPS PIO Control Wires
wire [9:0] brush_x;
wire [8:0] brush_y;
wire [3:0] brush_mat;
wire       brush_we;
wire [31:0] hw_cycle_count; 
wire [31:0] hps_keys;

//=======================================================
// SANDBOX: UNIFIED PING-PONG MEMORY ARCHITECTURE
//=======================================================

// Grid Resolution
parameter GRID_WIDTH  = 10'd320;
parameter GRID_HEIGHT = 10'd240;
parameter CANVAS_ROWS = 9'd200; // Canvas area (y=0..199, toolbar is y=200..239)
parameter MAX_CELLS   = 17'd76800; // 320 * 240

// Fire block parameters
parameter FIRE_BLOCK_WIDTH  = 9'd16; // 16 pixels wide (-8 to +7 from root)
parameter FIRE_BLOCK_HEIGHT = 9'd12; // 12 pixels tall (rows -11..0 from root)
parameter MAX_FIRE_BLOCKS   = 4'd16;

// Material Definitions
parameter MAT_EMPTY = 4'd0;
parameter MAT_SAND  = 4'd1;
parameter MAT_WATER = 4'd2;
parameter MAT_WALL  = 4'd3;
parameter MAT_FIRE  = 4'd4;
parameter MAT_SMOKE = 4'd5;

// VGA -> Grid coordinate mapping (640x480 -> 320x240, divide by 2)
wire [8:0] grid_read_x = next_x[9:1]; 
wire [8:0] grid_read_y = next_y[9:1]; 
wire [16:0] vga_read_addr = (grid_read_y * GRID_WIDTH) + grid_read_x;

// Ping-Pong Buffer Control
// FIX: active_buffer semantic is now crystal clear:
//   active_buffer=0 => Buffer A is FRONT (displayed by VGA), Buffer B is BACK (written by CA)
//   active_buffer=1 => Buffer B is FRONT (displayed by VGA), Buffer A is BACK (written by CA)
reg  active_buffer;
reg  [16:0] ca_read_addr;
reg  [16:0] ca_write_addr;
reg  [3:0]  ca_write_data;
reg         ca_we;
wire [3:0]  ca_read_data;

wire [3:0] vga_data_out;
wire [3:0] vga_q_A, vga_q_B;
wire [3:0] ca_q_A, ca_q_B;

// HPS brush address
wire [16:0] hps_write_addr = (brush_y * GRID_WIDTH) + brush_x;

// -------------------------------------------------------
// FIX: Isolate HPS brush writes from CA pipeline.
//
// Problem: brush_* signals are async to M10k_pll. The old design
// used combinational MUX (brush_we ? brush_mat : ca_data) directly
// on M10K port-B writes, causing setup/hold violations where
// fire(4)/smoke(5) wrote wrong values and displayed as black.
//
// Solution:
//   - brush_we uses a 2-stage synchronizer to prevent metastability
//     from async Avalon PIO signals crossing into M10k_pll domain.
//     An edge detector generates a clean 1-cycle pulse.
//   - brush addr/data are single-register-sync'd (valid when we fires).
//   - CA writes still flow directly through the combinational MUX
//     since ca_* is already synchronous to M10k_pll.
//   - brush_we_edge overrides CA when active (arbitration: brush wins).
// -------------------------------------------------------

// 2-stage synchronizer for brush_we (metastability hardening)
// Reviewer note: brush_we from Avalon PIO crosses async clock domains;
// a 2-stage sync ensures metastability does not propagate into M10K logic.
reg         brush_we_s1, brush_we_s2;
reg         brush_we_sync_prev;
wire        brush_we_edge = brush_we_s2 & ~brush_we_sync_prev;

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        brush_we_s1         <= 1'b0;
        brush_we_s2         <= 1'b0;
        brush_we_sync_prev  <= 1'b0;
    end else begin
        brush_we_s1        <= brush_we;
        brush_we_s2        <= brush_we_s1;
        brush_we_sync_prev <= brush_we_s2;
    end
end

// Brush address and data: single-register sync into M10k_pll domain.
// HPS writes x/y/mat before asserting we, so when brush_we_edge fires,
// these values have been stable for at least one M10k_pll cycle.
reg         [16:0] brush_addr_sync;
reg         [3:0]  brush_data_sync;

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        brush_addr_sync <= 17'd0;
        brush_data_sync <= 4'd0;
    end else begin
        brush_addr_sync <= hps_write_addr;
        brush_data_sync <= brush_mat;
    end
end

// CA MUX: still combinational (ca_* is already in M10k_pll domain)
wire        ca_we_mux   = ca_we;
wire [16:0] ca_addr_mux = ca_write_addr;
wire [3:0]  ca_data_mux = ca_write_data;

// Final merge: brush_we_edge overrides CA.
// Arbitration policy: brush (HPS user input) always wins over CA sweep.
// If we_edge and ca_we assert simultaneously on the same address, CA
// write is silently dropped and brush data is stored instead. This is
// desirable — user intent supersedes background physics simulation.
wire        we_final   = brush_we_edge ? 1'b1    : ca_we_mux;
wire [16:0] addr_final = brush_we_edge ? brush_addr_sync : ca_addr_mux;
wire [3:0]  data_final = brush_we_edge ? brush_data_sync  : ca_data_mux;

// -------------------------------------------------------
// FIX: Corrected dual-port routing
//
// Port A of each buffer is permanently tied to VGA (read-only).
// Port B of each buffer is used by the CA engine:
//   - When a buffer is FRONT: Port B reads from it (CA reads current state)
//   - When a buffer is BACK:  Port B writes to it (CA writes next state)
//
// active_buffer=0: A is FRONT, B is BACK
//   grid_A Port B => CA reads from A (front), write disabled
//   grid_B Port B => CA writes to B (back), write enabled
//
// active_buffer=1: B is FRONT, A is BACK
//   grid_A Port B => CA writes to A (back), write enabled
//   grid_B Port B => CA reads from B (front), write disabled
// -------------------------------------------------------

M10K_76800_4 grid_A (
    .clk(M10k_pll),
    // Port A: always to VGA
    .addr_a(vga_read_addr),
    .q_a(vga_q_A),
    // Port B: CA engine
    //   active=0 (A is front): CA reads from A, no write
    //   active=1 (A is back):  CA writes to A
    .we_b  ( (active_buffer == 1'b1) ? we_final   : 1'b0       ),
    .addr_b( (active_buffer == 1'b1) ? addr_final : ca_read_addr),
    .d_b(data_final),
    .q_b(ca_q_A)
);

M10K_76800_4 grid_B (
    .clk(M10k_pll),
    // Port A: always to VGA
    .addr_a(vga_read_addr),
    .q_a(vga_q_B),
    // Port B: CA engine
    //   active=0 (B is back):  CA writes to B
    //   active=1 (B is front): CA reads from B, no write
    .we_b  ( (active_buffer == 1'b0) ? we_final   : 1'b0       ),
    .addr_b( (active_buffer == 1'b0) ? addr_final : ca_read_addr),
    .d_b(data_final),
    .q_b(ca_q_B)
);

// VGA reads from the FRONT buffer
assign vga_data_out = (active_buffer == 1'b0) ? vga_q_A : vga_q_B;

// CA engine reads from the FRONT buffer
// FIX: CA must read from front (current state), write to back (next state)
//   active=0: front is A => read ca_q_A
//   active=1: front is B => read ca_q_B
assign ca_read_data = (active_buffer == 1'b0) ? ca_q_A : ca_q_B;


//=======================================================
// VGA Color Mapper
//=======================================================
// Fire and smoke animation is display-only; physics still stores only MAT_*.
reg [19:0] visual_anim_div;
reg [3:0]  visual_anim_ctr;
always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        visual_anim_div <= 20'd0;
        visual_anim_ctr <= 4'd0;
    end else begin
        visual_anim_div <= visual_anim_div + 20'd1;
        if (visual_anim_div == 20'd0)
            visual_anim_ctr <= visual_anim_ctr + 4'd1;
    end
end

// ============================================================
// ============================================================
// Toolbar color signals (Feature 2)
// ============================================================
wire in_toolbar;
assign in_toolbar = (grid_read_y >= 9'd200 && grid_read_y <= 9'd239);

// Toolbar slot computation (5 slots of 64px each)
wire [1:0] toolbar_slot;
assign toolbar_slot = grid_read_x[8:1] >> 6; // 0..4

// Toolbar border computation
wire toolbar_left_border  = (grid_read_x[8:0] == 9'd0) || (grid_read_x[8:0] == 9'd64) || 
                             (grid_read_x[8:0] == 9'd128) || (grid_read_x[8:0] == 9'd192) || 
                             (grid_read_x[8:0] == 9'd256) || (grid_read_x[8:0] == 9'd319);
wire toolbar_top_border    = (grid_read_y[8:0] == 9'd200);
wire toolbar_bottom_border = (grid_read_y[8:0] == 9'd239);
wire toolbar_border        = toolbar_left_border | toolbar_top_border | toolbar_bottom_border;

wire toolbar_selected_slot;
 // brush_mat maps: WALL=3->slot0, WATER=2->slot1, SAND=1->slot2, FIRE=4->slot3, SMOKE=5->slot4
assign toolbar_selected_slot = (brush_mat == 4'd3 && toolbar_slot == 2'd0) ||
                               (brush_mat == 4'd2 && toolbar_slot == 2'd1) ||
                               (brush_mat == 4'd1 && toolbar_slot == 2'd2) ||
                               (brush_mat == 4'd4 && toolbar_slot == 2'd3) ||
                               (brush_mat == 4'd5 && toolbar_slot == 2'd4);

// Toolbar pixel font / icon for each slot (5x3 mini-icon per slot)
// Using simple colored bars and a dot pattern approach
wire [2:0] icon_x = grid_read_x[2:0]; // pixel within icon area
wire [2:0] icon_y = grid_read_y[2:0] - 3'd0; // relative y in toolbar area

// ============================================================
// Mouse cursor (Feature 3)
// ============================================================
wire cursor_center;
wire cursor_ring;
assign cursor_center = (grid_read_x[8:0] == brush_x[8:0]) & (grid_read_y[8:0] == brush_y[8:0]);
assign cursor_ring   = ((grid_read_x[8:0] == brush_x[8:0]) & (
    (grid_read_y[8:0] == brush_y[8:0] - 9'd1) || 
    (grid_read_y[8:0] == brush_y[8:0] + 9'd1))) ||
    ((grid_read_y[8:0] == brush_y[8:0]) & (
    (grid_read_x[8:0] == brush_x[8:0] - 9'd1) || 
    (grid_read_x[8:0] == brush_x[8:0] + 9'd1)));

// ============================================================
// Pause indicator (Feature 4)
// ============================================================
// hps_keys bit 0 indicates pause
wire pause_active = hps_keys[0];
// Pause icon: two vertical bars centered at approximately (8,8) in grid coords
wire in_pause_icon;
wire pause_bar_left;
wire pause_bar_right;
assign pause_bar_left  = (grid_read_x[8:0] == 9'd19) & 
                          (grid_read_y[8:0] >= 9'd14 && grid_read_y[8:0] <= 9'd25);
assign pause_bar_right = (grid_read_x[8:0] == 9'd21) & 
                          (grid_read_y[8:0] >= 9'd14 && grid_read_y[8:0] <= 9'd25);
assign in_pause_icon = pause_bar_left | pause_bar_right;

// ============================================================
// Final color mapping with layered priority:
// 1. Base grid material color
// 2. Toolbar override
// 3. Fire block override
// 4. Cursor override
// ============================================================
reg [7:0] grid_color;
reg [7:0] final_vga_color;
always @(*) begin
    case(vga_data_out)
        MAT_EMPTY: grid_color = 8'b000_000_00; // Black
        MAT_SAND:  grid_color = 8'b111_110_00; // Yellow
        MAT_WATER: grid_color = 8'b000_010_11; // Blue
        MAT_WALL:  grid_color = 8'b011_011_01; // Gray
        MAT_FIRE:  grid_color = visual_anim_ctr[1] ? 8'b111_010_01 : 8'b111_000_00;
        MAT_SMOKE: grid_color = visual_anim_ctr[2] ? 8'b110_110_11 : 8'b100_100_10;
        default:   grid_color = 8'b000_000_00;
    endcase
end

// Toolbar color
wire [7:0] toolbar_bg = 8'b010_010_01; // Dark unified background for all slots

// Toolbar divider lines between slots — 2px wide, brighter than bg for visibility
wire toolbar_divider = (grid_read_x[8:0] >= 9'd63  && grid_read_x[8:0] <= 9'd64) ||
                       (grid_read_x[8:0] >= 9'd127 && grid_read_x[8:0] <= 9'd128) ||
                       (grid_read_x[8:0] >= 9'd191 && grid_read_x[8:0] <= 9'd192) ||
                       (grid_read_x[8:0] >= 9'd255 && grid_read_x[8:0] <= 9'd256);

// Toolbar top thick border at y=198..199 (2px high line above the toolbar)
wire toolbar_top_bar = (grid_read_y[8:0] >= 9'd198 && grid_read_y[8:0] <= 9'd199);

// Toolbar bottom border at y=238..239
wire toolbar_bottom_bar = (grid_read_y[8:0] >= 9'd238 && grid_read_y[8:0] <= 9'd239);

// Selected slot bounding box: entire slot 四周白框
wire slot_sel_left  = (toolbar_slot == 2'd0) && (grid_read_x[8:0] == 9'd0);
wire slot_sel_right = (toolbar_slot == 2'd0) && (grid_read_x[8:0] == 9'd63);
wire slot_sel_right2 = (toolbar_slot == 2'd1) && (grid_read_x[8:0] == 9'd127);
wire slot_sel_right3 = (toolbar_slot == 2'd2) && (grid_read_x[8:0] == 9'd191);
wire slot_sel_right4 = (toolbar_slot == 2'd3) && (grid_read_x[8:0] == 9'd255);
wire slot_sel_right5 = (toolbar_slot == 2'd4) && (grid_read_x[8:0] == 9'd319);
wire slot_sel_top    = (grid_read_y[8:0] == 9'd200);
wire slot_sel_bottom = (grid_read_y[8:0] == 9'd239);
wire slot_sel_vert   = toolbar_selected_slot && (slot_sel_left || slot_sel_right || slot_sel_right2 || slot_sel_right3 || slot_sel_right4 || slot_sel_right5);
wire slot_sel_horiz  = toolbar_selected_slot && (slot_sel_top || slot_sel_bottom);

// --- Font ROM: 每个字母 3 列 x 5 行，用 wire 数组实现 ---
// 字母定义（3x5 点阵）: 每行 3bit
// W= 100010011111010, A= 000011101100111, L= 100100100100111, L= same
// A= 同上, T= 111001001001001, E= 111100111100111, R= 111101111101101
// S= 111100111001111, A, N= 101101111111111, N=, D= 110101101101110
// F= 111100110100100, I= 111001101101111, R=, E=
// S, M= 111111101111101011111, O= 011101001010011, K= 101110101110101

// --- 简化方案：直接硬编码比较来绘制文字 ---
// 对于每个 slot，判断当前像素是否处于对应字母的某个点亮位置
// 文字区域：y=208..212 (5px高)
// 每个 slot=64px宽，文字居中

wire in_text_area_y = (grid_read_y[8:0] >= 9'd208 && grid_read_y[8:0] <= 9'd212);

// --- SLOT 0: "WALL" (4 chars * 3px = 12px, 3 gaps = 15px) 居中：起点 x=24 ---
wire t0_y0 = in_text_area_y && (grid_read_y[8:0] == 9'd208); // row 0
wire t0_y1 = in_text_area_y && (grid_read_y[8:0] == 9'd209); // row 1
wire t0_y2 = in_text_area_y && (grid_read_y[8:0] == 9'd210); // row 2
wire t0_y3 = in_text_area_y && (grid_read_y[8:0] == 9'd211); // row 3
wire t0_y4 = in_text_area_y && (grid_read_y[8:0] == 9'd212); // row 4

// WALL 点阵: W(101/101/111/111/110) A(010/101/111/101/101) L(100/100/100/100/111) L(same)
wire t0_pixel =
  // W at x=24..26:
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd26) && t0_y0 ) |
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd26) && t0_y1 ) |
  ( (grid_read_x[8:0] >= 9'd24 && grid_read_x[8:0] <= 9'd26) && t0_y2 ) |
  ( (grid_read_x[8:0] >= 9'd24 && grid_read_x[8:0] <= 9'd26) && t0_y3 ) |
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd25) && t0_y4 ) |
  // A at x=28..30:
  ( (grid_read_x[8:0] == 9'd29) && t0_y0 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && t0_y1 ) |
  ( (grid_read_x[8:0] >= 9'd28 && grid_read_x[8:0] <= 9'd30) && t0_y2 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && t0_y3 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && t0_y4 ) |
  // L at x=32..34:
  ( (grid_read_x[8:0] == 9'd32) && t0_y0 ) |
  ( (grid_read_x[8:0] == 9'd32) && t0_y1 ) |
  ( (grid_read_x[8:0] == 9'd32) && t0_y2 ) |
  ( (grid_read_x[8:0] == 9'd32) && t0_y3 ) |
  ( (grid_read_x[8:0] >= 9'd32 && grid_read_x[8:0] <= 9'd34) && t0_y4 ) |
  // L at x=36..38:
  ( (grid_read_x[8:0] == 9'd36) && t0_y0 ) |
  ( (grid_read_x[8:0] == 9'd36) && t0_y1 ) |
  ( (grid_read_x[8:0] == 9'd36) && t0_y2 ) |
  ( (grid_read_x[8:0] == 9'd36) && t0_y3 ) |
  ( (grid_read_x[8:0] >= 9'd36 && grid_read_x[8:0] <= 9'd38) && t0_y4 )
;

// --- SLOT 1: "WATER" (5chars) 起点 x=23 (居中于0..63) ---
// x: W=23-25, 空=26, A=27-29, 空=30, T=31-33, 空=34, E=35-37, 空=38, R=39-41
wire t1_y0 = in_text_area_y && (grid_read_y[8:0] == 9'd208);
wire t1_y1 = in_text_area_y && (grid_read_y[8:0] == 9'd209);
wire t1_y2 = in_text_area_y && (grid_read_y[8:0] == 9'd210);
wire t1_y3 = in_text_area_y && (grid_read_y[8:0] == 9'd211);
wire t1_y4 = in_text_area_y && (grid_read_y[8:0] == 9'd212);

wire t1_pixel =
  // W at 23-25:
  ( (grid_read_x[8:0] == 9'd23 || grid_read_x[8:0] == 9'd25) && t1_y0 ) |
  ( (grid_read_x[8:0] == 9'd23 || grid_read_x[8:0] == 9'd25) && t1_y1 ) |
  ( (grid_read_x[8:0] >= 9'd23 && grid_read_x[8:0] <= 9'd25) && t1_y2 ) |
  ( (grid_read_x[8:0] >= 9'd23 && grid_read_x[8:0] <= 9'd25) && t1_y3 ) |
  ( (grid_read_x[8:0] == 9'd23 || grid_read_x[8:0] == 9'd24) && t1_y4 ) |
  // A at 27-29:
  ( (grid_read_x[8:0] == 9'd28) && t1_y0 ) |
  ( (grid_read_x[8:0] == 9'd27 || grid_read_x[8:0] == 9'd29) && t1_y1 ) |
  ( (grid_read_x[8:0] >= 9'd27 && grid_read_x[8:0] <= 9'd29) && t1_y2 ) |
  ( (grid_read_x[8:0] == 9'd27 || grid_read_x[8:0] == 9'd29) && t1_y3 ) |
  ( (grid_read_x[8:0] == 9'd27 || grid_read_x[8:0] == 9'd29) && t1_y4 ) |
  // T at 31-33:
  ( (grid_read_x[8:0] >= 9'd31 && grid_read_x[8:0] <= 9'd33) && t1_y0 ) |
  ( (grid_read_x[8:0] == 9'd32) && t1_y1 ) |
  ( (grid_read_x[8:0] == 9'd32) && t1_y2 ) |
  ( (grid_read_x[8:0] == 9'd32) && t1_y3 ) |
  ( (grid_read_x[8:0] == 9'd32) && t1_y4 ) |
  // E at 35-37:
  ( (grid_read_x[8:0] >= 9'd35 && grid_read_x[8:0] <= 9'd37) && t1_y0 ) |
  ( (grid_read_x[8:0] == 9'd35) && t1_y1 ) |
  ( (grid_read_x[8:0] >= 9'd35 && grid_read_x[8:0] <= 9'd36) && t1_y2 ) |
  ( (grid_read_x[8:0] == 9'd35) && t1_y3 ) |
  ( (grid_read_x[8:0] >= 9'd35 && grid_read_x[8:0] <= 9'd37) && t1_y4 ) |
  // R at 39-41:
  ( (grid_read_x[8:0] >= 9'd39 && grid_read_x[8:0] <= 9'd41) && t1_y0 ) |
  ( (grid_read_x[8:0] == 9'd39 || grid_read_x[8:0] == 9'd40) && t1_y1 ) |
  ( (grid_read_x[8:0] >= 9'd39 && grid_read_x[8:0] <= 9'd41) && t1_y2 ) |
  ( (grid_read_x[8:0] == 9'd39 || grid_read_x[8:0] == 9'd40) && t1_y3 ) |
  ( (grid_read_x[8:0] == 9'd39 || grid_read_x[8:0] == 9'd41) && t1_y4 )
;

// --- SLOT 2: "SAND" (4chars) 起点x=24 (64宽中置12+3空格=15: (64-15)/2=24.5->24) ---
wire t2_y0 = in_text_area_y && (grid_read_y[8:0] == 9'd208);
wire t2_y1 = in_text_area_y && (grid_read_y[8:0] == 9'd209);
wire t2_y2 = in_text_area_y && (grid_read_y[8:0] == 9'd210);
wire t2_y3 = in_text_area_y && (grid_read_y[8:0] == 9'd211);
wire t2_y4 = in_text_area_y && (grid_read_y[8:0] == 9'd212);

wire t2_pixel =
  // S at 124-126 (slot 2 x range 128..191, S starts at 128+24-128=24... no, slot2 is x=128..191, offset 24 means x=152)
  // WAIT -- 文字在 SLOT 内部居中！slot2 的 x 范围是 128..191（64宽），所以文字从 128+24=152 开始
  // S at x=152..154:
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd154) && t2_y0 ) |
  ( (grid_read_x[8:0] == 9'd152) && t2_y1 ) |
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd153) && t2_y2 ) |
  ( (grid_read_x[8:0] == 9'd154) && t2_y3 ) |
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd154) && t2_y4 ) |
  // A at x=156..158:
  ( (grid_read_x[8:0] == 9'd157) && t2_y0 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && t2_y1 ) |
  ( (grid_read_x[8:0] >= 9'd156 && grid_read_x[8:0] <= 9'd158) && t2_y2 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && t2_y3 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && t2_y4 ) |
  // N at x=160..162:
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd162) && t2_y0 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd161 || grid_read_x[8:0] == 9'd162) && t2_y1 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd161 || grid_read_x[8:0] == 9'd162) && t2_y2 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd161 || grid_read_x[8:0] == 9'd162) && t2_y3 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd162) && t2_y4 ) |
  // D at x=164..166:
  ( (grid_read_x[8:0] >= 9'd164 && grid_read_x[8:0] <= 9'd165) && t2_y0 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && t2_y1 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && t2_y2 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && t2_y3 ) |
  ( (grid_read_x[8:0] >= 9'd164 && grid_read_x[8:0] <= 9'd165) && t2_y4 )
;

// --- SLOT 3: "FIRE" (4chars) x range 192..255, text starts 192+24=216 ---
wire t3_y0 = in_text_area_y && (grid_read_y[8:0] == 9'd208);
wire t3_y1 = in_text_area_y && (grid_read_y[8:0] == 9'd209);
wire t3_y2 = in_text_area_y && (grid_read_y[8:0] == 9'd210);
wire t3_y3 = in_text_area_y && (grid_read_y[8:0] == 9'd211);
wire t3_y4 = in_text_area_y && (grid_read_y[8:0] == 9'd212);

wire t3_pixel =
  // F at x=216..218:
  ( (grid_read_x[8:0] >= 9'd216 && grid_read_x[8:0] <= 9'd218) && t3_y0 ) |
  ( (grid_read_x[8:0] == 9'd216) && t3_y1 ) |
  ( (grid_read_x[8:0] >= 9'd216 && grid_read_x[8:0] <= 9'd217) && t3_y2 ) |
  ( (grid_read_x[8:0] == 9'd216) && t3_y3 ) |
  ( (grid_read_x[8:0] == 9'd216) && t3_y4 ) |
  // I at x=220..222:
  ( (grid_read_x[8:0] >= 9'd220 && grid_read_x[8:0] <= 9'd222) && t3_y0 ) |
  ( (grid_read_x[8:0] == 9'd221) && t3_y1 ) |
  ( (grid_read_x[8:0] == 9'd221) && t3_y2 ) |
  ( (grid_read_x[8:0] == 9'd221) && t3_y3 ) |
  ( (grid_read_x[8:0] >= 9'd220 && grid_read_x[8:0] <= 9'd222) && t3_y4 ) |
  // R at x=224..226:
  ( (grid_read_x[8:0] >= 9'd224 && grid_read_x[8:0] <= 9'd226) && t3_y0 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd225) && t3_y1 ) |
  ( (grid_read_x[8:0] >= 9'd224 && grid_read_x[8:0] <= 9'd226) && t3_y2 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd225) && t3_y3 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd226) && t3_y4 ) |
  // E at x=228..230:
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd230) && t3_y0 ) |
  ( (grid_read_x[8:0] == 9'd228) && t3_y1 ) |
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd229) && t3_y2 ) |
  ( (grid_read_x[8:0] == 9'd228) && t3_y3 ) |
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd230) && t3_y4 )
;

// --- SLOT 4: "SMOKE" (5chars) x range 256..319, text starts 256+23=279 ---
wire t4_y0 = in_text_area_y && (grid_read_y[8:0] == 9'd208);
wire t4_y1 = in_text_area_y && (grid_read_y[8:0] == 9'd209);
wire t4_y2 = in_text_area_y && (grid_read_y[8:0] == 9'd210);
wire t4_y3 = in_text_area_y && (grid_read_y[8:0] == 9'd211);
wire t4_y4 = in_text_area_y && (grid_read_y[8:0] == 9'd212);

wire t4_pixel =
  // S at x=279..281:
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd281) && t4_y0 ) |
  ( (grid_read_x[8:0] == 9'd279) && t4_y1 ) |
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd280) && t4_y2 ) |
  ( (grid_read_x[8:0] == 9'd281) && t4_y3 ) |
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd281) && t4_y4 ) |
  // M at x=283..285:
  ( (grid_read_x[8:0] == 9'd283 || grid_read_x[8:0] == 9'd284 || grid_read_x[8:0] == 9'd285) && t4_y0 ) |
  ( (grid_read_x[8:0] == 9'd283) && t4_y1 ) |
  ( (grid_read_x[8:0] == 9'd283 || grid_read_x[8:0] == 9'd284) && t4_y2 ) |
  ( (grid_read_x[8:0] == 9'd283) && t4_y3 ) |
  ( (grid_read_x[8:0] == 9'd283 || grid_read_x[8:0] == 9'd285) && t4_y4 ) |
  // O at x=287..289:
  ( (grid_read_x[8:0] >= 9'd287 && grid_read_x[8:0] <= 9'd289) && t4_y0 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && t4_y1 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && t4_y2 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && t4_y3 ) |
  ( (grid_read_x[8:0] >= 9'd287 && grid_read_x[8:0] <= 9'd289) && t4_y4 ) |
  // K at x=291..293:
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd293) && t4_y0 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd292) && t4_y1 ) |
  ( (grid_read_x[8:0] == 9'd291) && t4_y2 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd292) && t4_y3 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd293) && t4_y4 ) |
  // E at x=295..297:
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd297) && t4_y0 ) |
  ( (grid_read_x[8:0] == 9'd295) && t4_y1 ) |
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd296) && t4_y2 ) |
  ( (grid_read_x[8:0] == 9'd295) && t4_y3 ) |
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd297) && t4_y4 )
;

// Slot text color based on slot's original material color
wire [7:0] slot0_text_color = 8'b011_011_01; // Wall - gray
wire [7:0] slot1_text_color = 8'b000_010_11; // Water - blue
wire [7:0] slot2_text_color = 8'b111_110_00; // Sand - yellow
wire [7:0] slot3_text_color = 8'b111_100_00; // Fire - orange
wire [7:0] slot4_text_color = 8'b010_010_00; // Smoke - dark gray

// Final pixel-on-text signal
wire any_text_pixel = (in_toolbar && toolbar_slot == 2'd0 && in_text_area_y && t0_pixel) ||
                      (in_toolbar && toolbar_slot == 2'd1 && in_text_area_y && t1_pixel) ||
                      (in_toolbar && toolbar_slot == 2'd2 && in_text_area_y && t2_pixel) ||
                      (in_toolbar && toolbar_slot == 2'd3 && in_text_area_y && t3_pixel) ||
                      (in_toolbar && toolbar_slot == 2'd4 && in_text_area_y && t4_pixel);

// --- Toolbar text color mux ---
wire [7:0] text_color = (toolbar_slot == 2'd0) ? slot0_text_color :
                        (toolbar_slot == 2'd1) ? slot1_text_color :
                        (toolbar_slot == 2'd2) ? slot2_text_color :
                        (toolbar_slot == 2'd3) ? slot3_text_color :
                                                  slot4_text_color;

reg [7:0] toolbar_color;
always @(*) begin
    // Default: unified dark bg
    toolbar_color = toolbar_bg;

    // Top bar above toolbar (y=198..199)
    if (toolbar_top_bar)
        toolbar_color = 8'b111_111_11; // White top border
    else if (toolbar_bottom_bar)
        toolbar_color = 8'b000_000_00; // Black bottom border
    else if (toolbar_divider)
        toolbar_color = 8'b010_010_11; // Divider - dim blue-gray (visible vs bg 010_010_01)
    else if (slot_sel_horiz || slot_sel_vert)
        toolbar_color = 8'b111_111_11; // White selection border
    else if (any_text_pixel)
        toolbar_color = text_color; // Text pixel in slot
    // else: dark bg
end


// Cursor color
reg [7:0] cursor_color;
always @(*) begin
    if (cursor_center)
        cursor_color = 8'b111_111_11; // Yellow center
    else if (cursor_ring)
        cursor_color = 8'b000_111_00; // Green ring
    else
        cursor_color = 8'b000_000_00;
end

// Final composition
always @(*) begin
    final_vga_color = grid_color; // Default: grid material
    if (in_toolbar)
        final_vga_color = toolbar_color;
    if (cursor_center | cursor_ring)
        final_vga_color = cursor_color; // Cursor on top
    // Pause indicator (Feature 4): bright white bars on top of everything when paused
    if (pause_active && in_pause_icon)
        final_vga_color = 8'b111_111_11;
end

// vga_driver instantiation follows with .color_in(final_vga_color)

//=======================================================
// LFSR
// Provides a pseudo-random bit each clock cycle.
// Used by sand (diagonal slide) and water (left/right spread).
// Taps: [15,13,12,10] — maximal-length primitive polynomial.
//=======================================================
reg [15:0] lfsr;
wire random_bit = lfsr[0];

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n)
        lfsr <= 16'hACE1; // Non-zero seed
    else
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
end

//=======================================================
// CA Physics Engine State Machine
//
// Frame pipeline per VSYNC:
//   1. S_CLEAR  : Fill the BACK buffer entirely with MAT_EMPTY.
//   2. S_SWEEP  : Read every pixel from FRONT buffer, evaluate physics,
//                 write result into BACK buffer.
//   3. S_IDLE   : Wait for next VSYNC falling edge, then swap buffers.
//
// Buffer swap happens AFTER the sweep is complete (in S_IDLE),
// so the back buffer is fully populated before it becomes the front.
//
// Sand rules:
//   - Fall straight down if (x, y+1) is empty.
//   - If blocked below, try diagonal (left-down or right-down) using
//     random_bit to pick which side to attempt first. This creates
//     natural pyramid piling.
//
// Water rules (accumulation + active spread):
//   - Fall straight down if (x, y+1) is empty.
//   - If blocked by WATER below → accumulate (stay in place, stable pile).
//   - If blocked by WALL/SAND below → active water: spread left/right into empty cells only.
//   - Active water that cannot spread returns to normal water (stays in place).
//=======================================================

// FIX: Extended state encoding to cover sand, water, fire, and smoke motion.
localparam S_IDLE              = 5'd0,
           S_CLEAR             = 5'd1,
           S_SWEEP_READ        = 5'd2,
           S_SWEEP_WAIT        = 5'd3,
           S_SWEEP_EVAL        = 5'd4,
           S_CHK_BOT_WT        = 5'd5,   // wait 1 cycle after issuing read of (x, y+1)
           S_CHK_BOT_EV        = 5'd6,   // evaluate (x, y+1) result
           S_CHK_DIAG1_WT      = 5'd7,   // sand: wait for first diagonal read
           S_CHK_DIAG1_EV      = 5'd8,   // sand: evaluate first diagonal
           S_CHK_DIAG2_WT      = 5'd9,   // sand: wait for second diagonal read
           S_CHK_DIAG2_EV      = 5'd10,  // sand: evaluate second diagonal
           S_CHK_SIDE1_WT      = 5'd11,  // water: wait for first side read
           S_CHK_SIDE1_EV      = 5'd12,  // water: evaluate first side (spread into EMPTY only)
           S_CHK_SIDE2_WT      = 5'd13,  // water: wait for second side read
           S_CHK_SIDE2_EV      = 5'd14,  // water: evaluate second side / write self
           S_NEXT_PIXEL        = 5'd15,
           S_CHK_FIRE_BOT_WT   = 5'd16,
           S_CHK_FIRE_BOT_EV   = 5'd17,
           S_CHK_FIRE_DIAG1_WT = 5'd18,
           S_CHK_FIRE_DIAG1_EV = 5'd19,
           S_CHK_FIRE_DIAG2_WT = 5'd20,
           S_CHK_FIRE_DIAG2_EV = 5'd21,
           S_CHK_FIRE_SIDE1_WT = 5'd22,
           S_CHK_FIRE_SIDE1_EV = 5'd23,
           S_CHK_FIRE_SIDE2_WT = 5'd24,
           S_CHK_FIRE_SIDE2_EV = 5'd25,
           S_CHK_SMK_UP_WT     = 5'd26,
           S_CHK_SMK_UP_EV     = 5'd27,
           S_CHK_SMK_DIAG1_WT  = 5'd28,
           S_CHK_SMK_DIAG1_EV  = 5'd29,
           S_CHK_SMK_DIAG2_WT  = 5'd30,
           S_CHK_SMK_DIAG2_EV  = 5'd31;

reg [4:0]  state;
reg [16:0] clear_addr;
reg [9:0]  cx;
reg [9:0]  cy;
reg [3:0]  current_mat;
reg        diag_side;

// VSync falling edge detection
reg prev_vsync;
wire vsync_falling_edge = (prev_vsync == 1'b1 && VGA_VS == 1'b0);

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        state             <= S_IDLE;
        active_buffer     <= 1'b0;
        ca_we             <= 1'b0;
        prev_vsync        <= 1'b0;
        clear_addr        <= 17'd0;
        cx                <= 10'd0;
        cy                <= 10'd0;
        current_mat       <= MAT_EMPTY;
        diag_side         <= 1'b0;
    end else begin
        prev_vsync <= VGA_VS;
        ca_we      <= 1'b0; // default: no write this cycle

        case (state)

            // ----------------------------------------------------------
            // S_IDLE: Wait for VSYNC falling edge.
            // Swap buffers here, AFTER the previous sweep has finished
            // writing a complete frame into the back buffer.
            // ----------------------------------------------------------
            S_IDLE: begin
                if (vsync_falling_edge) begin
                    // NOW swap: the fully-rendered back buffer becomes front.
                    active_buffer <= ~active_buffer;
                    clear_addr    <= 17'd0;
                    state         <= S_CLEAR;
                end
            end

            // ----------------------------------------------------------
            // S_CLEAR: Erase the (new) back buffer with MAT_EMPTY.
            // After the swap, the new back buffer is the old front buffer.
            // We blank it before the CA engine writes new particle positions.
            // ----------------------------------------------------------
            S_CLEAR: begin
                ca_we         <= 1'b1;
                ca_write_addr <= clear_addr;
                ca_write_data <= MAT_EMPTY;
                if (clear_addr == MAX_CELLS - 17'd1) begin
                    cx    <= 10'd0;
                    cy    <= CANVAS_ROWS - 10'd1; // 从底行开始向上扫
                    state <= S_SWEEP_READ;
                end else begin
                    clear_addr <= clear_addr + 17'd1;
                end
            end

            // ----------------------------------------------------------
            // S_SWEEP_READ / WAIT / EVAL: 
            // Issue a read of (cx, cy) from the FRONT buffer.
            // Two cycles later the data is valid (M10K registered output).
            // ----------------------------------------------------------
            S_SWEEP_READ: begin
                ca_read_addr <= (cy * GRID_WIDTH) + cx;
                state        <= S_SWEEP_WAIT;
            end

            S_SWEEP_WAIT: begin
                state <= S_SWEEP_EVAL;
            end

            S_SWEEP_EVAL: begin
                current_mat <= ca_read_data;
                diag_side   <= random_bit; // capture LFSR now for this pixel

                case (ca_read_data)

                    MAT_EMPTY: begin
                        // Already cleared in S_CLEAR, nothing to do.
                        state <= S_NEXT_PIXEL;
                    end

                    MAT_WALL: begin
                        // Walls are static — copy in place.
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_WALL;
                        state         <= S_NEXT_PIXEL;
                    end

                    MAT_FIRE: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            // Bottom row flames do not pile up like sand; they flicker out.
                            if (random_bit) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_FIRE;
                            end
                            state <= S_NEXT_PIXEL;
                        end else begin
                            // Fire falls through air/smoke, is extinguished by water,
                            // and otherwise burns in place above solid fuel.
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_CHK_FIRE_BOT_WT;
                        end
                    end

                    MAT_SMOKE: begin
                        if (cy == 10'd0 || lfsr[6:0] == 7'b0000000) begin
                            // Top edge or random decay (~1/128 per frame, ~2s lifetime at 60fps): disappear.
                            state <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_CHK_SMK_UP_WT;
                        end
                    end

                    MAT_SAND: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            // Already at the bottom row, stay there.
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            // Read cell directly below: (cx, cy+1)
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_CHK_BOT_WT;
                        end
                    end

                    MAT_WATER: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            // Already at the bottom row, stay there.
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            // Read cell directly below: (cx, cy+1)
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_CHK_BOT_WT;
                        end
                    end

                    default: begin
                        // Unknown material — keep in place.
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= ca_read_data;
                        state         <= S_NEXT_PIXEL;
                    end
                endcase
            end

            // ----------------------------------------------------------
            // Check directly below (shared by sand and water)
            // ----------------------------------------------------------
            S_CHK_BOT_WT: begin
                state <= S_CHK_BOT_EV;
            end

            S_CHK_BOT_EV: begin
                if (ca_read_data == MAT_EMPTY ||
                    ca_read_data == MAT_SMOKE ||
                    ca_read_data == MAT_FIRE) begin
                    // Cell below is free — fall straight down.
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= current_mat;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Below is blocked.
                    if (current_mat == MAT_SAND) begin
                        // Sand: try diagonal slides.
                        // diag_side selects which diagonal to try first.
                        // First diagonal: diag_side=0 => left-down, diag_side=1 => right-down
                        if (diag_side == 1'b0) begin
                            // Try left-down (cx-1, cy+1) first
                            if (cx == 10'd0) begin
                                // At left edge, skip to right diagonal
                                if (cx == GRID_WIDTH - 10'd1) begin
                                    // Both edges — stay in place
                                    ca_we         <= 1'b1;
                                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                    ca_write_data <= MAT_SAND;
                                    state         <= S_NEXT_PIXEL;
                                end else begin
                                    ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                    state        <= S_CHK_DIAG2_WT;
                                end
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_DIAG1_WT;
                            end
                        end else begin
                            // Try right-down (cx+1, cy+1) first
                            if (cx == GRID_WIDTH - 10'd1) begin
                                // At right edge, skip to left diagonal
                                if (cx == 10'd0) begin
                                    // Both edges — stay in place
                                    ca_we         <= 1'b1;
                                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                    ca_write_data <= MAT_SAND;
                                    state         <= S_NEXT_PIXEL;
                                end else begin
                                    ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                                    state        <= S_CHK_DIAG2_WT;
                                end
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_DIAG1_WT;
                            end
                        end
                    end else begin
                        // -----------------------------------------------
                        // Water: accumulation vs active spread
                        // - Below is WATER   → accumulate (write self back, no spread)
                        // - Below is WALL/SAND → active water (try horizontal spread)
                        // - Below is unknown  → accumulate (safe default)
                        // -----------------------------------------------
                        if (ca_read_data == MAT_WATER) begin
                            // Water on water — accumulate, stay stable
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            // Water on solid (WALL/SAND) — active water, try horizontal spread
                            // Side spread only targets EMPTY cells (not smoke/fire)
                            if (diag_side == 1'b0) begin
                                // Prioritize left
                                if (cx == 10'd0) begin
                                    // Left edge, try right directly
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                    state        <= S_CHK_SIDE2_WT;
                                end else begin
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                    state        <= S_CHK_SIDE1_WT;
                                end
                            end else begin
                                // Prioritize right
                                if (cx == GRID_WIDTH - 10'd1) begin
                                    // Right edge, try left directly
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                    state        <= S_CHK_SIDE2_WT;
                                end else begin
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                    state        <= S_CHK_SIDE1_WT;
                                end
                            end
                        end
                    end
                end
            end

            // ----------------------------------------------------------
            // Sand diagonal check 1 (first preferred side)
            // ----------------------------------------------------------
            S_CHK_DIAG1_WT: begin
                state <= S_CHK_DIAG1_EV;
            end

            S_CHK_DIAG1_EV: begin
                if (ca_read_data == MAT_EMPTY ||
                    ca_read_data == MAT_SMOKE ||
                    ca_read_data == MAT_FIRE) begin
                    // First diagonal is free — slide there.
                    if (diag_side == 1'b0)
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    else
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_SAND;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // First diagonal blocked — try the other side.
                    if (diag_side == 1'b0) begin
                        // Was trying left-down, now try right-down
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // No right side — stay in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_DIAG2_WT;
                        end
                    end else begin
                        // Was trying right-down, now try left-down
                        if (cx == 10'd0) begin
                            // No left side — stay in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_DIAG2_WT;
                        end
                    end
                end
            end

            // ----------------------------------------------------------
            // Sand diagonal check 2 (fallback side)
            // ----------------------------------------------------------
            S_CHK_DIAG2_WT: begin
                state <= S_CHK_DIAG2_EV;
            end

            S_CHK_DIAG2_EV: begin
                if (ca_read_data == MAT_EMPTY ||
                    ca_read_data == MAT_SMOKE ||
                    ca_read_data == MAT_FIRE) begin
                    // Fallback diagonal is free.
                    if (diag_side == 1'b0)
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    else
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_SAND;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Both diagonals blocked — sand stays in place.
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SAND;
                    state         <= S_NEXT_PIXEL;
                end
            end

            // ----------------------------------------------------------
            // Water horizontal spread (simplified — direct write, no two-phase)
            // Only active water (on solid below) reaches here.
            // Spread only into EMPTY cells.
            //
            // SIDE1_WT/EV: read priority side neighbor
            //   If EMPTY → write water to neighbor, done (back buffer clear = self gone)
            //   If blocked → read alternate side → SIDE2_WT/EV
            //
            // SIDE2_WT/EV:
            //   If EMPTY → write water to neighbor, done
            //   If blocked → write self back (water stays in place)
            // ----------------------------------------------------------
            S_CHK_SIDE1_WT: begin
                state <= S_CHK_SIDE1_EV;
            end

            S_CHK_SIDE1_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    // Priority side is empty — spread there directly
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                     ? (cy * GRID_WIDTH) + (cx - 10'd1)
                                     : (cy * GRID_WIDTH) + (cx + 10'd1);
                    ca_write_data <= MAT_WATER;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Priority side blocked — try alternate side
                    if (diag_side == 1'b0) begin
                        // Was trying left, now try right
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // At right edge, nowhere to go — stay
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_SIDE2_WT;
                        end
                    end else begin
                        // Was trying right, now try left
                        if (cx == 10'd0) begin
                            // At left edge, nowhere to go — stay
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_SIDE2_WT;
                        end
                    end
                end
            end

            S_CHK_SIDE2_WT: begin
                state <= S_CHK_SIDE2_EV;
            end

            S_CHK_SIDE2_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    // Alternate side is empty — spread there
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                     ? (cy * GRID_WIDTH) + (cx + 10'd1) // left failed → right
                                     : (cy * GRID_WIDTH) + (cx - 10'd1); // right failed → left
                    ca_write_data <= MAT_WATER;
                end else begin
                    // Both sides blocked — water stays in place
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_WATER;
                end
                state <= S_NEXT_PIXEL;
            end

            // ----------------------------------------------------------
            // Fire physics: fall through air/smoke, extinguish on water,
            // and burn in place above sand/wall instead of piling up.
            // ----------------------------------------------------------
            S_CHK_FIRE_BOT_WT: begin
                state <= S_CHK_FIRE_BOT_EV;
            end

            S_CHK_FIRE_BOT_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    // Fire falls straight down through empty space or smoke
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_FIRE;
                    state         <= S_NEXT_PIXEL;
                end else if (ca_read_data == MAT_WATER) begin
                    // Water below extinguishes this flame
                    state <= S_NEXT_PIXEL;
                end else begin
                    // Solid materials (sand/wall/fire) below — try diagonal spread
                    // Need to issue a read for DIAG1 first
                    if (diag_side == 1'b0) begin
                        // Try left-down first
                        if (cx == 10'd0) begin
                            // Left edge, skip to right-down
                            if (cx == GRID_WIDTH - 10'd1) begin
                                // Both edges trapped — burn in place
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_FIRE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_FIRE_DIAG2_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_FIRE_DIAG1_WT;
                        end
                    end else begin
                        // Try right-down first
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // Right edge, skip to left-down
                            if (cx == 10'd0) begin
                                // Both edges trapped — burn in place
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_FIRE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_FIRE_DIAG2_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_FIRE_DIAG1_WT;
                        end
                    end
                end
            end

            S_CHK_FIRE_DIAG1_WT: begin
                state <= S_CHK_FIRE_DIAG1_EV;
            end

            S_CHK_FIRE_DIAG1_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1)
                                    : ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    ca_write_data <= MAT_FIRE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    if (diag_side == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // Right edge, cannot try right-down — burn in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_FIRE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_FIRE_DIAG2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            // Left edge, cannot try left-down — burn in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_FIRE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_FIRE_DIAG2_WT;
                        end
                    end
                end
            end

            S_CHK_FIRE_DIAG2_WT: begin
                state <= S_CHK_FIRE_DIAG2_EV;
            end

            S_CHK_FIRE_DIAG2_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    // Fallback diagonal is free — spread there
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1)
                                    : ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    ca_write_data <= MAT_FIRE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Both diagonals blocked — try side spread
                    // Need to issue a read for SIDE1 first
                    if (diag_side == 1'b0) begin
                        // Try left side first
                        if (cx == 10'd0) begin
                            // Left edge, skip to right
                            if (cx == GRID_WIDTH - 10'd1) begin
                                // Both edges trapped — burn in place
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_FIRE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_FIRE_SIDE2_WT;
                            end
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_FIRE_SIDE1_WT;
                        end
                    end else begin
                        // Try right side first
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // Right edge, skip to left
                            if (cx == 10'd0) begin
                                // Both edges trapped — burn in place
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_FIRE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_FIRE_SIDE2_WT;
                            end
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_FIRE_SIDE1_WT;
                        end
                    end
                end
            end

            S_CHK_FIRE_SIDE1_WT: begin
                state <= S_CHK_FIRE_SIDE1_EV;
            end

            S_CHK_FIRE_SIDE1_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? (cy * GRID_WIDTH) + (cx - 10'd1)
                                    : (cy * GRID_WIDTH) + (cx + 10'd1);
                    ca_write_data <= MAT_FIRE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    if (diag_side == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            // Right edge, cannot try right — burn in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_FIRE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_FIRE_SIDE2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            // Left edge, cannot try left — burn in place
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_FIRE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_FIRE_SIDE2_WT;
                        end
                    end
                end
            end

            S_CHK_FIRE_SIDE2_WT: begin
                state <= S_CHK_FIRE_SIDE2_EV;
            end

            S_CHK_FIRE_SIDE2_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    // Side spread succeeded
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? (cy * GRID_WIDTH) + (cx + 10'd1)
                                    : (cy * GRID_WIDTH) + (cx - 10'd1);
                    ca_write_data <= MAT_FIRE;
                end else begin
                    // Both sides blocked — burn in place (register fire block root)
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_FIRE;
                end
                state <= S_NEXT_PIXEL;
            end

            // ----------------------------------------------------------
            // Smoke physics: drift upward, spread diagonally when blocked,
            // and randomly decay to approximate finite lifetime.
            // ----------------------------------------------------------
            S_CHK_SMK_UP_WT: begin
                state <= S_CHK_SMK_UP_EV;
            end

            S_CHK_SMK_UP_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy - 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SMOKE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    if (diag_side == 1'b0) begin
                        if (cx == 10'd0) begin
                            if (cx == GRID_WIDTH - 10'd1) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_SMOKE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_SMK_DIAG2_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_SMK_DIAG1_WT;
                        end
                    end else begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            if (cx == 10'd0) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_SMOKE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_SMK_DIAG2_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_SMK_DIAG1_WT;
                        end
                    end
                end
            end

            S_CHK_SMK_DIAG1_WT: begin
                state <= S_CHK_SMK_DIAG1_EV;
            end

            S_CHK_SMK_DIAG1_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1)
                                    : ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    ca_write_data <= MAT_SMOKE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    if (diag_side == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SMOKE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_SMK_DIAG2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SMOKE;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_CHK_SMK_DIAG2_WT;
                        end
                    end
                end
            end

            S_CHK_SMK_DIAG2_WT: begin
                state <= S_CHK_SMK_DIAG2_EV;
            end

            S_CHK_SMK_DIAG2_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (diag_side == 1'b0)
                                    ? ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1)
                                    : ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    ca_write_data <= MAT_SMOKE;
                end else begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SMOKE;
                end
                state <= S_NEXT_PIXEL;
            end

            // ----------------------------------------------------------
            // 从下到上推进像素
            // ----------------------------------------------------------
            S_NEXT_PIXEL: begin
                if (cx == GRID_WIDTH - 10'd1) begin
                    cx <= 10'd0;
                    if (cy == 10'd0) begin
                        state <= S_IDLE;
                    end else begin
                        cy    <= cy - 10'd1;
                        state <= S_SWEEP_READ;
                    end
                end else begin
                    cx    <= cx + 10'd1;
                    state <= S_SWEEP_READ;
                end
            end

            default: state <= S_IDLE;

        endcase
    end
end

//=======================================================
// VGA Driver Instantiation
//=======================================================
vga_driver DUT (
    .clock(vga_pll),
    .reset(vga_reset),
    .color_in(final_vga_color),
    .next_x(next_x),
    .next_y(next_y),
    .hsync(VGA_HS),
    .vsync(VGA_VS),
    .red(VGA_R),
    .green(VGA_G),
    .blue(VGA_B),
    .sync(VGA_SYNC_N),
    .clk(VGA_CLK),
    .blank(VGA_BLANK_N)
);

//=======================================================
// Qsys System Instantiation
//=======================================================
Computer_System The_System (
    ////////////////////////////////////
    // FPGA Side
    ////////////////////////////////////
    .vga_pio_locked_export          (vga_pll_lock),
    .vga_pio_outclk0_clk            (vga_pll),
    .m10k_pll_locked_export         (M10k_pll_locked),
    .m10k_pll_outclk0_clk           (M10k_pll),

    // Global signals
    .system_pll_ref_clk_clk         (CLOCK_50),
    .system_pll_ref_reset_reset     (1'b0),

    // Sandbox PIOs
    .brush_x_pio_external_connection_export   (brush_x),
    .brush_y_pio_external_connection_export   (brush_y),
    .brush_mat_pio_external_connection_export (brush_mat),
    .brush_we_pio_external_connection_export  (brush_we),
    .timer_pio_external_connection_export     (hw_cycle_count),
    .key_pio_external_connection_export       (hps_keys),

    ////////////////////////////////////
    // HPS Side
    ////////////////////////////////////
    // DDR3 SDRAM
    .memory_mem_a           (HPS_DDR3_ADDR),
    .memory_mem_ba          (HPS_DDR3_BA),
    .memory_mem_ck          (HPS_DDR3_CK_P),
    .memory_mem_ck_n        (HPS_DDR3_CK_N),
    .memory_mem_cke         (HPS_DDR3_CKE),
    .memory_mem_cs_n        (HPS_DDR3_CS_N),
    .memory_mem_ras_n       (HPS_DDR3_RAS_N),
    .memory_mem_cas_n       (HPS_DDR3_CAS_N),
    .memory_mem_we_n        (HPS_DDR3_WE_N),
    .memory_mem_reset_n     (HPS_DDR3_RESET_N),
    .memory_mem_dq          (HPS_DDR3_DQ),
    .memory_mem_dqs         (HPS_DDR3_DQS_P),
    .memory_mem_dqs_n       (HPS_DDR3_DQS_N),
    .memory_mem_odt         (HPS_DDR3_ODT),
    .memory_mem_dm          (HPS_DDR3_DM),
    .memory_oct_rzqin       (HPS_DDR3_RZQ),

    // Ethernet
    .hps_io_hps_io_gpio_inst_GPIO35     (HPS_ENET_INT_N),
    .hps_io_hps_io_emac1_inst_TX_CLK    (HPS_ENET_GTX_CLK),
    .hps_io_hps_io_emac1_inst_TXD0     (HPS_ENET_TX_DATA[0]),
    .hps_io_hps_io_emac1_inst_TXD1     (HPS_ENET_TX_DATA[1]),
    .hps_io_hps_io_emac1_inst_TXD2     (HPS_ENET_TX_DATA[2]),
    .hps_io_hps_io_emac1_inst_TXD3     (HPS_ENET_TX_DATA[3]),
    .hps_io_hps_io_emac1_inst_RXD0     (HPS_ENET_RX_DATA[0]),
    .hps_io_hps_io_emac1_inst_MDIO     (HPS_ENET_MDIO),
    .hps_io_hps_io_emac1_inst_MDC      (HPS_ENET_MDC),
    .hps_io_hps_io_emac1_inst_RX_CTL   (HPS_ENET_RX_DV),
    .hps_io_hps_io_emac1_inst_TX_CTL   (HPS_ENET_TX_EN),
    .hps_io_hps_io_emac1_inst_RX_CLK   (HPS_ENET_RX_CLK),
    .hps_io_hps_io_emac1_inst_RXD1     (HPS_ENET_RX_DATA[1]),
    .hps_io_hps_io_emac1_inst_RXD2     (HPS_ENET_RX_DATA[2]),
    .hps_io_hps_io_emac1_inst_RXD3     (HPS_ENET_RX_DATA[3]),

    // Flash
    .hps_io_hps_io_qspi_inst_IO0    (HPS_FLASH_DATA[0]),
    .hps_io_hps_io_qspi_inst_IO1    (HPS_FLASH_DATA[1]),
    .hps_io_hps_io_qspi_inst_IO2    (HPS_FLASH_DATA[2]),
    .hps_io_hps_io_qspi_inst_IO3    (HPS_FLASH_DATA[3]),
    .hps_io_hps_io_qspi_inst_SS0    (HPS_FLASH_NCSO),
    .hps_io_hps_io_qspi_inst_CLK    (HPS_FLASH_DCLK),

    // Accelerometer
    .hps_io_hps_io_gpio_inst_GPIO61 (HPS_GSENSOR_INT),

    // General Purpose I/O
    .hps_io_hps_io_gpio_inst_GPIO40 (HPS_GPIO[0]),
    .hps_io_hps_io_gpio_inst_GPIO41 (HPS_GPIO[1]),

    // I2C
    .hps_io_hps_io_gpio_inst_GPIO48 (HPS_I2C_CONTROL),
    .hps_io_hps_io_i2c0_inst_SDA    (HPS_I2C1_SDAT),
    .hps_io_hps_io_i2c0_inst_SCL    (HPS_I2C1_SCLK),
    .hps_io_hps_io_i2c1_inst_SDA    (HPS_I2C2_SDAT),
    .hps_io_hps_io_i2c1_inst_SCL    (HPS_I2C2_SCLK),

    // Pushbutton
    .hps_io_hps_io_gpio_inst_GPIO54 (HPS_KEY),

    // LED
    .hps_io_hps_io_gpio_inst_GPIO53 (HPS_LED),

    // SD Card
    .hps_io_hps_io_sdio_inst_CMD    (HPS_SD_CMD),
    .hps_io_hps_io_sdio_inst_D0     (HPS_SD_DATA[0]),
    .hps_io_hps_io_sdio_inst_D1     (HPS_SD_DATA[1]),
    .hps_io_hps_io_sdio_inst_CLK    (HPS_SD_CLK),
    .hps_io_hps_io_sdio_inst_D2     (HPS_SD_DATA[2]),
    .hps_io_hps_io_sdio_inst_D3     (HPS_SD_DATA[3]),

    // SPI
    .hps_io_hps_io_spim1_inst_CLK   (HPS_SPIM_CLK),
    .hps_io_hps_io_spim1_inst_MOSI  (HPS_SPIM_MOSI),
    .hps_io_hps_io_spim1_inst_MISO  (HPS_SPIM_MISO),
    .hps_io_hps_io_spim1_inst_SS0   (HPS_SPIM_SS),

    // UART
    .hps_io_hps_io_uart0_inst_RX    (HPS_UART_RX),
    .hps_io_hps_io_uart0_inst_TX    (HPS_UART_TX),

    // USB
    .hps_io_hps_io_gpio_inst_GPIO09 (HPS_CONV_USB_N),
    .hps_io_hps_io_usb1_inst_D0     (HPS_USB_DATA[0]),
    .hps_io_hps_io_usb1_inst_D1     (HPS_USB_DATA[1]),
    .hps_io_hps_io_usb1_inst_D2     (HPS_USB_DATA[2]),
    .hps_io_hps_io_usb1_inst_D3     (HPS_USB_DATA[3]),
    .hps_io_hps_io_usb1_inst_D4     (HPS_USB_DATA[4]),
    .hps_io_hps_io_usb1_inst_D5     (HPS_USB_DATA[5]),
    .hps_io_hps_io_usb1_inst_D6     (HPS_USB_DATA[6]),
    .hps_io_hps_io_usb1_inst_D7     (HPS_USB_DATA[7]),
    .hps_io_hps_io_usb1_inst_CLK    (HPS_USB_CLKOUT),
    .hps_io_hps_io_usb1_inst_STP    (HPS_USB_STP),
    .hps_io_hps_io_usb1_inst_DIR    (HPS_USB_DIR),
    .hps_io_hps_io_usb1_inst_NXT    (HPS_USB_NXT)
);

endmodule // end top level

//=======================================================
// Sub-Modules
//=======================================================

// True Dual-Port M10K memory: 320x240 cells, 4 bits each
module M10K_76800_4 (
    input clk,
    // Port A: VGA read-only
    input  [16:0] addr_a,
    output reg [3:0] q_a,
    // Port B: CA engine read/write
    input  [16:0] addr_b,
    input  [3:0]  d_b,
    input         we_b,
    output reg [3:0] q_b
);
    reg [3:0] mem [76799:0] /* synthesis ramstyle = "no_rw_check, M10K" */;

    // Port A (VGA — read only)
    always @(posedge clk) begin
        q_a <= mem[addr_a];
    end

    // Port B (CA engine / HPS — read + write)
    always @(posedge clk) begin
        if (we_b) mem[addr_b] <= d_b;
        q_b <= mem[addr_b];
    end
endmodule

// VGA Driver (unchanged)
module vga_driver (
    input wire clock,
    input wire reset,
    input [7:0] color_in,
    output [9:0] next_x,
    output [9:0] next_y,
    output wire hsync,
    output wire vsync,
    output [7:0] red,
    output [7:0] green,
    output [7:0] blue,
    output sync,
    output clk,
    output blank
);
    parameter [9:0] H_ACTIVE = 10'd_639;
    parameter [9:0] H_FRONT  = 10'd_15;
    parameter [9:0] H_PULSE  = 10'd_95;
    parameter [9:0] H_BACK   = 10'd_47;

    parameter [9:0] V_ACTIVE = 10'd_479;
    parameter [9:0] V_FRONT  = 10'd_9;
    parameter [9:0] V_PULSE  = 10'd_1;
    parameter [9:0] V_BACK   = 10'd_32;

    parameter LOW  = 1'b_0;
    parameter HIGH = 1'b_1;

    parameter [7:0] H_ACTIVE_STATE = 8'd_0;
    parameter [7:0] H_FRONT_STATE  = 8'd_1;
    parameter [7:0] H_PULSE_STATE  = 8'd_2;
    parameter [7:0] H_BACK_STATE   = 8'd_3;

    parameter [7:0] V_ACTIVE_STATE = 8'd_0;
    parameter [7:0] V_FRONT_STATE  = 8'd_1;
    parameter [7:0] V_PULSE_STATE  = 8'd_2;
    parameter [7:0] V_BACK_STATE   = 8'd_3;

    reg hysnc_reg;
    reg vsync_reg;
    reg [7:0] red_reg;
    reg [7:0] green_reg;
    reg [7:0] blue_reg;
    reg line_done;
    reg [9:0] h_counter;
    reg [9:0] v_counter;
    reg [7:0] h_state;
    reg [7:0] v_state;

    always @(posedge clock) begin
        if (reset) begin
            h_counter <= 10'd_0;
            v_counter <= 10'd_0;
            h_state   <= H_ACTIVE_STATE;
            v_state   <= V_ACTIVE_STATE;
            line_done <= LOW;
        end else begin
            if (h_state == H_ACTIVE_STATE) begin
                h_counter <= (h_counter == H_ACTIVE) ? 10'd_0 : (h_counter + 10'd_1);
                hysnc_reg <= HIGH;
                line_done <= LOW;
                h_state   <= (h_counter == H_ACTIVE) ? H_FRONT_STATE : H_ACTIVE_STATE;
            end
            if (h_state == H_FRONT_STATE) begin
                h_counter <= (h_counter == H_FRONT) ? 10'd_0 : (h_counter + 10'd_1);
                hysnc_reg <= HIGH;
                h_state   <= (h_counter == H_FRONT) ? H_PULSE_STATE : H_FRONT_STATE;
            end
            if (h_state == H_PULSE_STATE) begin
                h_counter <= (h_counter == H_PULSE) ? 10'd_0 : (h_counter + 10'd_1);
                hysnc_reg <= LOW;
                h_state   <= (h_counter == H_PULSE) ? H_BACK_STATE : H_PULSE_STATE;
            end
            if (h_state == H_BACK_STATE) begin
                h_counter <= (h_counter == H_BACK) ? 10'd_0 : (h_counter + 10'd_1);
                hysnc_reg <= HIGH;
                h_state   <= (h_counter == H_BACK) ? H_ACTIVE_STATE : H_BACK_STATE;
                line_done <= (h_counter == (H_BACK - 1)) ? HIGH : LOW;
            end
            if (v_state == V_ACTIVE_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_ACTIVE) ? 10'd_0 : (v_counter + 10'd_1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_ACTIVE) ? V_FRONT_STATE : V_ACTIVE_STATE) : V_ACTIVE_STATE;
            end
            if (v_state == V_FRONT_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_FRONT) ? 10'd_0 : (v_counter + 10'd_1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_FRONT) ? V_PULSE_STATE : V_FRONT_STATE) : V_FRONT_STATE;
            end
            if (v_state == V_PULSE_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_PULSE) ? 10'd_0 : (v_counter + 10'd_1)) : v_counter;
                vsync_reg <= LOW;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_PULSE) ? V_BACK_STATE : V_PULSE_STATE) : V_PULSE_STATE;
            end
            if (v_state == V_BACK_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_BACK) ? 10'd_0 : (v_counter + 10'd_1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_BACK) ? V_ACTIVE_STATE : V_BACK_STATE) : V_BACK_STATE;
            end
            red_reg   <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[7:5], 5'd_0} : 8'd_0) : 8'd_0;
            green_reg <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[4:2], 5'd_0} : 8'd_0) : 8'd_0;
            blue_reg  <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[1:0], 6'd_0} : 8'd_0) : 8'd_0;
        end
    end

    assign hsync  = hysnc_reg;
    assign vsync  = vsync_reg;
    assign red    = red_reg;
    assign green  = green_reg;
    assign blue   = blue_reg;
    assign clk    = clock;
    assign sync   = 1'b_0;
    assign blank  = hysnc_reg & vsync_reg;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd_0;
    assign next_y = (v_state == V_ACTIVE_STATE)  ? v_counter : 10'd_0;

endmodule
