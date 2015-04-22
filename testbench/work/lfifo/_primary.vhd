library verilog;
use verilog.vl_types.all;
entity lfifo is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        din             : in     vl_logic_vector(35 downto 0);
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        prog_empty_thresh: in     vl_logic_vector(5 downto 0);
        prog_full_thresh: in     vl_logic_vector(5 downto 0);
        dout            : out    vl_logic_vector(35 downto 0);
        full            : out    vl_logic;
        empty           : out    vl_logic;
        data_count      : out    vl_logic_vector(5 downto 0);
        prog_full       : out    vl_logic;
        prog_empty      : out    vl_logic
    );
end lfifo;
