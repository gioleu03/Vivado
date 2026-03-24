----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2024 14:05:56
-- Design Name: 
-- Module Name: sim - Behavioral
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

entity sim is
--  Port ( );
    
end sim;

architecture Behavioral of sim is

constant DIM_DATA_OUT : integer
    component ShiftRegisterSIPO is
    Port(
        reset: in std_logic;
        clk: in std_logic;
        data_in : in std_logic; --data_out range is (X DOWNTO 0) where X >0
        data_out : out std_logic_vector(3 DOWNTO 0) --la dimensione non posso sceglierla con il generic
 );
 end component;
 
 signal clk: std_logic := '0';
 signal data_in: std_logic := '0';
 signal clk: std_logic_vector (3 downto 0);
 
begin
    OUT: ShiftRegisterSIPO
        Port Map(
        clk => clk;
        data_in => data_in;
        data_out => data_out
        );
end Behavioral;
