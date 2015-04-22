library verilog;
use verilog.vl_types.all;
entity L1aProc is
    generic(
        L1A_FULL_MARGIN : integer := 4
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        l1a             : in     vl_logic;
        bCnt            : in     vl_logic_vector(11 downto 0);
        bCntRes         : in     vl_logic;
        bCntStr         : in     vl_logic;
        evCntRes        : in     vl_logic;
        evCntLStr       : in     vl_logic;
        evCntHStr       : in     vl_logic;
        busyIn          : in     vl_logic;
        busyOut         : out    vl_logic;
        rdStb           : in     vl_logic;
        empty           : out    vl_logic;
        fifoIn          : out    vl_logic_vector(35 downto 0);
        dataOut         : out    vl_logic_vector(35 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of L1A_FULL_MARGIN : constant is 1;
end L1aProc;
