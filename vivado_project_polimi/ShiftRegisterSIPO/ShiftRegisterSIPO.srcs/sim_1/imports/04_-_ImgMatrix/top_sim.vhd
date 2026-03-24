library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity top_sim is
--  Port ( );
end top_sim;

architecture Behavioral of top_sim is

    constant clk_period : time := 10ns;
    constant IMG_DIM_POW2  : integer := 2;

    component img_matrix is
        Generic (
            IMG_DIM_POW2 : integer := 2
        );
        Port (
            clk   : in std_logic;
            reset : in std_logic;

            in_red     : in  std_logic_vector(7 DOWNTO 0);
            in_green   : in  std_logic_vector(7 DOWNTO 0);
            in_blue    : in  std_logic_vector(7 DOWNTO 0);
            in_x_addr  : in  std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0);
            in_y_addr  : in  std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0);

            out_gray   : out std_logic_vector(7 DOWNTO 0);
            out_x_addr : in  std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0);
            out_y_addr : in  std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0)
        );
    end component;

    signal clk, reset : std_logic := '0';

    signal in_x_addr_int, in_y_addr_int : integer := (2**IMG_DIM_POW2)-1;
    signal out_x_addr_int, out_y_addr_int : integer := (2**IMG_DIM_POW2)-1;

    signal in_x_addr, in_y_addr : std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0);
    signal out_x_addr, out_y_addr : std_logic_vector(IMG_DIM_POW2-1 DOWNTO 0);

    signal in_red_int, in_green_int, in_blue_int : integer := (2**IMG_DIM_POW2)-1;
    signal in_red, in_green, in_blue, out_gray : std_logic_vector(7 DOWNTO 0);


begin

    clk <= not clk after clk_period/2;

    DUT : img_matrix
        Generic Map (
            IMG_DIM_POW2 => IMG_DIM_POW2
        )
        Port Map (
            clk   => clk,
            reset => reset,

            in_red     => in_red,
            in_green   => in_green,
            in_blue    => in_blue,
            in_x_addr  => in_x_addr,
            in_y_addr  => in_y_addr,

            out_gray   => out_gray,
            out_x_addr => out_x_addr,
            out_y_addr => out_y_addr
        );

    in_x_addr <= std_logic_vector(to_unsigned(in_x_addr_int, in_x_addr'LENGTH));
    in_y_addr <= std_logic_vector(to_unsigned(in_y_addr_int, in_y_addr'LENGTH));
    out_x_addr <= std_logic_vector(to_unsigned(out_x_addr_int, out_x_addr'LENGTH));
    out_y_addr <= std_logic_vector(to_unsigned(out_y_addr_int, out_y_addr'LENGTH));

    in_red <= std_logic_vector(to_unsigned(in_red_int, in_red'LENGTH));
    in_green <= std_logic_vector(to_unsigned(in_green_int, in_green'LENGTH));
    in_blue <= std_logic_vector(to_unsigned(in_blue_int, in_blue'LENGTH));


	process
	begin
        reset <= '1';

        in_x_addr_int <= 0;
        in_y_addr_int <= 0;
        in_red_int <= 0;
        in_green_int <= 0;
        in_blue_int <= 0;

        out_x_addr_int <= 0;
        out_y_addr_int <= 0;

        for I in 0 TO 5 loop
            wait until rising_edge(clk);
        end loop;

        reset <= '0';

        for I in 0 TO 5 loop
            wait until rising_edge(clk);
        end loop;



        while (in_x_addr_int < 2**IMG_DIM_POW2-1) loop
            while (in_y_addr_int < 2**IMG_DIM_POW2-1) loop

                wait until rising_edge(clk);

                in_x_addr_int <= in_x_addr_int + 1;
                in_y_addr_int <= in_y_addr_int + 1;

                in_red_int <= (in_x_addr_int + 1) * 5 + (in_y_addr_int + 1) * 2;
                in_green_int <= (in_x_addr_int + 1) * 5 + (in_y_addr_int + 1) * 2;
                in_blue_int <= (in_x_addr_int + 1) * 5 + (in_y_addr_int + 1) * 2;

                wait until rising_edge(clk);

            end loop;
        end loop;

        wait until rising_edge(clk);
        wait until rising_edge(clk);

        while (out_x_addr_int < 2**IMG_DIM_POW2-1) loop
            while (out_y_addr_int < 2**IMG_DIM_POW2-1) loop

                wait until rising_edge(clk);

                out_x_addr_int <= out_x_addr_int + 1;
                out_y_addr_int <= out_y_addr_int + 1;

                wait until rising_edge(clk);

            end loop;
        end loop;

        wait;

    end process;

end Behavioral;
