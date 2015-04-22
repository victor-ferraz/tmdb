--------------------------------------------------------------------------------
-- Institutions:	UFRJ - Federal University of Rio de Janeiro
--						UFJF - Federal Univesity of Juiz de Fora
-- Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
--					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
--					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
--
-- Create Date: 13/03/2015
-- Design Name: tmdb_core
-- Module Name: tlk_wrapper_spt6
-- Orig. File:	 tlk_wrapper_vtx6.vhd
-- Target Device: Spartan-6 XC6SLX150T-FGG676
-- Tool versions: Xilinx ISE Design Suite 14.7
-- Description:
-- 	Emulate TLK2501 SERDES with Spartan-6 GTP for HOLA S-LINK
-- Dependencies:
-- 
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity tlk_wrapper_spt6 is
  
--  generic (SIM_GTXRESET_SPEEDUP : integer := 0);  -- simulation setting for GTX SecureIP model

  port (       
        GTX_RESET     		: in  std_logic;
        GTX_RESETDONE_IN 	: in	 std_logic;
		  GTX_RESETDONE_OUT 	: out std_logic;
        -- TLK2501 transmit ports
        TLK_GTXCLK    : out std_logic;
        TLK_TXD       : in  std_logic_vector(15 downto 0);
        TLK_TXEN      : in  std_logic;
        TLK_TXER      : in  std_logic;
        -- TLK2501 transmit ports
        TLK_RXCLK     : out std_logic;
        TLK_RXD       : out std_logic_vector(15 downto 0);
        TLK_RXDV      : out std_logic;
        TLK_RXER      : out std_logic;
		  -- GTP ports
			------------------------ Loopback and Powerdown Ports ----------------------
			GTX0_LOOPBACK_OUT         	: out  std_logic_vector(2 downto 0);
			----------------------- Receive Ports - 8b10b Decoder ----------------------
			GTX0_RXCHARISCOMMA_IN   	: in std_logic_vector(1 downto 0);
			GTX0_RXCHARISK_IN       	: in std_logic_vector(1 downto 0);
			GTX0_RXDISPERR_IN       	: in std_logic_vector(1 downto 0);
			GTX0_RXNOTINTABLE_IN    	: in std_logic_vector(1 downto 0);
			GTX0_RXRUNDISP_IN       	: in std_logic_vector(1 downto 0);
			--------------- Receive Ports - Comma Detection and Alignment --------------
			GTX0_RXBYTEISALIGNED_IN 	: in std_logic;
			GTX0_RXBYTEREALIGN_IN   	: in std_logic;
			GTX0_RXCOMMADET_IN      	: in std_logic;
			GTX0_RXENMCOMMAALIGN_OUT  	: out  std_logic;
			GTX0_RXENPCOMMAALIGN_OUT  	: out  std_logic;
			------------------- Receive Ports - RX Data Path interface -----------------
			GTX0_RXDATA_IN          	: in std_logic_vector(15 downto 0);
			GTX0_RXRECCLK_IN        	: in std_logic;
			GTX0_RXRESET_OUT          	: out  std_logic;
			------------------------ Receive Ports - RX/TX PLL Ports ----------------------
			GTX0_TXPLLLKDET_IN      	: in std_logic;
			GTX0_RXPLLLKDET_IN      	: in std_logic;
			---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
			GTX0_TXCHARISK_OUT        	: out  std_logic_vector(1 downto 0);
			GTX0_TXRUNDISP_IN       	: in  std_logic_vector(1 downto 0);
			------------------ Transmit Ports - TX Data Path interface -----------------
			GTX0_TXDATA_OUT           	: out  std_logic_vector(15 downto 0);
			GTX0_TXUSRCLK2_IN        	: in std_logic;
			GTX0_TXRESET_OUT          	: out  std_logic;
            -- Chipscope
            TLK_SYNC_FSM                : out std_logic_vector(9 downto 0);
            IS_SYNC                     : out std_logic
			);		  

end tlk_wrapper_spt6;

-------------------------------------------------------------------------------

architecture RTL of tlk_wrapper_spt6 is

--**************************Component Declarations*****************************



--***********************************Parameter Declarations********************

  attribute max_fanout : string;

--************************** Register Declarations ****************************

--  signal GTX_RESETDONE_IN                    : std_logic;
  signal gtx_resetdone_r                    : std_logic;
  signal gtx_resetdone_r2                   : std_logic;
  signal gtx_resetdone_r3                   : std_logic;
  signal gtx_resetdone_i_r                  : std_logic;
  
  attribute max_fanout of gtx_resetdone_i_r : signal is "1";

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
  signal gtx_plllkdet       : std_logic;
  signal gtx_rxresetdone      : std_logic;
  ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
  signal gtx_txcharisk        : std_logic_vector(1 downto 0);
  signal gtx_txrundisp        : std_logic_vector(1 downto 0);
  ------------------ Transmit Ports - TX Data Path interface -----------------
  signal gtx_txdata           : std_logic_vector(15 downto 0);
  signal gtx_clk              : std_logic;
  signal gtx_txreset          : std_logic;
  ----------------------- Transmit Ports - TX PLL Ports ----------------------
  signal gtx_gtxtxreset       : std_logic;
  signal gtx_txresetdone      : std_logic;
  signal gtx_tlk_reset        : std_logic;
  signal gtx_double_reset_clk : std_logic;
  signal tied_to_ground       : std_logic;
  signal tied_to_ground_vec   : std_logic_vector(2 downto 0);
  ----------------------------- User Clocks ---------------------------------
  signal gtx_txusrclk         : std_logic;
  signal gtx_txusrclk2        : std_logic;
  signal gtx_rxusrclk2        : std_logic;
  ----------------------------- Reference Clocks ----------------------------
  signal mgtrefclk   			: std_logic;
  signal refclk_bufg 			: std_logic;
  ---------------------------------------------------------------------------
  signal txrxfbpll_locked 		: std_logic;

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
              TLK_RXER           => TLK_RXER,
              TLK_SYNC_FSM       => TLK_SYNC_FSM,
              IS_SYNC            => IS_SYNC);

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

