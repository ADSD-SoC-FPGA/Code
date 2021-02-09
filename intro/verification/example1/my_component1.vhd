---------------------------------------------------------------------------
-- Description:  VHDL file with simple computation and delay 
--               to illustrate verification process
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using 
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  January 20, 2021
-- Revision:     1.0
---------------------------------------------------------------------------
-- Copyright (c) 2021 Ross K. Snider
-- All rights reserved. Redistribution and use in source and binary forms 
-- are permitted provided that the above copyright notice and this paragraph 
-- are duplicated in all such forms and that any documentation, advertising 
-- materials, and other materials related to such distribution and use 
-- acknowledge that the software was developed by Montana State University 
-- (MSU).  The name of MSU may not be used to endorse or promote products 
-- derived from this software without specific prior written permission.
-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. 
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;    
use ieee.std_logic_unsigned.all;

entity my_component1 is
	generic (
		MY_WIDTH : natural);
	port (
		my_clk    : in  std_logic;
		my_input  : in  std_logic_vector(MY_WIDTH-1 downto 0);
		my_output : out std_logic_vector(MY_WIDTH-1 downto 0)
	);
end my_component1;

architecture my_architecture of my_component1 is

	-----------------------------------------------
	-- Internal Signals
	-----------------------------------------------
	signal my_result         : std_logic_vector(MY_WIDTH-1 downto 0);
	signal my_delay_signal_1 : std_logic_vector(MY_WIDTH-1 downto 0);
	signal my_delay_signal_2 : std_logic_vector(MY_WIDTH-1 downto 0);

begin
 	------------------------------------------------
	-- Computation (simply add 1)
	------------------------------------------------ 
	my_add1_process : process(my_clk)
	begin
		if rising_edge(my_clk) then
			my_result <= my_input + 1;
		end if;
	end process;
	
	----------------------------------------------------------
	-- Delay 3 Additional Clock Cycles to create a component 
	-- with a longer latency
	----------------------------------------------------------
	my_delay_process : process(my_clk)
	begin
		if rising_edge(my_clk) then
			my_delay_signal_1 <= my_result;
			my_delay_signal_2 <= my_delay_signal_1;
			my_output         <= my_delay_signal_2;
		end if;
	end process;

end my_architecture;
