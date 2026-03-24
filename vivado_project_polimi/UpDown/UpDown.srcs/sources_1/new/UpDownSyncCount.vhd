----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2024 13:57:11
-- Design Name: 
-- Module Name: UpDown - Behavioral
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

entity UpDownSyncCount is
     Generic(
        COUNT_WIDTH : integer := 4
       );
    Port (
        reset: in std_logic;
        clk: in std_logic;
        inc_count : in std_logic;
        dec_count : in std_logic;
        count : out std_logic_vector(COUNT_WIDTH-1 DOWNTO 0)-- Signed
        );
 end UpDownSyncCount;

architecture Behavioral of UpDownSyncCount is
    component ff_d
    Port(
		reset	: in std_logic;
		clk		: in std_logic;

		d 	:	in std_logic;
		q 	: out std_logic
	);
    end component;
    
    signal count_reg : std_logic_vector (COUNT_WIDTH-1 DOWNTO 0):= (others => '0');
    signal next_count : std_logic_vector (COUNT_WIDTH-1 DOWNTO 0):= (others => '0');
    
begin

    next_count <= std_logic_vector(unsigned(count_reg) + 1) when (inc_count = '1' and dec_count = '0') else
                  std_logic_vector(unsigned(count_reg) - 1) when (inc_count = '0' and dec_count = '1') else
                  count_reg;
                  
    LOOP_COUNT: for I in COUNT_WIDTH-1 DOWNTO 0 generate
         ff_d_inst: ff_d
            Port Map(
            reset => reset,
            clk => clk,
            d => next_count(I),
            q => count_reg(I)
            );
     end generate;       
    
    count <= std_logic_vector (count_reg);

end Behavioral;

