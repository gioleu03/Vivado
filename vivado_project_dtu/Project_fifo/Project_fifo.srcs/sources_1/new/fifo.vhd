----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2026 01:07:26 PM
-- Design Name: 
-- Module Name: fifo - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
    port (  
        reset          : in std_logic; 
        wclk           : in std_logic; 
        rclk           : in std_logic; 
        write_enable   : in std_logic; 
        read_enable    : in std_logic; 
        fifo_occu_in   : out std_logic_vector(4 downto 0); 
        fifo_occu_out  : out std_logic_vector(4 downto 0); 
        write_data_in  : in std_logic_vector(8 downto 0); -- Bit 8 is EOF/Commit
        read_data_out  : out std_logic_vector(8 downto 0) 
    ); 
end fifo; 

architecture Behavioral of fifo is

    -- The RAM needs to store the FULL 9 bits to keep your EOF marker!
    COMPONENT blk_mem_gen_0
    PORT (
        clka  : IN STD_LOGIC;
        wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        dina  : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- Fixed to 9 bits
        clkb  : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0) -- Fixed to 9 bits
    );
    END COMPONENT;

    signal wptr, rptr       : unsigned(4 downto 0) := (others => '0');
    signal wptr_gray        : std_logic_vector(4 downto 0);
    signal rptr_gray        : std_logic_vector(4 downto 0);
    
    -- Synchronizer registers
    signal wptr_gray_sync1, wptr_gray_sync2 : std_logic_vector(4 downto 0) := (others => '0');
    signal rptr_gray_sync1, rptr_gray_sync2 : std_logic_vector(4 downto 0) := (others => '0');

    signal wptr_saved : unsigned(4 downto 0) := (others => '0');
    signal full, empty : std_logic;

    -- Helper function for Binary to Gray conversion
    function binary_to_gray(b : unsigned) return std_logic_vector is
    begin
        return std_logic_vector(b xor ("0" & b(b'high downto 1)));
    end function;

begin

    -- RAM Instance (Ensure your IP Core is configured for 9-bit width)
    RAM_INST : blk_mem_gen_0
    PORT MAP (
        clka  => wclk,
        wea(0)=> (write_enable and (not full)),
        addra => std_logic_vector(wptr(3 downto 0)),
        dina  => write_data_in,
        clkb  => rclk,
        addrb => std_logic_vector(rptr(3 downto 0)),
        doutb => read_data_out
    );

    -- 1. GRAY ENCODING (Safe for Crossing Clock Domains)
    wptr_gray <= binary_to_gray(wptr);
    rptr_gray <= binary_to_gray(rptr);

    -- 2. SYNCHRONIZATION (Double Flip-Flop)
    process(wclk) begin
        if rising_edge(wclk) then
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1; -- rptr now safe in wclk domain
        end if;
    end process;

    process(rclk) begin
        if rising_edge(rclk) then
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1; -- wptr now safe in rclk domain
        end if;
    end process;

    -- 3. FLAG LOGIC (Using Gray Code comparisons)
    -- Full: MSB and 2nd MSB different, others same
    full  <= '1' when (wptr_gray(4) /= rptr_gray_sync2(4) and 
                       wptr_gray(3) /= rptr_gray_sync2(3) and 
                       wptr_gray(2 downto 0) = rptr_gray_sync2(2 downto 0)) else '0';
                       
    -- Empty: Pointers are identical
    empty <= '1' when (rptr_gray = wptr_gray_sync2) else '0';

    -- 4. WRITE CONTROL (With Rollback/Commit)
    process(wclk, reset) begin
        if reset = '1' then
            wptr <= (others => '0');
            wptr_saved <= (others => '0');
        elsif rising_edge(wclk) then
            if write_enable = '1' and full = '0' then
                wptr <= wptr + 1;
                -- If bit 8 is '1', this is the end of a valid packet
                if write_data_in(8) = '1' then
                    wptr_saved <= wptr + 1;
                end if;
            elsif full = '1' and write_data_in(8) = '0' then
                -- Rollback: Reset pointer to the last saved "Good" state
                wptr <= wptr_saved;
            end if;
        end if;
    end process;

    -- 5. READ CONTROL
    process(rclk, reset) begin
        if reset = '1' then
            rptr <= (others => '0');
        elsif rising_edge(rclk) then
            if read_enable = '1' and empty = '0' then
                rptr <= rptr + 1;
            end if;
        end if;
    end process;

    fifo_occu_in  <= std_logic_vector(wptr);
    fifo_occu_out <= std_logic_vector(rptr);

end Behavioral;

