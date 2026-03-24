----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.11.2024 08:38:57
-- Design Name: 
-- Module Name: ShiftRegisterSIPO - Behavioral
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

entity ShiftRegisterSIPO is
    Port(
        reset: in std_logic;
        clk: in std_logic;
        data_in : in std_logic; --data_out range is (X DOWNTO 0) where X >0
        data_out : out std_logic_vector(3 DOWNTO 0) --la dimensione non posso sceglierla con il generic
 );
 end ShiftRegisterSIPO;

architecture Behavioral of ShiftRegisterSIPO is

    signal tmp_out: std_logic_vector(data_out'RANGE);
    
begin

  process(clk, reset, tmp_out) 
    begin
    if reset = '1' then
        if rising_edge(clk) then 
          tmp_out(0) <= data_in;
          for i in 1 to data_out'length-1 loop
                    tmp_out(i) <= tmp_out(i-1);
          end loop;
        end if;
      end if; 
   
   end process;
        
 data_out <= tmp_out;
  
  end Behavioral;        