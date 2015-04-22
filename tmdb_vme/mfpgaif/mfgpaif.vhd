-- $ mfpgaif.vhd
-- Master FPGA communication Interface - FI
-- v: svn controlled
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.mfpgaif_pkg.all;

--

entity mfpgaif is
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
end entity;

architecture rtl of mfpgaif is

--
-- Signals

--
signal		n_fi_data			: FI_DATA_T;
--
signal		n_fi_write			: std_logic;
--
signal		n_fi_read			: std_logic;
--
signal  	r_addr				: ADDR_REG_A;
--
signal		write_ack			: std_logic;
--
signal		read_ack			: std_logic;
--
type		state_values is
				(idle, write_ack_check, write_inc_counter, write_sync, 
					write_data, write_wait_slave, write_dtack, 
					read_inc_counter, read_ack_check, read_wait_ack, 
					read_get_data, read_dtack);
signal		state, next_state	: state_values;
attribute 	syn_encoding		: string;
attribute	syn_encoding of 
				state_values	: type is "safe, one-hot";
--
signal  	word_counter_en		: std_logic;
--
signal		r_word_counter_en	: std_logic;
--
signal		word_counter		: WORD_COUNTER_T;
--
signal		r_data_in			: FI_DATA_IN_A;
--
signal		c_data				: FI_DATA_T;
--
signal		r_data				: FI_DATA_T;
--
signal		write_gate			: std_logic;
--
signal		read_gate			: std_logic;
--
signal		c_fi_write			: std_logic;
--
signal		c_fi_read			: std_logic;
--
signal		c_dtack				: std_logic;
--
signal		r_fi_write			: std_logic;
--
signal		r_fi_read			: std_logic;
--
signal		r_dtack				: std_logic;
--
signal		fi_data_buf_en		: std_logic_vector((total_words-1) downto 0);
--
signal		r_fi_data			: FI_DATA_IN_A;
--
signal		get_data_en			: std_logic;

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
		r_addr(0) <= addr;
		r_addr(1) <= r_addr(0);
	end if;
end process;

fi_addr <= r_addr(1);

--*****************************************************************************

--
-- Write Acknowledgement
write_ack <= n_fi_read;

--
-- Read Acknowledgement
read_ack <= n_fi_write;


--*****************************************************************************
-- Transfer FSM
--*****************************************************************************

