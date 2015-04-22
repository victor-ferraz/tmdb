library verilog;
use verilog.vl_types.all;
entity MPU is
    generic(
        USE_CHIPSCOPE   : integer := 1
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        adc_in          : in     vl_logic_vector(255 downto 0);
        weights_m       : in     vl_logic_vector(2239 downto 0);
        LT6p            : in     vl_logic_vector(151 downto 0);
        HT6p            : in     vl_logic_vector(151 downto 0);
        LT56p           : in     vl_logic_vector(151 downto 0);
        HT56p           : in     vl_logic_vector(151 downto 0);
        ext_mod0        : in     vl_logic_vector(3 downto 0);
        ext_mod9        : in     vl_logic_vector(3 downto 0);
        ext_mod1        : out    vl_logic_vector(3 downto 0);
        ext_mod8        : out    vl_logic_vector(3 downto 0);
        sl1             : out    vl_logic_vector(15 downto 0);
        sl2             : out    vl_logic_vector(15 downto 0);
        sl3             : out    vl_logic_vector(15 downto 0);
        ila_control     : inout  vl_logic_vector(35 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of USE_CHIPSCOPE : constant is 1;
end MPU;
