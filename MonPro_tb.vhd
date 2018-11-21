----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.11.2018 09:04:26
-- Design Name: 
-- Module Name: MonPro_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MonPro_tb is
   -- nothing
end MonPro_tb;

architecture Behavioral of MonPro_tb is
      -- Constants
    constant COUNTER_WIDTH : natural := 8;
    constant CLK_PERIOD    : time := 10 ns;
    constant RESET_TIME    : time := 10 ns;
    
    -- Clocks and resets 
    signal clk            : std_logic := '0';
    signal reset_n        : std_logic := '0';
    
    -- Adder signals
--    signal add_enable   : STD_LOGIC;
    signal A        : STD_LOGIC_VECTOR (255 downto 0);
    signal B        : STD_LOGIC_VECTOR (255 downto 0);
--    signal full_sum     : STD_LOGIC_VECTOR (255 downto 0);
    signal modulo     : STD_LOGIC_VECTOR (255 downto 0);
    
    signal Product     : STD_LOGIC_VECTOR (255 downto 0);
    
    -- MonPro
    signal start : STD_LOGIC;
    signal done : STD_LOGIC;

begin


      dut: entity work.MonPro 
      port map (
      
        -- Clocks and resets 
        clk            => clk, 
        reset_n        => reset_n, 
    
        -- Data input interface           
        Start      => Start, 
        A          => A,            
        B          => B,
        modulo     => modulo,
               
        -- Data output interface           
        Done => Done,
        Product => Product
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
      
        -- Send in first test vector
        Start       <= '0';
        A           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
        B           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
        modulo      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
        
        wait for 2*CLK_PERIOD;
        
        modulo      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000077"; -- modulo 1110111
        A           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000042"; -- Msg bin 1000010 
        B           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000051"; -- r2_mod_n 1010001

--        modulo      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000001";
--        A           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"000000000100200F";
--        B           <= x"7777777777777777" & x"6666666666666666" & x"F444444444444444" & x"3333333333333330";
        
--        modulo      <= x"AAAAAAAAAAAAAAAA" & x"0000000000000000" & x"0000000000000000" & x"AAAAAAAAAAAAAAA1";
--        A           <= x"7777777777777777" & x"6666666666666666" & x"F444444444444444" & x"010F0FF0FFF0FFFF";
--        B           <= x"7777777777777777" & x"6666666666666666" & x"F444444444444444" & x"3333333333333333";
        Start       <= '1';
        
        wait for 1*CLK_PERIOD;
        Start       <= '0';
        
        wait for 1750*CLK_PERIOD;
        Start       <= '1';
        wait for 1*CLK_PERIOD;
        Start       <= '0';
        
        wait for 2500*CLK_PERIOD;
--        Num_1       <= x"0000000001111111" & x"0000000000000000" & x"0000000000011111" & x"0000000000000000";
--        Num_2       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
        
--        wait for CLK_PERIOD;
--        Start       <= '1';
--        Num_1       <= x"1111111111111111" & x"2222222222222222" & x"1111111111111111" & x"2222222222222222";
--        Num_2       <= x"1111111111111111" & x"2222222222222222" & x"1111111111111111" & x"2222222222222222";
        
--        wait for 5*CLK_PERIOD;
--        Start       <= '0';
--        Num_1       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
--        Num_2       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
--        Start       <= '0';
--        wait for 10*CLK_PERIOD;
        
--        Num_1       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000003" & x"FFFFFFFFFFFFFFFF";
--        Num_2       <= x"0000000000000000" & x"0000000000000000" & x"0000000000000003" & x"FFFFFFFFFFFFFFFF";
--        Start       <= '1';
--        add_enable  <= '1';
--        wait for 3*CLK_PERIOD;
        
        -- Wait for results
--        wait;
--        assert(false);
      end process;  
end Behavioral;
