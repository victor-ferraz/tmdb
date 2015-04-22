library verilog;
use verilog.vl_types.all;
entity cell_ene is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        ch1             : in     vl_logic_vector(7 downto 0);
        ch2             : in     vl_logic_vector(7 downto 0);
        weights1        : in     vl_logic_vector(69 downto 0);
        weights2        : in     vl_logic_vector(69 downto 0);
        \out\           : out    vl_logic_vector(18 downto 0);
        fir1_out        : out    vl_logic_vector(17 downto 0);
        fir2_out        : out    vl_logic_vector(17 downto 0)
    );
end cell_ene;
