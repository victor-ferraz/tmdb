--------------------------------------------------------------------------------
-- Institutions:	UFRJ - Federal University of Rio de Janeiro
--						UFJF - Federal Univesity of Juiz de Fora
-- Engineers:	Julio Souza Vieira		(julio.souza@cern.ch)
--					Rafael Gonçalves Gama	(rafael.gama@cern.ch)
--					Victor Araujo Ferraz		(victor.ferraz@cern.ch)
--
-- Create Date: 13/03/2015
-- Design Name: tmdb_core
-- Module Name: sfpgaif
-- Target Device: Spartan-6 XC6SLX150T-FGG676
-- Tool versions: Xilinx ISE Design Suite 14.7
-- Description:
-- 	Slave FPGA communication Interface - FI
-- Dependencies:
-- 
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

-- $ sfpgaif.vhd
-- Slave FPGA communication Interface - FI
-- v: svn controlled
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sfpgaif_pkg.all;

--

entity sfpgaif is
	port
	(
		-- 
		rst			: in	std_logic;
		clk			: in	std_logic;
		
		-- Internal Signals (VME User Side Interface)
		data_in		: in	std_logic_vector((fi_idata_width-1) downto 0);
		data_out	: out	std_logic_vector((fi_idata_width-1) downto 0);
		addr		: out	std_logic_vector((fi_addr_width-1) downto 0);
		read		: out	std_logic;
		write		: out	std_logic;
		
		-- External Interface (Core FPGA Interface)
		fi_addr		: in	std_logic_vector((fi_addr_width-1) downto 0);
		fi_data		: inout	std_logic_vector((fi_edata_width-1) downto 0);
		fi_write	: inout	std_logic;	--must be pulled down
		fi_read		: inout	std_logic	--must be pulled down
	);
end entity;

architecture rtl of sfpgaif is

--
-- Signals

--
signal		n_fi_data			: FI_DATA_T := (others => '0');
--
signal		n_fi_write			: std_logic := '0';
--
signal		n_fi_read			: std_logic := '0';
--
signal  	r_addr				: ADDR_REG_A := (others => (others => '0'));
--
--signal		write_ack			: std_logic;
--
--signal		read_ack			: std_logic;
--
type		state_values is
				(idle, write_inc_counter, write_send_ack, write_running, 
					write_write_data, read_ask_data, read_get_data, 
					read_running, read_inc_counter, read_sync, 
					read_send_ack, read_read_data, recov);
                    
signal		state               : state_values := idle; 
signal      next_state	        : state_values;

-- Xilinx Style
attribute   fsm_encoding          : string;
attribute   fsm_encoding of state : signal is "one-hot";
attribute   safe_implementation   : string;
attribute   safe_implementation of state : signal is "yes";
attribute   safe_recovery_state   : string;
attribute   safe_recovery_state of state : signal is "recov";

-- Altera Style                
--attribute 	syn_encoding		: string;
--attribute	syn_encoding of 
--				state_values	: type is "safe, one-hot";

--
signal  	word_counter_en		: std_logic := '0';

-- THIS COUNTER SHOULD START ON ZERO!
signal		word_counter		: WORD_COUNTER_T := (others => '1');
--
signal		r_data_in			: FI_DATA_IN_A := (others => (others => '0'));
--
signal		c_data				: FI_DATA_T := (others => '0');
--
signal		r_data				: FI_DATA_T := (others => '0');
--
--signal		data_in_gate		: std_logic;
--
signal		fi_data_buf_en		: std_logic_vector((total_words-1) downto 0) := (others => '0');
--
signal		r_fi_data			: FI_DATA_IN_A := (others => (others => '0'));
--
signal		c_write				: std_logic := '0';
--
signal		c_read				: std_logic := '0';
--
signal		c_write_ack			: std_logic := '0';
--
signal		c_read_ack			: std_logic := '0';
--
signal		r_word_counter_en	: std_logic := '0';
--
signal		r_write				: std_logic := '0';
--
signal		r_read				: std_logic := '0';
--
signal		r_write_ack			: std_logic := '0';
--
signal		r_read_ack			: std_logic := '0';
--
signal		read_en				: std_logic := '0';
--
signal		r_read_en			: std_logic := '0';
	
