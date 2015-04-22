------------------------------------------------------------------------------
-- TOP!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.vmeif_pkg.all;
use work.vmeif_usr.all;
use work.vRegs_pkg.all;
use work.vRegs_usr.all;
use work.mfpgaif_pkg.all;
use work.functions_pkg.all;			-- Misc. functions


entity tmdb_vme is 
	port
	(	
		-------------
		--   TTC   --
		-------------
		
		signal ttc_status_1		:in  		std_logic;
		signal ttc_status_2		:in  		std_logic;
		signal ttc_DQ				:in   	std_logic_vector(3 downto 0);
		signal ttc_DoutStr		:in  		std_logic;
		signal ttc_SinErrStr		:in  		std_logic;
		signal ttc_DbErrStr		:in  		std_logic;
		signal ttc_BrcstStr1		:in  		std_logic;
		signal ttc_BrcstStr2		:in  		std_logic;
		signal ttc_Brcst			:in  		std_logic_vector(5 downto 0);
		signal ttc_Ser_B_Ch		:in  		std_logic;
		
		signal ttc_PD				:out  	std_logic;
		signal ttc_clk_sel		:out  	std_logic;
		signal ttc_jtag_rst_b	:out  	std_logic;
	   signal ttc_subaddr		:out  	std_logic_vector(7 downto 0);
		signal ttc_Dout			:out  	std_logic_vector(7 downto 0);
		signal ttc_reset_b		:out  	std_logic;    
		signal ttc_SDA				:out  	std_logic;
		signal ttc_SCL				:out  	std_logic;
		
		-------------
		-- VME bus --
		-------------
		signal vme_add 		:in  		std_logic_vector(31 downto 1);-- 'vmeif' OK :VME Address Bus
		signal vme_oea		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_addrle') :VME Address Bus Enable
				
		signal vme_data		:inout 		std_logic_vector(31 downto 0);-- 'vmeif' OK :VME Data Bus
		signal vme_oed		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_dataoe') :VME Data Bus Enable
		signal vme_dird		:out  		std_logic;-- 'vmeif' OK ('vme_xbuf_datadir'):VME Data Bus Direction
		
		signal vme_gap 		:in  		std_logic;-- 'vmeif' OK						:VME Geographical Address Parity
		signal vme_ga 		:in  		std_logic_vector(4 downto 0);-- 'vmeif' OK	:VME Geographical Address
		
		signal vme_dtack	:out 		std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge
		signal vme_oetack	:out 		std_logic;-- 'vmeif' OK ('vme_xbuf_dtackoe'): VME Data Transfer Acknowledge Output Enable
		signal vme_vack		:in  		std_logic;-- 'vmeif' OK						: VME Data Transfer Acknowledge Read Value
		
		signal vme_as 		:in  		std_logic;-- 'vmeif' OK						: VME Address Strobe
		signal vme_lw 		:in  		std_logic;-- 'vmeif' OK ('vme_lword')		: VME Long Word
		signal vme_wr 		:in  		std_logic;-- 'vmeif' OK ('vme_write')		: VME Read/Write
		signal vme_ds0 		:in  		std_logic;-- 'vmeif' OK						: VME Data Strobe 0
		signal vme_ds1 		:in  		std_logic;-- 'vmeif' OK						: VME Data Strobe 1
		signal vme_am 		:in  		std_logic_vector(5 downto 0);-- 'vmeif' OK	: VME Address Modifier
		signal vme_sysrst	:in  		std_logic;-- 'vmeif' OK ('vme_sysreset')	: VME System Reset
		signal vme_sysclk	:in  		std_logic;-- 'vmeif' OK ('vme_sysclock')	: VME System Clock
		
		signal vme_iack		:in  		std_logic;-- 'vmeif' OK						: VME Interrupt Acknowledge
		signal vme_iackin	:in  		std_logic;-- 'vmeif' OK ('vme_iack_in')		: VME Interrupt Acknowledge Daisy-Chain Input
		signal vme_iackout	:out		std_logic;-- 'vmeif' OK ('vme_iack_out')	: VME Interrupt Acknoweldge Daisy-Chain Output
		signal vme_irq		:out		std_logic_vector(7 downto 1);-- 'vmeif' OK	: VME Interrupt Request
		
		signal vme_berr		:out  		std_logic;-- 'vmeif' OK						: VME Bus Error
		signal vme_verr		:in  		std_logic;-- 'vmeif' OK						: VME Bus Error Read Value
						
		----------------
		-- CLK system --
		----------------
		signal clk40M 		:in  	std_logic;
		
		---------------
		-- DTACK LED --
		---------------
		signal dtack_led	:out	std_logic;
		
		-------------------------
		-- Core FPGA Interface --
		-------------------------
		signal fi_addr		:out	std_logic_vector((fi_addr_width-1) downto 0);
		signal fi_data		:inout	std_logic_vector((fi_edata_width-1) downto 0);
		signal fi_write	:inout	std_logic;
		signal fi_read		:inout	std_logic;

		-----------------
		-- Test Points --
		-----------------
		
		signal t1_a			:out	std_logic;
		signal t1_b			:out	std_logic
	);
