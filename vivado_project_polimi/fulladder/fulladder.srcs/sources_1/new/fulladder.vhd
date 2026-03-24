----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2024 14:00:41
-- Design Name: 
-- Module Name: fulladder - Behavioral
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

entity full_adder is
  Port ( 
    af : in std_logic;
    bf : in std_logic;
    cfin : in std_logic; --carryingresso
    
    sf: out std_logic;
    cfout: out std_logic --carryuscita
    );
end full_adder;

architecture Behavioral of full_adder is
    
    component half_adder is
      Port ( 
        ah: in std_logic; 
        bh: in std_logic;
        ch: out std_logic;
        sh: out std_logic
       );
    end component;
        
        signal sum1, carry1, carry2 : std_logic;
begin
    
    half_adder_inst1 : half_adder
        Port map(
           ah => af,
           bh => bf,
           ch => carry1,
           sh => sum1
           );
      half_adder_inst2: half_adder
        Port map(
           ah => cfin,
           bh => sum1,
           sh => sf,
           ch => carry2
           );
           
      cfout <= carry1 or carry2;
           
end Behavioral;
