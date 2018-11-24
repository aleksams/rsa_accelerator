--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   Calculate
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
entity rsa_core is
  generic (
	-- Users to add parameters here
  C_BLOCK_SIZE          : integer := 256
  );
  port (
    -----------------------------------------------------------------------------
    -- Clocks and reset
    -----------------------------------------------------------------------------      
    clk                    :  in std_logic;
    reset_n                :  in std_logic;
      
    -----------------------------------------------------------------------------
    -- Slave msgin interface
    -----------------------------------------------------------------------------
    -- Message that will be sent in is valid
    msgin_valid            : in std_logic;   
    -- Slave ready to accept a new message
    msgin_ready            : out std_logic;
    -- Message that will be sent in to the rsa_msgin module
    msgin_data             :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    -- Indicates boundary of last packet
    msgin_last             :  in std_logic;
    
    -----------------------------------------------------------------------------
    -- Master msgout interface
    -----------------------------------------------------------------------------
    -- Message that will be sent out is valid
    msgout_valid            : out std_logic;   
    -- Slave ready to accept a new message
    msgout_ready            :  in std_logic;
    -- Message that will be sent out of the rsa_msgin module
    msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    -- Indicates boundary of last packet
    msgout_last             : out std_logic;

    -----------------------------------------------------------------------------
    -- Interface to the register block
    -----------------------------------------------------------------------------    
    key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    r_mod_n                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    r2_mod_n                :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    rsa_status              :  out std_logic_vector(31 downto 0)
    
  );
end rsa_core;


architecture rtl of rsa_core is
    type State_type is ( GET_MSG, CALCULATE_CIPHER, SEND_CIPHER );
                        
    signal State, State_nxt : State_Type;
    signal ModExp_start: STD_LOGIC;
    signal ModExp_done: STD_LOGIC;
    
    signal message_reg:  std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal message_nxt:  std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal message_reg_en: std_logic;
    
    signal last_message_reg : std_logic;
    signal last_message_nxt : std_logic;
    signal last_message_reg_en : std_logic;
    
    signal ModExp_data_out : std_logic_vector(C_BLOCK_SIZE-1 downto 0);
    signal msgout_valid_i  : std_logic;
    
begin

  u_ModExp : entity modular_exponentiation 
    generic  map(
      DATA_WIDTH => C_BLOCK_SIZE
    )
    port map(
    -- Clocks and resets
    clk             => clk,
    reset_n         => reset_n,
    
    -- Control Signals
    start           => ModExp_start,
    done            => ModExp_done,
    
    -- Inputs
    message         => message_reg,
    key             => key_e_d,
    modulo          => key_n,
    r_mod_n         => r_mod_n,
    r2_mod_n        => r2_mod_n,
    
    -- Outputs
    cipher          => ModExp_data_out
    );

-- Assignments
    msgout_valid <= msgout_valid_i;
    
    process(clk, reset_n) begin
        if(reset_n='0') then
            last_message_reg <= '0';
        elsif(clk'event and clk='1') then
            if(last_message_reg_en='1') then
                last_message_reg <= last_message_nxt;
            end if;
        end if;
    end process;
    
    process(clk, reset_n) begin
        if(reset_n='0') then
            message_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(message_reg_en='1') then
                message_reg <= message_nxt;
            end if;
        end if;
    end process;
    
-- State Register
    process(clk, reset_n) begin
        if(reset_n='0') then
            State <= GET_MSG;
        elsif(clk'event and clk='1') then
            State <= State_nxt;
        end if;
    end process;
    
    process(State, msgin_valid, ModExp_done, msgout_ready) begin
        State_nxt <= State;
        case(State) is 
            when GET_MSG =>
                if(msgin_valid='1') then
                    State_nxt <= CALCULATE_CIPHER;
                end if;
            when CALCULATE_CIPHER =>
                if(ModExp_done='1') then
                    State_nxt <= SEND_CIPHER;
                end if;
            when SEND_CIPHER =>
                if(msgout_ready='1') then
                    State_nxt <= GET_MSG;
                end if;
            when others =>
                 State_nxt <= GET_MSG;
        end case;
    end process;
    
    process(State, msgin_data, msgin_last, msgin_valid, last_message_reg) begin
        msgin_ready <= '0';
        msgout_valid_i <= '0';
        msgout_last <= '0';
        msgout_data <= (others => '0');
        
        ModExp_start <= '0';
        message_nxt <= (others => '0');
        message_reg_en <= '0';
        
        last_message_nxt <= '0';
        last_message_reg_en <= '0';
        
        case(State) is 
            when GET_MSG =>
                msgin_ready <= '1';
                message_nxt <= msgin_data;
                last_message_nxt <= msgin_last;
                if(msgin_valid='1') then
                    message_reg_en <= '1';
                    last_message_reg_en <= '1';
                end if;
            when CALCULATE_CIPHER =>
                ModExp_start <= '1';
            when SEND_CIPHER =>
                msgout_valid_i <= '1';
                msgout_last <= last_message_reg;
                msgout_data <= ModExp_data_out;
            when others =>
        end case;
    end process;

end rtl;