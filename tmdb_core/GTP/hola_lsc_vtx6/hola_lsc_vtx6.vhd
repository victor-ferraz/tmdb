-------------------------------------------------------------------------------
-- Title      : HOLA LSC implementation with on-chip SERDES for Virtex-6
-- Project    : S-LINK
-------------------------------------------------------------------------------
-- File       : hola_lsc_vtx6.vhd
-- Author     : Stefan Haas
-- Company    : CERN PH-ATE
-- Created    : 24-11-11
-- Last update: 2011-12-14
-- Platform   : Windows XP
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 CERN PH-ATE
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 24-11-11  1.0      haass     Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity hola_lsc_vtx6 is

  generic (SIMULATION : integer := 0);

  port (MGTREFCLK_P     : in  std_logic;  -- MGT reference clock input,
        MGTREFCLK_N     : in  std_logic;  -- should be 125 MHz in the current configuration.
        SYS_RST         : in  std_logic;
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
        -- SFP serial interface
        TLK_SIN_P       : in std_logic;   -- GTX serial input 
        TLK_SIN_N       : in std_logic;
        TLK_SOUT_P      : out std_logic;  -- GTX serial output
        TLK_SOUT_N      : out std_logic;
        -- LEDs
        TESTLED_N       : out std_logic;
        LDERRLED_N      : out std_logic;
        LUPLED_N        : out std_logic;
        FLOWCTLLED_N    : out std_logic;
        ACTIVITYLED_N   : out std_logic);

end entity hola_lsc_vtx6;

-------------------------------------------------------------------------------

architecture structure of hola_lsc_vtx6 is

  signal LSC_RST_N     : std_logic;
  signal GTX_RESETDONE : std_logic;
  signal TLK_GTXCLK    : std_logic;
  signal TLK_TXD       : std_logic_vector(15 downto 0);
  signal TLK_TXEN      : std_logic;
  signal TLK_TXER      : std_logic;
  signal TLK_RXCLK     : std_logic;
  signal TLK_RXD       : std_logic_vector(15 downto 0);
  signal TLK_RXDV      : std_logic;
  signal TLK_RXER      : std_logic;
  signal TLK_ENABLE    : std_logic;
  
begin  -- architecture structure

  holalsc_core_1 : entity work.holalsc_core
    generic map (SIMULATION      => SIMULATION,
                 ALTERA_XILINX   => 0,    -- XILINX
                 XCLK_FREQ       => 100,  -- XCLK = 100 MHz
                 USE_PLL         => 0,    -- Do not use PLL to generate ICLK_2
                 USE_ICLK2       => 0,    -- use external ICLK2 input
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
              ENABLE         => TLK_ENABLE,
              TXD            => TLK_TXD,
              TX_EN          => TLK_TXEN,
              TX_ER          => TLK_TXER,
              RXD            => TLK_RXD,
              RX_CLK         => TLK_RXCLK,
              RX_ER          => TLK_RXER,
              RX_DV          => TLK_RXDV);

  tlk_wrapper_vtx6_1 : entity work.tlk_wrapper_vtx6
    generic map (SIM_GTXRESET_SPEEDUP => SIMULATION)
    port map (MGTREFCLK_P   => MGTREFCLK_P,
              MGTREFCLK_N   => MGTREFCLK_N,
              GTX_RESET     => SYS_RST,  -- Reset the GTX on power-up
              GTX_RESETDONE => GTX_RESETDONE,
              GTX_RXN       => TLK_SIN_N,
              GTX_RXP       => TLK_SIN_P,
              GTX_TXN       => TLK_SOUT_N,
              GTX_TXP       => TLK_SOUT_P,
              TLK_GTXCLK    => TLK_GTXCLK,
              TLK_TXD       => TLK_TXD,
              TLK_TXEN      => TLK_TXEN,
              TLK_TXER      => TLK_TXER,
              TLK_RXCLK     => TLK_RXCLK,
              TLK_RXD       => TLK_RXD,
              TLK_RXDV      => TLK_RXDV,
              TLK_RXER      => TLK_RXER);

  -----------------------------------------------------------------------------
  -- Resets
  -----------------------------------------------------------------------------
  -- Hold the LSC core in reset until the GTX is initialized
  LSC_RST_N <= not SYS_RST and GTX_RESETDONE;
               
end architecture structure;
