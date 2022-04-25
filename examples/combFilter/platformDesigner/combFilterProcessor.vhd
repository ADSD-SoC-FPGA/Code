-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Authors:          Ross K. Snider
-- Company:          Montana State University
-- Create Date:      April 22, 2022
-- Revision:         1.0
-- License: MIT      (opensource.org/licenses/MIT)
-- Target Device(s): Terasic D1E0-Nano Board
-- Tool versions:    Quartus Prime 20.1
---------------------------------------------------------------------------
--
-- Design Name:      combFilterProcessor.vhd
--
-- Description:      VHDL file to be used by Platform Designer to create
--                   the combFilterProcessor component that has the
--                   following three interfaces:
--                       1. Avalon Streaming Sink
--                       2. Avalon Streaming Source
--                       1. Avalon Memory Mapped
--                   This file is a wrapper for the VHDL code
--                   combFilterSystem.vhd that was created by HDL Coder
--                   from the Simulink model combFilterFeedforward.slx
--
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity combfilterprocessor is
  port (
    clk                      : in    std_logic;
    reset                    : in    std_logic;
    avalon_st_sink_valid     : in    std_logic;
    avalon_st_sink_data      : in    std_logic_vector(23 downto 0);
    avalon_st_sink_channel   : in    std_logic_vector(0 downto 0);
    avalon_st_source_valid   : out   std_logic;
    avalon_st_source_data    : out   std_logic_vector(23 downto 0);
    avalon_st_source_channel : out   std_logic_vector(0 downto 0);
    avalon_mm_address        : in    std_logic_vector(1 downto 0);
    avalon_mm_read           : in    std_logic;
    avalon_mm_readdata       : out   std_logic_vector(31 downto 0);
    avalon_mm_write          : in    std_logic;
    avalon_mm_writedata      : in    std_logic_vector(31 downto 0)
  );
end entity combfilterprocessor;

architecture behavioral of combfilterprocessor is

  -- HDL Coder component we are interfacing with
  component combfiltersystem is
    port (
      clk        : in    std_logic;
      reset      : in    std_logic;
      clk_enable : in    std_logic;
      audioin    : in    std_logic_vector(23 downto 0);
      delaym     : in    std_logic_vector(15 downto 0);
      b0         : in    std_logic_vector(15 downto 0);
      bm         : in    std_logic_vector(15 downto 0);
      wetdrymix  : in    std_logic_vector(15 downto 0);
      ce_out     : out   std_logic;
      audioout   : out   std_logic_vector(23 downto 0)
    );
  end component combfiltersystem;

  -- Avalon Streaming (Avalon-ST) to Left/Right
  component ast2lr is
    port (
      clk                 : in    std_logic;
      avalon_sink_data    : in    std_logic_vector(23 downto 0);
      avalon_sink_channel : in    std_logic;
      avalon_sink_valid   : in    std_logic;
      data_left           : out   std_logic_vector(23 downto 0);
      data_right          : out   std_logic_vector(23 downto 0)
    );
  end component ast2lr;

  -- Left/Right to Avalon Streaming (Avalon-ST)
  component lr2ast is
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
  end component lr2ast;

  -- streaming internal signals
  signal left_data_sink    : std_logic_vector(23 downto 0);
  signal right_data_sink   : std_logic_vector(23 downto 0);
  signal left_data_source  : std_logic_vector(23 downto 0);
  signal right_data_source : std_logic_vector(23 downto 0);

  -- register signals
  -- Note: Left/right channels will be controlled from the same registers
  --       For independent control, create twice as many registers
  --       and prefix with left_ and right_
  --       This will require twice as many entries in the
  --       associated linux device driver
  -- delayM - uint16 - default value = "0001001011000000" = 24000 (0.5 sec)
  signal delaym    : std_logic_vector(15 downto 0) := "0101110111000000";
  -- b0 - sfix16_En16 - default value = "0111111111111111" = ~0.5
  signal b0        : std_logic_vector(15 downto 0) := "0111111111111111";
  -- bm - sfix16_En16 - default value = "0111111111111111" = ~0.5
  signal bm        : std_logic_vector(15 downto 0) := "0111111111111111";
  -- wetDryMix - ufix16_En16 - default value = "1111111111111111" = ~1
  signal wetdrymix : std_logic_vector(15 downto 0) := "1111111111111111";

