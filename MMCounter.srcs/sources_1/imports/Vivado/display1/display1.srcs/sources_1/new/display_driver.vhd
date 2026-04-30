library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    Port (
        -- Main clock and reset
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;

        -- Eight 4-bit values for eight seven-segment digits
        -- value(3 downto 0)    = rightmost digit
        -- value(31 downto 28)  = leftmost digit
        value : in  STD_LOGIC_VECTOR (31 downto 0);

        -- Seven-segment outputs
        seg   : out STD_LOGIC_VECTOR (6 downto 0);

        -- Eight anode outputs
        anode : out STD_LOGIC_VECTOR (7 downto 0)
    );
end display_driver;


architecture Behavioral of display_driver is

    --------------------------------------------------------------------
    -- INTERNAL SIGNALS
    --------------------------------------------------------------------

    signal refresh_cnt : unsigned(16 downto 0) := (others => '0');
    signal digit_sel   : unsigned(2 downto 0)  := (others => '0');
    signal digit_value : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');


begin

    --------------------------------------------------------------------
    -- REFRESH COUNTER
    --
    -- The display is multiplexed.
    -- Only one digit is active at a time, but digits are switched quickly.
    --------------------------------------------------------------------

    p_refresh : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                refresh_cnt <= (others => '0');
                digit_sel   <= (others => '0');
            else
                refresh_cnt <= refresh_cnt + 1;
                digit_sel   <= refresh_cnt(16 downto 14);
            end if;
        end if;
    end process;


    --------------------------------------------------------------------
    -- DIGIT MULTIPLEXER
    --
    -- Selects which digit is currently active and chooses its 4-bit value.
    -- Anodes are active LOW on Nexys A7.
    --------------------------------------------------------------------

    p_digit_select : process(digit_sel, value)
    begin
        case digit_sel is

            when "000" =>
                digit_value <= value(3 downto 0);
                anode       <= "11111110";

            when "001" =>
                digit_value <= value(7 downto 4);
                anode       <= "11111101";

            when "010" =>
                digit_value <= value(11 downto 8);
                anode       <= "11111011";

            when "011" =>
                digit_value <= value(15 downto 12);
                anode       <= "11110111";

            when "100" =>
                digit_value <= value(19 downto 16);
                anode       <= "11101111";

            when "101" =>
                digit_value <= value(23 downto 20);
                anode       <= "11011111";

            when "110" =>
                digit_value <= value(27 downto 24);
                anode       <= "10111111";

            when others =>
                digit_value <= value(31 downto 28);
                anode       <= "01111111";

        end case;
    end process;


    --------------------------------------------------------------------
    -- HEX TO SEVEN-SEGMENT DECODER
    --
    -- Segment outputs are active LOW.
    -- Supports hexadecimal symbols 0-F.
    --------------------------------------------------------------------

    p_hex_to_7seg : process(digit_value)
    begin
        case digit_value is
            when "0000" => seg <= "0000001"; -- 0
            when "0001" => seg <= "1001111"; -- 1
            when "0010" => seg <= "0010010"; -- 2
            when "0011" => seg <= "0000110"; -- 3
            when "0100" => seg <= "1001100"; -- 4
            when "0101" => seg <= "0100100"; -- 5
            when "0110" => seg <= "0100000"; -- 6
            when "0111" => seg <= "0001111"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0000100"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "1100000"; -- b
            when "1100" => seg <= "0110001"; -- C
            when "1101" => seg <= "1000010"; -- d
            when "1110" => seg <= "0110000"; -- E
            when "1111" => seg <= "0111000"; -- F
            when others => seg <= "1111111"; -- blank
        end case;
    end process;

end Behavioral;
