////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: fir.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

//`include "../array_conversion.v"

module fir 
/*#(
	parameter signed [9:0] w0 =  10'd234,
	parameter signed [9:0] w1 =  10'd465,
	parameter signed [9:0] w2 =  10'd298,
	parameter signed [9:0] w3 = -10'd345,
	parameter signed [9:0] w4 =  10'd463,
	parameter signed [9:0] w5 = -10'd345,
	parameter signed [9:0] w6 =  10'd321
)*/
(
	input                rst, clk,
	input         [ 7:0] adc,
	input			  [69:0] weights,
	output signed [17:0] out
);

//`include "../../common/array_conversion.v"
`include "../common/array_conversion.v"

// Weight Unpacking -----------------------------------------------------------

wire signed [9:0] w [6:0];
`UNPACK_ARRAY(10, 7, weights, w, unp0)
	
// ----------------------------------------------------------------------------
/*
reg [7:0] sr [5:0];

always @ (posedge clk or posedge rst) begin
	if (rst) begin
		sr[0] <= 0;
		sr[1] <= 0;
		sr[2] <= 0;
		sr[3] <= 0;
		sr[4] <= 0;
		sr[5] <= 0;
	end else begin
		sr[0] <= adc;
		sr[1] <= sr[0];
		sr[2] <= sr[1];
		sr[3] <= sr[2];
		sr[4] <= sr[3];
		sr[5] <= sr[4];
	end
end

assign out = adc*w[0] + sr[0]*w[1] + sr[1]*w[2] + sr[2]*w[3] + sr[3]*w[4] + 
				sr[4]*w[5] + sr[5]*w[6];
*/

reg signed [7:0] sr [5:0];

integer i;
initial for (i=0; i<6; i=i+1) sr[i] = 0;
                
always @(posedge clk) begin
    sr[0] <= adc*w[6];
    sr[1] <= adc*w[5]+sr[0];
    sr[2] <= adc*w[4]+sr[1];
    sr[3] <= adc*w[3]+sr[2];
    sr[4] <= adc*w[2]+sr[3];
    sr[5] <= adc*w[1]+sr[4];
end

assign out = adc*w[0]+sr[5];

endmodule
