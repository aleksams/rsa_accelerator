----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 15.10.2018 10:20:03
-- Design Name:
-- Module Name: modular_product - Behavioral
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
use WORK.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modular_product is
    Generic (
           DATA_WIDTH : integer := 256);
    Port (
           -- INPUT VALUES
           A        : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           B        : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           modulo   : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);

           -- CONTROL
           reset_n       : in STD_LOGIC;
           clk           : in STD_LOGIC;
           start         : in STD_LOGIC;
           --data_accepted : in STD_LOGIC;
           done          : out STD_LOGIC;

           -- OUTPUT VALUES
           product  : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end modular_product;

architecture Behavioral of modular_product is

    -- STATE DEFINITIONS
    type State_type is (STATE_START, STATE_ADD_AB, STATE_ADD_N, STATE_SHIFT, STATE_SUB_N, STATE_DONE, STATE_IDLE);
    
    -- STATE SIGNALS
    signal State, State_nxt : State_Type;

    -- Look ahed logic
    signal u_odd : STD_LOGIC;
    
    -- Internal
    signal done_i : STD_LOGIC;

    -- Shift Register for A
    signal load_shift_reg : STD_LOGIC;
    signal shift          : STD_LOGIC;
    signal shift_reg_out  : STD_LOGIC_VECTOR (255 downto 0);

    -- Product Register
    signal product_nxt    : STD_LOGIC_VECTOR (257 downto 0);
    signal product_reg    : STD_LOGIC_VECTOR (257 downto 0);
    signal product_reg_en : STD_LOGIC;

    -- Loop control
    signal loop_counter : UNSIGNED (9 downto 0); -- count to 256
    signal loop_reg_en  : STD_LOGIC;

begin

    --u_odd <= product_reg(0) xor (data_shift_reg(0) and B(0));
-- Assignments
    --process(product_reg, done_i) begin
    --    for i in 0 to 255 loop
    --        product(i) <= done_i and product_reg(i);
    --    end loop;
    --end process;
    product <= product_reg(255 downto 0);
    done <= done_i;

-- Shift Register Entity for A
    u_A_shift_reg: entity work.shift_reg
        port map (
         clk       => clk,
         rst_n       => reset_n,
         -- inputs
         d_in      => A(255 downto 0),
         load      => load_shift_reg,
         shift     => shift,
         -- output
         d_out     => shift_reg_out (255 downto 0)
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
    process(State, start) begin
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
                State_nxt <= STATE_ADD_AB;
            -- ADD_AB Description
            when STATE_ADD_AB =>
                State_nxt <= STATE_ADD_N;
            -- ADD_N Description
            when STATE_ADD_N =>
                State_nxt <= STATE_SHIFT;
            -- SHIFT Description
            when STATE_SHIFT =>
                if(loop_counter=255) then
                    State_nxt <= STATE_SUB_N;
                else
                    State_nxt <= STATE_ADD_AB;
                end if;
            -- SUB_N Description
            when STATE_SUB_N =>
                State_nxt <= STATE_DONE;
            -- DONE Description
            when STATE_DONE =>
                --if(data_accepted='1') then
                    State_nxt <= STATE_IDLE;
                --end if;
            -- Other Description
            when others =>
                State_nxt <= STATE_IDLE;
        end case;
    end process;

-- System controll
    process(State, loop_counter, shift_reg_out, product_reg) begin
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
                product_nxt <= "0" & product_reg(257 downto 1);
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
