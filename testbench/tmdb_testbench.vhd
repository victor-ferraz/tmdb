library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
--use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
--use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).
--use ieee.std_logic_signed.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as signed integers (used together with std_logic_unsigned is ambiguous).
--use ieee.numeric_std.all;		    -- altenative to std_logic_arith, used for maths too (will conflict with std_logic_arith if 'signed' is used in interfaces).

--use work.functions_pkg.all;
use work.mfpgaif_pkg.all;

entity tmdb_testbench is
end tmdb_testbench;


architecture testbench of tmdb_testbench is

--
-- ADC Emu
    component ADCemu
    port
    (
        clk         : in        std_logic;
        data        : out       std_logic_vector(7 downto 0)
    );
    end component;  
    
--
-- L1A Emu
    component L1Aemu
    port
    (
        clk         : in       std_logic;
        data        : in       std_logic_vector(7 downto 0);
        l1a         : out      std_logic;
        bCnt        : out      std_logic_vector(11 downto 0);
        bCntStr     : out      std_logic;
        evCntLStr   : out      std_logic;
        evCntHStr   : out      std_logic
    );
    end component;  

--
-- VME Stimulus
	
	component vme_stimulus
	port 
	(
		clock        : in     	std_logic;
		vme_addr     : buffer 	std_logic_vector(31 downto 1);
		vme_am       : out    	std_logic_vector(5 downto 0);
		vme_as       : buffer 	std_logic;
		vme_berr     : inout  	std_logic;
		vme_data     : inout  	std_logic_vector(31 downto 0);
		vme_ds0      : buffer 	std_logic;
		vme_ds1      : buffer 	std_logic;
		vme_dtack    : inout  	std_logic;
		vme_ga       : out    	std_logic_vector(4 downto 0);
		vme_gap      : out    	std_logic;
		vme_iack     : buffer 	std_logic;
		vme_iack_in  : buffer 	std_logic;
		vme_iack_out : in     	std_logic;
		vme_irq      : in     	std_logic_vector(7 downto 1);
		vme_retry    : in     	std_logic;
		vme_sysclock : out    	std_logic;
		vme_sysreset : out    	std_logic;
		vme_write    : buffer 	std_logic;
		vme_lword    : out    	std_logic
	);
	end component;
	
