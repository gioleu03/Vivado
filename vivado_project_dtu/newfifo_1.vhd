library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity newfifo_1 is
    port (  
        reset          : in std_logic; 
        wclk           : in std_logic; 
        rclk           : in std_logic; 
        write_enable   : in std_logic; 
        read_enable    : in std_logic; 
        fifo_occu_in   : out std_logic_vector(4 downto 0); 
        fifo_occu_out  : out std_logic_vector(4 downto 0); 
        write_data_in  : in std_logic_vector(8 downto 0); 
        read_data_out  : out std_logic_vector(8 downto 0) -- Changed to 9-bit to match crossbar expectations
    ); 
end newfifo_1; 

architecture Behavioral of newfifo_1 is

    -- Component declaration for Quartus RAM
    component ram
        PORT (
            clock      : IN STD_LOGIC := '1';
            data       : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdaddress  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            rden       : IN STD_LOGIC := '1';
            wraddress  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            wren       : IN STD_LOGIC := '0';
            q          : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    end component;

    signal ram_d_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_q_out : std_logic_vector(15 downto 0);

    -- Intermediate signals to fix "not globally static" error
    signal ram_rden_sig : std_logic;
    signal ram_wren_sig : std_logic;

    signal wptr : std_logic_vector(4 downto 0) := (others => '0');
    signal rptr : std_logic_vector(4 downto 0) := (others => '0');
    signal wptr_saved : std_logic_vector(4 downto 0) := (others => '0');

    signal rptr_s, wptr_saved_s : std_logic_vector(4 downto 0) := (others => '0');
    signal full, empty : std_logic;

begin

    -- Intermediate logic assignments
    ram_rden_sig <= read_enable and (not empty);
    ram_wren_sig <= write_enable and (not full);

    -- Bus adaptation
    ram_d_in(8 downto 0)  <= write_data_in;
    ram_d_in(15 downto 9) <= (others => '0');

    -- RAM Instance
    ram_inst : ram 
    PORT MAP (
        clock      => wclk,
        data       => ram_d_in,
        rdaddress  => rptr(3 downto 0),
        rden       => ram_rden_sig, -- FIXED: now using a simple signal
        wraddress  => wptr(3 downto 0),
        wren       => ram_wren_sig, -- FIXED: now using a simple signal
        q          => ram_q_out
    );

    -- Output Recovery (9 bits)
    read_data_out <= ram_q_out(8 downto 0);

    -- FULL / EMPTY Logic
    full  <= '1' when (wptr(4) /= rptr_s(4) and wptr(3 downto 0) = rptr_s(3 downto 0)) else '0';
    empty <= '1' when (rptr = wptr_saved_s) else '0';

    -- Write Process
    process(wclk, reset)
        variable v_wptr : unsigned(4 downto 0);
    begin
        if reset = '1' then
            wptr <= (others => '0');
            wptr_saved <= (others => '0');
            rptr_s <= (others => '0');
        elsif rising_edge(wclk) then
            rptr_s <= rptr; 

            if write_enable = '1' and full = '0' then
                v_wptr := unsigned(wptr) + 1;
                wptr <= std_logic_vector(v_wptr);
                if write_data_in(8) = '1' then
                    wptr_saved <= std_logic_vector(v_wptr);
                end if;
            elsif full = '1' and write_data_in(8) = '0' then
                wptr <= wptr_saved;
            end if;
        end if;
    end process;

    -- Read Process
    process(rclk, reset)
    begin
        if reset = '1' then
            rptr <= (others => '0');
            wptr_saved_s <= (others => '0');
        elsif rising_edge(rclk) then
            wptr_saved_s <= wptr_saved;

            if read_enable = '1' and empty = '0' then
                rptr <= std_logic_vector(unsigned(rptr) + 1);
            end if;
        end if;
    end process;

    fifo_occu_in  <= wptr;
    fifo_occu_out <= std_logic_vector(unsigned(wptr_saved_s) - unsigned(rptr));

end Behavioral;