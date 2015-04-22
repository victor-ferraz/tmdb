-- $ mfpgaif_pkg.vhd
-- Master FPGA communication Interface Package
-- v: svn controlled.
--

library ieee;
use ieee.std_logic_1164.all;		-- defines std_logic / std_logic_vector types and their functions.
use ieee.std_logic_arith.all;		-- defines basic arithmetic ops, CONV_STD_LOGIC_VECTOR() is here, 'signed' type too (will conflit with numeric_std if 'signed' is used in interfaces).
use ieee.std_logic_unsigned.all;	-- Synopsys extension to std_logic_arith to handle std_logic_vector as unsigned integers (used together with std_logic_signed is ambiguous).

use work.functions_pkg.all;

--

package mfpgaif_pkg is
	
	--
	--Constants
	--
	
	--
	constant total_words	: integer	:= 4;
		
	--
	constant fi_edata_width	: integer	:= 8;

	--
	constant fi_idata_width	: integer	:= 32;
	
	--
	constant fi_addr_width	: integer	:= 6;
	
--*****************************************************************************

	--
	--Data Types
	--	

	subtype	FI_DATA_T				is std_logic_vector(
										(fi_edata_width-1) downto 0);
	subtype	WORD_COUNTER_T			is std_logic_vector(
										(NumBits(total_words)-1) downto 0);
	subtype	ADDR_T					is std_logic_vector(
										(fi_addr_width-1) downto 0);
	subtype FI_DATA_OUT_T			is std_logic_vector(
										(fi_idata_width-1) downto 0);
	type	FI_DATA_IN_A			is array ((total_words-1) downto 0) of 
										FI_DATA_T;								
	type	ADDR_REG_A				is array (1 downto 0) of ADDR_T;
	
	
--*****************************************************************************

	--
	--Functions
	--
	function TO_FI_DATA_IN(in_data : std_logic_vector) return FI_DATA_IN_A;
	function TO_FI_DATA_OUT(in_data : FI_DATA_IN_A) return FI_DATA_OUT_T;
	
--*****************************************************************************

end package mfpgaif_pkg;

--

package body mfpgaif_pkg is

--
--
function TO_FI_DATA_IN(in_data : std_logic_vector) return FI_DATA_IN_A is 
	variable out_data : FI_DATA_IN_A; 
begin 
	for i in 0 to total_words-1 loop 
		out_data(i) := 
			in_data(i*fi_edata_width+fi_edata_width-1 downto i*fi_edata_width);
	end loop; 
	return out_data; 		
end TO_FI_DATA_IN; -- end function

--
--
function TO_FI_DATA_OUT(in_data : FI_DATA_IN_A) return FI_DATA_OUT_T is 
	variable out_data : FI_DATA_OUT_T; 
begin 
	for i in 0 to total_words-1 loop 
		out_data(i*fi_edata_width+fi_edata_width-1 downto i*fi_edata_width) := 
			in_data(i);
	end loop; 
	return out_data; 		
end TO_FI_DATA_OUT; -- end function

--
end package body mfpgaif_pkg;
