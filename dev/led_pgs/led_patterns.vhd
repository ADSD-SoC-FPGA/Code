-- SPDX-License-Identifier: MIT
-- Copyright (c) 2020 Ross K. Snider.  All rights reserved.
----------------------------------------------------------------------------
-- Description:  VHDL Entity for the LED_patterns component
--               Entity signal definitions
----------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  September 17, 2020
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
----------------------------------------------------------------------------

-- Library and Package Statements

entity LED_patterns is
    port(
        clk             : in  std_logic;                         -- system clock
        reset           : in  std_logic;                         -- system reset (assume active high, change at top level if needed)
        PB              : in  std_logic;                         -- Pushbutton to change state (assume active high, change at top level if needed)
        SW              : in  std_logic_vector(3 downto 0);      -- Switches that determine the next state to be selected
        HPS_LED_control : in  std_logic;                         -- Software is in control when asserted (=1)
        SYS_CLKs_sec    : in  std_logic_vector(31 downto 0);     -- Number of system clock cycles in one second
        Base_rate       : in  std_logic_vector(7 downto 0);      -- base transition period in seconds, fixed-point data type (W=8, F=4).
        LED_reg         : in  std_logic_vector(7 downto 0);      -- LED register
        LED             : out std_logic_vector(7 downto 0)       -- LEDs on the DE10-Nano board
    );
end entity LED_patterns;

architecture my_architecture of LED_patterns is

	-- Signal Declarations
	-- Component Declarations

begin
 	
	-- Concurrent Statements
	
end my_architecture;
