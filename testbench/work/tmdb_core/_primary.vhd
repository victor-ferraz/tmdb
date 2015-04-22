library verilog;
use verilog.vl_types.all;
entity tmdb_core is
    generic(
        SIMULATION      : integer := 1;
        USE_CHIPSCOPE   : integer := 0;
        USE_GTP         : integer := 0;
        USE_MPU         : integer := 1;
        USE_LVDS        : integer := 1;
        USE_FRAG_GEN    : integer := 1;
        REGS_QTY        : integer := 17;
        REGS_DATA_WIDTH : integer := 32;
        FIRMWARE_VERSION: integer := 10;
        BOARD_ID        : integer := 1
    );
    port(
        clk_in          : in     vl_logic;
        clk_out         : out    vl_logic_vector(15 downto 0);
        adc_in          : in     vl_logic_vector(255 downto 0);
        lvdsL_conn      : inout  vl_logic_vector(15 downto 0);
        lvdsL_TXlo      : out    vl_logic;
        lvdsL_TXhi      : out    vl_logic;
        lvdsR_conn      : inout  vl_logic_vector(15 downto 0);
        lvdsR_TXlo      : out    vl_logic;
        lvdsR_TXhi      : out    vl_logic;
        ttc_bcnt        : in     vl_logic_vector(11 downto 0);
        ttc_bcntstr     : in     vl_logic;
        ttc_bcntres     : in     vl_logic;
        ttc_l1accept    : in     vl_logic;
        ttc_evcntres    : in     vl_logic;
        ttc_evcntlstr   : in     vl_logic;
        ttc_evcnthstr   : in     vl_logic;
        TILE0_GTP1_REFCLK_PAD_N_IN: in     vl_logic;
        TILE0_GTP1_REFCLK_PAD_P_IN: in     vl_logic;
        SFP_ENABLE      : out    vl_logic_vector(3 downto 0);
        RXN_IN          : in     vl_logic;
        RXP_IN          : in     vl_logic;
        TXN_OUT         : out    vl_logic_vector(3 downto 0);
        TXP_OUT         : out    vl_logic_vector(3 downto 0);
        fi_data         : inout  vl_logic_vector(7 downto 0);
        fi_addr         : in     vl_logic_vector(5 downto 0);
        fi_write        : inout  vl_logic;
        fi_read         : inout  vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
    attribute mti_svvh_generic_type of USE_CHIPSCOPE : constant is 1;
    attribute mti_svvh_generic_type of USE_GTP : constant is 1;
    attribute mti_svvh_generic_type of USE_MPU : constant is 1;
    attribute mti_svvh_generic_type of USE_LVDS : constant is 1;
    attribute mti_svvh_generic_type of USE_FRAG_GEN : constant is 1;
    attribute mti_svvh_generic_type of REGS_QTY : constant is 1;
    attribute mti_svvh_generic_type of REGS_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FIRMWARE_VERSION : constant is 1;
    attribute mti_svvh_generic_type of BOARD_ID : constant is 1;
end tmdb_core;
