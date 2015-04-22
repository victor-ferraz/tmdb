////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: FragmentGen.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FragmentGen #
(
    // BUSY signal is asserted if the free processing space is
    // less than BUSY_MARGIN L1Accepts.
    parameter BUSY_MARGIN      = 4,
    // Full Flag is asserted if the free space in the VME readout FIFO is
    // less than VME_FULL_MARGIN.
    parameter VME_FULL_MARGIN  = 4,
    // 
	parameter USE_CHIPSCOPE    = 0
)
(
	 input          rst, 
    input          clk,
    input          enable,
    
    // Data Fragment Registers ------------------------------------------------
    
    input  [31:0]  sourceIdentifier,
    input  [31:0]  runNumber,
    
	// Testing ----------------------------------------------------------------

    input          testEn,         //1 -> TEST ENABLED ; 0 -> TEST DISABLED
    input          testSel,        //1 -> TEST MODE    ; 0 -> NORMAL MODE
    input          adcConstantSel, //1 -> ADC CONSTANT ; 0 -> TEST DATA
    
	// Sync Selector  ---------------------------------------------------------
    
    input          syncSel,        //1 -> VME          ; 0 -> HOLA

    // HOLA Reset Request -----------------------------------------------------
    
    input          holaReset,      
    
    // BUSY -------------------------------------------------------------------
    
    output         busyOut,
    
	// L1a stuff --------------------------------------------------------------
	
    input  [7:0]   l1aLatency,     // L1A Latency
    input          l1a,            // L1Accept
    input  [11:0]  bCnt,           // BCID / Event Counter Bus
    input          bCntRes,        // BCID Reset
    input          bCntStr,        // BCID Strobe
    input          evCntRes,       // Event Counter Reset
    input          evCntLStr,      // Event Counter Low Strobe
    input          evCntHStr,      // Event Counter High Strobe
    input          vmeEcr,			  // VME ECRID reset
	 
	// ADC interface ----------------------------------------------------------

	input  [255:0] adcIn,          // ADCs Input

    // HOLA interface ---------------------------------------------------------

	output [31:0]  UD,
	output         URESET_N,
	output         UCTRL_N, 
	output         UWEN_N, 
	input          LFF_N,        
	input          LDOWN_N, 
    
	// Register interface (VME) -----------------------------------------------
    
    output         vmeEmptyFlag,
    input          vmeReadEnable,
    output [31:0]  vmeData,
    
	// ILA Control ------------------------------------------------------------
	
	 input  [3:0]   trg_sel,
	 inout  [35:0]  ila_control
);    

/******************************************************************************/
/*
`include "../../common/array_conversion.v"
`include "FragmentConf.v"
*/

`include "../common/array_conversion.v"
`include "../tmdb_core/FragmentGen/FragmentConf.v"

/******************************************************************************/
// Global Signals
/******************************************************************************/

wire busy, holaNormalOper;
wire [OBJECT_QTY-1:0] readEnable;

/******************************************************************************/
// ADC Test Data Generator
/******************************************************************************/

wire test_l1a, test_bCntStr, test_evCntLStr, test_evCntHStr;
wire [11:0]  test_bCnt;
wire [255:0] test_dataOut;

testData testData_i
(
    .rst       (rst),
    .clk       (clk),
    .enable    (testEn),
    .l1a       (test_l1a),
    .bCnt      (test_bCnt),
    .bCntStr   (test_bCntStr),
    .evCntLStr (test_evCntLStr),
    .evCntHStr (test_evCntHStr),
    .dataOut   (test_dataOut)
);

/******************************************************************************/
// TTC Data Buffering (ADC Data is (MUST BE) buffered outside this module)
/******************************************************************************/

reg l1aR = 0, bCntResR = 0, bCntStrR = 0, evCntResR = 0, evCntLStrR = 0, 
    evCntHStrR = 0;
reg [11:0] bCntR = 0;

always @(posedge clk) begin
    l1aR           <= l1a;
    bCntR          <= bCnt;
    bCntResR       <= bCntRes;
    bCntStrR       <= bCntStr;
    evCntResR      <= evCntRes;
    evCntLStrR     <= evCntLStr;
    evCntHStrR     <= evCntHStr;
