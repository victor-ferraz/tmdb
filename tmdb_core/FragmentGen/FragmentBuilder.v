////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: FragmentBuilder.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FragmentBuilder #
(
    parameter REGISTERED_OUTPUTS = 0
)
(
    clk,
    rst,
    enable,
  
    // OBJECTs Interface (Source)
    slotInput,
    objectEnable,
    readEnable,
  
    // Destination FIFO interface
    fullFlag,
    dataOut,
    writeEnable
);

/*
`include "../../common/array_conversion.v"
`include "FragmentConf.v"
*/

`include "../common/array_conversion.v"
`include "../tmdb_core/FragmentGen/FragmentConf.v"

/******************************************************************************/

input                            clk;
input                            rst;
input                            enable;

input  [SLOT_WIDTH*SLOT_QTY-1:0] slotInput;
input  [OBJECT_QTY-1:0]          objectEnable;
output [OBJECT_QTY-1:0]          readEnable;

input                            fullFlag;
output [SLOT_WIDTH-1:0]          dataOut;
output                           writeEnable;

/******************************************************************************/

function integer logb2(input integer depth);
begin 
    logb2 = 0;
    while (depth) begin
        logb2 = logb2 + 1;
        depth = depth >> 1;
    end
end
endfunction

/******************************************************************************/
// Global Sigbals
/******************************************************************************/

// FSM Outputs
wire stIdle, stObjRead, stSlotWrite, stObjRepeat, stObjInc;

// Registered FSM Outputs
reg stSlotWriteR = 0, stObjRepeatR = 0;

// SLOT Counter state at the beginning of an OBJECT transfer
reg [logb2(SLOT_QTY)-1:0] slotCntrStart = 0;

/******************************************************************************/
// Object Counter
/******************************************************************************/

reg [logb2(OBJECT_QTY)-1:0] objCntr = 0;

always @(posedge clk or posedge rst)
    if      (rst)                   objCntr <= 0;
    else if (stObjInc)              
        if (objCntr < OBJECT_QTY-1) objCntr <= objCntr + 1;
        else                        objCntr <= 0;
                        
/******************************************************************************/
// Object Transfer Repetition Counter
/******************************************************************************/

reg [logb2(SLOT_QTY)-1:0] repeatCntr = 0; 

always @(posedge clk or posedge rst)
    if      (rst)          repeatCntr <= 0;
    else if (stObjInc)     repeatCntr <= 0;
    else if (stObjRepeatR) repeatCntr <= repeatCntr + 1;

/******************************************************************************/
// Slot Counter
/******************************************************************************/

reg [logb2(SLOT_QTY)-1:0] slotCntr   = 0;

always @(posedge clk or posedge rst)
    if      (rst)                  slotCntr <= 0;
    else if (stObjRepeat)          slotCntr <= slotCntrStart;
    else if (stSlotWriteR)         
        if (slotCntr < SLOT_QTY-1) slotCntr <= slotCntr + 1;
        else                       slotCntr <= 0;

/******************************************************************************/
// Slot Data Multiplexer
/******************************************************************************/

// Slot Data Array to be MUX'ed    
wire [SLOT_WIDTH-1:0] SLOT [SLOT_QTY-1:0];

`UNPACK_ARRAY(SLOT_WIDTH, SLOT_QTY, slotInput, SLOT, unp0)

// Slot Data MUX output
wire [SLOT_WIDTH-1:0] slotData;

assign slotData = SLOT[slotCntr];

/******************************************************************************/
// Transfer FSM
/******************************************************************************/

// Number of FSM Flip-Flops
localparam FSM_FF = 7;

// States
localparam [FSM_FF-1:0] idle      = 7'h1,
                        objRead   = 7'h2,
                        slotWrite = 7'h4,
                        objRepeat = 7'h8,
                        objInc    = 7'h10,
                        waitFull  = 7'h20,
                        recov     = 7'h30;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)
   
reg [FSM_FF-1:0] state, next;
initial state = idle;

// FSM Flip-Flops 
always @(posedge clk or posedge rst)
    if (rst) state <= idle;
    else     state <= next;

// Transfer Enable
wire transferEn = (enable && ~fullFlag && objectEnable[objCntr]);

// Current Object Width
wire [OBJ_WIDTH_BW-1:0] objWidth = OBJECT_WIDTH[objCntr];
            
// Current Object Transfer Repetition Qty
wire [OBJ_REPEAT_BW-1:0] objRepeatQty = OBJECT_REPEAT_QTY[objCntr];

// Slot Counter state at the beginning of an OBJECT transfer
always @(posedge clk)
    if (stObjRead) slotCntrStart <= slotCntr;
        
// Object Width Transfer Enable
wire objWidthEn = (slotCntr < slotCntrStart + objWidth);

// Object Transfer Repetition Enable
wire objRepeatEn = (repeatCntr < objRepeatQty);
            
// Next State Logic
always @(*) begin
    next = {FSM_FF{1'bx}};
    case (state)
        idle      : if      (transferEn)  next = objRead;
                    else                  next = idle;
                    
        objRead   :                       next = slotWrite;

        slotWrite : if      (objWidthEn && fullFlag)    next = waitFull;
                    else if (objWidthEn)  next = slotWrite;
                    else if (objRepeatEn) next = objRepeat;
                    else                  next = objInc;

        objRepeat : if      (objRepeatEn) next = objRead;
                    else                  next = objInc;
                    
        objInc    : if      (transferEn)  next = objRead;
                    else                  next = idle;
                    
        waitFull  : if      (fullFlag)    next = waitFull;
                    else                  next = slotWrite;
        
        recov     :                       next = idle;
    endcase
end

// FSM Outputs Logic
assign stObjRead   = (next == objRead);
assign stSlotWrite = (next == slotWrite);
assign stObjRepeat = (next == objRepeat);
assign stObjInc    = (next == objInc);

// Registerd FSM Outputs
always @(posedge clk or posedge rst)
    if (rst) begin
        stSlotWriteR <= 0;
        stObjRepeatR <= 0;
    end else begin
        stSlotWriteR <= stSlotWrite;
        stObjRepeatR <= stObjRepeat;
    end

/******************************************************************************/
// Read Enable Demux
/******************************************************************************/

reg [OBJECT_QTY-1:0] rdenDemux;

always @(*) begin
    rdenDemux          = 0;
    rdenDemux[objCntr] = stObjRead;
end

/******************************************************************************/
// Outputs
/******************************************************************************/
    
// Registered or Direct Outputs
generate
if (REGISTERED_OUTPUTS == 1) begin : registeredOutputs
    reg                  writeEnableR = 0; 
    reg [OBJECT_QTY-1:0] readEnableR  = 0;
    reg [SLOT_WIDTH-1:0] slotDataR    = 0; 

    //
    always @(posedge clk or posedge rst)
        if (rst) begin
            writeEnableR <= 0;
            readEnableR  <= 0; 
            slotDataR    <= 0;
        end else begin
            writeEnableR <= stSlotWriteR;
            readEnableR  <= rdenDemux;
            slotDataR    <= slotData;

        end

    // Interface    
    assign readEnable  = readEnableR;
    assign writeEnable = writeEnableR;
    assign dataOut     = slotDataR; 
end        
else begin : directOutputs
    // Interface    
    assign readEnable  = rdenDemux;
    assign writeEnable = stSlotWriteR;
    assign dataOut     = slotData;
end
endgenerate

/******************************************************************************/
    
endmodule
