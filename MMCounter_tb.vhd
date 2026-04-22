library ieee;
use ieee.std_logic_1164.all;

entity tb_MMCounter is
end tb_MMCounter;

architecture tb of tb_MMCounter is

    component MMCounter
        port (
            SW   : in  std_logic_vector(15 downto 0);
            clk  : in  std_logic;
            BTNC : in  std_logic;
            BTNR : in  std_logic;
            AN   : out std_logic_vector(7 downto 0);
            SEG  : out std_logic_vector(6 downto 0);
            LED  : out std_logic_vector(15 downto 0);
            DP   : out std_logic
        );
    end component;

    signal SW   : std_logic_vector(15 downto 0) := (others => '0');
    signal clk  : std_logic := '0';
    signal BTNC : std_logic := '0';
    signal BTNR : std_logic := '0';
    signal AN   : std_logic_vector(7 downto 0);
    signal SEG  : std_logic_vector(6 downto 0);
    signal LED  : std_logic_vector(15 downto 0);
    signal DP   : std_logic;

    constant TbPeriod : time := 10 ns; -- 100 MHz clock
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

    -- Generátor hodin
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    stimuli : process
    begin
        -- 1. Reset (BTNC)
        SW   <= (others => '0');
        BTNC <= '1';
        wait for 100 ns;
        BTNC <= '0';
        wait for 100 ns;

        -- 2. Spuštění čítače (Enable=1, Dir=0 -> UP)
        SW(0) <= '1'; 
        SW(1) <= '0';
        wait for 2 us; -- Čítač teď udělá několik kroků

        -- 3. Změna módu (Stisk BTNR)
        BTNR <= '1';
        wait for 100 ns;
        BTNR <= '0';
        wait for 2 us;

        -- 4. Změna směru (Dir=1 -> DOWN)
        SW(1) <= '1';
        wait for 2 us;

        -- 5. Ukončení simulace
        TbSimEnded <= '1';
        wait;
    end process;

end tb;