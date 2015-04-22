library verilog;
use verilog.vl_types.all;
entity fir is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        adc             : in     vl_logic_vector(7 downto 0);
        weights         : in     vl_logic_vector(69 downto 0);
        \out\           : out    vl_logic_vector(17 downto 0)
    );
end fir;
