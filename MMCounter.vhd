library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MMCounter is
    Port (
        SW   : in  STD_LOGIC_VECTOR (15 downto 0);
        clk  : in  STD_LOGIC;
        BTNC : in  STD_LOGIC;
        BTNR : in  STD_LOGIC;
        AN   : out STD_LOGIC_VECTOR (7 downto 0);
        SEG  : out STD_LOGIC_VECTOR (6 downto 0);
        LED  : out STD_LOGIC_VECTOR (15 downto 0);
        DP   : out STD_LOGIC
    );
end MMCounter;

architecture Behavioral of MMCounter is

    component debounce
        port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            btn_in    : in  STD_LOGIC;
            btn_state : out STD_LOGIC;
            btn_press : out STD_LOGIC
        );
    end component;

    component clk_en
        generic (
            G_MAX : positive := 5
        );
        port (
            clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            ce  : out STD_LOGIC
        );
    end component;

    component display_driver
        port (
            clk   : in  STD_LOGIC;
            rst   : in  STD_LOGIC;
            data  : in  STD_LOGIC_VECTOR (7 downto 0);
            seg   : out STD_LOGIC_VECTOR (6 downto 0);
            anode : out STD_LOGIC_VECTOR (1 downto 0)
        );
    end component;

    signal rst_state      : STD_LOGIC;
    signal rst_press      : STD_LOGIC;
    signal mode_state     : STD_LOGIC;
    signal mode_press     : STD_LOGIC;

    signal sig_enable     : STD_LOGIC;
    signal sig_dir        : STD_LOGIC;
    signal sig_tick       : STD_LOGIC;

    signal count_val      : unsigned(15 downto 0) := (others => '0');
    signal mode_reg       : unsigned(1 downto 0)  := "00";

    signal disp_data      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal anode_2dig     : STD_LOGIC_VECTOR(1 downto 0);

    constant MODE_DECIMAL : unsigned(1 downto 0) := "00";
    constant MODE_HEX     : unsigned(1 downto 0) := "01";
    constant MODE_SCROLL  : unsigned(1 downto 0) := "10";

begin

    sig_enable <= SW(0);
    sig_dir    <= SW(1);

    DP <= '1';

    LED(15 downto 2) <= STD_LOGIC_VECTOR(count_val(15 downto 2));
    LED(1 downto 0)  <= STD_LOGIC_VECTOR(mode_reg);

    DEBOUNCE_RST : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNC,
            btn_state => rst_state,
            btn_press => rst_press
        );

    DEBOUNCE_MODE : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNR,
            btn_state => mode_state,
            btn_press => mode_press
        );

    TICK_GEN : clk_en
        generic map (
            G_MAX => 10
        )
        port map (
            clk => clk,
            rst => rst_state,
            ce  => sig_tick
        );

    p_mode_control : process(clk)
    begin
        if rising_edge(clk) then
            if rst_state = '1' then
                mode_reg <= MODE_DECIMAL;
            elsif mode_press = '1' then
                if mode_reg = MODE_SCROLL then
                    mode_reg <= MODE_DECIMAL;
                else
                    mode_reg <= mode_reg + 1;
                end if;
            end if;
        end if;
    end process;

    p_counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst_state = '1' then
                count_val <= (others => '0');
            elsif sig_tick = '1' and sig_enable = '1' then
                if sig_dir = '0' then
                    count_val <= count_val + 1;
                else
                    count_val <= count_val - 1;
                end if;
            end if;
        end if;
    end process;

    p_display_data : process(count_val, mode_reg)
        variable tmp_int : integer range 0 to 255;
        variable tens_d  : integer range 0 to 9;
        variable ones_d  : integer range 0 to 9;
        variable low_b   : unsigned(7 downto 0);
    begin
        low_b := count_val(7 downto 0);

        case mode_reg is
            when MODE_DECIMAL =>
                tmp_int := to_integer(low_b) mod 100;
                tens_d  := tmp_int / 10;
                ones_d  := tmp_int mod 10;

                disp_data(7 downto 4) <= std_logic_vector(to_unsigned(tens_d, 4));
                disp_data(3 downto 0) <= std_logic_vector(to_unsigned(ones_d, 4));

            when MODE_HEX =>
                disp_data <= std_logic_vector(low_b);

            when MODE_SCROLL =>
                if count_val(4) = '0' then
                    disp_data <= x"A1";
                else
                    disp_data <= x"1A";
                end if;

            when others =>
                disp_data <= (others => '0');
        end case;
    end process;

    DISPLAY_INST : display_driver
        port map (
            clk   => clk,
            rst   => rst_state,
            data  => disp_data,
            seg   => SEG,
            anode => anode_2dig
        );

    AN <= "111111" & anode_2dig;

end Behavioral;
