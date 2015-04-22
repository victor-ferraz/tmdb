---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Design: C:\Projects\VmeInterface\vmeif_usr.vhd
-- Author: Ralf Spiwoks,   original version
-- Company: CERN
-- Description: VME Interface of the ATLAS Level-1 Central Trigger Processor
--              package file for user definitions
-- Notes:
--
-- History:
-- 21 JAN 2004: Created seperate package file.
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;
use work.vmeif_pkg.all;

package vmeif_usr is
--
-- user configuration ROM
--
constant usr_cr_data	: MEM_32_BYTE :=
								((x"00"),		-- check sum
								 (x"FF"),		-- length of rom
								 (x"03"),		-- length or rom
								 (x"00"),		-- length of rom
								 (x"81"),		-- CR data width
								 (x"81"),		-- CSR data width
								 (x"02"),		-- CR/CSR specification identifier
								 (x"43"),		-- ASCII "C"
								 (x"52"),		-- ASCII "R"
								 (x"08"),		-- manufacturer identifier
								 (x"00"),		-- manufacturer identifier
								 (x"30"),		-- manufacturer identifier
								 (x"00"),		-- board identifier
								 (x"00"),		-- board identifier
								 (x"01"),		-- board identifier
								 (x"4D"),		-- board identifier
								 (x"00"),		-- revision identifier
								 (x"00"),		-- revision identifier
								 (x"00"),		-- revision identifier
								 (x"03"),		-- revision identifier
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00"),		-- unused
								 (x"00")		-- unused
								);
--
-- user address decoder mask
--								
	constant usr_adem				: MEM_4_BYTE := ((x"FF"),(x"00"),(x"00"),(x"00"));
--
-- user address map
--	
constant usr_addr_map			: USR_MAP_VECTOR	:=


--
--    base            = base address of mapping;
--    mask            = mask of mapping, 0 => mapping not used
--    AM_SGL, AM_BLT  = two address modifiers to be decoded
--    DTACK           = 0..15 => generate DTACK #BCs after user_read/write, -1 => wait for user_dtack
--    external        = true  => mapping used with user bus, false => used in same device (user_data_in/out)
--

--    base address, window size (mask), AM_SGL,AM_BLT,DTACK (positive number means number of BCs to generate DTACK)
	
	--(x"00000000", x"00000000", x"09", x"0B", -1, true)	  -- mask to zeros mean not implememented.

	-- windows size(mask) = [User Address Space] - ([Range] - 1)

	(
		(x"00000000", x"00FFFC00", x"09", x"0B", 0, false),	-- 00 - FPGA VME Registers - 0x000 to 0x3FF (256 words x 32 bits)
		(x"00000400", x"00FFFC00", x"09", x"0B", -1, false)	-- 01 - FPGA Core Register - 0x400 to 0x7FF (256 words x 32 bits)
	);


--
-- user clock selection
--
constant usr_clock				: USR_CLOCK_OPTION	:= external;
--
-- user address latch enable: internal or external
--
constant usr_addrle				: USR_ADDRLE_OPTION	:= internal;

--
-- user data acknowledge: floating or rescinding
--

constant usr_dtack				: USR_DTACK_OPTION	:= rescinding;

--
-- user busses: external (tri-state) or internal (bi_state)
--	

--constant usr_bus				  : USR_BUS_OPTION	:= external;	
--constant usr_bus				  : USR_BUS_OPTION	:= internal;	


end package vmeif_usr;

package body vmeif_usr is
end package body vmeif_usr;