--	
--
begin
--*****************************************************************************

--
--
outside_signals_ff:
process(rst, clk)
begin
	if (rst = '1') then
		n_fi_data  <= (others => '0');
		n_fi_write <= '0';
		n_fi_read  <= '0';
	elsif rising_edge(clk) then
		n_fi_data  <= fi_data;
		n_fi_write <= fi_write;
		n_fi_read  <= fi_read;
	end if;
end process;


--*****************************************************************************

--
-- Address Register
address_ff:
process(rst, clk)
begin
	if (rst = '1') then
		r_addr <= (others => (others => '0'));
	elsif rising_edge(clk) then
		r_addr(0) <= fi_addr;
		r_addr(1) <= r_addr(0);
		r_addr(2) <= r_addr(1);
	end if;
end process;

addr <= r_addr(2);


--*****************************************************************************
-- Transfer FSM
--*****************************************************************************

--
-- Transfer FSM Next State Encoder
transfer_fsm_next_state_enc:
process(state, n_fi_write, n_fi_read, word_counter)
begin
	case (state) is
		when idle =>
			if (n_fi_write = '1') then
				next_state <= write_inc_counter;
			elsif (n_fi_read = '1') then
				next_state <= read_ask_data;
			else
				next_state <= idle;
			end if;
			
		-----------------------------------------------------------------------
		
		when write_inc_counter =>
			next_state <= write_send_ack;
		when write_send_ack =>
			if ((n_fi_write = '0') or (n_fi_write = 'L')) then
				if (word_counter = (total_words-1)) then
					next_state <= write_write_data;
				else
					next_state <= write_running;
				end if;
			else
				next_state <= write_send_ack;
			end if;
		when write_running =>
			if (n_fi_write = '1') then
				next_state <= write_inc_counter;
			else
				next_state <= write_running;
			end if;
		when write_write_data =>
			next_state <= idle;
			
		-----------------------------------------------------------------------
		when read_ask_data =>
			next_state <= read_get_data;
		when read_get_data =>
			next_state <= read_inc_counter;
		when read_running =>
			if (n_fi_read = '1') then
				next_state <= read_inc_counter;
			else
				next_state <= read_running;
			end if;
		when read_inc_counter =>
			next_state <= read_sync;
		when read_sync =>
			next_state <= read_send_ack;
		when read_send_ack =>
			if ((n_fi_read = '0') or (n_fi_read = 'L')) then
				if (word_counter = (total_words-1)) then
					next_state <= read_read_data;
				else
					next_state <= read_running;
				end if;
			else
				next_state <= read_send_ack;
			end if;
		when read_read_data =>
			next_state <= idle;
		
        when recov =>
            next_state <= idle;
            
		-----------------------------------------------------------------------
		
		when others	=>
			next_state <= idle;
	end case;
end process;

--
-- Transfer FSM Output Decoder
transfer_fsm_output_dec:
process(next_state)
begin
	case (next_state) is
		when idle =>
			word_counter_en <= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';
		
		-----------------------------------------------------------------------
		
		when write_inc_counter =>
			word_counter_en	<= '1';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when write_send_ack =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '1';
			c_read_ack		<= '0';
			
		when write_running =>
			word_counter_en <= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';
			
		when write_write_data =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '1';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';
		
		-----------------------------------------------------------------------

		when read_ask_data =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '1';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when read_get_data =>
			word_counter_en	<= '0';
			read_en			<= '1';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when read_running =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when read_inc_counter =>
			word_counter_en	<= '1';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when read_sync =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		when read_send_ack =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '1';
			
		when read_read_data =>
			word_counter_en	<= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';

		-----------------------------------------------------------------------

		when others	=>
			word_counter_en <= '0';
			read_en			<= '0';
			--
			c_write			<= '0';
			c_read			<= '0';
			--
			c_write_ack		<= '0';
			c_read_ack		<= '0';
			
	end case;
