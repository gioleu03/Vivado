----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2026 01:08:35 PM
-- Design Name: 
-- Module Name: fifo_tb - Behavioral
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

To simulate your Asynchronous FIFO, we need a Testbench that generates two independent clocks (since it's asynchronous) and handles the reset and data flow.

I have created a VHDL testbench that simulates a typical write-read cycle, specifically testing your rollback/commit logic (the logic involving write_data_in(8) as an End-of-Frame bit).

VHDL Testbench (tb_async_fifo.vhd)
VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_fifo is
end tb_fifo;

architecture sim of tb_fifo is

    -- Component Declaration
    component fifo
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
    end component;

    -- Signals
    signal reset         : std_logic := '0';
    signal wclk          : std_logic := '0';
    signal rclk          : std_logic := '0';
    signal write_enable  : std_logic := '0';
    signal read_enable   : std_logic := '0';
    signal fifo_occu_in  : std_logic_vector(4 downto 0);
    signal fifo_occu_out : std_logic_vector(4 downto 0);
    signal write_data_in : std_logic_vector(8 downto 0) := (others => '0');
    signal read_data_out : std_logic_vector(8 downto 0);

    -- Clock Periods (Asynchronous)
    constant WCLK_PERIOD : time := 10 ns; -- 100 MHz
    constant RCLK_PERIOD : time := 15 ns; -- ~66 MHz

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: fifo
        port map (
            reset         => reset,
            wclk          => wclk,
            rclk          => rclk,
            write_enable  => write_enable,
            read_enable   => read_enable,
            fifo_occu_in  => fifo_occu_in,
            fifo_occu_out => fifo_occu_out,
            write_data_in => write_data_in,
            read_data_out => read_data_out
        );

    -- Write Clock Generation
    wclk_process : process
    begin
        wclk <= '0'; wait for WCLK_PERIOD/2;
        wclk <= '1'; wait for WCLK_PERIOD/2;
    end process;

    -- Read Clock Generation
    rclk_process : process
    begin
        rclk <= '0'; wait for RCLK_PERIOD/2;
        rclk <= '1'; wait for RCLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin		
        -- Initial Reset
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 20 ns;

        -- CASE 1: Simple Write (Partial Packet)
        -- Data bit 8 is '0', so wptr_saved won't update yet
        wait until falling_edge(wclk);
        write_enable <= '1';
        write_data_in <= "000001010"; -- Data 10
        wait for WCLK_PERIOD;
        write_data_in <= "000001011"; -- Data 11
        wait for WCLK_PERIOD;
        
        -- CASE 2: Commit Packet (EOF = '1')
        write_data_in <= "100001100"; -- Data 12, Bit 8 = 1 (Commit)
        wait for WCLK_PERIOD;
        write_enable <= '0';

        -- Wait for synchronizers
        wait for 100 ns;

        -- CASE 3: Read data
        wait until falling_edge(rclk);
        read_enable <= '1';
        wait for 3 * RCLK_PERIOD;
        read_enable <= '0';

        wait;
    end process;

end sim;