--  refclk_ibufds_i : IBUFDS_GTXE1
--    port map (O     => mgtrefclk,
--              ODIV2 => open,
--              CEB   => tied_to_ground,
--              I     => MGTREFCLK_P,
--              IB    => MGTREFCLK_N);
  
  -----------------------Clock Input to Double Reset Module------------------

--  refclk_bufg_i : BUFG
--    port map (I => mgtrefclk,
--              O => refclk_bufg);
--
--  gtx_double_reset_clk <= refclk_bufg;

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

--  txoutclk_bufg0_i : BUFG
--    port map (I => gtx_clk,
--              O => gtx_txusrclk2);


--  rxrecclk_bufg1_i : BUFG
--    port map (I => gtx_rxrecclk,
--              O => gtx_rxusrclk2);
	gtx_rxusrclk2 <=	gtx_rxrecclk;

  -------------------------- User Module Resets -----------------------------
  -- All the User Modules i.e. FRAME_GEN, FRAME_CHECK and the sync modules
  -- are held in reset till the RESETDONE goes high. 
  -- The RESETDONE is registered a couple of times on USRCLK2 and connected 
  -- to the reset of the modules


-- TX and RX feedback PLL locked
	txrxfbpll_locked <= GTX0_TXPLLLKDET_IN and GTX0_RXPLLLKDET_IN;
	
-- GTP Resetdone registers
  process(gtx_txusrclk2)
  begin
    if rising_edge(gtx_txusrclk2) then
      gtx_resetdone_i_r <= GTX_RESETDONE_IN and txrxfbpll_locked;
    end if;
  end process;

  process(gtx_txusrclk2, gtx_resetdone_i_r)
  begin
    if(gtx_resetdone_i_r = '0') then
		gtx_resetdone_r  <= '0';
      gtx_resetdone_r2 <= '0';
    elsif rising_edge(gtx_txusrclk2) then
		gtx_resetdone_r  <= gtx_resetdone_i_r;
      gtx_resetdone_r2 <= gtx_resetdone_r;
    end if;
  end process;
  
  process(gtx_txusrclk2)
  begin
    if rising_edge(gtx_txusrclk2) then
      gtx_resetdone_r3 <= gtx_resetdone_r2;
    end if;
  end process;

  -- Hold the TX and RX in reset till the user clocks are stable
  gtx_rxreset		<= '0'; --GTX_RESET or not GTX0_RXPLLLKDET_IN;
  gtx_txreset	  	<= '0'; --GTX_RESET or not GTX0_TXPLLLKDET_IN;

  -- resets for the TLK-GTX interface
--  gtx_tlk_reset <= not gtx_txresetdone_r2 or not gtx_rxresetdone_r3 or GTX_RESET;
	 gtx_tlk_reset <= not gtx_resetdone_r3 or GTX_RESET;

  GTX_RESETDONE_OUT <= gtx_resetdone_r3;

  gtx_loopback    <= tied_to_ground_vec(2 downto 0);
--  gtx_pllrxreset  <= tied_to_ground;

	------------------------ Loopback and Powerdown Ports ----------------------
	GTX0_LOOPBACK_OUT		<= gtx_loopback;
	----------------------- Receive Ports - 8b10b Decoder ----------------------
--	gtx_rxchariscomma		<= GTX0_RXCHARISCOMMA_IN;
	gtx_rxcharisk			<= GTX0_RXCHARISK_IN;      
--	gtx_rxdisperr			<= GTX0_RXDISPERR_IN;  
--	gtx_rxnotintable		<= GTX0_RXNOTINTABLE_IN;
--	gtx_rxrundisp			<= GTX0_RXRUNDISP_IN;
	--------------- Receive Ports - Comma Detection and Alignment --------------
--	gtx_rxbyteisaligned	<= GTX0_RXBYTEISALIGNED_IN;
--	gtx_rxbyterealign		<= GTX0_RXBYTEREALIGN_IN;
--	gtx_rxcommadet			<= GTX0_RXCOMMADET_IN;
	GTX0_RXENMCOMMAALIGN_OUT	<= gtx_rxencommaalign;
	GTX0_RXENPCOMMAALIGN_OUT	<= gtx_rxencommaalign;
	------------------- Receive Ports - RX Data Path interface -----------------
	gtx_rxdata				<= GTX0_RXDATA_IN;
	gtx_rxrecclk			<= GTX0_RXRECCLK_IN;
	GTX0_RXRESET_OUT		<= gtx_rxreset;
	------------------------ Receive Ports - RX PLL Ports ----------------------
--	gtx_plllkdet			<= GTX0_PLLLKDET_IN;
	---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
	GTX0_TXCHARISK_OUT	<= gtx_txcharisk;
--	gtx_txrundisp			<= GTX0_TXRUNDISP_IN;
	------------------ Transmit Ports - TX Data Path interface -----------------
	GTX0_TXDATA_OUT		<= gtx_txdata;
--	gtx_clk					<= GTX0_TXUSRCLK2_IN;
	gtx_txusrclk2			<= GTX0_TXUSRCLK2_IN;
	GTX0_TXRESET_OUT		<= gtx_txreset;

end RTL;
