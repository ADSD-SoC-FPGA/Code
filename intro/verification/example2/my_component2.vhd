---------------------------------------------------------------------------
-- Description:  VHDL file with Quartus ROM IP, computation, and delay 
--               to illustrate verification process
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using 
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  January 27, 2021
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

entity my_component2 is
	generic (
        MY_ROM_A_W    : natural;   -- Width of ROM Address bus 
        MY_ROM_Q_W    : natural;   -- Width of ROM output 
        MY_ROM_Q_F    : natural;   -- Number of fractional bits in ROM output 
		MY_WORD_W     : natural;   -- Width of input signal
        MY_WORD_F     : natural;   -- Number of fractional bits in input signal
		MY_DELAY      : natural);  -- The amount to delay the product before sending out of component
	port (
		my_clk         : in  std_logic;
        my_rom_address : in  std_logic_vector(MY_ROM_A_W-1 downto 0);
		my_input       : in  std_logic_vector(MY_WORD_W-1  downto 0);
        my_rom_value   : out std_logic_vector(MY_ROM_Q_W-1 downto 0);
		my_output      : out std_logic_vector(MY_WORD_W-1  downto 0));
end my_component2;

architecture my_architecture of my_component2 is

	-----------------------------------------------
	-- Declarations
	-----------------------------------------------
    component ROM
        PORT (
            address	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock	: IN STD_LOGIC  := '1';
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
    end component;

	-----------------------------------------------
	-- Internal Signals
	-----------------------------------------------
    signal my_input_delayed_1 : std_logic_vector(MY_WORD_W-1 downto 0);
    signal my_input_delayed_2 : std_logic_vector(MY_WORD_W-1 downto 0);
    signal rom_value          : std_logic_vector(MY_ROM_Q_W-1 downto 0);
	signal my_product         : std_logic_vector(MY_WORD_W+MY_ROM_Q_W-1 downto 0);
	signal my_product_trimmed : std_logic_vector(MY_WORD_W-1 downto 0);

    -- delay array
    type my_delay_array is array (natural range <>) of std_logic_vector(MY_WORD_W-1 downto 0);
    signal delay_vector : my_delay_array(MY_DELAY-2 downto 0);
begin
 
    ------------------------------------------------
	-- Instantiate ROM
	------------------------------------------------ 
    ROM_inst : ROM PORT MAP (
		address	 => my_rom_address,
		clock	 => my_clk,
		q	     => rom_value);

    my_rom_value <= rom_value;  -- send the ROM value directly out of component

    ----------------------------------------------------------------
	-- Computation (multiplication) after aligning the input signal
    -- so that it aligns with the two clock cycle ROM latency
	---------------------------------------------------------------- 
	my_process : process(my_clk)
	begin
		if rising_edge(my_clk) then
            my_input_delayed_1 <= my_input;
            my_input_delayed_2 <= my_input_delayed_1;
			my_product         <= my_input_delayed_2 * rom_value;  
		end if;
	end process;

	my_product_trimmed <= my_product(MY_WORD_W + MY_ROM_Q_F - 1 downto MY_ROM_Q_F);  -- keep the output with the same W & F as the input.

    ------------------------------------------------
	-- Delay the trimmed product by MY_DELAY
	------------------------------------------------ 
	my_delay_process : process(my_clk)
	begin
        if MY_DELAY = 0
            my_output <= my_product_trimmed;
		elsif rising_edge(my_clk) then
            if MY_DELAY = 1
                my_output <= my_product_trimmed;
            elsif MY_DELAY = 2
                delay_vector(0) <= my_product_trimmed;
                my_output <= delay_vector(0);
            elsif MY_DELAY >= 3
                delay_vector(0) <= my_product_trimmed;
                for i in 0 to MY_DELAY-3 loop
                    delay_vector(i+1) <= delay_vector(i);
                end loop;
                my_output <=  <= delay_vector(MY_DELAY-2);
            end if;
		end if;
	end process;

end my_architecture;
