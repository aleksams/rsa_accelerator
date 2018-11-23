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
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    type State_type is (STATE_START, STATE_START_DONE, 
                        STATE_DONE, STATE_IDLE, WAIT_FOR_MSG,
                        WAIT_FOR_CIPHER, SEND_CIPHER);
                        
    signal State, State_nxt : State_Type;
    signal reset: STD_LOGIC;
    signal ModExp_start: STD_LOGIC;
    signal ModExp_done: STD_LOGIC;
    
    signal message_reg:  std_logic_vector(C_BLOCK_SIZE-1 downto 0); 
    signal send_msgin_ready: STD_LOGIC;
    
    signal test_reg: std_logic_vector(C_BLOCK_SIZE-1 downto 0); 
    
begin
    
    process(clk, reset_n) begin
        if(reset_n='0') then
            message_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(msgin_valid='1' and send_msgin_ready='1') then
                message_reg <= msgin_data;
            end if;
        end if;
    end process;

    process(clk, reset_n) begin
        if(reset_n='0') then
            State <= STATE_IDLE;
            message_reg <= (others => '0');
            send_msgin_ready <= '0';
            ModExp_start <= '0';
            
        elsif(clk'event and clk='1') then
            case (State) is
                when STATE_IDLE =>
                    msgout_last <= '0';
                    msgout_valid <= '0';
                    send_msgin_ready <= '1';
                    
                    if(msgin_valid = '1') then
                        State <= WAIT_FOR_MSG;
                        message_reg <= msgin_data;
                    end if;
                    
                when WAIT_FOR_MSG =>
                
                    if(msgin_valid = '0') then
                        send_msgin_ready <= '0';
                        State <= WAIT_FOR_CIPHER;
                        ModExp_start <= '1';
                    end if;
                    
                when WAIT_FOR_CIPHER =>
                    
                    ModExp_start <= '0';
                    if(ModExp_done = '1') then
                        State <= SEND_CIPHER;
                        msgout_valid <= ModExp_done;
                    end if;
                
                when SEND_CIPHER =>
                    if(msgout_ready = '1') then
                        State <= STATE_IDLE;
                        msgout_last <= '1';
                    end if;

                    
                when others =>
                    msgout_valid <= '0';
                    
            end case;        
        end if;
    end process;    

    reset <= not reset_n;
 
  
   u_ModExp : entity work.modular_exponentiation port map(
  -- Clocks and resets
  clk             => clk,
  reset_n           => reset_n,
  -- Control Signals
  start           => ModExp_start,

  --data_accepted   => monPro1_data_accepted,
  -- Inputs
  message         => msgin_data,
  key             => key_e_d,
  modulo          => key_n,
  r_mod_n         => r_mod_n,
  r2_mod_n        => r2_mod_n,
 
  -- Outputs
  cipher          => msgout_data,
  done            => ModExp_done
);

msgin_ready <= send_msgin_ready;


end rtl;
