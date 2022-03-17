-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Authors:          Ross K. Snider, Trevor Vannoy
-- Company:          Audio Logic
-- Create Date:      October 26, 2018; Updated 3/16/2022
-- Revision:         1.0
-- License: MIT      (opensource.org/licenses/MIT)
-- Target Device(s): Terasic D1E0-Nano Board
-- Tool versions:    Quartus Prime 18.0
---------------------------------------------------------------------------
--
-- Design Name:      AD1939_hps_audio_mini.vhd
--
-- Description:      The AD1939_hps_audio_mini component does the following:
--
--   1. Provides a streaming Avalon data interface for to the AD1939 Audio Codec
--      that can be used by Intel's Platform Designer in Quartus.
--   2. Note: It is assumed that the AD1939 SPI Control Interface is
--            connected to the SPI master of the Cyclone V HPS, thus there
--            is no control interface in this component.
--            -- Signals to/from AD1939 SPI Control Port (data direction
--               from AD1939 perspective), connection to physical pins
--               on AD1939
--            -- 10 MHz CCLK max (see page 7 of AD1939 data sheet)
--            -- CIN data is 24-bits (see page 14 of AD1939 data sheet)
--            -- CLATCH_n must have pull-up resistor so that AD1939
--               recognizes presence of SPI controller on power-up
--   3. Note: To create a synchronous fabric system clock, run the
--            AD1939 MCLK0 to a PLL in the FPGA to create appropriate
--            multiples of the 12.288 MHz audio clock (e.g. 98.304 MHz).
--   4. The Audio Mini card only has a stereo Line-In port and a
--      stereo Headphone-Out port.  The other AD1939 I/O channels are not
--      used in the Audio Mini card and do not appear in the VHDL interface.
--   5. AD1939 should be configured as follows:
--        a.  Normal stereo serial I2S mode (see page 15 of AD1939 data sheet)
--        b.  24-bit word length
--        c.  ADC set as Master
--        d.  DAC set as Slave
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Library packages
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------
-- ad1939 physical layer : signals to/from ad1939 serial data port
-- (from adcs/to dacs), i.e. connection to physical pins on ad1939
-- Note: asdata1 from adc and dsdata2, dsdata3, dsdata4 to dac are not used
--       since these are not present on the audio mini board.
--       ad1939 register control is connected via the ad1939 spi control
--       port and controlled with the hps spi,
--       so no control port in this component.
---------------------------------------------------------------------------
-- Abstracted data channels, i.e. interface to the data plane as
-- a stereo Avalon Streaming Interface with 24-bit data words.
-- See table 17, page 41, of Intel's Avalon streaming interface specifications
-- https://www.altera.com/content/dam/altera-www/global/en_us/pdfs/
-- ...literature/manual/mnl_avalon_spec.pdf
-- Data is being clocked out at the sys_clk rate and valid is asserted only
-- when data is present.  Left and right channels are specified
-- as channel number (0=left or 1=right)
-- Data is converted to a 2's complement  w=24 (word length in bits),
-- f=23 (number of fractional bits) before being sent out.
---------------------------------------------------------------------------
entity ad1939_hps_audio_mini is
  port (
    -- fpga system fabric clock  (note: sys_clk is assumed to be faster and
    -- synchronous to the ad1939 sample rate clock and bit clock, typically
    -- one generates sys_clk using a pll that is n * ad1939_adc_alrclk)
    sys_clk            : in    std_logic;
    -- fpga system fabric reset
    sys_reset          : in    std_logic;
    ------------------------------------------
    -- Physical signals from adc (serial data)
    ------------------------------------------
    -- serial data from ad1939 pin 26 asdata2, adc2 24-bit
    -- normal stereo serial mode
    ad1939_adc_asdata2 : in    std_logic;
    -- bit clock from adc (master mode) from pin 28 abclk on ad1939;
    -- note: bit clock = 64 * fs, fs = sample rate
    ad1939_adc_abclk   : in    std_logic;
    -- left/right framing clock from adc (master mode) from pin 29 alrclk
    -- on ad1939;  note: lr clock = fs, fs = sample rate
    ad1939_adc_alrclk  : in    std_logic;
    ------------------------------------------
    -- Physical signals to dac (serial data)
    ------------------------------------------
    -- serial data to ad1939 pin 20 dsdata1, dac1 24-bit
    -- normal stereo serial mode
    ad1939_dac_dsdata1 : out   std_logic;
    -- bit clock for dac (slave mode) to pin 21 dbclk on ad1939
    ad1939_dac_dbclk   : out   std_logic;
    -- left/right framing clock for dac (slave mode)
    -- to pin 22 dlrclk on ad1939
    ad1939_dac_dlrclk  : out   std_logic;
    -------------------------------------------------
    -- Avalon streaming interface from ADC to fabric
    -------------------------------------------------
    -- Data: w=24; f=23; signed 2's complement
    ad1939_adc_data    : out   std_logic_vector(23  downto 0);
    -- Channels: left <-> channel 0;  right <-> channel 1
    ad1939_adc_channel : out   std_logic;
    -- Valid: asserted when data is present
    ad1939_adc_valid   : out   std_logic;
    -------------------------------------------------
    -- Avalon streaming interface to DAC from fabric
    -------------------------------------------------
    -- Data: w=24; f=23; signed 2's complement
    ad1939_dac_data    : in    std_logic_vector(23 downto 0);
    -- Channels: left <-> channel 0;  right <-> channel 1
    ad1939_dac_channel : in    std_logic;
    -- Valid: asserted when data is present
    ad1939_dac_valid   : in    std_logic
  );
