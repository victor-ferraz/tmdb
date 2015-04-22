library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

--use work.txt_util.all;

entity vme_stimulus is
  
  generic (
    slot_number : integer range 0 to 31 := 09;
    dsdn_delay  : time                  := 30 ns;
    dsup_delay  : time                  := 30 ns;
    asup_delay  : time                  := 30 ns);

  port (
    clock        : in     std_logic;
    vme_addr     : buffer std_logic_vector(31 downto 1);
    vme_am       : out    std_logic_vector(5 downto 0);
    vme_as       : buffer std_logic;
    vme_berr     : inout  std_logic;
    vme_data     : inout  std_logic_vector(31 downto 0);
    vme_ds0      : buffer std_logic;
    vme_ds1      : buffer std_logic;
    vme_dtack    : inout  std_logic;
    vme_ga       : out    std_logic_vector(4 downto 0);
    vme_gap      : out    std_logic;
    vme_iack     : buffer std_logic;
    vme_iack_in  : buffer std_logic;
    vme_iack_out : in     std_logic;
    vme_irq      : in     std_logic_vector(7 downto 1);
    vme_retry    : in     std_logic;
    vme_sysclock : out    std_logic;
    vme_sysreset : out    std_logic;
    vme_write    : buffer std_logic;
    vme_lword    : out    std_logic);       

end vme_stimulus;

-------------------------------------------------------------------------------

architecture behavioral of vme_stimulus is

  type integer_vector is array (natural range <>) of integer;

-- constants

  constant ALLZ32 : std_logic_vector (31 downto 0) := (others => 'Z');
  constant ALLZ25 : std_logic_vector (24 downto 0) := (others => 'Z');

  constant clock_period     : time := 12.5 ns; --one half cycle period
  constant sysclk_period    : time := 62.5 ns; --one half cycle period
  constant init_time        : time := 200 ns;
  constant exit_time        : time := 200 ns;
  constant setup_time       : time := 10 ns;
  constant as_lo_min_time   : time := 30 ns;
  constant as_hi_min_time   : time := 30 ns;
  constant ds_hi_min_time   : time := 30 ns;
  constant ds_lo_min_time   : time := 30 ns;
  constant iack_up_max_time : time := 30 ns;
  constant iak_time         : time := 30 ns;
  constant bto_time         : time := 5000 ns; --1000ns
  constant addr_hold_time   : time := 1 ns;
  constant MAX_BURST_LENGTH : integer := 1024;
  