end
    
/******************************************************************************/
// Test Data / Real Data MUX: 1 -> TEST; 0 -> REAL
/******************************************************************************/

// ADC Constant Data
wire [255:0] adcConstant;
genvar i;
generate
    for (i=0; i<32; i=i+1) assign adcConstant[i*8+8-1:i*8] = i;
endgenerate     

wire         l1aM       = testSel ? test_l1a       : l1aR;
wire [11:0]  bCntM      = testSel ? test_bCnt      : bCntR;
wire         bCntStrM   = testSel ? test_bCntStr   : bCntStrR;
wire         evCntLStrM = testSel ? test_evCntLStr : evCntLStrR;
wire         evCntHStrM = testSel ? test_evCntHStr : evCntHStrR;
wire [255:0] adcDataM   = testSel ? 
                        (adcConstantSel ? adcConstant : test_dataOut) : adcIn;

/******************************************************************************/
// Sync Selector: 1 -> VME; 0 -> HOLA
/******************************************************************************/

wire vmeFullFlag, holaFullFlag;

// Full Flag Selector
wire fullFlagM = syncSel ? vmeFullFlag : (holaFullFlag || ~LDOWN_N);

// Enable Logic
wire intEnable = syncSel ? enable : (enable && holaNormalOper);

/******************************************************************************/
// L1A Processor 
/******************************************************************************/

wire l1aEmpty, l1aBusyOut;
wire [43:0] l1aOut;
wire [43:0] fifoIn;

L1aProc #
(
    .L1A_FULL_MARGIN(BUSY_MARGIN)
)
L1aProc_i
(
    .rst       (rst),
    .clk       (clk),
    .enable    (intEnable),
    .l1a       (l1aM),
    .bCnt      (bCntM),
    .bCntRes   (bCntResR),
    .bCntStr   (bCntStrM),
    .evCntRes  (evCntResR),
    .evCntLStr (evCntLStrM),
    .evCntHStr (evCntHStrM),
    .busyIn    (busy),
    .busyOut   (l1aBusyOut),
	 .vmeEcr	   (vmeEcr),
    .rdStb     (readEnable[1]), //OBJECT index 1
    .empty     (l1aEmpty),
	 .fifoIn		(fifoIn),	 
    .dataOut   (l1aOut)
);

/******************************************************************************/
// ADC Ring Buffer 
/******************************************************************************/

wire [255:0] adcOut;

ADCbuff #
(
    .RB_BUSY_MARGIN(BUSY_MARGIN),
    .WFIFO_FULL_MARGIN(BUSY_MARGIN)
)
ADCbuff_i
(
    .rst     (rst),
    .clk     (clk),
    .enable  (intEnable),
    .l1a     (l1aM),
    .l1aLat  (l1aLatency),
    .adcIn   (adcDataM),
    .busyOut (busy),
    .rdStb   (readEnable[3]), //OBJECT index 3
    .dataOut (adcOut)
);

/******************************************************************************/
// Data Fragment Builder 
/******************************************************************************/

wire [SLOT_WIDTH-1:0] SLOT [SLOT_QTY-1:0];

