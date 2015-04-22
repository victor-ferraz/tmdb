--------------------------------------------------------------------------------
-- Institutions:	UFRJ - Federal University of Rio de Janeiro
--						UFJF - Federal Univesity of Juiz de Fora
-- Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
--					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
--					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
--
-- Create Date: 13/03/2015
-- Design Name: tmdb_core
-- Module Name: hola_lsc_spt6
-- Orig. File:	 hola_lsc_vtx6.vhd
-- Target Device: Spartan-6 XC6SLX150T-FGG676
-- Tool versions: Xilinx ISE Design Suite 14.7
-- Description:
--    HOLA LSC implementation with on-chip SERDES for Spartan-6
-- Dependencies:
-- 
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity hola_lsc_spt6 is

  generic (SIMULATION : integer := 0);

  port (
        SYS_RST         : in  std_logic;
        INT_RESETDONE   : out std_logic;
        -- S-LINK interface
        UD              : in  std_logic_vector(31 downto 0);
        URESET_N        : in  std_logic;
        UTEST_N         : in  std_logic;
        UCTRL_N         : in  std_logic;
        UWEN_N          : in  std_logic;
        UCLK            : in  std_logic;
        LFF_N           : out std_logic;
        LRL             : out std_logic_vector(3 downto 0);
        LDOWN_N         : out std_logic;
        -- LEDs
        TESTLED_N       : out std_logic;
        LDERRLED_N      : out std_logic;
        LUPLED_N        : out std_logic;
        FLOWCTLLED_N    : out std_logic;
        ACTIVITYLED_N   : out std_logic;
		  -- GTP Interface
		  GTX_RESETDONE_IN  : in  std_logic;
			------------------------ Loopback and Powerdown Ports ----------------------
			GTX0_LOOPBACK_OUT         	: out  std_logic_vector(2 downto 0);
			----------------------- Receive Ports - 8b10b Decoder ----------------------
			GTX0_RXCHARISCOMMA_IN   	: in std_logic_vector(1 downto 0);
			GTX0_RXCHARISK_IN       	: in std_logic_vector(1 downto 0);
			GTX0_RXDISPERR_IN       	: in std_logic_vector(1 downto 0);
			GTX0_RXNOTINTABLE_IN    	: in std_logic_vector(1 downto 0);
			GTX0_RXRUNDISP_IN       	: in std_logic_vector(1 downto 0);
			--------------- Receive Ports - Comma Detection and Alignment --------------
			GTX0_RXBYTEISALIGNED_IN 	: in  std_logic;
			GTX0_RXBYTEREALIGN_IN   	: in  std_logic;
			GTX0_RXCOMMADET_IN      	: in  std_logic;
			GTX0_RXENMCOMMAALIGN_OUT  	: out std_logic;
			GTX0_RXENPCOMMAALIGN_OUT  	: out std_logic;
            GTX0_RXLOSSOFSYNC_IN        : in  std_logic_vector(1 downto 0);
			------------------- Receive Ports - RX Data Path interface -----------------
			GTX0_RXDATA_IN          	: in std_logic_vector(15 downto 0);
			GTX0_RXRECCLK_IN        	: in std_logic;
			GTX0_RXRESET_OUT          	: out  std_logic;
			------------------------ Receive Ports - RX PLL Ports ----------------------
			GTX0_TXPLLLKDET_IN 		    : in std_logic;
			GTX0_RXPLLLKDET_IN 		    : in std_logic;
			---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
			GTX0_TXCHARISK_OUT        	: out  std_logic_vector(1 downto 0);
			GTX0_TXRUNDISP_IN       	: in  std_logic_vector(1 downto 0);
			------------------ Transmit Ports - TX Data Path interface -----------------
			GTX0_TXDATA_OUT           	: out  std_logic_vector(15 downto 0);
			GTX0_TXUSRCLK2_IN        	: in std_logic;
			ICLK2_IN				    : in std_logic;
			GTX0_TXRESET_OUT          	: out  std_logic;
            --------------------------- ChipScope --------------------------------------
            ILA_CONTROL                 : inout std_logic_vector(35 downto 0)
			);

end entity hola_lsc_spt6;

-------------------------------------------------------------------------------

