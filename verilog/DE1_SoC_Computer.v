module DE1_SoC_Computer (
	////////////////////////////////////
	// FPGA Pins
	////////////////////////////////////

	// Clock pins
	input							CLOCK_50,
	input							CLOCK2_50,
	input							CLOCK3_50,
	input							CLOCK4_50,

	// ADC
	inout							ADC_CS_N,
	output							ADC_DIN,
	input							ADC_DOUT,
	output							ADC_SCLK,

	// Audio
	input							AUD_ADCDAT,
	inout							AUD_ADCLRCK,
	inout							AUD_BCLK,
	output							AUD_DACDAT,
	inout							AUD_DACLRCK,
	output							AUD_XCK,

	// SDRAM
	output 		[12: 0]	DRAM_ADDR,
	output		[ 1: 0]	DRAM_BA,
	output							DRAM_CAS_N,
	output							DRAM_CKE,
	output							DRAM_CLK,
	output							DRAM_CS_N,
	inout			[15: 0]	DRAM_DQ,
	output							DRAM_LDQM,
	output							DRAM_RAS_N,
	output							DRAM_UDQM,
	output							DRAM_WE_N,

	// I2C Bus for Configuration of the Audio and Video-In Chips
	output							FPGA_I2C_SCLK,
	inout							FPGA_I2C_SDAT,

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
	input							IRDA_RXD,
	output							IRDA_TXD,

	// Pushbuttons
	input			[ 3: 0]	KEY,

	// LEDs
	output		[ 9: 0]	LEDR,

	// PS2 Ports
	inout							PS2_CLK,
	inout							PS2_DAT,
	inout							PS2_CLK2,
	inout							PS2_DAT2,

	// Slider Switches
	input			[ 9: 0]	SW,

	// Video-In
	input							TD_CLK27,
	input			[ 7: 0]	TD_DATA,
	input							TD_HS,
	output							TD_RESET_N,
	input							TD_VS,

	// VGA
	output		[ 7: 0]	VGA_B,
	output							VGA_BLANK_N,
	output							VGA_CLK,
	output		[ 7: 0]	VGA_G,
	output							VGA_HS,
	output		[ 7: 0]	VGA_R,
	output							VGA_SYNC_N,
	output							VGA_VS,

	////////////////////////////////////
	// HPS Pins
	////////////////////////////////////
	
	// DDR3 SDRAM
	output		[14: 0]	HPS_DDR3_ADDR,
	output		[ 2: 0] HPS_DDR3_BA,
	output							HPS_DDR3_CAS_N,
	output							HPS_DDR3_CKE,
	output							HPS_DDR3_CK_N,
	output							HPS_DDR3_CK_P,
	output							HPS_DDR3_CS_N,
	output		[ 3: 0]	HPS_DDR3_DM,
	inout			[31: 0]	HPS_DDR3_DQ,
	inout			[ 3: 0]	HPS_DDR3_DQS_N,
	inout			[ 3: 0]	HPS_DDR3_DQS_P,
	output							HPS_DDR3_ODT,
	output							HPS_DDR3_RAS_N,
	output							HPS_DDR3_RESET_N,
	input							HPS_DDR3_RZQ,
	output							HPS_DDR3_WE_N,

	// Ethernet
	output							HPS_ENET_GTX_CLK,
	inout							HPS_ENET_INT_N,
	output							HPS_ENET_MDC,
	inout							HPS_ENET_MDIO,
	input							HPS_ENET_RX_CLK,
	input		[ 3: 0]	HPS_ENET_RX_DATA,
	input							HPS_ENET_RX_DV,
	output		[ 3: 0]	HPS_ENET_TX_DATA,
	output							HPS_ENET_TX_EN,

	// Flash
	inout			[ 3: 0]	HPS_FLASH_DATA,
	output							HPS_FLASH_DCLK,
	output							HPS_FLASH_NCSO,

	// Accelerometer
	inout							HPS_GSENSOR_INT,

	// General Purpose I/O
	inout			[ 1: 0]	HPS_GPIO,

	// I2C
	inout							HPS_I2C_CONTROL,
	inout							HPS_I2C1_SCLK,
	inout							HPS_I2C1_SDAT,
	inout							HPS_I2C2_SCLK,
	inout							HPS_I2C2_SDAT,

	// Pushbutton
	inout							HPS_KEY,

	// LED
	inout							HPS_LED,

	// SD Card
	output							HPS_SD_CLK,
	inout							HPS_SD_CMD,
	inout		[ 3: 0]	HPS_SD_DATA,

	// SPI
	output							HPS_SPIM_CLK,
	input							HPS_SPIM_MISO,
	output							HPS_SPIM_MOSI,
	inout							HPS_SPIM_SS,

	// UART
	input							HPS_UART_RX,
	output							HPS_UART_TX,

	// USB
	inout							HPS_CONV_USB_N,
	input							HPS_USB_CLKOUT,
	inout		[ 7: 0]	HPS_USB_DATA,
	input							HPS_USB_DIR,
	input							HPS_USB_NXT,
	output							HPS_USB_STP
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
wire [4:0] brush_mat;
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

// Material Definitions (5-bit: values 0-31)
parameter MAT_EMPTY        = 5'd0;
parameter MAT_SAND         = 5'd1;
parameter MAT_WATER        = 5'd2;
parameter MAT_WALL         = 5'd3;
parameter MAT_FIRE         = 5'd4;
parameter MAT_SMOKE        = 5'd5;
parameter MAT_WATER_ACTIVE = 5'd6;  // Active/spreading water state
// Fire flame layers: 9 unique values (7-15)
parameter MAT_FIRE_1  = 5'd7;
parameter MAT_FIRE_2  = 5'd8;
parameter MAT_FIRE_3  = 5'd9;
parameter MAT_FIRE_4  = 5'd10;
parameter MAT_FIRE_5  = 5'd11;
parameter MAT_FIRE_6  = 5'd12;
parameter MAT_FIRE_7  = 5'd13;
parameter MAT_FIRE_8  = 5'd14;
parameter MAT_FIRE_9  = 5'd15;
// New solid materials
parameter MAT_GRASS        = 5'd16;  // Grass block (falls, becomes MAT_GRASS_STATIC on dirt)
parameter MAT_DIRT         = 5'd17;  // Dirt block (static, like wall)
parameter MAT_GRASS_STATIC = 5'd18;  // Static grass (resting on dirt, or placed like dirt)

// VGA -> Grid coordinate mapping (640x480 -> 320x240, divide by 2)
wire [8:0] grid_read_x = next_x[9:1]; 
wire [8:0] grid_read_y = next_y[9:1]; 
wire [16:0] vga_read_addr = (grid_read_y * GRID_WIDTH) + grid_read_x;

// Ping-Pong Buffer Control
//   active_buffer=0 => Buffer A is FRONT (displayed by VGA), Buffer B is BACK (written by CA)
//   active_buffer=1 => Buffer B is FRONT (displayed by VGA), Buffer A is BACK (written by CA)
reg  active_buffer;
reg  [16:0] ca_read_addr;
reg  [16:0] ca_write_addr;
reg  [4:0]  ca_write_data;
reg         ca_we;
wire [4:0]  ca_read_data;

wire [4:0] vga_data_out;
wire [4:0] vga_q_A, vga_q_B;
wire [4:0] ca_q_A, ca_q_B;

// HPS brush address
wire [16:0] hps_write_addr = (brush_y * GRID_WIDTH) + brush_x;

// -------------------------------------------------------
// Brush CDC synchronizer (metastability hardening)
// brush_we is async from HPS (Avalon PIO domain)
// 2-stage sync + edge detector → clean 1-cycle pulse in M10k_pll domain
// -------------------------------------------------------
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

// Brush address and data: single-register sync into M10k_pll domain
reg         [16:0] brush_addr_sync;
reg         [4:0]  brush_data_sync;

// Clear trigger: HPS sends brush at y=250 with brush_mat=5 (sentinel)
// VGA scanline y=250 is outside visible area, so this write is off-screen
// In verilog: brush_y is 10-bit (0-1023), 250 maps to grid y=250
reg         clear_pending;
wire        clear_pending_done;

// State machine signals this wire to clear clear_pending
assign clear_pending_done = (state == S_CLEAR && clear_addr == MAX_CELLS - 17'd1 && clear_pending);

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        brush_addr_sync <= 17'd0;
        brush_data_sync <= 5'd0;
        clear_pending   <= 1'b0;
    end else begin
        brush_addr_sync <= hps_write_addr;
        brush_data_sync <= brush_mat;
        // Clear trigger: HPS writes y=250 with brush_mat=5 as sentinel
        // Address = 250*320 = 80000 >= MAX_CELLS(76800), so out-of-bounds
        if (brush_we_edge && (brush_mat == MAT_SMOKE) && (hps_write_addr >= MAX_CELLS))
            clear_pending <= 1'b1;
        else if (clear_pending_done)
            clear_pending <= 1'b0;
    end
end

// CA MUX (ca_* is already synchronous to M10k_pll)
wire        ca_we_mux   = ca_we;
wire [16:0] ca_addr_mux = ca_write_addr;
wire [4:0]  ca_data_mux = ca_write_data;

// Fire brush priority: if painting FIRE onto blocked/burning cells, skip the write
// Use vga_data_out (from Port A, the displayed buffer) to check current value
// If paint FIRE onto WALL/SAND/WATER/WATER_ACTIVE/FIRE/FIRE_* -> block the write

// Final merge: brush_we_edge overrides CA (user intent > physics)
// But if painting FIRE onto blocked/burning cells, block it
wire is_fire_brush = (brush_data_sync == MAT_FIRE);
wire is_blocked_for_fire = is_fire_brush & (
    (vga_data_out == MAT_WALL) |
    (vga_data_out == MAT_SAND) |
    (vga_data_out == MAT_WATER) |
    (vga_data_out == MAT_WATER_ACTIVE) |
    (vga_data_out == MAT_FIRE) |
    (vga_data_out >= MAT_FIRE_1)
);

wire brush_allowed = brush_we_edge & ~is_blocked_for_fire;
wire        we_final   = brush_allowed ? 1'b1    : ca_we_mux;
wire [16:0] addr_final = brush_allowed ? brush_addr_sync : ca_addr_mux;
wire [4:0]  data_final = brush_allowed ? brush_data_sync  : ca_data_mux;

// -------------------------------------------------------
// Dual-port routing
// active_buffer=0: A=FRONT, B=BACK
//   grid_A Port B => CA reads A (no write); grid_B Port B => CA writes B
// active_buffer=1: B=FRONT, A=BACK
//   grid_A Port B => CA writes A; grid_B Port B => CA reads B (no write)
// -------------------------------------------------------

M10K_76800_5 grid_A (
    .clk(M10k_pll),
    // Port A: always to VGA
    .addr_a(vga_read_addr),
    .q_a(vga_q_A),
    // Port B: CA engine
    .we_b  ( (active_buffer == 1'b1) ? we_final   : 1'b0       ),
    .addr_b( (active_buffer == 1'b1) ? addr_final : ca_read_addr),
    .d_b(data_final),
    .q_b(ca_q_A)
);

M10K_76800_5 grid_B (
    .clk(M10k_pll),
    // Port A: always to VGA
    .addr_a(vga_read_addr),
    .q_a(vga_q_B),
    // Port B: CA engine
    .we_b  ( (active_buffer == 1'b0) ? we_final   : 1'b0       ),
    .addr_b( (active_buffer == 1'b0) ? addr_final : ca_read_addr),
    .d_b(data_final),
    .q_b(ca_q_B)
);

// VGA reads from the FRONT buffer
assign vga_data_out = (active_buffer == 1'b0) ? vga_q_A : vga_q_B;

// CA engine reads from the FRONT buffer
assign ca_read_data = (active_buffer == 1'b0) ? ca_q_A : ca_q_B;

//=======================================================
// VGA Color Mapper
//=======================================================
// Fire and smoke animation is display-only; physics stores only MAT_*
// fire_anim uses visual_anim_ctr for synchronized animation across all fire cells
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

reg [7:0] grid_color;

// Fire animation helper: compute color for a flame layer
// Uses visual_anim_ctr for synchronized animation across all fire cells
// Layer index (1-9): 1-3=inner, 4-7=mid, 8-9=outer
// Animation cycle (ctr 0-7): layers progressively go dark from top, then re-light from bottom
function [7:0] fire_color;
    input [3:0] layer;  // fire layer index (1=FIRE_1, ..., 9=FIRE_9)
    input [3:0] ctr;    // animation counter (0-15 cycles)
    reg [3:0] dark_start;
begin
    if (layer >= 4 && layer <= 7) begin
        // Mid flame (4 layers): goes dark at different rates based on position
        // Each layer has a different threshold to go black
        dark_start = 8 - layer;
        // Phase 1 (ctr 0-7): go dark; Phase 2 (ctr 8-15): recovery
        if (ctr < 8) begin
            // Darkness spreads from top (layer 7) to bottom (layer 4)
            if (layer < ctr + 4'd4)
                fire_color = 8'b001_001_00;  // canvas bg
            else
                fire_color = 8'b111_010_00;  // light red
        end else begin
            // Recovery: light reclaims from bottom (layer 4) to top (layer 7)
            if (layer < (ctr - 4'd8) + 4'd4)
                fire_color = 8'b111_010_00;  // light red
            else
                fire_color = 8'b001_001_00;  // canvas bg (not yet recovered)
        end
    end else if (layer >= 8 && layer <= 9) begin
        // Outer flame (2 layers): same pattern but more aggressive
        if (ctr < 8) begin
            if (layer < ctr + 4'd6)
                fire_color = 8'b001_001_00;  // canvas bg
            else
                fire_color = 8'b111_100_11;  // pink
        end else begin
            if (layer < (ctr - 4'd8) + 4'd6)
                fire_color = 8'b111_100_11;  // pink
            else
                fire_color = 8'b001_001_00;  // canvas bg
        end
    end else begin
        // Inner flame (1-3): radial heat gradient + 2-phase flicker via ctr[3]
        case (layer)
            4'd1: fire_color = ctr[3] ? 8'b111_111_00 : 8'b111_110_00;  // yellow-white <-> light yellow
            4'd2: fire_color = ctr[3] ? 8'b111_110_00 : 8'b111_100_00;  // light yellow <-> orange
            4'd3: fire_color = ctr[3] ? 8'b111_100_00 : 8'b111_010_00;  // orange <-> deep orange-red
            default: fire_color = 8'b111_100_00;
        endcase
    end
end
endfunction

always @(*) begin
    case(vga_data_out)
        MAT_EMPTY: grid_color = 8'b001_001_00; // Dark gray (canvas bg)
        MAT_SAND:  grid_color = 8'b111_110_00; // Yellow
        MAT_WATER: grid_color = 8'b000_010_11; // Blue
        MAT_WATER_ACTIVE: grid_color = 8'b000_111_11; // Light blue
        MAT_WALL:  grid_color = 8'b011_011_01; // Gray
        MAT_FIRE:  grid_color = 8'b111_000_00; // Fire source - bright red
        MAT_SMOKE: grid_color = visual_anim_ctr[2] ? 8'b110_110_11 : 8'b100_100_10;
        MAT_FIRE_1,
        MAT_FIRE_2,
        MAT_FIRE_3,
        MAT_FIRE_4,
        MAT_FIRE_5,
        MAT_FIRE_6,
        MAT_FIRE_7,
        MAT_FIRE_8,
        MAT_FIRE_9:             grid_color = fire_color(vga_data_out[3:0] - 4'd6, visual_anim_ctr + {grid_read_x[2:0], 1'b0});
        MAT_GRASS: grid_color = 8'b011_111_10; // Bright green
        MAT_GRASS_STATIC: grid_color = 8'b010_110_01; // Darker green (settled grass)
        MAT_DIRT:  grid_color = 8'b100_011_00; // Brown
        default:   grid_color = 8'b000_000_00;
    endcase
end

// ============================================================
// Toolbar UI — 2 rows × 5 columns
// Row 0: y=200..219  (WALL / WATER / SAND / FIRE / SMOKE)
// Row 1: y=220..239  (GRASS / DIRT / future slots)
// Columns: 5 × 64 px; slot index = grid_read_x[8:6]
// ============================================================
wire in_toolbar;
assign in_toolbar = (grid_read_y[8:0] >= 9'd200 && grid_read_y[8:0] <= 9'd239);

wire toolbar_row;  // 0 = top row (y=200..219), 1 = bottom row (y=220..239)
assign toolbar_row = (grid_read_y[8:0] >= 9'd220);

wire [2:0] toolbar_slot;
assign toolbar_slot = grid_read_x[8:6]; // 0..4 per row

// ---------- borders & separators ----------
wire toolbar_top_bar    = (grid_read_y[8:0] >= 9'd198 && grid_read_y[8:0] <= 9'd199);
wire toolbar_bottom_bar = (grid_read_y[8:0] >= 9'd238 && grid_read_y[8:0] <= 9'd239);
wire toolbar_row_sep    = (grid_read_y[8:0] == 9'd219); // line between rows

wire toolbar_divider = (grid_read_x[8:0] >= 9'd63  && grid_read_x[8:0] <= 9'd64) ||
                       (grid_read_x[8:0] >= 9'd127 && grid_read_x[8:0] <= 9'd128) ||
                       (grid_read_x[8:0] >= 9'd191 && grid_read_x[8:0] <= 9'd192) ||
                       (grid_read_x[8:0] >= 9'd255 && grid_read_x[8:0] <= 9'd256);

// ---------- selected slot ----------
wire toolbar_selected_slot =
    (!toolbar_row && brush_mat == MAT_WALL  && toolbar_slot == 3'd0) ||
    (!toolbar_row && brush_mat == MAT_WATER && toolbar_slot == 3'd1) ||
    (!toolbar_row && brush_mat == MAT_SAND  && toolbar_slot == 3'd2) ||
    (!toolbar_row && brush_mat == MAT_FIRE  && toolbar_slot == 3'd3) ||
    (!toolbar_row && brush_mat == MAT_SMOKE && toolbar_slot == 3'd4) ||
    ( toolbar_row && brush_mat == MAT_GRASS && toolbar_slot == 3'd0) ||
    ( toolbar_row && brush_mat == MAT_DIRT  && toolbar_slot == 3'd1);

// Selection border — vertical (left/right edges of slot)
wire [8:0] sel_x_left  = {toolbar_slot, 6'b0};         // slot * 64
wire [8:0] sel_x_right = {toolbar_slot, 6'b0} + 9'd63; // slot * 64 + 63
wire slot_sel_vert  = toolbar_selected_slot &&
    (grid_read_x[8:0] == sel_x_left || grid_read_x[8:0] == sel_x_right);
// Selection border — horizontal (top/bottom edge of each row)
wire slot_sel_top    = toolbar_selected_slot &&
    ((!toolbar_row && grid_read_y[8:0] == 9'd200) ||
     ( toolbar_row && grid_read_y[8:0] == 9'd220));
wire slot_sel_bottom = toolbar_selected_slot &&
    ((!toolbar_row && grid_read_y[8:0] == 9'd218) ||
     ( toolbar_row && grid_read_y[8:0] == 9'd238));
wire slot_sel_horiz  = slot_sel_top || slot_sel_bottom;

// ---------- dot-matrix font ----------
// Row 0 text: y=208..212  |  Row 1 text: y=228..232
wire in_text_area_r0 = (grid_read_y[8:0] >= 9'd208 && grid_read_y[8:0] <= 9'd212);
wire in_text_area_r1 = (grid_read_y[8:0] >= 9'd228 && grid_read_y[8:0] <= 9'd232);

// -- ROW 0 y-wires (reused by all 5 row-0 labels) --
wire r0y0 = in_text_area_r0 && (grid_read_y[8:0] == 9'd208);
wire r0y1 = in_text_area_r0 && (grid_read_y[8:0] == 9'd209);
wire r0y2 = in_text_area_r0 && (grid_read_y[8:0] == 9'd210);
wire r0y3 = in_text_area_r0 && (grid_read_y[8:0] == 9'd211);
wire r0y4 = in_text_area_r0 && (grid_read_y[8:0] == 9'd212);

// SLOT 0 row 0: "WALL" x=24..38
wire t0_pixel =
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd26) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd26) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd24 && grid_read_x[8:0] <= 9'd26) && r0y2 ) |
  ( (grid_read_x[8:0] >= 9'd24 && grid_read_x[8:0] <= 9'd26) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd24 || grid_read_x[8:0] == 9'd25) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd29) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd28 && grid_read_x[8:0] <= 9'd30) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd28 || grid_read_x[8:0] == 9'd30) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd32) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd32) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd32) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd32) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd32 && grid_read_x[8:0] <= 9'd34) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd36) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd36) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd36) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd36) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd36 && grid_read_x[8:0] <= 9'd38) && r0y4 );

// SLOT 1 row 0: "WATER" x=87..105
wire t1_pixel =
  ( (grid_read_x[8:0] == 9'd87 || grid_read_x[8:0] == 9'd89) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd87 || grid_read_x[8:0] == 9'd89) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd87 && grid_read_x[8:0] <= 9'd89) && r0y2 ) |
  ( (grid_read_x[8:0] >= 9'd87 && grid_read_x[8:0] <= 9'd89) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd87 || grid_read_x[8:0] == 9'd88) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd92) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd91 || grid_read_x[8:0] == 9'd93) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd91 && grid_read_x[8:0] <= 9'd93) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd91 || grid_read_x[8:0] == 9'd93) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd91 || grid_read_x[8:0] == 9'd93) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd95 && grid_read_x[8:0] <= 9'd97) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd96) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd96) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd96) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd96) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd99 && grid_read_x[8:0] <= 9'd101) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd99) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd99 && grid_read_x[8:0] <= 9'd100) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd99) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd99 && grid_read_x[8:0] <= 9'd101) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd103 && grid_read_x[8:0] <= 9'd105) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd103 || grid_read_x[8:0] == 9'd104) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd103 && grid_read_x[8:0] <= 9'd105) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd103 || grid_read_x[8:0] == 9'd104) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd103 || grid_read_x[8:0] == 9'd105) && r0y4 );

// SLOT 2 row 0: "SAND" x=152..166
wire t2_pixel =
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd154) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd152) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd153) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd154) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd152 && grid_read_x[8:0] <= 9'd154) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd157) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd156 && grid_read_x[8:0] <= 9'd158) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd156 || grid_read_x[8:0] == 9'd158) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd162) && r0y0 ) |
  ( (grid_read_x[8:0] >= 9'd160 && grid_read_x[8:0] <= 9'd162) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd160 && grid_read_x[8:0] <= 9'd162) && r0y2 ) |
  ( (grid_read_x[8:0] >= 9'd160 && grid_read_x[8:0] <= 9'd162) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd160 || grid_read_x[8:0] == 9'd162) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd164 && grid_read_x[8:0] <= 9'd165) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd164 || grid_read_x[8:0] == 9'd165) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd164 && grid_read_x[8:0] <= 9'd166) && r0y4 );

// SLOT 3 row 0: "FIRE" x=216..230
wire t3_pixel =
  ( (grid_read_x[8:0] >= 9'd216 && grid_read_x[8:0] <= 9'd218) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd216) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd216 && grid_read_x[8:0] <= 9'd217) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd216) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd216) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd220 && grid_read_x[8:0] <= 9'd222) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd221) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd221) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd221) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd220 && grid_read_x[8:0] <= 9'd222) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd224 && grid_read_x[8:0] <= 9'd226) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd225) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd224 && grid_read_x[8:0] <= 9'd226) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd225) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd224 || grid_read_x[8:0] == 9'd226) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd230) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd228) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd229) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd228) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd228 && grid_read_x[8:0] <= 9'd230) && r0y4 );

