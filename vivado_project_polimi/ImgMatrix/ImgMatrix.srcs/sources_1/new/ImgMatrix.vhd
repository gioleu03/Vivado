----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2024 10:35:11
-- Design Name: 
-- Module Name: ImgMatrix - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity img_matrix is
    Generic(
        IMG_DIM_POW2 : integer :=2
        );
    Port (
        clk :in std_logic;
        reset :in std_logic;
        
        in_red : in std_logic_vector (7 DOWNTO 0);
        in_green : in std_logic_vector (7 DOWNTO 0);
        in_blue : in std_logic_vector (7 DOWNTO 0);
        in_x_addr : in std_logic_vector (IMG_DIM_POW2-1 DOWNTO 0);
        in_y_addr : in std_logic_vector (IMG_DIM_POW2-1 DOWNTO 0);
        
        out_gray : out std_logic_vector (7 DOWNTO 0);
        out_x_addr : in std_logic_vector (IMG_DIM_POW2-1 DOWNTO 0);
        out_y_addr : in std_logic_vector (IMG_DIM_POW2-1 DOWNTO 0)
         );
end img_matrix;

architecture Behavioral of img_matrix is
    component reg_matrix is  
        Port ( 
        clk : in std_logic;
        reset : in std_logic;
        D: in std_logic_vector;
        Q: out std_logic_vector 
        );
    end component;
 
-- type square is array (3 DOWNTO 0) of std_logic_vector(3 DOWNTO 0);
-- signal matrix: square; 
signal redgreen_sum, tot_sum, in_gray, out_mux, new_gray, final_in, final_out: std_logic_vector (7 DOWNTO 0);
type img_type is array (0 TO 2**IMG_DIM_POW2-1, 0 TO 2**IMG_DIM_POW2-1) of std_logic_vector(7 DOWNTO 0);
signal input_reg_img, output_reg_img : img_type;
 
begin
        redgreen_sum <= std_logic_vector(unsigned(in_red) + unsigned(in_green));
        tot_sum <= std_logic_vector(unsigned(redgreen_sum) + unsigned(in_blue));
        in_gray <= std_logic_vector(unsigned(tot_sum) / 3);
      
        LOOP_GEN_1: for i in in_x_addr'RANGE generate --3 DOWNTO 0 generate -- in_x_addr'RANGE generate   --IMG_DIM_POW2-1 DOWNTO 0 generate
            LOOP_GEN_2: for j in in_y_addr'RANGE generate --IMG_DIM_POW2-1 DOWNTO 0 generate
                reg_matrix_inst: reg_matrix
                    Port Map(
                    clk => clk, 
                    reset => reset,
                    D => out_mux,
                    Q => new_gray 
                    );
                    
                 out_mux <= in_gray when (unsigned(in_x_addr) = i) and (unsigned(in_y_addr) = j) else
                            new_gray;                                                                           
            end generate;
         end generate;
         
           LOOP_GEN_3: for i in out_x_addr'RANGE generate --3 DOWNTO 0 generate -- in_x_addr'RANGE generate   --IMG_DIM_POW2-1 DOWNTO 0 generate
            LOOP_GEN_4: for j in out_y_addr'RANGE generate --IMG_DIM_POW2-1 DOWNTO 0 generate
               
                 
            end generate;
         end generate;   
         
         reg_matrix_inst: reg_matrix
                    Port Map(
                    clk => clk, 
                    reset => reset,
                    D => final_in,
                    Q => final_out 
                    );    
                    
           
 end Behavioral;
