library ieee;
use ieee.std_logic_1164.all;

entity tb_MMCounter is
end tb_MMCounter;


architecture tb of tb_MMCounter is

    --------------------------------------------------------------------
    -- COMPONENT
    --------------------------------------------------------------------
    component MMCounter
        port (
            -- INPUTS
            SW   : in  std_logic_vector(15 downto 0);
            clk  : in  std_logic;
            BTNC : in  std_logic;
            BTNR : in  std_logic;
            BTNL : in  std_logic;
            BTNU : in  std_logic;
            BTND : in  std_logic;

            -- OUTPUTS
            AN   : out std_logic_vector(7 downto 0);
            SEG  : out std_logic_vector(6 downto 0);
            LED  : out std_logic_vector(15 downto 0);
            DP   : out std_logic
        );
    end component;


    --------------------------------------------------------------------
    -- TESTBENCH SIGNALS
    --------------------------------------------------------------------
    signal SW   : std_logic_vector(15 downto 0) := (others => '0');
    signal clk  : std_logic := '0';

    signal BTNC : std_logic := '0'; -- reset
    signal BTNR : std_logic := '0'; -- mode
    signal BTNL : std_logic := '0'; -- run/pause
    signal BTNU : std_logic := '0'; -- single step
    signal BTND : std_logic := '0'; -- load

    signal AN   : std_logic_vector(7 downto 0);
    signal SEG  : std_logic_vector(6 downto 0);
    signal LED  : std_logic_vector(15 downto 0);
    signal DP   : std_logic;

    constant TbPeriod : time := 10 ns;


begin

    --------------------------------------------------------------------
    -- DUT INSTANCE
    --------------------------------------------------------------------
    dut : MMCounter
        port map (
            SW   => SW,
            clk  => clk,
            BTNC => BTNC,
            BTNR => BTNR,
            BTNL => BTNL,
            BTNU => BTNU,
            BTND => BTND,
            AN   => AN,
            SEG  => SEG,
            LED  => LED,
            DP   => DP
        );


    --------------------------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for TbPeriod / 2;

            clk <= '1';
            wait for TbPeriod / 2;
        end loop;
    end process;


    --------------------------------------------------------------------
    -- STIMULI
    --------------------------------------------------------------------
    stimuli : process
    begin

        ----------------------------------------------------------------
        -- INITIAL STATE
        ----------------------------------------------------------------
        SW   <= (others => '0');
        BTNC <= '0';
        BTNR <= '0';
        BTNL <= '0';
        BTNU <= '0';
        BTND <= '0';

        wait for 100 ns;


        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        BTNC <= '1';
        wait for 5 us;

        BTNC <= '0';
        wait for 5 us;


        ----------------------------------------------------------------
        -- SINGLE STEP UP
        ----------------------------------------------------------------
        SW(0) <= '0';                 -- direction: up
        SW(7 downto 4) <= "0001";     -- step size: 1

        BTNU <= '1';
        wait for 5 us;

        BTNU <= '0';
        wait for 10 us;


        ----------------------------------------------------------------
        -- SECOND SINGLE STEP UP
        ----------------------------------------------------------------
        BTNU <= '1';
        wait for 5 us;

        BTNU <= '0';
        wait for 10 us;


        ----------------------------------------------------------------
        -- LOAD VALUE FROM SWITCHES
        ----------------------------------------------------------------
        SW(15 downto 8) <= x"AA";     -- value to load

        wait for 5 us;

        BTND <= '1';
        wait for 5 us;

        BTND <= '0';
        wait for 10 us;


        ----------------------------------------------------------------
        -- MODE CHANGE: DECIMAL -> HEX
        ----------------------------------------------------------------
        BTNR <= '1';
        wait for 5 us;

        BTNR <= '0';
        wait for 10 us;


        ----------------------------------------------------------------
        -- MODE CHANGE: HEX -> SCROLL
        ----------------------------------------------------------------
        BTNR <= '1';
        wait for 5 us;

        BTNR <= '0';
        wait for 10 us;


        ----------------------------------------------------------------
        -- BYTE SELECT
        ----------------------------------------------------------------
        SW(1) <= '1';                 -- show high byte
        wait for 10 us;

        SW(1) <= '0';                 -- show low byte
        wait for 10 us;


        ----------------------------------------------------------------
        -- RUN MODE
        ----------------------------------------------------------------
        SW(0) <= '0';                 -- direction: up
        SW(3 downto 2) <= "00";       -- fastest speed

        BTNL <= '1';
        wait for 5 us;

        BTNL <= '0';


        ----------------------------------------------------------------
        -- AUTOMATIC COUNTING
        ----------------------------------------------------------------
        wait for 200 ms;


        ----------------------------------------------------------------
        -- CHANGE DIRECTION
        ----------------------------------------------------------------
        SW(0) <= '1';                 -- direction: down

        wait for 200 ms;


        ----------------------------------------------------------------
        -- PAUSE
        ----------------------------------------------------------------
        BTNL <= '1';
        wait for 5 us;

        BTNL <= '0';
        wait for 20 us;


        ----------------------------------------------------------------
        -- FINAL RESET
        ----------------------------------------------------------------
        BTNC <= '1';
        wait for 5 us;

        BTNC <= '0';
        wait for 20 us;


        ----------------------------------------------------------------
        -- END OF SIMULATION
        ----------------------------------------------------------------
        wait;

    end process;

end tb;


configuration cfg_tb_MMCounter of tb_MMCounter is
    for tb
    end for;
end cfg_tb_MMCounter;