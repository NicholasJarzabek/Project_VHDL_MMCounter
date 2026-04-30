library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MMCounter is
    Port (
        -- Switch inputs
        SW   : in  STD_LOGIC_VECTOR (15 downto 0);

        -- Main clock
        clk  : in  STD_LOGIC;

        -- Push buttons
        BTNC : in  STD_LOGIC;  -- Reset counter and display mode
        BTNR : in  STD_LOGIC;  -- Change display mode: DEC -> HEX -> SCROLL
        BTNL : in  STD_LOGIC;  -- Run / pause automatic counting
        BTNU : in  STD_LOGIC;  -- Single manual step
        BTND : in  STD_LOGIC;  -- Load value from SW(15 downto 8)

        -- 8-digit seven-segment display
        AN   : out STD_LOGIC_VECTOR (7 downto 0);
        SEG  : out STD_LOGIC_VECTOR (6 downto 0);
        DP   : out STD_LOGIC;

        -- LEDs
        LED  : out STD_LOGIC_VECTOR (15 downto 0)
    );
end MMCounter;


architecture Behavioral of MMCounter is

    --------------------------------------------------------------------
    -- COMPONENTS
    --------------------------------------------------------------------

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
            value : in  STD_LOGIC_VECTOR (31 downto 0);
            seg   : out STD_LOGIC_VECTOR (6 downto 0);
            anode : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;


    --------------------------------------------------------------------
    -- BUTTON SIGNALS
    --------------------------------------------------------------------

    signal rst_state  : STD_LOGIC;
    signal mode_state : STD_LOGIC;
    signal run_state  : STD_LOGIC;
    signal step_state : STD_LOGIC;
    signal load_state : STD_LOGIC;

    signal rst_press  : STD_LOGIC;
    signal mode_press : STD_LOGIC;
    signal run_press  : STD_LOGIC;
    signal step_press : STD_LOGIC;
    signal load_press : STD_LOGIC;


    --------------------------------------------------------------------
    -- COUNTER AND CONTROL SIGNALS
    --------------------------------------------------------------------

    signal count_val : unsigned(15 downto 0) := (others => '0');
    signal step_size : unsigned(15 downto 0);

    signal mode_reg  : unsigned(1 downto 0) := "00";
    signal run_reg   : STD_LOGIC := '0';

    signal tick0     : STD_LOGIC;
    signal tick1     : STD_LOGIC;
    signal tick2     : STD_LOGIC;
    signal tick3     : STD_LOGIC;
    signal sig_tick  : STD_LOGIC;


    --------------------------------------------------------------------
    -- DISPLAY SIGNALS
    --------------------------------------------------------------------

    signal digits_8x4 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');


    --------------------------------------------------------------------
    -- DISPLAY MODES
    --------------------------------------------------------------------

    constant MODE_DECIMAL : unsigned(1 downto 0) := "00";
    constant MODE_HEX     : unsigned(1 downto 0) := "01";
    constant MODE_SCROLL  : unsigned(1 downto 0) := "10";


