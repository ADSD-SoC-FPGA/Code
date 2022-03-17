-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  March 17, 2022
-- Revision:     1.0
---------------------------------------------------------------------------
-- Description:  Signal delay component with arbitrary signal size
--               and delay.  Signal type is std_logic_vector.
--               Note: If connecting to std_logic (signal_width = 1)
--               you will need to add index 0 in port map to
--               standar_logic_vectors, i.e.
--               port map (
--                   clk               => sys_clk,
--                   signal_input(0)   => ad1939_adc_abclk,
--                   signal_delayed(0) => ad1939_dac_dbclk
--               );
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity delay_signal is
  generic (
    signal_width : natural; -- width of signal in bits
    signal_delay : natural  -- delay of signal in clock cycles
  );
  port (
    clk            : in    std_logic;
    signal_input   : in    std_logic_vector(signal_width - 1  downto 0);
    signal_delayed : out   std_logic_vector(signal_width - 1  downto 0)
  );
end entity delay_signal;

architecture delay_architecture of delay_signal is

begin

  ------------------------------------------------------
  --               delay = 0
  ------------------------------------------------------
  delay_z0 : if signal_delay = 0 generate
    signal_delayed <= signal_input; -- no delay
  end generate delay_z0;

  ------------------------------------------------------
  --               delay = 1
  ------------------------------------------------------
  delay_z1 : if signal_delay = 1 generate

    delay_process : process (clk) is
    begin

      if rising_edge(clk) then
        signal_delayed <= signal_input;
      end if;

    end process delay_process;

  end generate delay_z1;

  ------------------------------------------------------
  --               delay = 2
  ------------------------------------------------------
  delay_z2 : if signal_delay = 2 generate
    signal output_delayed : std_logic_vector(signal_width - 1 downto 0);
  begin

    delay_process : process (clk) is
    begin

      if rising_edge(clk) then
        output_delayed <= signal_input;
        signal_delayed <= output_delayed;
      end if;

    end process delay_process;

  end generate delay_z2;

  ------------------------------------------------------
  --               delay > 2
  ------------------------------------------------------
  delay_zg2 : if signal_delay > 2 generate

    type delay_array is array (natural range <>) of
   std_logic_vector(signal_width - 1 downto 0);

    signal delay_vector : delay_array(signal_delay - 2 downto 0);
  begin

    delay_process : process (clk) is
    begin

      if rising_edge(clk) then
        delay_vector(0) <= signal_input;

        for i in 0 to signal_delay - 3 loop
          delay_vector(i + 1) <= delay_vector(i);
        end loop;

        signal_delayed <= delay_vector(signal_delay - 2);
      end if;

    end process delay_process;

  end generate delay_zg2;

end architecture delay_architecture;

