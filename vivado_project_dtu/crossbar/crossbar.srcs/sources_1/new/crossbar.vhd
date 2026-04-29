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
    type sel_array is array (0 to 3) of std_logic_vector(0 to 3);
    type occu_array is array (0 to 3) of std_logic_vector(4 downto 0);
    type input_sel is array (0 to 3) of integer range 0 to 3;
    type state_type is (IDLE, WAIT_DATA, SENDING);
    type state_array is array (0 to 3) of state_type;
    type ninebit_matrix is array (0 to 3, 0 to 3) of std_logic_vector(8 downto 0);
    type occu_matrix is array (0 to 3, 0 to 3) of std_logic_vector(4 downto 0);
    type matrix_wr_en_type is array (0 to 3, 0 to 3) of std_logic;
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
        reset    : in std_logic;
        data_in  : in ninebit_array;
        dst_port : in sel_array;
        data_out : out eightbit_array;
        tx_ctrl  : out std_logic_vector(0 to 3)  
     );
end crossbar;

architecture Behavioral of crossbar is

    signal fifo_dout  : ninebit_array;
    signal fifo_empty : std_logic_vector(0 to 3);
    signal occuin, occuout: occu_array;
    signal selected_input : input_sel;
    signal fifo_we_vector : std_logic_vector(0 to 3);   
    signal state: state_array;
    signal current_port : input_sel;
    signal fifo_matrix_out : ninebit_matrix;
    signal matrix_occu      : occu_matrix;
    signal matrix_rd_en     : matrix_wr_en_type;
    signal matrix_we : matrix_wr_en_type;
    
    component newfifo is
        port (  
            reset          : in std_logic; 
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
        
        Gen_fifo_input: for i in 0 to 3 generate
            Gen_fifo_output: for j in 0 to 3 generate
            
            matrix_we(i, j) <= (fifo_we_vector(i) and dst_port(i)(j));
            
            buff_inst: newfifo
                port map(  
                    reset          => reset,
                    wclk           => clk, 
                    rclk           => clk, 
                    write_enable  => matrix_we(i,j),
                    read_enable   => matrix_rd_en(i, j),
                    write_data_in => data_in(i),
                    read_data_out => fifo_matrix_out(i, j),
                    fifo_occu_in  => open, 
                    fifo_occu_out => matrix_occu(i, j)
                ); 
                
            --fifo_empty(i) <= '1' when occuout(i) = "00000" else '0';
            end generate;
        end generate;
        
        Fair_queuing_manager: for j in 0 to 3 generate
        process(clk, reset)
        begin
        if reset = '1' then
            state(j) <= IDLE;
            current_port(j) <= 0;
            tx_ctrl(j) <= '0';
            data_out(j) <= (others => '0');
            for i in 3 downto 0 loop
                matrix_rd_en(i, j) <= '0';
            end loop;
        elsif rising_edge(clk) then
            for i in 0 to 3 loop
                matrix_rd_en(i, j) <= '0';
            end loop;
            tx_ctrl(j) <= '0';
            case state(j) is
                when IDLE =>
                    -- Check if FIFO(input i, output j) has data
                    if  (dst_port(current_port(j))(j) = '1') then   --(matrix_occu(current_port(j), j) /= "00000") and
                        selected_input(j) <= current_port(j); 
                        matrix_rd_en(current_port(j), j) <= '1';
                        state(j) <= WAIT_DATA;
                    else 
                        current_port(j) <= (current_port(j) + 1) mod 4;
                    end if;
                    
                when WAIT_DATA =>
                    -- In questo ciclo la BRAM sta processando l'indirizzo.
                    -- Teniamo rd_en alto per preparare già il secondo byte.
                    matrix_rd_en(selected_input(j), j) <= '1';
                    state(j) <= SENDING; -- Al prossimo colpo il dato sarà pronto

                when SENDING =>
                    matrix_rd_en(selected_input(j), j) <= '1';
                    data_out(j) <= fifo_matrix_out(selected_input(j), j)(7 downto 0);
                    tx_ctrl(j) <= '1'; -- Segnale valido in uscita [cite: 1164]

                    if fifo_matrix_out(selected_input(j), j)(8) = '1' then -- Fine frame 
                        state(j) <= IDLE;
                        current_port(j) <= (current_port(j) + 1) mod 4;
                        matrix_rd_en(selected_input(j), j) <= '0';
                    else
                        matrix_rd_en(selected_input(j), j) <= '1';
                    end if;
            end case;
        end if;
    end process;
end generate;
end Behavioral;

-- j is the output port, fixed per instance
-- current_port is the input port, dynamic
-- NOTE: the main problem of this code is the occupancy of the memory. It never updates. If I delete the part of the code that is referred
-- to the memory occupancy in the condition that changes the state 
-- NOTE: when the state is in sending the current_port doesn't change

--                 case state(j) is
--                        when IDLE =>
--                            if (fifo_empty(current_port) = '0') and (dst_port(current_port)(j) = '1') then
--                                deficit(j) := QUANTUM;
--                                selected_input(j) <= current_port; -- found a packet!
--                                state(j) <= SENDING;
--                            else 
--                                current_port := (current_port + 1) mod 4;
--                                deficit(j) := 0;
--                            end if;
                            
--    -- wainting state with counter 
--                        when SENDING =>
--                            deficit(j) := deficit(j) - 1;
--                            if fifo_dout(selected_input(j))(8) = '1' then
--                                if deficit(j) < SIZE then
--                                    state(j) <= IDLE;
--                                    current_port := (current_port + 1) mod 4;
--                                end if;
--                            end if;
--                            if deficit(j) > SIZE then
--                                data_out(j) <= fifo_dout(selected_input(j))(7 downto 0);
--                                tx_ctrl(selected_input(j)) <= '1';
--                           end if;
--                    end case;   