begin

  -- Avalon Streaming (Avalon-ST) to Left/Right
  u_ast2lr : component ast2lr
    port map (
      clk                 => clk,
      avalon_sink_data    => avalon_st_sink_data,
      avalon_sink_channel => avalon_st_sink_channel(0),
      avalon_sink_valid   => avalon_st_sink_valid,
      data_left           => left_data_sink,
      data_right          => right_data_sink
    );

  -- Left/Right to Avalon Streaming (Avalon-ST)
  u_lr2ast : component lr2ast
    port map (
      clk                   => clk,
      avalon_sink_channel   => avalon_st_sink_channel(0),
      avalon_sink_valid     => avalon_st_sink_valid,
      data_left             => left_data_source,
      data_right            => right_data_source,
      avalon_source_data    => avalon_st_source_data,
      avalon_source_channel => avalon_st_source_channel(0),
      avalon_source_valid   => avalon_st_source_valid
    );

  -- HDL Coder components (left channel)
  left_combfiltersystem : component combfiltersystem
    port map (
      clk        => clk,
      reset      => reset,
      clk_enable => '1',
      audioin    => left_data_sink,
      delaym     => delaym,
      b0         => b0,
      bm         => bm,
      wetdrymix  => wetdrymix,
      ce_out     => open,
      audioout   => left_data_source
    );

  -- HDL Coder components (right channel)
  right_combfiltersystem : component combfiltersystem
    port map (
      clk        => clk,
      reset      => reset,
      clk_enable => '1',
      audioin    => right_data_sink,
      delaym     => delaym,
      b0         => b0,
      bm         => bm,
      wetdrymix  => wetdrymix,
      ce_out     => open,
      audioout   => right_data_source
    );

  -- Avalon Memory Mapped interface (CPU reading from registers)
  bus_read : process (clk) is
  begin

    if rising_edge(clk) and avalon_mm_read = '1' then

      case avalon_mm_address is

        when "00" =>
          avalon_mm_readdata <= std_logic_vector(resize(unsigned(delaym), 32));

        when "01" =>
          avalon_mm_readdata <= std_logic_vector(resize(signed(b0), 32));

        when "10" =>
          avalon_mm_readdata <= std_logic_vector(resize(signed(bm), 32));

        when "11" =>
          avalon_mm_readdata <= std_logic_vector(resize(unsigned(wetdrymix), 32));

        when others =>
          avalon_mm_readdata <= (others => '0');

      end case;

    end if;

  end process bus_read;

  -- Avalon Memory Mapped interface (CPU writing to registers)
  bus_write : process (clk, reset) is
  begin

    if reset = '1' then
      delaym    <= "0101110111000000"; -- 24000
      b0        <= "0111111111111111"; -- ~0.5
      bm        <= "0111111111111111"; -- ~0.5
      wetdrymix <= "1111111111111111"; -- ~1
    elsif rising_edge(clk) and avalon_mm_write = '1' then

      case avalon_mm_address is

        when "00" =>
          delaym <= std_logic_vector(resize(unsigned(avalon_mm_writedata), 16));

        when "01" =>
          b0 <= std_logic_vector(resize(signed(avalon_mm_writedata), 16));

        when "10" =>
          bm <= std_logic_vector(resize(signed(avalon_mm_writedata), 16));

        when "11" =>
          wetdrymix <= std_logic_vector(resize(unsigned(avalon_mm_writedata), 16));

        when others =>
          null;

      end case;

    end if;

  end process bus_write;

end architecture behavioral;

