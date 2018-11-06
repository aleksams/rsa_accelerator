----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2018 10:20:03
-- Design Name: 
-- Module Name: rsa_core - Behavioral
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

entity modular_exponentiation is
    Port ( M        : in STD_LOGIC_VECTOR (255 downto 0);
           E        : in STD_LOGIC_VECTOR (255 downto 0);
           n        : in STD_LOGIC_VECTOR (255 downto 0);
           r_mod_n  : in STD_LOGIC_VECTOR (255 downto 0);
           clk      : in STD_LOGIC;
           done     : out STD_LOGIC;
           C        : out STD_LOGIC_VECTOR (255 downto 0));
end modular_exponentiation;

architecture Behavioral of modular_exponentiation is

begin


end Behavioral;