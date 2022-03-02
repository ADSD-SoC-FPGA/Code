-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using 
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:           Ross K. Snider
-- Company:          Audio Logic
-- Create Date:      October 26, 2018
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

use work.ad1939.all;

entity ad1939_hps_audio_mini is
    port (
        sys_clk   : in    std_logic; -- fpga system fabric clock  (note: sys_clk is assumed to be faster and synchronous to the ad1939 sample rate clock and bit clock, typically one generates sys_clk using a pll that is n * ad1939_adc_alrclk)
        sys_reset : in    std_logic; -- fpga system fabric reset
        -------------------------------------------------------------------
        -- ad1939 physical layer : signals to/from ad1939 serial data port (from adcs/to dacs), i.e. connection to physical pins on ad1939
        -- Note: asdata1 from adc and dsdata2, dsdata3, dsdata4 to dac are not used since these are not present on the audio mini board.
        --       ad1939 register control is connected via the ad1939 spi control port and controlled with the hps spi, so no control port in this component.
        -------------------------------------------------------------------
        -- physical signals from adc (serial data)
        ad1939_adc_asdata2 : in    std_logic; -- serial data from ad1939 pin 26 asdata2, adc2 24-bit normal stereo serial mode
        ad1939_adc_abclk   : in    std_logic; -- bit clock from adc (master mode) from pin 28 abclk on ad1939;  note: bit clock = 64 * fs, fs = sample rate
        ad1939_adc_alrclk  : in    std_logic; -- left/right framing clock from adc (master mode) from pin 29 alrclk on ad1939;  note: lr clock = fs, fs = sample rate
        -- physical signals to dac (serial data)
        ad1939_dac_dsdata1 : out   std_logic; -- serial data to ad1939 pin 20 dsdata1, dac1 24-bit normal stereo serial mode
        ad1939_dac_dbclk   : out   std_logic; -- bit clock for dac (slave mode) to pin 21 dbclk on ad1939
        ad1939_dac_dlrclk  : out   std_logic; -- left/right framing clock for dac (slave mode) to pin 22 dlrclk on ad1939
        -------------------------------------------------------------------
        -- Abstracted data channels, i.e. interface to the data plane as 24-bit data words.
        -- this is setup as a two channel avalon streaming interface
        -- See table 17, page 41, of Intel's Avalon streaming interface specifications
        -- https://www.altera.com/content/dam/altera-www/global/en_us/pdfs/literature/manual/mnl_avalon_spec.pdf
        -- Data is being clocked out at the sys_clk rate and valid is asserted only when data is present.  Left and right channels are specified as channel number (0 or 1)
        -- Data is converted to a w=24 (word length in bits), f=23 (number of fractional bits) before being sent out.
        -------------------------------------------------------------------
        -- avalon streaming interface from adc to fabric
        ad1939_adc_data    : out   std_logic_vector(23  downto 0); -- w=24; f=23; signed 2's complement
        ad1939_adc_channel : out   std_logic;                      -- left <-> channel 0;  right <-> channel 1
        ad1939_adc_valid   : out   std_logic;                      -- asserted when data is valid
        -- avalon streaming interface to dac from fabric
        ad1939_dac_data    : in    std_logic_vector(23 downto 0);  -- w=24; f=23; signed 2's complement
        ad1939_dac_channel : in    std_logic;                      -- left <-> channel 0;  right <-> channel 1
        ad1939_dac_valid   : in    std_logic                       -- asserted when data is valid
    );
end entity ad1939_hps_audio_mini;

architecture behavioral of ad1939_hps_audio_mini is

    -----------------------------------------------------------------------
    -- Intel/Altera component to convert serial data to parallel
    -- Generated using Quartus' megafunction wizard  
    -- Found in IP Library\Basic Functions\Miscellaneous\LPM_SHIFTREG
    -----------------------------------------------------------------------
    component serial2parallel_32bits is
        port (
            clock   : in    std_logic;
            shiftin : in    std_logic;
            q       : out   std_logic_vector(31 downto 0)
        );
    end component;

    -----------------------------------------------------------------------
    -- Intel/Altera component to convert parallel data to serial
    -- Generated using Quartus' megafunction wizard  
    -- Found in IP Library\Basic Functions\Miscellaneous\LPM_SHIFTREG
    -----------------------------------------------------------------------
    component parallel2serial_32bits is
        port (
            clock    : in    std_logic;
            data     : in    std_logic_vector(31 downto 0);
            load     : in    std_logic;
            shiftout : out   std_logic
        );
    end component;

    -----------------------------------------------------------------------
    -- States to implement avalon streaming with the data-channel-valid protocol
    -- see I2S-justified mode in figure 23 on page 21 of ad1939 data sheet.
    -----------------------------------------------------------------------
    type state_type is (state_left_wait, state_left_capture, state_left_valid, state_right_wait, state_right_capture, state_right_valid);
    signal state : state_type;

    --------------------------------------------------------------
    -- internal signals
    --------------------------------------------------------------
    signal sregout_adc2             : std_logic_vector(31 downto 0);
    signal adc2_data                : std_logic_vector(23 downto 0);
    signal dac1_data_left           : std_logic_vector(31 downto 0);
    signal dac1_data_right          : std_logic_vector(31 downto 0);
    signal ad1939_dac_dsdata1_left  : std_logic;
    signal ad1939_dac_dsdata1_right : std_logic;