--
-- VME FPGA

	component tmdb_vme
	port
	(			
		-------------
		-- VME bus --
		-------------
		vme_add 	: in  		std_logic_vector(31 downto 1);-- 'vmeif' OK : VME Address Bus
		vme_oea		: out  		std_logic;-- 'vmeif' OK ('vme_xbuf_addrle') : VME Address Bus Enable
				
		vme_data	: inout 	std_logic_vector(31 downto 0);-- 'vmeif' OK : VME Data Bus
		vme_oed		: out  		std_logic;-- 'vmeif' OK ('vme_xbuf_dataoe') : VME Data Bus Enable
		vme_dird	: out  		std_logic;-- 'vmeif' OK ('vme_xbuf_datadir'):VME Data Bus Direction
		
		vme_gap 	: in  		std_logic;-- 'vmeif' OK						: VME Geographical Address Parity
		vme_ga 		: in  		std_logic_vector(4 downto 0);-- 'vmeif' OK	: VME Geographical Address
		
		vme_dtack	: out 		std_logic;-- 'vmeif' OK						:  VME Data Transfer Acknowledge
		vme_oetack	: out 		std_logic;-- 'vmeif' OK ('vme_xbuf_dtackoe'): VME Data Transfer Acknowledge Output Enable
		vme_vack	: in  		std_logic;-- 'vmeif' OK						:  VME Data Transfer Acknowledge Read Value
		
		vme_as 		: in  		std_logic;-- 'vmeif' OK						:  VME Address Strobe
		vme_lw 		: in  		std_logic;-- 'vmeif' OK ('vme_lword')		:  VME Long Word
		vme_wr 		: in  		std_logic;-- 'vmeif' OK ('vme_write')		:  VME Read/Write
		vme_ds0 	: in  		std_logic;-- 'vmeif' OK						:  VME Data Strobe 0
		vme_ds1 	: in  		std_logic;-- 'vmeif' OK						:  VME Data Strobe 1
		vme_am 		: in  		std_logic_vector(5 downto 0);-- 'vmeif' OK	:  VME Address Modifier
		vme_sysrst	: in  		std_logic;-- 'vmeif' OK ('vme_sysreset')	:  VME System Reset
		vme_sysclk	: in  		std_logic;-- 'vmeif' OK ('vme_sysclock')	:  VME System Clock
		
		vme_iack	: in  		std_logic;-- 'vmeif' OK						:  VME Interrupt Acknowledge
		vme_iackin	: in  		std_logic;-- 'vmeif' OK ('vme_iack_in')		:  VME Interrupt Acknowledge Daisy-Chain Input
		vme_iackout	: out		std_logic;-- 'vmeif' OK ('vme_iack_out')	:  VME Interrupt Acknoweldge Daisy-Chain Output
		vme_irq		: out		std_logic_vector(7 downto 1);-- 'vmeif' OK	:  VME Interrupt Request
		
		vme_berr	: out  		std_logic;-- 'vmeif' OK						:  VME Bus Error
		vme_verr	: in  		std_logic;-- 'vmeif' OK						:  VME Bus Error Read Value
						
		----------------
		-- CLK system --
		----------------
		clk40M 		: in  		std_logic;
		
		---------------
		-- DTACK LED --
		---------------
		dtack_led	: out		std_logic;
		
		----------------------------------
		-- FPGA communication Interface --
		----------------------------------
		fi_addr		: out		std_logic_vector((fi_addr_width-1) downto 0);
		fi_data		: inout		std_logic_vector((fi_edata_width-1) downto 0);
		fi_write	: inout		std_logic;
		fi_read		: inout		std_logic;

		-----------------
		-- Test Points --
		-----------------
		
		t1_a		: out		std_logic;
		t1_b		: out		std_logic
	);
	end component;
	
--
-- CORE FPGA
	
	component tmdb_core
	port
	(
		-- Clock Inputs
		clk_in		    : in	std_logic;
        
        -- Clock Outputs
        clk_out         : out   std_logic_vector(15 downto 0);
        
        -- ADC Interface
        adc_in          : in    std_logic_vector(255 downto 0);
        
        -- LVDS Connectores
        lvdsL_conn      : inout std_logic_vector(15 downto 0);
        lvdsL_TXlo      : out   std_logic;
        lvdsL_TXhi      : out   std_logic;
        lvdsR_conn      : inout std_logic_vector(15 downto 0);
        lvdsR_TXlo      : out   std_logic;
        lvdsR_TXhi      : out   std_logic;
        
        -- TTC
        ttc_bcnt        : in    std_logic_vector(11 downto 0);
        ttc_bcntstr     : in    std_logic;
        ttc_bcntres     : in    std_logic;
        ttc_l1accept    : in    std_logic;
        ttc_evcntres    : in    std_logic;
        ttc_evcntlstr   : in    std_logic;
        ttc_evcnthstr   : in    std_logic;
        
        -- External Oscillator for LANE 0
        TILE0_GTP1_REFCLK_PAD_N_IN  : in std_logic;
        TILE0_GTP1_REFCLK_PAD_P_IN  : in std_logic;
        
        -- SFT enable outputs
        SFP_ENABLE      : out   std_logic_vector(3 downto 0);
        
        -- Transceiver I/Os
        RXN_IN          : in    std_logic;
        RXP_IN          : in    std_logic;
        TXN_OUT         : out   std_logic_vector(3 downto 0);
        TXP_OUT         : out   std_logic_vector(3 downto 0);
				
		-- FPGA communication Interface
		fi_addr		    : in	std_logic_vector((fi_addr_width-1) downto 0);
		fi_data		    : inout	std_logic_vector((fi_edata_width-1) downto 0);
		fi_write	    : inout	std_logic;
		fi_read		    : inout	std_logic
	);
	end component;
	
