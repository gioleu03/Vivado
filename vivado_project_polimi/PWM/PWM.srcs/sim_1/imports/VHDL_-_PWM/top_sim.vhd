library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity top_sim is
--  Port ( );
end top_sim;

architecture Behavioral of top_sim is
	
	constant clk_period : time := 10ns;
	
	component PWM is
		Port (
			reset 	: in std_logic;
			clk		: in std_logic;

			t_on	: in std_logic_vector(8-1 DOWNTO 0);	-- UNSIGNED
			t_total	: in std_logic_vector(8-1 DOWNTO 0);	-- UNSIGNED

			pwm_out	: out std_logic
		);
	end component;
	
	signal reset, clk		: std_logic := '1';

	signal t_on, t_total	: std_logic_vector(8-1 DOWNTO 0);	-- UNSIGNED
	signal t_on_integer		: integer; 
	signal t_total_integer 	: integer;
				
	signal pwm_out			: std_logic;
begin
	
	PWM_inst : PWM
		Port Map(
			reset 	=> reset,
			clk		=> clk,

			t_on	=> t_on,
			t_total	=> t_total,

			pwm_out	=> pwm_out
		);
	
	clk <= not clk after clk_period / 2;
	t_on 	<= std_logic_vector(to_unsigned(t_on_integer, t_on'LENGTH));
	t_total <= std_logic_vector(to_unsigned(t_total_integer, t_total'LENGTH));
	
	process
	begin
		
		reset 	<= '1';
		t_on_integer	<= 3;
		t_total_integer	<= 3;
		
		wait for 15ns;
		
		reset <= '0';
		
		for I in 0 TO 11 loop
			wait until rising_edge(clk);
		end loop;
		
		t_on_integer	<= 2;
		
		for I in 0 TO 11 loop
			wait until rising_edge(clk);
		end loop;
		
		wait;
		
	end process;
	
end Behavioral;
