library verilog;
use verilog.vl_types.all;
entity clock is
    generic(
        SIMULATION      : integer := 0
    );
    port(
        clk_in          : in     vl_logic;
        clk_out         : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
end clock;