--
-- Transfer FSM Next State Encoder
transfer_fsm_next_state_enc:
process(state, write, read, write_ack, read_ack, word_counter)
begin
	case (state) is
		when idle =>
			if ((write = '1') and (write_gate = '1')) then
				next_state <= write_ack_check;
			elsif ((read = '1') and (read_gate = '1')) then
				next_state <= read_ack_check;
			else
				next_state <= idle;
			end if;
		
		-----------------------------------------------------------------------
		
		when write_ack_check =>
			-- write_ack must be 0 to the cycle get started
			if ((write_ack = '0') or (write_ack = 'L')) then
				next_state <= write_inc_counter;
			else
				next_state <= write_ack_check;
			end if;
		when write_inc_counter =>
			next_state <= write_sync; --write_data;
		when write_sync =>
			next_state <= write_data;
		when write_data =>
			-- check data ack
			if (write_ack = '1') then
				-- if we have sent all the words
				if (word_counter = (total_words-1)) then
					-- check if slave has also finished the cycle
					--if ((write_ack = '0') or (write_ack = 'L')) then
						---- slave has finished the cycle
						--next_state <= write_dtack;
					--else
						-- wait for slave
						next_state <= write_wait_slave;
					--end if;
				else
					-- send another word
					next_state <= write_ack_check;
				end if;
			else
				-- wait
				next_state <= write_data;
			end if;
		when write_wait_slave =>
			if ((write_ack = '0') or (write_ack = 'L')) then
				next_state <= write_dtack;
			else
				next_state <= write_wait_slave;
			end if;
		when write_dtack =>
			next_state <= idle;
		
		-----------------------------------------------------------------------

		when read_ack_check =>
			-- write_ack must be 0 to the cycle get started
			if ((read_ack = '0') or (read_ack = 'L')) then
				next_state <= read_inc_counter;
			else
				next_state <= read_ack_check;
			end if;
		when read_inc_counter =>
			next_state <= read_wait_ack;
		when read_wait_ack =>
			-- check data ack
			if (read_ack = '1') then
				-- -- if we have get all the words
				-- if (word_counter = (total_words-1)) then
					-- -- check if slave has also finished the cycle
					-- if ((read_ack = '0') or (read_ack = 'L')) then
						-- -- slave has finished the cycle
						-- next_state <= write_dtack;
					-- else
						-- -- wait for slave
						-- next_state <= read_wait_slave;
					-- end if;
				-- else
					-- -- go get data
					-- next_state <= read_get_data;
				-- end if;
				next_state <= read_get_data;
			else
				-- wait
				next_state <= read_wait_ack;
			end if;
		when read_get_data =>
			-- write_ack must be 0 to continue the cycle
			if ((read_ack = '0') or (read_ack = 'L')) then
				-- if we have get all the words
				if (word_counter = (total_words-1)) then
					-- check if slave has also finished the cycle
					--if ((read_ack = '0') or (read_ack = 'L')) then
						-- slave has finished the cycle
						next_state <= read_dtack;
					--else
						-- wait for slave
						--next_state <= read_wait_slave;
					--end if;
				else
					-- go get one more word
					next_state <= read_inc_counter;
				end if;
			else
				next_state <= read_get_data;
			end if;
		--when read_wait_slave =>
			--if ((read_ack = '0') or (read_ack = 'L')) then
				--next_state <= read_dtack;
			--else
				--next_state <= read_wait_slave;
			--end if;
		when read_dtack =>
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
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		-----------------------------------------------------------------------
		when write_ack_check =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';
			
		when write_inc_counter =>
			word_counter_en	<= '1';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		when write_sync =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		when write_data =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '1';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';
		
		when write_wait_slave =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';
		
		when write_dtack =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '1';

		-----------------------------------------------------------------------

		when read_inc_counter =>
			word_counter_en	<= '1';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		when read_ack_check =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		when read_wait_ack =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '1';
			--
			c_dtack			<= '0';
		
		when read_get_data =>
			word_counter_en	<= '0';
			get_data_en		<= '1';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';

		--when read_wait_slave =>
			--word_counter_en	<= '0';
			--get_data_en		<= '0';
			----
			--c_fi_write		<= '0';
			--c_fi_read			<= '0';
			----
			--c_dtack			<= '0';

		when read_dtack =>
			word_counter_en	<= '0';
			get_data_en		<= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '1';
			
		-----------------------------------------------------------------------

		when others	=>
			word_counter_en <= '0';
			--
			c_fi_write		<= '0';
			c_fi_read		<= '0';
			--
			c_dtack			<= '0';
			
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
		--
		r_fi_write		<= '0';
		r_fi_read		<= '0';
		--
		r_dtack			<= '0';
	elsif (rising_edge(clk)) then
		r_word_counter_en <= word_counter_en;
		--
		r_fi_write		<= c_fi_write;
		r_fi_read		<= c_fi_read;
		--
		r_dtack			<= c_dtack;
	end if;
end process;

--
-- Word Counter
word_counter_ff:
process(rst, clk)
begin
	if (rst = '1') then
		word_counter <= (others => '1');
	elsif rising_edge(clk) then
		if (r_word_counter_en = '1') then
			word_counter <= word_counter+1;
		end if;
	end if;
end process;

--
-- Read Gate
read_gate_ff:
process(rst, clk)
begin
	if (rst = '1') then
		read_gate	<= '1';
	elsif rising_edge(clk) then
		if ((read = '1') and (read_gate = '1')) then
			read_gate	<= '0';
		elsif ((read = '0') and (read_gate = '0')) then
			read_gate	<= '1';
		end if;
	end if;
end process;


--*****************************************************************************
-- Master -> Slave (Master Write Operation)
--*****************************************************************************

--
-- Data Input Register
data_input_ff:
process(rst, clk)
begin
	if (rst = '1') then
		r_data_in 	<= (others => (others => '0'));
		write_gate	<= '1';
	elsif rising_edge(clk) then
		if ((write = '1') and (write_gate = '1')) then
			r_data_in 	<= TO_FI_DATA_IN(data_in);
			write_gate	<= '0';
		elsif ((write = '0') and (write_gate = '0')) then
			write_gate	<= '1';
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
fi_data <= r_data when (state = write_data) else (others => 'Z');


--*****************************************************************************
-- Slave -> Master (Master Read Operation)
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
			if ((fi_data_buf_en(i) = '1') and (get_data_en = '1')) then
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
fi_write	<= r_fi_write when (state = idle) 		or 
						(state = write_inc_counter)	or
						(state = write_ack_check)	or
						(state = write_sync)		or
						(state = write_data)		or
						(state = write_wait_slave)	or
						(state = write_dtack)		
			else 'Z';

			
--*****************************************************************************

--
-- FI Read Output Buffer
fi_read_output_buf:
fi_read		<= r_fi_read when (state = idle)		or
						(state = read_inc_counter)	or
						(state = read_ack_check)	or
						(state = read_wait_ack)		or
						(state = read_get_data)     or
						(state = read_dtack)		
			else 'Z';

--*****************************************************************************

--
-- DTACK Output
dtack_output:
dtack <= r_dtack;

--
end rtl;
