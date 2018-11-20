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
    Port (
           -- INPUT VALUES
           A        : in STD_LOGIC_VECTOR (255 downto 0);
           B        : in STD_LOGIC_VECTOR (255 downto 0);
           modulo   : in STD_LOGIC_VECTOR (255 downto 0);

           -- CONTROL
           reset    : in STD_LOGIC;
           clk      : in STD_LOGIC;
           start    : in STD_LOGIC;

           -- OUTPUT VALUES
           done     : out STD_LOGIC;
           product  : out STD_LOGIC_VECTOR (255 downto 0));
end modular_product;

architecture Behavioral of modular_product is

    -- STATE DEFINITIONS
    type State_type is (STATE_START, STATE_ADD_AB, STATE_ADD_N, STATE_SHIFT, STATE_DONE, STATE_IDLE);  -- Define the states
    signal State : State_Type;    -- Create a signal that uses

    -- STATE: ADD_AB

    -- STATE: ADD_N
    signal u_odd : STD_LOGIC;

    -- A Shift Register
    signal load_reg       : STD_LOGIC;
    signal shift          : STD_LOGIC;
    signal data_shift_reg : STD_LOGIC_VECTOR (255 downto 0);
    
    -- Adder Signals
    signal adder_active : STD_LOGIC;
    signal adder_done : STD_LOGIC;
    signal adder_a_nxt : STD_LOGIC_VECTOR (255 downto 0);
    signal adder_b_nxt : STD_LOGIC_VECTOR (255 downto 0);
    signal adder_result : STD_LOGIC_VECTOR (256 downto 0);

    -- Product Register
    signal product_nxt : STD_LOGIC_VECTOR (256 downto 0);
    signal product_reg  : STD_LOGIC_VECTOR (256 downto 0);

    signal loop_counter : UNSIGNED (7 downto 0); -- count to 256

begin

    u_odd <= product_reg(0) xor (data_shift_reg(0) and B(0));
    product <= product_reg(255 downto 0);

-- Shift Register for A entity
    u_A_shift_reg: entity work.shift_reg
        port map (
         clk       => clk,
         rst       => reset,
         -- inputs
         d_in      => A(255 downto 0),
         load      => load_reg,
         shift     => shift,
         -- output
         d_out     => data_shift_reg(255 downto 0)
        );
         
-- Adder entity
    u_Adder: entity work.adder_256_64
        port map (
         a_in => adder_a_nxt,
         b_in => adder_b_nxt,
         clk => clk,
         reset => reset,
         active => adder_active,
         done => adder_done,
         result_out => adder_result
        );

-- Finite State Machine
    process(clk, reset, State, start, adder_done, loop_counter) begin
        if(reset='1') then
            State <= STATE_IDLE;
        elsif(clk'event and clk='1') then
            case( State ) is
                -- IDLE Description
                when STATE_IDLE =>
                    if(start='1') then
                        State <= STATE_START;
                    end if;
                -- START Description
                when STATE_START =>
                    State <= STATE_ADD_AB;
                -- ADD_AB Description
                when STATE_ADD_AB =>
                    if(data_shift_reg(0)='0' or adder_done='1') then
                        if(u_odd='1') then
                            State <= STATE_ADD_N;
                        else
                            State <= STATE_SHIFT;
                        end if;
                    end if;
                -- ADD_N Description
                when STATE_ADD_N =>
                    if(adder_done='1') then
                        State <= STATE_SHIFT;
                    end if;
                -- SHIFT Description
                when STATE_SHIFT =>
                    if(loop_counter=255) then
                        State <= STATE_DONE;
                    else
                        State <= STATE_ADD_AB;
                    end if;
                -- DONE Description
                when STATE_DONE =>
                    State <= STATE_IDLE;
                -- Other Description
                when others =>
                    State <= STATE_IDLE;
            end case;
        end if;
    end process;

-- Next Product
    process(State) begin
        case(State) is
          when STATE_IDLE =>
            product_nxt <= (others => '0'); 
          when STATE_START =>
            product_nxt <= product_reg;
          when STATE_ADD_AB =>
            if(data_shift_reg(0)='1') then
                product_nxt <= adder_result;
            else
                product_nxt <= product_reg;
            end if;
          when STATE_ADD_N =>
            product_nxt <= adder_result;
          when STATE_SHIFT =>
            product_nxt(255 downto 0) <= product_reg(256 downto 1);
            product_nxt(256) <= '0';
          when STATE_DONE => -- HHMMM
            product_nxt <= product_reg;
        end case;
    end process;
    
-- Active Adder
    process(State) begin
        case(State) is
          when STATE_IDLE =>
            adder_active <= '0';
          when STATE_START =>
            adder_active <= '0';
          when STATE_ADD_AB =>
            if(data_shift_reg(0)='1') then
                adder_active <= '1';
            else
                adder_active <= '0';
            end if;
          when STATE_ADD_N =>
            adder_active <= '1';
          when STATE_SHIFT =>
            adder_active <= '0';
          when STATE_DONE => -- HHMMM
            adder_active <= '0';
        end case;
    end process;
    
-- Shift reg shift
    process(State) begin
        case(State) is
          when STATE_SHIFT =>
            shift <= '1';
          when others =>
            shift <= '0';
        end case;
    end process;
    
-- Shift reg shift
    process(State) begin
        case(State) is
          when STATE_START =>
            load_reg <= '1';
          when others =>
            load_reg <= '0';
        end case;
    end process;
    
-- Next Adder A
    adder_a_nxt <= product_reg(255 downto 0);
    
-- Next Adder B
    process(State) begin
        case(State) is
            when STATE_ADD_AB =>
                adder_b_nxt <= B;
            when STATE_ADD_N =>
                adder_b_nxt <= modulo;
            when others =>
                adder_b_nxt <= (others => '0');
        end case;
    end process;

-- Product register
    process(clk, reset) begin
        if(reset='1') then
            product_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            product_reg <= product_nxt;
        end if;
    end process;
    
-- Done out
    process(State) begin
        case(State) is
            when STATE_DONE =>
                done <= '1';
            when others =>
                done <= '0';
        end case;
    end process;
    
-- Loop Counter
    process(clk, reset) begin
        if(reset='1') then
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
