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
parameter MAX_CELLS   = 17'd76800; // 320 * 240

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

// Write priority MUX: HPS brush overrides CA engine
wire        we_comb   = brush_we ? 1'b1    : ca_we;
wire [16:0] addr_comb = brush_we ? hps_write_addr : ca_write_addr;
wire [3:0]  data_comb = brush_we ? brush_mat      : ca_write_data;

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
    .we_b  ( (active_buffer == 1'b1) ? we_comb   : 1'b0       ),
    .addr_b( (active_buffer == 1'b1) ? addr_comb : ca_read_addr),
    .d_b(data_comb),
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
    .we_b  ( (active_buffer == 1'b0) ? we_comb   : 1'b0       ),
    .addr_b( (active_buffer == 1'b0) ? addr_comb : ca_read_addr),
    .d_b(data_comb),
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
// 火焰动态显示：
// - MAT_FIRE 本体在红/橙之间闪烁
// - 与火焰相邻(北/西邻格)的空格在背景黑与暗红之间循环，形成简单火苗边缘
(* ramstyle = "MLAB, no_rw_check" *) reg [3:0] fire_row_north [0:319];
reg [3:0] north_mat_r;
always @(posedge M10k_pll) begin
    north_mat_r <= fire_row_north[grid_read_x];
    fire_row_north[grid_read_x] <= vga_data_out;
end

reg [8:0] fire_prev_gx;
reg [8:0] fire_prev_gy;
reg [3:0] fire_prev_mat;
always @(posedge M10k_pll) begin
    fire_prev_gx  <= grid_read_x;
    fire_prev_gy  <= grid_read_y;
    fire_prev_mat <= vga_data_out;
end

wire fire_same_row   = (grid_read_y == fire_prev_gy);
wire west_is_fire    = fire_same_row && (grid_read_x > 9'd0) &&
                       (grid_read_x == fire_prev_gx + 9'd1) && (fire_prev_mat == MAT_FIRE);
wire north_is_fire   = (north_mat_r == MAT_FIRE);
wire fire_neighbor   = north_is_fire || west_is_fire;
reg [23:0] fire_pulse_ctr;
always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n)
        fire_pulse_ctr <= 24'd0;
    else
        fire_pulse_ctr <= fire_pulse_ctr + 24'd1;
end

wire [15:0] fire_phase = hw_cycle_count[19:4] ^ hw_cycle_count[31:20] ^
                         {grid_read_x[7:0], grid_read_y[7:0]} ^ fire_pulse_ctr[23:8];
wire fire_core_hot   = fire_phase[0];
wire fire_glow_tick  = fire_phase[1] ^ fire_phase[6];

reg [7:0] final_vga_color;
always @(*) begin
    case(vga_data_out)
        MAT_EMPTY: final_vga_color = fire_neighbor ?
                                     (fire_glow_tick ? 8'b000_000_00 : 8'b100_000_00) :
                                     8'b000_000_00; // Black
        MAT_SAND:  final_vga_color = 8'b111_110_00; // Yellow
        MAT_WATER: final_vga_color = 8'b000_010_11; // Blue
        MAT_WALL:  final_vga_color = 8'b011_011_01; // Gray
        MAT_FIRE:  final_vga_color = fire_core_hot ? 8'b111_010_00 : 8'b101_000_00;
        MAT_SMOKE: final_vga_color = fire_glow_tick ? 8'b100_100_10 : 8'b010_010_01;
        default:   final_vga_color = 8'b000_000_00;
    endcase
end

//=======================================================
// LFSR - 16-bit Linear Feedback Shift Register
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
// Water rules:
//   - Fall straight down if (x, y+1) is empty.
//   - If blocked below, spread left or right using random_bit.
//=======================================================

// FIX: Extended state encoding to cover sand diagonals + water spread
localparam S_IDLE         = 4'd0,
           S_CLEAR        = 4'd1,
           S_SWEEP_READ   = 4'd2,
           S_SWEEP_WAIT   = 4'd3,
           S_SWEEP_EVAL   = 4'd4,
           S_CHK_BOT_WT   = 4'd5,   // wait 1 cycle after issuing read of (x, y+1)
           S_CHK_BOT_EV   = 4'd6,   // evaluate (x, y+1) result
           S_CHK_DIAG1_WT = 4'd7,   // sand: wait for first diagonal read
           S_CHK_DIAG1_EV = 4'd8,   // sand: evaluate first diagonal
           S_CHK_DIAG2_WT = 4'd9,   // sand: wait for second diagonal read
           S_CHK_DIAG2_EV = 4'd10,  // sand: evaluate second diagonal
           S_CHK_SIDE1_WT = 4'd11,  // water: wait for first side read
           S_CHK_SIDE1_EV = 4'd12,  // water: evaluate first side
           S_CHK_SIDE2_WT = 4'd13,  // water: wait for second side read
           S_CHK_SIDE2_EV = 4'd14,  // water: evaluate second side
           S_NEXT_PIXEL   = 4'd15;

reg [3:0]  state;
reg [16:0] clear_addr;
reg [9:0]  cx;
reg [9:0]  cy;
reg [3:0]  current_mat;
reg        diag_side;
reg        water_moving;       // 标记水已确认要移动，下一拍写邻居
reg [16:0] water_target_addr;  // 水要移动到的目标地址

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
        water_moving      <= 1'b0;
        water_target_addr <= 17'd0;
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
                    cy    <= GRID_HEIGHT - 10'd1; // 从底行开始向上扫
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
                        // Fire is static for now: keep cell in place.
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_FIRE;
                        state         <= S_NEXT_PIXEL;
                    end

                    MAT_SMOKE: begin
                        // Smoke is static for now: keep cell in place.
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_SMOKE;
                        state         <= S_NEXT_PIXEL;
                    end

                    MAT_SAND: begin
                        if (cy == GRID_HEIGHT - 10'd1) begin
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
                        if (cy == GRID_HEIGHT - 10'd1) begin
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
                if (ca_read_data == MAT_EMPTY) begin
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
                        // 水：下方被阻挡
                        // 步骤1：立即写回自身，确保水不消失
                        // 步骤2：同时发出横向邻居读请求（读前台=上一帧状态）
                        //        diag_side=0 优先读左，diag_side=1 优先读右
                        // -----------------------------------------------
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx; // 先保住自己
                        ca_write_data <= MAT_WATER;

                        if (cx == 10'd0 && cx == GRID_WIDTH - 10'd1) begin
                            // 宽度为1，无处可去，直接结束
                            state <= S_NEXT_PIXEL;
                        end else if (diag_side == 1'b0) begin
                            // 优先尝试左
                            if (cx == 10'd0) begin
                                // 左边界，直接跳去读右
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_SIDE2_WT; // 用side2作为"唯一尝试"
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_SIDE1_WT;
                            end
                        end else begin
                            // 优先尝试右
                            if (cx == GRID_WIDTH - 10'd1) begin
                                // 右边界，直接跳去读左
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_CHK_SIDE2_WT; // 用side2作为"唯一尝试"
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_CHK_SIDE1_WT;
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
                if (ca_read_data == MAT_EMPTY) begin
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
                if (ca_read_data == MAT_EMPTY) begin
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
            // 水横向扩散（方案一：读前台上一帧状态，延迟一帧）
            //
            // 进入前提（来自 S_CHK_BOT_EV）：
            //   - 水下方被阻
            //   - 自身已写回后台：back[(cy,cx)] = WATER
            //   - ca_read_addr 已设置为优先侧邻居地址
            //   - water_moving = 0
            //
            // 流程：
            //   SIDE1_WT/EV：读优先侧前台邻居
            //     若空：把自身后台改为 EMPTY，记录目标，water_moving=1，进 SIDE2_WT/EV 写邻居
            //     若非空：读另一侧，进 SIDE2_WT/EV 继续判断
            //
            //   SIDE2_WT/EV：
            //     若 water_moving=1：写 WATER 到 water_target_addr，结束
            //     若 water_moving=0：读另一侧前台邻居
            //       若空：把自身后台改为 EMPTY，记录目标，water_moving=1，再循环一次 SIDE2
            //       若非空：两侧都堵，自身已保留，结束
            // ----------------------------------------------------------
            S_CHK_SIDE1_WT: begin
                state <= S_CHK_SIDE1_EV;
            end

            S_CHK_SIDE1_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    // 优先侧为空：撤销自身，记录目标，下一拍写邻居
                    ca_we             <= 1'b1;
                    ca_write_addr     <= (cy * GRID_WIDTH) + cx;
                    ca_write_data     <= MAT_EMPTY;
                    water_target_addr <= (diag_side == 1'b0)
                                        ? (cy * GRID_WIDTH) + (cx - 10'd1)
                                        : (cy * GRID_WIDTH) + (cx + 10'd1);
                    water_moving      <= 1'b1;
                    state             <= S_CHK_SIDE2_WT;
                end else begin
                    // 优先侧被阻，发出另一侧读请求
                    if (diag_side == 1'b0) begin
                        // 优先左失败 → 读右
                        if (cx == GRID_WIDTH - 10'd1) begin
                            state <= S_NEXT_PIXEL; // 右边界，两侧都不行，自身已保留
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_CHK_SIDE2_WT;
                        end
                    end else begin
                        // 优先右失败 → 读左
                        if (cx == 10'd0) begin
                            state <= S_NEXT_PIXEL; // 左边界，自身已保留
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
                if (water_moving) begin
                    // 已确认移动：把水写到目标邻居格
                    ca_we         <= 1'b1;
                    ca_write_addr <= water_target_addr;
                    ca_write_data <= MAT_WATER;
                    water_moving  <= 1'b0;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // 读另一侧（备选侧）的前台结果
                    if (ca_read_data == MAT_EMPTY) begin
                        // 备选侧为空：撤销自身，记录目标，下一拍写邻居
                        ca_we             <= 1'b1;
                        ca_write_addr     <= (cy * GRID_WIDTH) + cx;
                        ca_write_data     <= MAT_EMPTY;
                        water_target_addr <= (diag_side == 1'b0)
                                            ? (cy * GRID_WIDTH) + (cx + 10'd1) // 左失败→右
                                            : (cy * GRID_WIDTH) + (cx - 10'd1); // 右失败→左
                        water_moving      <= 1'b1;
                        state             <= S_CHK_SIDE2_WT; // 再走一次 SIDE2 来写邻居
                    end else begin
                        // 两侧都堵，自身已保留，结束
                        state <= S_NEXT_PIXEL;
                    end
                end
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
