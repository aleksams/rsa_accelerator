----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2018 10:49:04
-- Design Name: 
-- Module Name: shift_reg - Behavioral
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
use WORK.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_reg is
    Port ( d_in  : in STD_LOGIC_VECTOR (255 downto 0);
           d_out : buffer STD_LOGIC_VECTOR (255 downto 0);
           rst   : in STD_LOGIC;
           clk   : in STD_LOGIC;
           load  : in STD_LOGIC);
end shift_reg;

architecture Behavioral of shift_reg is

begin
    process(clk, load, rst, d_in) begin
        if(rst='1') then
            d_out <= (others => '0');
        elsif(clk'event and clk='1') then
            if(load='1') then
                d_out <= d_in;
            else
                d_out(254 downto 0) <= d_out(255 downto 1);
                d_out(255) <= '0';
            end if;
        end if;
    end process;

end Behavioral;
