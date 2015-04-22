////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 1.11
//  \   \         Application : Spartan-6 FPGA GTP Transceiver Wizard  
//  /   /         Filename : instantiation_template.v
// /___/   /\       
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Instantiation Template
// Generated by Xilinx Spartan-6 FPGA GTP Transceiver Wizard
// 
// 
// (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


// Use the templates in this file to add the components generated by the wizard to your
// design. 

   


    //--------------------------- The GTP Wrapper -----------------------------


    gtp_dual_0 #
    (
        .WRAPPER_SIM_GTPRESET_SPEEDUP   (0),      // Set this to 1 for simulation
        .WRAPPER_SIMULATION             (0)       // Set this to 1 for simulation
    )
    gtp_dual_0_i
    (
    
        //_____________________________________________________________________
        //_____________________________________________________________________
        //TILE0  (X0_Y1)
 
        //---------------------- Loopback and Powerdown Ports ----------------------
        .TILE0_LOOPBACK0_IN             (),
        .TILE0_RXPOWERDOWN0_IN          (),
        .TILE0_TXPOWERDOWN0_IN          (),
        .TILE0_TXPOWERDOWN1_IN          (),
        //------------------------------- PLL Ports --------------------------------
        .TILE0_CLK00_IN                 (tile0_gtp1_refclk_i),
        .TILE0_CLK01_IN                 (tile0_gtp0_refclk_i),
        .TILE0_GTPRESET0_IN             (),
        .TILE0_GTPRESET1_IN             (),
        .TILE0_PLLLKDET0_OUT            (),
        .TILE0_PLLLKDET1_OUT            (),
        .TILE0_RESETDONE0_OUT           (),
        .TILE0_RESETDONE1_OUT           (),
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .TILE0_RXCHARISCOMMA0_OUT       (),
        .TILE0_RXCHARISK0_OUT           (),
        .TILE0_RXDISPERR0_OUT           (),
        .TILE0_RXNOTINTABLE0_OUT        (),
        .TILE0_RXRUNDISP0_OUT           (),
        //-------------------- Receive Ports - Clock Correction --------------------
        .TILE0_RXCLKCORCNT0_OUT         (),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .TILE0_RXBYTEISALIGNED0_OUT     (),
        .TILE0_RXBYTEREALIGN0_OUT       (),
        .TILE0_RXCOMMADET0_OUT          (),
        .TILE0_RXENMCOMMAALIGN0_IN      (),
        .TILE0_RXENPCOMMAALIGN0_IN      (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .TILE0_RXDATA0_OUT              (),
        .TILE0_RXRECCLK0_OUT            (),
        .TILE0_RXRESET0_IN              (),
        .TILE0_RXUSRCLK0_IN             (),
        .TILE0_RXUSRCLK1_IN             (),
        .TILE0_RXUSRCLK20_IN            (),
        .TILE0_RXUSRCLK21_IN            (),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .TILE0_RXEQMIX1_IN              (),
        .TILE0_RXN0_IN                  (),
        .TILE0_RXP0_IN                  (),
        //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
        .TILE0_RXBUFSTATUS0_OUT         (),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .TILE0_RXLOSSOFSYNC0_OUT        (),
        //------------------ Receive Ports - RX Polarity Control -------------------
        .TILE0_RXPOLARITY0_IN           (),
        //-------------------------- TX/RX Datapath Ports --------------------------
        .TILE0_GTPCLKFBEAST_OUT         (),
        .TILE0_GTPCLKOUT0_OUT           (),
        .TILE0_GTPCLKOUT1_OUT           (),
        //----------------- Transmit Ports - 8b10b Encoder Control -----------------
        .TILE0_TXBYPASS8B10B0_IN        (),
        .TILE0_TXCHARDISPMODE0_IN       (),
        .TILE0_TXCHARDISPVAL0_IN        (),
        .TILE0_TXCHARISK0_IN            (),
        .TILE0_TXKERR0_OUT              (),
        .TILE0_TXRUNDISP0_OUT           (),
        //------------- Transmit Ports - TX Buffer and Phase Alignment -------------
        .TILE0_TXBUFSTATUS0_OUT         (),
        .TILE0_TXENPMAPHASEALIGN1_IN    (),
        .TILE0_TXPMASETPHASE1_IN        (),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TILE0_TXDATA0_IN               (),
        .TILE0_TXDATA1_IN               (),
        .TILE0_TXOUTCLK0_OUT            (),
        .TILE0_TXOUTCLK1_OUT            (),
        .TILE0_TXRESET0_IN              (),
        .TILE0_TXRESET1_IN              (),
        .TILE0_TXUSRCLK0_IN             (),
        .TILE0_TXUSRCLK1_IN             (),
        .TILE0_TXUSRCLK20_IN            (),
        .TILE0_TXUSRCLK21_IN            (),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TILE0_TXN0_OUT                 (),
        .TILE0_TXN1_OUT                 (),
        .TILE0_TXP0_OUT                 (),
        .TILE0_TXP1_OUT                 ()


    );
    



    //---------------------Dedicated GTP Reference Clock Inputs ---------------
    // Each dedicated refclk you are using in your design will need its own IBUFDS instance
    
    IBUFDS tile0_gtp0_refclk_ibufds_i
    (
        .O                              (tile0_gtp0_refclk_i),
        .I                              (),  // Connect to package pin B10
        .IB                             ()   // Connect to package pin A10
    );

    IBUFDS tile0_gtp1_refclk_ibufds_i
    (
        .O                              (tile0_gtp1_refclk_i),
        .I                              (),  // Connect to package pin D11
        .IB                             ()   // Connect to package pin C11
    );



    //---------------------------- TXSYNC module ------------------------------
    // Since you are bypassing the TX Buffer in your wrapper, you will need to drive
    // the phase alignment ports to align the phase of the TX Datapath. Include
    // this module in your design to have phase alignment performed automatically as
    // it is done in the example design.
    

    
    TX_SYNC # 
    (
        .PLL_DIVSEL_OUT    (4)
    )
    tile0_txsync1_i 
    (
        .TXENPMAPHASEALIGN              ()    
        .TXPMASETPHASE                  ()
        .SYNC_DONE                      ()
        .USER_CLK                       ()
        .RESET                          (),
    );
    
    
    


