----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2026 04:34:28 PM
-- Design Name: 
-- Module Name: newfifo - Behavioral
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

entity newfifo is
    Generic(
         FIFO_WIDTH : integer := 9; -- Updated to 9 to include EOF bit [cite: 32]
         FIFO_DEPTH : integer := 32
     ); 
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
end newfifo; 

architecture Behavioral of newfifo is

    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(8 downto 0);
        douta : OUT STD_LOGIC_VECTOR(8 downto 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(8 downto 0);
        doutb : OUT STD_LOGIC_VECTOR(8 downto 0)
      );
    END COMPONENT;

    -- Pointers
    signal wptr : std_logic_vector(4 downto 0) := (others => '0'); -- Current write address
    signal wptr_commit : std_logic_vector(4 downto 0) := (others => '0'); -- Validated write address
    signal rptr : std_logic_vector(4 downto 0) := (others => '0');
    
    -- Sync signals
    signal wptr_commit_s : std_logic_vector(4 downto 0) := (others => '0');
    signal wptr_commit_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal rptr_s : std_logic_vector(4 downto 0) := (others => '0');
    signal rptr_reg : std_logic_vector(4 downto 0) := (others => '0');

    signal empty, full : std_logic;
    signal wptr_checkpoint : std_logic_vector(4 downto 0) := (others => '0');
    signal is_writing_frame : std_logic := '0';

begin

    RAM : blk_mem_gen_0
        PORT MAP (
            clka  => wclk,
            ena   => write_enable,
            wea(0)=> write_enable,
            addra => wptr(3 downto 0), 
            dina  => write_data_in,
            
            clkb  => rclk,
            enb   => read_enable,
            web(0)=> '0',
            addrb => rptr(3 downto 0),
            dinb  => (others => '0'),
            doutb => read_data_out
        );
    
    -- Sincronizzazione rptr -> wclk domain
    process(wclk) begin
        if rising_edge(wclk) then
            rptr_reg <= rptr; 
            rptr_s <= rptr_reg; 
        end if;
    end process;

    -- Sincronizzazione wptr_commit -> rclk domain
    process(rclk) begin
        if rising_edge(rclk) then
            wptr_commit_reg <= wptr_commit; 
            wptr_commit_s <= wptr_commit_reg; 
        end if;
    end process;
    
    -- Status signals
    -- Full uses the live wptr to prevent overwriting
    full  <= '1' when (wptr(4) /= rptr_s(4) and wptr(3 downto 0) = rptr_s(3 downto 0)) else '0';
    -- Empty uses wptr_commit_s so reader only sees finished packets 
    empty <= '1' when (rptr = wptr_commit_s) else '0';
    
    -- WRITE PROCESS (wclk domain)
    process(wclk, reset) begin
        if reset = '1' then
            wptr <= (others => '0');
            wptr_commit <= (others => '0');
            wptr_checkpoint <= (others => '0');
            is_writing_frame <= '0';
        elsif rising_edge(wclk) then
            if write_enable = '1' then
                -- Store start of packet for potential rollback
                if is_writing_frame = '0' then
                    wptr_checkpoint <= wptr;
                    is_writing_frame <= '1';
                end if;

                if full = '0' then
                    wptr <= std_logic_vector(unsigned(wptr) + 1);
                    
                    -- COMMIT: Packet is valid if EOF bit (8) is received [cite: 32, 60]
                    if write_data_in(8) = '1' then
                        wptr_commit <= std_logic_vector(unsigned(wptr) + 1);
                        is_writing_frame <= '0';
                    end if;
                else
                    -- ROLLBACK: Overflow occurred, reset wptr to start of this packet
                    wptr <= wptr_checkpoint;
                    is_writing_frame <= '0';
                end if;
            end if;
        end if;
    end process;

    -- READ PROCESS (rclk domain)
    process(rclk, reset) begin
        if reset = '1' then
            rptr <= (others => '0');
        elsif rising_edge(rclk) then
            if read_enable = '1' and empty = '0' then
                rptr <= std_logic_vector(unsigned(rptr) + 1);
            end if;
        end if;
    end process;

    -- Output signals
    fifo_occu_in <= wptr;
    fifo_occu_out <= rptr;

end Behavioral;
