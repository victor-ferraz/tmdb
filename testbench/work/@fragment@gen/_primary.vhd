library verilog;
use verilog.vl_types.all;
entity FragmentGen is
    generic(
        BUSY_MARGIN     : integer := 4;
        VME_FULL_MARGIN : integer := 4;
        USE_CHIPSCOPE   : integer := 0
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        sourceIdentifier: in     vl_logic_vector(31 downto 0);
        runNumber       : in     vl_logic_vector(31 downto 0);
        testEn          : in     vl_logic;
        testSel         : in     vl_logic;
        adcConstantSel  : in     vl_logic;
        syncSel         : in     vl_logic;
        holaReset       : in     vl_logic;
        busyOut         : out    vl_logic;
        l1aLatency      : in     vl_logic_vector(7 downto 0);
        l1a             : in     vl_logic;
        bCnt            : in     vl_logic_vector(11 downto 0);
        bCntRes         : in     vl_logic;
        bCntStr         : in     vl_logic;
        evCntRes        : in     vl_logic;
        evCntLStr       : in     vl_logic;
        evCntHStr       : in     vl_logic;
        adcIn           : in     vl_logic_vector(255 downto 0);
        UD              : out    vl_logic_vector(31 downto 0);
        URESET_N        : out    vl_logic;
        UCTRL_N         : out    vl_logic;
        UWEN_N          : out    vl_logic;
        LFF_N           : in     vl_logic;
        LDOWN_N         : in     vl_logic;
        vmeEmptyFlag    : out    vl_logic;
        vmeReadEnable   : in     vl_logic;
        vmeData         : out    vl_logic_vector(31 downto 0);
        trg_sel         : in     vl_logic_vector(3 downto 0);
        ila_control     : inout  vl_logic_vector(35 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BUSY_MARGIN : constant is 1;
    attribute mti_svvh_generic_type of VME_FULL_MARGIN : constant is 1;
    attribute mti_svvh_generic_type of USE_CHIPSCOPE : constant is 1;
end FragmentGen;