-------------------------------------------------------------------------------	
	
--
-- 
    constant adc_channels   : integer := 32;
    constant adc_dw         : integer := 8;
    
--
-- Signals

	-- VME Bus Emulation signals
	signal vme_addr     : std_logic_vector(31 downto 1);
	signal vme_am       : std_logic_vector(5 downto 0);
	signal vme_as       : std_logic;
	signal vme_berr     : std_logic;
	signal vme_data     : std_logic_vector(31 downto 0);
	signal vme_ds0      : std_logic;
	signal vme_ds1      : std_logic;
	signal vme_dtack    : std_logic;
	signal vme_ga       : std_logic_vector(4 downto 0);
	signal vme_gap      : std_logic;
	signal vme_iack     : std_logic;
	signal vme_iack_in  : std_logic;
	signal vme_iack_out : std_logic;
	signal vme_irq      : std_logic_vector(7 downto 1);
	signal vme_retry    : std_logic;
	signal vme_sysclock : std_logic;
	signal vme_sysreset : std_logic;
	signal vme_write    : std_logic;
	signal vme_lword    : std_logic;

	-- Clock @ 40 MHz
	signal clk40M		: std_logic;
	
	-- Clock @ 40 MHz + 5 ns phase
	signal clk40Md		: std_logic;
	
	-- Communication between FPGAs
	signal fi_addr		: std_logic_vector((fi_addr_width-1) downto 0);
	signal fi_data		: std_logic_vector((fi_edata_width-1) downto 0);
	signal fi_write		: std_logic;
	signal fi_read		: std_logic;
    
    -- ADC
    signal adc_data     : std_logic_vector(7 downto 0);
    signal adc_in       : std_logic_vector(adc_dw*adc_channels-1 downto 0);
    
    -- L1A
    signal l1a          : std_logic;
    signal bCnt         : std_logic_vector(11 downto 0);
    signal bCntStr      : std_logic;
    signal evCntLStr    : std_logic;
    signal evCntHStr    : std_logic;
    
-------------------------------------------------------------------------------	