end entity ad1939_hps_audio_mini;

architecture behavioral of ad1939_hps_audio_mini is

  -------------------------------------------------------------------------
  -- Intel/Altera component to convert serial data to parallel
  -- Generated using Quartus' megafunction wizard
  -- Found in IP Library\Basic Functions\Miscellaneous\LPM_SHIFTREG
  -------------------------------------------------------------------------
  component serial2parallel_32bits is
    port (
      clock   : in    std_logic;
      shiftin : in    std_logic;
      q       : out   std_logic_vector(31 downto 0)
    );
  end component serial2parallel_32bits;

  -------------------------------------------------------------------------
  -- Intel/Altera component to convert parallel data to serial
  -- Generated using Quartus' megafunction wizard
  -- Found in IP Library\Basic Functions\Miscellaneous\LPM_SHIFTREG
  -------------------------------------------------------------------------
  component parallel2serial_32bits is
    port (
      clock    : in    std_logic;
      data     : in    std_logic_vector(31 downto 0);
      load     : in    std_logic;
      shiftout : out   std_logic
    );
  end component parallel2serial_32bits;

  -------------------------------------------------------------------------
  -- Component to delay signals
  -- Used to delay BCLK and LRCLK going to DAC
  -------------------------------------------------------------------------
  component delay_signal is
    generic (
      signal_width : natural;
      signal_delay : natural
    );
    port (
      clk            : in    std_logic;
      signal_input   : in    std_logic_vector(signal_width - 1  downto 0);
      signal_delayed : out   std_logic_vector(signal_width - 1  downto 0)
    );
  end component delay_signal;

  -------------------------------------------------------------------------
  -- States to implement avalon streaming with the data-channel-valid protocol
  -- see I2S-justified mode in figure 23 on page 21 of ad1939 data sheet.
  -------------------------------------------------------------------------

  type state_type is (
    state_left_wait, state_left_capture, state_left_valid,
    state_right_wait, state_right_capture, state_right_valid
  );

  signal state : state_type;

  --------------------------------------------------------------
  -- Internal signals
  --------------------------------------------------------------
  signal sregout_adc2                     : std_logic_vector(31 downto 0);
  signal adc2_data                        : std_logic_vector(23 downto 0);
  signal dac1_data_left                   : std_logic_vector(31 downto 0);
  signal dac1_data_right                  : std_logic_vector(31 downto 0);
  signal ad1939_dac_dsdata1_left          : std_logic;
  signal ad1939_dac_dsdata1_right         : std_logic;
  signal ad1939_dac_dsdata1_left_delayed  : std_logic := '0';
  signal ad1939_dac_dsdata1_right_delayed : std_logic := '0';