-- signals

  type vme_data_array is array (0 to MAX_BURST_LENGTH-1) of std_logic_vector(31 downto 0);

  shared variable i_user_delay : time := 0 ns;

  signal finished : boolean := false;

  signal max_clock_read_up  : real    := 0.0;
  signal min_clock_read_up  : real    := real(time'pos(2*clock_period))/1.0E6;
  signal num_clock_read_up  : integer := 0;
  signal max_clock_write_up : real    := 0.0;
  signal min_clock_write_up : real    := real(time'pos(2*clock_period))/1.0E6;
  signal num_clock_write_up : integer := 0;
  signal max_clock_am_up    : real    := 0.0;
  signal min_clock_am_up    : real    := real(time'pos(2*clock_period))/1.0E6;
  signal num_clock_am_up    : integer := 0;
  signal max_clock_addr_up  : real    := 0.0;
  signal min_clock_addr_up  : real    := real(time'pos(2*clock_period))/1.0E6;
  signal num_clock_addr_up  : integer := 0;
  signal max_clock_data_up  : real    := 0.0;
  signal min_clock_data_up  : real    := real(time'pos(2*clock_period))/1.0E6;
  signal num_clock_data_up  : integer := 0;

  signal i_user_data : std_logic_vector(31 downto 0);  -- expected data on VME bus
  signal i_dtack     : std_logic;
  signal i_berr      : std_logic;

  file in_file  : text open read_mode is "vmeif_in.txt";
  file out_file : text open write_mode is "vmeif_out.txt";
------------------------------------------------------------------------------
-- convert std_logic to string
------------------------------------------------------------------------------

  function toString(value : in std_logic) return string is
    variable c : character;
    variable s : string(1 to 1);
  begin
    -- map value to character
    case value is
      when '0'    => c := '0';
      when '1'    => c := '1';
      when 'Z'    => c := 'Z';
      when 'U'    => c := 'U';
      when 'X'    => c := 'X';
      when others => c := 'E';
    end case;

    s(1) := c;
    return(s);
    
  end function toString;

------------------------------------------------------------------------------
-- convert std_logic_vector to string
------------------------------------------------------------------------------

  function toString(vector : in std_logic_vector) return string is
    variable i : integer;
    variable j : integer;
    variable v : integer;
    variable c : character;
    variable s : string(1 to ((vector'length - 1)/4 + 1));
  begin

    i := vector'low - 1;
    j := ((vector'length - 1)/4 + 1);
    while (i < vector'high) loop

      -- calculate value in nibble
      v := 0;
      for k in 0 to 3 loop
        i := i + 1;
        exit when (i = (vector'high + 1));
        case vector(i) is
          when '0'    => v := v;
          when '1'    => v := v + 2**k;
          when 'Z'    => v := v + 16;
          when 'U'    => v := v + 128;
          when 'X'    => v := v + 1024;
          when others => v := v + 8192;
        end case;
      end loop;

      -- map value to character
      case v is
        when 0            => c := '0';
        when 1            => c := '1';
        when 2            => c := '2';
        when 3            => c := '3';
        when 4            => c := '4';
        when 5            => c := '5';
        when 6            => c := '6';
        when 7            => c := '7';
        when 8            => c := '8';
        when 9            => c := '9';
        when 10           => c := 'A';
        when 11           => c := 'B';
        when 12           => c := 'C';
        when 13           => c := 'D';
        when 14           => c := 'E';
        when 15           => c := 'F';
        when 16 to 127    => c := 'Z';
        when 128 to 1023  => c := 'U';
        when 1024 to 8191 => c := 'X';
        when others       => c := 'E';
      end case;
      s(j) := c;
      j    := j - 1;
    end loop;

    return s;
    
  end function toString;

------------------------------------------------------------------------------
-- convert string to std_logic_vector
------------------------------------------------------------------------------

  function fromString(istring : in string) return std_logic_vector is
    variable j : integer;
    variable c : character;
    variable v : std_logic_vector(3 downto 0);
    variable s : std_logic_vector((istring'length*4 - 1) downto 0);
  begin

    for i in 1 to istring'length loop

      c := istring(i);
      case c is
        when '0'       => v := "0000";
        when '1'       => v := "0001";
        when '2'       => v := "0010";
        when '3'       => v := "0011";
        when '4'       => v := "0100";
        when '5'       => v := "0101";
        when '6'       => v := "0110";
        when '7'       => v := "0111";
        when '8'       => v := "1000";
        when '9'       => v := "1001";
        when 'A' | 'a' => v := "1010";
        when 'B' | 'b' => v := "1011";
        when 'C' | 'c' => v := "1100";
        when 'D' | 'd' => v := "1101";
        when 'E' | 'e' => v := "1110";
        when 'F' | 'f' => v := "1111";
        when 'Z' | 'z' => v := "ZZZZ";
        when 'U' | 'u' => v := "UUUU";
        when 'X' | 'x' => v := "XXXX";
        when others    => v := "XXXX";
      end case;

      j                         := istring'length - i;
      s((j*4 + 3) downto (j*4)) := v;
      
    end loop;

    return s;
    
  end function fromString;

------------------------------------------------------------------------------



begin

  vme_dtack <= 'H';                   -- pull-up for DTACK
  vme_berr  <= 'H';                   -- pull-up for BERR
  
  i_dtack   <= to_X01(vme_dtack);
  i_berr    <= to_X01(vme_berr);

------------------------------------------------------------------------------
-- generate clock
------------------------------------------------------------------------------

  sysclk_gen : process
    variable clk : std_logic := '0';
  begin
    vme_sysclock <= '0';
    while not finished loop
      wait for sysclk_period;
      clk          := not clk;
      vme_sysclock <= clk;
    end loop;
    wait;
  end process sysclk_gen;

------------------------------------------------------------------------------
-- main process
------------------------------------------------------------------------------

  always : process

    -- variables for statistics
    variable s_ds_dtack_down_sgl : real    := 0.0;
    variable n_ds_dtack_down_sgl : integer := 0;
    variable s_ds_dtack_down_blt : real    := 0.0;
    variable n_ds_dtack_down_blt : integer := 0;
    variable s_ds_dtack_down_iak : real    := 0.0;
    variable n_ds_dtack_down_iak : integer := 0;
    variable s_ds_dtack_up       : real    := 0.0;
    variable n_ds_dtack_up       : integer := 0;

    variable last_as_up_time : time    := 0 ns;
    variable last_ds_up_time : time    := 0 ns;
    variable wait_ds_up_time : time    := 0 ns;
    variable last_rdir       : boolean := true;

------------------------------------------------------------------------------
-- reset procedure
------------------------------------------------------------------------------

    procedure RST(srst : std_logic) is
    begin
      vme_sysreset <= srst;
    end procedure RST;

------------------------------------------------------------------------------
-- geographical address
------------------------------------------------------------------------------

    procedure GA(gadd : std_logic_vector(7 downto 0);
                 gpar : std_logic) is
    begin
      vme_ga  <= not gadd(4 downto 0);
      vme_gap <= gpar;
    end procedure GA;

------------------------------------------------------------------------------
-- helper function: as up
------------------------------------------------------------------------------

    procedure as_up is
    begin

      -- master releases as
      vme_as          <= '1';
      wait for addr_hold_time;
      vme_addr        <= (others => 'Z');
      vme_am          <= (others => 'Z');
      last_as_up_time := now;
      
    end procedure as_up;

------------------------------------------------------------------------------
-- helper function: as up
------------------------------------------------------------------------------

    procedure as_dn is
    begin

      -- master drives as
      vme_as <= '0';
      
    end procedure as_dn;

------------------------------------------------------------------------------
-- helper function: ds up
------------------------------------------------------------------------------

    procedure ds_up is
    begin

      -- master releases ds
      vme_ds0 <= '1';
      vme_ds1 <= '1';
      if not(last_rdir) then
        vme_data <= (others => 'Z');
      end if;
      last_ds_up_time := now;
      wait_ds_up_time := 0 ns;
      
    end procedure ds_up;

------------------------------------------------------------------------------
-- helper function: dtack up
------------------------------------------------------------------------------

    procedure dtack_up is
    begin

      -- check if data still trailing
      if (vme_data /= ALLZ32) then
      --assert false report ">>>> violation of rule 2.58a (31): data trailing " &
      --     "after dtack up, expected '" & "ZZZZZZZZ" & "' read '" &
      --     toString(vme_data) & "'";
      end if;

      -- report time ds up to dtack up
      --report "---- time ds up   to dtack up   : " & time'image(now - last_ds_up_time);

      -- collect statistics
      s_ds_dtack_up := s_ds_dtack_up + real(time'pos(now - last_ds_up_time))/1.0E6;
      n_ds_dtack_up := n_ds_dtack_up + 1;
      
    end procedure dtack_up;

------------------------------------------------------------------------------
-- helper function: finish cycle - leave after as up
------------------------------------------------------------------------------
    
    procedure finish_cycle(dsup : time;
                           asup : time;
                           rdir : boolean) is
      variable run_time   : time := 0 ns;
      variable start_time : time := 0 ns;
    begin

      last_rdir := rdir;

      -- master releases as or ds
      if (dsup < asup) then
        wait for dsup;
        run_time   := dsup;
        start_time := now;
        ds_up;
        wait until i_dtack = '1' for (asup - run_time);
        -------- ds - dtack - as --------
        if (i_dtack = '1') then
          dtack_up;
          run_time := run_time + (now - start_time);
          wait for (asup - run_time);
          as_up;
        else
          -------- ds - as - dtack --------
          as_up;
        -- return immediatly and let next cycle finish
        end if;
      elsif (dsup = asup) then
        -------- ds - as - dtack --------
        wait for dsup_delay;
        run_time := dsup;
        ds_up;
        as_up;
      -- return immediately and let next cycle finish
      else
        -------- as - ds - dtack --------
        wait for asup_delay;
        run_time        := asup;
        as_up;
        wait_ds_up_time := (dsup - run_time);
      -- return immediately and let next cycle finish
      end if;

    end procedure finish_cycle;

------------------------------------------------------------------------------
-- helper function: begin cycle - finish previous cycle if necessary
------------------------------------------------------------------------------

    procedure begin_cycle is
      variable start_time        : time;
      variable wait_as_down_time : time;
    begin

      -- calculate maximum time to wait before driving as down
      start_time := now;
      if ((as_hi_min_time - (start_time - last_as_up_time)) < setup_time) then
        wait_as_down_time := setup_time;
      else
        wait_as_down_time := (as_hi_min_time - (start_time - last_as_up_time));
      end if;

      -- wait for dtack up, ds up or as down
      if (i_dtack /= '1') and
        (wait_ds_up_time > 0 ns and wait_ds_up_time < wait_as_down_time) then
        wait until i_dtack = '1' for wait_ds_up_time;
        if i_dtack /= '1' then
          -------- ds up - as down - dtack up --------
          ds_up;
          wait_ds_up_time := 0 ns;
          wait until i_dtack = '1' for (wait_as_down_time - (now - start_time));
          if i_dtack /= '1' then
            as_dn;
            wait until i_dtack = '1';
            dtack_up;
          -------- ds up - dtack up - as down --------
          else
            dtack_up;
            wait for (wait_as_down_time - (now - start_time));
            as_dn;
          end if;
        end if;
      elsif (i_dtack /= '1') and
        (wait_ds_up_time > 0 ns and wait_ds_up_time >= wait_as_down_time) then
        wait until i_dtack = '1' for wait_as_down_time;
        if i_dtack /= '1' then
          -------- as down - ds up - dtack up --------
          as_dn;
          wait until i_dtack = '1' for (wait_ds_up_time - (now - start_time));
          if i_dtack /= '1' then
            ds_up;
            wait until i_dtack = '1';
            dtack_up;
          end if;
        end if;

      -- ds already up: wait for dtack up or as down
      elsif (i_dtack /= '1' and wait_ds_up_time = 0 ns) then
        wait until i_dtack = '1' for wait_as_down_time;
        if i_dtack /= '1' then
          -------- as down - dtack up --------
          as_dn;
          wait until i_dtack = '1';
          dtack_up;
        else
          -------- dtack up - as down --------
          dtack_up;
          wait for wait_as_down_time - (now -start_time);
          as_dn;
        end if;

      -- dtack already up: wait ds up or as down
      else
        if (wait_ds_up_time > 0 ns and wait_ds_up_time < wait_as_down_time) then
          wait for wait_ds_up_time;
          ds_up;
          wait for (wait_as_down_time - (now -start_time));
          as_dn;
        elsif (wait_ds_up_time > 0 ns and wait_ds_up_time >= wait_as_down_time) then
          wait for wait_as_down_time;
          as_dn;
          wait for wait_ds_up_time - (now - start_time);
          ds_up;
        else
          wait for wait_as_down_time;
          as_dn;
        end if;
      end if;

    end procedure begin_cycle;

------------------------------------------------------------------------------
-- helper function: clean-up after berr
------------------------------------------------------------------------------

    procedure berr is
    begin

      -- release DTB
      vme_as      <= '1';
      vme_ds0     <= '1';
      vme_ds1     <= '1';
      vme_am      <= (others => 'Z');
      vme_addr    <= (others => 'Z');
      vme_data    <= (others => 'Z');

      -- wait until berr finished
      wait until i_berr = '1';
      
    end procedure berr;

------------------------------------------------------------------------------
-- read single cycle
------------------------------------------------------------------------------
    
    procedure RS(addr : std_logic_vector(31 downto 0);
                 am   : std_logic_vector(7 downto 0);
                 data : std_logic_vector(31 downto 0);
                 dsdn : time;
                 dsup : time;
                 asup : time) is

      variable start_time : time;
      variable min_time   : time;
      variable max_time   : time;
      variable ds_flag    : boolean;

      variable out_line : line;

    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';

      -- begin cycle
      begin_cycle;

      vme_write   <= '1';

      -- drive ds (no distinction between dsa and dsb!!!!)
      if (now - last_ds_up_time < ds_hi_min_time) then
        wait for (ds_hi_min_time - (now - last_ds_up_time));
      end if;
      wait for dsdn;
      vme_ds0    <= '0';
      vme_ds1    <= '0';
      start_time := now;

      -- wait for dtack down or bus error
      wait until i_dtack = '0' or i_berr = '0';
      if (i_berr = '0') then
        berr;
        return;
      end if;
      --report "---- time ds down to dtack down: " & time'image(now - start_time);
      WRITE(out_line, "time: " & time'image(now) &"  read data: " & tostring(vme_data) & "  on address: " & toString(addr));
      --report "addr: " & toString(addr) & "  read: " & tostring(vme_data) severity note;  --
      if vme_data /= data then
        report "READ DATA != EXPECTED DATA on address: " & toString(addr) &
          " read: " & tostring(vme_data) & "  expected: " & tostring(data) severity warning;
        WRITE(out_line, " expected: " & tostring(data)& "  WARNING");
      else
        WRITE(out_line, string'(" ok "));
      end if;

      writeline(out_file, out_line);
      -- klofver
      if (now - start_time < 30 ns) then
        report ">>>> violation of rule 2.55 (28): ds down to dtack down " & "in less than 30 ns";
      end if;
      s_ds_dtack_down_sgl := s_ds_dtack_down_sgl +
                             real(time'pos(now - start_time - i_user_delay))/1.0E6;
      n_ds_dtack_down_sgl := n_ds_dtack_down_sgl + 1;

      -- finish cycle
      finish_cycle(dsup, asup, true);

    end procedure RS;

------------------------------------------------------------------------------
-- read single cycle masked check      klofver
------------------------------------------------------------------------------
    
    procedure RSM(addr : std_logic_vector(31 downto 0);
                  am   : std_logic_vector(7 downto 0);
                  data : std_logic_vector(31 downto 0);
                  dsdn : time;
                  dsup : time;
                  asup : time;
                  mask : std_logic_vector(31 downto 0)) is 
      variable start_time : time;
      variable min_time   : time;
      variable max_time   : time;
      variable ds_flag    : boolean;

      variable out_line : line;

      variable data_masked, vme_data_masked : std_logic_vector(31 downto 0);  -- klofver
      

    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';

      -- begin cycle
      begin_cycle;

      vme_write   <= '1';

      -- drive ds (no distinction between dsa and dsb!!!!)
      if (now - last_ds_up_time < ds_hi_min_time) then
        wait for (ds_hi_min_time - (now - last_ds_up_time));
      end if;
      wait for dsdn;
      vme_ds0    <= '0';
      vme_ds1    <= '0';
      start_time := now;

      -- wait for dtack down or bus error
      wait until i_dtack = '0' or i_berr = '0';
      if (i_berr = '0') then
        berr;
        return;
      end if;
      vme_data_masked := vme_data and mask;
      data_masked     := data and mask;
      --report "---- time ds down to dtack down: " & time'image(now - start_time);
      WRITE(out_line, "time: " & time'image(now) & " addr: " & toString(addr) & "  read: (" & tostring(vme_data) & " and " & toString(mask)& ") = "& toString(vme_data_masked));
--      report "addr: " & toString(addr) & "  read: " & tostring(vme_data) severity note;  --
      if (vme_data_masked) /= (data_masked) then
        report "READ DATA != EXPECTED DATA on address: " & toString(addr) & " read: " & tostring(vme_data) & "  expected: " & tostring(data) severity warning;
        WRITE(out_line, " expected: " & tostring(data)& "  WARNING");
      else
        WRITE(out_line, string'("  ok "));
      end if;

      --  WRITE(out_line," vmedata and mask" & toString(vme_data and mask));
      --  WRITE(out_line, " data and mask" & toString(data and mask));

      writeline(out_file, out_line);
      -- klofver
      if (now - start_time < 30 ns) then
        assert false report ">>>> violation of rule 2.55 (28): ds down to dtack down " &
          "in less than 30 ns";
      end if;
      s_ds_dtack_down_sgl := s_ds_dtack_down_sgl +
                             real(time'pos(now - start_time - i_user_delay))/1.0E6;
      n_ds_dtack_down_sgl := n_ds_dtack_down_sgl + 1;

      -- finish cycle
      finish_cycle(dsup, asup, true);

    end procedure RSM;



------------------------------------------------------------------------------
-- write single cycle
------------------------------------------------------------------------------
    
    procedure WS(addr : std_logic_vector(31 downto 0);
                 am   : std_logic_vector(7 downto 0);
                 data : std_logic_vector(31 downto 0);
                 dsdn : time;
                 dsup : time;
                 asup : time) is 
      variable start_time : time;
    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';

      -- begin cycle
      begin_cycle;

      vme_write   <= '0';
      vme_data    <= data;

      -- drive ds (no distinction between dsa and dsb!!!!)
      if (now - last_ds_up_time < ds_hi_min_time) then
        wait for (ds_hi_min_time - (now - last_ds_up_time));
      end if;
      wait for dsdn;
      vme_ds0    <= '0';
      vme_ds1    <= '0';
      start_time := now;

      -- wait for dtack down or bus error
      wait until i_dtack = '0' or i_berr = '0';
      if (i_berr = '0') then
        berr;
        return;
      end if;
      -- report "---- time ds down to dtack down: " & time'image(now - start_time);
      if (now - start_time < 30 ns) then
        assert false report ">>>> violation of rule 2.55 (28): ds down to dtack down " &
          "in less than 30 ns";
      end if;
      s_ds_dtack_down_sgl := s_ds_dtack_down_sgl +
                             real(time'pos(now - start_time - i_user_delay))/1.0E6;
      n_ds_dtack_down_sgl := n_ds_dtack_down_sgl + 1;

      -- finish cycle
      finish_cycle(dsup, asup, false);
      
    end procedure WS;

------------------------------------------------------------------------------
-- read block cycle
------------------------------------------------------------------------------
    
    procedure RB(addr : std_logic_vector(31 downto 0);
                 am   : std_logic_vector(7 downto 0);
                 data : vme_data_array; --std_logic_vector(31 downto 0);
                 mask : std_logic_vector(31 downto 0);
                 num  : integer;
                 dsdn : time;
                 dsup : time;
                 asup : time) is 

      variable start_time : time;
      variable out_line : line;
      variable data_masked, vme_data_masked : std_logic_vector(31 downto 0);  -- klofver
      
    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';

      -- begin cycle
      begin_cycle;

      vme_write <= '1';

      for i in 0 to num-1 loop

        -- drive ds (no distinction between dsa and dsb!!!!
        if (now - last_ds_up_time < ds_hi_min_time) then
          wait for (ds_hi_min_time - (now - last_ds_up_time));
        end if;
        wait for dsdn;
        vme_ds0    <= '0';
        vme_ds1    <= '0';
        start_time := now;

        -- wait for dtack down or bus error
        wait until i_dtack = '0' or i_berr = '0';
        if (i_berr = '0') then
          berr;
          return;
        end if;

        -- check the data
        vme_data_masked := vme_data and mask;
        data_masked     := data(i) and mask;
        WRITE(out_line, "time: " & time'image(now) &"  read data: " & tostring(vme_data) & "  on address: " & toString(addr));
        --report "addr: " & toString(addr) & "  read: " & tostring(vme_data) severity note;  --
        if vme_data_masked /= data_masked then
          report "READ DATA != EXPECTED DATA on address: " & toString(addr) & " read: " & tostring(vme_data) & "  expected: " & tostring(data(i)) severity warning;
          WRITE(out_line, " expected: " & tostring(data(i))& "  WARNING");
        else
          WRITE(out_line, string'(" ok "));
        end if;
        writeline(out_file, out_line);
        
        --report "---- time ds down to dtack down: " & time'image(now - start_time);
        if (now - start_time < 30 ns) then
          assert false report ">>>> violation of rule 2.55 (28): ds down to dtack down " &
            "in less than 30 ns";
        end if;
        if (i = 1) then
          s_ds_dtack_down_sgl := s_ds_dtack_down_sgl +
                                 real(time'pos(now - start_time - i_user_delay))/1.0E6;
          n_ds_dtack_down_sgl := n_ds_dtack_down_sgl + 1;
        else
          s_ds_dtack_down_blt := s_ds_dtack_down_blt +
                                 real(time'pos(now - start_time - i_user_delay))/1.0E6;
          n_ds_dtack_down_blt := n_ds_dtack_down_blt + 1;
        end if;

        if (i < num-1) then
          -- wait for master to release ds
          wait for dsup;
          last_ds_up_time := now;
          vme_ds0         <= '1';
          vme_ds1         <= '1';

          -- wait for dtack up
          wait until i_dtack = '1';
          if (vme_data /= ALLZ32) then
            report ">>>> violation of rule 2.58a (31): data trailing " &
              "after dtack up, expected '" & "ZZZZZZZZ" & "' read '" &
              toString(vme_data) & "'";
          end if;
          --report "---- time ds up   to dtack up   : " & time'image(now - last_ds_up_time);
          s_ds_dtack_up := s_ds_dtack_up + real(time'pos(now - last_ds_up_time))/1.0E6;
          n_ds_dtack_up := n_ds_dtack_up + 1;
--        i_user_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(i_user_addr)+4),32));
        end if;
      end loop;

      -- finish cycle
      finish_cycle(dsup, asup, true);
      
    end procedure RB;

------------------------------------------------------------------------------
-- write block cycle
------------------------------------------------------------------------------
    
    procedure WB(addr : std_logic_vector(31 downto 0);
                 am   : std_logic_vector(7 downto 0);
                 data : vme_data_array; --std_logic_vector(31 downto 0);
                 num  : integer;
                 dsdn : time;
                 dsup : time;
                 asup : time) is 
      variable start_time : time;
    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';

      -- begin cycle
      begin_cycle;

      vme_write <= '0';

      for i in 0 to num-1 loop
        vme_data    <= data(i);

        -- drive ds (no distinction between dsa and dsb!!!!
        if (now - last_ds_up_time < ds_hi_min_time) then
          wait for (ds_hi_min_time - (now - last_ds_up_time));
        end if;
        wait for dsdn;
        vme_ds0    <= '0';
        vme_ds1    <= '0';
        start_time := now;

        -- wait for dtack down or bus error
        wait until i_dtack = '0' or i_berr = '0';
        if (i_berr = '0') then
          berr;
          return;
        end if;
        --report "---- time ds down to dtack down: " & time'image(now - start_time);
        if (now - start_time < 30 ns) then
          assert false report ">>>> violation of rule2.55 (28): ds down to dtack down " &
            "in less than 30 ns";
        end if;
        if (i = 1) then
          s_ds_dtack_down_sgl := s_ds_dtack_down_sgl +
                                 real(time'pos(now - start_time - i_user_delay))/1.0E6;
          n_ds_dtack_down_sgl := n_ds_dtack_down_sgl + 1;
        else
          s_ds_dtack_down_blt := s_ds_dtack_down_blt +
                                 real(time'pos(now - start_time - i_user_delay))/1.0E6;
          n_ds_dtack_down_blt := n_ds_dtack_down_blt + 1;
        end if;

        if (i < num) then
          -- wait for master to release ds
          wait for dsup;
          last_ds_up_time := now;
          vme_ds0         <= '1';
          vme_ds1         <= '1';
          vme_data        <= (others => 'Z');
          last_ds_up_time := now;

          -- wait for dtack up
          wait until i_dtack = '1';
          --report "---- time ds up   to dtack up   : " & time'image(now - last_ds_up_time);
          s_ds_dtack_up := s_ds_dtack_up + real(time'pos(now - last_ds_up_time))/1.0E6;
          n_ds_dtack_up := n_ds_dtack_up + 1;
        end if;
      end loop;

      -- finish cycle
      finish_cycle(dsup, asup, false);

    end procedure WB;

------------------------------------------------------------------------------
-- interrupt acknowledge cycle
------------------------------------------------------------------------------
    
    procedure IAK(level : std_logic_vector(3 downto 0);
                  data  : std_logic_vector(31 downto 0);
                  dsdn  : time;
                  dsup  : time;
                  asup  : time) is
      variable start_time : time;
    begin

      -- write addr, lword, iack and write
      vme_addr  <= x"0000000" & level(2 downto 0);
      vme_lword <= '1';
      vme_iack  <= '0';

      -- begin cycle
      begin_cycle;

      vme_write   <= '1';

      -- drive as and ds (no distinction between dsa and dsb!!!!)
      -- drive ds (no distinction between dsa and dsb!!!!
      if (now - last_ds_up_time < ds_hi_min_time) then
        wait for (ds_hi_min_time - (now - last_ds_up_time));
      end if;
      wait for dsdn;
      vme_ds0    <= '0';
      vme_ds1    <= '0';
      start_time := now;

      wait for iak_time;

      -- drive iack_in
      vme_iack_in <= '0';

      -- wait for dtack down (repsonding interrupter) or
      --          iack_out down (participating interrupter)
      wait until i_dtack /= '1' or vme_iack_out = '0';

      -- responding interrupter
      if(i_dtack /= '1') then
        --report "---- time ds down to dtack down: " & time'image(now - start_time);
        if (now - start_time < 30 ns) then
          assert false report ">>>> violation of rule 2.55 (28): ds down to dtack down " &
            "in less than 30 ns";
        end if;
        s_ds_dtack_down_iak := s_ds_dtack_down_iak +
                               real(time'pos(now - start_time - iak_time))/1.0E6;
        n_ds_dtack_down_iak := n_ds_dtack_down_iak + 1;

        -- finish cycle
        finish_cycle(dsup, asup, true);

        -- drive iack and iack_in high
        vme_iack    <= '1';
        wait for iack_up_max_time;
        vme_iack_in <= '1';

      -- participating interrupter
      elsif (vme_iack_out = '0') then

        -- wait for other interrupter to finish cycle
        wait for 2 * iak_time;

        -- release as and ds   
        vme_ds0         <= '1';
        vme_ds1         <= '1';
        vme_as          <= '1';
        vme_addr        <= (others => 'Z');
        vme_iack        <= '1';
        vme_iack_in     <= '1';
        last_as_up_time := now;
      end if;

    end procedure IAK;

------------------------------------------------------------------------------
-- synchronization with clock
------------------------------------------------------------------------------

    procedure SYN(lvl : std_logic) is
    begin
      wait until clock'event and clock = lvl;
    end procedure SYN;

------------------------------------------------------------------------------
-- address-only cycle
------------------------------------------------------------------------------
    
    procedure ADO(addr : std_logic_vector(31 downto 0);
                  am   : std_logic_vector(7 downto 0);
                  asup : time) is 
      variable start_time : time;
    begin

      -- write am, addr, lword, iack and write
      vme_am    <= am(5 downto 0);
      vme_addr  <= addr(31 downto 1);
      vme_lword <= '1';
      vme_iack  <= '1';
      ds_up;

      wait for setup_time;              -- observation 2.52 (4) 
      if (now - last_as_up_time < as_hi_min_time) then  -- observation 2.53 (5) 
        wait for (as_hi_min_time - (now - last_as_up_time));
      end if;

      -- drive as
      vme_as <= '0';

      -- wait for master to release as
      wait for as_lo_min_time + asup;
      vme_as          <= '1';
      vme_addr        <= (others => 'Z');
      vme_am          <= (others => 'Z');
      last_as_up_time := now;
      
    end procedure ADO;

------------------------------------------------------------------------------
-- clear DTB
------------------------------------------------------------------------------

    procedure CLR is
    begin
      vme_ds0         <= '1';
      vme_ds1         <= '1';
      vme_as          <= '1';
      vme_addr        <= (others => 'Z');
      vme_am          <= (others => 'Z');
      vme_data        <= (others => 'Z');
      vme_iack        <= '1';
      vme_iack_in     <= '1';
      last_as_up_time := now;
    end procedure CLR;

------------------------------------------------------------------------------
-- variables
------------------------------------------------------------------------------

    -- variables for input
    variable in_line  : line;
    variable out_line : line;
    variable in_rtnv  : boolean;
    variable in_cmd   : string(1 to 3);
    variable space    : character;
    variable strg8_a  : string(1 to 8);
    variable strg8_b  : string(1 to 8);
    variable strg8_c  : string(1 to 8);  -- klofver
    variable strg2_a  : string(1 to 2);
    variable strg1_a  : string(1 to 1);
    variable strg1_b  : string(1 to 1);
    variable message  : string(1 to 80);
    variable msg_len  : integer;
    variable real_a   : real;
    variable real_b   : real;
    variable real_c   : real;
    variable in_int   : integer;
    variable in_bool  : boolean;
    variable ga_val   : std_logic_vector(4 downto 0);
    variable gap_val  : std_logic;
    variable data_block : vme_data_array;
    
  begin

--
-- initial values
--
    vme_as      <= '1';
    vme_ds0     <= '1';
    vme_ds1     <= '1';
    vme_write   <= '1';
    vme_lword   <= '1';
    vme_iack    <= '1';
    vme_iack_in <= '1';
    vme_addr    <= (others => 'Z');
    vme_am      <= (others => 'Z');
    vme_data    <= (others => 'Z');

    -- calculate the parity
    ga_val  := std_logic_vector(to_unsigned(slot_number, 5));
    gap_val := '0';
    for i in 4 downto 0 loop
      if (ga_val(i) = '0') then
        gap_val := not gap_val;
      end if;
    end loop;
    vme_ga  <= not ga_val;
    vme_gap <= not gap_val;
    -- IRQ(x"0");

--
-- initial reset
--
    vme_sysreset <= '0';
    wait for init_time;
    vme_sysreset <= '1';

--
-- run simulation
--
    while not(endfile(in_file)) loop
      readline(in_file, in_line);
      read(in_line, in_cmd);
      case in_cmd is
        when "T  " =>
          read(in_line, real_a);
          wait for (real_a * 1 ns);

        when "-- " =>
          -- read all characters of the line, up to the length  
          -- of the results string
          for i in message'range loop
            read(in_line, message(i), in_rtnv);
            if not in_rtnv then -- found end of line
              exit;
            end if;
            msg_len := i;
          end loop;
          write(out_line, "time: " & time'image(now) & message(1 to msg_len));
          writeline(out_file, out_line);
          assert (false) report message(1 to msg_len) severity note;
          
        when "RST" =>
          read(in_line, space); read(in_line, strg1_a);
          RST(fromString(strg1_a)(0));

        when "GA " =>
          read(in_line, space); read(in_line, strg2_a);
          read(in_line, space); read(in_line, strg1_a);
          GA(fromString(strg2_a), fromString(strg1_a)(0));

        when "RS " =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          read(in_line, space); read(in_line, strg8_b);
          RS(fromString(strg8_a), fromString(strg2_a), fromString(strg8_b),
             dsdn_delay, dsup_delay, asup_delay);  -- klofver

        when "RSM" =>                   --read single masked. klofver
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          read(in_line, space); read(in_line, strg8_b);
          read(in_line, space); read(in_line, strg8_c);
          
          RSM(fromString(strg8_a), fromString(strg2_a), fromString(strg8_b),
              dsdn_delay, dsup_delay, asup_delay, fromString(strg8_c));  -- klofver
          
        when "WS " =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          read(in_line, space); read(in_line, strg8_b);
          WS(fromString(strg8_a), fromString(strg2_a), fromString(strg8_b),
             dsdn_delay, dsup_delay, asup_delay);          -- klofver

        when "RB " =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          --read(in_line, space); read(in_line, strg8_b);
          read(in_line, space); read(in_line, in_int);
          for i in 0 to in_int-1 loop
            if ((i mod 16) = 0) then
              readline(in_file, in_line);
            end if;
            read(in_line, strg8_b);
            read(in_line, space);
            data_block(i) := fromString(strg8_b);
          end loop;  -- i loop
          RB(fromString(strg8_a), fromString(strg2_a), data_block, X"FFFFFFFF",
             in_int, dsdn_delay, dsup_delay, asup_delay);  -- klofver
          
        when "RBM" =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          read(in_line, space); read(in_line, strg8_b);
          read(in_line, space); read(in_line, in_int);
          for i in 0 to in_int-1 loop
            if ((i mod 16) = 0) then
              readline(in_file, in_line);
            end if;
            read(in_line, strg8_c);
            read(in_line, space);
            data_block(i) := fromString(strg8_c);
          end loop;  -- i loop
          RB(fromString(strg8_a), fromString(strg2_a), data_block, fromString(strg8_b),
             in_int, dsdn_delay, dsup_delay, asup_delay);  -- klofver
          
        when "WB " =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          --read(in_line, space); read(in_line, strg8_b);
          read(in_line, space); read(in_line, in_int);
          for i in 0 to in_int-1 loop
            if ((i mod 16) = 0) then
              readline(in_file, in_line);
            end if;
            read(in_line, strg8_b);
            read(in_line, space);
            data_block(i) := fromString(strg8_b);
          end loop;  -- i loop
          WB(fromString(strg8_a), fromString(strg2_a), data_block,
             in_int, dsdn_delay, dsup_delay, asup_delay);  -- klofver
        when "IAK" =>
          read(in_line, space); read(in_line, strg1_a);
          read(in_line, space); read(in_line, strg8_a);
          IAK(fromString(strg1_a), fromString(strg8_a),
              dsdn_delay, dsup_delay, asup_delay);         -- klofver
        when "SYN" =>
          read(in_line, space); read(in_line, strg1_a);
          SYN(fromString(strg1_a)(0));
        when "ADO" =>
          read(in_line, space); read(in_line, strg8_a);
          read(in_line, space); read(in_line, strg2_a);
          ADO(fromString(strg8_a), fromString(strg2_a), asup_delay);
        when "CLR" =>
          CLR;
        when others => null;
      end case;
    end loop;

--
-- print statistics and finish simulation
--
    wait for exit_time;
--   report "---- time ds down to dtack down : " &
--       real'image(s_ds_dtack_down_sgl/real(n_ds_dtack_down_sgl)) & "ns / " &
--       real'image(s_ds_dtack_down_blt/real(n_ds_dtack_down_blt)) & "ns / " &
--       real'image(s_ds_dtack_down_iak/real(n_ds_dtack_down_iak)) & "ns (" &
--       integer'image(n_ds_dtack_down_sgl) & " / " &
--       integer'image(n_ds_dtack_down_blt) & " / " &
--       integer'image(n_ds_dtack_down_iak) & ") (sgl/blt/iak)";
--   report "---- time ds up   to dtack up   : " &
--       real'image(s_ds_dtack_up  /real(n_ds_dtack_up)) & "ns (" &
--       integer'image(n_ds_dtack_up) & ")";
--   report "---- time clock   to read  up   : " &
--       real'image(min_clock_read_up) & "ns / " &
--       real'image(max_clock_read_up) & "ns (" &
--       integer'image(num_clock_read_up) & ")";
--   report "---- time clock   to write up   : " &
--       real'image(min_clock_write_up) & "ns / " &
--       real'image(max_clock_write_up) & "ns (" &
--       integer'image(num_clock_write_up) & ")";
--   report "---- time clock   to am    up   : " &
--       real'image(min_clock_am_up) & "ns / " &
--       real'image(max_clock_am_up) & "ns (" &
--       integer'image(num_clock_am_up) & ")";
--   report "---- time clock   to addr  up   : " &
--       real'image(min_clock_addr_up) & "ns / " &
--       real'image(max_clock_addr_up) & "ns (" &
--       integer'image(num_clock_addr_up) & ")";
--   report "---- time clock   to data  up   : " &
--       real'image(min_clock_data_up) & "ns / " &
--       real'image(max_clock_data_up) & "ns (" &
--       integer'image(num_clock_data_up) & ")";
    assert false report ">>>> End of VmeStimulus! <<<<" severity note;
    wait for 10 ns;
    finished <= true;
    wait;

  end process always;

------------------------------------------------------------------------------
-- bus timer
------------------------------------------------------------------------------

  bus_timer : process                   -- bus timer
  begin

    vme_berr <= 'H';

    wait for init_time;

    while true loop

      -- wait for ds down
      wait until (vme_ds0 = '0' or vme_ds1 = '0');

      -- wait for ds up or time-out
      wait until (vme_ds0 = '1' and vme_ds1 = '1') for bto_time;

      if (vme_ds0 = '0' or vme_ds1 = '0') then
        vme_berr <= '0';
        assert false report ">>>> bus error, addr '" & toString(vme_addr & '0') & "'";

        wait for init_time;
        vme_berr <= 'Z';                -- klofver

      end if;

    end loop;

  end process bus_timer;

------------------------------------------------------------------------------
-- check data bus
------------------------------------------------------------------------------

  check_rule26_31 : process             -- No "data driven" before ds down!!!
                                        -- No "data driven" after dtack up!!!
  begin

    wait for init_time;

    wait until ((vme_ds0 = '1' and vme_ds1 = '1') and
                i_dtack = '1' and i_berr = '1' and vme_write = '1' and
                vme_data /= ALLZ32);
    assert false report ">>>> violation of rule 2.53a (26): driving data before ds or dtack down, " &
      "expected 'ZZZZZZZZ' read '" & toString(vme_data) & "'" severity warning;
    
  end process check_rule26_31;

------------------------------------------------------------------------------

  check_rule27_29 : process             -- No "dtack" before data valid!!!
                                        -- No "data changed" before ds up!!!
  begin

    wait for init_time;

    while true loop

      -- wait for begin of read cycle (also iak)
      wait until ((vme_ds0 = '0' or vme_ds1 = '0') and vme_write = '1');

      -- wait for dtack down
      wait on i_dtack, i_berr;

      -- if (i_dtack /= '1' and i_berr_in = '1' and i_berr_out = '0') then
      -- check if data valid
--      if (vme_data /= i_user_data) then 
--        assert false report ">>>> violation of rule 2.54a (27): data not ready: " &
--            "expected '" & toString(i_user_data) & "' read '" & toString(vme_data) & "'";      
--      end if;      

      -- wait for ds up or data changed
      -- not yet distinguished between dsa and dsb!!!
--      wait until ((vme_ds0 = '1' and vme_ds1 = '1') or vme_data /= i_user_data);
--      if(vme_data /= i_user_data and (vme_ds0 = '0' or vme_ds1 = '0')) then
--        assert false report ">>>> violation of rule 2.56a (29): data changed before ds up, " &
--          "expected '" & toString(i_user_data) & "' read '" & toString(i_user_data) & "'";
--      end if;
      --end if;

      -- wait for end of cycle
      if (vme_ds0 /= '1' or vme_ds1 /= '1') then
        wait until (vme_ds0 = '1' and vme_ds1 = '1');
      end if;
      
    end loop;
    
  end process check_rule27_29;

------------------------------------------------------------------------------

  check_rule30 : process                -- No "dtack up" before ds up!!!
  begin
    wait for init_time;

    while true loop

      -- wait for dtack down, i.e. cycle started
      wait until (i_dtack /= '1');

      -- wait for ds or dtack up
      -- not yet distiguished between dsa and dsb!!!
      wait until ((vme_ds0 = '1' and vme_ds1 = '1') or i_dtack = '1');
      if(i_dtack = '1' and (vme_ds0 = '0' or vme_ds1 = '0')) then
        assert false report ">>>> violation of rule 2.57 (30): dtack up before ds up!!!";
      end if;
      
    end loop;
    
  end process check_rule30;

------------------------------------------------------------------------------

  check_rule35 : process  -- Iackout up after as up within 30 ns!!!
    variable start_time : time;
  begin
    
    wait for init_time;

    while true loop

      -- wait for participating interrupter cycle
      wait until (vme_iack_out /= '1' and vme_as /= '1');

      -- wait for as up, i.e. cycle finished
      wait until (vme_iack_out /= '1' and vme_as = '1');
      start_time := now;

      -- wait for iackout up
      wait until vme_iack_out = '1';

      if(now - start_time > iack_up_max_time) then
        assert false report ">>>> violation of rule 4.41 (35): iackout up after as up " &
          "in more than 30ns!!!" severity warning;
      end if;
      
    end loop;
    
  end process check_rule35;

------------------------------------------------------------------------------

--check_rule36 : process                  -- No "data driven" before Iackin down!!!
--begin

--  wait for init_time;

--  wait until (vme_iack_out = '0' and vme_as = '0' and
--              vme_iack_in = '1' and vme_data /= ALLZ32);
--  assert false report ">>>> violation of rule 4.42 (36): driving data before iackin down, " &
--    "expected " & "'ZZZZZZZZ' read '" & toString(vme_data) & "'";

--end process check_rule36;

------------------------------------------------------------------------------

  check_rule37 : process  -- No "data driven" after Iackout down!!!
  begin
    
    wait for init_time;
    
    wait until (vme_iack = '0' and vme_as = '0' and
                vme_iack_out = '0' and vme_data /= ALLZ32);
    assert false report ">>>> violation of rule 4.43 (37): driving data after iackout down, " &
      "expected " & "'ZZZZZZZZ' read '" & toString(vme_data) & "'";

  end process check_rule37;

------------------------------------------------------------------------------

  check_rule38a : process  -- No "Iackout down" before Iackin down!!!
  begin
    wait for init_time;
    wait until (vme_iack = '0' and vme_as = '0' and
                vme_iack_in = '1' and vme_iack_out = '0');
    assert false report ">>>> violation of rule 4.44 (38a): iackout down before iackin down";
  end process check_rule38a;

------------------------------------------------------------------------------

  check_rule38b : process  -- No "Dtack down" before Iackin down!!!
  begin
    wait for init_time;
    wait until (vme_iack = '0' and vme_as = '0' and
                vme_iack_in = '1' and i_dtack = '0');
    assert false report ">>>> violation of rule 4.45 (38b): dtack down before iackin down";
  end process check_rule38b;
  
end behavioral;

