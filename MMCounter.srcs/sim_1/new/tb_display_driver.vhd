library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_display_driver is
end tb_display_driver;

architecture tb of tb_display_driver is

    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '0';
    signal value : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal seg   : STD_LOGIC_VECTOR(6 downto 0);
    signal anode : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : entity work.display_driver
        port map (
            clk   => clk,
            rst   => rst,
            value => value,
            seg   => seg,
            anode => anode
        );

    p_clk : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

p_stimulus : process
begin

    ----------------------------------------------------------------
    -- RESET
    ----------------------------------------------------------------

    rst <= '1';
    value <= x"00000000";
    wait for 50 ns;

    rst <= '0';
    wait for 50 ns;


    ----------------------------------------------------------------
    -- DECIMAL-LIKE VALUES
    ----------------------------------------------------------------

    value <= x"12345678";
    wait for 100 ns;

    value <= x"87654321";
    wait for 100 ns;

    value <= x"00001234";
    wait for 100 ns;


    ----------------------------------------------------------------
    -- HEXADECIMAL VALUES
    ----------------------------------------------------------------

    value <= x"ABCDEF00";
    wait for 100 ns;

    value <= x"DEADBEEF";
    wait for 100 ns;

    value <= x"CAFEBABE";
    wait for 100 ns;


    ----------------------------------------------------------------
    -- EDGE / SPECIAL VALUES
    ----------------------------------------------------------------

    value <= x"FFFFFFFF";
    wait for 100 ns;

    value <= x"00000000";
    wait for 100 ns;

    value <= x"11111111";
    wait for 100 ns;

    value <= x"88888888";
    wait for 100 ns;


    ----------------------------------------------------------------
    -- SCROLL-LIKE PATTERNS
    ----------------------------------------------------------------

    value <= x"10000000";
    wait for 50 ns;

    value <= x"01000000";
    wait for 50 ns;

    value <= x"00100000";
    wait for 50 ns;

    value <= x"00010000";
    wait for 50 ns;

    value <= x"00001000";
    wait for 50 ns;

    value <= x"00000100";
    wait for 50 ns;

    value <= x"00000010";
    wait for 50 ns;

    value <= x"00000001";
    wait for 50 ns;


    ----------------------------------------------------------------
    -- FINAL VALUE
    ----------------------------------------------------------------

    value <= x"0000FFFF";
    wait for 100 ns;


    ----------------------------------------------------------------
    -- END SIMULATION
    ----------------------------------------------------------------

    wait;

end process;

end tb;