begin

  -------------------------------------------------------------------------
  -- Convert serial data stream to parallel
  -------------------------------------------------------------------------
  s2p_adc2 : component serial2parallel_32bits
    port map (
      clock   => ad1939_adc_abclk,
      shiftin => ad1939_adc_asdata2,
      q       => sregout_adc2
    );

  -----------------------------------------------------------------------
  -- Get the 24-bits with a sdata delay of 1 (sdata delay set in adc
  -- control 1 register; see table 24 page 27 of ad1939 data sheet)
  -----------------------------------------------------------------------
  adc2_data <= sregout_adc2(29 downto 6);

  -------------------------------------------------------------------------
  -- State machine states to implement the Avalon Streaming Interface
  -- Logic to advance to the next state
  -------------------------------------------------------------------------
  avalon_states : process (sys_clk, sys_reset) is
  begin

    if (sys_reset = '1') then
      state <= state_left_wait;
    elsif (rising_edge(sys_clk)) then

      case state is

        ---------------------------------------------
        -- left
        ---------------------------------------------
        when state_left_wait =>
          -- The 32-bit shift register is full of left data
          -- when alrck goes high
          if (ad1939_adc_alrclk = '1') then
            state <= state_left_capture;
          else
            state <= state_left_wait;
          end if;

        when state_left_capture => -- state to capture data
          state <= state_left_valid;

        when state_left_valid => -- state to generate valid signal
          state <= state_right_wait;

        ---------------------------------------------
        -- right
        ---------------------------------------------
        when state_right_wait =>
          -- The 32-bit shift register is full of right data
          -- when alrck goes low
          if (ad1939_adc_alrclk = '0') then
            state <= state_right_capture;
          else
            state <= state_right_wait;
          end if;

        when state_right_capture => -- state to capture data
          state <= state_right_valid;

        when state_right_valid => -- state to generate valid signal
          state <= state_left_wait;

        ---------------------------------------------
        -- catch all
        ---------------------------------------------
        when others =>
          state <= state_left_wait;

      end case;

    end if;

  end process avalon_states;

  -------------------------------------------------------------------------
  -- State machine signals to implement the Avalon Streaming Interface
  -- Generate the Avalon Streaming signals from serial data
  -------------------------------------------------------------------------
  avalon_signals : process (sys_clk) is
  begin

    if (rising_edge(sys_clk)) then
      -- default behavior is valid low  (signifies no data)
      ad1939_adc_valid   <= '0';
      -- set default channel to left
      ad1939_adc_channel <= '0';

      case state is

        ---------------------------------------------
        -- get left sample
        ---------------------------------------------
        when state_left_wait =>
          null; -- do nothing, shift register is being filled

        when state_left_capture =>
          ad1939_adc_data <= adc2_data; -- capture left 24-bit word

        when state_left_valid =>
          ad1939_adc_valid   <= '1'; -- sample is now valid
          ad1939_adc_channel <= '0'; -- data is from the left channel

        ---------------------------------------------
        -- get right sample
        ---------------------------------------------
        when state_right_wait =>
          null; -- do nothing, shift register is being filled

        when state_right_capture =>
          ad1939_adc_data <= adc2_data; -- capture right 24-bit word

        when state_right_valid =>
          ad1939_adc_valid   <= '1'; -- sample is now valid
          ad1939_adc_channel <= '1'; -- data is from the right channel

        when others =>
          null;

      end case;

    end if;

  end process avalon_signals;

  -------------------------------------------------------------------------
  -- Capture the Avalon Streaming data that is to be sent to DAC1
  -- Note: the streaming data is assumed to be normalized.
  -------------------------------------------------------------------------
  avalon_capture : process (sys_clk) is
  begin

    if (rising_edge(sys_clk)) then
      if (ad1939_dac_valid  = '1') then -- data has arrived

        case ad1939_dac_channel is

          -- data is in i2s-justified mode, which has one empty bit
          -- before the MSB. See Fig. 23 on page 21 of the AD1939 datasheet
          when '0' => -- left data
            -- pack into 32-bit word for L/R framing slot
            dac1_data_left <= '0' & ad1939_dac_data & "0000000";

          when '1' => -- right data
            -- pack into 32-bit word for L/R framing slot
            dac1_data_right <= '0' & ad1939_dac_data & "0000000";

          when others =>
            null;

        end case;

      end if;
    end if;

  end process avalon_capture;

  -------------------------------------------------------------------------
  -- DAC1 left
  -------------------------------------------------------------------------
  p2s_dac1_left : component parallel2serial_32bits
    port map (
      clock    => ad1939_adc_abclk,
      data     => dac1_data_left,
      load     => ad1939_adc_alrclk,
      shiftout => ad1939_dac_dsdata1_left
    );

  -------------------------------------------------------------------------
  -- DAC1 right
  -------------------------------------------------------------------------
  p2s_dac1_right : component parallel2serial_32bits
    port map (
      clock    => ad1939_adc_abclk,
      data     => dac1_data_right,
      load     => not ad1939_adc_alrclk,
      shiftout => ad1939_dac_dsdata1_right
    );

  -------------------------------------------------------------------------
  -- Need a delay of one bit clock cycle
  -------------------------------------------------------------------------
  delay_dsdata : process (ad1939_adc_abclk) is
  begin

    if rising_edge(ad1939_adc_abclk) then
      ad1939_dac_dsdata1_left_delayed  <= ad1939_dac_dsdata1_left;
      ad1939_dac_dsdata1_right_delayed <= ad1939_dac_dsdata1_right;
    end if;

  end process delay_dsdata;

  -------------------------------------------------------------------------
  -- interleave the left/right serial data that goes out to the dac
  -------------------------------------------------------------------------
  interleave : process (sys_clk) is
  begin

    if rising_edge(sys_clk) then
      if (ad1939_adc_alrclk = '0') then
        ad1939_dac_dsdata1 <= ad1939_dac_dsdata1_left_delayed;
      else
        ad1939_dac_dsdata1 <= ad1939_dac_dsdata1_right_delayed;
      end if;
    end if;

  end process interleave;

  -------------------------------------------------------------------------
  -- The master bit clock from adc drives the slave bit clock of DAC
  -- The master framing lr clock from ADC drives the slave lr clock of DAC
  -- The ADC is set as master for bclk and lrclk, which is set in
  -- ADC control 2 register. See table 25 on page 28 of ad1939 data sheet.
  -- Delay the DAC BCLK and LRCLK to allow for the data register latency
  -- and provide some setup time.
  -------------------------------------------------------------------------
  -- ad1939_dac_dbclk  <= ad1939_adc_abclk;
  delay_dac_bclk : component delay_signal
    generic map (
      signal_width => 1,
      signal_delay => 8
    )
    port map (
      clk               => sys_clk,
      signal_input(0)   => ad1939_adc_abclk,
      signal_delayed(0) => ad1939_dac_dbclk
    );

  -- ad1939_dac_dlrclk <= ad1939_adc_alrclk;
  delay_dac_lrclk : component delay_signal
    generic map (
      signal_width => 1,
      signal_delay => 8
    )
    port map (
      clk               => sys_clk,
      signal_input(0)   => ad1939_adc_alrclk,
      signal_delayed(0) => ad1939_dac_dlrclk
    );

end architecture behavioral;
