----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.02.2025 15:32:12
-- Design Name: 
-- Module Name: Pipeline - Behavioral
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

entity Pipeline is
    Port (
        reset: in std_logic;
        clk: in std_logic;
        
        input_a : in std_logic_vector(31 DOWNTO 0);
        input_b : in std_logic_vector(31 DOWNTO 0);
        input_c : in std_logic_vector(31 DOWNTO 0);
        
        result: out std_logic_vector(31 DOWNTO 0)
         );
end Pipeline;

architecture Behavioral of Pipeline is
    component adder is 
    Port(
        a: in unsigned(31 DOWNTO 0);
        b: in unsigned(31 DOWNTO 0);
        
        result: out unsigned(31 DOWNTO 0)
        );
    end component;
    
    component multiplier is 
    Port(
        a: in unsigned(31 DOWNTO 0);
        b: in unsigned(31 DOWNTO 0);
        
        result: out unsigned(31 DOWNTO 0)
        );
    end component;
    
    signal m_out, a_out, a_in, input_a_int, input_b_int, input_c_int: unsigned(input_a'range);
begin
    multiplier_inst: multiplier
    Port Map(
        a => unsigned(input_a),
        b => unsigned(input_b),
        result => m_out
        );
    adder_inst: adder
    Port Map(
        a => unsigned(input_c),
        b => a_in,
        result => a_out
        );
        
        
    process(reset,clk)
        begin
            if rising_edge(clk) then
                a_in <= m_out;
                input_c_int <= unsigned(input_c);    
                result <= std_logic_vector(a_out);
            end if;
        end process;
end Behavioral;
