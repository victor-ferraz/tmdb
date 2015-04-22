////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: testData.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testData #
(
    // Must be bigger than SAMPLES_PER_TRIG (in BCs)
    parameter L1A_LATENCY = 100,
    // Must be bigger than L1A_LATENCY (in BCs)
    parameter L1A_PERIOD = 400
) 
(
    input          rst,
    input          clk,
    input          enable,
    
    output         l1a,
    output [11:0]  bCnt,
    output         bCntStr,
    output         evCntLStr,
    output         evCntHStr,    
    output [255:0] dataOut
);

/******************************************************************************/
// Local Parameters
/******************************************************************************/

localparam SAMPLES_PER_TRIG = 7;
localparam CORRECTED_PERIOD = L1A_PERIOD - 4; 

/******************************************************************************/
// Global Signals
/******************************************************************************/

//FSM Outputs
wire stDataGen, stL1aWaitA, stDataClr, stL1aHit, stL1aWaitB, stL1aClr;

/******************************************************************************/
// Latency Counter
/******************************************************************************/

localparam LATENCY_COUNTER_WIDTH = 10;

reg [LATENCY_COUNTER_WIDTH-1:0] l1aCntr = 0;
wire l1aCntrEn = (stDataGen || stL1aWaitA || stL1aWaitB);

always @(posedge clk or posedge rst)
    if (rst)            l1aCntr <= 0;
    else if (stL1aClr)  l1aCntr <= 0;
    else if (l1aCntrEn) l1aCntr <= l1aCntr + 1;
    
/******************************************************************************/
// Load Strobe FSM
/******************************************************************************/
    
// Number of FSM Flip-Flops
localparam FSM_FF = 8;

// States
localparam [FSM_FF-1:0] idle     = 8'h1,
                        dataGen  = 8'h2,
                        dataClr  = 8'h4,
                        l1aWaitA = 8'h8,
                        l1aHit   = 8'h10,
                        l1aWaitB = 8'h20,
                        l1aClr   = 8'h30,
                        recov    = 8'h40;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)
   
reg [FSM_FF-1:0] state, next;
initial state = idle;

// FSM Flip-Flops 
always @(posedge clk or posedge rst)
    if (rst) state <= idle;
    else     state <= next;

// ADC Data Generator Enable
wire dataGenEn = (l1aCntr < SAMPLES_PER_TRIG);

// L1A Wait Enable (Latency Residue)
wire l1aWaitAEn = (l1aCntr < L1A_LATENCY);

// L1A Wait B Enable (Period Residue
wire l1aWaitBEn = (l1aCntr < CORRECTED_PERIOD);

// Next State Logic
always @(*) begin
    next = {FSM_FF{1'bx}};
    case (state)
        idle     : if (enable)     next = dataGen;
                   else            next = idle;
                    
        dataGen  : if (dataGenEn)  next = dataGen;
                   else            next = dataClr;
        
        dataClr  :                 next = l1aWaitA;
        
        l1aWaitA : if (l1aWaitAEn) next = l1aWaitA;
                   else            next = l1aHit;
                  
        l1aHit   :                 next = l1aWaitB;   
        
        l1aWaitB : if (l1aWaitBEn) next = l1aWaitB;
                   else            next = l1aClr;
         
        l1aClr   :                 next = idle;
                   
        recov    :                 next = idle;
    endcase
end

// FSM Outputs Logic
assign stDataGen  = (next == dataGen);
assign stL1aWaitA = (next == l1aWaitA);
assign stDataClr  = (next == dataClr);
assign stL1aHit   = (next == l1aHit);
assign stL1aWaitB = (next == l1aWaitB);
assign stL1aClr   = (next == l1aClr);

//L1a Output
assign l1a = stL1aHit;

/******************************************************************************/
// ADC Data Generator
/******************************************************************************/

localparam DATA_CNTR_WIDTH = 4;
localparam ADC_CHANNELS    = 32;
localparam ADC_WIDTH       = 8;

// Data Counter
reg [DATA_CNTR_WIDTH-1:0] dataCntr = 0;

always @(posedge clk or posedge rst) 
    if      (rst)       dataCntr <= 0;
    else if (stDataClr) dataCntr <= 0;
    else if (stDataGen) dataCntr <= dataCntr + 1;

// Data Output Assignments        
wire [255:0] out;
        
genvar i;    
generate
    for (i=0; i<ADC_CHANNELS/2; i=i+1) 
        assign out[i*ADC_WIDTH+ADC_WIDTH-1:i*ADC_WIDTH] = {i[3:0], dataCntr};
    for (i=ADC_CHANNELS/2; i<ADC_CHANNELS; i=i+1) 
        assign out[i*ADC_WIDTH+ADC_WIDTH-1:i*ADC_WIDTH] = {dataCntr, i[3:0]};
endgenerate

assign dataOut = out;

/******************************************************************************/
// BCID Generator 
/******************************************************************************/

reg [11:0] bcid = 0; //12'h5FD;

always @(posedge clk or posedge rst) 
    if      (rst) bcid <= 0;
    else if (l1a) bcid <= bcid + 12'd1;

assign bCntStr = l1a;

/******************************************************************************/
// Delayed L1A 
/******************************************************************************/

reg [1:0] delayedL1a = 2'd0;

always @(posedge clk) delayedL1a <= {delayedL1a[0], l1a};

/******************************************************************************/
// Event Counter Generator 
/******************************************************************************/

reg [23:0] evCnt = 0; //24'h4C6;

always @(posedge clk or posedge rst)
    if      (rst)           evCnt <= 0;
    else if (delayedL1a[0]) evCnt <= evCnt + 24'd1;

assign evCntLStr = delayedL1a[0];
assign evCntHStr = delayedL1a[1];

/******************************************************************************/
// bCnt mux 
/******************************************************************************/

reg [11:0] bCntMux;

always @(*) begin
    bCntMux = evCnt[11:0];
    case ({delayedL1a, l1a})
        3'b000: bCntMux = evCnt[11:0];
        3'b001: bCntMux = bcid;
        3'b010: bCntMux = evCnt[11:0];
        3'b100: bCntMux = evCnt[23:12];
    endcase
end 

assign bCnt = bCntMux;

/******************************************************************************/
// Simulation Stuff
/******************************************************************************/

//`include "../../common/array_conversion.v"

`include "../common/array_conversion.v"

wire [7:0] dataOutU [31:0];
`UNPACK_ARRAY(8, 32, out, dataOutU, unp0)

/******************************************************************************/

endmodule
