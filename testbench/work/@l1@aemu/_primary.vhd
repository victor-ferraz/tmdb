library verilog;
use verilog.vl_types.all;
entity L1Aemu is
    generic(
        RISE_TH         : integer := 0;
        FALL_TH         : integer := 1;
        LATENCY         : integer := 10
    );
    port(
        clk             : in     vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        l1a             : out    vl_logic;
        bCnt            : out    vl_logic_vector(11 downto 0);
        bCntStr         : out    vl_logic;
        evCntLStr       : out    vl_logic;
        evCntHStr       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of RISE_TH : constant is 1;
    attribute mti_svvh_generic_type of FALL_TH : constant is 1;
    attribute mti_svvh_generic_type of LATENCY : constant is 1;
end L1Aemu;
