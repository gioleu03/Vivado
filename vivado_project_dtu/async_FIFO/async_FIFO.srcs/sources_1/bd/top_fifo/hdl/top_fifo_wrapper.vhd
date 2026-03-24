--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Sun Mar  1 14:51:55 2026
--Host        : DESKTOP-LB7VOFM running 64-bit major release  (build 9200)
--Command     : generate_target top_fifo_wrapper.bd
--Design      : top_fifo_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity top_fifo_wrapper is
end top_fifo_wrapper;

architecture STRUCTURE of top_fifo_wrapper is
  component top_fifo is
  end component top_fifo;
begin
top_fifo_i: component top_fifo
 ;
end STRUCTURE;
