----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.02.2025 15:35:48
-- Design Name: 
-- Module Name: adder - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder is
    Port(
        a: in unsigned(31 DOWNTO 0);
        b: in unsigned(31 DOWNTO 0);
        
        result: out unsigned(31 DOWNTO 0)
        );
end adder;

architecture Behavioral of adder is
    signal tmp: unsigned(31 DOWNTO 0);
begin
    tmp <= a+b;
    result <= (others => 'U') after 2 ns,
              tmp after 7 ns;
end Behavioral;
