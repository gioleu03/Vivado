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

--architecture Behavioral of async_FIFO is

--COMPONENT blk_mem_gen_0
--  PORT (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    enb : IN STD_LOGIC;
--    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    dinb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
--  );
--END COMPONENT;

--signal wptr, rptr: std_logic_vector (4 downto 0) := (others => '0');
---- Sincronizzatori minimi indispensabili (Task 1 & 2)
--signal wptr_s, rptr_s : std_logic_vector (4 downto 0) := (others => '0');
--signal wptr_reg, rptr_reg, wptr_saved : std_logic_vector (4 downto 0) := (others => '0');

--signal empty, full: std_logic;

--begin

--RAM : blk_mem_gen_0
--    PORT MAP (
--        -- Lato Scrittura (Porta A)
--        clka  => wclk,                  -- Clock di scrittura [cite: 106]
--        ena   => write_enable,          -- Abilitazione [cite: 109]
--        wea(0)=> write_enable,          -- Scrivi quando abilitato [cite: 109]
--        addra => wptr(3 downto 0),      -- Solo i 4 bit bassi per l'indirizzo [cite: 24, 25]
--        dina  => write_data_in,         -- Dati in ingresso [cite: 118]
        
--        -- Lato Lettura (Porta B)
--        clkb  => rclk,                  -- Clock di lettura [cite: 108]
--        enb   => read_enable,           -- Abilitazione lettura [cite: 111]
--        web(0)=> '0',                   -- Mai scrivere dalla porta B
--        addrb => rptr(3 downto 0),      -- Solo i 4 bit bassi per l'indirizzo [cite: 24, 25]
--        dinb  => (others => '0'),       -- Non usato
--        doutb => read_data_out          -- Dati in uscita [cite: 117]
--      );
    
--    process(wclk) begin
--        if rising_edge(wclk) then
--            rptr_reg <= rptr; 
--            rptr_s <= rptr_reg; -- rptr sincronizzato in wclk
--        end if;
--    end process;

--    process(rclk) begin
--        if rising_edge(rclk) then
--            wptr_reg <= wptr_saved; 
--            wptr_s <= wptr_reg; -- wptr sincronizzato in rclk
--        end if;
--    end process;
    
--    full  <= '1' when (wptr(4) /= rptr_s(4) and wptr(3 downto 0) = rptr_s(3 downto 0)) else '0';
--    empty <= '1' when (rptr = wptr_s) else '0';
    
-- process(wclk, reset)
--    variable v_wptr : unsigned(4 downto 0);
--begin
--    if reset = '1' then
--        wptr <= (others => '0');
--        wptr_saved <= (others => '0');
--    elsif rising_edge(wclk) then
--        if write_enable = '1' and full = '0' then
--            v_wptr := unsigned(wptr) + 1;
--            wptr <= std_logic_vector(v_wptr);
--            if write_data_in(8) = '1' then
--                wptr_saved <= std_logic_vector(v_wptr); -- COMMIT REALE
--            end if;
--        elsif full = '1' and write_data_in(8) = '0' then
--            wptr <= wptr_saved; -- DROP
--        end if;
--    end if;
--end process;

--    -- PROCESSO DI LETTURA (Dominio rclk)
--    process(rclk, reset)
--    begin
--        if reset = '1' then
--            rptr <= (others => '0');
--        elsif rising_edge(rclk) then
--            -- EMPTY se i puntatori sono identici [cite: 29]
--            if read_enable = '1' and empty = '0' then
--                rptr <= std_logic_vector(unsigned(rptr) + 1);
--            end if;
--        end if;
--    end process;

--    -- Assegnazione segnali esterni
--    fifo_occu_in <= wptr;
--    fifo_occu_out <= std_logic_vector(unsigned(wptr_s) - unsigned(rptr));

--end Behavioral;


architecture Behavioral of async_FIFO is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
  );
END COMPONENT;

-- Inizializziamo a zero per evitare 'U' all'avvio
signal wptr : std_logic_vector(4 downto 0) := (others => '0');
signal rptr : std_logic_vector(4 downto 0) := (others => '0');
signal wptr_saved : std_logic_vector(4 downto 0) := (others => '0');

-- Sincronizzatori
signal rptr_reg, rptr_s : std_logic_vector(4 downto 0) := (others => '0');
signal wptr_saved_reg, wptr_saved_s : std_logic_vector(4 downto 0) := (others => '0');

signal empty, full : std_logic;

begin

RAM : blk_mem_gen_0
    PORT MAP (
        clka  => wclk,
        ena   => '1', -- Sempre attiva per scrivere
        wea(0)=> write_enable,
        addra => wptr(3 downto 0),
        dina  => write_data_in,
        clkb  => rclk,
        enb   => read_enable,
        addrb => rptr(3 downto 0),
        doutb => read_data_out
    );

    -- Sincronizzazione rptr nel dominio wclk (per il FULL)
    process(wclk) begin
        if rising_edge(wclk) then
            if reset = '1' then
                rptr_reg <= (others => '0');
                rptr_s   <= (others => '0');
            else
                rptr_reg <= rptr;
                rptr_s   <= rptr_reg;
            end if;
        end if;
    end process;

    -- Sincronizzazione wptr_saved nel dominio rclk (per l'EMPTY)
    -- Importante: usiamo wptr_saved perché i dati sono leggibili solo dopo il commit
    process(rclk) begin
        if rising_edge(rclk) then
            if reset = '1' then
                wptr_saved_reg <= (others => '0');
                wptr_saved_s   <= (others => '0');
            else
                wptr_saved_reg <= wptr_saved;
                wptr_saved_s   <= wptr_saved_reg;
            end if;
        end if;
    end process;

    -- Logica FULL (su wptr corrente) ed EMPTY (su wptr_saved sincronizzato)
    full  <= '1' when (wptr(4) /= rptr_s(4) and wptr(3 downto 0) = rptr_s(3 downto 0)) else '0';
    empty <= '1' when (rptr = wptr_saved_s) else '0';

    -- Processo di Scrittura con Commit/Drop
    process(wclk, reset)
        variable v_wptr : unsigned(4 downto 0);
    begin
        if reset = '1' then
            wptr <= (others => '0');
            wptr_saved <= (others => '0');
        elsif rising_edge(wclk) then
            if write_enable = '1' and full = '0' then
                v_wptr := unsigned(wptr) + 1;
                wptr <= std_logic_vector(v_wptr);
                -- Se arriva EOF (bit 8), rendiamo i dati visibili al lettore
                if write_data_in(8) = '1' then
                    wptr_saved <= std_logic_vector(v_wptr);
                end if;
            elsif full = '1' and write_data_in(8) = '0' then
                -- Se la FIFO si riempie senza aver finito il pacchetto, scartiamo tutto il frame
                wptr <= wptr_saved;
            end if;
        end if;
    end process;

    -- Processo di Lettura
    process(rclk, reset)
    begin
        if reset = '1' then
            rptr <= (others => '0');
        elsif rising_edge(rclk) then
            if read_enable = '1' and empty = '0' then
                rptr <= std_logic_vector(unsigned(rptr) + 1);
            end if;
        end if;
    end process;

    fifo_occu_in <= wptr;
    fifo_occu_out <= std_logic_vector(unsigned(wptr_saved_s) - unsigned(rptr));

end Behavioral;