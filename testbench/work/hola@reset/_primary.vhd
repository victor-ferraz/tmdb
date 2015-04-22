library verilog;
use verilog.vl_types.all;
entity holaReset is
    generic(
        LUP_WAIT        : integer := 4
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        holaReset       : in     vl_logic;
        normalOper      : out    vl_logic;
        LDOWN_N         : in     vl_logic;
        URESET_N        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of LUP_WAIT : constant is 1;
end holaReset;
