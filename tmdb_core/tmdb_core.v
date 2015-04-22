////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: tmdb_core.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tmdb_core #
(   
    // Set to 1 if in simulation mode
    parameter SIMULATION = 0,
    // If SIMULATION == 1, set USE_CHIPSCOPE = 0 and USE_GTP = 0
    parameter USE_CHIPSCOPE = 1,
    parameter USE_GTP = 1,
    parameter USE_MPU = 1,
    parameter USE_LVDS = 1,
    parameter USE_FRAG_GEN = 1,
    // Registers Parameters
    parameter REGS_QTY = 145,
    parameter REGS_DATA_WIDTH = 32,
    parameter FIRMWARE_VERSION = 10, //v1.0
	 parameter BOARD_ID = 1
)
(
	// Clock Inputs
	//input [5:0] clk_in,
    input         clk_in,
	//input [1:0] clk_in_pll,
	
	// Clock Outputs
	output [15:0] clk_out,
	
	// ADC interface -----------------------------------------------------------

	input [255:0] adc_in,
	
	// LVDS Connectors
	
	inout [15:0] lvdsL_conn,
	output 		 lvdsL_TXlo,
	output		 lvdsL_TXhi,
	inout [15:0] lvdsR_conn,
	output		 lvdsR_TXlo,
	output		 lvdsR_TXhi,
	
	// TTC ---------------------------------------------------------------------

	input [11:0] ttc_bcnt,
	input        ttc_bcntstr,
	input        ttc_bcntres,
	input        ttc_l1accept,
	input        ttc_evcntres,
	input        ttc_evcntlstr,
	input        ttc_evcnthstr,

	// External Oscillator for LANE0 ------------------------------------------

	input wire  TILE0_GTP1_REFCLK_PAD_N_IN,
	input wire  TILE0_GTP1_REFCLK_PAD_P_IN,
	
	// SFP enable outputs ----------------------------------------------------
	output wire  [3:0]   SFP_ENABLE,
	 
	// Transceivers I/Os -----------------------------------------------------

    input  wire  	   	 RXN_IN,
    input  wire  	    	 RXP_IN,
    output wire  [3:0]   TXN_OUT,
    output wire  [3:0]   TXP_OUT,

	// FPGA Comm interface ----------------------------------------------------

	inout [7:0] fi_data,
	input [5:0] fi_addr,
	inout       fi_write,
	inout       fi_read
);