end process;

--
-- Transfer FSM states register
transfer_fsm_ff:
process(clk, rst)
begin
	if (rst = '1') then
		state <= idle;
	elsif (rising_edge(clk)) then
		state <= next_state;
	end if;
end process;

--
-- Transfer FSM Output Register
transfer_fsm_output_ff:
process(clk, rst)
begin
	if (rst = '1') then
		r_word_counter_en <= '0';
		r_read_en <= '0'; 
		--
		r_write		<= '0';
		r_read		<= '0';
		--
		r_write_ack	<= '0';
		r_read_ack	<= '0';
	elsif (rising_edge(clk)) then
		r_word_counter_en <= word_counter_en;
		r_read_en <= read_en;
		--
		r_write		<= c_write;
		r_read		<= c_read;
		--
		r_write_ack	<= c_write_ack;
		r_read_ack	<= c_read_ack;
	end if;
end process;

write	<= r_write;
read	<= r_read;

--
-- Word Counter
word_counter_ff:
process(rst, clk)
begin
	if (rst = '1') then
		word_counter <= (others => '1');
	elsif rising_edge(clk) then
		if (word_counter_en = '1') then
			word_counter <= word_counter+1;
		end if;
	end if;
end process;


--*****************************************************************************
-- Slave -> Master (Master Read Operation)
--*****************************************************************************

--
-- Data Input Register
data_input_ff:
process(rst, clk)
begin
	if (rst = '1') then
		r_data_in <= (others => (others => '0'));
		--data_in_gate	<= '1';
	elsif rising_edge(clk) then
		--if ((r_read_en = '1') and (data_in_gate = '1')) then
		if (r_read_en = '1') then
			r_data_in <= TO_FI_DATA_IN(data_in);
			--data_in_gate	<= '0';
		--elsif ((r_read_en = '0') and (data_in_gate = '0')) then
			--data_in_gate	<= '1';
		end if;
	end if;
end process;

--
-- Data MUX
data_mux: c_data	<= r_data_in(conv_integer(word_counter));

--
-- FI Data Output Register
fi_data_output_ff:
process(rst, clk)
begin
	if (rst = '1') then
		r_data <= (others => '0');
	elsif rising_edge(clk) then
		r_data <= c_data;
	end if;
end process;

--
-- FI Data Output Buffer
fi_data_output_buf:
fi_data <= r_data when (state = read_send_ack) else (others => 'Z');


--*****************************************************************************
-- Master -> Slave (Master Write Operation)
--*****************************************************************************

--
-- Word Counter Decoder
word_counter_dec:
process(word_counter)
begin
	fi_data_buf_en <= (others => '0');
	fi_data_buf_en(conv_integer(word_counter))	<= '1';
end process;

--
-- FI Data Input Buffering
fi_data_input_buffer_construct:
for i in 0 to (total_words-1) generate
	fi_data_input_buffer:
	process(rst, clk)
	begin
		if (rst = '1') then
			r_fi_data(i) <= (others => '0');
		elsif rising_edge(clk) then
			if ((fi_data_buf_en(i) = '1') and (r_word_counter_en = '1')) then
				r_fi_data(i) <= n_fi_data;
			end if;
		end if;
	end process;
end generate fi_data_input_buffer_construct;

data_out <= TO_FI_DATA_OUT(r_fi_data);


--*****************************************************************************

--
-- FI Write Output Buffer
fi_write_output_buf:
fi_write	<= r_read_ack when	(state = read_ask_data)		or
								(state = read_get_data)		or
								(state = read_running)		or
								(state = read_inc_counter)	or
								(state = read_sync)			or
								(state = read_send_ack)		or
								(state = read_read_data)
			else 'Z';

			
--*****************************************************************************

--
-- FI Read Output Buffer
fi_read_output_buf:
fi_read		<= r_write_ack when	(state = write_inc_counter) or
								(state = write_running)		or
								(state = write_send_ack)	or
								(state = write_write_data)
			else 'Z';

--
end rtl;
