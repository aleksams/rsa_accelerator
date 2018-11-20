----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2018 13:56:26
-- Design Name: 
-- Module Name: MonPro - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MonPro is
    Port ( 
            clk      : in STD_LOGIC;
            reset_n  : in STD_LOGIC;
            A        : in STD_LOGIC_VECTOR (255 downto 0);
            B        : in STD_LOGIC_VECTOR (255 downto 0);
            modulo   : in STD_LOGIC_VECTOR (255 downto 0);
            Start    : in STD_LOGIC;
            
            Done     : out STD_LOGIC;   -- TODO: koblings
            Product  : out STD_LOGIC_VECTOR (255 downto 0));            
end MonPro;

architecture Behavioral of MonPro is

-- Internal signals

-- Internal regs
signal u_reg:             std_logic_vector(257 downto 0); -- k + 1 bits
signal u_next:            std_logic_vector(257 downto 0); -- k + 1 bits
signal for_counter_reg:   unsigned(7 downto 0);           -- skal fjernes
signal for_counter_reg2:  std_logic_vector(7 downto 0);
signal state:             unsigned(2 downto 0);
signal add_counter:       unsigned(2 downto 0);

signal is_minus:             std_logic;  
signal working:              std_logic;
signal done_signal:          std_logic;
signal last_bit:             std_logic;
signal adder_sum_valid:      std_logic;
signal add_cycle:            std_logic;
signal u_minus_n_done:       std_logic;
signal last_operation:       std_logic;

signal doing_UplusB:        std_logic; -- skal fjernes
signal doing_UplusN:        std_logic; -- skal fjernes

  -- signals to adder
--signal A_reg, B_reg : std_logic_vector(255 downto 0);
signal carry_in: std_logic;
signal Num_1, Num_2: std_logic_vector(256 downto 0); -- k + 1 bits
signal add_enable: std_logic;

-- signals from adder
signal sum_from_adder: std_logic_vector(257 downto 0);
signal carry_out: std_logic;



begin
      -- Instantiate adder
    u_full_adder : entity work.full_adder port map(
      clk         => clk,
      reset_n     => reset_n,
      add_enable  => add_enable,
      is_minus    => is_minus,
      Num_1       => Num_1,
      Num_2       => Num_2,
      full_sum    => sum_from_adder,
      out_valid   => adder_sum_valid
    );

    process(clk, reset_n) 
        variable FOR_I : natural range 0 to 520 := 0; -- TODO sette riktig
    begin
        if(reset_n = '0') then
            -- Iternal
             u_reg           <= (others => '0');
             for_counter_reg <= (others => '0'); -- skal fjernes
             state           <= (others => '0');
             done_signal     <= '0';
             last_bit        <= '0';
             add_counter  <= (others => '0');
             doing_UplusB <= '0'; -- skal fjernes
             doing_UplusN <= '0'; -- skal fjernes
             add_cycle    <= '0';
             u_minus_n_done <= '0';
             is_minus     <= '0';
             last_operation <= '0';
             
            -- Adder
             add_enable  <= '0';
             Num_1       <= (others => '0');
             Num_2       <= (others => '0');
             u_next <= (others => '0');
           
        elsif(clk'event and clk='1') then
            u_next <= sum_from_adder;
            if(FOR_I = 255 and state = "000") then
                FOR_I := 0;
                last_bit <= '1';
            elsif(working = '1') then
                if(u_minus_n_done = '1') then
                    done_signal <= '1';
                elsif(add_cycle = '1') then
                    doing_UplusB <= '0';
                    doing_UplusN <= '0';
                   
                    if(add_counter = "100") then
                        add_counter <= add_counter + 1;
                        add_enable <= '0';
                    elsif(add_counter = "101") then
                        u_reg <= u_next;
                        add_cycle <= '0';
                        if(is_minus = '1') then
                            u_minus_n_done <= '1';
                        end if;
                    else
                        add_counter <= add_counter + 1;
                        
                    end if;
                else
                
                    add_counter <= (others => '0');
                    if(last_operation = '1') then --?
                        last_operation <= '1';
                    elsif(A(FOR_I) = '1' and state = "000") then
                        add_cycle <= '1';
                        add_enable <= '1';
                        Num_1 <= u_reg(256 downto 0); -- 257 bitten brukes ikke siden det er skiften ned
                        Num_2 <= '0' & B;  
                        state <= state + 1;
                        doing_UplusB <= '1';

--                    elsif((u_reg(0) = '1' xor (A(FOR_I)='1' and B(0)='1')) and state = "001") then -- is odd and correct state
                    elsif(state = "001") then
                        if(u_reg(0)='1') then 
                            add_cycle <= '1';
                            add_enable <= '1';
                            Num_1 <= u_reg(256 downto 0); -- 257 bitten brukes ikke siden det er skiften ned
                            Num_2 <= '0' & modulo;
                            doing_UplusN <= '1';
                        end if;
                        state <= state + 1;
                        
                    elsif(state = "010") then
                        u_reg(257 downto 0) <= '0' & u_reg(257 downto 1); -- mulig å comboe med u_nex
                                                
                        FOR_I := FOR_I + 1;
                        for_counter_reg <= for_counter_reg + 1; -- skal fjernes
                        if(last_bit = '1' and u_minus_n_done = '1') then
                            done_signal <= '1';
                        elsif(last_bit = '1') then
                            state <= "110"; 
                        else
                            state <= "000";
                        end if;
                    elsif(state = "110") then -- u minus n
                        
                        if(unsigned(u_reg)>unsigned(modulo)) then
                            add_cycle <= '1';
                            add_enable <= '1';
                            Num_1 <= u_reg(256 downto 0);
                            Num_2 <= '0' & not modulo;
                            is_minus <= '1';
                        else 
                            done_signal <= '1';
                        end if;
                        
                    else
                        state <= state + 1;
                        add_enable <= '0';
                       
                    end if; -- State if, kan byttes i switch
                end if; -- if add_cycle
            else -- elsif working = '1'
                add_enable <= '0';
            end if; -- elsif working = '1'
        end if; -- reset clk
    end process;

    process (clk, reset_n) begin
        if(reset_n = '0') then
            working <= '0';
        elsif(clk'event and clk='1') then
        
            if(Start = '1') then
                Done <= '0';
                working <= '1';
                Product <= (others => '0');
            elsif(done_signal = '1') then
                working <= '0';
                Done <= '1';
                Product <= u_reg(255 downto 0);
            end if;
            
        end if;
    end process;
end Behavioral;