end tmdb_vme;

architecture rtl of tmdb_vme is

------------------------------
--**************************--
--******* COMPONENTS *******--
--**************************--
------------------------------

	-- Clock Manager
	component clkman
	port
	(	
		signal iclk				: in 	std_logic;
		 	
		signal pclk				: out	std_logic;
		signal nclk				: out	std_logic;
		signal mclk    			: out	std_logic;
		signal sclk    			: out	std_logic;
		signal clk_enable		: out	std_logic;
		signal tclk				: out	std_logic
	);
	end component;

		
	-- Reset Generator
	component rstgen
	port
	(	
		signal clk				: in 	std_logic; -- sync if
		
		signal reset			: in 	std_logic_vector(31 downto 0);
		
		signal rst				: out	std_logic := '1'
	);
	end component;


	-- VME controller developed at CERN (Per Gallno -> Herman -> Ralf)
	component vmeif
	port
	( testpin			: out	std_logic;
	  vme_addr			: in	std_logic_vector(31 downto 1);									-- VME address bus
	  vme_xbuf_addrle 	: out	std_logic;														-- VME address bus latch enable
      vme_am			: in	std_logic_vector(5 downto 0);  									-- VME address modifier code
	  vme_data			: inout	std_logic_vector(31 downto 0);									-- VME data bus
	  vme_xbuf_dataoe	: out	std_logic;														-- VME data bus output enable
	  vme_xbuf_datadir	: out	std_logic;														-- VME data bus direction
	  vme_lword			: in	std_logic;														-- VME long word
	  vme_dtack			: out	std_logic;														-- VME data transfer acknowledge
	  vme_xbuf_dtackoe	: out	std_logic;														-- VME data transfer acknowledge output enable
	  vme_vack			: in	std_logic;														-- VME data transfer acknowledge read value
	  vme_as			: in	std_logic;														-- VME address strobe
	  vme_ds0			: in	std_logic;														-- VME data strobe #0
	  vme_ds1			: in	std_logic;														-- VME data strobe #1
	  vme_write			: in	std_logic;														-- VME read/write
	  vme_iack			: in	std_logic;														-- VME interrupt acknowledge
	  vme_iack_in		: in	std_logic;														-- VME interrupt acknowledge daisy-chain input
	  vme_iack_out		: out	std_logic;														-- VME interrupt acknoweldge daisy-chain output
	  vme_irq			: out	std_logic_vector(7 downto 1);									-- VME interrupt request
	  vme_berr			: out	std_logic;														-- VME bus error
	  vme_verr			: in	std_logic;														-- VME bus error read value
	  vme_sysreset		: in	std_logic;														-- VME system reset
	  vme_sysclock		: in	std_logic;														-- VME system clock
	  vme_retry			: out	std_logic;														-- VME retry
	  vme_xbuf_retryoe	: out	std_logic;														-- VME retry output enable
	  vme_ga			: in	std_logic_vector(4 downto 0);									-- VME geographical address
	  vme_gap			: in	std_logic;														-- VME geographical address parity
	  powerup_reset		: in	std_logic := '0';												-- COM power-up reset
	  clock_40mhz		: in	std_logic;														-- COM 40 MHz clock
	  user_addr			: out	std_logic_vector(24 downto 0);									-- USR latched address bus (32-bit words)
	  user_am			: out	std_logic_vector(5 downto 0);									-- USR addres modifier
	  user_data			: inout	std_logic_vector(31 downto 0);									-- USR data bus
	  user_read			: out	std_logic_vector((NUM_USR_MAP-1) downto 0);						-- USR read strobe
	  user_write		: out	std_logic_vector((NUM_USR_MAP-1) downto 0);						-- USR vme_writeite strobe
	  user_dtack		: in	std_logic_vector((NUM_USR_MAP-1) downto 0) := (others => '0');	-- USR data transfer acknowledge
	  user_error		: in	std_logic_vector((NUM_USR_MAP-1) downto 0) := (others => '0');	-- USR error
	  user_ireq			: in	std_logic_vector((NUM_USR_IRQ-1) downto 0) := (others => '0');	-- USR interrupt request
	  user_iack			: out	std_logic_vector((NUM_USR_IRQ-1) downto 0);						-- USR interrupt acknowledge
	  user_reset		: out	std_logic_vector((NUM_USR_RST-1) downto 0);						-- USR reset	
	  user_addr_out		: out	std_logic_vector(24 downto 0);									-- USR latched address bus (32-bit words)
	  user_am_out		: out	std_logic_vector(5 downto 0);									-- USR addres modifier
	  user_data_out		: out	std_logic_vector(31 downto 0);									-- USR data bus
	  user_valid		: out	std_logic;														-- USR addr/am/data valid
	  user_data_in		: in	std_logic_vector(31 downto 0) := (others => '0'));				-- USR data bus
	end component;

	-- Registers
	component vRegs
	port
	(
		clk		: in 	std_logic; -- sync if
		rst		: in 	std_logic; -- async if
		
		-- Controller Interface
		addr	: in 	std_logic_vector(15 downto 0);
		read	: in	std_logic;
		write	: in	std_logic;
		iData	: in	std_logic_vector(31 downto 0);
		oData	: out	std_logic_vector(31 downto 0);

		-- Registers Interface (Registers's individual i/os)
		iReg	: in	std_logic_vector((num_regs*regs_data_width-1) 
                                            downto 0);
		oReg	: out	std_logic_vector((num_regs*regs_data_width-1) 
                                            downto 0);

		-- Peripherals Interface (peripherals's output strobes)
		pWrite	: out	std_logic_vector((num_regs-1) downto 0);
		pRead	: out	std_logic_vector((num_regs-1) downto 0)
	);
	end component;
	
	-- FPGA Communication Interface
	component mfpgaif
	port
	(
		-- 
		rst			: in	std_logic;
		clk			: in	std_logic;
		
		-- Internal Signals (VME User Side Interface)
		data_in		: in	std_logic_vector((fi_idata_width-1) downto 0);
		data_out	: out	std_logic_vector((fi_idata_width-1) downto 0);
		addr		: in	std_logic_vector((fi_addr_width-1) downto 0);
		read		: in	std_logic;
		write		: in	std_logic;
		dtack		: out	std_logic;
		
		-- External Interface (Core FPGA Interface)
		fi_addr		: out	std_logic_vector((fi_addr_width-1) downto 0);
		fi_data		: inout	std_logic_vector((fi_edata_width-1) downto 0);
		fi_write	: inout	std_logic;	--must be pulled down
		fi_read		: inout	std_logic	--must be pulled down
	);
	end component;
		
	
---------------------------
--***********************--
--******* SIGNALS *******--
--***********************--
---------------------------

	type USER_DATA_A is 
		array ((NUM_USR_MAP-1) downto 0) of std_logic_vector(31 downto 0);
	
	signal mrst					: std_logic;
	signal pclk, sclk, mclk		: std_logic; 
	

	-- VME
	signal i_dtack				: std_logic;
	signal user_read			: std_logic_vector((NUM_USR_MAP-1) downto 0);
	signal user_write			: std_logic_vector((NUM_USR_MAP-1) downto 0);
	signal user_dtack			: std_logic_vector((NUM_USR_MAP-1) downto 0);

	signal user_data_in			: std_logic_vector(31 downto 0);
	signal user_data_out		: std_logic_vector(31 downto 0);
	signal user_addr_out		: std_logic_vector(24 downto 0);
	
	signal user_data			: std_logic_vector(31 downto 0);
	signal user_addr			: std_logic_vector(24 downto 0);
	
	signal user_data_mux		: USER_DATA_A;
	signal encoded_read			: std_logic_vector((NumBits(NUM_USR_MAP)-1) downto 0);

	signal user_addr_temp		: std_logic_vector(15 downto 0);    
    signal iReg_temp            : std_logic_vector(
                                    (num_regs*regs_data_width-1) downto 0);
	signal oReg_temp            : std_logic_vector(
                                    (num_regs*regs_data_width-1) downto 0);	
	signal iReg					: SYS_REGS;
	signal oReg					: SYS_REGS;
	
------------------------------------------
------------------------------------------


begin
	
	-- TTC Signals
	
	ttc_clk_sel <= '1';
	ttc_PD      <= '1';
	ttc_jtag_rst_b <= '0';
	ttc_reset_b <= not (mrst);
	ttc_subaddr <= x"00";
	ttc_Dout <= x"07";
	
	-- DTACK LED
	dtack_led <= i_dtack;
	
	-- Test Points
	t1_a	<= sclk;
	t1_b	<= pclk;
	
	
	--	vme_berr		<= 'Z';
	vme_irq		<= (others => 'Z');
--	vme_oetack	<= 'Z';
--	vme_dtack	<= 'Z';
--	vme_dird	<= 'Z';
--	vme_oed		<= 'Z';
--	vme_data	<= (others => 'Z');
	vme_oea		<= '0'; --'Z';


------------------------
--********************--
--******* MAPS *******--
--********************--
------------------------

	master_rst_gen:
	rstgen port map
	(	
		clk				=> pclk,
		
		reset			=> oReg(0),
		
		rst				=> mrst
	);

	clock_manager: 
	clkman port map 
	(
		iclk				=> clk40M,
		
		pclk				=> pclk,	--40 MHz - 0	degree
		nclk				=> open,	--40 MHz - 180	degrees
		mclk				=> open,    --40 MHz
		sclk				=> sclk,    --20 MHz
		clk_enable			=> open,
		tclk				=> open
	);
			
--*****************************************************************************

	my_vmeif:
	vmeif port map (
							powerup_reset		=> mrst,
								
							user_addr			=> user_addr,
							user_data			=> user_data,
							
							user_addr_out		=> user_addr_out,
							user_data_in		=> user_data_in,
							user_data_out		=> user_data_out,
							user_read			=> user_read,
							user_write			=> user_write,
							user_dtack			=> user_dtack,
							
							vme_addr			=> vme_add,
							
							vme_am				=> vme_am,
							
							vme_data			=> vme_data,
														
							vme_xbuf_dataoe		=> vme_oed,		--
							vme_xbuf_datadir	=> vme_dird,	--
							vme_lword			=> vme_lw,
							vme_dtack			=> i_dtack, 	--vme_dtack,
							vme_xbuf_dtackoe	=> vme_oetack,	--
							vme_vack			=> vme_vack,
							vme_as				=> vme_as,
							vme_ds0				=> vme_ds0,
							vme_ds1				=> vme_ds1,
							vme_write			=> vme_wr,
							vme_iack			=> vme_iack,
							vme_iack_in			=> vme_iackin,
							vme_iack_out		=> vme_iackout,
							vme_irq				=> open,
							vme_berr			=> vme_berr,	--
							vme_verr			=> vme_verr,
							vme_sysreset		=> vme_sysrst,
							vme_sysclock		=> vme_sysclk,
							vme_ga				=> vme_ga,
							vme_gap				=> vme_gap,
							clock_40mhz			=> pclk
					);

	
	vme_dtack	<= i_dtack;
	
--*****************************************************************************

	--default values for 'ireg'
	iReg <= (others => (others => '0'));

    --array conversions
    iReg_temp <= TO_REGS_1D(iReg);
    oReg      <= TO_REGS_2D(oReg_temp);    
    
    --using only the 8 LSBs of the 'user_addr_out' to address vRegs
	user_addr_temp <= x"00" & user_addr_out(7 downto 0);
    
    vme_registers:
	vRegs port map
	(
		clk				=> pclk,
		rst				=> mrst,
		
		-- Controller Interface
		addr			=> user_addr_temp,
		write			=> user_write(0),
		read			=> user_read(0),
		iData			=> user_data_out,		
		oData			=> user_data_mux(0),
		
		-- Registers Interface (Registers's individual i/os)s
		iReg			=> iReg_temp,
		oReg			=> oReg_temp,

		-- Peripherals Interface (peripherals's output strobes)
		pWrite			=> open,
		pRead			=> open
	);
    
--*****************************************************************************
	
	-- -- FPGA communication Interface
	fpga_interface:
	mfpgaif port map
	(
		-- 
		rst			=> mrst,
		clk			=> pclk,
		
		-- Internal Signals (VME User Side Interface)
		data_in		=> user_data_out,
		data_out	=> user_data_mux(1),
		addr		=> user_addr_temp(5 downto 0),
		read		=> user_read(1),
		write		=> user_write(1),
		dtack		=> user_dtack(1),
		
		-- External Interface (Core FPGA Interface)
		fi_addr		=> fi_addr,
		fi_data		=> fi_data,
		fi_write	=> fi_write,
		fi_read		=> fi_read
		
	);
	
	-- fi_addr  <= (others => 'Z');
	-- fi_data  <= (others => 'Z');
	-- fi_write <= 'Z';
	-- fi_write <= 'Z';

--*****************************************************************************
	
	-- User Read Encoder
	user_read_encoder:
	process(user_read)
	begin
		for i in 0 to (NUM_USR_MAP-1) loop
			if user_read(i) = '1' then
				encoded_read <= std_logic_vector(
					conv_unsigned(i, NumBits(NUM_USR_MAP)));
				exit;
			end if;
			encoded_read <= (others => '0');
		end loop;
	end process;
	
	-- User Data MUX
	user_data_multiplexer: 
	user_data_in	<= user_data_mux(conv_integer(encoded_read));
	
--*****************************************************************************

end rtl;