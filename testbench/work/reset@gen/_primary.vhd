library verilog;
use verilog.vl_types.all;
entity resetGen is
    generic(
        RESET_PERIOD    : integer := 7;
        POWER_ON_RESET  : integer := 1
    );
    port(
        clk             : in     vl_logic;
        resetRequestWord: in     vl_logic_vector(31 downto 0);
        resetOut        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of RESET_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of POWER_ON_RESET : constant is 1;
end resetGen;
