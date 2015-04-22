-------------------------------------------------------------------------------
-- Title      : TLK2501 SERDES wrapper for Virtex-6
-- Project    : S-LINK
-------------------------------------------------------------------------------
-- File       : tlk_wrapper_vtx6.vhd
-- Author     : Stefan Haas
-- Company    : CERN, PH-ESE
-- Created    : 2011-12-13
-- Last update: 2011-12-13
-- Platform   : Windows 7
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Emulate TLK2501 SERDES with Virtex-6 GTX for HOLA S-LINK
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-12-13  1.0      haass	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity tlk_wrapper_vtx6 is
  
  generic (SIM_GTXRESET_SPEEDUP : integer := 0);  -- simulation setting for GTX SecureIP model

  port (MGTREFCLK_P   : in  std_logic;
        MGTREFCLK_N   : in  std_logic;
        GTX_RESET     : in  std_logic;
        GTX_RESETDONE : out std_logic;
        -- GTX serial I/O
        GTX_RXN       : in  std_logic;
        GTX_RXP       : in  std_logic;
        GTX_TXN       : out std_logic;
        GTX_TXP       : out std_logic;
        -- TLK2501 transmit ports
        TLK_GTXCLK    : out std_logic;
        TLK_TXD       : in  std_logic_vector(15 downto 0);
        TLK_TXEN      : in  std_logic;
        TLK_TXER      : in  std_logic;
        -- TLK2501 transmit ports
        TLK_RXCLK     : out std_logic;
        TLK_RXD       : out std_logic_vector(15 downto 0);
        TLK_RXDV      : out std_logic;
        TLK_RXER      : out std_logic);

end tlk_wrapper_vtx6;

-------------------------------------------------------------------------------

architecture RTL of tlk_wrapper_vtx6 is

--**************************Component Declarations*****************************

  component hola_tlk_gtx
    generic (WRAPPER_SIM_GTXRESET_SPEEDUP : integer := SIM_GTXRESET_SPEEDUP);  -- Set to 1 to speed up sim reset
    port (GTX0_DOUBLE_RESET_CLK_IN : in  std_logic;
          ------------------------ Loopback and Powerdown Ports ----------------------
          GTX0_LOOPBACK_IN         : in  std_logic_vector(2 downto 0);
          ----------------------- Receive Ports - 8b10b Decoder ----------------------
          GTX0_RXCHARISCOMMA_OUT   : out std_logic_vector(1 downto 0);
          GTX0_RXCHARISK_OUT       : out std_logic_vector(1 downto 0);
          GTX0_RXDISPERR_OUT       : out std_logic_vector(1 downto 0);
          GTX0_RXNOTINTABLE_OUT    : out std_logic_vector(1 downto 0);
          GTX0_RXRUNDISP_OUT       : out std_logic_vector(1 downto 0);
          --------------- Receive Ports - Comma Detection and Alignment --------------
          GTX0_RXBYTEISALIGNED_OUT : out std_logic;
          GTX0_RXBYTEREALIGN_OUT   : out std_logic;
          GTX0_RXCOMMADET_OUT      : out std_logic;
          GTX0_RXENMCOMMAALIGN_IN  : in  std_logic;
          GTX0_RXENPCOMMAALIGN_IN  : in  std_logic;
          ------------------- Receive Ports - RX Data Path interface -----------------
          GTX0_RXDATA_OUT          : out std_logic_vector(15 downto 0);
          GTX0_RXRECCLK_OUT        : out std_logic;
          GTX0_RXRESET_IN          : in  std_logic;
          GTX0_RXUSRCLK2_IN        : in  std_logic;
          ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
          GTX0_RXN_IN              : in  std_logic;
          GTX0_RXP_IN              : in  std_logic;
          ------------------------ Receive Ports - RX PLL Ports ----------------------
          GTX0_GTXRXRESET_IN       : in  std_logic;
          GTX0_MGTREFCLKRX_IN      : in  std_logic;
          GTX0_PLLRXRESET_IN       : in  std_logic;
          GTX0_RXPLLLKDET_OUT      : out std_logic;
          GTX0_RXRESETDONE_OUT     : out std_logic;
          ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
          GTX0_TXCHARISK_IN        : in  std_logic_vector(1 downto 0);
          GTX0_TXRUNDISP_OUT       : out  std_logic_vector(1 downto 0);
          ------------------ Transmit Ports - TX Data Path interface -----------------
          GTX0_TXDATA_IN           : in  std_logic_vector(15 downto 0);
          GTX0_TXOUTCLK_OUT        : out std_logic;
          GTX0_TXRESET_IN          : in  std_logic;
          GTX0_TXUSRCLK2_IN        : in  std_logic;
          ---------------- Transmit Ports - TX Driver and OOB signaling --------------
          GTX0_TXN_OUT             : out std_logic;
          GTX0_TXP_OUT             : out std_logic;
          ----------------------- Transmit Ports - TX PLL Ports ----------------------
          GTX0_GTXTXRESET_IN       : in  std_logic;
          GTX0_TXRESETDONE_OUT     : out std_logic);
  end component;

