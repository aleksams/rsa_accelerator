--------------------------------------------------------------------------------
-- Author       : Aleksander Skarnes, Eivind Erichsen and Halvor Horvei
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- Module       : Modular Exponentiation
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   Calculate
--   C = M**key mod modulo
--   using the LR Binary Method.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use work.all;

entity modular_exponentiation is
    Generic (
       DATA_WIDTH : integer := 256;
       R_SIZE     : integer := 256);
    Port ( 
           -- Clock and Reset
           clk           : in STD_LOGIC;
           reset_n       : in STD_LOGIC;
           -- Control Signals
           start         : in STD_LOGIC;
           done          : out STD_LOGIC;
           -- Inputs
           message       : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           key           : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           modulo        : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           r_mod_n       : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           r2_mod_n      : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           -- Outputs
           cipher        : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end modular_exponentiation;

architecture Behavioral of modular_exponentiation is
    
    -- State Definition
    type State_type is (STATE_START,   STATE_START_DONE, 
                        STATE_CP_MODN, STATE_CP_MODN_DONE, 
                        STATE_C1_MODN, STATE_C1_MODN_DONE,
                        STATE_DONE,    STATE_IDLE);
    
    -- State Signals
    signal State, State_nxt : State_Type;
    
    -- Internal Signals
    signal done_i       : STD_LOGIC;
    
    -- MonPro1 Signals
    signal monPro1_start         : STD_LOGIC;
    signal monPro1_done          : STD_LOGIC;
    signal monPro1_A_next        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal monPro1_B_next        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal monPro1_out           : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    -- MonPro2 Signals
    signal monPro2_start         : STD_LOGIC;
    signal monPro2_done          : STD_LOGIC;
    signal monPro2_A_next        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal monPro2_B_next        : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal monPro2_out           : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    -- Key Shift Register
    signal load_shift_reg    : STD_LOGIC;
    signal shift             : STD_LOGIC;
    signal shift_reg_out     : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal shift_reg_reduced : STD_LOGIC;
    
    -- P Register
    signal P_reg_en  : STD_LOGIC;
    signal P_reg     : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal P_nxt     : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    -- Cipher Text Register
    signal cipher_reg_en : STD_LOGIC;
    signal cipher_reg    : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal cipher_nxt    : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    
    -- Loop control
    signal loop_counter : UNSIGNED (7 downto 0); -- count to 256
    signal loop_reg_en  : STD_LOGIC;
    
begin

-- Assignments
    shift_reg_reduced <= or_reduce(shift_reg_out);
    cipher <= cipher_reg;
    done <= done_i;

-- Instantiate two MonPros
  u_Monpro_1 : entity work.modular_product 
    generic  map(
      DATA_WIDTH => DATA_WIDTH,
      R_SIZE     => R_SIZE
    )
    port map(
      -- Clocks and resets
      clk             => clk,
      reset_n         => reset_n,
      -- Control Signals
      start           => monPro1_start,
      done            => monPro1_done,
      -- Inputs
      A               => monPro1_A_next,
      B               => monPro1_B_next,
      modulo          => modulo,
      -- Outputs
      product         => monPro1_out
    );
  
  u_Monpro_2 : entity work.modular_product 
    generic  map(
      DATA_WIDTH => DATA_WIDTH,
      R_SIZE     => R_SIZE
    )    
    port map(
      -- Clocks and resets
      clk             => clk,
      reset_n         => reset_n,
      -- Control Signals
      start           => monPro2_start,
      done            => monPro2_done,
      -- Inputs
      A               => monPro2_A_next,
      B               => monPro2_B_next,
      modulo          => modulo,
      -- Outputs
      product         => monPro2_out
    );
  
  -- Shift Register Entity for Key
  u_key_shift_reg: entity work.shift_reg
    generic  map(
      DATA_WIDTH => DATA_WIDTH
    )
    port map (
      clk       => clk,
      rst_n       => reset_n,
      -- inputs
      d_in      => key,
      load      => load_shift_reg,
      shift     => shift,
      -- output
      d_out     => shift_reg_out
    );

--------------------------------
-- Finite State Machine Begin --
--------------------------------

-- State Register
    process(clk, reset_n) begin
        if(reset_n='0') then
            State <= STATE_IDLE;
        elsif(clk'event and clk='1') then
            State <= State_nxt;
        end if;
    end process;
    
-- Next State
    process(State, start, monPro1_done, monPro2_done, loop_counter, shift_reg_out, shift_reg_reduced) begin
        State_nxt <= State;
        case( State ) is
            when STATE_IDLE =>
                if(start='1') then
                    State_nxt <= STATE_START;
                else
                    State_nxt <= STATE_IDLE;
                end if;

            when STATE_START =>
                if(monPro1_done='1') then
                    State_nxt <= STATE_START_DONE;
                end if;

            when STATE_START_DONE =>
                State_nxt <= STATE_CP_MODN;

            when STATE_CP_MODN =>
                if(monPro2_done='1' and (monPro1_done='1' or shift_reg_out(0)='0')) then
                    State_nxt <= STATE_CP_MODN_DONE;
                end if;
                
            when STATE_CP_MODN_DONE =>
                if(loop_counter=255 or shift_reg_reduced='0') then
                    State_nxt <= STATE_C1_MODN;
                else
                    State_nxt <= STATE_CP_MODN;
                end if;

            when STATE_C1_MODN =>
                if(monPro1_done='1') then
                    State_nxt <= STATE_C1_MODN_DONE;
                end if;
            
            when STATE_C1_MODN_DONE =>
                State_nxt <= STATE_DONE;
            
            when STATE_DONE =>
                State_nxt <= STATE_IDLE;

            when others =>
                State_nxt <= STATE_IDLE;
        end case;
    end process;

-- System controll
    process(State, loop_counter, shift_reg_out, cipher_reg, P_reg, monPro1_out, monPro2_out, message, r2_mod_n, r_mod_n) begin
        load_shift_reg     <= '0';
        shift              <= '0';
        cipher_reg_en      <= '0';
        cipher_nxt         <= cipher_reg;
        P_reg_en           <= '0';
        P_nxt              <= P_reg;
        done_i             <= '0';
        loop_reg_en        <= '0';
        monPro1_start      <= '0';
        monPro1_A_next     <= (others => '0');
        monPro1_B_next     <= (others => '0');
        monPro2_start      <= '0';
        monPro2_A_next     <= (others => '0');
        monPro2_B_next     <= (others => '0');
        
        case(State) is
            
            when STATE_START =>
                load_shift_reg <= '1';
                monPro1_A_next <= message;
                monPro1_B_next <= r2_mod_n;
                monPro1_start  <= '1';
            
            when STATE_START_DONE =>
                cipher_reg_en <= '1';
                cipher_nxt <= r_mod_n;
                P_reg_en <= '1';
                P_nxt <= monPro1_out;
            
            when STATE_CP_MODN =>
                if(shift_reg_out(0)='1') then
                    monPro1_A_next <= cipher_reg;
                    monPro1_B_next <= P_reg;
                    monPro1_start <= '1';
                end if;
                monPro2_A_next <= P_reg;
                monPro2_B_next <= P_reg;
                monPro2_start <= '1';
            
            when STATE_CP_MODN_DONE =>
                if(shift_reg_out(0)='1') then
                    cipher_reg_en <= '1';
                    cipher_nxt <= monPro1_out;
                end if;
                P_reg_en <= '1';
                P_nxt <= monPro2_out;
                shift <= '1';
            
            when STATE_C1_MODN =>
                monPro1_A_next <= cipher_reg;
                monPro1_B_next(0) <= '1';
                monPro1_B_next(255 downto 1) <= (others => '0');
                monPro1_start <= '1';
            
            when STATE_C1_MODN_DONE =>
                cipher_reg_en <= '1';
                cipher_nxt <= monPro1_out;
            
            when STATE_DONE =>
                done_i <= '1';
            
            when others =>
        end case;
    end process;
    
------------------------------
-- Finite State Machine End --
------------------------------

-- Cipher Register
    process(clk, reset_n) begin
        if(reset_n='0') then
            cipher_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(cipher_reg_en='1') then
                cipher_reg <= cipher_nxt;
            end if;
        end if;
    end process;
    
-- Message_bar Register
        process(clk, reset_n) begin
            if(reset_n='0') then
                P_reg <= (others => '0');
            elsif(clk'event and clk='1') then
                if(P_reg_en='1') then
                    P_reg <= P_nxt;
                end if;
            end if;
        end process;

-- Loop Counter
    process(clk, reset_n) begin
        if(reset_n='0') then
            loop_counter <= (others => '0');
        elsif(clk'event and clk='1') then
            if(State=STATE_CP_MODN_DONE) then
                loop_counter <= loop_counter + 1;
            elsif(State=STATE_IDLE) then
                loop_counter <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;