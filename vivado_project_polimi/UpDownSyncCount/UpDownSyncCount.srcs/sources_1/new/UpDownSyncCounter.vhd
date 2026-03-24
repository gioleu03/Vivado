----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2024 11:37:10
-- Design Name: 
-- Module Name: UpDownSyncCounter - Behavioral
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


entity UpDownSyncCounter is
		Generic(
			COUNT_WIDTH	: integer := 4
		);
		Port (
			reset		: in std_logic;
			clk			: in std_logic;

			inc_count	: in std_logic;
			dec_count	: in std_logic;

			count		: out std_logic_vector(COUNT_WIDTH-1 DOWNTO 0) -- Signed
			);
end UpDownSyncCounter;

architecture Behavioral of UpDownSyncCounter is
    component RegFabio is
          Port ( 
          clk : in std_logic;
          reset: in std_logic;
          
          D: in signed;
          Q: out signed
          );
        end component;
        
    signal count_int, out_mux: signed(count'RANGE);
    signal supp_inc_dec: std_logic_vector (1 DOWNTO 0);
begin
    Reg_Fabio_inst : RegFabio 
          Port Map( 
              clk   => clk,
              reset => reset, 
              D     => out_mux,
              Q     => count_int
              );
          
    count <= std_logic_vector(count_int); -- perchè count int va riletto e i segnali di out non possono essere riletti
    supp_inc_dec <= inc_count & dec_count;
    
    with supp_inc_dec select out_mux <= count_int when "00",
                                        count_int when "11",
                                        count_int+1 when "10",
                                        count_int-1 when "01",
                                        (Others =>'X') when others;
    
end Behavioral;
