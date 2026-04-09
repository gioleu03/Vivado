----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2026 01:37:31 PM
-- Design Name: 
-- Module Name: crossbar - Behavioral
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

package switch_types is
    -- 9 bits: 8 bits data + 1 bit end-of-frame flag [cite: 32, 72]
    type ninebit_array is array (0 to 3) of std_logic_vector(8 downto 0);
    type eightbit_array is array (0 to 3) of std_logic_vector(7 downto 0);
    type sel_array is array (0 to 3) of std_logic_vector(3 downto 0);
    type occu_array is array (0 to 3) of std_logic_vector(4 downto 0);
    type input_sel is array (3 downto 0) of integer range 0 to 3;
    type state_type is (IDLE, SENDING);
    type state_array is array (0 to 3) of state_type;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
library work;
use work.switch_types.all;

entity crossbar is
Port (
        clk      : in std_logic;
        data_in  : in ninebit_array;
        dst_port : in sel_array;
        data_out : out eightbit_array;
        tx_ctrl  : out std_logic_vector(3 downto 0)  
     );
end crossbar;

architecture Behavioral of crossbar is

    signal fifo_dout  : ninebit_array;
    signal fifo_empty : std_logic_vector(3 downto 0);
    signal rd_en      : std_logic_vector(3 downto 0);
    signal occuin, occuout: occu_array;
    signal selected_input : input_sel;
    signal fifo_we_vector : std_logic_vector(3 downto 0);   
    signal state: state_array;
    
    component newfifo is
        port (  
            --reset          : in std_logic; 
            wclk           : in std_logic; 
            rclk           : in std_logic; 
            write_enable   : in std_logic; 
            read_enable    : in std_logic; 
            fifo_occu_in   : out std_logic_vector(4 downto 0); 
            fifo_occu_out  : out std_logic_vector(4 downto 0); 
            write_data_in  : in std_logic_vector(8 downto 0); -- 8-bit data + 1-bit EOF [cite: 32]
            read_data_out  : out std_logic_vector(8 downto 0) 
        ); 
    end component;    
                        
begin
        gen_logic: for i in 0 to 3 generate
            fifo_we_vector(i) <= '1' when dst_port(i) /= "0000" else '0';
        end generate;
        
        Gen_fifo: for i in 0 to 3 generate
            buff_inst: newfifo
                port map(  
                    --reset          => open,
                    wclk           => clk, 
                    rclk           => clk, 
                    write_enable   => fifo_we_vector(i),
                    read_enable    => rd_en(i),
                    fifo_occu_in   => occuin(i),
                    fifo_occu_out  => occuout(i),
                    write_data_in  => data_in(i), 
                    read_data_out  => fifo_dout(i)
                ); 
        end generate;

        Fair_queuing_manager: for j in 0 to 3 generate
        process(clk)
        variable current_port : integer range 0 to 3 := 0 ;
        begin
            if rising_edge(clk) then
                case state(j) is
                    when IDLE =>
                        if (fifo_empty(current_port) = '0') and (dst_port(current_port) = std_logic_vector(to_unsigned(j, 4))) then
                            selected_input(j) <= current_port; -- found a packet!
                            state(j) <= SENDING;
                        else 
                            current_port := (current_port + 1) mod 4;
                        end if;

                    when SENDING =>
                        data_out(j) <= fifo_dout(selected_input(j))(7 downto 0);
                        tx_ctrl(selected_input(j)) <= '1';
                        if fifo_dout(selected_input(j))(8) = '1' then
                            state(j) <= IDLE;
                            current_port := (current_port + 1) mod 4;
                        end if;
                end case;
            end if;
        end process;
    end generate;
end Behavioral;

-- j is the output port, fixed per instance
-- current_port is the input port, dynamic