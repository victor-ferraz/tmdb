////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: count_ROM.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module count_ROM
(
    input	[7:0]	 addr, //Read address
    output	[3:0]	 data  //Output data
);

(* ram_style = "distributed" *)
reg [3:0] ROM [255:0];

//Initializing the ROM contents
initial $readmemh("count_ROM.txt", ROM, 0, 255);
//Read port (asynchronous)
assign data = ROM[addr];

endmodule