begin

    -----------------------------------------------------------------------
    -- the master bit clock from adc drives the slave bit clock of dac
    -- the master framing lr clock from adc drives the slave lr clock of dac
    -- adc is set as master for bclk and lrclk.  set in adc control 2 register.
    -- see table 25 on page 28 of ad1939 data sheet.
    -----------------------------------------------------------------------
    ad1939_dac_dbclk  <= ad1939_adc_abclk;
    ad1939_dac_dlrclk <= ad1939_adc_alrclk;

    -----------------------------------------------------------------------
    -- convert serial data stream to parallel
    -----------------------------------------------------------------------
    s2p_adc2 : serial2parallel_32bits
        port map (
            clock   => ad1939_adc_abclk,
            shiftin => ad1939_adc_asdata2,
            q       => sregout_adc2
        );

    -----------------------------------------------------------------------
    -- get the 24-bits with a sdata delay of 1 (sdata delay set in adc control 1 register; see table 24 page 27 of ad1939 data sheet)
    -----------------------------------------------------------------------
    adc2_data <= sregout_adc2(30 downto 7); 

    --------------------------------------------------------------
    -- State machine to implement avalon streaming interface
    -- Logic to advance to the next state
    --------------------------------------------------------------
    process (sys_clk, sys_reset) is
    begin
        if (sys_reset = '1') then
            state <= state_left_wait;
        elsif (rising_edge(sys_clk)) then

            case state is
                ---------------------------------------------
                -- left
                ---------------------------------------------
                when state_left_wait =>
                    if (ad1939_adc_alrclk = '0') then   -- capture left data when alrck goes low
                        state <= state_left_capture;
                    else
                        state <= state_left_wait;
                    end if;
                when state_left_capture =>              -- state to capture data
                    state <= state_left_valid;
                when state_left_valid =>                -- state to generate valid signal
                    state <= state_right_wait;
                ---------------------------------------------
                -- right
                ---------------------------------------------
                when state_right_wait =>
                    if (ad1939_adc_alrclk = '1') then   -- capture right data when alrck goes high
                        state <= state_right_capture;
                    else
                        state <= state_right_wait;
                    end if;
                when state_right_capture =>             -- state to capture data
                    state <= state_right_valid;
                when state_right_valid =>
                    state <= state_left_wait;           -- state to generate valid signal
                ---------------------------------------------
                -- catch all
                ---------------------------------------------
                when others =>
                    state <= state_left_wait;

            end case;
        end if;
    end process;

    --------------------------------------------------------------
    -- state machine to implement avalon streaming
    -- generate avalon streaming signals from serial data
    --------------------------------------------------------------
    process (sys_clk) is
    begin
        if (rising_edge(sys_clk)) then
            ad1939_adc_valid   <= '0';  -- default behavior is valid low  (signifies no data)
            ad1939_adc_channel <= '0';  -- set default channel to left

            case state is
                ---------------------------------------------
                -- get left sample
                ---------------------------------------------
                when state_left_wait =>
                    null;
                when state_left_capture =>
                    ad1939_adc_data <= adc2_data;   -- capture left 24-bit word
                when state_left_valid =>
                    ad1939_adc_valid   <= '1';      -- sample is now valid
                    ad1939_adc_channel <= '0';      -- data is from the left channel

                ---------------------------------------------
                -- get right sample
                ---------------------------------------------
                when state_right_wait =>
                    null;
                when state_right_capture =>
                    ad1939_adc_data <= adc2_data;   -- capture right 24-bit word
                when state_right_valid =>
                    ad1939_adc_valid   <= '1';      -- sample is now valid
                    ad1939_adc_channel <= '1';      -- data is from the right channel
                when others =>
                    null;
            end case;
        end if;
    end process;

    -------------------------------------------------------------
    -- capture avalon streaming data that is to be sent to dac1
    -- the streaming data is assumed to be normalized.
    -------------------------------------------------------------
    process (sys_clk) is
        begin
            if (rising_edge(sys_clk)) then
                if (ad1939_dac_valid  = '1') then -- data has arrived
                    case ad1939_dac_channel is
                        -- data is in i2s-justified mode, which has one empty bit 
                        -- before the MSB. See Fig. 23 on page 21 of the AD1939 datasheet
                        when '0' => -- left data
                            dac1_data_left <= '0' & ad1939_dac_data & "0000000";  -- pack into 32-bit word for L/R framing slot
                        when '1' => -- right data
                            dac1_data_right <= '0' & ad1939_dac_data & "0000000"; -- pack into 32-bit word for L/R framing slot
                        when others =>
                            null;
                    end case;
                end if;
            end if;
    end process;

    -------------------------------------------------------------
    -- dac1 left
    -------------------------------------------------------------
     p2s_dac1_left : parallel2serial_32bits
        port map (
            clock    => ad1939_adc_abclk,
            data     => dac1_data_left,
            load     => ad1939_adc_alrclk,
            shiftout => ad1939_dac_dsdata1_left
        );

    -------------------------------------------------------------
    -- dac1 right
    -------------------------------------------------------------
    p2s_dac1_right : parallel2serial_32bits
        port map (
            clock    => ad1939_adc_abclk,
            data     => dac1_data_right,
            load     => not ad1939_adc_alrclk,
            shiftout => ad1939_dac_dsdata1_right
        );

    ------------------------------------------------------------------
    -- interleave the left/right serial data that goes out to the dac
    ------------------------------------------------------------------
    process (ad1939_adc_alrclk, ad1939_dac_dsdata1_left, ad1939_dac_dsdata1_right) is
    begin
        if (ad1939_adc_alrclk = '0') then
            ad1939_dac_dsdata1 <= ad1939_dac_dsdata1_left; 
        else
            ad1939_dac_dsdata1 <= ad1939_dac_dsdata1_right;
        end if;
    end process;


end architecture behavioral;
