----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2024 11:39:36
-- Design Name: 
-- Module Name: RegFabio - Behavioral
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



entity RegFabio is
  Port ( 
  clk : in std_logic;
  reset: in std_logic;
  
  D: in signed;
  Q: out signed
  );
end RegFabio;

architecture Behavioral of RegFabio is
    component ff_d is
        Port(
            reset	: in std_logic;
            clk		: in std_logic;
    
            d 	:	in std_logic;
            q 	: out std_logic
        );
end component;

begin

   REG_GEN: for i in D'RANGE generate
    ff_d_inst: ff_d 
        Port Map(
            reset	=>reset,
            clk		=>clk,
    
            d 	=> D(i),
            q 	=> Q(i)
        );
end generate;


end Behavioral;
