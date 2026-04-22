----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2026 04:34:28 PM
-- Design Name: 
-- Module Name: newfifo - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity async_fifo is
    port (  
        reset          : in std_logic; 
        wclk           : in std_logic; 
        rclk           : in std_logic; 
        write_enable   : in std_logic; 
        read_enable    : in std_logic; 
        fifo_occu_in   : out std_logic_vector(4 downto 0); 
        fifo_occu_out  : out std_logic_vector(4 downto 0); 
        write_data_in  : in std_logic_vector(8 downto 0); 
        read_data_out  : out std_logic_vector(8 downto 0) 
    ); 
end async_fifo; 

architecture Behavioral of async_FIFO is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal wptr, rptr: std_logic_vector (4 downto 0) := (others => '0');
-- Sincronizzatori minimi indispensabili (Task 1 & 2)
signal wptr_s, rptr_s : std_logic_vector (4 downto 0) := (others => '0');
signal wptr_reg, rptr_reg, wptr_saved : std_logic_vector (4 downto 0) := (others => '0');

signal empty, full: std_logic;

begin

RAM : blk_mem_gen_0
    PORT MAP (
        -- Lato Scrittura (Porta A)
        clka  => wclk,                  -- Clock di scrittura [cite: 106]
        ena   => write_enable,          -- Abilitazione [cite: 109]
        wea(0)=> write_enable,          -- Scrivi quando abilitato [cite: 109]
        addra => wptr(3 downto 0),      -- Solo i 4 bit bassi per l'indirizzo [cite: 24, 25]
        dina  => write_data_in,         -- Dati in ingresso [cite: 118]
        
        -- Lato Lettura (Porta B)
        clkb  => rclk,                  -- Clock di lettura [cite: 108]
        enb   => read_enable,           -- Abilitazione lettura [cite: 111]
        web(0)=> '0',                   -- Mai scrivere dalla porta B
        addrb => rptr(3 downto 0),      -- Solo i 4 bit bassi per l'indirizzo [cite: 24, 25]
        dinb  => (others => '0'),       -- Non usato
        doutb => read_data_out          -- Dati in uscita [cite: 117]
      );
    
    process(wclk) begin
        if rising_edge(wclk) then
            rptr_reg <= rptr; 
            rptr_s <= rptr_reg; -- rptr sincronizzato in wclk
        end if;
    end process;

    process(rclk) begin
        if rising_edge(rclk) then
            wptr_reg <= wptr; 
            wptr_s <= wptr_reg; -- wptr sincronizzato in rclk
        end if;
    end process;
    
    full  <= '1' when (wptr(4) /= rptr_s(4) and wptr(3 downto 0) = rptr_s(3 downto 0)) else '0';
    empty <= '1' when (rptr = wptr_s) else '0';
    
    process(wclk, reset)
    begin
        if reset = '1' then
            wptr <= (others => '0');
        elsif rising_edge(wclk) then
            -- FULL se i bit bassi sono uguali ma il bit MSB è diverso [cite: 29]
            if write_data_in(8) <= '1' then
                wptr_saved <= wptr;
            end if;
            if write_enable = '1' and full = '0' then
                wptr <= std_logic_vector(unsigned(wptr) + 1);
            end if;
            if full <= '1' and write_data_in(8) <= '0' then
                wptr <= wptr_saved;
            end if;
        end if;
    end process;

    -- PROCESSO DI LETTURA (Dominio rclk)
    process(rclk, reset)
    begin
        if reset = '1' then
            rptr <= (others => '0');
        elsif rising_edge(rclk) then
            -- EMPTY se i puntatori sono identici [cite: 29]
            if read_enable = '1' and empty = '0' then
                rptr <= std_logic_vector(unsigned(rptr) + 1);
            end if;
        end if;
    end process;

    -- Assegnazione segnali esterni
    fifo_occu_in <= wptr;
    fifo_occu_out <= rptr;

end Behavioral;
