--------------------------------------------------------------------------------
-- Author       : Aleksander Skarnes, Eivind Erichsen and Halvor Horvei
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- Module       : Shift Register Testbench
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   Functional testing of the Shift Register module
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg_tb is
--  Port ( );
end shift_reg_tb;

architecture Behavioral of shift_reg_tb is

-- Constants
  constant CLK_PERIOD : time                                    := 10 ns;
  constant RESET_TIME : time                                    := 10 ns;
  constant DATA_WIDTH : integer                                 := 256;
  constant TEST_DATA  : std_logic_vector(DATA_WIDTH-1 downto 0) := x"a8925173ad65686715385ea810cd28120288fc70a9bc98dd4c90d676f81f768d";
  
  signal clk_tb  : std_logic := '0';
  signal reset_n : std_logic := '1';
  
  signal data_in    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal data_out   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal shift_data : std_logic := '0';
  signal load_data  : std_logic := '0';

begin
    -- Instantiate DUT
    dut: entity work.shift_reg
        generic  map(
          DATA_WIDTH => DATA_WIDTH
        )
        port map (
        -- Clock and Reset
         clk       => clk_tb,
         rst_n     => reset_n,
         -- Inputs
         d_in      => data_in,
         load      => load_data,
         shift     => shift_data,
         -- Output
         d_out     => data_out
        );
        
    -- Clock generation
    clk_tb <= not clk_tb after CLK_PERIOD/2;
    
    -- Reset process
    process
    begin
        reset_n <= '0';
        wait for RESET_TIME;
        reset_n <= '1';
        wait;
    end process;
    
    -- Stimuli process
    process
    begin
        wait for 10*CLK_PERIOD;
        data_in <= TEST_DATA;
        load_data <= '1';
        wait for CLK_PERIOD;
        load_data <= '0';
        shift_data <= '1';
        for i in 0 to DATA_WIDTH-1 loop
            assert data_out(0) = TEST_DATA(i)
                report "Shifted data bit does not match corresponding test data bit"
                severity Failure;
            wait for CLK_PERIOD;
        end loop;
        assert true;
            report "********************************************************************************";
            report "ALL TESTS FINISHED SUCCESSFULLY";
            report "********************************************************************************";            
            report "ENDING SIMULATION..." severity Failure; 
        wait;
    end process;

end Behavioral;
