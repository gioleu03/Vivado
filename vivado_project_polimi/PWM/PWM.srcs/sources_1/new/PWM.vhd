----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2024 14:55:24
-- Design Name: 
-- Module Name: PWM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM is
    Port (
        reset : in std_logic;
        clk : in std_logic;
        t_on : in std_logic_vector(8-1 DOWNTO 0); -- UNSIGNED
        t_total: in std_logic_vector(8-1 DOWNTO 0); -- UNSIGNED
        pwm_out: out std_logic
    );
end PWM;

architecture Behavioral of PWM is
    signal count: unsigned(t_on'range) := (others=>'0');
    signal t_on_reg : unsigned(t_on'range); -- mi serve per modificare il valore di t_on
    signal t_total_reg : unsigned(t_on'range); 
begin
    rise_process: process(clk, reset)
    begin
        if reset='1' then
            count <= (others => '0');
            t_on_reg <= unsigned(t_on);
            t_total_reg <= unsigned(t_total);
            pwm_out <= '1';
            
                elsif rising_edge(clk) then
                    count <= count+1;
                    if (count = unsigned(t_total_reg))then
                        pwm_out <= '1';
                        count <= (others => '0');
                        t_on_reg <= unsigned(t_on); --serve a garantire che il valore rimanga stabile per tutto il cilo di clk
                        t_total_reg <= unsigned(t_total); --devo registrarli di nuovo perchè e finito il ciclo

                    else if(count = unsigned(t_on_reg))then
                        pwm_out <= '0';
                    end if;
               end if;
        end if;
    end process;

end Behavioral;

       