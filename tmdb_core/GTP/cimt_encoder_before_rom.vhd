----------------------------------------------------------------------------------
-- Institute: LIP
-- Engineer: José Alves
-- Create Date:    01:04:06 01/15/2013 
-- Design Name:    G-Link encoding
-- Module Name:    cimt_encoder - Behavioral 
-- Revision 0.01 - 15/12/2013
-- This version conclusion - 10:34 02/08/2014 (CERN)

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
 
entity cimt_encoder is
port 
	( 
		txclk       : in  STD_LOGIC;
		txreset     : in  STD_LOGIC;
		tx          : in  STD_LOGIC_VECTOR (15 downto 0);
		txflag      : in  STD_LOGIC;
		txflgenb    : in  STD_LOGIC;
		txcntl      : in  STD_LOGIC;
		txdata      : in  STD_LOGIC; 
		Encodeddata : out STD_LOGIC_VECTOR (19 downto 0)
	);

	-- attribute use_dsp48                 : string;
	-- attribute use_dsp48        of cimt_encoder : entity is "yes";
	-- attribute resource_sharing          : string;
	-- attribute resource_sharing of cimt_encoder : entity is "no";  
	
end cimt_encoder;


architecture Behavioral of cimt_encoder is


    signal counter_words        : integer range 0 to 2147483647:= 0;
    signal cnt_idles            : integer range 0 to 2147483647:= 0;
    signal count_clk_cycles     : integer range 0 to 2147483647 := 0; --Need this for disparity monitoring -> need to count words, 
    signal count_clk_cycles_i   : std_logic_vector (31 downto 0);
    signal rst_counter          : std_logic;																		 												  
 
    signal tx_delay             : std_logic_vector(15 downto 0);	
    signal tx_data_delay        : std_logic;	
    signal txcntl_delay         : std_logic;	
    signal txflgenb_delay       : std_logic;	
    signal txflag_delay         : std_logic;	
 
    signal disparity_20bi         : std_logic_vector (5 downto 0);
    signal disparity_20bi_accum   : std_logic_vector (5 downto 0);
    signal disparity_20bi_d       : std_logic_vector (5 downto 0);
    signal disparity_20bi_accum_d : std_logic_vector (5 downto 0);
    signal disparity_20bi_2       : std_logic_vector (5 downto 0);
    signal disparity_20bi_accum_2 : std_logic_vector (5 downto 0);
 
    signal encoded20b             : std_logic_vector (19 downto 0);
    signal encoded20b_delay       : std_logic_vector (19 downto 0); 
    signal encoded20b_out_reverse : std_logic_vector (19 downto 0);
    signal flag_int               : std_logic := '0';
    signal flag_to_encode         : std_logic := '0';
    signal test_disp              : std_logic := '0';
	
	--attribute use_dsp48 : string;
	--attribute use_dsp48 of disparity_20bi    : signal is "yes";
	--attribute use_dsp48 of disparity_20bi_2  : signal is "yes";
 
    attribute keep : string;
    attribute keep of encoded20b             : signal is "true";
    attribute keep of encoded20b_delay       : signal is "true";
    attribute keep of count_clk_cycles_i     : signal is "true";
    attribute keep of disparity_20bi         : signal is "true";
    attribute keep of disparity_20bi_accum   : signal is "true";
    attribute keep of encoded20b_out_reverse : signal is "true";
	attribute keep of test_disp : signal is "true";
	 

--function count_ones(s : std_logic_vector) return integer is
--  variable temp : integer := 0;
--begin
--  for i in s'low to s'high loop
--		if s(i) = '1' then temp := temp + 1; 
--		end if;
--  end loop;
--  return temp;
--end function count_ones;
 
 
--function which count the high bits for disparity computation--
function count_ones(s : std_logic_vector) return integer is
  variable temp : integer := 0;
begin
  for i in s'range loop
    if s(i) = '1' then temp := temp + 1; 
    end if;
  end loop;
  return temp;
end function count_ones;

--function to reverse the bit order in std_logic_vector--
function reverse_bits(v : std_logic_vector; vector_dim: integer) return std_logic_vector is
  variable output : std_logic_vector(vector_dim downto 0) := (others =>'0');
begin
  for i in v'range loop
    output(i) := v(vector_dim-i);
  end loop;
  return output;
end function reverse_bits;
	
begin

encoded20b_delay <= encoded20b;


--internal_flag_generation: if txflgenb = '1' generate

