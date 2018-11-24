----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.11.2018 09:04:26
-- Design Name: 
-- Module Name: MonPro_tb - Behavioral
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
use ieee.math_real.all;
use ieee.numeric_std.all;

entity modular_product_tb is
   -- nothing
end modular_product_tb;

architecture Behavioral of modular_product_tb is
      -- Constants
    constant BLOCK_SIZE    : integer := 256;
    constant R_SIZE        : integer := 256;
    constant CLK_PERIOD    : time := 10 ns;
    constant RESET_TIME    : time := 10 ns;
    
    -- Clocks and resets 
    signal clk            : std_logic := '0';
    signal reset_n        : std_logic := '0';
    
    -- signal inputs
    signal A        : STD_LOGIC_VECTOR (255 downto 0);
    signal B        : STD_LOGIC_VECTOR (255 downto 0);
    signal start    : STD_LOGIC;
    
    -- signal outputs
    signal modulo     : STD_LOGIC_VECTOR (255 downto 0);
    signal Product    : STD_LOGIC_VECTOR (255 downto 0);    
    signal done  : STD_LOGIC;
    
    signal teststring1 : STD_LOGIC_VECTOR (255 downto 0);
    signal teststring2 : STD_LOGIC_VECTOR (255 downto 0);
    signal teststring3 : STD_LOGIC_VECTOR (255 downto 0);
    signal teststring4 : STD_LOGIC_VECTOR (255 downto 0);
    signal teststring5 : STD_LOGIC_VECTOR (255 downto 0);
    signal teststring6 : STD_LOGIC_VECTOR (255 downto 0);
    
    signal expected_product1 : STD_LOGIC_VECTOR (255 downto 0);
    signal expected_product2 : STD_LOGIC_VECTOR (255 downto 0);
    signal expected_product3 : STD_LOGIC_VECTOR (255 downto 0);
    signal expected_product4 : STD_LOGIC_VECTOR (255 downto 0);
    signal expected_product5 : STD_LOGIC_VECTOR (255 downto 0);
    signal expected_product6 : STD_LOGIC_VECTOR (255 downto 0);
    
    signal zero_vector : STD_LOGIC_VECTOR (255 downto 0);

    signal testcaseA_counter : unsigned(2 downto 0);
    signal testcaseB_counter : unsigned(2 downto 0);
    signal tb_done      : STD_LOGIC;
    
     signal tb_init      : STD_LOGIC;
    
