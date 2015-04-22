--
--

library ieee;
use ieee.std_logic_1164.all;

use work.cRegs_pkg.all;

package cRegs_usr is

------------------------------------------------------------------------------- 

    -- CORE_ADDRESS is the address for a register within the CORE FPGA.
    -- As we are able to fit up to 63 registers per page, the CORE_ADDRESS
    -- ranges from 0x0 to 0x3E. The CORE_ADDRESS = 0x3F is dedicated to the
    -- "Page Register".
    
    -- VME_ADDRESS is a register address propagated to the VME address spacing.
    -- VME_ADDRESS = CORE_ADDRESS_OFFSET + 4 * CORE_ADDRESS
    -- CORE_ADDRESS_OFFSET is defined in the VME FPGA firmware. Normally it's 
    -- set to be 0x400.
    -- Example: For "Page Register" at CORE_ADDRESS = 0x3F
    -- VME_ADDRESS = 0x400 + 4 * 0x3F = 0x4FC
    -- Don't forget about the VME_BASE_ADDRESS. So, when accessing that example
    -- register through VME, the complete address is VME_BASE_ADDRESS + VME_ADDRESS.
    -- For a VME card at slot 14, the VME_BASE_ADDRES is 0x0E000000. Thus the
    -- complete address should be 0x0E0004FC.
    
    -- Paging goes in increments of 0x40 as a PAGE_OFFSET to the CORE_ADDRESS.
    -- PAGE_OFFSET = N * 0x40, where N is the page number (an integer).
    -- Example 1: Registers at page 0 must have a PAGE_OFFSET = 0 * 0x40 = 0.
    -- Thus, all CORE_ADDRESS(es) within page 0, ranges from 0x0 to 0x3E.
    -- Example 2: Registers at page 2 must have a PAGE_OFFSET = 2 * 0x40 = 0x80.
    -- Thus, all CORE_ADDRESS(es) within page 2 ranges from 0x80 to 0xBE.

