library verilog;
use verilog.vl_types.all;
entity testData is
    generic(
        L1A_LATENCY     : integer := 100;
        L1A_PERIOD      : integer := 400
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        l1a             : out    vl_logic;
        bCnt            : out    vl_logic_vector(11 downto 0);
        bCntStr         : out    vl_logic;
        evCntLStr       : out    vl_logic;
        evCntHStr       : out    vl_logic;
        dataOut         : out    vl_logic_vector(255 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of L1A_LATENCY : constant is 1;
    attribute mti_svvh_generic_type of L1A_PERIOD : constant is 1;
end testData;
