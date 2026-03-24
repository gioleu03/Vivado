library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_tb is
end entity;

architecture Behavioral of FIFO_tb is

    -- Component under test (CUT)
    component FIFO
        Generic (
            FIFO_WIDTH : integer := 8;
            FIFO_DEPTH : integer := 16
        );
        Port (
            reset : in std_logic;
            clk : in std_logic;

            din : in std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
            dout : out std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);

            rd_en : in std_logic;
            wr_en : in std_logic;

            full : out std_logic;
            empty : out std_logic
        );
    end component;

    -- Signals for simulation
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';

    signal din     : std_logic_vector(7 downto 0) := (others => '0');
    signal dout    : std_logic_vector(7 downto 0);

    signal rd_en   : std_logic := '0';
    signal wr_en   : std_logic := '0';

    signal full    : std_logic;
    signal empty   : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the FIFO component
    uut: FIFO
        generic map (
            FIFO_WIDTH => 8,
            FIFO_DEPTH => 16
        )
        port map (
            reset => reset,
            clk => clk,

            din => din,
            dout => dout,

            rd_en => rd_en,
            wr_en => wr_en,

            full => full,
            empty => empty
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Reset the FIFO
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Write data into FIFO
        for i in 0 to 15 loop
            din <= std_logic_vector(to_unsigned(i, 8));
            wr_en <= '1';
            wait for CLK_PERIOD;
            wr_en <= '0';
            wait for CLK_PERIOD;
        end loop;

        -- Attempt to write when FIFO is full
        wr_en <= '1';
        din <= x"FF";
        wait for CLK_PERIOD;
        wr_en <= '0';
        wait for CLK_PERIOD;

        -- Read data from FIFO
        for i in 0 to 15 loop
            rd_en <= '1';
            wait for CLK_PERIOD;
            rd_en <= '0';
            wait for CLK_PERIOD;
        end loop;

        -- Attempt to read when FIFO is empty
        rd_en <= '1';
        wait for CLK_PERIOD;
        rd_en <= '0';

        wait;
    end process;

end Behavioral;



