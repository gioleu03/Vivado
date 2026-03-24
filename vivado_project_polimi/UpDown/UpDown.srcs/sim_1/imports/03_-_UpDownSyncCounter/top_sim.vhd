library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;

entity top_sim is
--  Port ( );
end top_sim;

architecture Behavioral of top_sim is

	constant LARGHEZZA_COUNTER : integer := 4;

	component UpDownSyncCounter is
		Generic(
			COUNT_WIDTH	: integer := 4
		);
		Port (
			reset		: in std_logic;
			clk			: in std_logic;

			inc_count	: in std_logic;
			dec_count	: in std_logic;

			count		: out std_logic_vector(COUNT_WIDTH-1 DOWNTO 0) -- Signed
			);
	end component;

	signal clk			: std_logic := '0';
	signal reset		: std_logic := '0';

	signal inc_count	: std_logic := '0';
	signal dec_count	: std_logic := '0';
	signal count		: std_logic_vector(LARGHEZZA_COUNTER-1 DOWNTO 0);

begin

	UpDownSyncCounter_inst : UpDownSyncCounter
		Generic Map(
			COUNT_WIDTH	=> LARGHEZZA_COUNTER
		)
		Port Map(
			reset		=> reset,
			clk			=> clk,

			inc_count	=> inc_count,
			dec_count	=> dec_count,

			count		=> count
			);


	clk <= not clk after 5 ns;

	process
	begin

		reset 		<= '1';
		inc_count 	<= '0';
		dec_count 	<= '0';
		wait for 15 ns;

		reset 		<= '0';

		wait until rising_edge(clk);

		inc_count 	<= '0';
		dec_count 	<= '1';
		wait until rising_edge(clk);

		inc_count 	<= '0';
		dec_count 	<= '1';
		wait until rising_edge(clk);

		inc_count 	<= '0';
		dec_count 	<= '0';
		wait until rising_edge(clk);

		inc_count 	<= '1';
		dec_count 	<= '0';
		wait until rising_edge(clk);

		inc_count 	<= '1';
		dec_count 	<= '0';
		wait until rising_edge(clk);

		inc_count 	<= '1';
		dec_count 	<= '0';
		wait until rising_edge(clk);

		inc_count 	<= '1';
		dec_count 	<= '0';
		wait until rising_edge(clk);

		inc_count 	<= '0';
		dec_count 	<= '0';

		wait for 3 ns;	-- Testo il reset asincrono

		reset		<= '1';

		wait until rising_edge(clk);

		reset		<= '0';

		wait;
	end process;
end Behavioral;