`include "../common/array_conversion.v"

//----------------------------------------------------------------------------- 
//----------------------------------------------------------------------------- 

// Reset signal ---------------------------------------------------------------

wire		rst;

// Registers signals ----------------------------------------------------------

wire [REGS_QTY*REGS_DATA_WIDTH-1:0] iReg_temp;
wire [REGS_QTY*REGS_DATA_WIDTH-1:0] oReg_temp;
wire [REGS_DATA_WIDTH-1:0] iReg [REGS_QTY-1:0];
wire [REGS_DATA_WIDTH-1:0] oReg [REGS_QTY-1:0];
`PACK_ARRAY(REGS_DATA_WIDTH, REGS_QTY, iReg, iReg_temp, pak0)
`UNPACK_ARRAY(REGS_DATA_WIDTH, REGS_QTY, oReg_temp, oReg, unp0)
wire [REGS_QTY-1:0] pWrite;
wire [REGS_QTY-1:0] pRead;

// ChipScope signals ----------------------------------------------------------

wire    [35:0]  vio_control;
wire    [35:0]  ila_control_0;
wire    [35:0]  ila_control_1;
wire    [35:0]  ila_control_2;

wire    [7:0]   vio_async_in;
wire    [7:0]   vio_async_out;
wire    [7:0]   vio_sync_in;
wire    [255:0] vio_sync_out;

/******************************************************************************/
// Clocking 
/******************************************************************************/

wire [3:0] USR_CLK2_LANE;
wire       clk;

generate
if (SIMULATION==1)
    assign clk = clk_in;
else
    assign clk = USR_CLK2_LANE[1];
endgenerate

clock #
(
    .SIMULATION(SIMULATION)
)
clock_dist
(
	clk,
	clk_out
);
	
/******************************************************************************/
// ADC Buffering 
/******************************************************************************/

reg [255:0] adc_r = 0;

always @ (posedge clk) begin
	adc_r <= adc_in;
end

/******************************************************************************/
// MPU 
/******************************************************************************/

// The 'weights_m' array holds all the weights for the 32 channels.
wire [2239:0] weights_m;

// Threshold
wire [151:0] LT6p;
wire [151:0] HT6p;
wire [151:0] LT56p;
wire [151:0] HT56p;

wire [18:0] lt6;
wire [18:0] ht6;
wire [18:0] lt56;
wire [18:0] ht56;

// Neighbor Communication 
wire [3:0] ext_mod0;
wire [3:0] ext_mod9;
wire [3:0] ext_mod1;
wire [3:0] ext_mod8;

// SL Outputs
wire [15:0] sl1;
wire [15:0] sl2;
wire [15:0] sl3;

genvar i;
generate
if (USE_MPU==1)
begin : use_mpu

    for (i=0; i<8; i=i+1) begin : threshold
        assign LT6p[(i*19+19-1):(i*19)]  = lt6;
        assign HT6p[(i*19+19-1):(i*19)]  = ht6;
        assign LT56p[(i*19+19-1):(i*19)] = lt56;
        assign HT56p[(i*19+19-1):(i*19)] = ht56;
    end
    
    MPU # 
    (
        .USE_CHIPSCOPE(USE_CHIPSCOPE)
    )
    MPU_i
    (
        .rst					(rst), 
        .clk					(clk),

        // ADC converters ----------------------------------------------------------

        .adc_in                 (adc_r),
        
        // Weights Matrix ----------------------------------------------------------
        
        .weights_m              (weights_m),

        // Threshold --------------------------------------------------------------

        .LT6p                   (LT6p),
        .HT6p                   (HT6p),
        .LT56p                  (LT56p),
        .HT56p                  (HT56p),
        
        // Trigger from/to neighbored TMDB -----------------------------------------

        //Input
        .ext_mod0               (ext_mod0),
        .ext_mod9               (ext_mod9),

        //Ouput
        .ext_mod1               (ext_mod1),
        .ext_mod8               (ext_mod8),
        
        // Sector Logic outputs ----------------------------------------------------

        .sl1					(sl1), 
        .sl2					(sl2), 
        .sl3					(sl3),
        
        // ILA Control ------------------------------------------------------------
        
        .ila_control            (ila_control_0)
    );
end
else
begin : no_mpu

    assign sl1      = 16'h0000;
    assign sl2      = 16'h0000;
    assign sl3      = 16'h0000;
    assign ext_mod1 = 4'h0;
    assign ext_mod8 = 4'h0;
    
    if (USE_CHIPSCOPE==1)
        null_vio null_vio_0
        (
          .control                          (ila_control_0)
        ); 

end
endgenerate

/******************************************************************************/
// Fragment Generator 
/******************************************************************************/

// Input Wires to Fragment Generator
wire        fragmentGenEn;
wire [31:0] sourceIdentifier, runNumber;
wire        testEn, testSel, adcConstantSel;
wire        syncSel;
wire			vmeEcr;
wire        vmeHolaReset;
wire [7:0]  l1aLatency;
wire        LFF_N, LDOWN_N;
wire        vmeReadEnable;
wire [3:0]  trg_sel;

// Output Wires from Fragment Generator
wire        busyOut;
wire        vmeURESET_N, UCTRL_N, UWEN_N;
wire [31:0] UD;
wire        vmeEmptyFlag;
wire [31:0] vmeData;

generate
if (USE_FRAG_GEN==1) 
begin : fragGen

    FragmentGen #
    (
        .USE_CHIPSCOPE(USE_CHIPSCOPE)
    )
    FragmentGen_i
    (
        .rst(rst),
        .clk(clk),
        .enable(fragmentGenEn),
        
        // Data Fragment Registers ------------------------------------------------
        
        .sourceIdentifier(sourceIdentifier),
        .runNumber(runNumber),
        
        // Testing ----------------------------------------------------------------
        
        .testEn(testEn),         //1 -> TEST ENABLED ; 0 -> TEST DISABLED
        .testSel(testSel),       //1 -> TEST MODE    ; 0 -> NORMAL MODE
        
        //MUST FIX IT
        .adcConstantSel(1'b0),   //1 -> ADC CONSTANT ; 0 -> TEST DATA
        
        // Sync Selector  ---------------------------------------------------------
        
        .syncSel(syncSel),       //1 -> VME          ; 0 -> HOLA
        
        // HOLA Reset Request -----------------------------------------------------
        
        .holaReset(vmeHolaReset),
        
        // BUSY -------------------------------------------------------------------
        
        .busyOut(busyOut),
        
        // L1a stuff --------------------------------------------------------------

        .l1aLatency(l1aLatency),        
        .l1a(ttc_l1accept),
        .bCnt(ttc_bcnt),
        .bCntRes(ttc_bcntres),
        .bCntStr(ttc_bcntstr),
        .evCntRes(ttc_evcntres),
        .evCntLStr(ttc_evcntlstr),
        .evCntHStr(ttc_evcnthstr),
		  .vmeEcr(vmeEcr),
        
        // ADC interface ----------------------------------------------------------
        
        .adcIn(adc_r),
        
        // HOLA interface ---------------------------------------------------------
        
        .UD(UD),
        .URESET_N(vmeURESET_N),
        .UCTRL_N(UCTRL_N),
        .UWEN_N(UWEN_N),
        .LFF_N(LFF_N),
        .LDOWN_N(LDOWN_N),
        
        // Register interface (VME) -----------------------------------------------
        
        .vmeEmptyFlag(vmeEmptyFlag),
        .vmeReadEnable(vmeReadEnable),
        .vmeData(vmeData),
        
        // ILA Control ------------------------------------------------------------
        .trg_sel(trg_sel),
        .ila_control(ila_control_1)
    );
 
end
else
begin : no_fragGen
 
    assign busyOut      = 1'b1;  //no fragment gen? so it's busy.
    assign URESET_N     = 1'b1;  //deasserted.
    assign UCTRL_N      = 1'b1;  //deasserted.
    assign UWEN_N       = 1'b1;  //deasserted.
    assign UD           = 32'd0; //zero.
    assign vmeEmptyFlag = 1'b1;  //empty.
    assign vmeData      = 32'd0; //zero.
    
    if (USE_CHIPSCOPE==1)
        null_vio null_vio_1
        (
          .control                          (ila_control_1)
        ); 
    
end
endgenerate

/******************************************************************************/
// GTP Transceivers 
/******************************************************************************/

wire        URESET_N, UTEST_N;
wire        LANES123_SYNC_DONE, INT_RESETDONE;
wire			LANE0_FBPLL_LOCKED, LANES123_FBDCM_LOCKED, PLL_INPUT_LOCKED;
wire        TESTLED_N, LDERRLED_N, LUPLED_N, FLOWCTLLED_N, ACTIVITYLED_N;
wire [3:0]  RESET_LANE;
wire [3:0]  RESET_DONE;
wire [3:0]  PLL_LOCK_DET;
wire [15:0] lane1;
wire [15:0] lane2;
wire [15:0] lane3;
wire        lane1_cntl;
wire        lane1_data;
wire        lane2_cntl;
wire        lane2_data;
wire        lane3_cntl;
wire        lane3_data;

generate
if (USE_GTP==1)
begin : use_gtp
    
    wire		gtp1_refclk_buff;

    IBUFDS tile0_gtp1_refclk_ibufds_i
    (
      .O                              (gtp1_refclk_buff),
      .I                              (TILE0_GTP1_REFCLK_PAD_P_IN),
      .IB                             (TILE0_GTP1_REFCLK_PAD_N_IN)
    );
         
    gtp gtp_transceivers
    (
		  .PLL_INPUT_LOCKED				 (PLL_INPUT_LOCKED),
        .LANES123_FBDCM_LOCKED       (LANES123_FBDCM_LOCKED),
        .LANES123_SYNC_DONE          (LANES123_SYNC_DONE),
        // S-LINK interface
        .LANE0_FBPLL_LOCKED          (LANE0_FBPLL_LOCKED),
        .INT_RESETDONE               (INT_RESETDONE),
        .UD									 (UD),
        .URESET_N							 (URESET_N),
        .UTEST_N							 (UTEST_N),
        .UCTRL_N							 (UCTRL_N),
        .UWEN_N								 (UWEN_N),
        .UCLK								 (clk),
        .LFF_N								 (LFF_N),
        .LRL								 (),     
        .LDOWN_N							 (LDOWN_N),
        // S-LINK LEDs
        .TESTLED_N							 (TESTLED_N),
        .LDERRLED_N							 (LDERRLED_N),
        .LUPLED_N							 (LUPLED_N),
        .FLOWCTLLED_N					     (FLOWCTLLED_N), 
        .ACTIVITYLED_N					     (ACTIVITYLED_N),
        // GTP Signals
        .CLK_IN_40                           (clk_in),
        .LANE0_REFCLK					     (gtp1_refclk_buff),
    //	.TILE0_GTP1_REFCLK_PAD_N_IN          (TILE0_GTP1_REFCLK_PAD_N_IN),
    //	.TILE0_GTP1_REFCLK_PAD_P_IN          (TILE0_GTP1_REFCLK_PAD_P_IN),
        .USR_CLK2_LANE                       (USR_CLK2_LANE),
        .PLL_LOCK_DET                        (PLL_LOCK_DET),
    //	.RX_DATA_LANE0                       (),
    //	.TX_DATA_LANE0                       (16'h0000),
        .TX_DATA_LANE1                       (lane1), //sl1
        .TX_DATA_LANE2                       (lane2), //sl2
        .TX_DATA_LANE3                       (lane3), //sl3
        .RX_POWER_DOWN_LANE0                 (2'b00),
        .TX_POWER_DOWN_LANE0                 (2'b00),
        .TX_POWER_DOWN_LANE1                 (2'b00),
        .TX_POWER_DOWN_LANE2                 (2'b00),
        .TX_POWER_DOWN_LANE3                 (2'b00),
        .RESET_LANE                          (RESET_LANE),
        .RESET_DONE                          (RESET_DONE),
        .SFP_ENABLE                          (SFP_ENABLE),
        .RXN_IN                              (RXN_IN),
        .RXP_IN                              (RXP_IN),
        .TXN_OUT                             (TXN_OUT),
        .TXP_OUT                             (TXP_OUT),
        .lane1_cntl                          (lane1_cntl),
        .lane1_data                          (lane1_data),
        .lane2_cntl                          (lane2_cntl),
        .lane2_data                          (lane2_data),
        .lane3_cntl                          (lane3_cntl),
        .lane3_data                          (lane3_data),
        .ILA_CONTROL                         (ila_control_2)
    );

end
else
begin : no_gtp
    
    assign LDOWN_N            = 1'b0; //link is down.
    assign INT_RESETDONE      = 1'b0; //hola internal reset is not done.
    assign LANE0_FBPLL_LOCKED = 1'b0; //lane 0 feedback pll is not locked.
    assign TESTLED_N          = 1'b1; //deasserted.
    assign LDERRLED_N         = 1'b1; //deasserted.
    assign LUPLED_N           = 1'b1; //deasserted.
    assign FLOWCTLLED_N       = 1'b1; //deasserted.
    assign ACTIVITYLED_N      = 1'b1; //deasserted.
    assign PLL_LOCK_DET       = 3'd0; //pll lock detection is not asserted.
    
end
endgenerate

/******************************************************************************/
// LVDS Connectors 
/******************************************************************************/

generate
if (USE_LVDS==1)
begin : use_lvds
	
    /*
    reg [15:0] cntr = 0;

    always @ (posedge clk) begin
        if (rst) begin
            cntr <= 16'b0;
        end 
        else begin
            cntr <= cntr+1;
        end	
    end
    */
    
    //Left LVDS lo byte TX enabled
    assign lvdsL_TXlo = 1'b1; 

    //Left LVDS hi byte RX enabled
    assign lvdsL_TXhi = 1'b0;
    
    //BusyOut is at the LSB of the Left Connector
    assign lvdsL_conn[7:0] = {7'b0, busyOut};

    //Right LVDS lo byte TX enabled
    assign lvdsR_TXlo = 1'b1; 

    assign lvdsR_conn[3:0] = ext_mod1;
    assign lvdsR_conn[7:4] = ext_mod8;


    //Right LVDS hi byte RX enabled
    assign lvdsR_TXhi = 1'b0;

    assign ext_mod0  = lvdsR_conn[11:8];
    assign ext_mod9  = lvdsR_conn[15:12];

end
else
begin : no_lvds
    
    //Left LVDS lo byte RX enabled
    assign lvdsL_TXlo = 1'b0; 
    //Left LVDS hi byte RX enabled
    assign lvdsL_TXhi = 1'b0;
    //Right LVDS lo byte RX enabled
    assign lvdsR_TXlo = 1'b0; 
    //Right LVDS hi byte RX enabled
    assign lvdsR_TXhi = 1'b0;  
   
    assign ext_mod0 = 4'h0;
    assign ext_mod9 = 4'h0;
    
end
endgenerate

/******************************************************************************/
// FPGA Comm 
/******************************************************************************/

wire [31:0] comm_data_in;
wire [31:0] comm_data_out;
wire [5:0]  comm_addr;
wire [15:0] paging_addr;
wire comm_write;
wire comm_read;

sfpgaif fpga_comm_if
(
	.rst(rst),
	.clk(clk),
	
	.data_in(comm_data_in),
	.data_out(comm_data_out),
	.addr(comm_addr),
	.write(comm_write),
	.read(comm_read),
	
	.fi_addr(fi_addr),                           
	.fi_data(fi_data),
	.fi_read(fi_read),
	.fi_write(fi_write)
);

/******************************************************************************/
// Registers Declarations
/******************************************************************************/

// Page 0 ---------------------------------------------------------------------

// Reset Register
wire [31:0] resetReg;
localparam RESET_INDEX                   = 1;
assign resetReg                          = oReg[RESET_INDEX];

// Control Register
localparam CONTROL_INDEX                 = 2;
wire   vmeFragmentGenEn                  = oReg[CONTROL_INDEX][0];
assign testEn                            = oReg[CONTROL_INDEX][1];
assign testSel                           = oReg[CONTROL_INDEX][2];
assign syncSel                           = oReg[CONTROL_INDEX][3];
assign vmeEcr									  = oReg[CONTROL_INDEX][4];

// Status Register
localparam STATUS_INDEX                  = 3;
assign iReg[STATUS_INDEX]                = {30'd0, busyOut, vmeEmptyFlag};

// Data Fragment Register
localparam FRAGMENT_INDEX                = 4;
assign iReg[FRAGMENT_INDEX]              = vmeData;
assign vmeReadEnable                     = pRead[FRAGMENT_INDEX];

// L1A Latency Register
localparam L1A_LATENCY_INDEX             = 5;
assign l1aLatency                        = oReg[L1A_LATENCY_INDEX][7:0];

// Source Identifier Register
localparam SRC_IDENTIFIER_INDEX          = 6;
assign sourceIdentifier                  = oReg[SRC_IDENTIFIER_INDEX];

// Run Number Register
localparam RUN_NUMBER_INDEX              = 7;
assign runNumber                         = oReg[RUN_NUMBER_INDEX];

// HOLA Control Register
localparam HOLA_CONTROL_INDEX            = 8;
wire   vmeRstLane0                       = oReg[HOLA_CONTROL_INDEX][0];
assign vmeHolaReset                      = oReg[HOLA_CONTROL_INDEX][1];
wire   vmeUTEST_N                        = ~oReg[HOLA_CONTROL_INDEX][2];

// HOLA Status Register
localparam HOLA_STATUS_INDEX             = 9;
assign iReg[HOLA_STATUS_INDEX]           = {26'd0, PLL_LOCK_DET[0], ~LDERRLED_N, ~TESTLED_N, ~FLOWCTLLED_N, ~ACTIVITYLED_N, ~LUPLED_N};

// Board ID Register
localparam BOARD_ID_INDEX                = 10;
assign iReg[BOARD_ID_INDEX]              = BOARD_ID;

// Firmware Version Register
localparam FIRMWARE_VERSION_INDEX        = 11;
assign iReg[FIRMWARE_VERSION_INDEX]      = FIRMWARE_VERSION;

// G-Link Control Register
localparam GLINK_CONTROL_INDEX           = 12;
wire   vmeRstLane1                       = oReg[GLINK_CONTROL_INDEX][0];
wire   vmeRstLane2                       = oReg[GLINK_CONTROL_INDEX][1];
wire   vmeRstLane3                       = oReg[GLINK_CONTROL_INDEX][2];
wire   vmeCtrWordLane1                   = oReg[GLINK_CONTROL_INDEX][3];
wire   vmeCtrWordLane2                   = oReg[GLINK_CONTROL_INDEX][4];
wire   vmeCtrWordLane3                   = oReg[GLINK_CONTROL_INDEX][5];
wire   vmeDataWordLane1                  = oReg[GLINK_CONTROL_INDEX][6];
wire   vmeDataWordLane2                  = oReg[GLINK_CONTROL_INDEX][7];
wire   vmeDataWordLane3                  = oReg[GLINK_CONTROL_INDEX][8];
wire   vmeGlinkSel1                      = oReg[GLINK_CONTROL_INDEX][9];
wire   vmeGlinkSel2                      = oReg[GLINK_CONTROL_INDEX][10];
wire   vmeGlinkSel3                      = oReg[GLINK_CONTROL_INDEX][11];
wire   vmeGlinkPattern1                  = oReg[GLINK_CONTROL_INDEX][12];
wire   vmeGlinkPattern2                  = oReg[GLINK_CONTROL_INDEX][13];
wire   vmeGlinkPattern3                  = oReg[GLINK_CONTROL_INDEX][14];
wire   vmeGlinkCounterRst                = oReg[GLINK_CONTROL_INDEX][15];
wire   vmeGlinkCounterEn                 = oReg[GLINK_CONTROL_INDEX][16];

// G-Link Pattern 0 Register
localparam GLINK_PATTERN0_INDEX          = 13;
wire [15:0] vmePatternLane1              = oReg[GLINK_PATTERN0_INDEX][15:0];
wire [15:0] vmePatternLane2              = oReg[GLINK_PATTERN0_INDEX][31:16];

// G-Link Pattern 1 Register
localparam GLINK_PATTERN1_INDEX          = 14;
wire [15:0] vmePatternLane3              = oReg[GLINK_PATTERN1_INDEX][15:0];

// G-Link Status Register
localparam GLINK_STATUS_INDEX            = 15;
assign iReg[GLINK_STATUS_INDEX]          = {28'd0, LANES123_SYNC_DONE, PLL_LOCK_DET[3], PLL_LOCK_DET[2], PLL_LOCK_DET[1]};

// Clock Status Register
localparam CLOCK_STATUS_INDEX            = 16;
assign iReg[CLOCK_STATUS_INDEX]          = {29'd0, LANES123_FBDCM_LOCKED, LANE0_FBPLL_LOCKED, PLL_INPUT_LOCKED};

// Page 1 ---------------------------------------------------------------------

// Weights

wire      [31:0] W1_W0_ADC0                  = oReg[17];
wire      [31:0] W3_W2_ADC0                  = oReg[18];
wire      [31:0] W5_W4_ADC0                  = oReg[19];
wire      [31:0] W6_ADC0                  = oReg[20];
wire      [31:0] W1_W0_ADC1                  = oReg[21];
wire      [31:0] W3_W2_ADC1                  = oReg[22];
wire      [31:0] W5_W4_ADC1                  = oReg[23];
wire      [31:0] W6_ADC1                  = oReg[24];
wire      [31:0] W1_W0_ADC2                  = oReg[25];
wire      [31:0] W3_W2_ADC2                  = oReg[26];
wire      [31:0] W5_W4_ADC2                  = oReg[27];
wire      [31:0] W6_ADC2                  = oReg[28];
wire      [31:0] W1_W0_ADC3                  = oReg[29];
wire      [31:0] W3_W2_ADC3                  = oReg[30];
wire      [31:0] W5_W4_ADC3                  = oReg[31];
wire      [31:0] W6_ADC3                  = oReg[32];
wire      [31:0] W1_W0_ADC4                  = oReg[33];
wire      [31:0] W3_W2_ADC4                  = oReg[34];
wire      [31:0] W5_W4_ADC4                  = oReg[35];
wire      [31:0] W6_ADC4                  = oReg[36];
wire      [31:0] W1_W0_ADC5                  = oReg[37];
wire      [31:0] W3_W2_ADC5                  = oReg[38];
wire      [31:0] W5_W4_ADC5                  = oReg[39];
wire      [31:0] W6_ADC5                  = oReg[40];
wire      [31:0] W1_W0_ADC6                  = oReg[41];
wire      [31:0] W3_W2_ADC6                  = oReg[42];
wire      [31:0] W5_W4_ADC6                  = oReg[43];
wire      [31:0] W6_ADC6                  = oReg[44];
wire      [31:0] W1_W0_ADC7                  = oReg[45];
wire      [31:0] W3_W2_ADC7                  = oReg[46];
wire      [31:0] W5_W4_ADC7                  = oReg[47];
wire      [31:0] W6_ADC7                  = oReg[48];
wire      [31:0] W1_W0_ADC8                  = oReg[49];
wire      [31:0] W3_W2_ADC8                  = oReg[50];
wire      [31:0] W5_W4_ADC8                  = oReg[51];
wire      [31:0] W6_ADC8                  = oReg[52];
wire      [31:0] W1_W0_ADC9                  = oReg[53];
wire      [31:0] W3_W2_ADC9                  = oReg[54];
wire      [31:0] W5_W4_ADC9                  = oReg[55];
wire      [31:0] W6_ADC9                  = oReg[56];
wire      [31:0] W1_W0_ADC10                  = oReg[57];
wire      [31:0] W3_W2_ADC10                  = oReg[58];
wire      [31:0] W5_W4_ADC10                  = oReg[59];
wire      [31:0] W6_ADC10                  = oReg[60];
wire      [31:0] W1_W0_ADC11                  = oReg[61];
wire      [31:0] W3_W2_ADC11                  = oReg[62];
wire      [31:0] W5_W4_ADC11                  = oReg[63];
wire      [31:0] W6_ADC11                  = oReg[64];
wire      [31:0] W1_W0_ADC12                  = oReg[65];
wire      [31:0] W3_W2_ADC12                  = oReg[66];
wire      [31:0] W5_W4_ADC12                  = oReg[67];
wire      [31:0] W6_ADC12                  = oReg[68];
wire      [31:0] W1_W0_ADC13                  = oReg[69];
wire      [31:0] W3_W2_ADC13                  = oReg[70];
wire      [31:0] W5_W4_ADC13                  = oReg[71];
wire      [31:0] W6_ADC13                  = oReg[72];
wire      [31:0] W1_W0_ADC14                  = oReg[73];
wire      [31:0] W3_W2_ADC14                  = oReg[74];
wire      [31:0] W5_W4_ADC14                  = oReg[75];
wire      [31:0] W6_ADC14                  = oReg[76];

// Page 2 ---------------------------------------------------------------------

// Weights
wire      [31:0] W1_W0_ADC15                  = oReg[77];
wire      [31:0] W3_W2_ADC15                  = oReg[78];
wire      [31:0] W5_W4_ADC15                  = oReg[79];
wire      [31:0] W6_ADC15                  = oReg[80];
wire      [31:0] W1_W0_ADC16                  = oReg[81];
wire      [31:0] W3_W2_ADC16                  = oReg[82];
wire      [31:0] W5_W4_ADC16                  = oReg[83];
wire      [31:0] W6_ADC16                  = oReg[84];
wire      [31:0] W1_W0_ADC17                  = oReg[85];
wire      [31:0] W3_W2_ADC17                  = oReg[86];
wire      [31:0] W5_W4_ADC17                  = oReg[87];
wire      [31:0] W6_ADC17                  = oReg[88];
wire      [31:0] W1_W0_ADC18                  = oReg[89];
wire      [31:0] W3_W2_ADC18                  = oReg[90];
wire      [31:0] W5_W4_ADC18                  = oReg[91];
wire      [31:0] W6_ADC18                  = oReg[92];
wire      [31:0] W1_W0_ADC19                  = oReg[93];
wire      [31:0] W3_W2_ADC19                  = oReg[94];
wire      [31:0] W5_W4_ADC19                  = oReg[95];
wire      [31:0] W6_ADC19                  = oReg[96];
wire      [31:0] W1_W0_ADC20                  = oReg[97];
wire      [31:0] W3_W2_ADC20                  = oReg[98];
wire      [31:0] W5_W4_ADC20                  = oReg[99];
wire      [31:0] W6_ADC20                  = oReg[100];
wire      [31:0] W1_W0_ADC21                  = oReg[101];
wire      [31:0] W3_W2_ADC21                  = oReg[102];
wire      [31:0] W5_W4_ADC21                  = oReg[103];
wire      [31:0] W6_ADC21                  = oReg[104];
wire      [31:0] W1_W0_ADC22                  = oReg[105];
wire      [31:0] W3_W2_ADC22                  = oReg[106];
wire      [31:0] W5_W4_ADC22                  = oReg[107];
wire      [31:0] W6_ADC22                  = oReg[108];
wire      [31:0] W1_W0_ADC23                  = oReg[109];
wire      [31:0] W3_W2_ADC23                  = oReg[110];
wire      [31:0] W5_W4_ADC23                  = oReg[111];
wire      [31:0] W6_ADC23                  = oReg[112];
wire      [31:0] W1_W0_ADC24                  = oReg[113];
wire      [31:0] W3_W2_ADC24                  = oReg[114];
wire      [31:0] W5_W4_ADC24                  = oReg[115];
wire      [31:0] W6_ADC24                  = oReg[116];
wire      [31:0] W1_W0_ADC25                  = oReg[117];
wire      [31:0] W3_W2_ADC25                  = oReg[118];
wire      [31:0] W5_W4_ADC25                  = oReg[119];
wire      [31:0] W6_ADC25                  = oReg[120];
wire      [31:0] W1_W0_ADC26                  = oReg[121];
wire      [31:0] W3_W2_ADC26                  = oReg[122];
wire      [31:0] W5_W4_ADC26                  = oReg[123];
wire      [31:0] W6_ADC26                  = oReg[124];
wire      [31:0] W1_W0_ADC27                  = oReg[125];
wire      [31:0] W3_W2_ADC27                  = oReg[126];
wire      [31:0] W5_W4_ADC27                  = oReg[127];
wire      [31:0] W6_ADC27                  = oReg[128];
wire      [31:0] W1_W0_ADC28                  = oReg[129];
wire      [31:0] W3_W2_ADC28                  = oReg[130];
wire      [31:0] W5_W4_ADC28                  = oReg[131];
wire      [31:0] W6_ADC28                  = oReg[132];
wire      [31:0] W1_W0_ADC29                  = oReg[133];
wire      [31:0] W3_W2_ADC29                  = oReg[134];
wire      [31:0] W5_W4_ADC29                  = oReg[135];
wire      [31:0] W6_ADC29                  = oReg[136];

// Page 3 ---------------------------------------------------------------------

// Weights
wire      [31:0] W1_W0_ADC30                  = oReg[137];
wire      [31:0] W3_W2_ADC30                  = oReg[138];
wire      [31:0] W5_W4_ADC30                  = oReg[139];
wire      [31:0] W6_ADC30                  = oReg[140];
wire      [31:0] W1_W0_ADC31                  = oReg[141];
wire      [31:0] W3_W2_ADC31                  = oReg[142];
wire      [31:0] W5_W4_ADC31                  = oReg[143];
wire      [31:0] W6_ADC31                  = oReg[144];

/*
// ADC Registers
parameter ADC_REG_START = 10;
parameter ADC_REG_QTY   = 8;
parameter ADC_PER_REG   = 4;


generate
    for (i=0; i<ADC_REG_QTY; i=i+1) begin : adc_regs
        //Connecting the 'bc_data' bus to the registers's buses
        assign iReg[i+ADC_REG_START] = 
            bc_data[(i*REGS_DATA_WIDTH+REGS_DATA_WIDTH-1):(i*REGS_DATA_WIDTH)];
        //Connecting the registers's read strobes to the 'bc_read' port
        assign bc_read[i*ADC_PER_REG+ADC_PER_REG-1:i*ADC_PER_REG] = 
            {pRead[i+ADC_REG_START], pRead[i+ADC_REG_START], 
             pRead[i+ADC_REG_START], pRead[i+ADC_REG_START]};
    end
endgenerate
*/
                
/******************************************************************************/
// Registers Component 
/******************************************************************************/

// Paging Scheme
parameter PAGE_REG_INDEX = 0;

assign paging_addr = {oReg[PAGE_REG_INDEX][9:0], comm_addr}; 
    
cRegs registers
(
	.rst(rst),
	.clk(clk),
	
	.addr(paging_addr),
	.read(comm_read),
	.write(comm_write),
	.iData(comm_data_out),
	.oData(comm_data_in),
    
    //WHAT MATTERS HIPPIE!
	.iReg(iReg_temp),
	.oReg(oReg_temp),
	.pWrite(pWrite),
	.pRead(pRead)
);


/******************************************************************************/
// Reset Generator 
/******************************************************************************/

wire vmeReset;

resetGen resetGen_i
(
    .clk(clk),
    .resetRequestWord(resetReg),
    .resetOut(vmeReset)
);
    
/******************************************************************************/
// ChipScope 
/******************************************************************************/

// G-Link data counter     
reg [15:0] data_counter = 0;
wire       glink_sel1;
wire       glink_sel2;
wire       glink_sel3;
wire       glink_pattern1;
wire       glink_pattern2;
wire       glink_pattern3;
wire       reset_counter;
wire       enable_counter;

 always @ (posedge clk)
	if      (reset_counter)  data_counter <= 16'd0;
	else if (enable_counter) data_counter <= data_counter + 1; 
	
wire            tied_to_ground;
wire    [255:0] tied_to_ground_vec;

generate
if (USE_CHIPSCOPE==1) 
begin : chipscope
    
    // ChipScope VIO
    chipscope_vio chipscope_vio_0
    (
     .CLK                               (clk),
	  .CONTROL                           (vio_control),
	  .ASYNC_IN                          (vio_async_in),
     .ASYNC_OUT                         (vio_async_out),
	  .SYNC_IN                           (vio_sync_in),
	  .SYNC_OUT                          (vio_sync_out)
    );
    
    // ICON
    chipscope_icon chipscope_icon_0
    (
      .CONTROL0                          (vio_control),
      .CONTROL1                          (ila_control_0),
      .CONTROL2                          (ila_control_1),
      .CONTROL3                          (ila_control_2)
    );
    //FIR weights
    // Each 'weights' array holds seven weight values (10-bit weights).
	
	// From Page 1
	
	assign weights_m[9:0] =  W1_W0_ADC0[9:0];
	assign weights_m[19:10] =  W1_W0_ADC0[25:16];
	assign weights_m[29:20] =  W3_W2_ADC0[9:0];
	assign weights_m[39:30] =  W3_W2_ADC0[25:16];
	assign weights_m[49:40] =  W5_W4_ADC0[9:0];
	assign weights_m[59:50] =  W5_W4_ADC0[25:16];
	assign weights_m[69:60] =  W6_ADC0[9:0];
	assign weights_m[79:70] =  W1_W0_ADC1[9:0];
	assign weights_m[89:80] =  W1_W0_ADC1[25:16];
	assign weights_m[99:90] =  W3_W2_ADC1[9:0];
	assign weights_m[109:100] =  W3_W2_ADC1[25:16];
	assign weights_m[119:110] =  W5_W4_ADC1[9:0];
	assign weights_m[129:120] =  W5_W4_ADC1[25:16];
	assign weights_m[139:130] =  W6_ADC1[9:0];
	assign weights_m[149:140] =  W1_W0_ADC2[9:0];
	assign weights_m[159:150] =  W1_W0_ADC2[25:16];
	assign weights_m[169:160] =  W3_W2_ADC2[9:0];
	assign weights_m[179:170] =  W3_W2_ADC2[25:16];
	assign weights_m[189:180] =  W5_W4_ADC2[9:0];
	assign weights_m[199:190] =  W5_W4_ADC2[25:16];
	assign weights_m[209:200] =  W6_ADC2[9:0];
	assign weights_m[219:210] =  W1_W0_ADC3[9:0];
	assign weights_m[229:220] =  W1_W0_ADC3[25:16];
	assign weights_m[239:230] =  W3_W2_ADC3[9:0];
	assign weights_m[249:240] =  W3_W2_ADC3[25:16];
	assign weights_m[259:250] =  W5_W4_ADC3[9:0];
	assign weights_m[269:260] =  W5_W4_ADC3[25:16];
	assign weights_m[279:270] =  W6_ADC3[9:0];
	assign weights_m[289:280] =  W1_W0_ADC4[9:0];
	assign weights_m[299:290] =  W1_W0_ADC4[25:16];
	assign weights_m[309:300] =  W3_W2_ADC4[9:0];
	assign weights_m[319:310] =  W3_W2_ADC4[25:16];
	assign weights_m[329:320] =  W5_W4_ADC4[9:0];
	assign weights_m[339:330] =  W5_W4_ADC4[25:16];
	assign weights_m[349:340] =  W6_ADC4[9:0];
	assign weights_m[359:350] =  W1_W0_ADC5[9:0];
	assign weights_m[369:360] =  W1_W0_ADC5[25:16];
	assign weights_m[379:370] =  W3_W2_ADC5[9:0];
	assign weights_m[389:380] =  W3_W2_ADC5[25:16];
	assign weights_m[399:390] =  W5_W4_ADC5[9:0];
	assign weights_m[409:400] =  W5_W4_ADC5[25:16];
	assign weights_m[419:410] =  W6_ADC5[9:0];
	assign weights_m[429:420] =  W1_W0_ADC6[9:0];
	assign weights_m[439:430] =  W1_W0_ADC6[25:16];
	assign weights_m[449:440] =  W3_W2_ADC6[9:0];
	assign weights_m[459:450] =  W3_W2_ADC6[25:16];
	assign weights_m[469:460] =  W5_W4_ADC6[9:0];
	assign weights_m[479:470] =  W5_W4_ADC6[25:16];
	assign weights_m[489:480] =  W6_ADC6[9:0];
	assign weights_m[499:490] =  W1_W0_ADC7[9:0];
	assign weights_m[509:500] =  W1_W0_ADC7[25:16];
	assign weights_m[519:510] =  W3_W2_ADC7[9:0];
	assign weights_m[529:520] =  W3_W2_ADC7[25:16];
	assign weights_m[539:530] =  W5_W4_ADC7[9:0];
	assign weights_m[549:540] =  W5_W4_ADC7[25:16];
	assign weights_m[559:550] =  W6_ADC7[9:0];
	assign weights_m[569:560] =  W1_W0_ADC8[9:0];
	assign weights_m[579:570] =  W1_W0_ADC8[25:16];
	assign weights_m[589:580] =  W3_W2_ADC8[9:0];
	assign weights_m[599:590] =  W3_W2_ADC8[25:16];
	assign weights_m[609:600] =  W5_W4_ADC8[9:0];
	assign weights_m[619:610] =  W5_W4_ADC8[25:16];
	assign weights_m[629:620] =  W6_ADC8[9:0];
	assign weights_m[639:630] =  W1_W0_ADC9[9:0];
	assign weights_m[649:640] =  W1_W0_ADC9[25:16];
	assign weights_m[659:650] =  W3_W2_ADC9[9:0];
	assign weights_m[669:660] =  W3_W2_ADC9[25:16];
	assign weights_m[679:670] =  W5_W4_ADC9[9:0];
	assign weights_m[689:680] =  W5_W4_ADC9[25:16];
	assign weights_m[699:690] =  W6_ADC9[9:0];
	assign weights_m[709:700] =  W1_W0_ADC10[9:0];
	assign weights_m[719:710] =  W1_W0_ADC10[25:16];
	assign weights_m[729:720] =  W3_W2_ADC10[9:0];
	assign weights_m[739:730] =  W3_W2_ADC10[25:16];
	assign weights_m[749:740] =  W5_W4_ADC10[9:0];
	assign weights_m[759:750] =  W5_W4_ADC10[25:16];
	assign weights_m[769:760] =  W6_ADC10[9:0];
	assign weights_m[779:770] =  W1_W0_ADC11[9:0];
	assign weights_m[789:780] =  W1_W0_ADC11[25:16];
	assign weights_m[799:790] =  W3_W2_ADC11[9:0];
	assign weights_m[809:800] =  W3_W2_ADC11[25:16];
	assign weights_m[819:810] =  W5_W4_ADC11[9:0];
	assign weights_m[829:820] =  W5_W4_ADC11[25:16];
	assign weights_m[839:830] =  W6_ADC11[9:0];
	assign weights_m[849:840] =  W1_W0_ADC12[9:0];
	assign weights_m[859:850] =  W1_W0_ADC12[25:16];
	assign weights_m[869:860] =  W3_W2_ADC12[9:0];
	assign weights_m[879:870] =  W3_W2_ADC12[25:16];
	assign weights_m[889:880] =  W5_W4_ADC12[9:0];
	assign weights_m[899:890] =  W5_W4_ADC12[25:16];
	assign weights_m[909:900] =  W6_ADC12[9:0];
	assign weights_m[919:910] =  W1_W0_ADC13[9:0];
	assign weights_m[929:920] =  W1_W0_ADC13[25:16];
	assign weights_m[939:930] =  W3_W2_ADC13[9:0];
	assign weights_m[949:940] =  W3_W2_ADC13[25:16];
	assign weights_m[959:950] =  W5_W4_ADC13[9:0];
	assign weights_m[969:960] =  W5_W4_ADC13[25:16];
	assign weights_m[979:970] =  W6_ADC13[9:0];
	assign weights_m[989:980] =  W1_W0_ADC14[9:0];
	assign weights_m[999:990] =  W1_W0_ADC14[25:16];
	assign weights_m[1009:1000] =  W3_W2_ADC14[9:0];
	assign weights_m[1019:1010] =  W3_W2_ADC14[25:16];
	assign weights_m[1029:1020] =  W5_W4_ADC14[9:0];
	assign weights_m[1039:1030] =  W5_W4_ADC14[25:16];
	assign weights_m[1049:1040] =  W6_ADC14[9:0];

	// From Page 2
	
	assign weights_m[1059:1050] =  W1_W0_ADC15[9:0];
	assign weights_m[1069:1060] =  W1_W0_ADC15[25:16];
	assign weights_m[1079:1070] =  W3_W2_ADC15[9:0];
	assign weights_m[1089:1080] =  W3_W2_ADC15[25:16];
	assign weights_m[1099:1090] =  W5_W4_ADC15[9:0];
	assign weights_m[1109:1100] =  W5_W4_ADC15[25:16];
	assign weights_m[1119:1110] =  W6_ADC15[9:0];
	assign weights_m[1129:1120] =  W1_W0_ADC16[9:0];
	assign weights_m[1139:1130] =  W1_W0_ADC16[25:16];
	assign weights_m[1149:1140] =  W3_W2_ADC16[9:0];
	assign weights_m[1159:1150] =  W3_W2_ADC16[25:16];
	assign weights_m[1169:1160] =  W5_W4_ADC16[9:0];
	assign weights_m[1179:1170] =  W5_W4_ADC16[25:16];
	assign weights_m[1189:1180] =  W6_ADC16[9:0];
	assign weights_m[1199:1190] =  W1_W0_ADC17[9:0];
	assign weights_m[1209:1200] =  W1_W0_ADC17[25:16];
	assign weights_m[1219:1210] =  W3_W2_ADC17[9:0];
	assign weights_m[1229:1220] =  W3_W2_ADC17[25:16];
	assign weights_m[1239:1230] =  W5_W4_ADC17[9:0];
	assign weights_m[1249:1240] =  W5_W4_ADC17[25:16];
	assign weights_m[1259:1250] =  W6_ADC17[9:0];
	assign weights_m[1269:1260] =  W1_W0_ADC18[9:0];
	assign weights_m[1279:1270] =  W1_W0_ADC18[25:16];
	assign weights_m[1289:1280] =  W3_W2_ADC18[9:0];
	assign weights_m[1299:1290] =  W3_W2_ADC18[25:16];
	assign weights_m[1309:1300] =  W5_W4_ADC18[9:0];
	assign weights_m[1319:1310] =  W5_W4_ADC18[25:16];
	assign weights_m[1329:1320] =  W6_ADC18[9:0];
	assign weights_m[1339:1330] =  W1_W0_ADC19[9:0];
	assign weights_m[1349:1340] =  W1_W0_ADC19[25:16];
	assign weights_m[1359:1350] =  W3_W2_ADC19[9:0];
	assign weights_m[1369:1360] =  W3_W2_ADC19[25:16];
	assign weights_m[1379:1370] =  W5_W4_ADC19[9:0];
	assign weights_m[1389:1380] =  W5_W4_ADC19[25:16];
	assign weights_m[1399:1390] =  W6_ADC19[9:0];
	assign weights_m[1409:1400] =  W1_W0_ADC20[9:0];
	assign weights_m[1419:1410] =  W1_W0_ADC20[25:16];
	assign weights_m[1429:1420] =  W3_W2_ADC20[9:0];
	assign weights_m[1439:1430] =  W3_W2_ADC20[25:16];
	assign weights_m[1449:1440] =  W5_W4_ADC20[9:0];
	assign weights_m[1459:1450] =  W5_W4_ADC20[25:16];
	assign weights_m[1469:1460] =  W6_ADC20[9:0];
	assign weights_m[1479:1470] =  W1_W0_ADC21[9:0];
	assign weights_m[1489:1480] =  W1_W0_ADC21[25:16];
	assign weights_m[1499:1490] =  W3_W2_ADC21[9:0];
	assign weights_m[1509:1500] =  W3_W2_ADC21[25:16];
	assign weights_m[1519:1510] =  W5_W4_ADC21[9:0];
	assign weights_m[1529:1520] =  W5_W4_ADC21[25:16];
	assign weights_m[1539:1530] =  W6_ADC21[9:0];
	assign weights_m[1549:1540] =  W1_W0_ADC22[9:0];
	assign weights_m[1559:1550] =  W1_W0_ADC22[25:16];
	assign weights_m[1569:1560] =  W3_W2_ADC22[9:0];
	assign weights_m[1579:1570] =  W3_W2_ADC22[25:16];
	assign weights_m[1589:1580] =  W5_W4_ADC22[9:0];
	assign weights_m[1599:1590] =  W5_W4_ADC22[25:16];
	assign weights_m[1609:1600] =  W6_ADC22[9:0];
	assign weights_m[1619:1610] =  W1_W0_ADC23[9:0];
	assign weights_m[1629:1620] =  W1_W0_ADC23[25:16];
	assign weights_m[1639:1630] =  W3_W2_ADC23[9:0];
	assign weights_m[1649:1640] =  W3_W2_ADC23[25:16];
	assign weights_m[1659:1650] =  W5_W4_ADC23[9:0];
	assign weights_m[1669:1660] =  W5_W4_ADC23[25:16];
	assign weights_m[1679:1670] =  W6_ADC23[9:0];
	assign weights_m[1689:1680] =  W1_W0_ADC24[9:0];
	assign weights_m[1699:1690] =  W1_W0_ADC24[25:16];
	assign weights_m[1709:1700] =  W3_W2_ADC24[9:0];
	assign weights_m[1719:1710] =  W3_W2_ADC24[25:16];
	assign weights_m[1729:1720] =  W5_W4_ADC24[9:0];
	assign weights_m[1739:1730] =  W5_W4_ADC24[25:16];
	assign weights_m[1749:1740] =  W6_ADC24[9:0];
	assign weights_m[1759:1750] =  W1_W0_ADC25[9:0];
	assign weights_m[1769:1760] =  W1_W0_ADC25[25:16];
	assign weights_m[1779:1770] =  W3_W2_ADC25[9:0];
	assign weights_m[1789:1780] =  W3_W2_ADC25[25:16];
	assign weights_m[1799:1790] =  W5_W4_ADC25[9:0];
	assign weights_m[1809:1800] =  W5_W4_ADC25[25:16];
	assign weights_m[1819:1810] =  W6_ADC25[9:0];
	assign weights_m[1829:1820] =  W1_W0_ADC26[9:0];
	assign weights_m[1839:1830] =  W1_W0_ADC26[25:16];
	assign weights_m[1849:1840] =  W3_W2_ADC26[9:0];
	assign weights_m[1859:1850] =  W3_W2_ADC26[25:16];
	assign weights_m[1869:1860] =  W5_W4_ADC26[9:0];
	assign weights_m[1879:1870] =  W5_W4_ADC26[25:16];
	assign weights_m[1889:1880] =  W6_ADC26[9:0];
	assign weights_m[1899:1890] =  W1_W0_ADC27[9:0];
	assign weights_m[1909:1900] =  W1_W0_ADC27[25:16];
	assign weights_m[1919:1910] =  W3_W2_ADC27[9:0];
	assign weights_m[1929:1920] =  W3_W2_ADC27[25:16];
	assign weights_m[1939:1930] =  W5_W4_ADC27[9:0];
	assign weights_m[1949:1940] =  W5_W4_ADC27[25:16];
	assign weights_m[1959:1950] =  W6_ADC27[9:0];
	assign weights_m[1969:1960] =  W1_W0_ADC28[9:0];
	assign weights_m[1979:1970] =  W1_W0_ADC28[25:16];
	assign weights_m[1989:1980] =  W3_W2_ADC28[9:0];
	assign weights_m[1999:1990] =  W3_W2_ADC28[25:16];
	assign weights_m[2009:2000] =  W5_W4_ADC28[9:0];
	assign weights_m[2019:2010] =  W5_W4_ADC28[25:16];
	assign weights_m[2029:2020] =  W6_ADC28[9:0];
	assign weights_m[2039:2030] =  W1_W0_ADC29[9:0];
	assign weights_m[2049:2040] =  W1_W0_ADC29[25:16];
	assign weights_m[2059:2050] =  W3_W2_ADC29[9:0];
	assign weights_m[2069:2060] =  W3_W2_ADC29[25:16];
	assign weights_m[2079:2070] =  W5_W4_ADC29[9:0];
	assign weights_m[2089:2080] =  W5_W4_ADC29[25:16];
	assign weights_m[2099:2090] =  W6_ADC29[9:0];
	
	// From Page 3
	
	assign weights_m[2109:2100] =  W1_W0_ADC30[9:0];
	assign weights_m[2119:2110] =  W1_W0_ADC30[25:16];
	assign weights_m[2129:2120] =  W3_W2_ADC30[9:0];
	assign weights_m[2139:2130] =  W3_W2_ADC30[25:16];
	assign weights_m[2149:2140] =  W5_W4_ADC30[9:0];
	assign weights_m[2159:2150] =  W5_W4_ADC30[25:16];
	assign weights_m[2169:2160] =  W6_ADC30[9:0];
	assign weights_m[2179:2170] =  W1_W0_ADC31[9:0];
	assign weights_m[2189:2180] =  W1_W0_ADC31[25:16];
	assign weights_m[2199:2190] =  W3_W2_ADC31[9:0];
	assign weights_m[2209:2200] =  W3_W2_ADC31[25:16];
	assign weights_m[2219:2210] =  W5_W4_ADC31[9:0];
	assign weights_m[2229:2220] =  W5_W4_ADC31[25:16];
	assign weights_m[2239:2230] =  W6_ADC31[9:0];

    /*for (i=0; i<32; i=i+1) begin : w_weight
        assign weights_m[(i*70+70-1):(i*70)] = weights;		
    end*/

   // VIO Asynchronous Outputs
    
	//Resets are controlled via Chipscope or VME

   assign  rst                          =  vio_async_out[0] | vmeReset;
	assign  RESET_LANE[0]                =  vio_async_out[1] | vmeRstLane0;  
	assign  RESET_LANE[1]                =  vio_async_out[2] | vmeRstLane1;
	assign  RESET_LANE[2]                =  vio_async_out[3];              	// Signal 'vmeReset' CANNOT reset lane 2 
	assign  RESET_LANE[3]                =  vio_async_out[4] | vmeRstLane3; 
 
   // VIO Asynchronous Inputs
	
	assign  vio_async_in[0]              =  RESET_DONE[0];
	assign  vio_async_in[1]              =  LANES123_SYNC_DONE;
	assign  vio_async_in[2]              =  vmeReset;
//	assign  vio_async_in[3]              =  RESET_DONE[3];
	assign  vio_async_in[4]              =  PLL_LOCK_DET[0];
	assign  vio_async_in[5]              =  PLL_LOCK_DET[1];
	assign  vio_async_in[6]              =  PLL_LOCK_DET[2];
	assign  vio_async_in[7]              =  PLL_LOCK_DET[3];		
    
   // VIO Synchronous Outputs 
   assign  weights           =  vio_sync_out[69:0];
   assign  lt6               =  vio_sync_out[88:70];
	assign  ht6               =  vio_sync_out[107:89];
	assign  lt56              =  vio_sync_out[126:108];
	assign  ht56              =  vio_sync_out[145:127];
	assign  lane1             =  glink_sel1 ? (glink_pattern1 ? data_counter : vio_sync_out[161:146] | vmePatternLane1) : sl1;
	assign  lane2             =  glink_sel2 ? (glink_pattern2 ? data_counter : vio_sync_out[177:162] | vmePatternLane2) : sl2;
	assign  lane3             =  glink_sel3 ? (glink_pattern3 ? data_counter : vio_sync_out[193:178] | vmePatternLane3) : sl3;
	assign  lane1_cntl        =  vio_sync_out[194] | vmeCtrWordLane1;
	assign  lane1_data        =  vio_sync_out[195] | vmeDataWordLane1;
	assign  lane2_cntl        =  vio_sync_out[196] | vmeCtrWordLane2;
	assign  lane2_data        =  vio_sync_out[197] | vmeDataWordLane2;
	assign  lane3_cntl        =  vio_sync_out[198] | vmeCtrWordLane3;
	assign  lane3_data        =  vio_sync_out[199] | vmeDataWordLane3;
   assign  fragmentGenEn     =  vio_sync_out[200] | vmeFragmentGenEn; // Signal fragmentGenEn can be controlled via Chipscope OR VME
   assign  UTEST_N           =  ~vio_sync_out[201] && vmeUTEST_N;     // Signal UTEST_N from HOLA can be controlled via Chipscope OR VME
   assign  URESET_N          =  ~vio_sync_out[202] && vmeURESET_N;    // Signal URESET_N from HOLA can be controlled via Chipscope OR VME
   
	// Signals glink_sel can be controlled via Chipscope OR VME
	 
	assign	glink_sel1       =  vio_sync_out[203] | vmeGlinkSel1;
	assign	glink_sel2       =  vio_sync_out[206] | vmeGlinkSel2;
	assign	glink_sel3       =  vio_sync_out[207] | vmeGlinkSel3;
	assign	glink_pattern1   =  vio_sync_out[208] | vmeGlinkPattern1;
	assign	glink_pattern2   =  vio_sync_out[209] | vmeGlinkPattern2;
	assign	glink_pattern3   =  vio_sync_out[210] | vmeGlinkPattern3;
	assign	reset_counter    =  vio_sync_out[204] | vmeGlinkCounterRst;
   assign	enable_counter   =  vio_sync_out[205] | vmeGlinkCounterEn;
	
	// VIO MUX for triggering channels with thrshold
	
	assign   trg_sel          =  vio_sync_out[214:211];
	
	// VIO Synchronous Inputs

   assign  vio_sync_in[0]   =  ~TESTLED_N;
   assign  vio_sync_in[1]   =  ~LDERRLED_N;
   assign  vio_sync_in[2]   =  ~LUPLED_N;
   assign  vio_sync_in[3]   =  ~FLOWCTLLED_N;
   assign  vio_sync_in[4]   =  ~ACTIVITYLED_N;
   assign  vio_sync_in[5]   =  ~LDOWN_N;
   assign  vio_sync_in[6]   =  INT_RESETDONE;
   assign  vio_sync_in[7]   =  LANE0_FBPLL_LOCKED;
  
end //end USE_CHIPSCOPE=1 generate section
else
begin: no_chipscope

   assign  rst                          =  vmeReset;
	assign  RESET_LANE[0]                =  vmeRstLane0;
	assign  RESET_LANE[1]                =  vmeRstLane1;
	assign  RESET_LANE[2]                =  vmeRstLane2;
	assign  RESET_LANE[3]                =  vmeRstLane3;

    //FIR weights
    // Each 'weights' array holds seven weight values (10-bit weights).
	
	// From Page 1
		
	assign weights_m[9:0] =  W1_W0_ADC0[9:0];
	assign weights_m[19:10] =  W1_W0_ADC0[25:16];
	assign weights_m[29:20] =  W3_W2_ADC0[9:0];
	assign weights_m[39:30] =  W3_W2_ADC0[25:16];
	assign weights_m[49:40] =  W5_W4_ADC0[9:0];
	assign weights_m[59:50] =  W5_W4_ADC0[25:16];
	assign weights_m[69:60] =  W6_ADC0[9:0];
	assign weights_m[79:70] =  W1_W0_ADC1[9:0];
	assign weights_m[89:80] =  W1_W0_ADC1[25:16];
	assign weights_m[99:90] =  W3_W2_ADC1[9:0];
	assign weights_m[109:100] =  W3_W2_ADC1[25:16];
	assign weights_m[119:110] =  W5_W4_ADC1[9:0];
	assign weights_m[129:120] =  W5_W4_ADC1[25:16];
	assign weights_m[139:130] =  W6_ADC1[9:0];
	assign weights_m[149:140] =  W1_W0_ADC2[9:0];
	assign weights_m[159:150] =  W1_W0_ADC2[25:16];
	assign weights_m[169:160] =  W3_W2_ADC2[9:0];
	assign weights_m[179:170] =  W3_W2_ADC2[25:16];
	assign weights_m[189:180] =  W5_W4_ADC2[9:0];
	assign weights_m[199:190] =  W5_W4_ADC2[25:16];
	assign weights_m[209:200] =  W6_ADC2[9:0];
	assign weights_m[219:210] =  W1_W0_ADC3[9:0];
	assign weights_m[229:220] =  W1_W0_ADC3[25:16];
	assign weights_m[239:230] =  W3_W2_ADC3[9:0];
	assign weights_m[249:240] =  W3_W2_ADC3[25:16];
	assign weights_m[259:250] =  W5_W4_ADC3[9:0];
	assign weights_m[269:260] =  W5_W4_ADC3[25:16];
	assign weights_m[279:270] =  W6_ADC3[9:0];
	assign weights_m[289:280] =  W1_W0_ADC4[9:0];
	assign weights_m[299:290] =  W1_W0_ADC4[25:16];
	assign weights_m[309:300] =  W3_W2_ADC4[9:0];
	assign weights_m[319:310] =  W3_W2_ADC4[25:16];
	assign weights_m[329:320] =  W5_W4_ADC4[9:0];
	assign weights_m[339:330] =  W5_W4_ADC4[25:16];
	assign weights_m[349:340] =  W6_ADC4[9:0];
	assign weights_m[359:350] =  W1_W0_ADC5[9:0];
	assign weights_m[369:360] =  W1_W0_ADC5[25:16];
	assign weights_m[379:370] =  W3_W2_ADC5[9:0];
	assign weights_m[389:380] =  W3_W2_ADC5[25:16];
	assign weights_m[399:390] =  W5_W4_ADC5[9:0];
	assign weights_m[409:400] =  W5_W4_ADC5[25:16];
	assign weights_m[419:410] =  W6_ADC5[9:0];
	assign weights_m[429:420] =  W1_W0_ADC6[9:0];
	assign weights_m[439:430] =  W1_W0_ADC6[25:16];
	assign weights_m[449:440] =  W3_W2_ADC6[9:0];
	assign weights_m[459:450] =  W3_W2_ADC6[25:16];
	assign weights_m[469:460] =  W5_W4_ADC6[9:0];
	assign weights_m[479:470] =  W5_W4_ADC6[25:16];
	assign weights_m[489:480] =  W6_ADC6[9:0];
	assign weights_m[499:490] =  W1_W0_ADC7[9:0];
	assign weights_m[509:500] =  W1_W0_ADC7[25:16];
	assign weights_m[519:510] =  W3_W2_ADC7[9:0];
	assign weights_m[529:520] =  W3_W2_ADC7[25:16];
	assign weights_m[539:530] =  W5_W4_ADC7[9:0];
	assign weights_m[549:540] =  W5_W4_ADC7[25:16];
	assign weights_m[559:550] =  W6_ADC7[9:0];
	assign weights_m[569:560] =  W1_W0_ADC8[9:0];
	assign weights_m[579:570] =  W1_W0_ADC8[25:16];
	assign weights_m[589:580] =  W3_W2_ADC8[9:0];
	assign weights_m[599:590] =  W3_W2_ADC8[25:16];
	assign weights_m[609:600] =  W5_W4_ADC8[9:0];
	assign weights_m[619:610] =  W5_W4_ADC8[25:16];
	assign weights_m[629:620] =  W6_ADC8[9:0];
	assign weights_m[639:630] =  W1_W0_ADC9[9:0];
	assign weights_m[649:640] =  W1_W0_ADC9[25:16];
	assign weights_m[659:650] =  W3_W2_ADC9[9:0];
	assign weights_m[669:660] =  W3_W2_ADC9[25:16];
	assign weights_m[679:670] =  W5_W4_ADC9[9:0];
	assign weights_m[689:680] =  W5_W4_ADC9[25:16];
	assign weights_m[699:690] =  W6_ADC9[9:0];
	assign weights_m[709:700] =  W1_W0_ADC10[9:0];
	assign weights_m[719:710] =  W1_W0_ADC10[25:16];
	assign weights_m[729:720] =  W3_W2_ADC10[9:0];
	assign weights_m[739:730] =  W3_W2_ADC10[25:16];
	assign weights_m[749:740] =  W5_W4_ADC10[9:0];
	assign weights_m[759:750] =  W5_W4_ADC10[25:16];
	assign weights_m[769:760] =  W6_ADC10[9:0];
	assign weights_m[779:770] =  W1_W0_ADC11[9:0];
	assign weights_m[789:780] =  W1_W0_ADC11[25:16];
	assign weights_m[799:790] =  W3_W2_ADC11[9:0];
	assign weights_m[809:800] =  W3_W2_ADC11[25:16];
	assign weights_m[819:810] =  W5_W4_ADC11[9:0];
	assign weights_m[829:820] =  W5_W4_ADC11[25:16];
	assign weights_m[839:830] =  W6_ADC11[9:0];
	assign weights_m[849:840] =  W1_W0_ADC12[9:0];
	assign weights_m[859:850] =  W1_W0_ADC12[25:16];
	assign weights_m[869:860] =  W3_W2_ADC12[9:0];
	assign weights_m[879:870] =  W3_W2_ADC12[25:16];
	assign weights_m[889:880] =  W5_W4_ADC12[9:0];
	assign weights_m[899:890] =  W5_W4_ADC12[25:16];
	assign weights_m[909:900] =  W6_ADC12[9:0];
	assign weights_m[919:910] =  W1_W0_ADC13[9:0];
	assign weights_m[929:920] =  W1_W0_ADC13[25:16];
	assign weights_m[939:930] =  W3_W2_ADC13[9:0];
	assign weights_m[949:940] =  W3_W2_ADC13[25:16];
	assign weights_m[959:950] =  W5_W4_ADC13[9:0];
	assign weights_m[969:960] =  W5_W4_ADC13[25:16];
	assign weights_m[979:970] =  W6_ADC13[9:0];
	assign weights_m[989:980] =  W1_W0_ADC14[9:0];
	assign weights_m[999:990] =  W1_W0_ADC14[25:16];
	assign weights_m[1009:1000] =  W3_W2_ADC14[9:0];
	assign weights_m[1019:1010] =  W3_W2_ADC14[25:16];
	assign weights_m[1029:1020] =  W5_W4_ADC14[9:0];
	assign weights_m[1039:1030] =  W5_W4_ADC14[25:16];
	assign weights_m[1049:1040] =  W6_ADC14[9:0];

	// From Page 2
	
	assign weights_m[1059:1050] =  W1_W0_ADC15[9:0];
	assign weights_m[1069:1060] =  W1_W0_ADC15[25:16];
	assign weights_m[1079:1070] =  W3_W2_ADC15[9:0];
	assign weights_m[1089:1080] =  W3_W2_ADC15[25:16];
	assign weights_m[1099:1090] =  W5_W4_ADC15[9:0];
	assign weights_m[1109:1100] =  W5_W4_ADC15[25:16];
	assign weights_m[1119:1110] =  W6_ADC15[9:0];
	assign weights_m[1129:1120] =  W1_W0_ADC16[9:0];
	assign weights_m[1139:1130] =  W1_W0_ADC16[25:16];
	assign weights_m[1149:1140] =  W3_W2_ADC16[9:0];
	assign weights_m[1159:1150] =  W3_W2_ADC16[25:16];
	assign weights_m[1169:1160] =  W5_W4_ADC16[9:0];
	assign weights_m[1179:1170] =  W5_W4_ADC16[25:16];
	assign weights_m[1189:1180] =  W6_ADC16[9:0];
	assign weights_m[1199:1190] =  W1_W0_ADC17[9:0];
	assign weights_m[1209:1200] =  W1_W0_ADC17[25:16];
	assign weights_m[1219:1210] =  W3_W2_ADC17[9:0];
	assign weights_m[1229:1220] =  W3_W2_ADC17[25:16];
	assign weights_m[1239:1230] =  W5_W4_ADC17[9:0];
	assign weights_m[1249:1240] =  W5_W4_ADC17[25:16];
	assign weights_m[1259:1250] =  W6_ADC17[9:0];
	assign weights_m[1269:1260] =  W1_W0_ADC18[9:0];
	assign weights_m[1279:1270] =  W1_W0_ADC18[25:16];
	assign weights_m[1289:1280] =  W3_W2_ADC18[9:0];
	assign weights_m[1299:1290] =  W3_W2_ADC18[25:16];
	assign weights_m[1309:1300] =  W5_W4_ADC18[9:0];
	assign weights_m[1319:1310] =  W5_W4_ADC18[25:16];
	assign weights_m[1329:1320] =  W6_ADC18[9:0];
	assign weights_m[1339:1330] =  W1_W0_ADC19[9:0];
	assign weights_m[1349:1340] =  W1_W0_ADC19[25:16];
	assign weights_m[1359:1350] =  W3_W2_ADC19[9:0];
	assign weights_m[1369:1360] =  W3_W2_ADC19[25:16];
	assign weights_m[1379:1370] =  W5_W4_ADC19[9:0];
	assign weights_m[1389:1380] =  W5_W4_ADC19[25:16];
	assign weights_m[1399:1390] =  W6_ADC19[9:0];
	assign weights_m[1409:1400] =  W1_W0_ADC20[9:0];
	assign weights_m[1419:1410] =  W1_W0_ADC20[25:16];
	assign weights_m[1429:1420] =  W3_W2_ADC20[9:0];
	assign weights_m[1439:1430] =  W3_W2_ADC20[25:16];
	assign weights_m[1449:1440] =  W5_W4_ADC20[9:0];
	assign weights_m[1459:1450] =  W5_W4_ADC20[25:16];
	assign weights_m[1469:1460] =  W6_ADC20[9:0];
	assign weights_m[1479:1470] =  W1_W0_ADC21[9:0];
	assign weights_m[1489:1480] =  W1_W0_ADC21[25:16];
	assign weights_m[1499:1490] =  W3_W2_ADC21[9:0];
	assign weights_m[1509:1500] =  W3_W2_ADC21[25:16];
	assign weights_m[1519:1510] =  W5_W4_ADC21[9:0];
	assign weights_m[1529:1520] =  W5_W4_ADC21[25:16];
	assign weights_m[1539:1530] =  W6_ADC21[9:0];
	assign weights_m[1549:1540] =  W1_W0_ADC22[9:0];
	assign weights_m[1559:1550] =  W1_W0_ADC22[25:16];
	assign weights_m[1569:1560] =  W3_W2_ADC22[9:0];
	assign weights_m[1579:1570] =  W3_W2_ADC22[25:16];
	assign weights_m[1589:1580] =  W5_W4_ADC22[9:0];
	assign weights_m[1599:1590] =  W5_W4_ADC22[25:16];
	assign weights_m[1609:1600] =  W6_ADC22[9:0];
	assign weights_m[1619:1610] =  W1_W0_ADC23[9:0];
	assign weights_m[1629:1620] =  W1_W0_ADC23[25:16];
	assign weights_m[1639:1630] =  W3_W2_ADC23[9:0];
	assign weights_m[1649:1640] =  W3_W2_ADC23[25:16];
	assign weights_m[1659:1650] =  W5_W4_ADC23[9:0];
	assign weights_m[1669:1660] =  W5_W4_ADC23[25:16];
	assign weights_m[1679:1670] =  W6_ADC23[9:0];
	assign weights_m[1689:1680] =  W1_W0_ADC24[9:0];
	assign weights_m[1699:1690] =  W1_W0_ADC24[25:16];
	assign weights_m[1709:1700] =  W3_W2_ADC24[9:0];
	assign weights_m[1719:1710] =  W3_W2_ADC24[25:16];
	assign weights_m[1729:1720] =  W5_W4_ADC24[9:0];
	assign weights_m[1739:1730] =  W5_W4_ADC24[25:16];
	assign weights_m[1749:1740] =  W6_ADC24[9:0];
	assign weights_m[1759:1750] =  W1_W0_ADC25[9:0];
	assign weights_m[1769:1760] =  W1_W0_ADC25[25:16];
	assign weights_m[1779:1770] =  W3_W2_ADC25[9:0];
	assign weights_m[1789:1780] =  W3_W2_ADC25[25:16];
	assign weights_m[1799:1790] =  W5_W4_ADC25[9:0];
	assign weights_m[1809:1800] =  W5_W4_ADC25[25:16];
	assign weights_m[1819:1810] =  W6_ADC25[9:0];
	assign weights_m[1829:1820] =  W1_W0_ADC26[9:0];
	assign weights_m[1839:1830] =  W1_W0_ADC26[25:16];
	assign weights_m[1849:1840] =  W3_W2_ADC26[9:0];
	assign weights_m[1859:1850] =  W3_W2_ADC26[25:16];
	assign weights_m[1869:1860] =  W5_W4_ADC26[9:0];
	assign weights_m[1879:1870] =  W5_W4_ADC26[25:16];
	assign weights_m[1889:1880] =  W6_ADC26[9:0];
	assign weights_m[1899:1890] =  W1_W0_ADC27[9:0];
	assign weights_m[1909:1900] =  W1_W0_ADC27[25:16];
	assign weights_m[1919:1910] =  W3_W2_ADC27[9:0];
	assign weights_m[1929:1920] =  W3_W2_ADC27[25:16];
	assign weights_m[1939:1930] =  W5_W4_ADC27[9:0];
	assign weights_m[1949:1940] =  W5_W4_ADC27[25:16];
	assign weights_m[1959:1950] =  W6_ADC27[9:0];
	assign weights_m[1969:1960] =  W1_W0_ADC28[9:0];
	assign weights_m[1979:1970] =  W1_W0_ADC28[25:16];
	assign weights_m[1989:1980] =  W3_W2_ADC28[9:0];
	assign weights_m[1999:1990] =  W3_W2_ADC28[25:16];
	assign weights_m[2009:2000] =  W5_W4_ADC28[9:0];
	assign weights_m[2019:2010] =  W5_W4_ADC28[25:16];
	assign weights_m[2029:2020] =  W6_ADC28[9:0];
	assign weights_m[2039:2030] =  W1_W0_ADC29[9:0];
	assign weights_m[2049:2040] =  W1_W0_ADC29[25:16];
	assign weights_m[2059:2050] =  W3_W2_ADC29[9:0];
	assign weights_m[2069:2060] =  W3_W2_ADC29[25:16];
	assign weights_m[2079:2070] =  W5_W4_ADC29[9:0];
	assign weights_m[2089:2080] =  W5_W4_ADC29[25:16];
	assign weights_m[2099:2090] =  W6_ADC29[9:0];
	
	// From Page 3
	
	assign weights_m[2109:2100] =  W1_W0_ADC30[9:0];
	assign weights_m[2119:2110] =  W1_W0_ADC30[25:16];
	assign weights_m[2129:2120] =  W3_W2_ADC30[9:0];
	assign weights_m[2139:2130] =  W3_W2_ADC30[25:16];
	assign weights_m[2149:2140] =  W5_W4_ADC30[9:0];
	assign weights_m[2159:2150] =  W5_W4_ADC30[25:16];
	assign weights_m[2169:2160] =  W6_ADC30[9:0];
	assign weights_m[2179:2170] =  W1_W0_ADC31[9:0];
	assign weights_m[2189:2180] =  W1_W0_ADC31[25:16];
	assign weights_m[2199:2190] =  W3_W2_ADC31[9:0];
	assign weights_m[2209:2200] =  W3_W2_ADC31[25:16];
	assign weights_m[2219:2210] =  W5_W4_ADC31[9:0];
	assign weights_m[2229:2220] =  W5_W4_ADC31[25:16];
	assign weights_m[2239:2230] =  W6_ADC31[9:0];

    // Thresholds -------------------------------------------------------------
    for (i=0; i<18; i=i+1) begin : thresholds
        assign lt6[i]  = 1'b1;
        assign ht6[i]  = 1'b1;
        assign lt56[i] = 1'b1;
        assign ht56[i] = 1'b1;            
    end
    
    // ------------------------------------------------------------------------
    
	assign  lane1                        =  glink_sel1 ? (glink_pattern1 ? data_counter : vmePatternLane1) : sl1; 
	assign  lane2                        =  glink_sel2 ? (glink_pattern2 ? data_counter : vmePatternLane2) : sl2; 
	assign  lane3                        =  glink_sel3 ? (glink_pattern3 ? data_counter : vmePatternLane3) : sl3; 
	assign  lane1_cntl                   =  vmeCtrWordLane1; 
	assign  lane1_data                   =  vmeDataWordLane1;
	assign  lane2_cntl                   =  vmeCtrWordLane2;
	assign  lane2_data                   =  vmeDataWordLane2;
	assign  lane3_cntl                   =  vmeCtrWordLane3;
	assign  lane3_data                   =  vmeDataWordLane3;
   assign  fragmentGenEn                =  vmeFragmentGenEn;
   assign  UTEST_N                      =  vmeUTEST_N;
   assign  URESET_N                     =  vmeURESET_N;
   assign  glink_sel1			 	       =  vmeGlinkSel1;
	assign  glink_sel2				       =  vmeGlinkSel2;
	assign  glink_sel3				       =  vmeGlinkSel3;
	assign  glink_pattern1               =  vmeGlinkPattern1;
	assign  glink_pattern2               =  vmeGlinkPattern2;
	assign  glink_pattern3               =  vmeGlinkPattern3;
   assign  reset_counter				    =  vmeGlinkCounterRst;
   assign  enable_counter				    =  vmeGlinkCounterEn;
   assign  trg_sel                      =  4'b1111;
end
endgenerate 

endmodule 
