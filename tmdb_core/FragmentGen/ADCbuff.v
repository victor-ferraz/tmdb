////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: ADCbuff.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ADCbuff #
(
	//Ring Buffer Address Width
    parameter MAX_LATENCY       = 128,
    parameter RB_ADDRESS_WIDTH  = 10, //10 
    parameter RB_SIZE           = 2**RB_ADDRESS_WIDTH,
    parameter SAMPLES_PER_TRIG  = 7,
    parameter WRITE_END         = RB_SIZE-1,
    //RB_BUSY_MARGIN MUST NOT BE ZERO
    parameter RB_BUSY_MARGIN    = 4,
    parameter WFIFO_FULL_MARGIN = 4

)
(
	input          rst, 
    input          clk,
    input          enable,
    
    // L1A stuff --------------------------------------------------------------
    
    input          l1a,     // L1Accept
    input  [7:0]   l1aLat,  // L1A Latency

	// ADC interface -----------------------------------------------------------

	input [255:0]  adcIn,   // ADCs Input

    // L1A Processor interface -------------------------------------------------
    
	output         busyOut, // Load Strobe

	// Builder Interface -------------------------------------------------------
    
    input          rdStb,   // Read Strobe    
	output [255:0] dataOut  // ADC FIFO Data Output	
);

/******************************************************************************/
// Global Signals
/******************************************************************************/

wire ldStb, busy;
reg  rbBusy = 0;

/******************************************************************************/
// Write Address Counter (up to 1024 samples)
/******************************************************************************/

reg [RB_ADDRESS_WIDTH-1:0] wrAddr = 10'd0;
 
always @(posedge clk or posedge rst)
    if      (rst)                 wrAddr <= 10'd0;
    //else if (wrAddr == WRITE_END) wrAddr <= 10'd0;
    else if (enable && ~rbBusy)   wrAddr <= wrAddr + 10'd1;
        
/******************************************************************************/        
// Read Start Address Logic
/******************************************************************************/

wire        [RB_ADDRESS_WIDTH-1:0] qWrAddr;
wire        [RB_ADDRESS_WIDTH-1:0] rdStartAddr;
wire signed [RB_ADDRESS_WIDTH:0]   addrTemp;

assign addrTemp = qWrAddr - l1aLat;
//assign rdStartAddr = addrTemp[RB_ADDRESS_WIDTH] ? (addrTemp + 1) : addrTemp;
assign rdStartAddr = addrTemp;

/******************************************************************************/
// Delayed Load Strobe
/******************************************************************************/

reg ldStbR = 0;

always @(posedge clk) ldStbR <= ldStb;
    
/******************************************************************************/    
// Read Address Counter (up to 1024 samples)
/******************************************************************************/

reg [RB_ADDRESS_WIDTH-1:0] rdAddr = 10'd0;

always @(posedge clk or posedge rst)
    if      (rst)    rdAddr <= 10'd0;
    else if (ldStbR) rdAddr <= rdStartAddr;
    else if (rdStb)  rdAddr <= rdAddr + 10'd1;
    
/******************************************************************************/    
// Write Address FIFO 
/******************************************************************************/

localparam WFIFO_DEPTH = 64;

wire empty, full, prog_empty, prog_full;
wire [5:0] dataCount;

