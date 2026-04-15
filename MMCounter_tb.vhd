library ieee;
use ieee.std_logic_1164.all;

entity tb_MMCounter is
end tb_MMCounter;

architecture tb of tb_MMCounter is

    component MMCounter
    
        port (
            SW        : in  std_logic_vector(15 downto 0);
            clk       : in  std_logic;
            BTNC      : in  std_logic;
            BTNR      : in  std_logic;
            AN        : out std_logic_vector(7 downto 0);
            SEG       : out std_logic_vector(6 downto 0);
            LED       : out std_logic_vector(15 downto 0);
            DP        : out std_logic
        );
        
    end component;

    signal SW         : std_logic_vector(15 downto 0) := (others => '0');
    signal clk        : std_logic := '0';
    signal BTNC       : std_logic := '0';
    signal BTNR       : std_logic := '0';
    signal AN         : std_logic_vector(7 downto 0);
    signal SEG        : std_logic_vector(6 downto 0);
    signal LED        : std_logic_vector(15 downto 0);
    signal DP         : std_logic;

    constant TbPeriod : time := 10 ns;
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : MMCounter
    
        port map (
            SW   => SW,
            clk  => clk,
            BTNC => BTNC,
            BTNR => BTNR,
            AN   => AN,
            SEG  => SEG,
            LED  => LED,
            DP   => DP
        );


    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin

        SW   <= (others => '0');
        BTNC <= '0';
        BTNR <= '0';
        wait for 20 ns;


        BTNC <= '1';
        wait for 200 ns;
        BTNC <= '0';
        wait for 200 ns;


        SW(0) <= '1';   -- enable
        SW(1) <= '0';   -- up
        wait for 300 ms;


        BTNR <= '1';
        wait for 200 ns;
        BTNR <= '0';
        wait for 100 ms;


        BTNR <= '1';
        wait for 200 ns;
        BTNR <= '0';
        wait for 100 ms;


        SW(1) <= '1';
        wait for 300 ms;


        BTNC <= '1';
        wait for 200 ns;
        BTNC <= '0';
        wait for 100 ms;


        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_MMCounter of tb_MMCounter is
    for tb
    end for;
end cfg_tb_MMCounter;