--
--

library ieee;
use ieee.std_logic_1164.all;


package cRegs_pkg is
	
    -- total system registers
	constant num_regs			     : integer := 145;
    
    -- data width
    constant regs_data_width         : integer := 32;
    
------------------------------------------------------------------------------- 
    --
	type	SYS_REGS_STRUCT		is record
			addr				: std_logic_vector(15 downto 0);
			writable			: boolean;
			readable			: boolean;
			peripheral			: boolean;
			rstState			: std_logic_vector(31 downto 0);
	end record SYS_REGS_STRUCT;
	 
    --
	type SYS_REGS_VECTOR	    is array (0 to (num_regs-1)) of 
                                    SYS_REGS_STRUCT;

    --
	type	SYS_REGS			is array (0 to (num_regs-1)) of 
                                    std_logic_vector(31 downto 0);

    --
    subtype REGS_1D_T           is std_logic_vector(
                                    (num_regs*regs_data_width-1) downto 0);
                                    
-------------------------------------------------------------------------------
                                    
function TO_REGS_2D(in_data : std_logic_vector) return SYS_REGS;
function TO_REGS_1D(in_data : SYS_REGS) return REGS_1D_T;

------------------------------------------------------------------------------- 	

end package cRegs_pkg;

package body cRegs_pkg is

--
--
function TO_REGS_2D(in_data : std_logic_vector) return SYS_REGS is 
	variable out_data : SYS_REGS; 
begin 
	for i in 0 to num_regs-1 loop 
		out_data(i) := 
			in_data(i*regs_data_width+regs_data_width-1 downto i*regs_data_width);
	end loop; 
	return out_data; 		
end TO_REGS_2D; -- end function

--
--
function TO_REGS_1D(in_data : SYS_REGS) return REGS_1D_T is 
	variable out_data : REGS_1D_T; 
begin 
	for i in 0 to num_regs-1 loop 
		out_data(i*regs_data_width+regs_data_width-1 downto i*regs_data_width) := 
			in_data(i);
	end loop; 
	return out_data; 		
end TO_REGS_1D; -- end function

end package body cRegs_pkg;
