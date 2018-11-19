----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2018 14:11:22
-- Design Name: 
-- Module Name: full_adder - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity full_adder is
    Port ( 
    -- Clocks and resets
           clk          : in STD_LOGIC;
           reset_n      : in STD_LOGIC;
           add_enable   : in STD_LOGIC;
           Num_1        : in STD_LOGIC_VECTOR (255 downto 0);
           Num_2        : in STD_LOGIC_VECTOR (255 downto 0);
           full_sum     : out STD_LOGIC_VECTOR (255 downto 0);
           out_valid    : out std_logic);
end full_adder;

architecture Behavioral of full_adder is

-- reg associated with adder
signal sum_reg: std_logic_vector(255 downto 0);
signal carry_reg: std_logic_vector(3 downto 0);
  
-- counter
signal output_shift_counter_r: unsigned(2 downto 0);

--signal a_r: std_logic_vector(255 downto 0);
--signal b_r: std_logic_vector(255 downto 0);

  -- signals to adder
signal to_adder_1, to_adder_2 : std_logic_vector(63 downto 0);
signal carry_in: std_logic;

-- signals from adder
signal sum_from_adder: std_logic_vector(63 downto 0);
signal carry_out: std_logic;

signal done_add: std_logic;
signal add_enable_reg: std_logic;

begin
  -- Instantiate cla_adder
  u_carry_look_ahead : entity work.cla_adder port map(
     Num_A       => to_adder_1,
     Num_B       => to_adder_2,
     carry_in    => carry_in,
     sum         => sum_from_adder,
     carry_out   => carry_out
  );
  
process (sum_reg, done_add) begin
    if(done_add = '1') then
        full_sum <= sum_reg;
        out_valid <= '1';
    else
        full_sum <= (others => '0');
        out_valid <= '0';
    end if;
end process;



process (clk, reset_n) begin
    if(reset_n = '0') then
--      a_r       <= (others => '0');
--      b_r       <= (others => '0');
      done_add  <= '0';
--      carry_reg <= (others => '0');
--      carry_in  <= '0';
      output_shift_counter_r <= (others => '0'); 
    elsif(clk'event and clk='1') then
--        a_r <= Num_1;
--        b_r <= Num_2;
        if(done_add = '1') then
--            carry_in   <= '0';
            done_add <= '0';
            output_shift_counter_r <= (others => '0');
        elsif(add_enable = '1') then
            output_shift_counter_r <= output_shift_counter_r + 1;
            case output_shift_counter_r is
                  when "000" =>
                      sum_reg(63 downto 0) <= sum_from_adder;
                      
                  when "001" =>
                      sum_reg(127 downto 64) <= sum_from_adder;
                      
                  when "010" =>
                      sum_reg(191 downto 128) <= sum_from_adder;
                      
                  when "011" =>
                      sum_reg(255 downto 192) <= sum_from_adder;
                      done_add <= '1';
                  when others =>
                      sum_reg <= (others => '0');
            end case;
        else 
            sum_reg <= (others => '0');
        end if;
    end if;
end process;

process (Num_1,Num_2, carry_out, carry_reg, output_shift_counter_r, add_enable) begin
    if(add_enable = '1') then
      case output_shift_counter_r is
        when "000" =>
            carry_in <= '0';
            to_adder_1 <= Num_1(63 downto 0);
            to_adder_2 <= Num_2(63 downto 0);
            carry_reg(0) <= carry_out;
        when "001" =>
            carry_in <= carry_reg(0);
            to_adder_1 <= Num_1(127 downto 64);
            to_adder_2 <= Num_2(127 downto 64);
            carry_reg(1) <= carry_out;
        when "010" =>
            carry_in <= carry_reg(1);
            to_adder_1 <= Num_1(191 downto 128);
            to_adder_2 <= Num_2(191 downto 128);
            carry_reg(2) <= carry_out;
        when "011" =>
            carry_in <= carry_reg(2);
            to_adder_1 <= Num_1(255 downto 192);
            to_adder_2 <= Num_2(255 downto 192);
        when others =>
            carry_in <= '0';
            to_adder_1 <= (others => '0');
            to_adder_2 <= (others => '0');
            carry_reg  <= (others => '0');
      end case;
    else 
        carry_reg <= (others => '0');
        carry_in  <= '0';
    end if;
end process;

--process (a_r, b_r, carry_out, carry_reg, output_shift_counter_r, add_enable) begin
--    if(add_enable = '1') then
--      case output_shift_counter_r is
--        when "000" =>
--            carry_in <= '0';
--            to_adder_1 <= a_r(63 downto 0);
--            to_adder_2 <= b_r(63 downto 0);
--            carry_reg(0) <= carry_out;
--        when "001" =>
--            carry_in <= carry_reg(0);
--            to_adder_1 <= a_r(127 downto 64);
--            to_adder_2 <= b_r(127 downto 64);
--            carry_reg(1) <= carry_out;
--        when "010" =>
--            carry_in <= carry_reg(1);
--            to_adder_1 <= a_r(191 downto 128);
--            to_adder_2 <= b_r(191 downto 128);
--            carry_reg(2) <= carry_out;
--        when "011" =>
--            carry_in <= carry_reg(2);
--            to_adder_1 <= a_r(255 downto 192);
--            to_adder_2 <= b_r(255 downto 192);
--        when others =>
--            carry_in <= '0';
--            to_adder_1 <= (others => '0');
--            to_adder_2 <= (others => '0');
--            carry_reg  <= (others => '0');
--      end case;
--    else 
--        carry_reg <= (others => '0');
--        carry_in  <= '0';
--    end if;
--end process;

end Behavioral;