begin

    --------------------------------------------------------------------
    -- OUTPUT CONNECTIONS
    --------------------------------------------------------------------

    -- LEDs show the full 16-bit binary value of the counter.
    LED <= STD_LOGIC_VECTOR(count_val);

    -- Decimal point is disabled.
    DP <= '1';


    --------------------------------------------------------------------
    -- STEP SIZE
    --
    -- SW(7 downto 4) sets the counter step size.
    -- If SW(7 downto 4) = 0000, step size is forced to 1.
    --------------------------------------------------------------------

    step_size <= to_unsigned(1, 16) when SW(7 downto 4) = "0000" else
                 resize(unsigned(SW(7 downto 4)), 16);


    --------------------------------------------------------------------
    -- BUTTON DEBOUNCERS
    --
    -- BTNC = reset
    -- BTNR = change display mode
    -- BTNL = run / pause
    -- BTNU = single manual step
    -- BTND = load value from SW(15 downto 8)
    --------------------------------------------------------------------

    DEB_RST : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNC,
            btn_state => rst_state,
            btn_press => rst_press
        );

    DEB_MODE : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNR,
            btn_state => mode_state,
            btn_press => mode_press
        );

    DEB_RUN : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNL,
            btn_state => run_state,
            btn_press => run_press
        );

    DEB_STEP : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTNU,
            btn_state => step_state,
            btn_press => step_press
        );

    DEB_LOAD : debounce
        port map (
            clk       => clk,
            rst       => '0',
            btn_in    => BTND,
            btn_state => load_state,
            btn_press => load_press
        );


    --------------------------------------------------------------------
    -- CLOCK ENABLE GENERATORS
    --
    -- With 100 MHz clock:
    -- 100_000_000 is approximately 1 second.
    --
    -- SW(3 downto 2) selects counting speed:
    -- 00 = slowest
    -- 01 = medium-slow
    -- 10 = medium-fast
    -- 11 = fastest
    --------------------------------------------------------------------

    TICK0_GEN : clk_en
        generic map (
            G_MAX => 100_000_000
        )
        port map (
            clk => clk,
            rst => rst_state,
            ce  => tick0
        );

    TICK1_GEN : clk_en
        generic map (
            G_MAX => 50_000_000
        )
        port map (
            clk => clk,
            rst => rst_state,
            ce  => tick1
        );

    TICK2_GEN : clk_en
        generic map (
            G_MAX => 25_000_000
        )
        port map (
            clk => clk,
            rst => rst_state,
            ce  => tick2
        );

    TICK3_GEN : clk_en
        generic map (
            G_MAX => 10_000_000
        )
        port map (
            clk => clk,
            rst => rst_state,
            ce  => tick3
        );

    with SW(3 downto 2) select
        sig_tick <= tick0 when "00",
                    tick1 when "01",
                    tick2 when "10",
                    tick3 when others;


    --------------------------------------------------------------------
    -- MODE CONTROL
    --
    -- BTNR cycles display mode:
    -- DECIMAL -> HEX -> SCROLL -> DECIMAL
    --------------------------------------------------------------------

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


    --------------------------------------------------------------------
    -- RUN / PAUSE CONTROL
    --
    -- BTNL toggles automatic counting.
    -- run_reg = 0 -> paused
    -- run_reg = 1 -> automatic counting active
    --------------------------------------------------------------------

    p_run_control : process(clk)
    begin
        if rising_edge(clk) then
            if rst_state = '1' then
                run_reg <= '0';

            elsif run_press = '1' then
                run_reg <= not run_reg;
            end if;
        end if;
    end process;


    --------------------------------------------------------------------
    -- MAIN COUNTER
    --
    -- BTNC reset:
    --   count_val = 0
    --
    -- BTND load:
    --   loads SW(15 downto 8) into the counter
    --
    -- BTNU single step:
    --   one manual increment/decrement
    --
    -- Automatic counting:
    --   enabled by BTNL and controlled by selected speed
    --
    -- SW(0):
    --   0 = count up
    --   1 = count down
    --------------------------------------------------------------------

    p_counter : process(clk)
    begin
        if rising_edge(clk) then

            if rst_state = '1' then
                count_val <= (others => '0');

            elsif load_press = '1' then
                count_val <= resize(unsigned(SW(15 downto 8)), 16);

            elsif step_press = '1' then
                if SW(0) = '0' then
                    count_val <= count_val + step_size;
                else
                    count_val <= count_val - step_size;
                end if;

            elsif sig_tick = '1' and run_reg = '1' then
                if SW(0) = '0' then
                    count_val <= count_val + step_size;
                else
                    count_val <= count_val - step_size;
                end if;
            end if;

        end if;
    end process;


    --------------------------------------------------------------------
    -- 8-DIGIT DISPLAY FORMATTER
    --
    -- digits_8x4 contains eight 4-bit digits:
    -- digits_8x4(3 downto 0)    = rightmost digit
    -- digits_8x4(31 downto 28)  = leftmost digit
    --
    -- MODE_DECIMAL:
    --   displays counter value as decimal number 00000000 - 00065535
    --
    -- MODE_HEX:
    --   displays 16-bit counter as hexadecimal 0000XXXX
    --
    -- MODE_SCROLL:
    --   displays a simple scrolling-like pattern using hex symbols
    --------------------------------------------------------------------

    p_display_formatter : process(count_val, mode_reg)
        variable decimal_value : integer range 0 to 65535;
        variable d0            : integer range 0 to 9;
        variable d1            : integer range 0 to 9;
        variable d2            : integer range 0 to 9;
        variable d3            : integer range 0 to 9;
        variable d4            : integer range 0 to 9;
        variable d5            : integer range 0 to 9;
    begin

        case mode_reg is

            when MODE_DECIMAL =>
                decimal_value := to_integer(count_val);

                d0 := decimal_value mod 10;
                d1 := (decimal_value / 10) mod 10;
                d2 := (decimal_value / 100) mod 10;
                d3 := (decimal_value / 1000) mod 10;
                d4 := (decimal_value / 10000) mod 10;
                d5 := (decimal_value / 100000) mod 10;

                digits_8x4(3 downto 0)     <= STD_LOGIC_VECTOR(to_unsigned(d0, 4));
                digits_8x4(7 downto 4)     <= STD_LOGIC_VECTOR(to_unsigned(d1, 4));
                digits_8x4(11 downto 8)    <= STD_LOGIC_VECTOR(to_unsigned(d2, 4));
                digits_8x4(15 downto 12)   <= STD_LOGIC_VECTOR(to_unsigned(d3, 4));
                digits_8x4(19 downto 16)   <= STD_LOGIC_VECTOR(to_unsigned(d4, 4));
                digits_8x4(23 downto 20)   <= STD_LOGIC_VECTOR(to_unsigned(d5, 4));
                digits_8x4(27 downto 24)   <= x"0";
                digits_8x4(31 downto 28)   <= x"0";

            when MODE_HEX =>
                -- show 16-bit counter on the right side, upper digits are zero
                digits_8x4 <= x"0000" & STD_LOGIC_VECTOR(count_val);

            when MODE_SCROLL =>
                -- simple changing 8-digit pattern
                case count_val(5 downto 3) is
                    when "000"  => digits_8x4 <= x"DE100000";
                    when "001"  => digits_8x4 <= x"0DE10000";
                    when "010"  => digits_8x4 <= x"00DE1000";
                    when "011"  => digits_8x4 <= x"000DE100";
                    when "100"  => digits_8x4 <= x"0000DE10";
                    when "101"  => digits_8x4 <= x"00000DE1";
                    when "110"  => digits_8x4 <= x"100000DE";
                    when others => digits_8x4 <= x"E100000D";  
                end case;

            when others =>
                digits_8x4 <= (others => '0');

        end case;

    end process;


    --------------------------------------------------------------------
    -- 8-DIGIT DISPLAY DRIVER
    --------------------------------------------------------------------

    DISPLAY_INST : display_driver
        port map (
            clk   => clk,
            rst   => rst_state,
            value => digits_8x4,
            seg   => SEG,
            anode => AN
        );

end Behavioral;