process (txclk,txreset,rst_counter)
begin
      if txreset = '1' or rst_counter = '1' then --or txflgenb = '0' then
		   count_clk_cycles <= 0;
		elsif rising_edge (txclk) then
		  count_clk_cycles <= count_clk_cycles + 1;
		end if;
	     count_clk_cycles_i <= conv_std_logic_vector(count_clk_cycles,32);
end process;

process (txclk,txreset)
begin

   if txreset = '1' or txflgenb = '0' then
	    flag_int <= '0';
	elsif rising_edge (txclk) then
	    if(count_clk_cycles mod 2)/= 0 then
	       flag_int <= '1';
		 else 
	       flag_int <= '0';
	    end if;
  end if;
end process;

--Flag_decode/encode--
process (txclk,txreset,txflgenb)
begin

   if txreset = '1' then
	  flag_to_encode <= '0';
	elsif rising_edge (txclk) then
		if txflgenb = '0' then
		   flag_to_encode <= txflag;
		elsif txflgenb = '1' then
		    flag_to_encode <= flag_int;
		end if;
   end if;

end process;
--End Flag_decode/encode--

process (txclk,txreset)
begin
    if txreset = '1' then
	    rst_counter <= '0';
	 elsif rising_edge (txclk) then
       if count_clk_cycles = 2147483647 then
		    rst_counter <= '1';
		 else 
			 rst_counter <= '0';
		end if;
	end if;
end process;

--disparity computation process--
disparity_comput : process (txclk,txreset,txcntl,txdata)

	variable disparity_20b_i		: integer := 0;
	variable disparity_20b_ii		: integer := 0;
	variable disparity_20b_i_cntl	: integer := 0;
	variable word_dim        		: integer := 16;
	variable word_dim_i        		: integer := 14;
	variable word_dim_test     		: integer := 20;
	
begin 
	if txreset = '1' then
		disparity_20bi   <=(others => '0');
		disparity_20bi_2 <=(others => '0');
	elsif rising_edge (txclk) then 
		if txcntl = '1' then
			disparity_20b_i :=(count_ones (tx(15 downto 9))) - (word_dim_i - count_ones (tx(6 downto 0)));
		end if;
		if txdata = '1' and txcntl = '0' then
			disparity_20b_i :=(count_ones (tx)) -(word_dim - (count_ones (tx))) + 2;
		    --disparity_20b_ii :=(count_ones (encoded20b)) -(word_dim_test - count_ones(encoded20b));
		end if;
		disparity_20b_ii := (count_ones (encoded20b)) - (word_dim_test - count_ones(encoded20b));
		disparity_20bi_2 <= conv_std_logic_vector(disparity_20b_ii,6);
		disparity_20bi   <= conv_std_logic_vector(disparity_20b_i,6);
	end if;			
end process;
	 
disparity_accumulation: process (txclk, txreset)
begin
		if txreset = '1' then
			disparity_20bi_accum <=(others => '0');
			disparity_20bi_accum_2 <=(others => '0');
		elsif rising_edge (txclk) then 
			
			disparity_20bi_accum <= disparity_20bi;
			disparity_20bi_accum_2 <= disparity_20bi_2;
				
		end if;
end process;


data_delayed: process (txclk,txreset,tx)
begin
		if txreset = '1' then
			--encoded20b_delay <= (others => '0');  
			 disparity_20bi_d <= (others => '0');   
          disparity_20bi_accum_d <= (others => '0');
			 tx_delay <= (others => '0');
			 tx_data_delay <= '0';
			 txcntl_delay <= '0';
			 txflgenb_delay <= '0';
			 txflag_delay <= '0';
				
		elsif rising_edge (txclk) then
				--encoded20b_delay <= encoded20b;
			 disparity_20bi_d <= disparity_20bi;  
          disparity_20bi_accum_d <= disparity_20bi_accum;
				
				--lacth input signals--
			 tx_delay	<= tx;
			 tx_data_delay <= txdata;
			 txcntl_delay <= txcntl;
			 txflgenb_delay <= txflgenb;
				--txflag_delay <= txflag;
	  end if;
end process;



-- coding--
coding: process (txclk,txreset,tx_data_delay,txcntl_delay,tx,txflgenb_delay,flag_to_encode)

