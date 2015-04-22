module ADCemu #
(
    parameter EVENT_SIZE = 7,
    parameter LFILL_SIZE = 10,
    parameter TFILL_SIZE = 10
)
(
    input            clk, 
    output reg [7:0] data
);

parameter TOTAL = EVENT_SIZE+LFILL_SIZE+TFILL_SIZE;

// Data
reg [7:0] rom [TOTAL-1:0];

integer i;
initial begin
    //Leading fill
    for (i=0; i<LFILL_SIZE; i=i+1) rom[i] = 8'd0;
    //Event
    rom[i+0] = 8'd1;
    rom[i+1] = 8'd2;
    rom[i+2] = 8'd3;
    rom[i+3] = 8'd4;
    rom[i+4] = 8'd5;
    rom[i+5] = 8'd6;
    rom[i+6] = 8'd7;
    //Trailing fill
    for (i=LFILL_SIZE+EVENT_SIZE; i<TOTAL; i=i+1) rom[i] = 8'd0;
end

// Data Addressing
reg [9:0] counter = 10'd0;

always @(posedge clk)
    if (counter == TOTAL-1)
        counter <= 10'd0;
    else
        counter <= counter + 10'd1;
    
// Data Driving
always @(posedge clk) data <= rom[counter];

endmodule