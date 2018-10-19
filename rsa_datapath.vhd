----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.10.2018 15:14:55
-- Design Name: 
-- Module Name: rsa_datapath - Behavioral
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

entity rsa_datapath is
    Port ( clk : in STD_LOGIC;
           mem_addr : in STD_LOGIC_VECTOR (4 downto 0);
           mem_data : in STD_LOGIC_VECTOR (31 downto 0);
           message_in : in STD_LOGIC_VECTOR (255 downto 0);
           message_out : out STD_LOGIC_VECTOR (255 downto 0));
end rsa_datapath;

architecture Behavioral of rsa_datapath is

begin


end Behavioral;
