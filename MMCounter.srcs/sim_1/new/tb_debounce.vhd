library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture tb of tb_debounce is

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '0';
    signal btn_in    : STD_LOGIC := '0';
    signal btn_state : STD_LOGIC;
    signal btn_press : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : entity work.debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btn_in,
            btn_state => btn_state,
            btn_press => btn_press
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
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- short button pulse
        btn_in <= '1';
        wait for 100 ns;
        btn_in <= '0';
        wait for 100 ns;

        -- longer button press
        btn_in <= '1';
        wait for 500 ns;
        btn_in <= '0';
        wait for 500 ns;

        wait;
    end process;

end tb;