begin


      dut: entity work.modular_product 
      generic  map(
        DATA_WIDTH => BLOCK_SIZE,
        R_SIZE     => R_SIZE
      )
      port map (
      
        -- Clocks and resets 
        clk            => clk, 
        reset_n        => reset_n, 
        -- Data input interface           
        Start      => Start, 
        A          => A,            
        B          => B,
        modulo     => modulo,
        -- Data output interface           
        Done => Done,
        Product => Product
      );
      
      teststring1      <= x"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
      teststring2      <= x"1010101010101010101010101010101010101010101010101010101010101010";
      teststring3      <= x"0000000000000000000000000000000000000000000000000000000000000000";
      teststring4      <= x"0b03764d2bd0d7650a94ec5c669cd45dfe3e2b7c5936702168bc67a1bd1db7b6";
      teststring5      <= x"ca5fe788135de9da1ebd6d0e2aa2cdfd19a6c5df172c5296f8c2426d2d765c5d";
      teststring6      <= x"203223e5dee6f728c01bd181668a89404de215c71e1c8f73f847968035be9127";
      
      zero_vector      <= x"0000000000000000000000000000000000000000000000000000000000000000";
      
      -- Clock generation
      clk <= not clk after CLK_PERIOD/2;
    
      -- Reset generation
      reset_proc: process
      begin
        wait for RESET_TIME;
        reset_n <= '1';
        wait;
      end process;
      
      process(clk, reset_n) begin
          if(reset_n = '0') then
          
          elsif(clk'event and clk='1') then
          
          if(Done = '1') then
          
          if(testcaseA_counter = "011" or testcaseB_counter = "010") then
--            assert Product = zero_vector
--                  report "Product did not match expected value"
--                  severity Failure;
           else
           
                case testcaseB_counter is
                    
                    when "000" =>
                        if(testcaseA_counter = "001") then
                            assert Product = x"e277949a7057f76169acd75ab146ad84c021b45efa80d234d2bdc8b2c4b45739"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "010") then
                            assert Product = x"74973a9b133e14df6a1c58a9e582299ddf90a38c4cabf69cdee2ede411b6a0ce"
                                report "Product did not match expected value"
                                severity Failure;
                            
                        elsif(testcaseA_counter = "100") then
                            assert Product = x"8ff89b00530af9bed5675b8a1829874dc1627702b387709f4ef989c8d555a6cc"
                                report "Product did not match expected value"
                                severity Failure;
                        elsif(testcaseA_counter = "101") then
                            assert Product = x"630de1bddfc25d33a2c55174d449e36a2b3f29571e80e36a642abd4bbcaacfc3"
                                report "Product did not match expected value"
                                severity Failure;
                        end if;
                    

                        
                    when "001" =>
                        if(testcaseA_counter = "001") then
                            assert Product = x"74973a9b133e14df6a1c58a9e582299ddf90a38c4cabf69cdee2ede411b6a0ce"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "010") then
                            assert Product = x"640f883178fbddf9f359078332059246fa79ec008b71a503f1ef3f20f3d8f04e"
                                report "Product did not match expected value"
                                severity Failure;
                            
                        elsif(testcaseA_counter = "100") then
                            assert Product = x"8fef8075b29c06fd1d04cd58fb314cd16fbdc214d4920eda7260b4f9a0d5b7e0"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "101") then
                            assert Product = x"04688fb73a2e23bdc2af5b56abee24e34ffc53f413fed74351aea7f9502fde77"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "000") then
                            assert Product = x"0cca89c0caf3bebe99d89849692a842cc341a9fd9292944078bd1318731ab024"
                                report "Product did not match expected value"
                                severity Failure;
                        end if;
                    
                    when "011" =>
                        if(testcaseA_counter = "001") then
                            assert Product = x"8ff89b00530af9bed5675b8a1829874dc1627702b387709f4ef989c8d555a6cc"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "010") then
                            assert Product = x"8fef8075b29c06fd1d04cd58fb314cd16fbdc214d4920eda7260b4f9a0d5b7e0"
                                report "Product did not match expected value"
                                severity Failure;
                            
                        elsif(testcaseA_counter = "100") then
                            assert Product = x"07098542dc237b9d260603861835d8f17a500eb2b60968141b1721a2ab4e6cc3"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = x"4513d6f2cac9d0f3e2824513053d879f7cfea7f3470ac62d11e97c72e2a34187") then
                            assert Product = x"50be949725fd5ccb1e8d6b22f365638a839983332202d97742dc91467b0a8670"
                                report "Product did not match expected value"
                                severity Failure;
                             --50be949725fd5ccb1e8d6b22f365638a839983332202d97742dc91467b0a8670   
                        elsif(testcaseA_counter = "000") then
                            assert Product = zero_vector
                                report "Product did not match expected value"
                                severity Failure;
                        end if;
                    
                    when "101" =>   
                        if(testcaseA_counter = "001") then
                            assert Product = x"8ff89b00530af9bed5675b8a1829874dc1627702b387709f4ef989c8d555a6cc"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = "010") then
                            assert Product = x"8fef8075b29c06fd1d04cd58fb314cd16fbdc214d4920eda7260b4f9a0d5b7e0"
                                report "Product did not match expected value"
                                severity Failure;
                            
                        elsif(testcaseA_counter = "100") then
                            assert Product = x"07098542dc237b9d260603861835d8f17a500eb2b60968141b1721a2ab4e6cc3"
                                report "Product did not match expected value"
                                severity Failure;
                                
                        elsif(testcaseA_counter = x"4513d6f2cac9d0f3e2824513053d879f7cfea7f3470ac62d11e97c72e2a34187") then
                            assert Product = x""
                                report "Product did not match expected value"
                                severity Failure;
                             --   
                        elsif(testcaseA_counter = "000") then
                            assert Product = x"50be949725fd5ccb1e8d6b22f365638a839983332202d97742dc91467b0a8670"
                                report "Product did not match expected value"
                                severity Failure;
                        end if;
                when others =>
                end case;
            end if; -- zero check
          end if;
          end if; -- reset/clk
      end process;
      
      
      process(clk, reset_n) begin
          if(reset_n = '0') then
            tb_done <= '0';
            Start       <= '0';
            testcaseA_counter <= "000";
            testcaseB_counter <= (others => '0');
            modulo <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
            A <= teststring1;
            B <= teststring1;
            Start       <= '0';
            tb_init <= '0';
            
          elsif(clk'event and clk='1') then
            
            if(Done = '1' or tb_init = '0') then
            tb_init <= '1';
            Start       <= '0';
                case testcaseA_counter is
                  when "000" =>
                    A <= teststring1;
                    testcaseA_counter <= testcaseA_counter + 1;
                    Start       <= '1';

                            
                  when "001" =>
                    A <= teststring2;
                    testcaseA_counter <= testcaseA_counter + 1;
                    Start       <= '1';

                            
                  when "010" =>
                    A <= zero_vector;  
                    testcaseA_counter <= testcaseA_counter + 1;
                    Start       <= '1';
       
                  when "011" =>
                    A <= teststring4;  
                    testcaseA_counter <= testcaseA_counter + 1;
                    Start       <= '1';

                            
                  when "100" =>
                    A <= teststring5;
                    testcaseA_counter <= testcaseA_counter + 1;
                    Start       <= '1';

                  when "101" =>
                    Start       <= '1';
                    A <= teststring6;
                    if(testcaseB_counter = "101")then
                        tb_done <= '1';
                    else
                        testcaseB_counter <= testcaseB_counter + 1;
                        testcaseA_counter <= (others => '0');
                    end if;
                    
                    when others =>
                end case; 
                
                case testcaseB_counter is
                  when "000" =>
                    B <= teststring1;
                  when "001" =>
                    B <= teststring2;
                  when "010" =>
                    B <= teststring3;    
                  when "011" =>
                    B <= teststring4;     
                  when "100" =>
                    B <= teststring5;        
                  when "101" =>
                    B <= teststring6;
                   when others =>
                end case; 
                
              end if; -- if MonPro is done
           end if; -- clk
      end process;
    
      -- Stimuli generation
      stimuli_proc: process
      begin
      wait for 10*CLK_PERIOD;
      
        -- Send in first test vector
--        Start       <= '0';
--        A           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
--        B           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
--        modulo      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000000";
        
--        wait for 2*CLK_PERIOD;
        
----        modulo      <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000077"; -- modulo 1110111
----        A           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000042"; -- Msg bin 1000010 
----        B           <= x"0000000000000000" & x"0000000000000000" & x"0000000000000000" & x"0000000000000051"; -- r2_mod_n 1010001
        
--        -- message
--        A      <= x"0A23232323232323232323232323232323232323232323232323232323232323";
--        A      <= x"0A23232323232323232323232323232323232323232323232323232323232323";
--        -- r2_mod_n
--        B      <= x"56ddf8b43061ad3dbcd1757244d1a19e2e8c849dde4817e55bb29d1c20c06364"; -- bin 1010001. dec 81
--        modulo <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
--        wait for 1*CLK_PERIOD;
--        Start       <= '1';
        
--        wait for 1*CLK_PERIOD;
--        Start       <= '0';
        
--        wait for 2500*CLK_PERIOD;
        
        wait;

      end process;  
end Behavioral;