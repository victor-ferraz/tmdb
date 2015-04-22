////////////////////////////////////////////////////////////////////////////////
// Institutions:	UFRJ - Federal University of Rio de Janeiro
//						UFJF - Federal Univesity of Juiz de Fora
// Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
//					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
//					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
//
// Create Date: 13/03/2015
// Design Name: tmdb_core
// Module Name: gtp.v
// Target Device: Spartan-6 XC6SLX150T-FGG676
// Tool versions: Xilinx ISE Design Suite 14.7
// Description:
//    
// Dependencies:
// 
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`define DLY #1

//***********************************Entity Declaration************************

module gtp #
(
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES          =   1,   //configuration for frame gen and check
    parameter EXAMPLE_LANE_WITH_START_CHAR              =   0,   // specifies lane with unique start frame char
    parameter EXAMPLE_WORDS_IN_BRAM                     =   512, // specifies amount of data in BRAM   
    parameter EXAMPLE_SIM_GTPRESET_SPEEDUP              =   0,   // simulation setting for GTP SecureIP model
    parameter EXAMPLE_USE_CHIPSCOPE                     =   1,    // Set to 1 to use Chipscope to drive resets
    parameter EXAMPLE_SIMULATION                        =   0    // Set to 1 in testbench for simulation
)
(
	// HOLA Interface
//	input wire				SYS_RST, // RESET_LANE [0]
	 output wire				 PLL_INPUT_LOCKED,
    output wire             LANES123_FBDCM_LOCKED,
    output wire             LANE0_FBPLL_LOCKED,
    output wire             INT_RESETDONE,
	 output wire				 LANES123_SYNC_DONE,
	 output wire [19:0]		 TX_DATA_ENCODED_LANE2,
	 output wire [19:0]		 TX_DATA_ENCODED_LANE3,
	// S-LINK interface
	input wire 	[31:0] 	    UD,
	input wire 				URESET_N,
	input wire 				UTEST_N, 
	input wire 				UCTRL_N, 
	input wire 				UWEN_N, 
	input wire 				UCLK,    
	output wire 			LFF_N,   
	output wire	[3:0]		LRL,     
	output wire 			LDOWN_N, 
	// LEDs
	output wire 			TESTLED_N,
	output wire 			LDERRLED_N,
	output wire 			LUPLED_N,  
	output wire 			FLOWCTLLED_N, 
	output wire 			ACTIVITYLED_N,
	// input and output clocks
	 input  wire			 CLK_IN_40,					// External pin oscilator clock (40 MHz)
	 input  wire			 LANE0_REFCLK,				// External oscillator clock (100 MHz)
//	 input  wire          TILE0_GTP1_REFCLK_PAD_N_IN,	// External pin oscillator clock (100 MHz)
//	 input  wire          TILE0_GTP1_REFCLK_PAD_P_IN,	// External pin oscillator clock (100 MHz)
	 output wire	[3:0]	 USR_CLK2_LANE, 			// User clock 2 - Lanes 0, 1, 2 and 3
	 // pll lock detected
	 output wire	[3:0]	 PLL_LOCK_DET,			// Pll lock detected - Lanes 0, 1, 2 and 3
	 // rx data port
//	 output wire	[15:0] RX_DATA_LANE0,		// Rx data path - Lane 0
	 // tx data port
//	 input wire		[15:0] TX_DATA_LANE0,		// Tx data path - Lane 0
	 input wire		[15:0] TX_DATA_LANE1,		// Tx data path - Lane 1
	 input wire		[15:0] TX_DATA_LANE2,		// Tx data path - Lane 2
	 input wire		[15:0] TX_DATA_LANE3,		// Tx data path - Lane 3
	 // Power Down
	 input wire		[1:0]	 RX_POWER_DOWN_LANE0,	// Rx Power Down (Lane 0)
	 input wire		[1:0]	 TX_POWER_DOWN_LANE0,	// Tx Power Down (Lane 0)
	 input wire		[1:0]	 TX_POWER_DOWN_LANE1,	// Tx Power Down (Lane 1)
	 input wire		[1:0]	 TX_POWER_DOWN_LANE2,	// Tx Power Down (Lane 2)
	 input wire		[1:0]	 TX_POWER_DOWN_LANE3,	// Tx Power Down (Lane 3)
	 // reset GTPs
    input  wire   [3:0]  RESET_LANE,			// Global GTP reset - Lanes 0, 1, 2 and 3
	 output wire	[3:0]	 RESET_DONE,			// GTP reset_done - Lanes 0, 1, 2 and 3
	 // SFP enable outputs
	 output wire  [3:0]   SFP_ENABLE,			// Enable signals for SFP connector - Lanes 0, 1, 2 and 3
	 // Transceivers outputs
    input  wire  		    RXN_IN,
    input  wire  		    RXP_IN,
    output wire  [3:0]   TXN_OUT,
    output wire  [3:0]   TXP_OUT,
	
	input wire lane1_cntl,
	input wire lane1_data,
	input wire lane2_cntl,
	input wire lane2_data,
	input wire lane3_cntl,
	input wire lane3_data,
    
    //ChipScope
    inout wire [35:0] ILA_CONTROL
);

    
//************************** Register Declarations ****************************

    

//**************************** Wire Declarations ******************************

    //------------------------ MGT Wrapper Wires ------------------------------

    //________________________________________________________________________
    //________________________________________________________________________
    //TILE0   (X0_Y1)

    //---------------------- Loopback and Powerdown Ports ----------------------
    wire    [2:0]   loopback_lane0;
    wire    [1:0]   rxpowerdown_lane0;
    wire    [1:0]   txpowerdown_lane0;
	 wire    [1:0]   txpowerdown_lane1;
	 wire    [1:0]	  txpowerdown_lane2;
	 wire    [1:0]	  txpowerdown_lane3;
    //------------------------------- PLL Ports --------------------------------
    wire            gtpreset_lane0;
    wire            gtpreset_lane1;
	 wire            gtpreset_lane2;
    wire            gtpreset_lane3;
    wire            plllkdet_lane0;
    wire            plllkdet_lane1;
	 wire            plllkdet_lane2;
    wire            plllkdet_lane3;
    wire            resetdone_lane0;
    wire            resetdone_lane1;
	 wire            resetdone_lane2;
    wire            resetdone_lane3;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
	 wire		[1:0]	  rxrundisp_lane0;
    //-------------------- Receive Ports - Clock Correction --------------------
    wire    [2:0]   rxclkcorcnt_lane0;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    wire            rxbyteisaligned_lane0;
    wire            rxbyterealign_lane0;
    wire            rxcommadet_lane0;
	 wire		[1:0]	  rxcharisk_lane0;
	 wire 	[1:0]	  rxdisperr_lane0;
	 wire		[1:0]	  rxnotintable_lane0;
	 wire				  rxenmcommaalign_lane0;
	 wire				  rxenpcommaalign_lane0;
    wire    [1:0]   rxlossofsync_lane0;
    //----------------- Receive Ports - RX Data Path interface -----------------
    wire    [15:0]  rxdata_lane0;
    wire            rxrecclk_lane0;
	 wire            rxrecclk_pll_lane0;
    wire            rxreset_lane0;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    wire    [1:0]   rxeqmix_lane0;
    wire    [1:0]   rxeqmix_lane1;
	 wire    [1:0]   rxeqmix_lane2;
    wire    [1:0]   rxeqmix_lane3;
    //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
    wire    [2:0]   rxbufstatus_lane0;
	 wire		[1:0]		  rxcharriscomma_lane0;
    //------------------ Receive Ports - RX Polarity Control -------------------
    wire            rxpolarity_lane0;
    //-------------------------- TX/RX Datapath Ports --------------------------
    wire    [1:0]   gtpclkfbeast;
	 wire    [1:0]   gtpclkfbwest;
	 wire    [1:0]   gtpclkout_lane0;
    wire    [1:0]   gtpclkout_lane1;
	 wire    [1:0]   gtpclkout_lane2;
    //----------------- Transmit Ports - 8b10b Encoder Control -----------------
    wire    [1:0]   txbypass8b10b_lane0;
    wire    [1:0]   txbypass8b10b_lane1;
    wire    [1:0]   txbypass8b10b_lane2;
    wire    [1:0]   txbypass8b10b_lane3;
	 wire	   [1:0]	  txcharisk_lane0;
	 wire	   [1:0]	  txcharisk_lane1;
	 wire	   [1:0]	  txcharisk_lane2;
	 wire	   [1:0]	  txcharisk_lane3;
	 wire 	[1:0]	  txrundisp_lane0;
    wire    [1:0]   txchardispmode_lane0;
    wire    [1:0]   txchardispmode_lane1;
	 wire    [1:0]   txchardispmode_lane2;
    wire    [1:0]   txchardispmode_lane3;
    wire    [1:0]   txchardispval_lane0;
    wire    [1:0]   txchardispval_lane1;
	 wire    [1:0]   txchardispval_lane2;
    wire    [1:0]   txchardispval_lane3;
    //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
    wire    [1:0]   txbufstatus_lane0;
    wire            txenpmaphasealign_lanes123;
    wire            txpmasetphase_lanes123;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    wire    [15:0]  txdata_lane0;
    wire    [19:0]  txdata_lane1;
	 wire    [19:0]  txdata_lane2;
    wire    [19:0]  txdata_lane3;
    //wire       	  txoutclk_lane0;
    wire            txreset_lane0;
    wire            txreset_lane1;
    wire            txreset_lane2;
    wire            txreset_lane3;
    //----------------------------- Global Signals -----------------------------
    wire            tied_to_ground_i;
    wire    [191:0] tied_to_ground_vec_i;
    wire            tied_to_vcc_i;   
    
    //--------------------------- User Clocks ---------------------------------
    wire            txusrclk_lane0;
    wire            txusrclk2_lane0;
	 wire            rxusrclk_lane0;
    wire            rxusrclk2_lane0;
    wire            txusrclk_hola;
    wire            txusrclk2_hola;
	 wire            txusrclk_lanes123;
    wire            txusrclk2_lanes123;
    wire            gtpclkout_pll_locked_lane0;
	 wire            gtprecclkout_pll_locked_lane0;
    wire            gtpclkout_pll_reset_lane0;
	 wire            gtprecclkout_pll_reset_lane0;
    wire            gtpclkout_to_cmt_lane0;
    wire            pll0_fb_out_lane0;
	 wire            pll1_fb_out_lane0;
    wire            gtpclkout_lanes123_dcm1_locked;
    wire            gtpclkout_lanes123_dcm1_reset;
    wire            gtpclkout_lanes123_to_dcm;
	 wire            dcm1_fb_in;
	 wire            input_pll_locked;
	 
    //----------------------- Sync Module Signals -----------------------------
    wire            tx_sync_done_lanes123;

    //--------------------- Module Signals --------------------
    //wire            gtp0_refclk;
    //wire            gtp1_refclk;
	//wire            gtp1_refclk_buff;
	wire            pll_clk_80mhz;
	//wire            pll_clk_100mhz;


//**************************** Main Body of Code *******************************

    //---------------------Dedicated GTP Reference Clock Inputs ---------------
    // The dedicated reference clock inputs you selected in the GUI are implemented using
    // IBUFDS instances.
    //
    // In the UCF file for this example design, you will see that each of
    // these IBUFDS instances has been LOCed to a particular set of pins. By LOCing to these
    // locations, we tell the tools to use the dedicated input buffers to the GTP reference
    // clock network, rather than general purpose IOs. To select other pins, consult the 
    // Implementation chapter of UG___, or rerun the wizard.
    //
    // This network is the highest performace (lowest jitter) option for providing clocks
    // to the GTP transceivers.
    
    
    /*IBUFDS tile0_gtp1_refclk_ibufds_i
    (
        .O                              (gtp1_refclk),		// 125 MHz
        .I                              (TILE0_GTP1_REFCLK_PAD_P_IN),
        .IB                             (TILE0_GTP1_REFCLK_PAD_N_IN)
    );*/
	  // Instantiation of the clocking GTP (125MHz -> 100MHz)
	  //--------------------------------------
//	  pll_gtp pllgtp
//		(// Clock in ports
//		 .CLK_IN            (CLK_IN_GTP), // 125MHz
//		 // Clock out ports
//		 .CLK_OUT1           (gtp1_refclk), //100MHz
//		 // Status and control signals
//		 .RESET              (1'b0),
//		 .LOCKED             ()
//		);

    //--------------------------------- User Clocks ---------------------------
    
    // The clock resources in this section were added based on userclk source selections on
    // the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
    // * The userclk and userclk2 for each GTP datapath (TX and RX) must be phase aligned to 
    //   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
    // * To minimize clock resources, you can share clocks between GTPs. GTPs using the same frequency
    //   or multiples of the same frequency can be accomadated using DCMs and PLLs. Use caution when
    //   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
    //   the channels using the clock are receiving data from TX channels that share a reference clock 
    //   source with each other.

    BUFIO2 #
    (
        .DIVIDE                         (1),
        .DIVIDE_BYPASS                  ("TRUE")
    )
    gtpclkout0_0_pll0_bufio2_i
    (
        .I                              (gtpclkout_lane0[0]),
        .DIVCLK                         (gtpclkout_to_cmt_lane0),
        .IOCLK                          (),
        .SERDESSTROBE                   ()
    );
	 
	// Instantiation of DCM and PLL for gtp_dual_0
    assign  gtpclkout_pll_reset_lane0       =  !plllkdet_lane0;
    MGT_USRCLK_SOURCE_PLL #
    (
        .MULT                           (4),
        .DIVIDE                         (1),
        .FEEDBACK                       ("CLKFBOUT"),
        .CLK_PERIOD                     (10.0),
        .OUT0_DIVIDE                    (4), // 100MHz
        .OUT1_DIVIDE                    (2), // 200MHz
        .OUT2_DIVIDE                    (8), // 50MHz
        .OUT3_DIVIDE                    (1)
    )
    gtpclkout0_0_pll0_i
    (
        .CLK0_OUT                       (txusrclk2_lane0),
        .CLK1_OUT                       (txusrclk_lane0),
        .CLK2_OUT                       (iclk2_lane0),
        .CLK3_OUT                       (),
        .CLK_IN                         (gtpclkout_to_cmt_lane0),
        .CLKFB_IN                       (pll0_fb_out_lane0),
        .CLKFB_OUT                      (pll0_fb_out_lane0),
        .PLL_LOCKED_OUT                 (gtpclkout_pll_locked_lane0),
        .PLL_RESET_IN                   (gtpclkout_pll_reset_lane0)
    );

    
	// BUFG for RECCLK in gtp_dual_0 (lane0)
	//BUFG rxrecclk_bufg
	//(.O   (rxrecclk_pll_lane0),
	// .I   (rxrecclk_lane0));

     BUFIO2 #
    (
        .DIVIDE                         (1),
        .DIVIDE_BYPASS                  ("TRUE")
    )
    rxrecclk_bufio2
    (
        .I                              (gtpclkout_lane0[1]),
        .DIVCLK                         (rxrecclk_pll_lane0),
        .IOCLK                          (),
        .SERDESSTROBE                   ()
    );

     // Instantiation of PLL for RECCLK in gtp_dual_0 (lane0)
	assign  gtprecclkout_pll_reset_lane0       =  !plllkdet_lane0;
	MGT_USRCLK_SOURCE_PLL #
    (
        .MULT                           (4),
        .DIVIDE                         (1),
        .FEEDBACK                       ("CLKFBOUT"),
        .CLK_PERIOD                     (10.0),
        .OUT0_DIVIDE                    (4), //  100MHz
        .OUT1_DIVIDE                    (2), //  200MHz
        .OUT2_DIVIDE                    (1), 
        .OUT3_DIVIDE                    (1)
    )
    gtprecclk_pll
    (
        .CLK0_OUT                       (), //(rxusrclk2_lane0),
        .CLK1_OUT                       (), //(rxusrclk_lane0),
        .CLK2_OUT                       (),
        .CLK3_OUT                       (),
        .CLK_IN                         (rxrecclk_pll_lane0),
        .CLKFB_IN                       (pll1_fb_out_lane0),
        .CLKFB_OUT                      (pll1_fb_out_lane0),
        .PLL_LOCKED_OUT                 (gtprecclkout_pll_locked_lane0),
        .PLL_RESET_IN                   (gtprecclkout_pll_reset_lane0)
    );

    assign rxusrclk2_lane0 = txusrclk2_lane0;
    assign rxusrclk_lane0  = txusrclk_lane0;
    
    BUFIO2 #
    (
        .DIVIDE                         (1),
        .DIVIDE_BYPASS                  ("TRUE")
    )
    gtpclkout1_0_dcm1_bufio2_i
    (
        .I                              (gtpclkout_lane2[0]),
        .DIVCLK                         (gtpclkout_lanes123_to_dcm),
        .IOCLK                          (),
        .SERDESSTROBE                   ()
    );
    
	 BUFIO2FB #
    (
        .DIVIDE_BYPASS                  ("TRUE")
    )
    gtpclkout1_0_dcm1_bufio2fb_i
    (
        .I                              (gtpclkfbwest[0]),
        .O                              (dcm1_fb_in)
    );	 

    assign  gtpclkout_lanes123_dcm1_reset       =  !plllkdet_lane2;
    MGT_USRCLK_SOURCE #
    (
        .FREQUENCY_MODE                 ("LOW"),
        .DIVIDE_2                       ("FALSE"),
        .FEEDBACK                       ("1X"),
        .DIVIDE                         (2.0)
    )
    gtpclkout1_0_dcm1_i
    (
        .DIV1_OUT                       (txusrclk_lanes123),
        .DIV2_OUT                       (txusrclk2_lanes123),
        .CLK2X_OUT                      (),
        .DCM_LOCKED_OUT                 (gtpclkout_lanes123_dcm1_locked),
        .CLK_IN                         (gtpclkout_lanes123_to_dcm),
        .FB_IN                          (dcm1_fb_in),
        .DCM_RESET_IN                   (gtpclkout_lanes123_dcm1_reset)
    );
	 
	 //---------------------------- TXSYNC module ------------------------------
    // The TXSYNC module performs phase synchronization for all the active TX datapaths. It
    // waits for the user clocks to be stable, then drives the phase align signals on each
    // GTP. When phase synchronization is complete, it asserts SYNC_DONE
    
    // Include the tx_sync module in your own design to perform phase synchronization if
    // your protocol bypasses the TX Buffers
    
    gtp_dual_0_tx_sync #
    (
        .PLL_DIVSEL_OUT   (4)
    )
    txsync_lanes123
    (
        .TXENPMAPHASEALIGN(txenpmaphasealign_lanes123),
        .TXPMASETPHASE(txpmasetphase_lanes123),
        .SYNC_DONE(tx_sync_done_lanes123),
        .USER_CLK(txusrclk2_lanes123),
        .RESET(!gtpclkout_lanes123_dcm1_locked)
    );	 
	
  // Instantiation of the clocking network
  //--------------------------------------
  pll clknetwork
   (// Clock in ports
    .CLK_IN_40            (CLK_IN_40),
    // Clock out ports
//    .CLK_OUT_40           (),
    .CLK_OUT_80           (pll_clk_80mhz),
    .CLK_OUT_100          (),
    // Status and control signals
    .RESET              (1'b0),
    .LOCKED             (input_pll_locked)
	);

	// Flipping data for G-Link encoder
	wire [15:0]	TX_DATA_LANE1_FLIP;
	wire [15:0]	TX_DATA_LANE2_FLIP;
	wire [15:0]	TX_DATA_LANE3_FLIP;
	genvar i;
	generate
		for (i=0; i<16; i=i+1) begin
			assign TX_DATA_LANE1_FLIP[i] = TX_DATA_LANE1[15-i];
			assign TX_DATA_LANE2_FLIP[i] = TX_DATA_LANE2[15-i];
			assign TX_DATA_LANE3_FLIP[i] = TX_DATA_LANE3[15-i];
		end
	endgenerate	
	
	// Instantiation of the CIMT encoder
	cimt_encoder encoder_lane1
	(
		.txclk(txusrclk2_lanes123),
		.txreset(gtpreset_lane1),
		.tx(TX_DATA_LANE1_FLIP),
		.txflag(1'b0),
		.txflgenb(1'b0),
		.txcntl(lane1_cntl),
		.txdata(lane1_data),
		.encodeddata(txdata_lane1)
	);
//	assign txdata_lane1 = 20'd0;
//	assign txdata_lane1 = TX_DATA_LANE1_FLIP;

//	// Instantiation of the Alberto's CIMT encoder
//	glink_encoder encoder_lane1
//	(
//		.RESET(gtpreset_lane1),
//		.TXDATA(lane1_data),
//		.TXCNTL(lane1_cntl),
//		.TX(TX_DATA_LANE1_FLIP),
//		.TXFLAG(1'b0),
//		.TXCLK(txusrclk2_lanes123),
//		.FRAME(txdata_lane1)
//	);

//	// Instantiation of the CIMT encoder
	cimt_encoder encoder_lane2
	(
		.txclk(txusrclk2_lanes123),
		.txreset(gtpreset_lane2),
		.tx(TX_DATA_LANE2_FLIP),
		.txflag(1'b0),
		.txflgenb(1'b0),
		.txcntl(lane2_cntl),
		.txdata(lane2_data),
		.encodeddata(txdata_lane2)
	);
//	assign txdata_lane2 = 20'd0;
//	assign txdata_lane2 = TX_DATA_LANE2_FLIP;
	
	// Instantiation of the Alberto's CIMT encoder
//	glink_encoder encoder_lane2
//	(
//		.RESET(gtpreset_lane2),
//		.TXDATA(lane2_data),
//		.TXCNTL(lane2_cntl),
//		.TX(TX_DATA_LANE2_FLIP),
//		.TXFLAG(1'b0),
//		.TXCLK(txusrclk2_lanes123),
//		.FRAME(txdata_lane2)
//	);
//	
	// Instantiation of the CIMT encoder
	cimt_encoder encoder_lane3
	(
		.txclk(txusrclk2_lanes123),
		.txreset(gtpreset_lane3),
		.tx(TX_DATA_LANE3_FLIP),
		.txflag(1'b0),
		.txflgenb(1'b0),
		.txcntl(lane3_cntl),
		.txdata(lane3_data),
		.encodeddata(txdata_lane3)
	);
//	assign txdata_lane3 = 20'd0;
//	assign txdata_lane3 = TX_DATA_LANE3_FLIP;

	// Instantiation of the Alberto's CIMT encoder
//	glink_encoder encoder_lane3
//	(
//		.RESET(gtpreset_lane3),
//		.TXDATA(lane3_data),
//		.TXCNTL(lane3_cntl),
//		.TX(TX_DATA_LANE3_FLIP),
//		.TXFLAG(1'b0),
//		.TXCLK(txusrclk2_lanes123),
//		.FRAME(txdata_lane3)
//	);
	
	//---------------------------- The Hola Core -------------------------------
	hola_lsc_spt6 hola
	(
        .INT_RESETDONE(INT_RESETDONE),
		.SYS_RST(gtpreset_lane0),
		.UD(UD),
		.URESET_N(URESET_N),
        .UTEST_N(UTEST_N),
		.UCTRL_N(UCTRL_N),
		.UWEN_N(UWEN_N),
		.UCLK(UCLK),
		.LFF_N(LFF_N),
		.LRL(LRL),
		.LDOWN_N(LDOWN_N),
		.TESTLED_N(TESTLED_N),
		.LDERRLED_N(LDERRLED_N),
		.LUPLED_N(LUPLED_N),
		.FLOWCTLLED_N(FLOWCTLLED_N),
		.ACTIVITYLED_N(ACTIVITYLED_N),
		.GTX_RESETDONE_IN(resetdone_lane0),
		.GTX0_LOOPBACK_OUT(loopback_lane0),
		.GTX0_RXCHARISCOMMA_IN(rxcharriscomma_lane0),
		.GTX0_RXCHARISK_IN(rxcharisk_lane0),
		.GTX0_RXDISPERR_IN(rxdisperr_lane0),
		.GTX0_RXNOTINTABLE_IN(rxnotintable_lane0),
		.GTX0_RXRUNDISP_IN(rxrundisp_lane0),
		.GTX0_RXBYTEISALIGNED_IN(rxbyteisaligned_lane0),
		.GTX0_RXBYTEREALIGN_IN(rxbyterealign_lane0),
		.GTX0_RXCOMMADET_IN(rxcommadet_lane0),
		.GTX0_RXENMCOMMAALIGN_OUT(rxenmcommaalign_lane0),
		.GTX0_RXENPCOMMAALIGN_OUT(rxenpcommaalign_lane0),
        .GTX0_RXLOSSOFSYNC_IN(rxlossofsync_lane0),
		.GTX0_RXDATA_IN(rxdata_lane0),
		.GTX0_RXRECCLK_IN(rxusrclk2_lane0),
		.GTX0_RXRESET_OUT(rxreset_lane0),
		.GTX0_TXPLLLKDET_IN(gtpclkout_pll_locked_lane0),
		.GTX0_RXPLLLKDET_IN(gtprecclkout_pll_locked_lane0),
		.GTX0_TXCHARISK_OUT(txcharisk_lane0),
		.GTX0_TXRUNDISP_IN(txrundisp_lane0),
		.GTX0_TXDATA_OUT(txdata_lane0),
		.GTX0_TXUSRCLK2_IN(txusrclk2_lane0),
		.ICLK2_IN(iclk2_lane0),
		.GTX0_TXRESET_OUT(txreset_lane0),
        .ILA_CONTROL(ILA_CONTROL)
	);	
    //--------------------------- The GTP Wrapper -----------------------------
    
    // Use the instantiation template in the examples directory to add the GTP wrapper to your design.
    // In this example, the wrapper is wired up for basic operation with a frame generator and frame 
    // checker. The GTPs will reset, then attempt to align and transmit data. If channel bonding is 
    // enabled, bonding should occur after alignment.

    // All clock inputs on the individual GTP transceiver must be driven for RESETDONE to work. 
    // When RX Line Rate is set to No RX, the source of RXUSRCLK(2) is set to txusrclk(2). 

		// GTP_DUAL_X0Y1 (Lane 0 and 1)
    gtp_dual_0 #
    (
        .WRAPPER_SIM_GTPRESET_SPEEDUP           (EXAMPLE_SIM_GTPRESET_SPEEDUP),
        .WRAPPER_CLK25_DIVIDER_0                (4),
        .WRAPPER_CLK25_DIVIDER_1                (4),
        .WRAPPER_PLL_DIVSEL_FB_0                (2),
        .WRAPPER_PLL_DIVSEL_FB_1                (4),
        .WRAPPER_PLL_DIVSEL_REF_0               (1),
        .WRAPPER_PLL_DIVSEL_REF_1               (1),
        .WRAPPER_SIMULATION                     (EXAMPLE_SIMULATION)
    )
    gtp_dual_0_i
    (
        //_____________________________________________________________________
        //_____________________________________________________________________
        //TILE0  (X0_Y1)
        //---------------------- Loopback and Powerdown Ports ----------------------
        .TILE0_LOOPBACK0_IN             (loopback_lane0),
        .TILE0_RXPOWERDOWN0_IN          (rxpowerdown_lane0),
        .TILE0_TXPOWERDOWN0_IN          (txpowerdown_lane0),
		.TILE0_TXPOWERDOWN1_IN          (txpowerdown_lane1),
        //------------------------------- PLL Ports --------------------------------
        .TILE0_CLK00_IN                 (LANE0_REFCLK),
        .TILE0_CLK01_IN                 (pll_clk_80mhz),
        .TILE0_GTPRESET0_IN             (gtpreset_lane0),
        .TILE0_GTPRESET1_IN             (gtpreset_lane1),
        .TILE0_PLLLKDET0_OUT            (plllkdet_lane0),
        .TILE0_PLLLKDET1_OUT            (plllkdet_lane1),
        .TILE0_RESETDONE0_OUT           (resetdone_lane0),
        .TILE0_RESETDONE1_OUT           (resetdone_lane1),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .TILE0_RXCHARISCOMMA0_OUT       (rxcharriscomma_lane0),
        .TILE0_RXCHARISK0_OUT           (rxcharisk_lane0),
        .TILE0_RXDISPERR0_OUT           (rxdisperr_lane0),
        .TILE0_RXNOTINTABLE0_OUT        (rxnotintable_lane0),
        .TILE0_RXRUNDISP0_OUT           (rxrundisp_lane0),
        //-------------------- Receive Ports - Clock Correction --------------------
//        .TILE0_RXCLKCORCNT0_OUT         (),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .TILE0_RXBYTEISALIGNED0_OUT     (rxbyteisaligned_lane0),
        .TILE0_RXBYTEREALIGN0_OUT       (rxbyterealign_lane0),
        .TILE0_RXCOMMADET0_OUT          (rxcommadet_lane0),
        .TILE0_RXENMCOMMAALIGN0_IN      (rxenmcommaalign_lane0),
        .TILE0_RXENPCOMMAALIGN0_IN      (rxenpcommaalign_lane0),
        .TILE0_RXLOSSOFSYNC0_OUT        (rxlossofsync_lane0),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .TILE0_RXDATA0_OUT              (rxdata_lane0),
        //.TILE0_RXRECCLK0_OUT            (rxrecclk_lane0),
        //.TILE0_RXRECCLK1_OUT            (),
        .TILE0_RXRESET0_IN              (rxreset_lane0),
        .TILE0_RXUSRCLK0_IN             (rxusrclk_lane0),
        .TILE0_RXUSRCLK1_IN             (txusrclk_lanes123),
        .TILE0_RXUSRCLK20_IN            (rxusrclk2_lane0),
        .TILE0_RXUSRCLK21_IN            (txusrclk2_lanes123),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
//        .TILE0_RXEQMIX0_IN              (rxeqmix_lane0),
        .TILE0_RXEQMIX1_IN              (rxeqmix_lane1),
        .TILE0_RXN0_IN                  (RXN_IN),
        .TILE0_RXP0_IN                  (RXP_IN),
        //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
        .TILE0_RXBUFSTATUS0_OUT         (),
        .TILE0_TXENPMAPHASEALIGN1_IN    (txenpmaphasealign_lanes123),
        .TILE0_TXPMASETPHASE1_IN        (txpmasetphase_lanes123),
        //------------------ Receive Ports - RX Polarity Control -------------------
        .TILE0_RXPOLARITY0_IN           (rxpolarity_lane0),
        //-------------------------- TX/RX Datapath Ports --------------------------
        .TILE0_GTPCLKFBEAST_OUT         (gtpclkfbeast),
		  .TILE0_GTPCLKOUT0_OUT           (gtpclkout_lane0),
        .TILE0_GTPCLKOUT1_OUT           (gtpclkout_lane1),
        //----------------- Transmit Ports - 8b10b Encoder Control -----------------
        .TILE0_TXBYPASS8B10B0_IN        (txbypass8b10b_lane0),
        //.TILE0_TXBYPASS8B10B1_IN        (txbypass8b10b_lane1),
        .TILE0_TXCHARDISPMODE0_IN       (txchardispmode_lane0),
        //.TILE0_TXCHARDISPMODE1_IN       (txchardispmode_lane1),
        .TILE0_TXCHARDISPVAL0_IN        (txchardispval_lane0),
        //.TILE0_TXCHARDISPVAL1_IN        (txchardispval_lane1),
        .TILE0_TXCHARISK0_IN            (txcharisk_lane0),
        //.TILE0_TXCHARISK1_IN            (txcharisk_lane1),
        .TILE0_TXKERR0_OUT              (),
        //.TILE0_TXKERR1_OUT              (),
        .TILE0_TXRUNDISP0_OUT           (txrundisp_lane0),
        //.TILE0_TXRUNDISP1_OUT           (),
        //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
        .TILE0_TXBUFSTATUS0_OUT         (),
//		  .TILE0_TXBUFSTATUS1_OUT         (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TILE0_TXDATA0_IN               (txdata_lane0),
        .TILE0_TXDATA1_IN               (txdata_lane1),
        .TILE0_TXOUTCLK0_OUT            (),
        .TILE0_TXOUTCLK1_OUT            (),
        .TILE0_TXRESET0_IN              (txreset_lane0),
        .TILE0_TXRESET1_IN              (txreset_lane1),
        .TILE0_TXUSRCLK0_IN             (txusrclk_lane0),
        .TILE0_TXUSRCLK1_IN             (txusrclk_lanes123),
        .TILE0_TXUSRCLK20_IN            (txusrclk2_lane0),
        .TILE0_TXUSRCLK21_IN            (txusrclk2_lanes123),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TILE0_TXN0_OUT                 (TXN_OUT[0]),
        .TILE0_TXN1_OUT                 (TXN_OUT[1]),
        .TILE0_TXP0_OUT                 (TXP_OUT[0]),
        .TILE0_TXP1_OUT                 (TXP_OUT[1])
    );

	// GTP_DUAL_X1Y1 (Lane 2 and 3)
	 gtp_dual_1 #
    (
        .WRAPPER_SIM_GTPRESET_SPEEDUP           (EXAMPLE_SIM_GTPRESET_SPEEDUP),
        .WRAPPER_CLK25_DIVIDER_0                (4),
        .WRAPPER_CLK25_DIVIDER_1                (4),
        .WRAPPER_PLL_DIVSEL_FB_0                (4),
        .WRAPPER_PLL_DIVSEL_FB_1                (4),
        .WRAPPER_PLL_DIVSEL_REF_0               (1),
        .WRAPPER_PLL_DIVSEL_REF_1               (1),
        .WRAPPER_SIMULATION                     (EXAMPLE_SIMULATION)
    )
    gtp_dual_1_i
    ( 
        //_____________________________________________________________________
        //_____________________________________________________________________
        //TILE0  (X1_Y1)

        //---------------------- Loopback and Powerdown Ports ----------------------
        .TILE0_TXPOWERDOWN0_IN          (txpowerdown_lane2),
        .TILE0_TXPOWERDOWN1_IN          (txpowerdown_lane3),
        //------------------------------- PLL Ports --------------------------------
        .TILE0_CLK00_IN                 (pll_clk_80mhz),
        .TILE0_CLK01_IN                 (pll_clk_80mhz),
        .TILE0_GTPRESET0_IN             (gtpreset_lane2),
        .TILE0_GTPRESET1_IN             (gtpreset_lane3),
        .TILE0_PLLLKDET0_OUT            (plllkdet_lane2),
        .TILE0_PLLLKDET1_OUT            (plllkdet_lane3),
        .TILE0_RESETDONE0_OUT           (resetdone_lane2),
        .TILE0_RESETDONE1_OUT           (resetdone_lane3),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .TILE0_RXUSRCLK0_IN             (txusrclk_lanes123),
        .TILE0_RXUSRCLK1_IN             (txusrclk_lanes123),
        .TILE0_RXUSRCLK20_IN            (txusrclk2_lanes123),
        .TILE0_RXUSRCLK21_IN            (txusrclk2_lanes123),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .TILE0_RXEQMIX0_IN              (rxeqmix_lane2),
        .TILE0_RXEQMIX1_IN              (rxeqmix_lane3),
        //-------------------------- TX/RX Datapath Ports --------------------------
        .TILE0_GTPCLKFBWEST_OUT         (gtpclkfbwest),
		  .TILE0_GTPCLKOUT0_OUT           (gtpclkout_lane2),
        .TILE0_GTPCLKOUT1_OUT           (),
        //----------------- Transmit Ports - 8b10b Encoder Control -----------------
        /*.TILE0_TXBYPASS8B10B0_IN        (txbypass8b10b_lane2),
        .TILE0_TXBYPASS8B10B1_IN        (txbypass8b10b_lane3),
        .TILE0_TXCHARDISPMODE0_IN       (txchardispmode_lane2),
        .TILE0_TXCHARDISPMODE1_IN       (txchardispmode_lane3),
        .TILE0_TXCHARDISPVAL0_IN        (txchardispval_lane2),
        .TILE0_TXCHARDISPVAL1_IN        (txchardispval_lane3),
        .TILE0_TXCHARISK0_IN            (txcharisk_lane2),
        .TILE0_TXCHARISK1_IN            (txcharisk_lane3),
        .TILE0_TXKERR0_OUT              (),
        .TILE0_TXKERR1_OUT              (),
        .TILE0_TXRUNDISP0_OUT           (),
        .TILE0_TXRUNDISP1_OUT           (),*/
        //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
//        .TILE0_TXBUFSTATUS0_OUT         (),
//        .TILE0_TXBUFSTATUS1_OUT         (),
        .TILE0_TXENPMAPHASEALIGN1_IN    (txenpmaphasealign_lanes123),
        .TILE0_TXPMASETPHASE1_IN        (txpmasetphase_lanes123),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TILE0_TXDATA0_IN               (txdata_lane2),
        .TILE0_TXDATA1_IN               (txdata_lane3),
        .TILE0_TXRESET0_IN              (txreset_lane2),
        .TILE0_TXRESET1_IN              (txreset_lane3),
        .TILE0_TXUSRCLK0_IN             (txusrclk_lanes123),
        .TILE0_TXUSRCLK1_IN             (txusrclk_lanes123),
        .TILE0_TXUSRCLK20_IN            (txusrclk2_lanes123),
        .TILE0_TXUSRCLK21_IN            (txusrclk2_lanes123),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TILE0_TXN0_OUT                 (TXN_OUT[2]),
        .TILE0_TXN1_OUT                 (TXN_OUT[3]),
        .TILE0_TXP0_OUT                 (TXP_OUT[2]),
        .TILE0_TXP1_OUT                 (TXP_OUT[3])
    );

    // Hold the TX in reset till the TX user clocks are stable
//	 assign txreset_lane0 =   !(plllkdet_lane0 && gtpclkout_pll_locked_lane0);
	 assign txreset_lane1 =   !(plllkdet_lane1 && gtpclkout_lanes123_dcm1_locked);
	 assign txreset_lane2 =   !(plllkdet_lane2 && gtpclkout_lanes123_dcm1_locked);
	 assign txreset_lane3 =   !(plllkdet_lane3 && gtpclkout_lanes123_dcm1_locked);
	 
//	 assign rxreset_lane0 =   !(plllkdet_lane0 && gtpclkout_pll_locked_lane0);
//	 assign plllkdet_hola =   (gtprecclkout_pll_locked_lane0 && gtpclkout_pll_locked_lane0);
    

    // GTP signals assignments
	 assign  SFP_ENABLE				= 4'h0;						// Enable all SFPs

    assign  gtpreset_lane0		= RESET_LANE[0];			// Global GTP reset (Lane 0)
	 assign  gtpreset_lane1		= RESET_LANE[1];			// Global GTP reset (Lane 1)
    assign  gtpreset_lane2		= RESET_LANE[2];			// Global GTP reset (Lane 2)
	 assign  gtpreset_lane3		= RESET_LANE[3];			// Global GTP reset (Lane 3)

	 assign  RESET_DONE[0]			= resetdone_lane0;	// Reset Done (Lane 0)
	 assign  RESET_DONE[1]			= resetdone_lane1;	// Reset Done (Lane 1)
	 assign  RESET_DONE[2]			= resetdone_lane2;	// Reset Done (Lane 2)
	 assign  RESET_DONE[3]			= resetdone_lane3;	// Reset Done (Lane 3)

	 assign	PLL_LOCK_DET[0]		= plllkdet_lane0;		// Pll lock detected (Lane 0)
	 assign	PLL_LOCK_DET[1]		= plllkdet_lane1;		// Pll lock detected (Lane 1)
	 assign	PLL_LOCK_DET[2]		= plllkdet_lane2;		// Pll lock detected (Lane 2)
	 assign	PLL_LOCK_DET[3]		= plllkdet_lane3;		// Pll lock detected (Lane 3)
	 
//	 assign  USR_CLK2_LANE[0]			= txusrclk2_lane0;	// User Clock 2 (Lane 0)
	 assign  USR_CLK2_LANE[1]			= txusrclk2_lanes123;	// User Clock 2 (Lane 1)
	 assign  USR_CLK2_LANE[2]			= txusrclk2_lanes123;	// User Clock 2 (Lane 2)
	 assign  USR_CLK2_LANE[3]			= txusrclk2_lanes123;	// User Clock 2 (Lane 3)

//	 assign RX_DATA_LANE0			= rxdata_lane0;		// Rx Data Path (Lane 0)
	 
//	 assign txdata_lane0 		= TX_DATA_LANE0;			// Tx Data Path (Lane 0)
	 //assign txdata_lane1 		= TX_DATA_LANE1;			// Tx Data Path (Lane 1)
	 //assign txdata_lane2 		= TX_DATA_LANE2;			// Tx Data Path (Lane 2)
	// assign txdata_lane3 		= TX_DATA_LANE3;			// Tx Data Path (Lane 3)

	 assign rxpowerdown_lane0	= RX_POWER_DOWN_LANE0;

	 assign txpowerdown_lane0	= TX_POWER_DOWN_LANE0;
	 assign txpowerdown_lane1	= TX_POWER_DOWN_LANE1;
	 assign txpowerdown_lane2	= TX_POWER_DOWN_LANE2;
	 assign txpowerdown_lane3	= TX_POWER_DOWN_LANE3;
	 
//    assign  loopback_lane0               =  3'b000;
//    assign  rxeqmix_lane0                =  2'b00;
//    assign  rxeqmix_lane1                =  2'b00;
//		assign  rxeqmix_lane2                =  2'b00;
//    assign  rxeqmix_lane3                =  2'b00;
    assign  rxpolarity_lane0             =  2'b00;
//    assign  txbypass8b10b_lane0          =  2'b00;
    assign  txbypass8b10b_lane1          =  2'b00;
	 assign  txbypass8b10b_lane2          =  2'b00;
    assign  txbypass8b10b_lane3          =  2'b00;
//	 assign	txcharisk_lane0				  =  2'b00;
//	 assign	txcharisk_lane1				  =  2'b00;
//	 assign	txcharisk_lane2				  =  2'b00;
//	 assign	txcharisk_lane3				  =  2'b00;
//    assign  txchardispmode_lane0         =  1'b0;
    assign  txchardispmode_lane1         =  1'b0;
	 assign  txchardispmode_lane2         =  1'b0;
    assign  txchardispmode_lane3         =  1'b0;
//    assign  txchardispval_lane0          =  1'b0;
    assign  txchardispval_lane1          =  1'b0;
	 assign  txchardispval_lane2          =  1'b0;
    assign  txchardispval_lane3          =  1'b0;
    
    assign LANE0_FBPLL_LOCKED            = gtpclkout_pll_locked_lane0;
    assign LANES123_FBDCM_LOCKED         = gtpclkout_lanes123_dcm1_locked;
	 assign LANES123_SYNC_DONE				  = tx_sync_done_lanes123;
	 assign PLL_INPUT_LOCKED				  = input_pll_locked;
	 
	 assign TX_DATA_ENCODED_LANE2				= txdata_lane2;
	 assign TX_DATA_ENCODED_LANE3				= txdata_lane3;
	 

endmodule