begin

    --
    -- VME Stimulus Map

	vmeBus_emulation:
	vme_stimulus port map
	(
		clock        => clk40M,
		vme_addr     =>	vme_addr,
		vme_am       => vme_am,
		vme_as       => vme_as,
		-- Parece que o vmeif deixa o vme_berr o tempo todo em '0'. 
		-- Isso faz como que o vme_stimulus (emulação do bus) pense que há um erro no bus.
		vme_berr     => open, --vme_berr,
		vme_data     => vme_data,
		vme_ds0      => vme_ds0,
		vme_ds1      => vme_ds1,
		vme_dtack    => vme_dtack,
		vme_ga       => vme_ga,
		vme_gap      => vme_gap,
		vme_iack     => vme_iack,
		vme_iack_in  => vme_iack_in,
		vme_iack_out => vme_iack_out,
		vme_irq      => vme_irq,
		vme_retry    => 'Z',			-- not used
		vme_sysclock => vme_sysclock,
		vme_sysreset => vme_sysreset,
		vme_write    => vme_write,
		vme_lword    => vme_lword
	);

    --
    -- VME FPGA Map
	
	vme_fpga:
	tmdb_vme port map
	(			
		-------------
		-- VME bus --
		-------------
		vme_add 	=> vme_addr,
		vme_oea		=> open,			-- controls hardware
				
		vme_data	=> vme_data,
		vme_oed		=> open,			-- controls hardware
		vme_dird	=> open,			-- controls hardware
		
		vme_gap 	=> vme_gap,
		vme_ga 		=> vme_ga,
		
		vme_dtack	=> vme_dtack,
		vme_oetack	=> open,
		vme_vack	=> '1',				-- '1' means ack ok
		
		vme_as 		=> vme_as,
		vme_lw 		=> vme_lword,
		vme_wr 		=> vme_write,
		vme_ds0 	=> vme_ds0,
		vme_ds1 	=> vme_ds1,
		vme_am 		=> vme_am,
		vme_sysrst	=> vme_sysreset,
		vme_sysclk	=> vme_sysclock,
		
		vme_iack	=> vme_iack,
		vme_iackin	=> vme_iack_in,
		vme_iackout	=> vme_iack_out,
		vme_irq		=> vme_irq,
		
		vme_berr	=> vme_berr,
		vme_verr	=> '1',				-- '1' means no error
						
		----------------
		-- CLK system --
		----------------
		clk40M 		=> clk40M,
		
		---------------
		-- DTACK LED --
		---------------
		dtack_led	=> open,
		
		----------------------------------
		-- FPGA communication Interface --
		----------------------------------
		fi_addr		=> fi_addr,
		fi_data		=> fi_data,
		fi_write	=> fi_write,
		fi_read		=> fi_read,

		-----------------
		-- Test Points --
		-----------------
		
		t1_a		=> open,
		t1_b		=> open
	);
	
    --
    -- Pull-Ups/Pull-Downs
	fi_write	<= 'L';
	fi_read		<= 'L';

    --
    -- CORE FPGA Map
	core_fpga:
	tmdb_core port map
	(
		-- Clock Inputs
		clk_in		    => clk40Md,
       -- Clock Outputs
        clk_out         => open,
        
        -- ADC Interface
        adc_in          => adc_in,
        
        -- LVDS Connectores
        lvdsL_conn      => open,
        lvdsL_TXlo      => open,
        lvdsL_TXhi      => open,
        lvdsR_conn      => open,
        lvdsR_TXlo      => open,
        lvdsR_TXhi      => open,
        
        -- TTC
        ttc_bcnt        => bCnt,
        ttc_bcntstr     => bCntStr,
        ttc_bcntres     => '0',
        ttc_l1accept    => '1', --l1a,
        ttc_evcntres    => '0',
        ttc_evcntlstr   => evCntLStr,
        ttc_evcnthstr   => evCntHStr,
        
        -- External Oscillator for LANE 0
        TILE0_GTP1_REFCLK_PAD_N_IN  => '0',
        TILE0_GTP1_REFCLK_PAD_P_IN  => '0',
        
        -- SFT enable outputs
        SFP_ENABLE      => open,
        
        -- Transceiver I/Os
        RXN_IN          => '0',
        RXP_IN          => '0',
        TXN_OUT         => open,
        TXP_OUT         => open,
        
		-- FPGA communication Interface
		fi_addr		    => fi_addr,
		fi_data		    => fi_data,
		fi_write	    => fi_write,
		fi_read		    => fi_read
	);

    --
    -- ADCemu map
    ADCemu_i:
    ADCemu port map
    (
        clk             => clk40Md,
        data            => adc_data
        
    );
    
    adc_in_bus:
    for i in 0 to (adc_channels-1) generate
        adc_in(adc_dw*i+adc_dw-1 downto adc_dw*i) <= adc_data;
    end generate adc_in_bus;

    --
    -- L1Aemu map
    L1Aemu_i:
    L1Aemu port map
    (
        clk             => clk40Md,
        data            => adc_data,
        l1a             => l1a,
        bCnt            => bCnt,
        bCntStr         => bCntStr,
        evCntLStr       => evCntLStr,
        evCntHStr       => evCntHStr
        
    );

-------------------------------------------------------------------------------	
	
--
-- Stimulus

	-- clk @ 40 MHz
	clk40M_gen: process
	begin
	loop
		clk40M	<= '0';
		wait for 12.5 ns;
		clk40M	<= '1';
		wait for 12.5 ns;
		-- if (now >= 1000000 ps) then wait; end if;
	end loop;
	end process clk40M_gen;
	
	-- clk @ 40 MHz + 5 ns phase
	clk40Md_gen: process
	begin
		wait for 1 ns;
	loop
		clk40Md	<= '0';
		wait for 12.5 ns;
		clk40Md	<= '1';
		wait for 12.5 ns;
		-- if (now >= 1000000 ps) then wait; end if;
	end loop;
	end process clk40Md_gen;
    	
-------------------------------------------------------------------------------	

end testbench;