--***********************************Parameter Declarations********************

  attribute max_fanout : string;

--************************** Register Declarations ****************************

  signal gtx_txresetdone_r                    : std_logic;
  signal gtx_txresetdone_r2                   : std_logic;
  signal gtx_rxresetdone_i_r                  : std_logic;
  signal gtx_rxresetdone_r                    : std_logic;
  signal gtx_rxresetdone_r2                   : std_logic;
  signal gtx_rxresetdone_r3                   : std_logic;
  attribute max_fanout of gtx_rxresetdone_i_r : signal is "1";

  -----------------------------------------------------------------------------
  -- Internal signals
  -----------------------------------------------------------------------------
  -------------------------- MGT Wrapper Wires ------------------------------
  ------------------------ Loopback and Powerdown Ports ----------------------
  signal gtx_loopback         : std_logic_vector(2 downto 0);
  ----------------------- Receive Ports - 8b10b Decoder ----------------------
  signal gtx_rxchariscomma    : std_logic_vector(1 downto 0);
  signal gtx_rxcharisk        : std_logic_vector(1 downto 0);
  signal gtx_rxdisperr        : std_logic_vector(1 downto 0);
  signal gtx_rxnotintable     : std_logic_vector(1 downto 0);
  signal gtx_rxrundisp        : std_logic_vector(1 downto 0);
  --------------- Receive Ports - Comma Detection and Alignment --------------
  signal gtx_rxbyteisaligned  : std_logic;
  signal gtx_rxbyterealign    : std_logic;
  signal gtx_rxcommadet       : std_logic;
  signal gtx_rxencommaalign   : std_logic;
  ------------------- Receive Ports - RX Data Path interface -----------------
  signal gtx_rxdata           : std_logic_vector(15 downto 0);
  signal gtx_rxrecclk         : std_logic;
  signal gtx_rxreset          : std_logic;
  ------------------------ Receive Ports - RX PLL Ports ----------------------
  signal gtx_gtxrxreset       : std_logic;
  signal gtx_pllrxreset       : std_logic;
  signal gtx_rxplllkdet       : std_logic;
  signal gtx_rxresetdone      : std_logic;
  ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
  signal gtx_txcharisk        : std_logic_vector(1 downto 0);
  signal gtx_txrundisp        : std_logic_vector(1 downto 0);
  ------------------ Transmit Ports - TX Data Path interface -----------------
  signal gtx_txdata           : std_logic_vector(15 downto 0);
  signal gtx_txoutclk         : std_logic;
  signal gtx_txreset          : std_logic;
  ----------------------- Transmit Ports - TX PLL Ports ----------------------
  signal gtx_gtxtxreset       : std_logic;
  signal gtx_txresetdone      : std_logic;
  signal gtx_tlk_reset        : std_logic;
  signal gtx_double_reset_clk : std_logic;
  signal tied_to_ground       : std_logic;
  signal tied_to_ground_vec   : std_logic_vector(2 downto 0);
  ----------------------------- User Clocks ---------------------------------
  signal gtx_txusrclk2         : std_logic;
  signal gtx_rxusrclk2         : std_logic;
  ----------------------------- Reference Clocks ----------------------------
  signal mgtrefclk   : std_logic;
  signal refclk_bufg : std_logic;
  

