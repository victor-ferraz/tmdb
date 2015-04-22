////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: L1aProc.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module L1aProc #
(
    // Full Flag is asserted if the free space in the FIFO is
    // less than L1A_FULL_MARGIN.
    parameter L1A_FULL_MARGIN = 4
)
(
	 input          rst, 
    input          clk,
    input          enable,
    
    // L1A stuff --------------------------------------------------------------
    
    input         l1a,        // L1Accept
    input  [11:0] bCnt,       // BCID / Event Counter Bus
    input         bCntRes,    // BCID Reset
    input         bCntStr,    // BCID Strobe
    input         evCntRes,   // Event Counter Reset
    input         evCntLStr,  // Event Counter Low Strobe
    input         evCntHStr,  // Event Counter High Strobe
    
    // ------------------------------------------------------------------------

    input         busyIn,     // Busy Input from other modules
    output        busyOut,    // Busy Output
    
    // ------------------------------------------------------------------------
    
	 input 			vmeEcr,     // ECR vme reset
	 
	 // ------------------------------------------------------------------------

    input         rdStb,      // Read Strobe
    output        empty,      // L1A FIFO Empty Flag
	 output [43:0] fifoIn,
    output [43:0] dataOut     // L1A FIFO Data Output
);

/*****************************************************************************/
// Global Signals
/******************************************************************************/

// Programmable FIFO full flag
wire prog_full;

/******************************************************************************/
// Delayed L1A 
/******************************************************************************/

reg delayedL1a = 0;

always @(posedge clk) if (enable) delayedL1a <= l1a;

/******************************************************************************/
// BCID Register 
/******************************************************************************/

reg [11:0] bcid = 12'd0;
//reg lockedBcid = 0;

always @(posedge clk)  begin
    if      (bCntRes|rst)			bcid <= 0;
    else if (enable) 				bcid <= bcid + 1;
end

reg [11:0] delayedBcid = 12'd0;
always @(posedge clk) if (enable) delayedBcid <= bcid;

/******************************************************************************/   
// Event Counter Register 
/******************************************************************************/

reg [23:0] evCnt = 24'd0;

always @(posedge clk) begin
    if      (evCntRes|rst|vmeEcr)      evCnt <= 24'hxFFFFFF;
    else if (enable && l1a)				evCnt  <= evCnt + 1;
end
   
/*****************************************************************************/
// ECR Counter
/******************************************************************************/	

reg [7:0] ecrid = 8'b0;

always @(posedge clk) begin
	if (vmeEcr|rst)			ecrid <= 0;
   else if (evCntRes)      ecrid <= ecrid + 1;
end
/*****************************************************************************/
// Busy Handling
/******************************************************************************/

wire busy = (busyIn || prog_full);
assign busyOut = busy;

/*****************************************************************************/
// L1A FIFO 
/******************************************************************************/

localparam L1A_FIFO_DEPTH = 64;

wire full, prog_empty;
wire [5:0] dataCount;
assign fifoIn = {ecrid,delayedBcid, evCnt};

lfifo lfifo_i
(
  .clk               (clk),
  .rst               (rst),
  .din               ({ecrid, delayedBcid, evCnt}),
  .wr_en             (delayedL1a && enable && ~busy),
  .rd_en             (rdStb),
  .prog_empty_thresh (6'd32),
  .prog_full_thresh  (L1A_FIFO_DEPTH - L1A_FULL_MARGIN),
  .dout              (dataOut),
  .full              (full),
  .empty             (empty),
  .data_count        (dataCount),
  .prog_full         (prog_full),
  .prog_empty        (prog_empty) 
);

/******************************************************************************/

endmodule
