library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.switch_types.all;

entity crossbar_tb is
end crossbar_tb;

architecture sim of crossbar_tb is

    -- Component Declaration
    component crossbar_1
        Port (
            clk      : in std_logic;
            reset    : in std_logic;
            data_in  : in ninebit_array;
            dst_port : in sel_array;
            data_out : out eightbit_array;
            tx_ctrl  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signal Declarations con inizializzazione VHDL-2008
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal data_in  : ninebit_array := (others => (others => '0'));
    signal dst_port : sel_array     := (others => (others => '0'));
    signal data_out : eightbit_array;
    signal tx_ctrl  : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Unit Under Test
    uut: crossbar_1
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
        -- Reset iniziale
        reset <= '1';
        data_in  <= (others => (others => '0'));
        dst_port <= (others => (others => '0'));
        wait for 100 ns;
        
        -- Sincronizzazione sul fronte di discesa (Safe zone)
        wait until falling_edge(clk);
        reset <= '0';
        wait for CLK_PERIOD * 2;

        -- Test Case 1: Port 0 manda un pacchetto a Output 1
        wait until falling_edge(clk);
        dst_port(0) <= "0100"; 
        data_in(0)  <= '0' & x"AA"; -- Byte 1
        
        wait until falling_edge(clk);
        data_in(0)  <= '0' & x"BB"; -- Byte 2
        
        wait until falling_edge(clk);
        data_in(0)  <= '1' & x"CC"; -- Byte 3 (EOF = '1')
        
        wait until falling_edge(clk);
        -- Pulizia segnali dopo l'invio
        dst_port(0) <= "0000";
        data_in(0)  <= (others => '0');

        -- Lascia tempo alla Crossbar di svuotare la FIFO
        wait for 500 ns;
        
        report "Simulazione completata con successo!";
        --std.env.stop; -- Comando VHDL-2008 per fermare la simulazione
        wait;
    end process;

end sim;