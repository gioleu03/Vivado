----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.10.2024 14:42:12
-- Design Name: 
-- Module Name: lab2 - Behavioral
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

entity Adder_4bit is
  Port ( 
    a : in std_logic_vector(3 DOWNTO 0);
    b : in std_logic_vector(3 DOWNTO 0);
    
    sum : out std_logic_vector (3 DOWNTO 0) 
    );
end Adder_4bit;

architecture Behavioral of Adder_4bit is

     component half_adder is
      Port ( 
        ah: in std_logic; 
        bh: in std_logic;
        ch: out std_logic;
        sh: out std_logic
       );
    end component;
    
    component full_adder is
      Port ( 
        af: in std_logic; 
        bf: in std_logic;
        cfin: in std_logic;
        cfout: out std_logic;
        sf: out std_logic
       );
    end component;
    
    signal carry2, carry1, carry0 : std_logic; --carry3??
        
begin
        full_adder_inst4: full_adder
        Port map(
        af => a(3),
        bf => b(3),
        cfout => open, --oppure carry3
        cfin => carry2,
        sf => sum(3)
        );
        
        full_adder_inst3: full_adder
        Port map(
        af => a(2),
        bf => b(2),
        cfout => carry2,
        cfin => carry1,
        sf => sum(2)
        );
        
        full_adder_inst2 : full_adder
        Port map(
        af => a(1),
        bf => b(1),
        cfout => carry1,
        cfin => carry0,
        sf => sum(1)
        );
        
        half_adder_inst1 : half_adder
        Port map(
        ah => a(0),
        bh => b(0),
        ch => carry0,
        sh => sum(0)
        );

end Behavioral;

--prova