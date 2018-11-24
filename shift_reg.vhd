--------------------------------------------------------------------------------
-- Author       : Aleksander Skarnes, Eivind Erichsen and Halvor Horvei
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- Module       : Shift Register
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   Calculate the Montgomery modular product
--   U = AB mod modulo.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.ALL;

entity shift_reg is
    Generic (
       DATA_WIDTH : integer);
    Port (
           -- Input Data
           d_in  : in     STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           -- Output Data
           d_out : buffer STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           -- Clock and Reset
           rst_n : in     STD_LOGIC;
           clk   : in     STD_LOGIC;
           -- Controll Signals
           shift : in     STD_LOGIC;
           load  : in     STD_LOGIC);
end shift_reg;

architecture Behavioral of shift_reg is

signal out_nxt : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);

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
            out_nxt(DATA_WIDTH-2 downto 0) <= d_out(DATA_WIDTH-1 downto 1);
            out_nxt(DATA_WIDTH-1) <= '0';
        else
            out_nxt <= d_out;
        end if;
    end process;

end Behavioral;
