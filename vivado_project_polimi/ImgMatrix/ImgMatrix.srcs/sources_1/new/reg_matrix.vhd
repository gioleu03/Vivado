----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2024 09:41:26
-- Design Name: 
-- Module Name: reg_matrix - Behavioral
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

entity reg_matrix is  
    Port ( 
    clk : in std_logic;
    reset : in std_logic;
    D: in std_logic_vector;
    Q: out std_logic_vector 
    );
end reg_matrix;

architecture Behavioral of reg_matrix is
    component ff_d is 
        Port(
            reset	: in std_logic;
            clk		: in std_logic;
    
            d 	:	in std_logic;
            q 	: out std_logic
        );
    end component;
begin
    LOOP_GEN: for i in D'RANGE generate
        ff_d_inst: ff_d
            Port Map(
            reset => reset,
            clk =>clk,
            d => D(i),
            q => Q(i)
            );
     end generate;
end Behavioral;
