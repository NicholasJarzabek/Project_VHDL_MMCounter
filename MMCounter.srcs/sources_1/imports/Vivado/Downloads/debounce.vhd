library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        btn_in    : in  STD_LOGIC;
        btn_state : out STD_LOGIC;
        btn_press : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is

    constant C_MAX : integer := 100000; -- FPGA verzia

    signal counter     : integer range 0 to C_MAX := 0;
    signal btn_sync    : STD_LOGIC := '0';
    signal btn_prev    : STD_LOGIC := '0';
    signal stable      : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                counter   <= 0;
                stable    <= '0';
                btn_prev  <= '0';

            else
                -- synchronizácia vstupu
                btn_sync <= btn_in;

                if btn_sync /= stable then
                    counter <= counter + 1;

                    if counter = C_MAX then
                        stable  <= btn_sync;
                        counter <= 0;
                    end if;
                else
                    counter <= 0;
                end if;

                btn_prev <= stable;
            end if;
        end if;
    end process;

    btn_state <= stable;

    -- detekcia nábežnej hrany
    btn_press <= '1' when (stable = '1' and btn_prev = '0') else '0';

end Behavioral;