----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2024 21:43:34
-- Design Name: 
-- Module Name: shiftregister - Behavioral
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

entity  ShiftRegisterSIPO is
    Generic(
        SR_WIDTH :integer:=4
        );
    Port (
        rst :in std_logic;
        clock :in std_logic;
        
        data_in :in std_logic;
        
        data_out :out std_logic_vector (SR_WIDTH-1 DOWNTO 0) 
        );
end ShiftRegisterSIPO;

architecture Behavioral of ShiftRegisterSIPO is
    component ff_d is
        Port(
        reset	: in std_logic;
		clk		: in std_logic;

		d 	:	in std_logic;
		q 	: out std_logic
         );
    end component;
    
    signal temp_out: std_logic_vector (SR_WIDTH-1 DOWNTO 0);
        
begin
    
    LOOP_GEN : for I in 0 TO SR_WIDTH-1 generate
        ff_d_inst: ff_d
        Port map(
        d => data_in,
        clk => clock,
        reset => rst,
        q => temp_out(I)
        );
    end generate;
    
    data_out <= temp_out;
    
end Behavioral;