architecture structure of hola_lsc_spt6 is

  signal LSC_RST_N     : std_logic;
  signal RESETDONE : std_logic;
  signal TLK_GTXCLK    : std_logic;
  signal TLK_TXD       : std_logic_vector(15 downto 0);
  signal TLK_TXEN      : std_logic;
  signal TLK_TXER      : std_logic;
  signal TLK_RXCLK     : std_logic;
  signal TLK_RXD       : std_logic_vector(15 downto 0);
  signal TLK_RXDV      : std_logic;
  signal TLK_RXER      : std_logic;
  signal TLK_ENABLE    : std_logic;
  --
  signal tlk_sync_fsm   : std_logic_vector(9 downto 0);
  signal tlk_is_sync    : std_logic;
  signal GTX0_RXENMCOMMAALIGN_OUT_aux : std_logic;
  signal GTX0_RXRESET_OUT_aux         : std_logic;
  signal GTX0_TXCHARISK_OUT_aux       : std_logic_vector(1 downto 0);
  signal GTX0_TXRESET_OUT_aux         : std_logic;
  
begin  -- architecture structure

  holalsc_core_1 : entity work.holalsc_core
    generic map (SIMULATION      => SIMULATION,
                 ALTERA_XILINX   => 0,    -- XILINX
                 XCLK_FREQ       => 100,  -- XCLK = 100 MHz
                 USE_PLL         => 0,    -- Do not use PLL to generate ICLK_2
                 USE_ICLK2       => 1,    -- use external ICLK2 input
                 ACTIVITY_LENGTH => 15,
                 FIFODEPTH       => 64,
                 LOG2DEPTH       => 6,
                 FULLMARGIN      => 16)
    port map (POWER_UP_RST_N => LSC_RST_N,
              UD             => UD,
              URESET_N       => URESET_N,
              UTEST_N        => UTEST_N,
              UCTRL_N        => UCTRL_N,
              UWEN_N         => UWEN_N,
              UCLK           => UCLK,
              LFF_N          => LFF_N,
              LRL            => LRL,
              LDOWN_N        => LDOWN_N,
              TESTLED_N      => TESTLED_N,
              LDERRLED_N     => LDERRLED_N,
              LUPLED_N       => LUPLED_N,
              FLOWCTLLED_N   => FLOWCTLLED_N,
              ACTIVITYLED_N  => ACTIVITYLED_N,
              XCLK           => TLK_GTXCLK,
			  ICLK2_IN		 => ICLK2_IN,
              ENABLE         => TLK_ENABLE,
              TXD            => TLK_TXD,
              TX_EN          => TLK_TXEN,
              TX_ER          => TLK_TXER,
              RXD            => TLK_RXD,
              RX_CLK         => TLK_RXCLK,
              RX_ER          => TLK_RXER,
              RX_DV          => TLK_RXDV,
              
              ILA_DATA_SUBSET(68 downto 59) => tlk_sync_fsm,                 --from TLK EMU
              ILA_DATA_SUBSET(70 downto 69) => GTX0_RXCHARISCOMMA_IN,        --from GTP 
			  ILA_DATA_SUBSET(72 downto 71) => GTX0_RXCHARISK_IN,            --from GTP
			  ILA_DATA_SUBSET(74 downto 73) => GTX0_RXDISPERR_IN,            --from GTP
			  ILA_DATA_SUBSET(76 downto 75) => GTX0_RXNOTINTABLE_IN,         --from GTP
			  ILA_DATA_SUBSET(78 downto 77) => GTX0_RXRUNDISP_IN,            --from GTP
			  ILA_DATA_SUBSET(79)           => GTX0_RXBYTEISALIGNED_IN,      --from GTP
			  ILA_DATA_SUBSET(80)           => GTX0_RXBYTEREALIGN_IN,        --from GTP
			  ILA_DATA_SUBSET(81)           => GTX0_RXCOMMADET_IN,           --from GTP
              ILA_DATA_SUBSET(82)           => GTX0_RXENMCOMMAALIGN_OUT_aux, --from TLK
              ILA_DATA_SUBSET(83)           => GTX0_RXRESET_OUT_aux,         --from TLK WRAPPER
              ILA_DATA_SUBSET(84)           => GTX0_RXPLLLKDET_IN,           --from RX FB PLL
              
              ILA_DATA_SUBSET(86 downto 85) => GTX0_TXCHARISK_OUT_aux,       --from TLK EMU to GTP
              ILA_DATA_SUBSET(88 downto 87) => GTX0_TXRUNDISP_IN,            --from GTP
              ILA_DATA_SUBSET(89)           => GTX0_TXRESET_OUT_aux,         --from TLK WRAPPER
              ILA_DATA_SUBSET(90)           => GTX0_TXPLLLKDET_IN,           --from TX FB PLL
              ILA_DATA_SUBSET(106 downto 91)=> GTX0_RXDATA_IN,
              ILA_DATA_SUBSET(107)          => GTX0_RXLOSSOFSYNC_IN(0),
              ILA_DATA_SUBSET(108)          => GTX0_RXLOSSOFSYNC_IN(1),
              
              ILA_DATA_SUBSET(158 downto 109)=> (others => '0'),
              
              ILA_TRIG_SUBSET(0)             => tlk_is_sync,
              ILA_TRIG_SUBSET(3 downto 1)    => (others => '0'),
              
              ILA_CONTROL    => ILA_CONTROL);

  tlk_wrapper_spt6_1 : entity work.tlk_wrapper_spt6