// Before Header ---------------------------------------------------------------
assign SLOT[0]  = 33'h1B0F00000;                         // Beginning of fragment - Constant
// Header ----------------------------------------------------------------------
assign SLOT[1]  = 33'hEE1234EE;                          // Start of header marker - Constant
assign SLOT[2]  = 33'd9;                  				   // Header size - Constant
assign SLOT[3]  = 33'h03010000;            					// Format version - Constant
assign SLOT[4]  = sourceIdentifier;        					// Source identifier - Register
assign SLOT[5]  = runNumber;               					// Run number - Register
assign SLOT[6]  = {1'b0, l1aOut [43:36],l1aOut[23:0]};   // Lvl1 ID Extended
assign SLOT[7]  = {21'b0, l1aOut[35:24]};  					// BCID
assign SLOT[8]  = 33'd0;                   					// Lvl1 trigger type
assign SLOT[9]  = 33'd0;                   					// Detector event type - Constant
// ADC Sub-fragment ------------------------------------------------------------
assign SLOT[10] = 33'hFF1234FF;            					// Start of Tilecal sub-fragment marker
assign SLOT[11] = 33'd59;                  					// ADC sub-fragment size: 3+8*N_SAMPLES (3+8*7)
assign SLOT[12] = 33'h00400000;                   			// ADC sub-fragment type and version
assign SLOT[13] = {1'b0, adcOut[31:0]};    					// ADC OBJECT - [ADC04 ; ADC03 ; ADC02 ; ADC01]
assign SLOT[14] = {1'b0, adcOut[63:32]};  					// ADC OBJECT - [ADC08 ; ADC07 ; ADC06 ; ADC05]
assign SLOT[15] = {1'b0, adcOut[95:64]};  					// ADC OBJECT - [ADC12 ; ADC11 ; ADC10 ; ADC09]
assign SLOT[16] = {1'b0, adcOut[127:96]}; 					// ADC OBJECT - [ADC16 ; ADC15 ; ADC14 ; ADC13]
assign SLOT[17] = {1'b0, adcOut[159:128]}; 					// ADC OBJECT - [ADC20 ; ADC19 ; ADC18 ; ADC17]
assign SLOT[18] = {1'b0, adcOut[191:160]};					// ADC OBJECT - [ADC24 ; ADC23 ; ADC22 ; ADC21]
assign SLOT[19] = {1'b0, adcOut[223:192]}; 					// ADC OBJECT - [ADC28 ; ADC27 ; ADC26 ; ADC25]
assign SLOT[20] = {1'b0, adcOut[255:224]};					// ADC OBJECT - [ADC32 ; ADC31 ; ADC30 ; ADC29]
// Trailer ---------------------------------------------------------------------
assign SLOT[21] = 33'd0;                   					// Number of status elements - Constant
assign SLOT[22] = 33'd59;                  					// Number of data elements - Constant: Sum of sub-fragments sizes.
assign SLOT[23] = 33'd0;                   					// Status block position - Constant
// After Trailer ---------------------------------------------------------------
assign SLOT[24] = 33'h1E0F00000;          					// Slot 25 - End of fragment - Constant
//------------------------------------------------------------------------------

// Source SLOT Input Wires
wire [SLOT_WIDTH*SLOT_QTY-1:0] slotInput;
`PACK_ARRAY(SLOT_WIDTH, SLOT_QTY, SLOT, slotInput, pak0)

// Source Empty
wire [OBJECT_QTY-1:0] objectEnable;

assign objectEnable[0]              = ~l1aEmpty;
assign objectEnable[OBJECT_QTY-1:1] = ~0;

// Destination FIFO Wires
wire [SLOT_WIDTH-1:0] fragDataOut;
wire                  fragWriteEnable;

FragmentBuilder FragmentBuilder_i
(
    .rst          (rst),
    .clk          (clk),
    .enable       (intEnable),
  
    .slotInput    (slotInput), 
    .objectEnable (objectEnable),
    .readEnable   (readEnable),
  
    .fullFlag     (fullFlagM),
    .dataOut      (fragDataOut),
    .writeEnable  (fragWriteEnable)
);

/******************************************************************************/
// HOLA Interace
/******************************************************************************/

assign holaFullFlag = ~LFF_N;
assign UD           = fragDataOut[31:0];
assign UCTRL_N      = ~fragDataOut[32];
assign UWEN_N       = ~fragWriteEnable;

/******************************************************************************/
// HOLA Reset
/******************************************************************************/

holaReset holaReset_i
(
    .rst        (rst),
    .clk        (clk),
    .enable     (enable),
    
    .holaReset  (holaReset),
    .normalOper (holaNormalOper),
    
    .LDOWN_N    (LDOWN_N),
    .URESET_N   (URESET_N)
);

/******************************************************************************/
// VME FIFO
/******************************************************************************/

localparam VME_FIFO_DEPTH = 64;

wire empty, full, prog_empty, prog_full;
wire [5:0] dataCount;

vfifo vfifo_i 
(
  .clk               (clk),
  .rst               (rst),
  .din               (fragDataOut[31:0]),
  .wr_en             (fragWriteEnable && ~fragDataOut[32]),
  .rd_en             (vmeReadEnable),
  .prog_empty_thresh (6'd32),
  .prog_full_thresh  (VME_FIFO_DEPTH-VME_FULL_MARGIN),
  .dout              (vmeData),
  .full              (),
  .empty             (vmeEmptyFlag),
  .data_count        (dataCount),
  .prog_full         (vmeFullFlag),
  .prog_empty        ()
);

/******************************************************************************/
// BUSY Out Register (get rid of glitches from comb logic)
/******************************************************************************/

reg busyOutR = 0;

always @(posedge clk) busyOutR = l1aBusyOut;

assign busyOut = busyOutR;

/******************************************************************************/
// ChipScope 
/******************************************************************************/

generate
if (USE_CHIPSCOPE==1) 
begin : chipscope
	// ChipScope signals ------------------------------------------------------

	wire    [273:0] tied_to_ground_vec;		
	wire    [7:0]   ila_trig;
	wire    [317:0] ila_data;
  
  //MUX for triggering channels with thrshold 
  
  reg     [7:0]   trig_chipscope;
  
  	always @(posedge clk)
      case (trg_sel)
         4'b0000: trig_chipscope = adcIn[7:0];             // ADC 01       
         4'b0001: trig_chipscope = adcIn[39:32];           // ADC 05
         4'b0010: trig_chipscope = adcIn[71:64];           // ADC 09
         4'b0011: trig_chipscope = adcIn[103:96];          // ADC 13
         4'b0100: trig_chipscope = adcIn[135:128];         // ADC 17
         4'b0101: trig_chipscope = adcIn[167:160];         // ADC 21
         4'b0110: trig_chipscope = adcIn[199:192];         // ADC 25
         4'b0111: trig_chipscope = adcIn[231:224];		     // ADC 29
			4'b1000: trig_chipscope = adcIn[31:24];           // ADC 04
		   4'b1001: trig_chipscope = adcIn[63:56];           // ADC 08
         4'b1010: trig_chipscope = adcIn[95:88];           // ADC 12
         4'b1011: trig_chipscope = adcIn[127:120];         // ADC 16
         4'b1100: trig_chipscope = adcIn[159:152];         // ADC 20
         4'b1101: trig_chipscope = adcIn[191:184];         // ADC 24
         4'b1110: trig_chipscope = adcIn[223:216];         // ADC 28
			4'b1111: trig_chipscope = {4'd0,evCntResR,bCntResR,bCntStrM,l1aM};   //L1A, BCntStr and resets
      endcase
  
    // ILA 
    chipscope_ila chipscope_ila_1
    (
     .CLK                               (clk),
	  .CONTROL                           (ila_control),
     .TRIG0                             (ila_trig),
	  .DATA                              (ila_data)
    );
   
    // ILA Trigger Inputs
	 assign  ila_trig                      = trig_chipscope;
/*  assign  ila_trig[0]                   = l1aR;
    assign  ila_trig[1]                   = bCntStrR;
    assign  ila_trig[7:2]                 = tied_to_ground_vec[7:2];*/
	
	// ILA Data Inputs
    assign  ila_data[0]                   =  l1aM;
    assign  ila_data[12:1]                =  bCntM;
    assign  ila_data[13]                  =  bCntResR;
    assign  ila_data[14]                  =  bCntStrM;
    assign  ila_data[15]                  =  evCntResR;
    assign  ila_data[16]                  =  evCntLStrM;
    assign  ila_data[17]                  =  evCntHStrM;	 
	 assign  ila_data[273:18]              =  adcIn[255:0];
	 assign  ila_data[317:274]             =  fifoIn;
   
end //end USE_CHIPSCOPE=1 generate section
// else
// begin: no_chipscope
// end
endgenerate

/******************************************************************************/

endmodule