// SLOT 4 row 0: "SMOKE" x=279..297
wire t4_pixel =
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd281) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd279) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd280) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd281) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd279 && grid_read_x[8:0] <= 9'd281) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd283 && grid_read_x[8:0] <= 9'd285) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd283) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd283 || grid_read_x[8:0] == 9'd284) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd283) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd283 || grid_read_x[8:0] == 9'd285) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd287 && grid_read_x[8:0] <= 9'd289) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd287 || grid_read_x[8:0] == 9'd289) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd287 && grid_read_x[8:0] <= 9'd289) && r0y4 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd293) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd292) && r0y1 ) |
  ( (grid_read_x[8:0] == 9'd291) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd292) && r0y3 ) |
  ( (grid_read_x[8:0] == 9'd291 || grid_read_x[8:0] == 9'd293) && r0y4 ) |
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd297) && r0y0 ) |
  ( (grid_read_x[8:0] == 9'd295) && r0y1 ) |
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd296) && r0y2 ) |
  ( (grid_read_x[8:0] == 9'd295) && r0y3 ) |
  ( (grid_read_x[8:0] >= 9'd295 && grid_read_x[8:0] <= 9'd297) && r0y4 );

// -- ROW 1 y-wires --
wire r1y0 = in_text_area_r1 && (grid_read_y[8:0] == 9'd228);
wire r1y1 = in_text_area_r1 && (grid_read_y[8:0] == 9'd229);
wire r1y2 = in_text_area_r1 && (grid_read_y[8:0] == 9'd230);
wire r1y3 = in_text_area_r1 && (grid_read_y[8:0] == 9'd231);
wire r1y4 = in_text_area_r1 && (grid_read_y[8:0] == 9'd232);

// SLOT 0 row 1: "GRASS" x=22..40
// G(22-24) R(26-28) A(30-32) S(34-36) S(38-40)
wire t5_pixel =
  // G
  ( (grid_read_x[8:0] == 9'd23 || grid_read_x[8:0] == 9'd24) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd22) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd22 || grid_read_x[8:0] == 9'd24) && r1y2 ) |
  ( (grid_read_x[8:0] >= 9'd22 && grid_read_x[8:0] <= 9'd24) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd23 || grid_read_x[8:0] == 9'd24) && r1y4 ) |
  // R
  ( (grid_read_x[8:0] == 9'd26 || grid_read_x[8:0] == 9'd27) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd26 || grid_read_x[8:0] == 9'd28) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd26 || grid_read_x[8:0] == 9'd27) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd26 || grid_read_x[8:0] == 9'd28) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd26) && r1y4 ) |
  // A
  ( (grid_read_x[8:0] == 9'd31) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd30 || grid_read_x[8:0] == 9'd32) && r1y1 ) |
  ( (grid_read_x[8:0] >= 9'd30 && grid_read_x[8:0] <= 9'd32) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd30 || grid_read_x[8:0] == 9'd32) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd30 || grid_read_x[8:0] == 9'd32) && r1y4 ) |
  // S (first)
  ( (grid_read_x[8:0] >= 9'd34 && grid_read_x[8:0] <= 9'd36) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd34) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd34 || grid_read_x[8:0] == 9'd35) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd36) && r1y3 ) |
  ( (grid_read_x[8:0] >= 9'd34 && grid_read_x[8:0] <= 9'd36) && r1y4 ) |
  // S (second)
  ( (grid_read_x[8:0] >= 9'd38 && grid_read_x[8:0] <= 9'd40) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd38) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd38 || grid_read_x[8:0] == 9'd39) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd40) && r1y3 ) |
  ( (grid_read_x[8:0] >= 9'd38 && grid_read_x[8:0] <= 9'd40) && r1y4 );

// SLOT 1 row 1: "DIRT" x=88..102
// D(88-90) I(92-94) R(96-98) T(100-102)
wire t6_pixel =
  // D
  ( (grid_read_x[8:0] == 9'd88 || grid_read_x[8:0] == 9'd89) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd88 || grid_read_x[8:0] == 9'd90) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd88 || grid_read_x[8:0] == 9'd90) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd88 || grid_read_x[8:0] == 9'd90) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd88 || grid_read_x[8:0] == 9'd89) && r1y4 ) |
  // I
  ( (grid_read_x[8:0] >= 9'd92 && grid_read_x[8:0] <= 9'd94) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd93) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd93) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd93) && r1y3 ) |
  ( (grid_read_x[8:0] >= 9'd92 && grid_read_x[8:0] <= 9'd94) && r1y4 ) |
  // R
  ( (grid_read_x[8:0] == 9'd96 || grid_read_x[8:0] == 9'd97) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd96 || grid_read_x[8:0] == 9'd98) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd96 || grid_read_x[8:0] == 9'd97) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd96 || grid_read_x[8:0] == 9'd98) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd96) && r1y4 ) |
  // T
  ( (grid_read_x[8:0] >= 9'd100 && grid_read_x[8:0] <= 9'd102) && r1y0 ) |
  ( (grid_read_x[8:0] == 9'd101) && r1y1 ) |
  ( (grid_read_x[8:0] == 9'd101) && r1y2 ) |
  ( (grid_read_x[8:0] == 9'd101) && r1y3 ) |
  ( (grid_read_x[8:0] == 9'd101) && r1y4 );

wire any_text_pixel =
    (in_toolbar && !toolbar_row && toolbar_slot == 3'd0 && in_text_area_r0 && t0_pixel) ||
    (in_toolbar && !toolbar_row && toolbar_slot == 3'd1 && in_text_area_r0 && t1_pixel) ||
    (in_toolbar && !toolbar_row && toolbar_slot == 3'd2 && in_text_area_r0 && t2_pixel) ||
    (in_toolbar && !toolbar_row && toolbar_slot == 3'd3 && in_text_area_r0 && t3_pixel) ||
    (in_toolbar && !toolbar_row && toolbar_slot == 3'd4 && in_text_area_r0 && t4_pixel) ||
    (in_toolbar &&  toolbar_row && toolbar_slot == 3'd0 && in_text_area_r1 && t5_pixel) ||
    (in_toolbar &&  toolbar_row && toolbar_slot == 3'd1 && in_text_area_r1 && t6_pixel);

// Text colors per slot
wire [7:0] text_color =
    (!toolbar_row && toolbar_slot == 3'd0) ? 8'b011_011_01 :  // WALL  gray
    (!toolbar_row && toolbar_slot == 3'd1) ? 8'b000_010_11 :  // WATER blue
    (!toolbar_row && toolbar_slot == 3'd2) ? 8'b111_110_00 :  // SAND  yellow
    (!toolbar_row && toolbar_slot == 3'd3) ? 8'b111_100_00 :  // FIRE  orange
    (!toolbar_row)                         ? 8'b010_010_00 :  // SMOKE dark
    ( toolbar_row && toolbar_slot == 3'd0) ? 8'b011_111_10 :  // GRASS green
    ( toolbar_row && toolbar_slot == 3'd1) ? 8'b100_011_00 :  // DIRT  brown
                                             8'b010_010_01;   // empty slot

// Material color preview strips
// Row 0: y=214..218   Row 1: y=234..238
wire in_preview_strip =
    ((grid_read_y[8:0] >= 9'd214 && grid_read_y[8:0] <= 9'd218 && !toolbar_row) ||
     (grid_read_y[8:0] >= 9'd234 && grid_read_y[8:0] <= 9'd238 &&  toolbar_row)) &&
    !toolbar_divider &&
    // Row 1: only show preview for assigned slots
    (!toolbar_row || toolbar_slot == 3'd0 || toolbar_slot == 3'd1);

wire [7:0] preview_color =
    (!toolbar_row && toolbar_slot == 3'd0) ? 8'b011_011_01 :  // WALL
    (!toolbar_row && toolbar_slot == 3'd1) ? 8'b000_010_11 :  // WATER
    (!toolbar_row && toolbar_slot == 3'd2) ? 8'b111_110_00 :  // SAND
    (!toolbar_row && toolbar_slot == 3'd3) ? 8'b111_000_00 :  // FIRE
    (!toolbar_row)                         ? 8'b100_100_10 :  // SMOKE
    ( toolbar_row && toolbar_slot == 3'd0) ? 8'b011_111_10 :  // GRASS
                                             8'b100_011_00;   // DIRT

// ---------- color logic ----------
reg [7:0] toolbar_color;
always @(*) begin
    toolbar_color = 8'b010_010_01; // dark bg
    if (toolbar_top_bar)
        toolbar_color = 8'b111_111_11; // white bar above toolbar
    else if (toolbar_bottom_bar)
        toolbar_color = 8'b000_000_00; // black bar below toolbar
    else if (toolbar_row_sep)
        toolbar_color = 8'b100_100_11; // row separator (mid gray-blue)
    else if (toolbar_divider)
        toolbar_color = 8'b001_001_01; // dark column divider
    else if (slot_sel_horiz || slot_sel_vert)
        toolbar_color = 8'b111_111_11; // white selection border
    else if (any_text_pixel)
        toolbar_color = text_color;
    else if (in_preview_strip)
        toolbar_color = preview_color;
    else if (toolbar_selected_slot)
        toolbar_color = 8'b011_011_10; // selected slot bg highlight
end

// ============================================================
// Mouse cursor (Feature 3) — 11-pixel crosshair (±5)
// ============================================================
wire [8:0] cur_y_lo = (brush_y[8:0] >= 9'd5) ? brush_y[8:0] - 9'd5 : 9'd0;
wire [8:0] cur_y_hi = brush_y[8:0] + 9'd5;
wire [8:0] cur_x_lo = (brush_x[8:0] >= 9'd5) ? brush_x[8:0] - 9'd5 : 9'd0;
wire [8:0] cur_x_hi = brush_x[8:0] + 9'd5;

wire cursor_center;
wire cursor_ring;
assign cursor_center = (grid_read_x[8:0] == brush_x[8:0]) & (grid_read_y[8:0] == brush_y[8:0]);
assign cursor_ring   =
    ((grid_read_x[8:0] == brush_x[8:0]) &
     (grid_read_y[8:0] >= cur_y_lo) & (grid_read_y[8:0] <= cur_y_hi)) ||
    ((grid_read_y[8:0] == brush_y[8:0]) &
     (grid_read_x[8:0] >= cur_x_lo) & (grid_read_x[8:0] <= cur_x_hi));

reg [7:0] cursor_color;
always @(*) begin
    if (cursor_center)
        cursor_color = 8'b111_111_11; // white center
    else if (cursor_ring)
        cursor_color = 8'b000_111_00; // green arms
    else
        cursor_color = 8'b000_000_00;
end

// ============================================================
// Pause indicator (Feature 4)
// ============================================================
wire pause_active = hps_keys[0];
wire in_pause_icon;
assign in_pause_icon = ((grid_read_x[8:0] == 9'd19) | (grid_read_x[8:0] == 9'd21)) &
                          (grid_read_y[8:0] >= 9'd14 && grid_read_y[8:0] <= 9'd25);

// Final composition
reg [7:0] final_vga_color;
always @(*) begin
    final_vga_color = grid_color;
    if (in_toolbar)
        final_vga_color = toolbar_color;
    if (cursor_center | cursor_ring)
        final_vga_color = cursor_color;
    if (pause_active && in_pause_icon)
        final_vga_color = 8'b111_111_11;
end

//=======================================================
// LFSR - 16-bit Linear Feedback Shift Register
// Taps: [15,13,12,10] — maximal-length primitive polynomial.
//=======================================================
reg [15:0] lfsr;
wire random_bit = lfsr[0];

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n)
        lfsr <= 16'hACE1;
    else
        lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
end

// =======================================================
// CA Physics Engine State Machine
//
// States 0-18: Sand + Water (from temp.v)
// States 19-28: Fire + Smoke
//
// 扫描：从下到上（cy:199→0），从左到右（cx:0→319）
// Canvas: y=0..199, Toolbar: y=200..239
//
// 沙子规则（temp.v）：
//   下方 EMPTY  → 落下
//   下方 WATER  → 置换：沙写到下方，水写到沙原位（两拍完成）
//   下方其他    → 检查左下/右下空格（LFSR随机优先方向）
//   全阻        → 原地
//
// 水规则（temp.v）：
//   下方 EMPTY  → 落下
//   下方非空    → 检查左邻/右邻（前台，上一帧），LFSR随机优先
//   两侧都非空  → 原地堆积
//
// 火规则：
//   下方 EMPTY/SMOKE → 落下
//   下方 WATER       → 熄灭（不写）
//   下方固体         → 对角→侧向扩散
//   全阻             → 原地燃烧
//   底行             → 50%随机闪烁
//
// 烟规则：
//   上方 EMPTY → 上升
//   上方阻塞   → 上对角扩散
//   全阻       → 留在原地
//   随机衰减   → 1/128概率消失
//   顶行       → 消失
// =======================================================

// States 0-18: temp.v sand+water
// States 19-28: fire + smoke (new)
localparam S_IDLE        = 6'd0,
           S_CLEAR       = 6'd1,
           S_SWEEP_READ  = 6'd2,
           S_SWEEP_WAIT  = 6'd3,
           S_SWEEP_EVAL  = 6'd4,
           S_SAND_DN_WT  = 6'd5,
           S_SAND_DN_EV  = 6'd6,
           S_SAND_SWAP   = 6'd7,
           S_SAND_DG1_WT = 6'd8,
           S_SAND_DG1_EV = 6'd9,
           S_SAND_DG2_WT = 6'd10,
           S_SAND_DG2_EV = 6'd11,
           // Water states. Normal water accumulates first; active water spreads later.
           S_WATR_DN_WT      = 6'd12,
           S_WATR_DN_EV      = 6'd13,
           S_WATR_S1_WT      = 6'd14,
           S_WATR_S1_EV      = 6'd15,
           S_WATR_S1_SUP_WT  = 6'd16,
           S_WATR_S1_SUP_EV  = 6'd17,
           S_WATR_S2_WT      = 6'd18,
           S_WATR_S2_EV      = 6'd19,
           S_WATR_S2_SUP_WT  = 6'd20,
           S_WATR_S2_SUP_EV  = 6'd21,
           S_NEXT_PIXEL      = 6'd22,
           S_FIRE_EVAL       = 6'd23,
           S_FIRE_MARK_WT    = 6'd24,  // wait for read of flame cell
           S_FIRE_MARK_EV    = 6'd25,  // evaluate and write flame layer
           S_SMK_UP_WT       = 6'd26,
           S_SMK_UP_EV       = 6'd27,
           S_SMK_DIAG_WT     = 6'd28,
           S_SMK_DIAG_EV     = 6'd29,
           S_CLEAR_AGAIN     = 6'd30,  // second pass to clear old FRONT buffer
           S_FIRE_DN_WT      = 6'd31,  // extra wait so M10K read of cell-below settles before S_FIRE_EVAL
           S_FIRE_MARK_WT2   = 6'd32;  // extra wait so M10K read of cell-above settles before S_FIRE_MARK_EV

// Grass physics states (simplified: no diagonal sliding)
localparam S_GRASS_DN_WT  = 6'd33,
           S_GRASS_DN_EV  = 6'd34;

reg [5:0]  state;
reg [16:0] clear_addr;
reg [9:0]  cx;
reg [9:0]  cy;
reg [4:0]  current_mat;
reg        rnd;           // LFSR sample for priority direction
// Fire flame marking: layer counter and pending flag
reg [3:0]  fire_mark_layer;   // 0=idle, 1-9 = writing FIRE_1 through FIRE_9

reg prev_vsync;
wire vsync_falling_edge = (prev_vsync == 1'b1 && VGA_VS == 1'b0);


// Water helper predicates for the two-stage water logic.
function is_water_like;
    input [4:0] m;
    begin
        is_water_like = (m == MAT_WATER || m == MAT_WATER_ACTIVE);
    end
endfunction

function is_supported_for_water;
    input [4:0] m;
    begin
        is_supported_for_water = (m == MAT_WALL || m == MAT_SAND ||
                                  m == MAT_WATER || m == MAT_WATER_ACTIVE ||
                                  m == MAT_GRASS || m == MAT_DIRT ||
                                  m == MAT_GRASS_STATIC);
    end
endfunction

always @(posedge M10k_pll or negedge sys_reset_n) begin
    if (!sys_reset_n) begin
        state         <= S_IDLE;
        active_buffer <= 1'b0;
        ca_we         <= 1'b0;
        prev_vsync    <= 1'b0;
        clear_addr    <= 17'd0;
        cx            <= 10'd0;
        cy            <= 10'd0;
        current_mat   <= MAT_EMPTY;
        rnd           <= 1'b0;
    end else begin
        prev_vsync <= VGA_VS;
        ca_we      <= 1'b0;

        case (state)

            // ==================================================
            // S_IDLE: Wait for VSYNC, flip buffer
            // ==================================================
            S_IDLE: begin
                if (vsync_falling_edge) begin
                    active_buffer <= ~active_buffer;
                    clear_addr    <= 17'd0;
                    state         <= S_CLEAR;
                end
            end

            // ==================================================
            // S_CLEAR: Fill BACK buffer with EMPTY
            // Normal: after clear, do sweep (copy physics from FRONT)
            // clear_pending: after clear, skip sweep → keep BACK empty,
            //   then next VSYNC swap makes both buffers empty
            // ==================================================
            S_CLEAR: begin
                ca_we         <= 1'b1;
                ca_write_addr <= clear_addr;
                ca_write_data <= MAT_EMPTY;
                if (clear_addr == MAX_CELLS - 17'd1) begin
                    clear_addr <= 17'd0;
                    cx         <= 10'd0;
                    cy         <= CANVAS_ROWS - 10'd1;
                    if (clear_pending) begin
                        // Next VSYNC: BACK is still dirty from old FRONT,
                        // so clear again on the very next frame
                        state         <= S_CLEAR_AGAIN;
                    end else begin
                        state         <= S_SWEEP_READ;
                    end
                end else begin
                    clear_addr <= clear_addr + 17'd1;
                end
            end

            // ==================================================
            // S_CLEAR_AGAIN: Second pass to clear old FRONT buffer
            // ==================================================
            S_CLEAR_AGAIN: begin
                if (vsync_falling_edge) begin
                    active_buffer <= ~active_buffer;  // swap dirty FRONT to BACK
                    clear_addr <= 17'd0;              // now BACK is the old dirty FRONT
                    state      <= S_CLEAR;            // fill BACK with EMPTY
                end
            end

            // ==================================================
            // Read current cell (FRONT), wait 1 cycle
            // ==================================================
            S_SWEEP_READ: begin
                ca_read_addr <= (cy * GRID_WIDTH) + cx;
                state        <= S_SWEEP_WAIT;
            end

            S_SWEEP_WAIT: begin
                state <= S_SWEEP_EVAL;
            end

            // ==================================================
            // Evaluate current cell
            // ==================================================
            S_SWEEP_EVAL: begin
                current_mat <= ca_read_data;
                rnd         <= random_bit;

                case (ca_read_data)
                    MAT_EMPTY: begin
                        state <= S_NEXT_PIXEL;
                    end

                    MAT_WALL: begin
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_WALL;
                        state         <= S_NEXT_PIXEL;
                    end

                    // ===========================
                    // SAND physics (temp.v)
                    // ===========================
                    MAT_SAND: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_SAND_DN_WT;
                        end
                    end

                    // ===========================
                    // WATER physics (temp.v)
                    // ===========================
                    MAT_WATER: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_WATR_DN_WT;
                        end
                    end

                    MAT_WATER_ACTIVE: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_WATR_DN_WT;
                        end
                    end

                    // ===========================
                    // FIRE physics (simplified: no diffusion)
                    // ===========================
                    MAT_FIRE: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            // Bottom row: stay in place, start marking flame layers above
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_FIRE;
                            fire_mark_layer <= 4'd1;
                            state <= S_FIRE_MARK_WT;
                        end else begin
                            // Read cell below — extra wait state because M10K has
                            // 2-cycle read latency (registered addr + registered q).
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_FIRE_DN_WT;
                        end
                    end

                    // ===========================
                    // SMOKE physics
                    // ===========================
                    MAT_SMOKE: begin
                        if (cy == 10'd0 || lfsr[6:0] == 7'b0000000) begin
                            // Top edge or random decay — disappear
                            state <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_SMK_UP_WT;
                        end
                    end

                    // ===========================
                    // FIRE flame layers (visual only): decay each frame so they
                    // must be re-marked by an active fire source to remain visible.
                    // BACK was cleared in S_CLEAR, so skipping the writeback erases them.
                    // ===========================
                    MAT_FIRE_1, MAT_FIRE_2, MAT_FIRE_3,
                    MAT_FIRE_4, MAT_FIRE_5, MAT_FIRE_6,
                    MAT_FIRE_7, MAT_FIRE_8, MAT_FIRE_9: begin
                        state <= S_NEXT_PIXEL;
                    end

                    // ===========================
                    // GRASS physics: falls, becomes MAT_GRASS_STATIC on dirt support
                    // ===========================
                    MAT_GRASS: begin
                        if (cy == CANVAS_ROWS - 10'd1) begin
                            // Bottom row: disappears (no dirt to rest on at absolute bottom)
                            state <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                            state        <= S_GRASS_DN_WT;
                        end
                    end

                    // ===========================
                    // GRASS_STATIC physics: static like wall
                    // ===========================
                    MAT_GRASS_STATIC: begin
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_GRASS_STATIC;
                        state         <= S_NEXT_PIXEL;
                    end

                    default: begin
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= ca_read_data;
                        state         <= S_NEXT_PIXEL;
                    end
                endcase
            end

            // ==================================================
            // SAND physics (from temp.v)
            // ==================================================
            S_SAND_DN_WT: state <= S_SAND_DN_EV;

            S_SAND_DN_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SAND;
                    state         <= S_NEXT_PIXEL;
                end else if (ca_read_data == MAT_WATER || ca_read_data == MAT_WATER_ACTIVE) begin
                    // Swap: sand -> below, water -> sand's position
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SAND;
                    state         <= S_SAND_SWAP;
                end else begin
                    // Below blocked → try diagonal
                    if (rnd == 1'b0) begin
                        if (cx == 10'd0) begin
                            if (cx == GRID_WIDTH - 10'd1) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_SAND;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_SAND_DG2_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_SAND_DG1_WT;
                        end
                    end else begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            if (cx == 10'd0) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_SAND;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_SAND_DG1_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_SAND_DG2_WT;
                        end
                    end
                end
            end

            S_SAND_SWAP: begin
                ca_we         <= 1'b1;
                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                ca_write_data <= MAT_WATER;
                state         <= S_NEXT_PIXEL;
            end

            S_SAND_DG1_WT: state <= S_SAND_DG1_EV;

            S_SAND_DG1_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_SAND;
                    ca_write_addr <= (rnd == 1'b0)
                        ? ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1)
                        : ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    state <= S_NEXT_PIXEL;
                end else begin
                    if (rnd == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_SAND_DG2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_SAND;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_SAND_DG2_WT;
                        end
                    end
                end
            end

            S_SAND_DG2_WT: state <= S_SAND_DG2_EV;

            S_SAND_DG2_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_SAND;
                    ca_write_addr <= (rnd == 1'b0)
                        ? ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1)
                        : ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    state <= S_NEXT_PIXEL;
                end else begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SAND;
                    state         <= S_NEXT_PIXEL;
                end
            end

            // ==================================================
            // WATER physics: two-stage accumulation + active spreading
            // ==================================================
            S_WATR_DN_WT: state <= S_WATR_DN_EV;

            S_WATR_DN_EV: begin
                if (current_mat == MAT_WATER) begin
                    if (ca_read_data == MAT_EMPTY ||
                        ca_read_data == MAT_SMOKE ||
                        ca_read_data == MAT_FIRE ||
                        (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                        // Normal water falls straight down.
                        ca_we         <= 1'b1;
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_WATER;
                        state         <= S_NEXT_PIXEL;
                    end else begin
                        // Reference behavior: if normal water cannot fall, do NOT spread
                        // immediately. Keep this cell for the current frame, but mark it
                        // active so the next frame can perform one horizontal relaxation step.
                        // This applies both on solid support and on uneven water surfaces.
                        ca_we         <= 1'b1;
                        ca_write_addr <= (cy * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_WATER_ACTIVE;
                        state         <= S_NEXT_PIXEL;
                    end
                end else begin
                    // MAT_WATER_ACTIVE: if it cannot fall, it is allowed to try
                    // a one-cell horizontal spread/relaxation step, even when it is
                    // supported by water. This is the key difference from the previous
                    // version, where active water on water immediately became stable and
                    // therefore never spread over an uneven water surface.
                    if (ca_read_data == MAT_EMPTY ||
                        ca_read_data == MAT_SMOKE ||
                        ca_read_data == MAT_FIRE ||
                        (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                        // If unsupported, keep falling and remain active.
                        ca_we         <= 1'b1;
                        ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                        ca_write_data <= MAT_WATER_ACTIVE;
                        state         <= S_NEXT_PIXEL;
                    end else begin
                        // Blocked below: try horizontal spreading with support check.
                        if (rnd == 1'b0) begin
                            if (cx == 10'd0) begin
                                if (cx == GRID_WIDTH - 10'd1) begin
                                    ca_we         <= 1'b1;
                                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                    ca_write_data <= MAT_WATER;
                                    state         <= S_NEXT_PIXEL;
                                end else begin
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                    state        <= S_WATR_S2_WT;
                                end
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                state        <= S_WATR_S1_WT;
                            end
                        end else begin
                            if (cx == GRID_WIDTH - 10'd1) begin
                                if (cx == 10'd0) begin
                                    ca_we         <= 1'b1;
                                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                    ca_write_data <= MAT_WATER;
                                    state         <= S_NEXT_PIXEL;
                                end else begin
                                    ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                                    state        <= S_WATR_S2_WT;
                                end
                            end else begin
                                ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_WATR_S1_WT;
                            end
                        end
                    end
                end
            end

            S_WATR_S1_WT: state <= S_WATR_S1_EV;

            S_WATR_S1_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    // Side cell is empty. Now check whether the side cell is supported below.
                    ca_read_addr <= (rnd == 1'b0)
                        ? ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1)
                        : ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                    state <= S_WATR_S1_SUP_WT;
                end else begin
                    // First side blocked. Try the opposite side if possible.
                    if (rnd == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_WATR_S2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_WATR_S2_WT;
                        end
                    end
                end
            end

            S_WATR_S1_SUP_WT: state <= S_WATR_S1_SUP_EV;

            S_WATR_S1_SUP_EV: begin
                if (is_supported_for_water(ca_read_data)) begin
                    // Move to the first side only if that side has support below.
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_WATER;
                    ca_write_addr <= (rnd == 1'b0)
                        ? (cy * GRID_WIDTH) + (cx - 10'd1)
                        : (cy * GRID_WIDTH) + (cx + 10'd1);
                    state <= S_NEXT_PIXEL;
                end else begin
                    // Unsupported side would make water float sideways. Try the opposite side.
                    if (rnd == 1'b0) begin
                        if (cx == GRID_WIDTH - 10'd1) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_WATR_S2_WT;
                        end
                    end else begin
                        if (cx == 10'd0) begin
                            ca_we         <= 1'b1;
                            ca_write_addr <= (cy * GRID_WIDTH) + cx;
                            ca_write_data <= MAT_WATER;
                            state         <= S_NEXT_PIXEL;
                        end else begin
                            ca_read_addr <= (cy * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_WATR_S2_WT;
                        end
                    end
                end
            end

            S_WATR_S2_WT: state <= S_WATR_S2_EV;

            S_WATR_S2_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    ca_read_addr <= (rnd == 1'b0)
                        ? ((cy + 10'd1) * GRID_WIDTH) + (cx + 10'd1)
                        : ((cy + 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                    state <= S_WATR_S2_SUP_WT;
                end else begin
                    // Both sides failed. Active water becomes stable water instead of disappearing.
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_WATER;
                    state         <= S_NEXT_PIXEL;
                end
            end

            S_WATR_S2_SUP_WT: state <= S_WATR_S2_SUP_EV;

            S_WATR_S2_SUP_EV: begin
                if (is_supported_for_water(ca_read_data)) begin
                    ca_we         <= 1'b1;
                    ca_write_data <= MAT_WATER;
                    ca_write_addr <= (rnd == 1'b0)
                        ? (cy * GRID_WIDTH) + (cx + 10'd1)
                        : (cy * GRID_WIDTH) + (cx - 10'd1);
                    state <= S_NEXT_PIXEL;
                end else begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_WATER;
                    state         <= S_NEXT_PIXEL;
                end
            end

            // ==================================================
            // FIRE physics (simplified: no diffusion)
            // ==================================================
            S_FIRE_DN_WT: state <= S_FIRE_EVAL;

            S_FIRE_EVAL: begin
                if (ca_read_data == MAT_WATER || ca_read_data == MAT_WATER_ACTIVE) begin
                    // Water below → extinguish, produce smoke at fire origin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SMOKE;
                    state         <= S_NEXT_PIXEL;
                end else if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE) begin
                    // Empty/smoke below -> fall. The current cell remains empty because
                    // the BACK buffer was cleared before this sweep.
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_FIRE;
                    state         <= S_NEXT_PIXEL;
                end else if (ca_read_data == MAT_FIRE ||
                             (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    // Fire/flame below -> redundant fire pixel, disappear so multi-pixel
                    // brushes collapse to a single falling spark instead of stacking.
                    ca_we         <= 1'b0;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Solid (sand/wall) below -> stay in place (FIRE), start marking flame layers
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_FIRE;
                    fire_mark_layer <= 4'd1;
                    state         <= S_FIRE_MARK_WT;
                end
            end

            // ==================================================
            // FIRE flame marking (iteratively writes FIRE_1..FIRE_9 upward)
            // ==================================================
            S_FIRE_MARK_WT: begin
                // Read cell above at current fire_mark_layer offset to check if it's empty
                if (cy < fire_mark_layer) begin
                    // Above canvas edge (y=0) — stop marking
                    state <= S_NEXT_PIXEL;
                end else begin
                    ca_read_addr <= ((cy - fire_mark_layer) * GRID_WIDTH) + cx;
                    state        <= S_FIRE_MARK_WT2;
                end
            end

            // Extra wait so the M10K read of the cell-above settles before S_FIRE_MARK_EV
            S_FIRE_MARK_WT2: state <= S_FIRE_MARK_EV;

            S_FIRE_MARK_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_SMOKE ||
                    (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    // Empty/smoke/existing flame layer → overwrite. Overwriting flame
                    // layers is needed because they decay each frame (BACK is cleared)
                    // and remain visible only if the source re-marks them.
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy - fire_mark_layer) * GRID_WIDTH) + cx;
                    if (fire_mark_layer <= 4'd1)
                        ca_write_data <= MAT_FIRE_1;       // inner flame
                    else if (fire_mark_layer <= 4'd2)
                        ca_write_data <= MAT_FIRE_2;       // inner flame
                    else if (fire_mark_layer <= 4'd3)
                        ca_write_data <= MAT_FIRE_3;       // inner flame 3
                    else if (fire_mark_layer <= 4'd4)
                        ca_write_data <= MAT_FIRE_4;       // mid flame 1
                    else if (fire_mark_layer <= 4'd5)
                        ca_write_data <= MAT_FIRE_5;       // mid flame 2
                    else if (fire_mark_layer <= 4'd6)
                        ca_write_data <= MAT_FIRE_6;       // mid flame 3
                    else if (fire_mark_layer <= 4'd7)
                        ca_write_data <= MAT_FIRE_7;       // mid flame 4
                    else if (fire_mark_layer <= 4'd8)
                        ca_write_data <= MAT_FIRE_8;       // outer flame 1
                    else
                        ca_write_data <= MAT_FIRE_9;       // outer flame 2+3
                    fire_mark_layer <= fire_mark_layer + 4'd1;
                    if (fire_mark_layer >= 4'd9) begin
                        // Done after writing layer 9
                        state <= S_NEXT_PIXEL;
                    end else begin
                        state <= S_FIRE_MARK_WT;
                    end
                end else begin
                    // Blocked (wall/sand/water/other fire) → stop marking
                    state <= S_NEXT_PIXEL;
                end
            end

            // ==================================================
            // SMOKE physics (new)
            // ==================================================
            S_SMK_UP_WT: state <= S_SMK_UP_EV;

            S_SMK_UP_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy - 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SMOKE;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Above blocked → try diagonal up
                    if (rnd == 1'b0) begin
                        if (cx == 10'd0) begin
                            if (cx == GRID_WIDTH - 10'd1) begin
                                ca_we         <= 1'b1;
                                ca_write_addr <= (cy * GRID_WIDTH) + cx;
                                ca_write_data <= MAT_SMOKE;
                                state         <= S_NEXT_PIXEL;
                            end else begin
                                ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                                state        <= S_SMK_DIAG_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx - 10'd1);
                            state        <= S_SMK_DIAG_WT;
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
                                state        <= S_SMK_DIAG_WT;
                            end
                        end else begin
                            ca_read_addr <= ((cy - 10'd1) * GRID_WIDTH) + (cx + 10'd1);
                            state        <= S_SMK_DIAG_WT;
                        end
                    end
                end
            end

            S_SMK_DIAG_WT: state <= S_SMK_DIAG_EV;

            S_SMK_DIAG_EV: begin
                if (ca_read_data == MAT_EMPTY) begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= ca_read_addr;
                    ca_write_data <= MAT_SMOKE;
                end else begin
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_SMOKE;
                end
                state <= S_NEXT_PIXEL;
            end

            // ==================================================
            // GRASS physics: falls like sand, vanishes if no dirt below
            // Simplified: no diagonal sliding — only straight down
            // ==================================================
            S_GRASS_DN_WT: state <= S_GRASS_DN_EV;

            S_GRASS_DN_EV: begin
                if (ca_read_data == MAT_EMPTY || ca_read_data == MAT_FIRE || (ca_read_data >= MAT_FIRE_1 && ca_read_data <= MAT_FIRE_9)) begin
                    // Empty below (or fire/flame layers) -> fall down.
                    // Do NOT write back to current cell -> old position vanishes naturally.
                    ca_we         <= 1'b1;
                    ca_write_addr <= ((cy + 10'd1) * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_GRASS;
                    state         <= S_NEXT_PIXEL;
                end else if (ca_read_data == MAT_DIRT) begin
                    // Dirt below -> grass rests on dirt, becomes MAT_GRASS_STATIC.
                    // Write MAT_GRASS_STATIC at current position (cy, cx).
                    // Do NOT overwrite the dirt cell at cy+1.
                    ca_we         <= 1'b1;
                    ca_write_addr <= (cy * GRID_WIDTH) + cx;
                    ca_write_data <= MAT_GRASS_STATIC;
                    state         <= S_NEXT_PIXEL;
                end else begin
                    // Below is blocked by non-dirt material (sand, wall, water, grass, other).
                    // Do NOT write back -> grass vanishes.
                    state <= S_NEXT_PIXEL;
                end
            end

            // ==================================================
            // Advance to next pixel
            // ==================================================
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

    .hps_io_hps_io_qspi_inst_IO0    (HPS_FLASH_DATA[0]),
    .hps_io_hps_io_qspi_inst_IO1    (HPS_FLASH_DATA[1]),
    .hps_io_hps_io_qspi_inst_IO2    (HPS_FLASH_DATA[2]),
    .hps_io_hps_io_qspi_inst_IO3    (HPS_FLASH_DATA[3]),
    .hps_io_hps_io_qspi_inst_SS0    (HPS_FLASH_NCSO),
    .hps_io_hps_io_qspi_inst_CLK    (HPS_FLASH_DCLK),

    .hps_io_hps_io_gpio_inst_GPIO61 (HPS_GSENSOR_INT),
    .hps_io_hps_io_gpio_inst_GPIO40 (HPS_GPIO[0]),
    .hps_io_hps_io_gpio_inst_GPIO41 (HPS_GPIO[1]),

    .hps_io_hps_io_gpio_inst_GPIO48 (HPS_I2C_CONTROL),
    .hps_io_hps_io_i2c0_inst_SDA    (HPS_I2C1_SDAT),
    .hps_io_hps_io_i2c0_inst_SCL    (HPS_I2C1_SCLK),
    .hps_io_hps_io_i2c1_inst_SDA    (HPS_I2C2_SDAT),
    .hps_io_hps_io_i2c1_inst_SCL    (HPS_I2C2_SCLK),

    .hps_io_hps_io_gpio_inst_GPIO54 (HPS_KEY),
    .hps_io_hps_io_gpio_inst_GPIO53 (HPS_LED),

    .hps_io_hps_io_sdio_inst_CMD    (HPS_SD_CMD),
    .hps_io_hps_io_sdio_inst_D0     (HPS_SD_DATA[0]),
    .hps_io_hps_io_sdio_inst_D1     (HPS_SD_DATA[1]),
    .hps_io_hps_io_sdio_inst_CLK    (HPS_SD_CLK),
    .hps_io_hps_io_sdio_inst_D2     (HPS_SD_DATA[2]),
    .hps_io_hps_io_sdio_inst_D3     (HPS_SD_DATA[3]),

    .hps_io_hps_io_spim1_inst_CLK   (HPS_SPIM_CLK),
    .hps_io_hps_io_spim1_inst_MOSI  (HPS_SPIM_MOSI),
    .hps_io_hps_io_spim1_inst_MISO  (HPS_SPIM_MISO),
    .hps_io_hps_io_spim1_inst_SS0   (HPS_SPIM_SS),

    .hps_io_hps_io_uart0_inst_RX    (HPS_UART_RX),
    .hps_io_hps_io_uart0_inst_TX    (HPS_UART_TX),

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

// True Dual-Port M10K memory: 320x240 cells, 5 bits each
module M10K_76800_5 (
    input clk,
    // Port A: VGA read-only
    input  [16:0] addr_a,
    output reg [4:0] q_a,
    // Port B: CA engine read/write
    input  [16:0] addr_b,
    input  [4:0]  d_b,
    input         we_b,
    output reg [4:0] q_b
);
    reg [4:0] mem [76799:0] /* synthesis ramstyle = "no_rw_check, M10K" */;

    always @(posedge clk) begin
        q_a <= mem[addr_a];
    end

    always @(posedge clk) begin
        if (we_b) mem[addr_b] <= d_b;
        q_b <= mem[addr_b];
    end
endmodule

// VGA Driver
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
    parameter [9:0] H_ACTIVE = 10'd639;
    parameter [9:0] H_FRONT  = 10'd15;
    parameter [9:0] H_PULSE  = 10'd95;
    parameter [9:0] H_BACK   = 10'd47;

    parameter [9:0] V_ACTIVE = 10'd479;
    parameter [9:0] V_FRONT  = 10'd9;
    parameter [9:0] V_PULSE  = 10'd1;
    parameter [9:0] V_BACK   = 10'd32;

    parameter LOW  = 1'b0;
    parameter HIGH = 1'b1;

    parameter [7:0] H_ACTIVE_STATE = 8'd0;
    parameter [7:0] H_FRONT_STATE  = 8'd1;
    parameter [7:0] H_PULSE_STATE  = 8'd2;
    parameter [7:0] H_BACK_STATE   = 8'd3;

    parameter [7:0] V_ACTIVE_STATE = 8'd0;
    parameter [7:0] V_FRONT_STATE  = 8'd1;
    parameter [7:0] V_PULSE_STATE  = 8'd2;
    parameter [7:0] V_BACK_STATE   = 8'd3;

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
            h_counter <= 10'd0;
            v_counter <= 10'd0;
            h_state   <= H_ACTIVE_STATE;
            v_state   <= V_ACTIVE_STATE;
            line_done <= LOW;
        end else begin
            if (h_state == H_ACTIVE_STATE) begin
                h_counter <= (h_counter == H_ACTIVE) ? 10'd0 : (h_counter + 10'd1);
                hysnc_reg <= HIGH;
                line_done <= LOW;
                h_state   <= (h_counter == H_ACTIVE) ? H_FRONT_STATE : H_ACTIVE_STATE;
            end
            if (h_state == H_FRONT_STATE) begin
                h_counter <= (h_counter == H_FRONT) ? 10'd0 : (h_counter + 10'd1);
                hysnc_reg <= HIGH;
                h_state   <= (h_counter == H_FRONT) ? H_PULSE_STATE : H_FRONT_STATE;
            end
            if (h_state == H_PULSE_STATE) begin
                h_counter <= (h_counter == H_PULSE) ? 10'd0 : (h_counter + 10'd1);
                hysnc_reg <= LOW;
                h_state   <= (h_counter == H_PULSE) ? H_BACK_STATE : H_PULSE_STATE;
            end
            if (h_state == H_BACK_STATE) begin
                h_counter <= (h_counter == H_BACK) ? 10'd0 : (h_counter + 10'd1);
                hysnc_reg <= HIGH;
                h_state   <= (h_counter == H_BACK) ? H_ACTIVE_STATE : H_BACK_STATE;
                line_done <= (h_counter == (H_BACK - 1)) ? HIGH : LOW;
            end
            if (v_state == V_ACTIVE_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_ACTIVE) ? 10'd0 : (v_counter + 10'd1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_ACTIVE) ? V_FRONT_STATE : V_ACTIVE_STATE) : V_ACTIVE_STATE;
            end
            if (v_state == V_FRONT_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_FRONT) ? 10'd0 : (v_counter + 10'd1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_FRONT) ? V_PULSE_STATE : V_FRONT_STATE) : V_FRONT_STATE;
            end
            if (v_state == V_PULSE_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_PULSE) ? 10'd0 : (v_counter + 10'd1)) : v_counter;
                vsync_reg <= LOW;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_PULSE) ? V_BACK_STATE : V_PULSE_STATE) : V_PULSE_STATE;
            end
            if (v_state == V_BACK_STATE) begin
                v_counter <= (line_done == HIGH) ? ((v_counter == V_BACK) ? 10'd0 : (v_counter + 10'd1)) : v_counter;
                vsync_reg <= HIGH;
                v_state   <= (line_done == HIGH) ? ((v_counter == V_BACK) ? V_ACTIVE_STATE : V_BACK_STATE) : V_BACK_STATE;
            end
            red_reg   <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[7:5], 5'd0} : 8'd0) : 8'd0;
            green_reg <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[4:2], 5'd0} : 8'd0) : 8'd0;
            blue_reg  <= (h_state == H_ACTIVE_STATE) ? ((v_state == V_ACTIVE_STATE) ? {color_in[1:0], 6'd0} : 8'd0) : 8'd0;
        end
    end

    assign hsync  = hysnc_reg;
    assign vsync  = vsync_reg;
    assign red    = red_reg;
    assign green  = green_reg;
    assign blue   = blue_reg;
    assign clk    = clock;
    assign sync   = 1'b0;
    assign blank  = hysnc_reg & vsync_reg;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE)  ? v_counter : 10'd0;

endmodule
