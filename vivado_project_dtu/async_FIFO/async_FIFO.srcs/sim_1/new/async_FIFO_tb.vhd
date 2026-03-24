----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2026 02:13:08 PM
-- Design Name: 
-- Module Name: async_FIFO_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity async_FIFO_tb is
--  Port ( );
end async_FIFO_tb;

architecture Behavioral of async_FIFO_tb is

    -- Costanti per i parametri
    constant WIDTH : integer := 8;
    constant DEPTH : integer := 32;

    -- Segnali del Testbench
    signal reset   : std_logic := '0';
    signal wclk    : std_logic := '0';
    signal rclk    : std_logic := '0';
    signal wr_en   : std_logic := '0';
    signal rd_en   : std_logic := '0';
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out: std_logic_vector(7 downto 0);
    signal occu_in : std_logic_vector(4 downto 0);
    signal occu_out: std_logic_vector(4 downto 0);

    -- Periodi dei clock (Asincroni: Scrittura più veloce della lettura)
    constant WCLK_PERIOD : time := 10 ns; -- 100 MHz
    constant RCLK_PERIOD : time := 25 ns; -- 40 MHz

begin

    -- Istanza della FIFO
    uut: entity work.async_fifo
        generic map ( FIFO_WIDTH => WIDTH, FIFO_DEPTH => DEPTH )
        port map (
            reset => reset, wclk => wclk, rclk => rclk,
            write_enable => wr_en, read_enable => rd_en,
            fifo_occu_in => occu_in, fifo_occu_out => occu_out,
            write_data_in => data_in, read_data_out => data_out
        );

    -- Generatore Clock Scrittura
    wclk_process : process
    begin
        wclk <= '0'; wait for WCLK_PERIOD/2;
        wclk <= '1'; wait for WCLK_PERIOD/2;
    end process;

    -- Generatore Clock Lettura
    rclk_process : process
    begin
        rclk <= '0'; wait for RCLK_PERIOD/2;
        rclk <= '1'; wait for RCLK_PERIOD/2;
    end process;

    -- Stimoli
    stim_proc: process
    begin		
        -- Reset iniziale
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 20 ns;

        -- Test 1: Scrittura sequenziale (Riempire la FIFO)
        for i in 1 to 10 loop
            wait until falling_edge(wclk);
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 8));
        end loop;
        wait until falling_edge(wclk);
        wr_en <= '0';

        wait for 100 ns;

        -- Test 2: Lettura sequenziale (Svuotare la FIFO)
        for i in 1 to 10 loop
            wait until falling_edge(rclk);
            rd_en <= '1';
        end loop;
        wait until falling_edge(rclk);
        rd_en <= '0';

        wait;
    end process;

end Behavioral;
