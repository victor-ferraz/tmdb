////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: MPU.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module MPU #
(
	parameter USE_CHIPSCOPE = 1
)
(
	input rst, clk,

	// ADC converters ----------------------------------------------------------

	input [255:0] adc_in,
	
	// Weights Matrix ---------------------------------------------------------
	input [2239:0] weights_m,

	// Threshold --------------------------------------------------------------

	input [151:0] LT6p,
	input [151:0] HT6p,
	input [151:0] LT56p,
	input [151:0] HT56p,
		
	// Trigger from/to neighbored TMDB -----------------------------------------

	input  [3:0] ext_mod0,
	input  [3:0] ext_mod9,
	output [3:0] ext_mod1,
	output [3:0] ext_mod8,

	// Sector Logic outputs ----------------------------------------------------

	output [15:0] sl1, sl2, sl3,
	
	// ILA Control ------------------------------------------------------------
	
	inout [35:0] ila_control
);

//`include "../../common/array_conversion.v"
`include "../common/array_conversion.v"

// Cell energy ----------------------------------------------------------------

//ADC Data
wire [7:0] adc_unp [31:0];
`UNPACK_ARRAY(8, 32, adc_in, adc_unp, unp0)

wire [7:0] mod_d5_0 [7:0];
wire [7:0] mod_d5_1 [7:0];
wire [7:0] mod_d6_0 [7:0];
wire [7:0] mod_d6_1 [7:0];

genvar i;
generate
	for(i=0; i<8; i=i+1) begin : adc_unpacking
		assign mod_d5_0[i] = adc_unp[i*4];
		assign mod_d5_1[i] = adc_unp[i*4+1];
		assign mod_d6_0[i] = adc_unp[i*4+2];
		assign mod_d6_1[i] = adc_unp[i*4+3];		
	end
endgenerate

// Each 'weights' array holds seven weight values (10-bit weights).
wire [69:0] weights [31:0];
`UNPACK_ARRAY(70, 32, weights_m, weights, unp1)

wire signed [18:0] mod_d5_out [7:0];
wire signed [18:0] mod_d6_out [7:0];

wire signed [17:0] fir_d5_0 [7:0];
wire signed [17:0] fir_d5_1 [7:0];
wire signed [17:0] fir_d6_0 [7:0];
wire signed [17:0] fir_d6_1 [7:0];

generate
	for (i=0; i<8; i=i+1) begin : cell_energy
		cell_ene mod1_d5(rst, clk, mod_d5_0[i], mod_d5_1[i], weights[i*4], 
			weights[i*4+1], mod_d5_out[i], fir_d5_0[i], fir_d5_1[i]);
		cell_ene mod1_d6(rst, clk, mod_d6_0[i], mod_d6_1[i], weights[i*4+2], 
			weights[i*4+3], mod_d6_out[i], fir_d6_0[i], fir_d6_1[i]);
	end
endgenerate
	
// Signal detectors -----------------------------------------------------------

wire [3:0] mod_result [7:0];

wire signed [18:0] LT6  [7:0];
wire signed [18:0] HT6  [7:0];
wire signed [18:0] LT56 [7:0];
wire signed [18:0] HT56 [7:0];

`UNPACK_ARRAY(19, 8, LT6p,  LT6,  unp2)
`UNPACK_ARRAY(19, 8, HT6p,  HT6,  unp3)
`UNPACK_ARRAY(19, 8, LT56p, LT56, unp4)
`UNPACK_ARRAY(19, 8, HT56p, HT56, unp5)

wire [7:0]  pd6;
wire [7:0]  pd56;

wire signed [18:0] mask6  [7:0];
wire signed [18:0] mask56 [7:0];

generate
	for (i=0; i<8; i=i+1) begin : mod_detect
		detect mod1_det(rst, clk, mod_d5_out[i], mod_d6_out[i], 
			mod_result[i], LT6[i], HT6[i], LT56[i], HT56[i], 
			pd6[i], pd56[i], mask6[i], mask56[i]);
	end
endgenerate

// Event Builder --------------------------------------------------------------

assign sl1 = {mod_result[2], mod_result[1], mod_result[0], ext_mod0};
assign sl2 = {mod_result[5], mod_result[4], mod_result[3], mod_result[2]};
assign sl3 = {ext_mod9, mod_result[7], mod_result[6], mod_result[5]};

assign ext_mod1 = mod_result[0];
assign ext_mod8 = mod_result[7];

// ChipScope ------------------------------------------------------------------

generate
if (USE_CHIPSCOPE==1) 
begin : chipscope
	// ChipScope signals ------------------------------------------------------

	wire    [511:0] tied_to_ground_vec;		
	wire    [7:0]   ila_trig;
	wire    [511:0] ila_data;

    // ILA 
    chipscope_ila_512 chipscope_ila_0
    (
      .CLK                               (clk),
	  .CONTROL                           (ila_control),
      .TRIG0                             (ila_trig),
	  .DATA                              (ila_data)
    );

    // ILA Trigger Inputs
	assign  ila_trig[3:0]                =  mod_result[0]; //mod1 result as trigger
    assign  ila_trig[7:4]                =  tied_to_ground_vec[7:4];
	
	// ILA Data Inputs
	assign  ila_data[15:0]               =  sl1;           //Detection results to SL1
	assign  ila_data[31:16]              =  sl2;           //Detection results to SL2
	assign  ila_data[47:32]              =  sl3;           //Detection results do SL3
	assign	ila_data[55:48]              =  mod_d5_0[0];   //mod1 d5 left
	assign  ila_data[63:56]              =  mod_d5_1[0];   //mod1 d5 right
	assign	ila_data[71:64]              =  mod_d6_0[0];   //mod1 d6 left
	assign  ila_data[79:72]              =  mod_d6_1[0];   //mod 1d6 right
	assign  ila_data[97:80]              =  fir_d5_0[0];   //mod1 d5 left fir result
	assign  ila_data[115:98]             =  fir_d5_1[0];   //mod1 d5 right fir result
	assign  ila_data[133:116]            =  fir_d6_0[0];   //mod1 d6 left fir result
	assign  ila_data[151:134]            =  fir_d6_1[0];   //mod1 d6 right fir result
	assign  ila_data[170:152]            =  mod_d5_out[0]; //mod1 d5 sum result
	assign  ila_data[189:171]            =  mod_d6_out[0]; //mod1 d6 sum result
	assign  ila_data[208:190]            =  mask6[0];      //mod1 d6 mask
	assign  ila_data[227:209]            =  mask56[0];	   //mod1 d5+d6 mask
	assign  ila_data[235:228]            =  pd6;           //all d6 peak detectors
	assign  ila_data[243:236]            =  pd56;          //all d5+d6 peak detector
	assign  ila_data[262:244]            =  LT6[0];        //d6 low level trigger setting
	assign  ila_data[281:263]            =  HT6[0];        //d6 high level trigger setting
	assign  ila_data[300:282]            =  LT56[0];       //d5+d6 low level trigger setting
	assign  ila_data[319:301]            =  HT56[0];       //d5+d6 high level trigger setting
	assign	ila_data[511:320]			 =  tied_to_ground_vec[511:320];

end //end USE_CHIPSCOPE=1 generate section
// else
// begin: no_chipscope
// end
endgenerate
	
  
endmodule 