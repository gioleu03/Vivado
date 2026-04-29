library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package switch_types is
    type ninebit_array is array (0 to 3) of std_logic_vector(8 downto 0);
    type eightbit_array is array (0 to 3) of std_logic_vector(7 downto 0);
    type sel_array is array (0 to 3) of std_logic_vector(3 downto 0);
    type occu_array is array (0 to 3) of std_logic_vector(4 downto 0);
    type input_sel is array (0 to 3) of integer range 0 to 3;
    type state_type is (IDLE, WAIT_DATA, SENDING);
    type state_array is array (0 to 3) of state_type;
    type ninebit_matrix is array (0 to 3, 0 to 3) of std_logic_vector(8 downto 0);
    type occu_matrix is array (0 to 3, 0 to 3) of std_logic_vector(4 downto 0);
    type matrix_en_type is array (0 to 3) of std_logic_vector(0 to 3);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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
    signal matrix_rd_en   : matrix_en_type := (others => (others => '0'));
    signal matrix_occu      : occu_matrix;
    signal fifo_matrix_out : ninebit_matrix;
    signal selected_input  : input_sel := (others => 0);
    signal state           : state_array := (others => IDLE);
    signal current_port    : input_sel := (others => 0);
    signal matrix_we       : matrix_en_type;

    component newfifo_1 is
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

begin
    -- Generazione Matrix di FIFO
    Gen_In: for i in 0 to 3 generate
        Gen_Out: for j in 0 to 3 generate
            -- FIXED: (i,j) -> (i)(j)
            matrix_we(i)(j) <= '1' when (dst_port(i)(j) = '1') else '0';
            
            buff_inst: newfifo_1    
                port map(  
                    reset          => reset,
                    wclk           => clk, 
                    rclk           => clk, 
                    write_enable   => matrix_we(i)(j),    -- FIXED indexing
                    read_enable    => matrix_rd_en(i)(j), -- FIXED indexing
                    write_data_in  => data_in(i),
                    read_data_out  => fifo_matrix_out(i, j),
                    fifo_occu_in   => open, 
                    fifo_occu_out  => matrix_occu(i, j)
                ); 
        end generate;
    end generate;

    -- Fair Queuing Manager
    Fair_logic: for j in 0 to 3 generate
        process(clk, reset)
        begin
            if reset = '1' then
                state(j) <= IDLE;
                current_port(j) <= 0;
                tx_ctrl(j) <= '0';
                data_out(j) <= (others => '0');
                for i in 0 to 3 loop 
                    matrix_rd_en(i)(j) <= '0'; -- FIXED indexing
                end loop;
            elsif rising_edge(clk) then
                -- Default
                for i in 0 to 3 loop 
                    matrix_rd_en(i)(j) <= '0'; -- FIXED indexing
                end loop;
                tx_ctrl(j) <= '0';

                case state(j) is
                    when IDLE =>
                        if (dst_port(current_port(j))(j) = '1') then
                            selected_input(j) <= current_port(j);
			--matrix_rd_en(current_port(j))(j) <= '1'; -- FIXED indexing
                            state(j) <= WAIT_DATA;
                        else
                            matrix_rd_en(current_port(j))(j) <= '0'; -- FIXED indexing
                            current_port(j) <= (current_port(j) + 1) mod 4;
                        end if;

                    when WAIT_DATA =>
                        --matrix_rd_en(selected_input(j))(j) <= '1'; -- FIXED indexing
                        state(j) <= SENDING;
                        
                    when SENDING =>
                        data_out(j) <= fifo_matrix_out(selected_input(j), j)(7 downto 0);
                        tx_ctrl(j) <= '1';
                        if fifo_matrix_out(selected_input(j), j)(8) = '1' then -- EOF
                            state(j) <= IDLE;
                            current_port(j) <= (selected_input(j) + 1) mod 4;
                            matrix_rd_en(selected_input(j))(j) <= '0'; -- FIXED indexing
                        else
                            matrix_rd_en(selected_input(j))(j) <= '1'; -- FIXED indexing
                        end if;
                    when others =>
                        state(j) <= IDLE;
                end case;
            end if;
        end process;
    end generate;
end Behavioral;