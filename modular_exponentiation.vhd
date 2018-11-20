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
use IEEE.NUMERIC_STD.ALL;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modular_exponentiation is
    Port ( 
           -- Clock and Reset
           clk           : in STD_LOGIC;
           reset         : in STD_LOGIC;
           -- Inputs
           start         : in STD_LOGIC;
           message       : in STD_LOGIC_VECTOR (255 downto 0);
           key           : in STD_LOGIC_VECTOR (255 downto 0);
           modulo        : in STD_LOGIC_VECTOR (255 downto 0);
           r_mod_n       : in STD_LOGIC_VECTOR (255 downto 0);
           r2_mod_n      : in STD_LOGIC_VECTOR (255 downto 0);
           -- Outputs
           done          : out STD_LOGIC;
           cipher        : out STD_LOGIC_VECTOR (255 downto 0));
end modular_exponentiation;

architecture Behavioral of modular_exponentiation is
    
    type State_type is (STATE_START, STATE_START_DONE, 
                        STATE_CC_MODN, STATE_CC_MODN_DONE, 
                        STATE_CM_MODN, STATE_CM_MODN_DONE, 
                        STATE_DONE, STATE_IDLE);
    
    -- STATE SIGNALS
    signal State, State_nxt : State_Type;
    
    -- Internal Signals
    signal done_i       : STD_LOGIC;
    
    -- MonPro Signals
    signal monPro_start : STD_LOGIC;
    signal monPro_done  : STD_LOGIC;
    signal A_next       : STD_LOGIC_VECTOR(255 downto 0);
    signal B_next       : STD_LOGIC_VECTOR(255 downto 0);
    signal monPro_out   : STD_LOGIC_VECTOR(255 downto 0);
    
    -- Key Shift Register
    signal load_shift_reg : STD_LOGIC;
    signal shift          : STD_LOGIC;
    signal shift_reg_out  : STD_LOGIC_VECTOR (255 downto 0);
    signal key_reversed   : STD_LOGIC_VECTOR (255 downto 0);
    
    -- Message Bar Register
    signal message_bar_reg_en : STD_LOGIC;
    signal message_bar_reg : STD_LOGIC_VECTOR(255 downto 0);
    signal message_bar_nxt : STD_LOGIC_VECTOR(255 downto 0);
    
    -- Cipher Text Register
    signal cipher_reg_en : STD_LOGIC;
    signal cipher_reg    : STD_LOGIC_VECTOR(255 downto 0);
    signal cipher_nxt    : STD_LOGIC_VECTOR(255 downto 0);
    
    -- Loop control
    signal loop_counter : UNSIGNED (7 downto 0); -- count to 256
    signal loop_reg_en  : STD_LOGIC;
begin

-- Assignments
    cipher <= cipher_reg;
    done <= done_i;
    
    process(key) begin
        for i in 0 to 255 loop
            key_reversed(i) <= key(255-i);
        end loop;
    end process;

-- Instantiate the MonPro
  u_Monpro : entity work.modular_product port map(
    -- Clocks and resets
    clk             => clk,
    reset           => reset,
    -- Signals
    start           => monPro_start,
    done            => monPro_done,
    -- Inputs
    A               => A_next,
    B               => B_next,
    modulo          => modulo,
    -- Outputs
    product         => monPro_out
  );
  
  -- Shift Register Entity for Key
  u_key_shift_reg: entity work.shift_reg
      port map (
       clk       => clk,
       rst       => reset,
       -- inputs
       d_in      => key_reversed,
       load      => load_shift_reg,
       shift     => shift,
       -- output
       d_out     => shift_reg_out
      );

--------------------------------
-- Finite State Machine Begin --
--------------------------------

-- State Register
    process(clk, reset) begin
        if(reset='1') then
            State <= STATE_IDLE;
        elsif(clk'event and clk='1') then
            State <= State_nxt;
        end if;
    end process;
    
-- Next State
    process(State, start, monPro_done) begin
        case( State ) is
            -- IDLE Description
            when STATE_IDLE =>
                if(start='1') then
                    State_nxt <= STATE_START;
                else
                    State_nxt <= STATE_IDLE;
                end if;
            -- START Description
            when STATE_START =>
                if(monPro_done='1') then
                    State_nxt <= STATE_START_DONE;
                end if;
            when STATE_START_DONE =>
                State_nxt <= STATE_CC_MODN;
            -- ADD_AB Description
            when STATE_CC_MODN =>
                if(monPro_done='1') then
                    State_nxt <= STATE_CC_MODN_DONE;
                end if;
            -- ADD_AB Description
            when STATE_CC_MODN_DONE =>
                State_nxt <= STATE_CM_MODN;
            -- ADD_N Description
            when STATE_CM_MODN =>
                if(monPro_done='1' or shift_reg_out(0)='0') then
                    State_nxt <= STATE_CM_MODN_DONE;
                end if;
            -- 
            when STATE_CM_MODN_DONE =>
                if(loop_counter=255) then
                    State_nxt <= STATE_DONE;
                else
                    State_nxt <= STATE_CC_MODN;
                end if;
            -- DONE Description
            when STATE_DONE =>
                State_nxt <= STATE_IDLE;
            -- Other Description
            --when others =>
            --    State_nxt <= STATE_IDLE;
        end case;
    end process;

-- System controll
    process(State, loop_counter, shift_reg_out, cipher_reg, message_bar_reg, monPro_out) begin
        load_shift_reg     <= '0';
        shift              <= '0';
        cipher_reg_en      <= '0';
        cipher_nxt         <= cipher_reg;
        message_bar_reg_en <= '0';
        message_bar_nxt    <= message_bar_reg;
        done_i             <= '0';
        loop_reg_en        <= '0';
        monPro_start       <= '0';
        A_next             <= (others => '0');
        B_next             <= (others => '0');
        case(State) is
            when STATE_START =>
                load_shift_reg <= '1';
                cipher_nxt <= r_mod_n;
                A_next <= message;
                B_next <= r2_mod_n;
                monPro_start <= '1';
            when STATE_START_DONE =>
                message_bar_reg_en <= '1';
                message_bar_nxt <= monPro_out;
            when STATE_CC_MODN =>
                A_next <= cipher_reg;
                B_next <= cipher_reg;
                monPro_start <= '1';
            when STATE_CC_MODN_DONE =>
                cipher_reg_en <= '1';
                cipher_nxt <= monPro_out;
            when STATE_CM_MODN =>
                if(shift_reg_out(0)='1') then
                    A_next <= message_bar_reg;
                    B_next <= cipher_reg;
                    monPro_start <= '1';
                end if;
            when STATE_CM_MODN_DONE =>
                if(shift_reg_out(0)='1') then
                    shift <= '1';
                    cipher_reg_en <= '1';
                    cipher_nxt <= monPro_out;
                else
                    shift <= '1';
                end if;
            when STATE_DONE =>
                done_i <= '1';
            when others =>
        end case;
    end process;
    
------------------------------
-- Finite State Machine End --
------------------------------

-- Cipher register
    process(clk, reset) begin
        if(reset='1') then
            cipher_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(cipher_reg_en='1') then
                cipher_reg <= cipher_nxt;
            end if;
        end if;
    end process;

-- Loop Counter
    process(clk, reset) begin
        if(reset='1') then
            loop_counter <= (others => '0');
        elsif(clk'event and clk='1') then
            if(State=STATE_CM_MODN_DONE) then
                loop_counter <= loop_counter + 1;
            elsif(State=STATE_IDLE) then
                loop_counter <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
