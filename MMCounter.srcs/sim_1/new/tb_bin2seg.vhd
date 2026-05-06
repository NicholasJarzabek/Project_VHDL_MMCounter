library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bin2seg is
end tb_bin2seg;

architecture tb of tb_bin2seg is

    signal bin : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal seg : STD_LOGIC_VECTOR(6 downto 0);

begin

    DUT : entity work.bin2seg
        port map (
            bin => bin,
            seg => seg
        );

    p_stimulus : process
    begin
        for i in 0 to 15 loop
            bin <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
            wait for 50 ns;
        end loop;

        wait;
    end process;

end tb;