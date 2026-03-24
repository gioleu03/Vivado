----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.02.2026 18:36:57
-- Design Name: 
-- Module Name: fcs_tb - Behavioral
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

entity fcs_check_serial_tb is
-- Le testbench non hanno porte
end fcs_check_serial_tb;

architecture behavior of fcs_check_serial_tb is 

    -- Component Declaration per la Unit Under Test (UUT)
    component fcs_check_serial
    port(
         clk            : in  std_logic;
         reset          : in  std_logic;
         start_of_frame : in  std_logic;
         end_of_frame   : in  std_logic;
         data_in        : in  std_logic;
         fcs_error      : out std_logic
        );
    end component;
    
    -- Segnali di stimolo
    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal start_of_frame : std_logic := '0';
    signal end_of_frame   : std_logic := '0';
    signal data_in        : std_logic := '0';
    signal fcs_error      : std_logic;

    -- Definizione del periodo di Clock (100 MHz)
    constant clk_period : time := 10 ns;

    -- Array per il Payload (60 byte)
    type byte_array is array (natural range <>) of std_logic_vector(7 downto 0);
    constant packet_data : byte_array(0 to 59) := (
        x"00", x"10", x"A4", x"7B", x"EA", x"80", x"00", x"12", x"34", x"56", x"78",
        x"90", x"08", x"00", x"45", x"00", x"00", x"2E", x"B3", x"FE", x"00", x"00", 
        x"80", x"11", x"05", x"40", x"C0", x"A8", x"00", x"2C", x"C0", x"A8", x"00", 
        x"04", x"04", x"00", x"04", x"00", x"00", x"1A", x"2D", x"E8", x"00", x"01", 
        x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A", x"0B", x"0C", 
        x"0D", x"0E", x"0F", x"10", x"11"
    );
    
    -- Array per il Checksum FCS (4 byte / 32 bit)
    constant fcs_data : byte_array(0 to 3) := (x"E6", x"C5", x"3D", x"B2");

begin

    -- Istanza della UUT (Il modulo dove hai rinominato rem in rema)
    uut: fcs_check_serial port map (
          clk => clk,
          reset => reset,
          start_of_frame => start_of_frame,
          end_of_frame => end_of_frame,
          data_in => data_in,
          fcs_error => fcs_error
        );

    -- Generazione del Clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo di Stimolo
    stim_proc: process
    begin		
        -- 1. Reset Iniziale
        reset <= '1';
        start_of_frame <= '0';
        end_of_frame <= '0';
        data_in <= '0';
        wait for 35 ns; -- Reset asincrono attivo per un po'	
        reset <= '0';
        wait until rising_edge(clk);
        wait for clk_period;

        -- 2. Invio Payload (start_of_frame = '1')
        -- Inviamo i bit dal MSB (bit 7) al LSB (bit 0) per ogni byte
        start_of_frame <= '1';
        for i in packet_data'range loop
            for j in 7 downto 0 loop
                data_in <= packet_data(i)(j);
                wait until rising_edge(clk);
            end loop;
        end loop;
        start_of_frame <= '0';

        -- 3. Invio FCS (end_of_frame = '1')
        -- Qui iniziano gli ultimi 32 bit
        end_of_frame <= '1';
        for i in fcs_data'range loop
            for j in 7 downto 0 loop
                data_in <= fcs_data(i)(j);
                wait until rising_edge(clk);
            end loop;
        end loop;
        
        -- 4. Fine del pacchetto (Entrambi i segnali a '0')
        end_of_frame <= '0';
        data_in <= '0';

        -- Osservazione del risultato finale
        wait for clk_period * 10;

        report "Simulazione Terminata correttamente.";
        wait;
    end process;

end behavior;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity fcs_tb is
--end fcs_tb;

--architecture sim of fcs_tb is
--    -- Segnali per collegare il componente
--    signal clk            : std_logic := '0';
--    signal reset          : std_logic := '0';
--    signal start_of_frame : std_logic := '0';
--    signal end_of_frame   : std_logic := '0';
--    signal data_in        : std_logic := '0';
--    signal fcs_error      : std_logic;

--    -- Costante con il messaggio fornito (64 byte totali inclusi i 4 di FCS)
--    constant message_vector : std_logic_vector(0 to 511) := x"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    
--    constant CLK_PERIOD : time := 10 ns;

--begin
--    -- Istanza del tuo componente
--    uut: entity work.fcs
--        port map (
--            clk            => clk,
--            reset          => reset,
--            start_of_frame => start_of_frame,
--            end_of_frame   => end_of_frame,
--            data_in        => data_in,
--            fcs_error      => fcs_error
--        );

--    -- Generatore di clock
--    clk_process : process
--    begin
--        clk <= '0';
--        wait for CLK_PERIOD/2;
--        clk <= '1';
--        wait for CLK_PERIOD/2;
--    end process;

--    -- Processo di stimolo
--    stim_proc: process
--    begin		
--        -- Reset iniziale
--        reset <= '1';
--        wait for 20 ns;
--        reset <= '0';
--        wait for CLK_PERIOD;

--        -- 1. Impulso START OF FRAME
--        start_of_frame <= '1';
--        wait for CLK_PERIOD;
--        start_of_frame <= '0';

--        -- 2. Trasmissione Dati (Primi 60 byte, ovvero 480 bit)
--        -- Escludiamo gli ultimi 32 bit (4 byte) che sono l'FCS
--        for i in 0 to 479 loop
--            -- Logica per estrarre il bit corretto (Ethernet trasmette LSB dell'ottetto per primo)
--            -- Calcoliamo l'indice del bit all'interno del byte corrente
--            data_in <= message_vector(i); 
--            wait for CLK_PERIOD;
--        end loop;

--        -- 3. Impulso END OF FRAME (va su prima degli ultimi 32 bit)
--        end_of_frame <= '1';
--        wait for CLK_PERIOD;
--        end_of_frame <= '0';

--        -- 4. Trasmissione FCS (Ultimi 32 bit: da 480 a 511)
--        for i in 480 to 511 loop
--            data_in <= message_vector(i);
--            wait for CLK_PERIOD;
--        end loop;

--        -- Fine trasmissione, attendiamo qualche colpo di clock per vedere il risultato
--        data_in <= '0';
--        wait for 100 ns;

--        -- Verifica finale: fcs_error dovrebbe essere '0' per questo vettore specifico
--        assert fcs_error = '0' report "ERRORE: FCS non valido per il pacchetto di esempio!" severity error;

--        wait;
--    end process;

--end sim;
                -- Logica del circuito LFSR basata sullo schema
                