wfifo wfifo_i 
(
  .clk               (clk),
  .rst               (rst),
  .din               (wrAddr),
  .wr_en             (l1a && enable && ~busy),
  .rd_en             (ldStb),
  .prog_empty_thresh (6'd32),
  .prog_full_thresh  (WFIFO_DEPTH-WFIFO_FULL_MARGIN),
  .dout              (qWrAddr),
  .full              (full),
  .empty             (empty),
  .data_count        (dataCount),
  .prog_full         (prog_full),
  .prog_empty        (prog_empty)
);

/******************************************************************************/
// Load Strobe FSM
/******************************************************************************/
    
// Number of FSM Flip-Flops
localparam FSM_FF = 4;

// States
localparam [FSM_FF-1:0] idle      = 5'h1,
                        load      = 5'h2,
                        rdWait    = 5'h4,
                        recov     = 5'h8;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)
   
reg [FSM_FF-1:0] state, next;
initial state = idle;

// FSM Flip-Flops 
always @(posedge clk or posedge rst)
    if (rst) state <= idle;
    else     state <= next;

// Read Strobe Counter
reg [7:0] rdCntr = 0;

always @(posedge clk or posedge rst)
    if      (rst)          rdCntr <= 0;
    else if (next == load) rdCntr <= 0;
    else if (rdStb)        rdCntr <= rdCntr + 1;

// Read Wait State Enable
wire rdWaitEn = (rdCntr < SAMPLES_PER_TRIG);

    
// Next State Logic
always @(*) begin
    next = {FSM_FF{1'bx}};
    case (state)
        idle   : if (~empty)   next = load;
                 else          next = idle;
                    
        load   :               next = rdWait;

        rdWait : if (rdWaitEn) next = rdWait;
                 else          next = idle;
        
        recov :                next = idle;
    endcase
end

// FSM Outputs Logic
assign ldStb = (next == load);

/******************************************************************************/
// BUSY(FULL) Logic
/******************************************************************************/

reg wrLap = 0;

// wrAddr made at least 1 lap
always @(posedge clk or posedge rst) 
    if      (rst)                 wrLap <= 0;
    else if (wrAddr == WRITE_END) wrLap <= 1;

// 'addrDelta': difference between 'rdStartAddr' and 'wrAddr';
// 'rdStartAddr' is the first address in the queue (wfifo), waiting to be
// processed.
wire signed [RB_ADDRESS_WIDTH:0]   addrDeltaS;
wire        [RB_ADDRESS_WIDTH-1:0] addrDelta;

assign addrDeltaS = rdStartAddr - wrAddr;
assign addrDelta  = addrDeltaS;

// Ring Buffer BUSY Logic
always @(posedge clk or posedge rst)
    if      (rst)                         rbBusy <= 0;
    else if (wrLap && ~empty && 
            (addrDelta < RB_BUSY_MARGIN)) rbBusy <= 1;
    else                                  rbBusy <= 0;

// Delayed Ring Buffer Busy 
reg [MAX_LATENCY-1:0] delayedRbBusy = 0;
always @(posedge clk) 
    delayedRbBusy <= {delayedRbBusy[MAX_LATENCY-2:0], rbBusy};

// Delayer Ring Buffr Busy at Tap = 'l1aLat-1' (matching the L1A latency)   
wire delayedRbBusyTap = delayedRbBusy[l1aLat-1];

// Underflow Check
wire underflow = (~wrLap && (wrAddr < l1aLat));

// BUSY Signal
assign busy = (rbBusy || delayedRbBusyTap || prog_full || underflow);

// BUSY Signal to other modules
assign busyOut = busy;
   
/******************************************************************************/
// Memory instance (ring buffer)
/******************************************************************************/

// Read Bus
reg [255:0] buffOut;

// Memories: 256 bits * RB_SIZE Samples
(* ram_style = "block" *)
reg [255:0] buff [RB_SIZE-1:0];

// Write port
always @ (posedge clk)
    if (enable && ~rbBusy) buff[wrAddr] <= adcIn;
    
// Read port
always @ (posedge clk)
    if (rdStb) buffOut <= buff[rdAddr];

assign dataOut = buffOut;

/******************************************************************************/
// Simulation Stuff
/******************************************************************************/

//`include "../../common/array_conversion.v"

`include "../common/array_conversion.v"

wire [7:0] adcInU [31:0];
`UNPACK_ARRAY(8, 32, adcIn, adcInU, unp0)
wire [7:0] buffOutU [31:0];
`UNPACK_ARRAY(8, 32, buffOut, buffOutU, unp1)

/******************************************************************************/

endmodule 
