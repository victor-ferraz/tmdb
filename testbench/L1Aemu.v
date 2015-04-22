module L1Aemu #
(
    parameter RISE_TH = 0,
    parameter FALL_TH = 1,
    parameter LATENCY = 10
)
(
    input         clk, 
    input  [7:0]  data,
    output        l1a,
    output [11:0] bCnt,
    output        bCntStr,
    output        evCntLStr,
    output        evCntHStr
);


// Trigger FSM ----------------------------------------------------------------

// FSM Flip-Flops
localparam FSM_FF = 4;

// FSM to control stuff
localparam [FSM_FF-1:0] idle   = 4'h1,
                        trig   = 4'h2,
                        lock   = 4'h4,
                        recov  = 4'h8;

(* fsm_encoding = "user",
   safe_implementation = "yes",
   safe_recovery_state = recov *)   

reg [FSM_FF-1:0] state, next;
initial state = idle;

//
always @(posedge clk)
    state <= next;

//
always @(*) begin
    next = 4'bx;
    case (state)
        idle  : if (data > RISE_TH)  next = trig;
                else                 next = idle;
        trig  :                      next = lock;
        lock  : if (data < FALL_TH)  next = idle;
                else                 next = lock;
        recov :                      next = idle;
    endcase
end    

//
wire trigger = (next == trig);

 
// L1A Latency Generator ------------------------------------------------------

reg       lcountEn = 1'b0;
reg [9:0] lcounter = 10'd0;

// Latency Counter Enable End Reached Logic
wire lcntrEnd = (lcounter == LATENCY);

// Latency Counter Enable
always @(posedge clk)
    if      (trigger)  lcountEn <= 1'b1;
    else if (lcntrEnd) lcountEn <= 1'b0;

// Latency Counter
always @(posedge clk)
    if      (trigger)  lcounter <= 10'd0;
    else if (lcountEn) lcounter <= lcounter + 10'd1;

// L1A
assign l1a = lcntrEnd;

    
// BCID Generator -------------------------------------------------------------

reg [11:0] bcid = 12'h5FD;

always @(posedge clk) if (l1a) bcid <= bcid + 12'd1;

assign bCntStr = l1a;


// Delayed L1A ----------------------------------------------------------------

reg [1:0]  delayedL1a = 2'd0;

always @(posedge clk) delayedL1a <= {delayedL1a[0], l1a};


// Event Counter Generator ----------------------------------------------------

reg [23:0] evCnt = 24'h4C6;

always @(posedge clk) 
    if (delayedL1a[0]) evCnt <= evCnt + 24'd1;

assign evCntLStr = delayedL1a[0];
assign evCntHStr = delayedL1a[1];


// bCnt mux -------------------------------------------------------------------

reg [11:0] out;

always @(*) begin
    out = evCnt[11:0];
    case ({delayedL1a, l1a})
        3'b000: out = evCnt[11:0];
        3'b001: out = bcid;
        3'b010: out = evCnt[11:0];
        3'b100: out = evCnt[23:12];
    endcase
end 

assign bCnt = out;

// ---------------------------------------------------------------------------

endmodule
