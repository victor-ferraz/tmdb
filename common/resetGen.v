module resetGen #
(
    parameter RESET_PERIOD = 7,
    parameter POWER_ON_RESET = 1
)
( 
    input        clk,
    input [31:0] resetRequestWord,
    
    output       resetOut    
);

localparam RESET_WORD = 32'h55555555;

/******************************************************************************/
// Global Signals
/******************************************************************************/

wire stReset;

/******************************************************************************/
// Reset Request treatment
/******************************************************************************/

reg userResetRequest = 0, locked = 0;

always @(posedge clk) begin
    if ((resetRequestWord == RESET_WORD) && ~locked) begin
        userResetRequest <= 1;
        locked           <= 1;
    end
    else  
        userResetRequest <= 0;
    
    if ((resetRequestWord == 0) && locked) locked <= 0;
end

/******************************************************************************/
// Power-on Reset 
/******************************************************************************/

reg powerOnResetDone = 0;

always @(posedge clk) 
    if (POWER_ON_RESET && stReset) powerOnResetDone <= 1;
    
wire powerOnReset = POWER_ON_RESET && ~powerOnResetDone;

/******************************************************************************/
// Reset FSM
/******************************************************************************/
    
// Number of FSM Flip-Flops
localparam FSM_FF = 3;

// States
localparam [FSM_FF-1:0] idle  = 3'h1,
                        reset = 3'h2,
                        recov = 3'h4;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)
   
reg [FSM_FF-1:0] state, next;
initial state = idle;

// FSM Flip-Flops 
always @(posedge clk) state <= next;

// Reset Request
wire resetRequest = userResetRequest || powerOnReset;

// Reset Period Counter
reg [3:0] resetPeriodCntr = 0;

always @(posedge clk)
    if      (userResetRequest)  resetPeriodCntr <= 0;
    else if (next == reset) resetPeriodCntr <= resetPeriodCntr + 1;

// Reset Period Enable
wire resetPeriodEn = (resetPeriodCntr < RESET_PERIOD - 1);

// Next State Logic
always @(*) begin
    next = {FSM_FF{1'bx}};
    case (state)
        idle  : if (resetRequest)  next = reset;
                else               next = idle;
                 
        reset : if (resetPeriodEn) next = reset;
                else               next = idle;
        
        recov :                    next = idle;
    endcase
end

// FSM Outputs Logic
assign stReset = (next == reset);

// Reset Output
assign resetOut = stReset;
    
endmodule
