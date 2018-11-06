----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.10.2018 10:20:03
-- Design Name: 
-- Module Name: modular_product - Behavioral
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

entity modular_product is
    Port ( A        : in STD_LOGIC_VECTOR (255 downto 0);
           B        : in STD_LOGIC_VECTOR (255 downto 0);
           modulo   : in STD_LOGIC_VECTOR (255 downto 0);
           clk      : in STD_LOGIC;
           start    : in STD_LOGIC
           done     : out STD_LOGIC;
           product  : out STD_LOGIC_VECTOR (255 downto 0));
end modular_product;

architecture Behavioral of modular_product is
    signal product_reg : STD_ULOGIC_VECTOR (256 downto 0);

begin

    process(clk) begin
        if(clk'event and clk='1') then
            if(start='1') then
                product_reg <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
