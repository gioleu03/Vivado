library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;

entity top_sim_mealy is
--  Port ( );
end top_sim_mealy;

architecture Behavioral of top_sim_mealy is

	component MealyEdgeDetector is
		Port (
			clk		: in std_logic;
			reset 	: in std_logic;

			signal_in	: in std_logic;
			upEdge		: out std_logic;
			downEdge	: out std_logic
		);
	end component;

	signal clk			: std_logic := '0';
	signal reset		: std_logic := '0';

	signal signal_in		: std_logic := '0';
	signal upEdge, downEdge	: std_logic;

begin

	MealyEdgeDetector_inst : MealyEdgeDetector
		Port Map(
			reset		=> reset,
			clk			=> clk,

			signal_in	=> signal_in,
			upEdge		=> upEdge,
			downEdge	=> downEdge
			);


	clk <= not clk after 5 ns;

	process
	begin

		reset 		<= '1';
		signal_in 	<= '0';
		wait for 15 ns;

		reset 		<= '0';

		wait until rising_edge(clk);

		signal_in <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		signal_in <= '0';
		wait until rising_edge(clk);
		signal_in <= '1';
		wait until rising_edge(clk);
		signal_in <= '0';
		wait until rising_edge(clk);
		signal_in <= '1';
		wait until rising_edge(clk);
		signal_in <= '0';

		wait;
	end process;
end Behavioral;
