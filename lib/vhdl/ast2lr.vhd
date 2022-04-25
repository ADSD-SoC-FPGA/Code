-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Authors:          Ross K. Snider, Trevor Vannoy
-- Company:          Montana State University
-- Create Date:      April 20, 2022
-- Revision:         1.0
-- License: MIT      (opensource.org/licenses/MIT)
-- Target Device(s): Terasic D1E0-Nano Board
-- Tool versions:    Quartus Prime 20.1
---------------------------------------------------------------------------
--
-- Design Name:      ast2lr.vhd
--
-- Description:      Converts the Avalon Streaming (Avalon-ST) interface
--                   to individual Left/Right audio channels
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ast2lr is
  port (
    clk                 : in    std_logic;
    avalon_sink_data    : in    std_logic_vector(23 downto 0);
    avalon_sink_channel : in    std_logic;
    avalon_sink_valid   : in    std_logic;
    data_left           : out   std_logic_vector(23 downto 0);
    data_right          : out   std_logic_vector(23 downto 0)
  );
end entity ast2lr;

architecture behavioral of ast2lr is

begin

  avalon_streaming_to_samples : process (clk) is
  begin

    if rising_edge(clk) then
      if avalon_sink_valid = '1' then

        case avalon_sink_channel is

          when '0' =>
            data_left <= avalon_sink_data;

          when '1' =>
            data_right <= avalon_sink_data;

          when others =>
            null;

        end case;

      end if;
    end if;

  end process avalon_streaming_to_samples;

end architecture behavioral;
