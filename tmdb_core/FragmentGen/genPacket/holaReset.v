module holaReset #
(
    parameter      LUP_WAIT = 4
)
(
    input          rst,
    input          clk,
    input          enable,
    
    input          holaReset,  //HOLA Reset Request from VME
    output         normalOper, //Normal Operation Signal
    
	input          LDOWN_N,     
	output         URESET_N
);

/******************************************************************************/
// HOLA Reset Request treatment
/******************************************************************************/

reg holaResetR = 0, locked = 0;

always @(posedge clk) begin
    if (holaReset && ~locked) begin
        holaResetR <= 1;
        locked     <= 1;
    end
    else  
        holaResetR <= 0;
    
    if (~holaReset && locked) locked <= 0;
end
    
/******************************************************************************/
// HOLA Reset FSM
/******************************************************************************/
    
// Number of FSM Flip-Flops
localparam FSM_FF = 6;

// States
localparam [FSM_FF-1:0] idle  = 6'h1,
                        reset = 6'h2,
                        ldown = 6'h4,
                        lup   = 6'h8,
                        oper  = 6'h10,
                        recov = 6'h20;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)
   
reg [FSM_FF-1:0] state, next;
initial state = idle;

// FSM Flip-Flops 
always @(posedge clk or posedge rst)
    if (rst) state <= idle;
    else     state <= next;

// 4 UCLKs Counter
reg [2:0] upCntr = 0;

always @(posedge clk or posedge rst)
    if      (rst)           upCntr <= 0;
    else if (next == reset) upCntr <= 0;
    else if (next == lup)   upCntr <= upCntr + 1;

// Link up Wait State Enable
wire lupEn = (upCntr < LUP_WAIT);

    
// Next State Logic
always @(*) begin
    next = {FSM_FF{1'bx}};
    case (state)
        idle   : if (enable)                 next = reset;
                 else                        next = idle;
                 
                 // if link down
        reset  : if (~LDOWN_N)               next = ldown;
                 else                        next = reset;
        
                 //if link up
        ldown  : if ( LDOWN_N)               next = lup;
                 else                        next = ldown;
        
                 //lupEn is asserted during 4 UCLKS
        lup    : if (lupEn)                  next = lup;
                 else                        next = oper;
                 
                 //if reset request or link down                       
        oper   : if (holaResetR || ~LDOWN_N) next = reset;
                 else                        next = oper;
                         
        recov  :                             next = idle;
    endcase
end

// FSM Outputs Logic
wire stReset = (next == reset);
wire stLdown = (next == ldown);
assign normalOper = (next == oper);

// URESET_N
reg ureset = 0;

always @(posedge clk or posedge rst)
    if (rst) ureset <= 0;
    else     ureset <= (stReset || stLdown);
    
assign URESET_N = ~ureset;
    
endmodule