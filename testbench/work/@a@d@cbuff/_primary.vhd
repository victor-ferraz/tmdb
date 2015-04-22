library verilog;
use verilog.vl_types.all;
entity ADCbuff is
    generic(
        MAX_LATENCY     : integer := 128;
        RB_ADDRESS_WIDTH: integer := 10;
        RB_SIZE         : vl_notype;
        SAMPLES_PER_TRIG: integer := 7;
        WRITE_END       : vl_notype;
        RB_BUSY_MARGIN  : integer := 4;
        WFIFO_FULL_MARGIN: integer := 4
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        l1a             : in     vl_logic;
        l1aLat          : in     vl_logic_vector(7 downto 0);
        adcIn           : in     vl_logic_vector(255 downto 0);
        busyOut         : out    vl_logic;
        rdStb           : in     vl_logic;
        dataOut         : out    vl_logic_vector(255 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_LATENCY : constant is 1;
    attribute mti_svvh_generic_type of RB_ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RB_SIZE : constant is 3;
    attribute mti_svvh_generic_type of SAMPLES_PER_TRIG : constant is 1;
    attribute mti_svvh_generic_type of WRITE_END : constant is 3;
    attribute mti_svvh_generic_type of RB_BUSY_MARGIN : constant is 1;
    attribute mti_svvh_generic_type of WFIFO_FULL_MARGIN : constant is 1;
end ADCbuff;
