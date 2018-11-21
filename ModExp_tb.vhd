
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModExp_tb is
    -- nothing
end ModExp_tb;

architecture Behavioral of ModExp_tb is
      -- Constants
    constant COUNTER_WIDTH : natural := 8;
    constant CLK_PERIOD    : time := 10 ns;
    constant RESET_TIME    : time := 10 ns;
    
    -- Clocks and resets 
    signal clk            : std_logic := '0';
    signal reset_n        : std_logic := '0';
    
    -- Adder signals
    signal add_enable   : STD_LOGIC;
    signal message            : STD_LOGIC_VECTOR (255 downto 0);
    signal key            : STD_LOGIC_VECTOR (255 downto 0);
    signal modulo     : STD_LOGIC_VECTOR (255 downto 0);
    signal r_mod_n     : STD_LOGIC_VECTOR (255 downto 0);
    signal r2_mod_n     : STD_LOGIC_VECTOR (255 downto 0);
    signal Done:  STD_LOGIC;
    
    -- MonPro
    signal start : STD_LOGIC;
    signal ModExp_done : STD_LOGIC;
begin

    dut: entity work.modular_exponentiation 
    port map (

      -- Clocks and resets 
      clk            => clk, 
      reset_n        => reset_n, 
    
      -- Data input interface           
      message      => message, 
      key          => key,            
      modulo       => modulo,
      r_mod_n      => r_mod_n,
      r2_mod_n     => r2_mod_n,
             
      -- Data output interface           
      ModExp_done => Done
);

      -- Clock generation
      clk <= not clk after CLK_PERIOD/2;
      
      -- Reset generation
      reset_proc: process
      begin
        wait for RESET_TIME;
        reset_n <= '1';
        wait;
      end process;
    
      -- Stimuli generation
      stimuli_proc: process
      begin
      
      modulo       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000077"; -- bin 1110111. dec 119
      message      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000042"; -- bin 1000010. dec 66
      key          <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000005"; -- 
      r_mod_n      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000009"; -- 
      r2_mod_n     <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000051"; -- bin 1010001. dec 81
      
      wait;
      
  end process;
end Behavioral;
