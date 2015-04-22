--
--

library ieee;
use ieee.std_logic_1164.all;

use work.vRegs_pkg.all;


package vRegs_usr is

------------------------------------------------------------------------------- 

	--(addr, writable, readable, peripheral, reset state)
	constant system_regs_enum	: SYS_REGS_VECTOR :=
	(
		-- Reset										- VME: Base+0x2A8.
		(x"00AA",	true,	true,	false,	x"00000000"),
		-- R/W Test Register							- VME: Base+0x3FC.
		(x"00FF",	true,	true,	false,	x"00000000"),
		-- R/W Test Register							- VME: Base+0x4.
		(x"0001",	true,	true,	false,	x"00000000"),
		-- R/W Test Register							- VME: Base+0x0.	
		(x"0000",	true,	true,	false,	x"00000000")	
	);

-------------------------------------------------------------------------------
	
end package vRegs_usr;

package body vRegs_usr is
end package body vRegs_usr;