--**************************** Main Body of Code *******************************
begin

  -----------------------------------------------------------------------------
  -- Interface from TLK2501 ports to Virtex-6 GTX
  -----------------------------------------------------------------------------
  tlk_gtx_interface_1 : entity work.tlk_gtx_interface
    port map (SYS_RST            => gtx_tlk_reset,
              GTX_RXUSRCLK2      => GTX_RXUSRCLK2,
              GTX_RXDATA         => GTX_RXDATA,
              GTX_RXCHARISK      => GTX_RXCHARISK,
              GTX_RXENCOMMAALIGN => GTX_RXENCOMMAALIGN,
              GTX_TXUSRCLK2      => GTX_TXUSRCLK2,
              GTX_TXCHARISK      => GTX_TXCHARISK,
              GTX_TXDATA         => GTX_TXDATA,
              TLK_TXD            => TLK_TXD,
              TLK_TXEN           => TLK_TXEN,
              TLK_TXER           => TLK_TXER,
              TLK_RXD            => TLK_RXD,
              TLK_RXDV           => TLK_RXDV,
              TLK_RXER           => TLK_RXER);

  -----------------------------------------------------------------------------
  -- Clock outputs
  -----------------------------------------------------------------------------
  TLK_RXCLK  <= GTX_RXUSRCLK2;
  TLK_GTXCLK <= GTX_TXUSRCLK2;

  --  Static signal Assigments
  tied_to_ground     <= '0';
  tied_to_ground_vec <= "000";

  -----------------------Dedicated GTX Reference Clock Inputs ---------------
  -- The dedicated reference clock inputs you selected in the GUI are implemented using
  -- IBUFDS_GTXE1 instances.
  --
  -- In the UCF file for this example design, you will see that each of
  -- these IBUFDS_GTXE1 instances has been LOCed to a particular set of pins. By LOCing to these
  -- locations, we tell the tools to use the dedicated input buffers to the GTX reference
  -- clock network, rather than general purpose IOs. To select other pins, consult the 
  -- Implementation chapter of UG___, or rerun the wizard.
  --
  -- This network is the highest performace (lowest jitter) option for providing clocks
  -- to the GTX transceivers.

  refclk_ibufds_i : IBUFDS_GTXE1
    port map (O     => mgtrefclk,
              ODIV2 => open,
              CEB   => tied_to_ground,
              I     => MGTREFCLK_P,
              IB    => MGTREFCLK_N);
  
  -----------------------Clock Input to Double Reset Module------------------

  refclk_bufg_i : BUFG
    port map (I => mgtrefclk,
              O => refclk_bufg);

  gtx_double_reset_clk <= refclk_bufg;

  ----------------------------------- User Clocks ---------------------------

  -- The clock resources in this section were added based on userclk source selections on
  -- the Latency, Buffering, and Clocking page of the GUI. A few notes about user clocks:
  -- * The userclk and userclk2 for each GTX datapath (TX and RX) must be phase aligned to 
  --   avoid data errors in the fabric interface whenever the datapath is wider than 10 bits
  -- * To minimize clock resources, you can share clocks between GTXs. GTXs using the same frequency
  --   or multiples of the same frequency can be accomadated using MMCMs. Use caution when
  --   using RXRECCLK as a clock source, however - these clocks can typically only be shared if all
  --   the channels using the clock are receiving data from TX channels that share a reference clock 
  --   source with each other.

  txoutclk_bufg0_i : BUFG
    port map (I => gtx_txoutclk,
              O => gtx_txusrclk2);


  rxrecclk_bufg1_i : BUFG
    port map (I => gtx_rxrecclk,
              O => gtx_rxusrclk2);
  
  ----------------------------- The GTX Wrapper -----------------------------

  hola_tlk_gtx_i : hola_tlk_gtx
    generic map (WRAPPER_SIM_GTXRESET_SPEEDUP => SIM_GTXRESET_SPEEDUP)
    
    port map (GTX0_DOUBLE_RESET_CLK_IN => gtx_double_reset_clk,
              ------------------------ Loopback and Powerdown Ports ----------------------
              GTX0_LOOPBACK_IN         => gtx_loopback,
              ----------------------- Receive Ports - 8b10b Decoder ----------------------
              GTX0_RXCHARISCOMMA_OUT   => gtx_rxchariscomma,
              GTX0_RXCHARISK_OUT       => gtx_rxcharisk,
              GTX0_RXDISPERR_OUT       => gtx_rxdisperr,
              GTX0_RXNOTINTABLE_OUT    => gtx_rxnotintable,
              GTX0_RXRUNDISP_OUT       => gtx_rxrundisp,
              --------------- Receive Ports - Comma Detection and Alignment --------------
              GTX0_RXBYTEISALIGNED_OUT => gtx_rxbyteisaligned,
              GTX0_RXBYTEREALIGN_OUT   => gtx_rxbyterealign,
              GTX0_RXCOMMADET_OUT      => gtx_rxcommadet,
              GTX0_RXENMCOMMAALIGN_IN  => gtx_rxencommaalign,
              GTX0_RXENPCOMMAALIGN_IN  => gtx_rxencommaalign,
              ------------------- Receive Ports - RX Data Path interface -----------------
              GTX0_RXDATA_OUT          => gtx_rxdata,
              GTX0_RXRECCLK_OUT        => gtx_rxrecclk,
              GTX0_RXRESET_IN          => gtx_rxreset,
              GTX0_RXUSRCLK2_IN        => gtx_rxusrclk2,
              ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
              GTX0_RXN_IN              => GTX_RXN,
              GTX0_RXP_IN              => GTX_RXP,
              ------------------------ Receive Ports - RX PLL Ports ----------------------
              GTX0_GTXRXRESET_IN       => gtx_gtxrxreset,
              GTX0_MGTREFCLKRX_IN      => mgtrefclk,
              GTX0_PLLRXRESET_IN       => gtx_pllrxreset,
              GTX0_RXPLLLKDET_OUT      => gtx_rxplllkdet,
              GTX0_RXRESETDONE_OUT     => gtx_rxresetdone,
              ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
              GTX0_TXCHARISK_IN        => gtx_txcharisk,
              GTX0_TXRUNDISP_OUT       => gtx_txrundisp,
              ------------------ Transmit Ports - TX Data Path interface -----------------
              GTX0_TXDATA_IN           => gtx_txdata,
              GTX0_TXOUTCLK_OUT        => gtx_txoutclk,
              GTX0_TXRESET_IN          => gtx_txreset,
              GTX0_TXUSRCLK2_IN        => gtx_txusrclk2,
              ---------------- Transmit Ports - TX Driver and OOB signaling --------------
              GTX0_TXN_OUT             => GTX_TXN,
              GTX0_TXP_OUT             => GTX_TXP,
              ----------------------- Transmit Ports - TX PLL Ports ----------------------
              GTX0_GTXTXRESET_IN       => gtx_gtxtxreset,
              GTX0_TXRESETDONE_OUT     => gtx_txresetdone);

  -------------------------- User Module Resets -----------------------------
  -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
  -- are held in reset till the RESETDONE goes high. 
  -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
  -- to the reset of the modules
  
  process(gtx_rxusrclk2)
  begin
    if rising_edge(gtx_rxusrclk2) then
      gtx_rxresetdone_i_r <= gtx_rxresetdone;
    end if;
  end process;

  process(gtx_rxusrclk2, gtx_rxresetdone_i_r)
  begin
    if (gtx_rxresetdone_i_r = '0') then
      gtx_rxresetdone_r  <= '0';
      gtx_rxresetdone_r2 <= '0';
    elsif rising_edge(gtx_rxusrclk2) then
      gtx_rxresetdone_r  <= gtx_rxresetdone_i_r;
      gtx_rxresetdone_r2 <= gtx_rxresetdone_r;
    end if;
  end process;

  process(gtx_rxusrclk2)
  begin
    if rising_edge(gtx_rxusrclk2) then
      gtx_rxresetdone_r3 <= gtx_rxresetdone_r2;
    end if;
  end process;

  process(gtx_txusrclk2, gtx_txresetdone)
  begin
    if(gtx_txresetdone = '0') then
      gtx_txresetdone_r  <= '0';
      gtx_txresetdone_r2 <= '0';
    elsif rising_edge(gtx_txusrclk2) then
      gtx_txresetdone_r  <= gtx_txresetdone;
      gtx_txresetdone_r2 <= gtx_txresetdone_r;
    end if;
  end process;

  gtx_gtxtxreset <= GTX_RESET;
  gtx_gtxrxreset <= GTX_RESET;
  gtx_rxreset    <= tied_to_ground;
  gtx_txreset    <= tied_to_ground;

  -- resets for the TLK-GTX interface
  gtx_tlk_reset <= not gtx_txresetdone_r2 or not gtx_rxresetdone_r3 or GTX_RESET;

  GTX_RESETDONE <= gtx_txresetdone_r2 and gtx_rxresetdone_r3;

  gtx_loopback    <= tied_to_ground_vec(2 downto 0);
  gtx_pllrxreset  <= tied_to_ground;

end RTL;
