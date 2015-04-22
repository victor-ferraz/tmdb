library verilog;
use verilog.vl_types.all;
entity detect is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        cell5           : in     vl_logic_vector(18 downto 0);
        cell6           : in     vl_logic_vector(18 downto 0);
        \out\           : out    vl_logic_vector(3 downto 0);
        LT6             : in     vl_logic_vector(18 downto 0);
        HT6             : in     vl_logic_vector(18 downto 0);
        LT56            : in     vl_logic_vector(18 downto 0);
        HT56            : in     vl_logic_vector(18 downto 0);
        pd6             : out    vl_logic;
        pd56            : out    vl_logic;
        mask6o          : out    vl_logic_vector(18 downto 0);
        mask56o         : out    vl_logic_vector(18 downto 0)
    );
end detect;
