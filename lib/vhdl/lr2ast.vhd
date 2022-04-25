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
-- Design Name:      lr2ast.vhd
--
-- Description:      Converts the individual Left/Right audio channels
--                   back to the Avalon Streaming (Avalon-ST) interface
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Note: We have access to the avalon sink signals,
--       so just use them to generate the avalon source signals
entity lr2ast is
  port (
    clk                   : in    std_logic;
    avalon_sink_channel   : in    std_logic;
    avalon_sink_valid     : in    std_logic;
    data_left             : in    std_logic_vector(23 downto 0);
    data_right            : in    std_logic_vector(23 downto 0);
    avalon_source_data    : out   std_logic_vector(23 downto 0);
    avalon_source_channel : out   std_logic;
    avalon_source_valid   : out   std_logic
  );
end entity lr2ast;

architecture behavioral of lr2ast is

begin

  samples_to_avalon_streaming : process (clk) is
  begin

    if rising_edge(clk) then
      avalon_source_valid <= '0';
      if avalon_sink_valid = '1' then

        case avalon_sink_channel is

          when '0' =>
            avalon_source_data    <= data_left;
            avalon_source_channel <= '0';
            avalon_source_valid   <= '1';

          when '1' =>
            avalon_source_data    <= data_right;
            avalon_source_channel <= '1';
            avalon_source_valid   <= '1';

          when others =>
            null;

        end case;

      end if;
    end if;

  end process samples_to_avalon_streaming;

end architecture behavioral;
