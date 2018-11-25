--------------------------------------------------------------------------------
-- Author       : Aleksander Skarnes, Eivind Erichsen and Halvor Horvei
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018
-- Project      : RSA accelerator
-- Module       : Modular Product
-- License      : This is free and unencumbered software released into the 
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose: 
--   Calculate the Montgomery modular product
--   U = (AB r^-1) mod modulo.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.ALL;


entity modular_product is
    Generic (
           DATA_WIDTH : integer := 256;
           R_SIZE     : integer := 256);
    Port (
           -- INPUT VALUES
           A        : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           B        : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           modulo   : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           -- CONTROL
           reset_n       : in STD_LOGIC;
           clk           : in STD_LOGIC;
           start         : in STD_LOGIC;
           done          : out STD_LOGIC;
           -- OUTPUT VALUES
           product  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end modular_product;

architecture Behavioral of modular_product is

    -- State Definitions
    type State_type is (STATE_START, STATE_ADD_AB, 
                        STATE_ADD_N, STATE_SHIFT , 
                        STATE_SUB_N, STATE_DONE  , 
                        STATE_IDLE               );
    
    -- State Signals
    signal State, State_nxt : State_Type;
    
    -- Internal Signal
    signal done_i : STD_LOGIC;

    -- Shift Register for A
    signal load_shift_reg : STD_LOGIC;
    signal shift          : STD_LOGIC; 
    signal shift_reg_out  : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);

    -- Product Register
    signal product_nxt    : STD_LOGIC_VECTOR (DATA_WIDTH+1 downto 0);
    signal product_reg    : STD_LOGIC_VECTOR (DATA_WIDTH+1 downto 0); 
    signal product_reg_en : STD_LOGIC;

    -- Loop control
    signal loop_counter : UNSIGNED (7 downto 0);
    signal loop_reg_en  : STD_LOGIC;
    
begin

-- Assignments
    product <= product_reg(DATA_WIDTH-1 downto 0);
    done <= done_i;

-- Shift Register Entity for A
    u_A_shift_reg: entity work.shift_reg
        generic  map(
          DATA_WIDTH => DATA_WIDTH
        )
        port map (
        -- Clock and Reset
         clk       => clk,
         rst_n     => reset_n,
         -- Inputs
         d_in      => A (DATA_WIDTH-1 downto 0),
         load      => load_shift_reg,
         shift     => shift,
         -- Output
         d_out     => shift_reg_out (DATA_WIDTH-1 downto 0)
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
    process(State, start, loop_counter) begin
        State_nxt <= State;
        case( State ) is
            when STATE_IDLE =>
                if(start='1') then
                    State_nxt <= STATE_START;
                else
                    State_nxt <= STATE_IDLE;
                end if;

            when STATE_START =>
                State_nxt <= STATE_ADD_AB;

            when STATE_ADD_AB =>
                State_nxt <= STATE_ADD_N;

            when STATE_ADD_N =>
                State_nxt <= STATE_SHIFT;

            when STATE_SHIFT =>
                if(loop_counter=(R_SIZE-1)) then
                    State_nxt <= STATE_SUB_N;
                else
                    State_nxt <= STATE_ADD_AB;
                end if;

            when STATE_SUB_N =>
                State_nxt <= STATE_DONE;

            when STATE_DONE =>
                State_nxt <= STATE_IDLE;

            when others =>
                State_nxt <= STATE_IDLE;
        end case;
    end process;

-- System controll
    process(State, loop_counter, shift_reg_out, product_reg, B, modulo) begin
        load_shift_reg <= '0';
        shift          <= '0';
        product_reg_en <= '0';
        product_nxt    <= product_reg;
        done_i         <= '0';
        loop_reg_en    <= '0';
        case(State) is
            when STATE_START =>
                load_shift_reg <= '1';
                product_reg_en <= '1';
                product_nxt <= (others => '0');
            when STATE_ADD_AB =>
                product_reg_en <= '1';
                if(shift_reg_out(0)='1') then
                    product_nxt <= STD_LOGIC_VECTOR(UNSIGNED(product_reg) + UNSIGNED("00" & B));
                end if;
            when STATE_ADD_N =>
                product_reg_en <= '1';
                if(product_reg(0)='1') then
                    product_nxt <= STD_LOGIC_VECTOR(UNSIGNED(product_reg) + UNSIGNED("00" & modulo));
                end if;
            when STATE_SHIFT =>
                shift <= '1';
                loop_reg_en <= '1';
                product_reg_en <= '1';
                product_nxt <= "0" & product_reg(DATA_WIDTH+1 downto 1);
            when STATE_SUB_N =>
                product_reg_en <= '1';
                if(UNSIGNED(product_reg) >= UNSIGNED(modulo)) then
                    product_nxt <= STD_LOGIC_VECTOR(UNSIGNED(product_reg) - UNSIGNED("00" & modulo));
                end if;
            when STATE_DONE =>
                done_i <= '1';
            when others =>
        end case;
    end process;
    
------------------------------
-- Finite State Machine End --
------------------------------

-- Product register
    process(clk, reset_n) begin
        if(reset_n='0') then
            product_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            if(product_reg_en='1') then
                product_reg <= product_nxt;
            end if;
        end if;
    end process;
    
-- Loop Counter
    process(clk, reset_n) begin
        if(reset_n='0') then
            loop_counter <= (others => '0');
        elsif(clk'event and clk='1') then
            if(State=STATE_SHIFT) then
                loop_counter <= loop_counter + 1;
            elsif(State=STATE_IDLE) then
                loop_counter <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
