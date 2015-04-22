library verilog;
use verilog.vl_types.all;
entity ADCemu is
    generic(
        EVENT_SIZE      : integer := 7;
        LFILL_SIZE      : integer := 10;
        TFILL_SIZE      : integer := 10
    );
    port(
        clk             : in     vl_logic;
        data            : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of EVENT_SIZE : constant is 1;
    attribute mti_svvh_generic_type of LFILL_SIZE : constant is 1;
    attribute mti_svvh_generic_type of TFILL_SIZE : constant is 1;
end ADCemu;