--------------------------------------------------------------------------------
    
	--(addr, writable, readable, peripheral, reset state)    
	constant system_regs_enum	: SYS_REGS_VECTOR :=
	(   ------------------------------------------------------------------------
		-- Page Register							    - VME: Base+4FC
		------------------------------------------------------------------------
		
		(x"003F",	true,	true,	false,	x"00000000"),
		
        ------------------------------------------------------------------------
        -- Page 0 --------------------------------------------------------------
        ------------------------------------------------------------------------
        
		-- Reset Register     							- VME: Base+4F8
		(x"003E",	true,	true,	false,	x"00000000"),
        -- Control Register                             - VME: Base+400
        (x"0000",	true,	true,	false,	x"00000000"),
		-- Status Register     							- VME: Base+404
		(x"0001",	true,	true,	true,	x"00000000"),
		-- Data Fragment Readout Register			    - VME: Base+408
		(x"0002",	true,	true,	true,	x"00000000"),
		-- L1A Latency Register 						- VME: Base+40Cd
		(x"0003",	true,	true,	false,	x"00000064"),
		-- Source Identifier Register					- VME: Base+410
		(x"0004",	true,	true,	false,	x"00000001"),
        -- Run Number Register		     			    - VME: Base+414
		(x"0005",	true,	true,	false,	x"00000002"),
        -- HOLA Control Register		     			- VME: Base+418
		(x"0006",	true,	true,	false,	x"00000000"),
		-- HOLA Status Register		     		     	- VME: Base+41C
		(x"0007",	true,	true,	true, 	x"00000000"),
		-- Board ID Register	 	     			    - VME: Base+420
		(x"0008",	true,	true,	true, 	x"00000000"),
		-- Firmware Version Register		     	    - VME: Base+424
		(x"0009",	true,	true,	true, 	x"00000000"),
		-- G-Link Control Register		     	        - VME: Base+428
		(x"000A",	true,	true,	false, 	x"00000000"),        
		-- G-Link Pattern0 Register		     		    - VME: Base+42A
		(x"000B",	true,	true,	false, 	x"00000000"),
		-- G-Link Pattern1 Register		     		    - VME: Base+430
		(x"000C",	true,	true,	false, 	x"00000000"),
		-- G-Link Status Register		     		    - VME: Base+434
		(x"000D",	true,	true,	true, 	x"00000000"),
		-- Clock Status Register		     		    - VME: Base+438
		(x"000E",	true,	true,	true, 	x"00000000"),
		
		------------------------------------------------------------------------
        -- Page 1
		------------------------------------------------------------------------	
        
		-- W1 - ADC 0, W0 - ADC 0          - VME: Base + 0x400
		(x"0040", true, true, false, x"00000000"),
		-- W3 - ADC 0, W2 - ADC 0          - VME: Base + 0x404
		(x"0041", true, true, false, x"00000000"),
		-- W5 - ADC 0, W4 - ADC 0          - VME: Base + 0x408
		(x"0042", true, true, false, x"00000000"),
		-- W6 - ADC 0                      - VME: Base + 0x40C
		(x"0043", true, true, false, x"00000000"),
		-- W1 - ADC 1, W0 - ADC 1          - VME: Base + 0x410
		(x"0044", true, true, false, x"00000000"),
		-- W3 - ADC 1, W2 - ADC 1          - VME: Base + 0x414
		(x"0045", true, true, false, x"00000000"),
		-- W5 - ADC 1, W4 - ADC 1          - VME: Base + 0x418
		(x"0046", true, true, false, x"00000000"),
		-- W6 - ADC 1                      - VME: Base + 0x41C
		(x"0047", true, true, false, x"00000000"),
		-- W1 - ADC 2, W0 - ADC 2          - VME: Base + 0x420
		(x"0048", true, true, false, x"00000000"),
		-- W3 - ADC 2, W2 - ADC 2          - VME: Base + 0x424
		(x"0049", true, true, false, x"00000000"),
		-- W5 - ADC 2, W4 - ADC 2          - VME: Base + 0x428
		(x"004A", true, true, false, x"00000000"),
		-- W6 - ADC 2                       - VME: Base + 0x42C
		(x"004B", true, true, false, x"00000000"),
		-- W1 - ADC 3, W0 - ADC 3          - VME: Base + 0x430
		(x"004C", true, true, false, x"00000000"),
		-- W3 - ADC 3, W2 - ADC 3          - VME: Base + 0x434
		(x"004D", true, true, false, x"00000000"),
		-- W5 - ADC 3, W4 - ADC 3          - VME: Base + 0x438
		(x"004E", true, true, false, x"00000000"),
		-- W6 - ADC 3                       - VME: Base + 0x43C
		(x"004F", true, true, false, x"00000000"),
		-- W1 - ADC 4, W0 - ADC 4          - VME: Base + 0x440
		(x"0050", true, true, false, x"00000000"),
		-- W3 - ADC 4, W2 - ADC 4          - VME: Base + 0x444
		(x"0051", true, true, false, x"00000000"),
		-- W5 - ADC 4, W4 - ADC 4          - VME: Base + 0x448
		(x"0052", true, true, false, x"00000000"),
		-- W6 - ADC 4                      - VME: Base + 0x44C
		(x"0053", true, true, false, x"00000000"),
		-- W1 - ADC 5, W0 - ADC 5          - VME: Base + 0x450
		(x"0054", true, true, false, x"00000000"),
		-- W3 - ADC 5, W2 - ADC 5          - VME: Base + 0x454
		(x"0055", true, true, false, x"00000000"),
		-- W5 - ADC 5, W4 - ADC 5          - VME: Base + 0x458
		(x"0056", true, true, false, x"00000000"),
		-- W6 - ADC 5                      - VME: Base + 0x45C
		(x"0057", true, true, false, x"00000000"),
		-- W1 - ADC 6, W0 - ADC 6          - VME: Base + 0x460
		(x"0058", true, true, false, x"00000000"),
		-- W3 - ADC 6, W2 - ADC 6          - VME: Base + 0x464
		(x"0059", true, true, false, x"00000000"),
		-- W5 - ADC 6, W4 - ADC 6          - VME: Base + 0x468
		(x"005A", true, true, false, x"00000000"),
		-- W6 - ADC 6                      - VME: Base + 0x46C
		(x"005B", true, true, false, x"00000000"),
		-- W1 - ADC 7, W0 - ADC 7          - VME: Base + 0x470
		(x"005C", true, true, false, x"00000000"),
		-- W3 - ADC 7, W2 - ADC 7          - VME: Base + 0x474
		(x"005D", true, true, false, x"00000000"),
		-- W5 - ADC 7, W4 - ADC 7          - VME: Base + 0x478
		(x"005E", true, true, false, x"00000000"),
		-- W6 - ADC 7                      - VME: Base + 0x47C
		(x"005F", true, true, false, x"00000000"),
		-- W1 - ADC 8, W0 - ADC 8          - VME: Base + 0x480
		(x"0060", true, true, false, x"00000000"),
		-- W3 - ADC 8, W2 - ADC 8          - VME: Base + 0x484
		(x"0061", true, true, false, x"00000000"),
		-- W5 - ADC 8, W4 - ADC 8          - VME: Base + 0x488
		(x"0062", true, true, false, x"00000000"),
		-- W6 - ADC 8                      - VME: Base + 0x48C
		(x"0063", true, true, false, x"00000000"),
		-- W1 - ADC 9, W0 - ADC 9          - VME: Base + 0x490
		(x"0064", true, true, false, x"00000000"),
		-- W3 - ADC 9, W2 - ADC 9          - VME: Base + 0x494
		(x"0065", true, true, false, x"00000000"),
		-- W5 - ADC 9, W4 - ADC 9          - VME: Base + 0x498
		(x"0066", true, true, false, x"00000000"),
		-- W6 - ADC 9                      - VME: Base + 0x49C
		(x"0067", true, true, false, x"00000000"),
		-- W1 - ADC 10, W0 - ADC 10        - VME: Base + 0x4A0
		(x"0068", true, true, false, x"00000000"),
		-- W3 - ADC 10, W2 - ADC 10        - VME: Base + 0x4A4
		(x"0069", true, true, false, x"00000000"),
		-- W5 - ADC 10, W4 - ADC 10        - VME: Base + 0x4A8
		(x"006A", true, true, false, x"00000000"),
		-- W6 - ADC 10                     - VME: Base + 0x4AC
		(x"006B", true, true, false, x"00000000"),
		-- W1 - ADC 11, W0 - ADC 11        - VME: Base + 0x4B0
		(x"006C", true, true, false, x"00000000"),
		-- W3 - ADC 11, W2 - ADC 11        - VME: Base + 0x4B4
		(x"006D", true, true, false, x"00000000"),
		-- W5 - ADC 11, W4 - ADC 11        - VME: Base + 0x4B8
		(x"006E", true, true, false, x"00000000"),
		-- W6 - ADC 11                     - VME: Base + 0x4BC
		(x"006F", true, true, false, x"00000000"),
		-- W1 - ADC 12, W0 - ADC 12        - VME: Base + 0x4C0
		(x"0070", true, true, false, x"00000000"),
		-- W3 - ADC 12, W2 - ADC 12        - VME: Base + 0x4C4
		(x"0071", true, true, false, x"00000000"),
		-- W5 - ADC 12, W4 - ADC 12        - VME: Base + 0x4C8
		(x"0072", true, true, false, x"00000000"),
		-- W6 - ADC 12                     - VME: Base + 0x4CC
		(x"0073", true, true, false, x"00000000"),
		-- W1 - ADC 13, W0 - ADC 13        - VME: Base + 0x4D0
		(x"0074", true, true, false, x"00000000"),
		-- W3 - ADC 13, W2 - ADC 13        - VME: Base + 0x4D4
		(x"0075", true, true, false, x"00000000"),
		-- W5 - ADC 13, W4 - ADC 13        - VME: Base + 0x4D8
		(x"0076", true, true, false, x"00000000"),
		-- W6 - ADC 13                     - VME: Base + 0x4DC
		(x"0077", true, true, false, x"00000000"),
		-- W1 - ADC 14, W0 - ADC 14        - VME: Base + 0x4E0
		(x"0078", true, true, false, x"00000000"),
		-- W3 - ADC 14, W2 - ADC 14        - VME: Base + 0x4E4
		(x"0079", true, true, false, x"00000000"),
		-- W5 - ADC 14, W4 - ADC 14        - VME: Base + 0x4E8
		(x"007A", true, true, false, x"00000000"),
		-- W6 - ADC 14                     - VME: Base + 0x4EC
		(x"007B", true, true, false, x"00000000"),

		------------------------------------------------------------------------
        -- Page 2
        ------------------------------------------------------------------------
		
		-- W1 - ADC 15, W0 - ADC 15          - VME: Base + 0x400
		(x"0080", true, true, false, x"00000000"),
		-- W3 - ADC 15, W2 - ADC 15          - VME: Base + 0x404
		(x"0081", true, true, false, x"00000000"),
		-- W5 - ADC 15, W4 - ADC 15          - VME: Base + 0x408
		(x"0082", true, true, false, x"00000000"),
		-- W6 - ADC 15                       - VME: Base + 0x40C
		(x"0083", true, true, false, x"00000000"),
		-- W1 - ADC 16, W0 - ADC 16          - VME: Base + 0x410
		(x"0084", true, true, false, x"00000000"),
		-- W3 - ADC 16, W2 - ADC 16          - VME: Base + 0x414
		(x"0085", true, true, false, x"00000000"),
		-- W5 - ADC 16, W4 - ADC 16          - VME: Base + 0x418
		(x"0086", true, true, false, x"00000000"),
		-- W6 - ADC 16                       - VME: Base + 0x41C
		(x"0087", true, true, false, x"00000000"),
		-- W1 - ADC 17, W0 - ADC 17          - VME: Base + 0x420
		(x"0088", true, true, false, x"00000000"),
		-- W3 - ADC 17, W2 - ADC 17          - VME: Base + 0x424
		(x"0089", true, true, false, x"00000000"),
		-- W5 - ADC 17, W4 - ADC 17          - VME: Base + 0x428
		(x"008A", true, true, false, x"00000000"),
		-- W6 - ADC 17                       - VME: Base + 0x42C
		(x"008B", true, true, false, x"00000000"),
		-- W1 - ADC 18, W0 - ADC 18          - VME: Base + 0x430
		(x"008C", true, true, false, x"00000000"),
		-- W3 - ADC 18, W2 - ADC 18          - VME: Base + 0x434
		(x"008D", true, true, false, x"00000000"),
		-- W5 - ADC 18, W4 - ADC 18          - VME: Base + 0x438
		(x"008E", true, true, false, x"00000000"),
		-- W6 - ADC 18                       - VME: Base + 0x43C
		(x"008F", true, true, false, x"00000000"),
		-- W1 - ADC 19, W0 - ADC 19          - VME: Base + 0x440
		(x"0090", true, true, false, x"00000000"),
		-- W3 - ADC 19, W2 - ADC 19          - VME: Base + 0x444
		(x"0091", true, true, false, x"00000000"),
		-- W5 - ADC 19, W4 - ADC 19          - VME: Base + 0x448
		(x"0092", true, true, false, x"00000000"),
		-- W6 - ADC 19                       - VME: Base + 0x44C
		(x"0093", true, true, false, x"00000000"),
		-- W1 - ADC 20, W0 - ADC 20          - VME: Base + 0x450
		(x"0094", true, true, false, x"00000000"),
		-- W3 - ADC 20, W2 - ADC 20          - VME: Base + 0x454
		(x"0095", true, true, false, x"00000000"),
		-- W5 - ADC 20, W4 - ADC 20          - VME: Base + 0x458
		(x"0096", true, true, false, x"00000000"),
		-- W6 - ADC 20                       - VME: Base + 0x45C
		(x"0097", true, true, false, x"00000000"),
		-- W1 - ADC 21, W0 - ADC 21          - VME: Base + 0x460
		(x"0098", true, true, false, x"00000000"),
		-- W3 - ADC 21, W2 - ADC 21          - VME: Base + 0x464
		(x"0099", true, true, false, x"00000000"),
		-- W5 - ADC 21, W4 - ADC 21          - VME: Base + 0x468
		(x"009A", true, true, false, x"00000000"),
		-- W6 - ADC 21                       - VME: Base + 0x46C
		(x"009B", true, true, false, x"00000000"),
		-- W1 - ADC 22, W0 - ADC 22          - VME: Base + 0x470
		(x"009C", true, true, false, x"00000000"),
		-- W3 - ADC 22, W2 - ADC 22          - VME: Base + 0x474
		(x"009D", true, true, false, x"00000000"),
		-- W5 - ADC 22, W4 - ADC 22          - VME: Base + 0x478
		(x"009E", true, true, false, x"00000000"),
		-- W6 - ADC 22                       - VME: Base + 0x47C
		(x"009F", true, true, false, x"00000000"),
		-- W1 - ADC 23, W0 - ADC 23          - VME: Base + 0x480
		(x"00A0", true, true, false, x"00000000"),
		-- W3 - ADC 23, W2 - ADC 23          - VME: Base + 0x484
		(x"00A1", true, true, false, x"00000000"),
		-- W5 - ADC 23, W4 - ADC 23          - VME: Base + 0x488
		(x"00A2", true, true, false, x"00000000"),
		-- W6 - ADC 23                       - VME: Base + 0x48C
		(x"00A3", true, true, false, x"00000000"),
		-- W1 - ADC 24, W0 - ADC 24          - VME: Base + 0x490
		(x"00A4", true, true, false, x"00000000"),
		-- W3 - ADC 24, W2 - ADC 24          - VME: Base + 0x494
		(x"00A5", true, true, false, x"00000000"),
		-- W5 - ADC 24, W4 - ADC 24          - VME: Base + 0x498
		(x"00A6", true, true, false, x"00000000"),
		-- W6 - ADC 24                       - VME: Base + 0x49C
		(x"00A7", true, true, false, x"00000000"),
		-- W1 - ADC 25, W0 - ADC 25          - VME: Base + 0x4A0
		(x"00A8", true, true, false, x"00000000"),
		-- W3 - ADC 25, W2 - ADC 25          - VME: Base + 0x4A4
		(x"00A9", true, true, false, x"00000000"),
		-- W5 - ADC 25, W4 - ADC 25          - VME: Base + 0x4A8
		(x"00AA", true, true, false, x"00000000"),
		-- W6 - ADC 25                       - VME: Base + 0x4AC
		(x"00AB", true, true, false, x"00000000"),
		-- W1 - ADC 26, W0 - ADC 26          - VME: Base + 0x4B0
		(x"00AC", true, true, false, x"00000000"),
		-- W3 - ADC 26, W2 - ADC 26          - VME: Base + 0x4B4
		(x"00AD", true, true, false, x"00000000"),
		-- W5 - ADC 26, W4 - ADC 26          - VME: Base + 0x4B8
		(x"00AE", true, true, false, x"00000000"),
		-- W6 - ADC 26                       - VME: Base + 0x4BC
		(x"00AF", true, true, false, x"00000000"),
		-- W1 - ADC 27, W0 - ADC 27          - VME: Base + 0x4C0
		(x"00B0", true, true, false, x"00000000"),
		-- W3 - ADC 27, W2 - ADC 27          - VME: Base + 0x4C4
		(x"00B1", true, true, false, x"00000000"),
		-- W5 - ADC 27, W4 - ADC 27          - VME: Base + 0x4C8
		(x"00B2", true, true, false, x"00000000"),
		-- W6 - ADC 27                       - VME: Base + 0x4CC
		(x"00B3", true, true, false, x"00000000"),
		-- W1 - ADC 28, W0 - ADC 28          - VME: Base + 0x4D0
		(x"00B4", true, true, false, x"00000000"),
		-- W3 - ADC 28, W2 - ADC 28          - VME: Base + 0x4D4
		(x"00B5", true, true, false, x"00000000"),
		-- W5 - ADC 28, W4 - ADC 28          - VME: Base + 0x4D8
		(x"00B6", true, true, false, x"00000000"),
		-- W6 - ADC 28                       - VME: Base + 0x4DC
		(x"00B7", true, true, false, x"00000000"),
		-- W1 - ADC 29, W0 - ADC 29          - VME: Base + 0x4E0
		(x"00B8", true, true, false, x"00000000"),
		-- W3 - ADC 29, W2 - ADC 29          - VME: Base + 0x4E4
		(x"00B9", true, true, false, x"00000000"),
		-- W5 - ADC 29, W4 - ADC 29          - VME: Base + 0x4E8
		(x"00BA", true, true, false, x"00000000"),
		-- W6 - ADC 29                       - VME: Base + 0x4EC
		(x"00BB", true, true, false, x"00000000"),

		
		------------------------------------------------------------------------
        -- Page 3
        ------------------------------------------------------------------------
				
		-- W1 - ADC 30, W0 - ADC 30          - VME: Base + 0x400
		(x"00C0", true, true, false, x"00000000"),
		-- W3 - ADC 30, W2 - ADC 30          - VME: Base + 0x404
		(x"00C1", true, true, false, x"00000000"),
		-- W5 - ADC 30, W4 - ADC 30          - VME: Base + 0x408
		(x"00C2", true, true, false, x"00000000"),
		-- W6 - ADC 30                      - VME: Base + 0x40C
		(x"00C3", true, true, false, x"00000000"),
		-- W1 - ADC 31, W0 - ADC 31          - VME: Base + 0x410
		(x"00C4", true, true, false, x"00000000"),
		-- W3 - ADC 25, W2 - ADC 31          - VME: Base + 0x414
		(x"00C5", true, true, false, x"00000000"),
		-- W5 - ADC 25, W4 - ADC 31          - VME: Base + 0x418
		(x"00C6", true, true, false, x"00000000"),
		-- W6 - ADC 31                       - VME: Base + 0x41C
		(x"00C7", true, true, false, x"00000000")
		
		------------------------------------------------------------------------
        ------------------------------------------------------------------------		    
	);
	
-------------------------------------------------------------------------------

end package cRegs_usr;

package body cRegs_usr is
end package body cRegs_usr;
