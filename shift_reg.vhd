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
           rst_n   : in STD_LOGIC;
           clk   : in STD_LOGIC;
           shift : in STD_LOGIC;
           load  : in STD_LOGIC);
end shift_reg;

architecture Behavioral of shift_reg is

signal out_nxt : STD_LOGIC_VECTOR (255 downto 0);

begin
    process(clk, rst_n) begin
        if(rst_n='0') then
            d_out <= (others => '0');
        elsif(clk'event and clk='1') then
            d_out <= out_nxt;
        end if;
    end process;

    process(shift, load, d_out, d_in) begin
        if(load='1') then
            out_nxt <= d_in;
        elsif(shift='1') then
            out_nxt(254 downto 0) <= d_out(255 downto 1);
            out_nxt(255) <= '0';
        else
            out_nxt <= d_out;
        end if;
    end process;

end Behavioral;
