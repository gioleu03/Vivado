----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2026 16:26:16
-- Design Name: 
-- Module Name: fcs - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity fcs is
	port ( 
		clk            : in std_logic; -- system clock
		reset          : in std_logic; -- asynchronous reset
		start_of_frame : in std_logic; -- arrival of the first bit.
		end_of_frame   : in std_logic; -- arrival of the first bit in FCS.
		data_in 	   : in std_logic; -- serial input data.
		fcs_error      : out std_logic -- indicates an error.
	);
end fcs;


architecture Behavioral of fcs is  

    signal generator: std_logic_vector(0 to 31) := "11011011011100001000001100100000"; 
    --signal generator: std_logic_vector(31 downto 0) := "00000100110000010000111011011011";
    signal flag, flag2, current_bit: std_logic;
    signal R: std_logic_vector(0 to 31);
    signal bit_count, last_bits: integer range 0 to 1024;
    
begin
	

  	process(clk, reset)

    variable current_bit, feedback: std_logic;
    variable bit_count: integer range 0 to 64;
    variable R_next: std_logic_vector(0 to 31) := (others => '0') ;
  	begin
        if reset = '1' then
            R <= (others => '0');
            fcs_error <= '0';
            flag <= '0';
            flag2 <= '0';
            bit_count := 0; 
            last_bits <= 0; 
        elsif rising_edge(clk) then
            if start_of_frame = '1' then
                flag <= '1';
                current_bit := not data_in;
            end if;
            elsif flag = '1' then 
                if bit_count < 32 then
                    current_bit := not data_in;
                else
                    current_bit := data_in;
                end if;
                bit_count := bit_count + 1;
                
                R_next(0) := current_bit xor R(31);
                for i in 1 to 31 loop
                    if generator(i) = '1' then
                        R_next(i) := R_next(i+1) xor R(31);
                        else 
                        R_next(i) := R_next(i+1);
                    end if;
                end loop;
                R <= R_next;
            end if;

            if end_of_frame = '1' then
                bit_count := 0; 
                flag2 <= '1';              
            end if;
            
            if bit_count >= 32 and flag2 = '1' then
                flag <= '0';
                    if (R = x"00000000") then
                        fcs_error <= '0';
                    else
                        fcs_error <= '1';
                    end if;
                end if;
        R <= R_next;  
    end process;  
              
  end Behavioral;
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

--entity fcs is
--    port ( 
--        clk            : in std_logic;
--        reset          : in std_logic;
--        start_of_frame : in std_logic;
--        end_of_frame   : in std_logic;
--        data_in        : in std_logic;
--        fcs_error      : out std_logic
--    );
--end fcs;

--architecture Behavioral of fcs is  
--    -- Il polinomio G(x) del PDF mappato sui coefficienti g0..g31 [cite: 29, 49]
--    constant generator : std_logic_vector(31 downto 0) := "00000100110000010001110110110111"; 
--    signal R : std_logic_vector(31 downto 0) := (others => '0');
--    signal active : std_logic := '0';
--begin

--    process(clk, reset)
--        variable current_bit : std_logic;
--        variable R_next    : std_logic_vector(31 downto 0) := (others => '0');
--        variable bit_count : integer range 0 to 2048;
--    begin
--        if reset = '1' then
--            R <= (others => '0'); -- Inizializzazione a 1 per il punto a) 
--            fcs_error <= '0';
--            bit_count := 0;
--        elsif rising_edge(clk) then
            
--            -- Se arriva start_of_frame, resettiamo a '1' e iniziamo a processare
--            if start_of_frame = '1' then
--                if bit_count < 32 then
--                    current_bit := not data_in;
--                else
--                    current_bit := data_in;
--                end if;
--                bit_count := bit_count + 1;
                
--                R_next := R(30 downto 0) & current_bit;
                
--                for i in 0 to 31 loop
--                    if generator(i) = '1' then
--                        R_next(i) := R_next(i) xor R(31);      
--                    end if;
--                end loop;
                
--                R <= R_next;
                
--            elsif end_of_frame = '1' then
--                bit_count := 1;
--                current_bit := not data_in;
                
--                R_next := R(30 downto 0) & current_bit;
                
--                for i in 0 to 31 loop
--                    if generator(i) = '1' then
--                        R_next(i) := R_next(i) xor R(31);      
--                    end if;
--                end loop;
--                bit_count := bit_count + 1;
--                R <= R_next;
                
--            elsif (end_of_frame = '0') and (start_of_frame = '1') and bit_count = 32 then
--                if (R = x"00000000") then
--                    fcs_error <= '0';
--                else
--                    fcs_error <= '1';
--                end if;
--            end if;
--         end if;
--    end process;
--end Behavioral;

--architecture Behavioral of fcs is  

--    signal generator: std_logic_vector(0 to 31) := "11011011011100001000001100100000"; 
--    --signal generator: std_logic_vector(31 downto 0) := "00000100110000010000111011011011";
--   -- signal R_fin: std_logic_vector(0 to 31);
--    signal flag, flag2, current_bit: std_logic;
--    signal R_next, R: std_logic_vector(0 to 31);
--    signal bit_count, last_bits: integer range 0 to 1024;
    
--begin
	

--  	process(clk, reset)

--    --variable current_bit, feedback: std_logic;
--    --variable last_bits: integer range 0 to 64;
--   -- variable R_next, R: std_logic_vector(31 downto 0);
--  	begin
--        if reset = '1' then
--            --R <= (others => '0');
--            R_next <= (others => '0');
--            fcs_error <= '0';
--            flag <= '0';
--            flag2 <= '0';
--            bit_count <= 0; 
--            last_bits <= 0; 
--        elsif rising_edge(clk) then
--            if start_of_frame = '1' then
--                flag <= '1';
--                current_bit <= not data_in;
--            end if;
--            elsif flag = '1' then
                
