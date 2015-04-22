--------------------------------------------------------------------------------
-- Institutions:	UFRJ - Federal University of Rio de Janeiro
--						UFJF - Federal Univesity of Juiz de Fora
-- Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
--					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
--					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
--
-- Create Date: 13/03/2015
-- Design Name: tmdb_core
-- Module Name: cRegs
-- Target Device: Spartan-6 XC6SLX150T-FGG676
-- Tool versions: Xilinx ISE Design Suite 14.7
-- Description:
-- 	
-- Dependencies:
-- 
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--use ieee.numeric_std.all;

use work.cRegs_pkg.all;
use work.cRegs_usr.all;
use work.functions_pkg.all;			-- Misc. functions

entity cRegs is

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

end entity;

architecture rtl of cRegs is

	signal		c_addrStb	: std_logic_vector((num_regs-1) downto 0) := (others => '0');
	signal		c_decWr		: std_logic_vector((num_regs-1) downto 0) := (others => '0');
	signal		c_decRd		: std_logic_vector((num_regs-1) downto 0) := (others => '0');
	signal		r_decWr		: std_logic_vector((num_regs-1) downto 0) := (others => '0');
	signal		r_decRd		: std_logic_vector((num_regs-1) downto 0) := (others => '0');
	signal		encoded_read: std_logic_vector((NumBits(num_regs)-1) downto 0) := (others => '0');
	signal		r_enc_read	: std_logic_vector((NumBits(num_regs)-1) downto 0) := (others => '0');

	signal		regs	    :	SYS_REGS := (others => (others => '0'));
	signal 		locked	    :	std_logic_vector((num_regs-1) downto 0) := (others => '0');


begin

	-- Page Register have a special address decoding
    page_reg_addr_decoder:
    c_addrStb(0)    <= '1' when (addr(5 downto 0) = 
                                system_regs_enum(0).addr(5 downto 0)) else '0';
	
    -- Address Decoding
    addr_decoder:
	for i in 1 to (num_regs - 1) generate
        c_addrStb(i)	<= '1' when	(addr = system_regs_enum(i).addr) else '0';
	end generate addr_decoder;
    
    -- Read and Write Strobes
    rw_strobes:
    for i in 0 to (num_regs - 1) generate
        c_decWr(i)		<= '1' when ((c_addrStb(i) = '1') 
                                and (write = '1')) else '0';
        c_decRd(i)		<= '1' when ((c_addrStb(i) = '1') 
                                and (read = '1')) else '0';
        -- Strobe Registers
        --strobe_regs:
        --process (clk, rst)
        --begin
        --    if (rst = '1') then
        --        r_decWr(i)	<= '0';
        --        r_decRd(i)	<= '0';
        --    elsif (rising_edge(clk)) then
                r_decWr(i)	<= c_decWr(i);
                r_decRd(i)	<= c_decRd(i);
        --    end if;
        --end process;
	end generate rw_strobes;

	-- Read Encoder
	read_encoder:
	process(c_decRd)
	begin
		for i in 0 to (num_regs-1) loop
			if c_decRd(i) = '1' then
				encoded_read <= std_logic_vector(
					conv_unsigned(i, NumBits(num_regs)));
				exit;
			end if;
			encoded_read <= (others => '0');
		end loop;
	end process;
	
    -- Encoded Read Register
	encoded_read_reg:
	process (clk, rst)
	begin
		if (rst = '1') then
			r_enc_read	<= (others => '0');
		elsif (rising_edge(clk)) then
			r_enc_read	<= encoded_read;
		end if;
	end process;

	-- Read Data MUX
	read_data_multiplexer: 
	oData	<= regs(conv_integer(r_enc_read));
	
	---------------------------------------------------------------------------

	-- Register Construct 
	r_construct:
	for i in 0 to (num_regs - 1) generate

		rType_test:
		if (system_regs_enum(i).peripheral = false) generate	
															
			rWritable_test:
			if (system_regs_enum(i).writable = true) generate
                
                -- Register itself
				rHold_ffs:
				process(clk, rst)							
				begin
					if (rst = '1') then
						regs(i)		<= system_regs_enum(i).rstState;
						locked(i)	<= '0';
						
					elsif(rising_edge(clk)) then
						if ((r_decWr(i) = '1') and (locked(i) = '0')) then	-- 'locked' ensures one write per rising edge of 'r_decWr'.
							regs(i)		<= iData;
							locked(i)	<= '1';
						elsif (r_decWr(i) = '0') then
							locked(i)	<= '0';
						end if;

					end if;
				end process;
			end generate rWritable_test;
            
            -- Data: Register -> Controller Interface
            r_output:
            --oReg(i)	<= regs(i);
            oReg(i*regs_data_width+regs_data_width-1 downto 
                i*regs_data_width) <= regs(i);
            
		end generate rType_test;
	end generate r_construct;
	

    
	---------------------------------------------------------------------------

	-- Peripheral Construct
	p_construct:
	for i in 0 to (num_regs - 1) generate

		pType_test:
		if (system_regs_enum(i).peripheral = true) generate	
															
			pWritable_test:
			if (system_regs_enum(i).writable = true) generate
				
                -- Data: Controller Interface -> Peripheral
				input_to_peripheral:
				--oReg(i)	<= iData;
                oReg(i*regs_data_width+regs_data_width-1 downto 
                    i*regs_data_width) <= iData;
				
                -- Peripheral Write Strobe
				wrStb_to_peripheral:
				pWrite(i) <= r_decWr(i);
				
			end generate pWritable_test;
			
			pReadable_test:
			if (system_regs_enum(i).readable = true) generate
                
                -- Peripheral Read Strobe
				rdStb_to_peripheral:
				pRead(i) <= r_decRd(i);
                
                -- Data: Peripheral -> Controller Interface
                -- iReg is directly connected to oData thru regs(i)
                regs(i) <= iReg(i*regs_data_width+regs_data_width-1 downto
                                    i*regs_data_width);
                
			end generate pReadable_test;
						
		end generate pType_test;
	end generate p_construct;

	---------------------------------------------------------------------------
--
--	
end rtl;
