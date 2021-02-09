---------------------------------------------------------------------------
-- Description:  VHDL Test bench file for my_component.vhd
--               Reads file input.txt and produces file output.txt
--               Sends a test vector into my_input every clock cycle
--               Writes my_output every clock cycle
--               Note: Constant W_WIDTH in this file must match the
--                     the word length of the test vectors in input.txt 
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using 
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  January 18, 2021
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
-------------------------------------------------------------------------------
-- Use the appropriate library packages
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;    -- IEEE standard for digital logic values
use ieee.numeric_std.all;       -- arithmetic functions for vectors
use std.textio.all;             -- Needed for file functions
use ieee.std_logic_textio.all;  -- Needed for std_logic_vector
use work.txt_util.all;          -- I don't know who created the txt_util.vhd 
                                -- package, but I got it from
                                -- https://www.ece.tufts.edu/ee/126/misc/text_util.vhd
 
-------------------------------------------------------------------------------
-- Entity of this test bench file
-- (It's a blank entity)
------------------------------------------------------------------------------- 
entity my_component1_tb is
   -- nothing here to see, i.e. no signal i/o
end my_component1_tb;
 
-------------------------------------------------------------------------------
-- Architecture of this test bench file
-- Note: We don't care that this VHDL is not synthesizable.
------------------------------------------------------------------------------- 
architecture behavioral of my_component1_tb is
 
    -----------------------------------------------------------------------------
    -- Internal Signals
    -- Note: W_WIDTH must match the word length of the test vectors in input.txt
    --       The clock period is arbitrary
    -----------------------------------------------------------------------------
    constant W_WIDTH : natural := 16;          -- width of input signal for DUT
    constant clk_half_period : time := 10 ns;  -- clk frequency is 1/(clk_half_period * 2)
    signal clk : std_logic := '0';             -- clock starts at zero
    signal input_signal  : std_logic_vector(W_WIDTH-1 downto 0) := (others => '0');
    signal output_signal : std_logic_vector(W_WIDTH-1 downto 0) := (others => '0');

    -----------------------------------------------------------------------------
    -- Declaration for Device Under Test (DUT)
    -- Declare the component you are testing here 
    -- (e.g. my_component.vhd)
    -----------------------------------------------------------------------------
    component my_component1 is
       generic (
            MY_WIDTH : natural);
        port (
            my_clk    : in  std_logic;
            my_input  : in  std_logic_vector(MY_WIDTH-1 downto 0);
            my_output : out std_logic_vector(MY_WIDTH-1 downto 0)
        );
    end component my_component1;

begin
    -----------------------------------------------------------------------------
    -- Instantiate the DUT
    -----------------------------------------------------------------------------
    DUT : my_component1
    generic map (
        MY_WIDTH => W_WIDTH)
    port map (
        my_clk    => clk,
        my_input  => input_signal,
        my_output => output_signal
    );
 
    -----------------------------------------------------------------------------
    -- Create Clock
    -----------------------------------------------------------------------------
    clk <= not clk after clk_half_period;
 
    ---------------------------------------------------------------------------
    -- File Reading and Writing Process
    ---------------------------------------------------------------------------
    process
        file read_file_pointer   : text;
        file write_file_pointer  : text;
        variable line_in         : line;
        variable line_out        : line;
        variable input_string    : string(W_WIDTH downto 1);
        variable input_vector    : std_logic_vector(W_WIDTH-1 downto 0);
    begin
        -- Open Files
        file_open(read_file_pointer,  "input.txt",  read_mode);
        file_open(write_file_pointer, "output.txt", write_mode);
        while not endfile(read_file_pointer) loop -- Read input file until end of file
            -- Read test vectors
            readline(read_file_pointer, line_in); -- Read a line from input file
            read(line_in, input_string);          -- convert line to a string
            input_vector := to_std_logic_vector(input_string); -- convert string to std_logic_vector
            report "line in = " & line_in.all & " value in = " & integer'image(to_integer(unsigned(input_vector)));  -- display what is being read in
            input_signal <= input_vector;  -- assign to the input_signal going into the DUT
            -- Write results
            write(line_out, output_signal, right, W_WIDTH);
            writeline(write_file_pointer, line_out);
            -- Read and Write on rising clock edge
            wait until rising_edge(clk);
        end loop; 
        -- Close Files
        file_close(read_file_pointer);
        file_close(write_file_pointer);
        wait; -- we are done so don't read the file again
   end process;
 
end behavioral;