--                if bit_count < 32 then
--                    current_bit <= not data_in;
--                else
--                    current_bit <= data_in;
--                end if;
--                bit_count <= bit_count + 1;

                
--                 R_next(0) <= current_bit xor (R(31) and generator(0));
--                 R_next(1) <= R(0) xor (R(31) and generator(1)); 
--                 R_next(2) <= R(1) xor (R(31) and generator(2));
--                 R_next(3) <= R(2) xor (R(31) and generator(3)); 
--                 R_next(4) <= R(3) xor (R(31) and generator(4));
--                 R_next(5) <= R(4) xor (R(31) and generator(5));
--                 R_next(6) <= R(5) xor (R(31) and generator(6));
--                 R_next(7) <= R(6) xor (R(31) and generator(7));
--                 R_next(8) <= R(7) xor (R(31) and generator(8));
--                 R_next(9) <= R(8) xor (R(31) and generator(9));
--                 R_next(10) <= R(9) xor (R(31) and generator(10));
--                 R_next(11) <= R(10) xor (R(31) and generator(11));
--                 R_next(12) <= R(11) xor (R(31) and generator(12));
--                 R_next(13) <= R(12) xor (R(31) and generator(13));
--                 R_next(14) <= R(13) xor (R(31) and generator(14));
--                 R_next(15) <= R(14) xor (R(31) and generator(15));
--                 R_next(16) <= R(15) xor (R(31) and generator(16));
--                 R_next(17) <= R(16) xor (R(31) and generator(17));
--                 R_next(18) <= R(17) xor (R(31) and generator(18));
--                 R_next(19) <= R(18) xor (R(31) and generator(19));
--                 R_next(20) <= R(19) xor (R(31) and generator(20));
--                 R_next(21) <= R(20) xor (R(31) and generator(21));
--                 R_next(22) <= R(21) xor (R(31) and generator(22));
--                 R_next(23) <= R(22) xor (R(31) and generator(23));
--                 R_next(24) <= R(23) xor (R(31) and generator(24));
--                 R_next(25) <= R(24) xor (R(31) and generator(25));
--                 R_next(26) <= R(25) xor (R(31) and generator(26));
--                 R_next(27) <= R(26) xor (R(31) and generator(27));
--                 R_next(28) <= R(27) xor (R(31) and generator(28));
--                 R_next(29) <= R(28) xor (R(31) and generator(29));
--                 R_next(30) <= R(29) xor (R(31) and generator(30)); 
--                 R_next(31) <= R(30) xor (R(31) and generator(31));


--            end if;

--            if end_of_frame = '1' then
--                bit_count <= 0; 
--                flag2 <= '1';              
--            end if;
            
--            if bit_count >= 32 and flag2 = '1' then
--                flag <= '0';
--                    if (R = x"00000000") then
--                        fcs_error <= '0';
--                    else
--                        fcs_error <= '1';
--                    end if;
--                end if;
        
--    end process;  
--    R <= R_next;            
--  end Behavioral;
                
--                feedback := current_bit xor R(31);
--                 R_next(0) := feedback;
--                 for i in 31 downto 1 loop
--                    if (generator(i) = '1') then
--                        R_next(i) := R(i-1) xor R(31);
--                    else
--                        R_next(i) := R(i-1);
--                    end if;
--                end loop;
--                 R_next(1) := R(0) xor R(31); 
--                 R_next(2) := R(1) xor R(31);
--                 R_next(3) := R(2); 
--                 R_next(4) := R(3) xor R(31);
--                 R_next(5) <= R(4) xor R(31);
--                 R_next(6) <= R(5); 
--                 R_next(7) <= R(6) xor R(31);
--                 R_next(8) <= R(7) xor R(31);
--                 R_next(9) <= R(8);
--                 R_next(10) <= R(9) xor R(31);
--                 R_next(11) <= R(10) xor R(31);
--                 R_next(12) <= R(11) xor R(31);
--                 R_next(13) <= R(12);
--                 R_next(14) <= R(13);
--                 R_next(15) <= R(14);
--                 R_next(16) <= R(15) xor R(31);
--                 R_next(17) <= R(16);
--                 R_next(18) <= R(17);
--                 R_next(19) <= R(18);
--                 R_next(20) <= R(19);
--                 R_next(21) <= R(20);
--                 R_next(22) <= R(21) xor R(31);
--                 R_next(23) <= R(22) xor R(31);
--                 R_next(24) <= R(23);
--                 R_next(25) <= R(24);
--                 R_next(26) <= R(25) xor R(31);
--                 R_next(27) <= R(26);
--                 R_next(28) <= R(27);
--                 R_next(29) <= R(28); 
--                 R_next(30) <= R(29);
--                 R_next(31) <= R(30);
                 
--                for i in 1 to 31 loop
--                    if (generator(i) = '1') then
--                        R_next(i) <= R(i-1) xor R(31);
--                    else
--                        R_next(i) <= R(i-1);
--                    end if;
--                end loop;

--                   R := R_next;
--                   r_fin <= r;
--            end if;
            
--            if end_of_frame = '1' then
--                if R_fin = x"00000000" then
--                    fcs_error <= '0';
--                else
--                    fcs_error <= '1';
--                end if;
--            end if;
--        end if;
--    end process;          
--  end Behavioral;


