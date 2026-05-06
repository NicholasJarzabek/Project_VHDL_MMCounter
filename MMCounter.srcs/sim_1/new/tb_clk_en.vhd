library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_clk_en is
end tb_clk_en;

architecture tb of tb_clk_en is

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal ce  : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : entity work.clk_en
        generic map (
            G_MAX => 10
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce
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
        wait for 300 ns;

        rst <= '1';
        wait for 50 ns;

        rst <= '0';
        wait for 200 ns;

        wait;
    end process;

end tb;