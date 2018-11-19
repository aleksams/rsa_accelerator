----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2018 14:02:22
-- Design Name: 
-- Module Name: cla_adder - Behavioral
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

entity cla_adder is
    Port ( Num_A : in STD_LOGIC_VECTOR (63 downto 0);
           Num_B : in STD_LOGIC_VECTOR (63 downto 0);
           carry_in : in STD_LOGIC;
           sum : out STD_LOGIC_VECTOR (63 downto 0);
           carry_out : out STD_LOGIC);
end cla_adder;

architecture Behavioral of cla_adder is
signal    h_sum              :    STD_LOGIC_VECTOR(63 DOWNTO 0);
signal    carry_generate     :    STD_LOGIC_VECTOR(63 DOWNTO 0);
signal    carry_propagate    :    STD_LOGIC_VECTOR(63 DOWNTO 0);
signal    carry_in_internal  :    STD_LOGIC_VECTOR(63 DOWNTO 1);

begin
h_sum <= Num_A XOR Num_B;
carry_generate <= Num_A AND Num_B;
carry_propagate <= Num_A OR Num_B;
PROCESS (carry_generate,carry_propagate,carry_in_internal)
BEGIN
carry_in_internal(1) <= carry_generate(0) OR (carry_propagate(0) AND carry_in);
    inst: FOR i IN 1 TO 62 LOOP
          carry_in_internal(i+1) <= carry_generate(i) OR (carry_propagate(i) AND carry_in_internal(i));
          END LOOP;
carry_out <= carry_generate(63) OR (carry_propagate(63) AND carry_in_internal(63));
END PROCESS;

sum(0) <= h_sum(0) XOR carry_in;
sum(63 DOWNTO 1) <= h_sum(63 DOWNTO 1) XOR carry_in_internal(63 DOWNTO 1);
end Behavioral;
