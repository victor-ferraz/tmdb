////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: cell_ene.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cell_ene
(
	input                rst, clk,
	input         [ 7:0] ch1, ch2,
	input			  [69:0] weights1,
	input 		  [69:0] weights2,
	output signed [18:0] out,
	output signed [17:0] fir1_out,
	output signed [17:0] fir2_out
);

/*
wire signed [17:0] fir1_out;
wire signed [17:0] fir2_out;
*/

fir fir1(rst, clk, ch1, weights1, fir1_out);
fir fir2(rst, clk, ch2, weights2, fir2_out);

assign out = fir1_out+fir2_out;

endmodule 