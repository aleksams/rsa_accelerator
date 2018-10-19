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
    Port ( d_in  : in STD_ULOGIC_VECTOR (255 downto 0);
           d_out : buffer STD_ULOGIC_VECTOR (255 downto 0);
           rst   : in STD_ULOGIC;
           clk   : in STD_ULOGIC;
           load  : in STD_ULOGIC;
           sin   : in STD_ULOGIC;
           left  : in STD_ULOGIC;
           right : in STD_ULOGIC);
end shift_reg;

architecture Behavioral of shift_reg is

begin
    process(all) begin
        
    end process;

end Behavioral;
