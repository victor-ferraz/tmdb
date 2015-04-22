////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: clock.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module clock #
(
    parameter SIMULATION = 0
)
(
	// Clock Inputs
	input clk_in,
	
	// Clock Outputs
	output [15:0] clk_out
);

//assign clk_out[0] = clk_in[0];
//assign clk_out[1] = clk_in[0];
//assign clk_out[2] = clk_in[0];
//assign clk_out[3] = clk_in[0];
//assign clk_out[4] = clk_in[0];
//assign clk_out[5] = clk_in[0];
//assign clk_out[6] = clk_in[0];
//assign clk_out[7] = clk_in[0];
//assign clk_out[8] = clk_in[0];
//assign clk_out[9] = clk_in[0];
//assign clk_out[10] = clk_in[0];
//assign clk_out[11] = clk_in[0];
//assign clk_out[12] = clk_in[0];
//assign clk_out[13] = clk_in[0];
//assign clk_out[14] = clk_in[0];
//assign clk_out[15] = clk_in[0];

//wire [5:0] clk_buf;

wire clk_in_n;
assign clk_in_n = ~clk_in;

// Instantiation of the pll clocking
//--------------------------------------
genvar i;
/*
generate 
	for (i=0; i<1; i=i+1) begin : pll_i
//        IBUFG #(.IBUF_LOW_PWR("FALSE")) ibufg_clk ( .I(clk_in[i]), .O(clk_buf[i])); 
		  clk_pll pll_inst(			
			 .CLK_IN            (clk_in[i]),
 			 // Clock out ports
			 .CLK_OUT1           (clk_pll[i*4]),
			 .CLK_OUT2           (clk_pll[i*4+1]),
			 .CLK_OUT3           (clk_pll[i*4+2]),
			 .CLK_OUT4           (clk_pll[i*4+3]),
			 // Status and control signals
			 .RESET              (1'b0),
			 .LOCKED             ());
   end
endgenerate
*/

// Instantiation of the ODDR2 for outputs
//--------------------------------------
generate
if (SIMULATION==0) 
    for (i=0; i<16; i=i+1) begin : gen_outclk_oddr
      ODDR2 clkout_oddr
        (.Q  (clk_out[i]),
         .C0 (clk_in),
         .C1 (clk_in_n),
         .CE (1'b1),
         .D0 (1'b1),
         .D1 (1'b0),
         .R  (1'b0),
         .S  (1'b0));
    end
else
    for (i=0; i<16; i=i+1) begin : gen_outclk
      assign clk_out[i] = clk_in;
    end
endgenerate

endmodule
