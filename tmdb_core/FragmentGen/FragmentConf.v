////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: FragmentConf.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

/******************************************************************************/
/*
OBJETC:
    - An OBJECT is any kind of data entity that have to be transfered. E.g.: 
      The output bus of a FIFO, a constant data word, the output bus of another
      component or module.
    - May have any bit width but will have to be divided into 32 bits chunks in 
      order to be tranferred. In the present design, the width of an OBJECT 
      (denoted by the the parameter OBJECT_WIDTH) is an integer number that 
      represents how many 32 bits chunks will an OBJECT take to be fully 
      connected. When declaring an OBJECT_WIDTH, you will have to subtract 1
      from its real width.
    - Its transference may be repeated continously (reaching  
      OBJECT_REPEAT_QTY+1 transferences).
    - Has one (and only) read enable for each transfer repetition. In other 
      words it has OBJECT_TRANSFER_QTY+1 read enables, ocurring in the 
      beginning of each transference.
    - The OBJECT quantity will be probably limited by the fitting on a target
      device. If only simulation is considered, the limit is going to be 
      the simulation computational power. 
 
SLOT:
    - Represents a 32 bits chunk of data.
    - Has one (and only) write enable
    - The number of SLOTs is a function of the number of OBJETCs and its 
      dimensions. Examples:
        1) If we have 1 OBJECT with OBJECT_WIDTH=0 that means that we have
           1 SLOT.
        2) If we have 4 OBJETCs with the following OBJECT_WIDTHs: 0, 1, 3, 6;
        That means that we have 14 SLOTs.
      Basically, the numbers of SLOTs is the sum of all object widths.
    - The SLOT counter plays an important hole addressing the SLOTs*32 bits to
      32 bits data multiplexer.
*/
/******************************************************************************/

/******************************************************************************/
// User Configuration
/******************************************************************************/

// Number of OBJECTs
parameter OBJECT_QTY = 5;

// Number of bits required to represent the maximum width that an 
// OBJECT must have. (Object Width Bit Width)
parameter OBJ_WIDTH_BW = 3;

// List of the width minus 1 for each OBJECT
wire [OBJ_WIDTH_BW-1:0] OBJECT_WIDTH [OBJECT_QTY-1:0];

// Before Header ---------------------------------------------------------------
assign OBJECT_WIDTH[0]  = 5; // Beginning of fragment - Constant
// Header ----------------------------------------------------------------------
                             // Start of header marker - Constant
                             // Header size - Constant
                             // Format version - Constant
                             // Source identifier - Register
                             // Run number - Register
assign OBJECT_WIDTH[1]  = 2; // Lvl1 ID - from L1aProc module
                             // BCID - from L1aProc module
                             // Lvl1 trigger type - from L1aProc module
assign OBJECT_WIDTH[2]  = 3; // Detector event type - Constant
// ADC Sub-fragment ------------------------------------------------------------
                             // Start of Tilecal sub-fragment marker
                             // ADC sub-fragment size
                             // ADC sub-fragment type and version
assign OBJECT_WIDTH[3] = 7;  // ADC OBJECT - [ADC04 ; ADC03 ; ADC02 ; ADC01] - from ADCbuff module
                             // ADC OBJECT - [ADC08 ; ADC07 ; ADC06 ; ADC05]
                             // ADC OBJECT - [ADC12 ; ADC11 ; ADC10 ; ADC09]
                             // ADC OBJECT - [ADC16 ; ADC15 ; ADC14 ; ADC13]
                             // ADC OBJECT - [ADC20 ; ADC19 ; ADC18 ; ADC17]
                             // ADC OBJECT - [ADC24 ; ADC23 ; ADC22 ; ADC21]
                             // ADC OBJECT - [ADC28 ; ADC27 ; ADC26 ; ADC25]
                             // ADC OBJECT - [ADC32 ; ADC31 ; ADC30 ; ADC29]
// Trailer ---------------------------------------------------------------------
assign OBJECT_WIDTH[4] = 3;  // Number of status elements - Constant
                             // Number of data elements - Constant
                             // Status block position - Constant
// After Trailer ---------------------------------------------------------------
                             // End of fragment - Constant
//------------------------------------------------------------------------------

// Sum of the above OBJECT_WIDTHs
parameter SLOT_QTY = 25;

// Number of bits required to represent the maximum transfer repetition quantity  
// that an OBJECT must have. (Object Repetition quantity Bit Width)
parameter OBJ_REPEAT_BW = 3;

// List of the transfer repetition quantity MINUS ONE for each OBJECT
// Note: A value of 0 means 1 transference. 
wire [OBJ_REPEAT_BW-1:0] OBJECT_REPEAT_QTY [OBJECT_QTY-1:0];

// Before Header ---------------------------------------------------------------
assign OBJECT_REPEAT_QTY[0]  = 0; // Beginning of fragment - Constant
// Header ----------------------------------------------------------------------
                                  // Start of header marker - Constant
                                  // Header size - Constant
                                  // Format version - Constant
                                  // Source identifier - Register
                                  // Run number - Register
assign OBJECT_REPEAT_QTY[1]  = 0; // Lvl1 ID - from L1aProc module
                                  // BCID - from L1aProc module
                                  // Lvl1 trigger type - from L1aProc module
assign OBJECT_REPEAT_QTY[2]  = 0; // Detector event type - Constant
// ADC Sub-fragment ------------------------------------------------------------
                                  // Start of Tilecal sub-fragment marker
                                  // ADC sub-fragment size
                                  // ADC sub-fragment type and version
assign OBJECT_REPEAT_QTY[3] = 6;  // ADC OBJECT - [ADC04 ; ADC03 ; ADC02 ; ADC01] - from ADCbuff module - ADC Number of Samples per L1A
                                  // ADC OBJECT - [ADC08 ; ADC07 ; ADC06 ; ADC05]
                                  // ADC OBJECT - [ADC12 ; ADC11 ; ADC10 ; ADC09]
                                  // ADC OBJECT - [ADC16 ; ADC15 ; ADC14 ; ADC13]
                                  // ADC OBJECT - [ADC20 ; ADC19 ; ADC18 ; ADC17]
                                  // ADC OBJECT - [ADC24 ; ADC23 ; ADC22 ; ADC21]
                                  // ADC OBJECT - [ADC28 ; ADC27 ; ADC26 ; ADC25]
                                  // ADC OBJECT - [ADC32 ; ADC31 ; ADC30 ; ADC29]
// Trailer ---------------------------------------------------------------------
assign OBJECT_REPEAT_QTY[4] = 0;  // Number of status elements - Constant
                                  // Number of data elements - Constant
                                  // Status block position - Constant
// After Trailer ---------------------------------------------------------------
                                  // End of fragment - Constant
//------------------------------------------------------------------------------

/******************************************************************************/
// Internal Configuration
/******************************************************************************/

// Slot Data Width
localparam SLOT_WIDTH = 33;

/******************************************************************************/