begin
      
		if txreset = '1' then
			 encoded20b (19 downto 0) <=  (others => '0');
			 counter_words <= 0; 
		elsif rising_edge (txclk) then -- clock 40 MHz
			
			--DATA words Encoding--
		   if tx_data_delay = '1' and txcntl_delay = '0' then 
 			   if txflgenb_delay  = '1' or txflgenb_delay  = '0' then
				   if flag_to_encode = '0'  then
				      if encoded20b_delay = x"FF803" then 
				         if disparity_20bi(5) = '0' then 
				             encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						       --counter_words <= counter_words + 1;
				         elsif disparity_20bi(5) = '1' then
					          encoded20b (19 downto 0) <=  (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						       --counter_words <= 0;
					      end if;
					    --end if;
				       elsif encoded20b_delay = x"FE003" then
					         if disparity_20bi(5) = '0' then 
				              encoded20b (19 downto 0) <=  (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						      --counter_words <= 0;
				            elsif disparity_20bi(5) = '1' then
					           encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						        --counter_words <= counter_words + 1;
					         end if;
				        else
						  --end if;
				     
				       if encoded20b_delay (3 downto 0) = "1101" or encoded20b_delay (3 downto 0) = "1011" 
						    or (encoded20b_delay (3 downto 0) = "0011" and encoded20b_delay (12 downto 11) = "01")then
					       if disparity_20bi /= "000000" then
					          if disparity_20bi (5) = disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						 --counter_words <= counter_words + 1;
					          elsif disparity_20bi (5) /= disparity_20bi_accum (5) then
					             encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						 --counter_words <= 0; 
					          end if;
				           elsif disparity_20bi = "000000" then
					            encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
					       end if;
					    end if;
						 
				       if encoded20b_delay (3 downto 0) = "0010" or encoded20b_delay (3 downto 0) = "0100" or
						    (encoded20b_delay (3 downto 0) = "1100" and encoded20b_delay (12 downto 11) = "10")then
				          if disparity_20bi /= "000000" then
					          if disparity_20bi (5) = disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						 --counter_words <= 0; 
					          elsif disparity_20bi (5) /= disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <=  not (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						 --counter_words <= counter_words + 1;
					          end if;
				          elsif disparity_20bi = "000000" then
					            encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
					       end if;
				         end if;
						 end if;
			   end if;
		    
			 if flag_to_encode = '1' then
			    
			           if encoded20b_delay = x"FF803" then 
				         if disparity_20bi(5) = '0' then 
				             encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						       --counter_words <= counter_words + 1;
				         elsif disparity_20bi(5) = '1' then
					          encoded20b (19 downto 0) <=  (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						       --counter_words <= 0;
					      end if;
					    --end if;
				       elsif encoded20b_delay = x"FE003" then
					         if disparity_20bi(5) = '0' then 
				              encoded20b (19 downto 0) <=  (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						      --counter_words <= 0;
				            elsif disparity_20bi(5) = '1' then
					           encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						        --counter_words <= counter_words + 1;
					         end if;
				        else
						  --end if;
				     
				       if encoded20b_delay (3 downto 0) = "1101" or encoded20b_delay (3 downto 0) = "1011" or
						   (encoded20b_delay (3 downto 0) = "0011" and encoded20b_delay (12 downto 11) = "01") then
					       if disparity_20bi /= "000000" then
					          if disparity_20bi (5) = disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						 --counter_words <= counter_words + 1;
					          elsif disparity_20bi (5) /= disparity_20bi_accum (5) then
					             encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						 --counter_words <= 0; 
					          end if;
				           elsif disparity_20bi = "000000" then
					            encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
					       end if;
					    end if;
						 
				       if encoded20b_delay (3 downto 0) = "0010" or encoded20b_delay (3 downto 0) = "0100" or
						   (encoded20b_delay (3 downto 0) = "0011" and encoded20b_delay (12 downto 11) = "10")then
				          if disparity_20bi /= "000000" then
					          if disparity_20bi (5) = disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						 --counter_words <= 0; 
					          elsif disparity_20bi (5) /= disparity_20bi_accum (5)  then
					             encoded20b (19 downto 0) <=  not (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
						 --counter_words <= counter_words + 1;
					          end if;
				          elsif disparity_20bi = "000000" then
					            encoded20b (19 downto 0) <= (tx_delay (15 downto 0) & "10" & flag_to_encode & "1");
					       end if;
				         end if;
						 end if;
			         end if;
			
			
			
			end if;
      end if;
				  
		
------------------------------------------------------------------------------------------------------------------
             --Control Words--
				 
				 	      
			if  txcntl_delay  = '1' then 
			    if encoded20b_delay = x"FF083" then 
				    if disparity_20bi(5) = '0' then 
				       encoded20b (19 downto 0) <= not (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
				    elsif disparity_20bi(5) = '1' then
					   encoded20b (19 downto 0) <= (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
					 end if;
				  end if;
				  
			    if encoded20b_delay = x"FE003" then
					 if disparity_20bi(5) = '0' then 
				       encoded20b (19 downto 0) <=  (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
				    elsif disparity_20bi(5) = '1' then
					    encoded20b (19 downto 0) <= not (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
					 end if;
				 end if;
				 
			    if (encoded20b_delay (3 downto 0) = "0011" and encoded20b_delay (12 downto 11)= "01") or encoded20b_delay (3 downto 0) = "1101" or encoded20b_delay (3 downto 0) = "1011" then
					 if disparity_20bi /= "000000" then
					    if disparity_20bi (5) = disparity_20bi_accum (5)  then
					       encoded20b (19 downto 0) <= not (tx_delay (15 downto 0) & "11" & flag_to_encode & "1");
						 --counter_words <= counter_words + 1;
					    elsif disparity_20bi (5) /= disparity_20bi_accum (5) then
					       encoded20b (19 downto 0) <= (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
						 --counter_words <= 0; 
					    end if;
					 elsif disparity_20bi = "000000" then
					        encoded20b (19 downto 0) <= (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
					 end if;
				 end if;
				 
		       if (encoded20b_delay (3 downto 0) = "1100" and encoded20b_delay (12 downto 11)= "10" ) or encoded20b_delay (3 downto 0) = "0010" or encoded20b_delay (3 downto 0) = "0100"  then
				    if disparity_20bi /= "000000" then
					    if disparity_20bi (5) = disparity_20bi_accum (5)  then
					       encoded20b (19 downto 0) <= (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
						 --counter_words <= 0; 
					    elsif disparity_20bi (5) /= disparity_20bi_accum (5)  then
					       encoded20b (19 downto 0) <=  not (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
						 --counter_words <= counter_words + 1;
					    end if;
				    elsif disparity_20bi = "000000" then
					       encoded20b (19 downto 0) <= (tx_delay (15 downto 9) & "01" & tx_delay (6 downto 0) & "0011");
				    end if;
				 end if;
					
	      end if;


------------------------------------------------------------------------------------------------------------------
		           --Idle words--
		 if tx_data_delay  = '0' and txcntl_delay  = '0' then
          encoded20b(19 downto 0) <= x"FF803";
		    if encoded20b_delay = x"FF803" then
				 encoded20b(19 downto 0) <= x"FE003";
			 elsif encoded20b_delay = x"FE003" then
				 encoded20b(19 downto 0) <= x"FF803";
			 end if;
			 
		    if encoded20b_delay(3 downto 0)  = "1101" or encoded20b_delay(3 downto 0)  = "0010" or encoded20b_delay(3 downto 0)  = "1011" or encoded20b_delay(3 downto 0)  = "0100" or 
			 (encoded20b_delay(3 downto 0)  = "1100" and encoded20b_delay(12 downto 11)= "10") or (encoded20b_delay(3 downto 0)  = "0011" and encoded20b_delay(12 downto 11)= "01") then
				 if disparity_20bi_accum(5) = '0'  then
					 encoded20b (19 downto 0) <= x"FE003";
				 elsif disparity_20bi_accum(5) = '1' then
					 encoded20b (19 downto 0) <= x"FF803";
				 end if;
			 end if;
			end if;
	
end if;	 
		          --x"002b3";  
					 --x"00338"; --only for simulation
					 --x"ff2b3";
					 --x"FF803"; --G-link idle word
end process;


encoded20b_out_reverse <= reverse_bits(encoded20b,19);

Encodeddata <= encoded20b_out_reverse;

----disp_test: check the DC balance in the output data : optional--
--process (txclk)
--begin
--   if txreset = '1' then
--     test_disp <= '0';
--	elsif rising_edge (txclk) then
--	   --if encoded20b /= x"FE003" or encoded20b /= x"FF803" then
--	      if disparity_20bi_2 /= "000000" then --or disparity_20bi_accum_2 /= "000000" then
--	         if disparity_20bi_accum_2(5) = disparity_20bi_2(5) then
--               test_disp <= '1';
--		      else
--		         test_disp <= '0';
--		      end if;
--		   else
--		        test_disp <= '0';
--		   end if;
--		--else
--		--test_disp <= '0';
--	  --end if;
--	end if;
--end process;

end Behavioral;

 