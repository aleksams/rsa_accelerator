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
    type State_type IS (ADD_AB, ADD_N, SHIFT, DONE, IDLE);  -- Define the states
    signal State : State_Type;    -- Create a signal that uses

    -- STATE: ADD_AB
    signal add_ab_start : STD_LOGIC;
    signal add_ab_done : STD_LOGIC;

    -- STATE: ADD_N
    signal u_odd : STD_LOGIC;
    signal add_n_start : STD_LOGIC;
    signal add_n_done : STD_LOGIC;

    -- A Shift Register
    signal load_reg       : STD_LOGIC;
    signal shift          : STD_LOGIC;
    signal data_shift_reg : STD_LOGIC_VECTOR (255 downto 0);

    -- Product Register
    signal product_nxt : STD_LOGIC_VECTOR (256 downto 0);
    signal product_reg  : STD_LOGIC_VECTOR (256 downto 0);

    signal loop_counter : UNSIGNED (7 downto 0); -- count to 256

begin

    u_odd <= product_reg(0) xor (data_shift_reg(0) and B(0));

-- Shift Register for A
    u_A_shift_reg: entity work.cla_adder
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

-- Finite State Machine
    process(clk, reset) begin
        if(reset='1') begin
            State <= IDLE;
        elsif(clk'event and clk='1') then
            case( State ) is
                -- IDLE Description
                when IDLE =>
                    if(start='1') then
                        State <= ADD_AB;
                    end if;
                -- ADD_AB Description
                when ADD_AB =>
                    if(add_ab_done='1') then
                        if(product_reg(0)='1') then
                            State <= ADD_N;
                        else
                            State <= SHIFT;
                        end if;
                    end if;
                -- ADD_N Description
                when ADD_N =>
                    if(add_n_done='1') then
                        State <= SHIFT;
                    end if;
                -- SHIFT Description
                when SHIFT =>
                    if(loop_counter=255) then
                        State <= DONE;
                    else
                        State <= ADD_AB;
                    end if;
                -- DONE Description
                when DONE =>
                    State <= IDLE;
                -- Other Description
                when others =>
                    State <= IDLE;
            end case;
        end if;
    end process;

    process(State) begin
        case(State) begin
          when IDLE =>
              load_reg
          when ADD_AB =>
              if(add_ab_done='1') then
                  State <= ADD_N;
              end if;
          when ADD_N =>
              if(add_n_done='1') then
                  State <= SHIFT;
              end if;
          when SHIFT =>
              if(loop_counter=255) then
                  State <= DONE;
              else
                  State <= ADD_AB;
              end if;
          when DONE =>
              State <= IDLE;
          when others =>
              State <= IDLE;
        end case;
    end process;

-- Product register
    process(clk, start) begin
        if(reset='1') then
            product_reg <= (others => '0');
        elsif(clk'event and clk='1') then
            product_reg <= product_nxt;
        end if;
    end process;

-- Next Product
    process() begin

    end process;

end Behavioral;
