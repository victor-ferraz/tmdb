////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: detect.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module detect
/*#(
	parameter signed LT = 100,
	parameter signed HT = 120
)*/
(
	input                rst, clk,
	input  signed [18:0] cell5, cell6,
/*	output               llt, hlt,
	output               sllt, shlt,*/
	output        [3:0]  out,
	input  signed [18:0] LT6, HT6,
	input  signed [18:0] LT56, HT56,
	output               pd6, pd56,
	output signed [18:0] mask6o, mask56o
);

reg signed [18:0] mask6  [2:0];
reg signed [18:0] mask56 [2:0];

integer i;
initial for (i=0; i<3; i=i+1) mask6[i]  = 0;
initial for (i=0; i<3; i=i+1) mask56[i] = 0;

// PD1
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		mask6[0] <= 0;
		mask6[1] <= 0;
		mask6[2] <= 0;
	end else begin
		mask6[0] <= cell6;
		mask6[1] <= mask6[0];
		mask6[2] <= mask6[1];
	end
end

// PD2
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		mask56[0] <= 0;
		mask56[1] <= 0;
		mask56[2] <= 0;
	end else begin
		mask56[0] <= cell5+cell6;
		mask56[1] <= mask56[0];
		mask56[2] <= mask56[1];
	end
end

assign pd6 = ((mask6[0] < mask6[1]) & (mask6[1] > mask6[2]));
assign pd56 = ((mask56[0] < mask56[1]) & (mask56[1] > mask56[2]));

assign  llt = (pd6 & (mask6[1] > LT6));
assign  hlt = (pd6 & (mask6[1] > HT6));
assign sllt = (pd56 & (mask56[1] > LT56));
assign shlt = (pd56 & (mask56[1] > HT56));

assign out[0] = llt;
assign out[1] = hlt;
assign out[2] = sllt;
assign out[3] = shlt;

assign mask6o  = mask6[1];
assign mask56o = mask56[1];

endmodule 