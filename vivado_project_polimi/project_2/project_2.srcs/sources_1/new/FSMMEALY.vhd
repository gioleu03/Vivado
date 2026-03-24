----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.02.2025 17:06:30
-- Design Name: 
-- Module Name: FSMMEALY - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSMMEALY is
   Port (
    clk: in std_logic;
    reset: in std_logic;
    signal_in : in std_logic;
    upEdge: out std_logic;
    downEdge: out std_logic
    );
end FSMMEALY;

architecture Behavioral of FSMMEALY is
    type statetype is (IDLE, WAITING_UP, WAITING_DOWN);
    
    signal state, nextstate : statetype := IDLE;
         
begin
    
    logicasincrona: process(reset, clk)
    begin
        if (reset = '1') then
            state <= IDLE;
        elsif rising_edge (clk) then
            state <= nextstate;
        end if;
   end process;
   
   logicanextstate: process(state, signal_in)
   begin
        case(state) is when IDLE => nextstate <= WAITING_UP;
                       when WAITING_UP => if(signal_in = '1') then
                                                nextstate <= WAITING_DOWN;
                                           else 
                                                nextstate <= WAITING_UP;
                                           end if; 
                       when WAITING_DOWN => if(signal_in = '0') then
                                                nextstate <= WAITING_UP;
                                           else 
                                                nextstate <= WAITING_DOWN;
                                           end if;  
       end case;                                    
   end process;
    
    logicadiuscita: process(state, signal_in)
        begin
            case(state) is when IDLE => upEdge <= '0';
                                        downEdge <= '0';
                           when WAITING_UP => if (signal_in = '1') then
                                              upEdge <= '0';
                                              downEdge <= '1'; 
                                              else
                                              upEdge <= '0';
                                              downEdge <= '0'; 
                                              end if;         
                           when WAITING_DOWN => if (signal_in = '0') then
                                              upEdge <= '1';
                                              downEdge <= '0';
                                              else
                                              upEdge <= '0';
                                              downEdge <= '0';  
                                              end if;
                           when others  => upEdge <= '0';
                                           downEdge <= '0';
                             
             end case;                                              
    end process;

end Behavioral;
