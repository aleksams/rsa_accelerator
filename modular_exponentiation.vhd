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
    Port ( 
           -- to MonPro
           message       : in STD_ULOGIC_VECTOR (255 downto 0);
           key           : in STD_ULOGIC_VECTOR (255 downto 0);
           modulo        : in STD_ULOGIC_VECTOR (255 downto 0);
           r_mod_n       : in STD_ULOGIC_VECTOR (255 downto 0);
           r2_mod_n      : in STD_ULOGIC_VECTOR (255 downto 0);

           clk           : in STD_ULOGIC;
           done          : out STD_ULOGIC;
           cipher        : out STD_ULOGIC_VECTOR (255 downto 0));
end modular_exponentiation;

architecture Behavioral of modular_exponentiation is

signal monPro_start : STD_ULOGIC;
signal monPro_done  : STD_ULOGIC;
signal A_next       : STD_ULOGIC;
signal B_next       : STD_ULOGIC;
signal product_reg  : STD_ULOGIC_VECTOR(255 downto 0);

begin

  -- Instantiate the Monpro
  u_Monpro : entity work.Monpro port map(
    -- Clocks and resets
    clk             => clk,
    -- Signals
    start           => monPro_start,
    done            => monPro_done,
    -- Inputs
    A               => A_next,
    B               => B_next,
    modulo          => modulo,
    -- Outputs
    product         => product_reg
  );

  

end Behavioral;