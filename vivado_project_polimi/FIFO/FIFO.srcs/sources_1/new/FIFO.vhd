----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.12.2024 10:54:36
-- Design Name: 
-- Module Name: FIFO - Behavioral
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


entity FIFO is
     Generic(
         FIFO_WIDTH : integer := 8;
         FIFO_DEPTH : integer := 16
     );
     Port(
         reset: in std_logic;
         clk: in std_logic;
         
         din : in std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
         dout: out std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
         
         rd_en: in std_logic;
         wr_en: in std_logic;
         
         full: out std_logic;
         empty: out std_logic
     );
end FIFO;

architecture Behavioral of FIFO is
signal count: integer range 0 to FIFO_DEPTH := 0; 
signal read_pointer, write_pointer: integer range 0 to FIFO_DEPTH-1 :=0;

type memory_type is array (0 to FIFO_DEPTH-1) of std_logic_vector(din'range);

signal memory :memory_type;
signal full_int, empty_int: std_logic;

begin

full_int <= '1' when count = FIFO_DEPTH else '0';
empty_int <= '1' when count = 0;

empty <= empty_int;
full <= full_int;

     process(clk, reset)
        begin
        if (reset = '1') then
            count <= 0;
            write_pointer <= 0;
            read_pointer <= 0;
            elsif rising_edge(clk) then
            if(wr_en = '1' and rd_en = '0') then
                if(full_int ='0') then
                    count <= count + 1; 
                end if;   
            elsif(wr_en ='0' and rd_en = '1') then
                if(empty_int = '0') then
                    count <= count-1;
                end if;
            elsif(wr_en = '1' and rd_en = '1') then
                if(full_int = '0') then
                    count <= count + 1;
                end if;
                if(empty_int = '0') then
                    count <= count-1;               
                 end if;
            end if;
            
            if(wr_en = '1' and full_int = '0')then
                if (write_pointer = FIFO_DEPTH-1) then
                    write_pointer <= 0;
                else 
                    write_pointer <= write_pointer+1; 
                end if;
             end if;
             
             if(rd_en = '1' and empty_int = '0')then
                if (read_pointer = FIFO_DEPTH-1) then
                    read_pointer <= 0;
                else 
                    write_pointer <= write_pointer+1; 
                end if;
             end if;
              
             if(wr_en = '1' and full_int = '0') then
                memory(write_pointer) <= din;
             end if;
             
             if(rd_en = '1' and empty_int ='0') then
                dout <= memory(read_pointer);
             end if;
        end if;
     end process;   

end Behavioral;
