library verilog;
use verilog.vl_types.all;
entity FragmentBuilder is
    generic(
        REGISTERED_OUTPUTS: integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        slotInput       : in     vl_logic_vector(824 downto 0);
        objectEnable    : in     vl_logic_vector(4 downto 0);
        readEnable      : out    vl_logic_vector(4 downto 0);
        fullFlag        : in     vl_logic;
        dataOut         : out    vl_logic_vector(32 downto 0);
        writeEnable     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of REGISTERED_OUTPUTS : constant is 1;
end FragmentBuilder;
