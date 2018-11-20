----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2018 13:48:53
-- Design Name: 
-- Module Name: adder_256_64 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder_256_64 is
    Port ( a_in   :     in      STD_LOGIC_VECTOR (255 downto 0);
           b_in   :     in      STD_LOGIC_VECTOR (255 downto 0);
           clk    :     in      STD_LOGIC;
           reset  :     in      STD_LOGIC;
           active :     in      STD_LOGIC;
           done   :     buffer  STD_LOGIC;
           result_out : out     STD_LOGIC_VECTOR (256 downto 0)
          );
end adder_256_64;

architecture Behavioral of adder_256_64 is

signal a_nxt : STD_LOGIC_VECTOR (255 downto 0);
signal b_nxt : STD_LOGIC_VECTOR (255 downto 0);
signal a_reg : STD_LOGIC_VECTOR (255 downto 0);
signal b_reg : STD_LOGIC_VECTOR (255 downto 0);
signal result_nxt : STD_LOGIC_VECTOR (256 downto 0);
signal result_reg : STD_LOGIC_VECTOR (256 downto 0);
signal counter_reg : UNSIGNED (2 downto 0);
signal active_reg : STD_LOGIC;
signal done_reg : STD_LOGIC;

begin

 u_adder64: entity work.cla_adder
    port map (
      -- inputs
      x_in      => a_reg(63 downto 0),
      y_in      => b_reg(63 downto 0),
      carry_in  => result_reg(256),
      -- outputs
      sum       => result_nxt(255 downto 192),
      carry_out => result_nxt(256)
    );

    --start <= active and (not or_reduce(STD_LOGIC_VECTOR(counter_reg)));

-- A and B registers
    process(clk, reset)
    begin
        if(reset = '1') then
            a_reg <= (others => '0');
            b_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            a_reg <= a_nxt;
            b_reg <= b_nxt;
        end if;
    end process;
    
-- A_nxt and B_nxt
    process(a_in, b_in, a_reg, b_reg, active_reg)
    begin
        if(active_reg='1') then
            a_nxt <= x"0000000000000000" & a_reg(255 downto 64);
            b_nxt <= x"0000000000000000" & b_reg(255 downto 64);
        else
            a_nxt <= a_in;
            b_nxt <= b_in;
        end if;
    end process;
    
-- Result register
    process(clk, reset)
    begin
        if(reset = '1') then
            result_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(active_reg='1') then
                result_reg <= result_nxt;
            end if;
        end if;
    end process;
    
-- Result_nxt
    process(result_reg, active_reg)
    begin
        if(active='0') then
            result_nxt(191 downto 0) <= (others => '0');
        else
            result_nxt(191 downto 0) <= result_reg(255 downto 64);
        end if;
    end process;
    
-- Counter
    process(clk, counter_reg, active_reg, reset) begin
        if(reset = '1') then
                counter_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(active_reg = '1') then
                counter_reg <= counter_reg + 1;
            else
                counter_reg <= (others => '0');
            end if;
        end if;
    end process;

-- Active
    process(clk, counter_reg, active, reset) begin
        if(reset = '1') then
            active_reg <= '0';
        elsif(clk'event and clk='1') then
            if(counter_reg = 4) then
                active_reg <= '0';
            elsif(active='1') then
                active_reg <= '1';
            end if;
        end if;
    end process;
    
-- Output
    --process(result_reg) begin
    --    for i in 0 to 256 loop
    --        result_out(i) <= active and result_reg(i);--STD_LOGIC(counter_reg(2)) and result_reg(i);
    --    end loop;
    --end process;
    
    process(counter_reg) begin
        if(counter_reg=4) then
            done_reg <= '1';
        else
            done_reg <= '0';
        end if;
    end process;
    
    result_out <= result_reg;
    --done <= STD_LOGIC(counter_reg(2)) and active_reg;
    done <= done_reg;

end Behavioral;
