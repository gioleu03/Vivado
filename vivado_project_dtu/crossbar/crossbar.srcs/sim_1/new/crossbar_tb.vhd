----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2026 10:34:59 AM
-- Design Name: 
-- Module Name: crossbar_tb - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.switch_types.all;

entity crossbar_tb is
-- Testbench has no ports
end crossbar_tb;

architecture sim of crossbar_tb is

    -- Component Declaration
    component crossbar
        Port (
            clk      : in std_logic;
            reset    : in std_logic;
            data_in  : in ninebit_array;
            dst_port : in sel_array;
            data_out : out eightbit_array;
            tx_ctrl  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signal Declarations
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : ninebit_array := (others => (others => '0'));
    signal dst_port : sel_array := (others => (others => '0'));
    signal data_out : eightbit_array;
    signal tx_ctrl  : std_logic_vector(3 downto 0);

    -- Clock Period Definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: crossbar
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => data_in,
            dst_port => dst_port,
            data_out => data_out,
            tx_ctrl  => tx_ctrl
        );

    -- Clock Process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin		
        -- Global Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Test Case 1: Send a 3-byte packet from Input 0 to Output 0
        -- Byte 1
        dst_port(0) <= "0010"; -- Target Port 0
        data_in(0)  <= '0' & x"AA"; 
        wait for CLK_PERIOD;
        
        -- Byte 2
        data_in(0)  <= '0' & x"BB";
        wait for CLK_PERIOD;
        
        -- Byte 3 (End of Frame bit set to '1')
        data_in(0)  <= '1' & x"CC";
        wait for CLK_PERIOD;
        
        -- Stop sending from Port 0
        dst_port(0) <= "0000";
        data_in(0)  <= (others => '0');
        
        wait for CLK_PERIOD * 5;

        -- Test Case 2: Parallel Transfer
        -- Port 1 -> Output 2
        -- Port 2 -> Output 3
        dst_port(1) <= "0100"; -- Target Port 2
        dst_port(2) <= "1000"; -- Target Port 3
        
        data_in(1) <= '0' & x"11";
        data_in(2) <= '0' & x"22";
        wait for CLK_PERIOD;
        
        data_in(1) <= '1' & x"EE"; -- EOF for Port 1
        data_in(2) <= '1' & x"FF"; -- EOF for Port 2
        wait for CLK_PERIOD;

        dst_port <= (others => "0000");
        data_in  <= (others => (others => '0'));

        wait for 100 ns;
        
        -- End Simulation
        assert false report "Simulation Finished" severity failure;
        wait;
    end process;

end sim;