--    generic map (SIM_GTXRESET_SPEEDUP => SIMULATION)
    port map (GTX_RESET     		=> SYS_RST,  -- Reset the GTX on power-up
              GTX_RESETDONE_IN	=> GTX_RESETDONE_IN,
				  GTX_RESETDONE_OUT 	=> RESETDONE,
              TLK_GTXCLK    		=> TLK_GTXCLK,
              TLK_TXD       		=> TLK_TXD,
              TLK_TXEN      		=> TLK_TXEN,
              TLK_TXER      		=> TLK_TXER,
              TLK_RXCLK     		=> TLK_RXCLK,
              TLK_RXD       		=> TLK_RXD,
              TLK_RXDV      		=> TLK_RXDV,
              TLK_RXER      		=> TLK_RXER,
				GTX0_LOOPBACK_OUT			=> GTX0_LOOPBACK_OUT,
				GTX0_RXCHARISCOMMA_IN		=> GTX0_RXCHARISCOMMA_IN,	
				GTX0_RXCHARISK_IN       	=> GTX0_RXCHARISK_IN,	
				GTX0_RXDISPERR_IN       	=> GTX0_RXDISPERR_IN,
				GTX0_RXNOTINTABLE_IN    	=> GTX0_RXNOTINTABLE_IN,
				GTX0_RXRUNDISP_IN       	=> GTX0_RXRUNDISP_IN,
				GTX0_RXBYTEISALIGNED_IN 	=> GTX0_RXBYTEISALIGNED_IN,
				GTX0_RXBYTEREALIGN_IN   	=> GTX0_RXBYTEREALIGN_IN,
				GTX0_RXCOMMADET_IN      	=> GTX0_RXCOMMADET_IN,
				GTX0_RXENMCOMMAALIGN_OUT  	=> GTX0_RXENMCOMMAALIGN_OUT_aux,
				GTX0_RXENPCOMMAALIGN_OUT  	=> GTX0_RXENPCOMMAALIGN_OUT,
                --GTX0_RXLOSSOFSYNC_IN        => GTX0_RXLOSSOFSYNC_IN,
				GTX0_RXDATA_IN          	=> GTX0_RXDATA_IN,
				GTX0_RXRECCLK_IN        	=> GTX0_RXRECCLK_IN,
				GTX0_RXRESET_OUT          	=> GTX0_RXRESET_OUT_aux,
				GTX0_TXPLLLKDET_IN      	=> GTX0_TXPLLLKDET_IN,
				GTX0_RXPLLLKDET_IN      	=> GTX0_RXPLLLKDET_IN,
				GTX0_TXCHARISK_OUT        	=> GTX0_TXCHARISK_OUT_aux,
				GTX0_TXRUNDISP_IN       	=> GTX0_TXRUNDISP_IN,
				GTX0_TXDATA_OUT           	=> GTX0_TXDATA_OUT,
				GTX0_TXUSRCLK2_IN        	=> GTX0_TXUSRCLK2_IN,
				GTX0_TXRESET_OUT          	=> GTX0_TXRESET_OUT_aux,
                TLK_SYNC_FSM                => tlk_sync_fsm,
                IS_SYNC                     => tlk_is_sync
				);

                --
                GTX0_RXENMCOMMAALIGN_OUT <= GTX0_RXENMCOMMAALIGN_OUT_aux;
                GTX0_RXRESET_OUT         <= GTX0_RXRESET_OUT_aux;
                GTX0_TXCHARISK_OUT       <= GTX0_TXCHARISK_OUT_aux;
                GTX0_TXRESET_OUT         <= GTX0_TXRESET_OUT_aux;
                
  -----------------------------------------------------------------------------
  -- Resets
  -----------------------------------------------------------------------------
  -- Hold the LSC core in reset until the GTX is initialized
  LSC_RST_N <= not SYS_RST and RESETDONE;
  
  INT_RESETDONE <= RESETDONE;
  
end architecture structure;
