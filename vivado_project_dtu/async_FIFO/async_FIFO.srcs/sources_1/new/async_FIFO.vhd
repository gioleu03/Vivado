----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2026 12:44:37
-- Design Name: 
-- Module Name: async_FIFO - Behavioral
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
    Generic(
         FIFO_WIDTH : integer := 8;
         FIFO_DEPTH : integer := 32
     ); 
    port (  
        reset          : in std_logic; 
        wclk           : in std_logic; 
        rclk           : in std_logic; 
        write_enable   : in std_logic; 
        read_enable    : in std_logic; 
        fifo_occu_in   : out std_logic_vector(4 downto 0); 
        fifo_occu_out  : out std_logic_vector(4 downto 0); 
        write_data_in  : in std_logic_vector(7 downto 0); 
        read_data_out  : out std_logic_vector(7 downto 0) 
    ); 
end async_fifo; 

architecture Behavioral of async_FIFO is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal wptr, rptr: std_logic_vector (4 downto 0) := (others => '0');
-- Sincronizzatori minimi indispensabili (Task 1 & 2)
signal wptr_s, rptr_s : std_logic_vector (4 downto 0) := (others => '0');
signal wptr_reg, rptr_reg : std_logic_vector (4 downto 0) := (others => '0');

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
            if write_enable = '1' and full = '0' then
                wptr <= std_logic_vector(unsigned(wptr) + 1);
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

-- KINDA SIMILAR TO THE ORIGINAL BUT WITH IMPROVEMENTS
--process(wclk) begin
--        if rising_edge(wclk) then
--            rptr_reg <= rptr; rptr_s <= rptr_reg; 
--        end if;
--    end process;

--    process(rclk) begin
--        if rising_edge(rclk) then
--            wptr_reg <= wptr; wptr_s <= wptr_reg;
--        end if;
--    end process;

--    -- PROCESSO DI SCRITTURA (Tua logica originale)
--    process(wclk, reset)
--        variable index_write : integer;
--    begin
--        if reset = '1' then
--            wptr <= (others => '0');
--            full <= '0';
--        elsif rising_edge(wclk) then
--            if write_enable = '1' and full = '0' then
--                index_write := to_integer(unsigned(wptr(3 downto 0))); -- [cite: 24, 25]
--                memory(index_write) <= write_data_in;
--                wptr <= std_logic_vector(unsigned(wptr) + 1); -- 
--            end if;
            
--            -- TUA OPERAZIONE: Logica FULL (usando il segnale sincronizzato rptr_s)
--            --  Se MSB diversi (wptr(4) /= rptr_s(4)) e indirizzo uguale, è FULL.
--            if (wptr(4) /= rptr_s(4)) and (wptr(3 downto 0) = rptr_s(3 downto 0)) then
--                full <= '1';
--            else
--                full <= '0';
--            end if;
--        end if;
--    end process;

--    -- PROCESSO DI LETTURA (Tua logica originale)
--    process(rclk, reset)
--    begin
--        if reset = '1' then
--            rptr <= (others => '0');
--            empty <= '1';
--        elsif rising_edge(rclk) then
--            if read_enable = '1' and empty = '0' then
--                rptr <= std_logic_vector(unsigned(rptr) + 1); -- 
--            end if;

--            -- TUA OPERAZIONE: Logica EMPTY (usando wptr_s)
--            --  Se i puntatori sono identici, è EMPTY.
--            if wptr_s = rptr then
--                empty <= '1';
--            else
--                empty <= '0';
--            end if;
--        end if;
--    end process;





--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

--entity async_fifo is
--    Generic(
--         FIFO_WIDTH : integer := 8;
--         FIFO_DEPTH : integer := 32
--     ); 
--    port (  
--        reset          : in std_logic; 
--        wclk           : in std_logic; 
--        rclk           : in std_logic; 
--        write_enable   : in std_logic; 
--        read_enable    : in std_logic; 
--        fifo_occu_in   : out std_logic_vector(4 downto 0); 
--        fifo_occu_out  : out std_logic_vector(4 downto 0); 
--        write_data_in  : in std_logic_vector(7 downto 0); 
--        read_data_out  : out std_logic_vector(7 downto 0) 
--    ); 
--end async_fifo; 

--architecture Behavioral of async_FIFO is

--COMPONENT blk_mem_gen_0
--  PORT (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    enb : IN STD_LOGIC;
--    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--    dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--  );
--END COMPONENT;

--signal wptr, rptr: std_logic_vector (4 downto 0);
----signal fifo_size: integer range 0 to 64;
--type memory_type is array (0 to FIFO_DEPTH-1) of std_logic_vector(write_data_in'range);
--signal memory: memory_type;
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
    
    
--    process(wclk, reset)
--        variable index_write : integer;
--    begin
--        if reset = '1' then
--            wptr <= (others => '0');
--            full <= '0';
--            memory <= (others => (others => '0'));
--        elsif rising_edge(wclk) then
--            if write_enable = '1' and full = '0' then
--                index_write := to_integer(unsigned(wptr(3 downto 0)));
--                memory(index_write) <= write_data_in;
--                wptr <= std_logic_vector(unsigned(wptr) + 1);
--            end if;
            
--            -- Logica FULL (semplificata per asincrono)
--            if unsigned(wptr) + 1 = unsigned(rptr) then
--                full <= '1';
--            else
--                full <= '0';
--            end if;
--        end if;
--    end process;

--    -- PROCESSO DI LETTURA (Dominio rclk)
--    process(rclk, reset)
--    begin
--        if reset = '1' then
--            rptr <= (others => '0');
--            empty <= '1';
--        elsif rising_edge(rclk) then
--            if read_enable = '1' and empty = '0' then
--                rptr <= std_logic_vector(unsigned(rptr) + 1);
--            end if;

--            -- Logica EMPTY
--            if wptr = rptr then
--                empty <= '1';
--            else
--                empty <= '0';
--            end if;
--        end if;
--    end process;

--    fifo_occu_in <= wptr;
--    fifo_occu_out <= rptr;

--end Behavioral;

