////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: count_ones_rom.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module count_ones_rom
(
    input	[15:0] in,
    output	[4:0]  out
);

wire [7:0] aux;

// Component to count ones on LSBs Input 
count_ROM counterLSB(
	.addr(in[7:0]),
	.data(aux[3:0])
);
// Component to count ones on MSBs Input
count_ROM counterMSB(
	.addr(in[15:8]),
	.data(aux[7:4])
);
// Component to adder ones's quantity on MSB and LSB Input
adder_ROM adder(
	.addr(aux),
	.data(out)
);

endmodule