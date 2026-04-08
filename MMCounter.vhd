library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity MMCounter is
    Port ( 
           SW        : in STD_LOGIC_VECTOR (15 downto 0);
           clk       : in STD_LOGIC;
           BTNC      : in STD_LOGIC;
           BTNR      : in STD_LOGIC;
           AN        : out STD_LOGIC_VECTOR (7 downto 0);
           SEG       : out STD_LOGIC_VECTOR (6 downto 0);
           LED       : out STD_LOGIC_VECTOR (15 downto 0);
           DP        : out STD_LOGIC
           );
end MMCounter;

architecture Behavioral of MMCounter is

    component debounce
            port (
                clk       : in STD_LOGIC;
                rst       : in STD_LOGIC;
                btn_in    : in STD_LOGIC;
                btn_state : out STD_LOGIC;
                btn_press : out STD_LOGIC
                );
    end component;
    
    component counter
            generic ( G_BITS : positive := 3 );
            
        
            port (
                clk : in  std_logic;                             
                rst : in  std_logic;                             
                en  : in  std_logic;                             
                cnt : out std_logic_vector(G_BITS - 1 downto 0)  
                );
    end component;
    
    component display_driver
            port (
                clk   : in STD_LOGIC;
                rst   : in STD_LOGIC;
                data  : in STD_LOGIC_VECTOR (7 downto 0);
                seg   : out STD_LOGIC_VECTOR (6 downto 0);
                anode : out STD_LOGIC_VECTOR (1 downto 0)
                );
    end component;
    
        signal rst_clean    : STD_LOGIC;
        signal step_clean   : STD_LOGIC;
        signal mode         : STD_LOGIC_VECTOR(1 downto 0);
        signal direction    : STD_LOGIC;
        signal count_val    : STD_LOGIC_VECTOR(15 downto 0);
        signal seg_data_reg : STD_LOGIC_VECTOR(31 downto 0);
        
        constant MODE_DECIMAL : STD_LOGIC_VECTOR(1 downto 0) := "00";
        constant MODE_HEX     : STD_LOGIC_VECTOR(1 downto 0) := "01";
        constant MODE_SCROLL  : STD_LOGIC_VECTOR(1 downto 0) := "10";
begin
     mode      <= SW (1 downto 0);
     direction <= SW (2);
 
     DP                <= '1';
     LED (1 downto 0)  <= mode;
     LED (2)           <= direction;
     LED (15 downto 3) <= (others => '0');
  
    counter_0: counter
        generic map (G_BITS => 1)
        
        port map (
        clk       =>  clk,
        rst       =>  rst_clean,
        MODE      =>  mode,
        dir       =>  direction,
        step      =>  step_clean,
        count_out =>  count_val
        
        );
    
end Behavioral;
