-- SPDX-License-Identifier: MIT
-- Copyright (c) 2020 Ross K. Snider.  All rights reserved.
----------------------------------------------------------------------------
-- Description:  VHDL Entity for the HPS_LED_patterns component
--               Entity signal definitions
----------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  September 30, 2021
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
----------------------------------------------------------------------------

-- Library and Package Statements

entity HPS_LED_patterns is
    port(
        clk              : in  std_logic;                     -- system clock
        reset            : in  std_logic;                     -- system reset (assume active high, change at top level if needed)
 		    avs_s1_read	     : in  std_logic;                     -- Avalon read control signal
		    avs_s1_write 	   : in  std_logic;                     -- Avalon write control signal
		    avs_s1_address 	 : in  std_logic_vector(1 downto 0);  -- Avalon address;  Note: width determines the number of registers created by Platform Designer
		    avs_s1_readdata	 : out std_logic_vector(31 downto 0); -- Avalon read data bus 
		    avs_s1_writedata : in  std_logic_vector(31 downto 0); -- Avalon write data bus 
		    PB               : in  std_logic;                     -- Pushbutton to change state (assume active high, change at top level if needed)  (export in Platform Designer)
        SW               : in  std_logic_vector(3 downto 0);  -- Switches that determine the next state to be selected  (export in Platform Designer)
        LED              : out std_logic_vector(7 downto 0)   -- LEDs on the DE10-Nano board (export in Platform Designer)
    );
end entity HPS_LED_patterns;

architecture my_architecture of HPS_LED_patterns is

	-- Signal Declarations
	-- Component Declarations (including LED_patterns)

begin
 	
	-- Concurrent Statements and processes (including Avalon bus interfacing and register creation)
	
end my_architecture;
