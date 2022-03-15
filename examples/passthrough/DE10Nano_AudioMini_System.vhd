-- SPDX-License-Identifier: MIT
-- Copyright (c) 2022 Ross K. Snider.  All rights reserved.
---------------------------------------------------------------------------
-- Description:  VHDL top level file for a DE10-Nano system that contains
--               an Audio Mini board and a Platform Designer system.
---------------------------------------------------------------------------
-- This file is used in the book: Advanced Digital System Design using
-- System-on-Chip Field Programmable Gate Arrays
-- An Integrated Hardware/Software Approach
-- by Ross K. Snider
---------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  October 26, 2018
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Library packages
---------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

library altera;
use altera.altera_primitives_components.all;

---------------------------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
---------------------------------------------------------------------------
entity de10nano_audiomini_system is
  port (
    -----------------------------------------------------------------------
    --  CLOCK Inputs
    --  See DE10 Nano User Manual page 23
    -----------------------------------------------------------------------
    fpga_clk1_50 : in    std_logic; -- 50 MHz clock input #1
    fpga_clk2_50 : in    std_logic; -- 50 MHz clock input #2
    fpga_clk3_50 : in    std_logic; -- 50 MHz clock input #3

    -----------------------------------------------------------------------
    --  Push Button Inputs (KEY)
    --  See DE10 Nano User Manual page 24
    --  The KEY push button inputs produce a '0' when pressed (asserted)
    --  and produces a '1' in the rest (non-pushed) state
    --  a better name for KEY would be Push_Button_n
    -----------------------------------------------------------------------
    key : in    std_logic_vector(1 downto 0); -- Pushbuttons (active low)

    -----------------------------------------------------------------------
    --  Slide Switch Inputs (SW)
    --  See DE10 Nano User Manual page 25
    --  The slide switches produce a '0' when in the down position
    --  (towards the edge of the board)
    -----------------------------------------------------------------------
    sw : in    std_logic_vector(3 downto 0); -- Four Slide Switches

    -----------------------------------------------------------------------
    --  LED Outputs
    --  See DE10 Nano User Manual page 26
    --  Setting LED to 1 will turn it on
    -----------------------------------------------------------------------
    led : out   std_logic_vector(7 downto 0); -- Eight LEDs

    -----------------------------------------------------------------------
    --  GPIO Expansion Headers (40-pin)
    --  See DE10 Nano User Manual page 27
    --  Pin 11 = 5V supply (1A max)
    --  Pin 29 - 3.3 supply (1.5A max)
    --  Pins 12, 30 GND
    --  Note: the DE10-Nano GPIO_0 & GPIO_1 signals have been replaced
    --  by the signals Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1
    --  because of the DE10-Nano GPIO pins that have been dedicated to
    --  the Audio Mini plug-in card.  
    --  The old name for the 40 pin header at the top of the board:
    --         GPIO_0 : inout std_logic_vector(35 downto 0);            
    --  The old name for the 40 pin header at the bottom of the board:
    --         GPIO_1 : inout std_logic_vector(35 downto 0);            
    --  The new named signals are:
    --      Audio_Mini_GPIO_0 -- 34 available I/O pins on GPIO_0
    --      Audio_Mini_GPIO_1 -- 13 available I/O pins on GPIO_1
    -----------------------------------------------------------------------
    audio_mini_gpio_0 : inout std_logic_vector(33 downto 0); 
    audio_mini_gpio_1 : inout std_logic_vector(12 downto 0); 

    -----------------------------------------------------------------------
    --  AD1939 Audio Codec Physical Connection Signals
    -----------------------------------------------------------------------
    -- AD1939 clock and Reset
    -- 12.288 MHz clock signal that is driving the AD1939
    ad1939_mclk         : in    std_logic; 
    ad1939_rst_codec_n  : out   std_logic;
    -------------
    -- AD1939 SPI
    -------------
    -- AD1939 SPI signal = mosi data to AD1939 registers
    ad1939_spi_cin      : out   std_logic; 
    -- AD1939 SPI signal = ss_n: slave select (active low)
    ad1939_spi_clatch_n : out   std_logic; 
    -- AD1939 SPI signal = sclk: serial clock
    ad1939_spi_cclk     : out   std_logic; 
    -- AD1939 SPI signal = miso data from AD1939 registers
    ad1939_spi_cout     : in    std_logic; 
    -------------------------
    -- AD1939 ADC Serial Data
    -------------------------
    -- Serial data from AD1939 pin 28 ABCLK,   
    -- Bit Clock for ADCs (Master Mode)
    ad1939_adc_abclk    : in    std_logic; 
    -- Serial data from AD1939 pin 29 ALRCLK,  
    -- LR Clock for ADCs  (Master Mode)
    ad1939_adc_alrclk   : in    std_logic; 
    -- Serial data from AD1939 pin 26 ASDATA2, 
    -- ADC2 24-bit normal stereo serial mode
    ad1939_adc_asdata2  : in    std_logic; 
    -------------------------
    -- AD1939 DAC Serial Data
    -------------------------
    -- Serial data to   AD1939 pin 21 DBCLK,   
    -- Bit Clock for DACs (Slave Mode)
    ad1939_dac_dbclk    : out   std_logic; 
    -- Serial data to   AD1939 pin 22 DLRCLK,  
    -- LR Clock for DACs  (Slave Mode)
    ad1939_dac_dlrclk   : out   std_logic; 
    -- Serial data to   AD1939 pin 20 DSDATA1, 
    -- DAC1 24-bit normal stereo serial mode
    ad1939_dac_dsdata1  : out   std_logic; 

    -----------------------------------------------------------------------
    --  Headphone Amplifier TI TPA6130 Physical connection signals
    -----------------------------------------------------------------------
    tpa6130_i2c_sda   : inout std_logic;
    tpa6130_i2c_scl   : inout std_logic;
    tpa6130_power_off : out   std_logic;

    -----------------------------------------------------------------------
    --  Digital Microphone INMP621 Physical connection signals
    -----------------------------------------------------------------------
    inmp621_mic_clk  : out   std_logic;
    inmp621_mic_data : in    std_logic;

    -----------------------------------------------------------------------
    --  Audio Mini LEDs and Switches
    -----------------------------------------------------------------------
    audio_mini_leds     : out   std_logic_vector(3 downto 0);
    audio_mini_switches : in    std_logic_vector(3 downto 0);

    -----------------------------------------------------------------------
    --  Arduino Uno R3 Expansion Header
    --  See DE10 Nano User Manual page 30
    --  500 ksps, 8-channel, 12-bit ADC
    -----------------------------------------------------------------------
    arduino_io      : inout std_logic_vector(15 downto 0);-- 16 Arduino I/O
    arduino_reset_n : inout std_logic;          -- Reset signal, active low

    -----------------------------------------------------------------------
    --  ADC
    --  See DE10 Nano User Manual page 33
    --  500 ksps, 8-channel, 12-bit ADC
    -----------------------------------------------------------------------
    adc_convst : out   std_logic; -- ADC Conversion Start
    adc_sck    : out   std_logic; -- ADC Serial Data Clock
    adc_sdi    : out   std_logic; -- ADC Serial Data Input  (FPGA to ADC)
    adc_sdo    : in    std_logic; -- ADC Serial Data Output (ADC to FPGA)

    -----------------------------------------------------------------------
    --  Hard Processor System (HPS)
    --  See DE10 Nano User Manual page 36
    -----------------------------------------------------------------------
    hps_conv_usb_n   : inout std_logic;
    hps_ddr3_addr    : out   std_logic_vector(14 downto 0);
    hps_ddr3_ba      : out   std_logic_vector(2 downto 0);
    hps_ddr3_cas_n   : out   std_logic;
    hps_ddr3_cke     : out   std_logic;
    hps_ddr3_ck_n    : out   std_logic;
    hps_ddr3_ck_p    : out   std_logic;
    hps_ddr3_cs_n    : out   std_logic;
    hps_ddr3_dm      : out   std_logic_vector(3 downto 0);
    hps_ddr3_dq      : inout std_logic_vector(31 downto 0);
    hps_ddr3_dqs_n   : inout std_logic_vector(3 downto 0);
    hps_ddr3_dqs_p   : inout std_logic_vector(3 downto 0);
    hps_ddr3_odt     : out   std_logic;
    hps_ddr3_ras_n   : out   std_logic;
    hps_ddr3_reset_n : out   std_logic;
    hps_ddr3_rzq     : in    std_logic;
    hps_ddr3_we_n    : out   std_logic;
    hps_enet_gtx_clk : out   std_logic;
    hps_enet_int_n   : inout std_logic;
    hps_enet_mdc     : out   std_logic;
    hps_enet_mdio    : inout std_logic;
    hps_enet_rx_clk  : in    std_logic;
    hps_enet_rx_data : in    std_logic_vector(3 downto 0);
    hps_enet_rx_dv   : in    std_logic;
    hps_enet_tx_data : out   std_logic_vector(3 downto 0);
    hps_enet_tx_en   : out   std_logic;
    hps_gsensor_int  : inout std_logic;
    hps_i2c0_sclk    : inout std_logic;
    hps_i2c0_sdat    : inout std_logic;
    hps_i2c1_sclk    : inout std_logic;
    hps_i2c1_sdat    : inout std_logic;
    hps_key          : inout std_logic;
    hps_led          : inout std_logic;
    hps_ltc_gpio     : inout std_logic;
    hps_sd_clk       : out   std_logic;
    hps_sd_cmd       : inout std_logic;
    hps_sd_data      : inout std_logic_vector(3 downto 0);
    hps_spim_clk     : out   std_logic;
    hps_spim_miso    : in    std_logic;
    hps_spim_mosi    : out   std_logic;
    hps_spim_ss      : inout std_logic;
    hps_uart_rx      : in    std_logic;
    hps_uart_tx      : out   std_logic;
    hps_usb_data     : inout std_logic_vector(7 downto 0);
    hps_usb_clkout   : in    std_logic;
    hps_usb_stp      : out   std_logic;
    hps_usb_dir      : in    std_logic;
    hps_usb_nxt      : in    std_logic
  );
end entity de10nano_audiomini_system;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
architecture de10nano_arch of de10nano_audiomini_system is

  -------------------------------------------------------------------------
  -- SoC Component from Intel Platform Designer
  -------------------------------------------------------------------------
  component soc_system_passthrough is
    port (
      ad1939_physical_asdata2         : in    std_logic;
      ad1939_physical_dbclk           : out   std_logic;
      ad1939_physical_dlrclk          : out   std_logic;
      ad1939_physical_dsdata1         : out   std_logic;
      ad1939_physical_abclk_clk       : in    std_logic;
      ad1939_physical_alrclk_clk      : in    std_logic;
      ad1939_physical_mclk_clk        : in    std_logic;
      fabric_reset_reset              : in    std_logic;
      hps_and_fabric_reset_reset      : in    std_logic;
      hps_clk_clk                     : in    std_logic;
      hps_io_hps_io_emac1_inst_tx_clk : out   std_logic;
      hps_io_hps_io_emac1_inst_txd0   : out   std_logic;
      hps_io_hps_io_emac1_inst_txd1   : out   std_logic;
      hps_io_hps_io_emac1_inst_txd2   : out   std_logic;
      hps_io_hps_io_emac1_inst_txd3   : out   std_logic;
      hps_io_hps_io_emac1_inst_rxd0   : in    std_logic;
      hps_io_hps_io_emac1_inst_mdio   : inout std_logic;
      hps_io_hps_io_emac1_inst_mdc    : out   std_logic;
      hps_io_hps_io_emac1_inst_rx_ctl : in    std_logic;
      hps_io_hps_io_emac1_inst_tx_ctl : out   std_logic;
      hps_io_hps_io_emac1_inst_rx_clk : in    std_logic;
      hps_io_hps_io_emac1_inst_rxd1   : in    std_logic;
      hps_io_hps_io_emac1_inst_rxd2   : in    std_logic;
      hps_io_hps_io_emac1_inst_rxd3   : in    std_logic;
      hps_io_hps_io_sdio_inst_cmd     : inout std_logic;
      hps_io_hps_io_sdio_inst_d0      : inout std_logic;
      hps_io_hps_io_sdio_inst_d1      : inout std_logic;
      hps_io_hps_io_sdio_inst_clk     : out   std_logic;
      hps_io_hps_io_sdio_inst_d2      : inout std_logic;
      hps_io_hps_io_sdio_inst_d3      : inout std_logic;
      hps_io_hps_io_usb1_inst_d0      : inout std_logic;
      hps_io_hps_io_usb1_inst_d1      : inout std_logic;
      hps_io_hps_io_usb1_inst_d2      : inout std_logic;
      hps_io_hps_io_usb1_inst_d3      : inout std_logic;
      hps_io_hps_io_usb1_inst_d4      : inout std_logic;
      hps_io_hps_io_usb1_inst_d5      : inout std_logic;
      hps_io_hps_io_usb1_inst_d6      : inout std_logic;
      hps_io_hps_io_usb1_inst_d7      : inout std_logic;
      hps_io_hps_io_usb1_inst_clk     : in    std_logic;
      hps_io_hps_io_usb1_inst_stp     : out   std_logic;
      hps_io_hps_io_usb1_inst_dir     : in    std_logic;
      hps_io_hps_io_usb1_inst_nxt     : in    std_logic;
      hps_io_hps_io_spim1_inst_clk    : out   std_logic;
      hps_io_hps_io_spim1_inst_mosi   : out   std_logic;
      hps_io_hps_io_spim1_inst_miso   : in    std_logic;
      hps_io_hps_io_spim1_inst_ss0    : out   std_logic;
      hps_io_hps_io_uart0_inst_rx     : in    std_logic;
      hps_io_hps_io_uart0_inst_tx     : out   std_logic;
      hps_io_hps_io_i2c1_inst_sda     : inout std_logic;
      hps_io_hps_io_i2c1_inst_scl     : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio09  : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio35  : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio40  : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio53  : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio54  : inout std_logic;
      hps_io_hps_io_gpio_inst_gpio61  : inout std_logic;
      hps_i2c0_out_data               : out   std_logic;
      hps_i2c0_sda                    : in    std_logic;
      hps_i2c0_clk_clk                : out   std_logic;
      hps_i2c0_scl_in_clk             : in    std_logic;
      hps_spim0_txd                   : out   std_logic;
      hps_spim0_rxd                   : in    std_logic;
      hps_spim0_ss_in_n               : in    std_logic;
      hps_spim0_ssi_oe_n              : out   std_logic;
      hps_spim0_ss_0_n                : out   std_logic;
      hps_spim0_ss_1_n                : out   std_logic;
      hps_spim0_ss_2_n                : out   std_logic;
      hps_spim0_ss_3_n                : out   std_logic;
      hps_spim0_sclk_out_clk          : out   std_logic;
      memory_mem_a                    : out   std_logic_vector(14 downto 0);
      memory_mem_ba                   : out   std_logic_vector(2 downto 0);
      memory_mem_ck                   : out   std_logic;
      memory_mem_ck_n                 : out   std_logic;
      memory_mem_cke                  : out   std_logic;
      memory_mem_cs_n                 : out   std_logic;
      memory_mem_ras_n                : out   std_logic;
      memory_mem_cas_n                : out   std_logic;
      memory_mem_we_n                 : out   std_logic;
      memory_mem_reset_n              : out   std_logic;
      memory_mem_dq                   : inout std_logic_vector(31 downto 0);
      memory_mem_dqs                  : inout std_logic_vector(3 downto 0);
      memory_mem_dqs_n                : inout std_logic_vector(3 downto 0);
      memory_mem_odt                  : out   std_logic;
      memory_mem_dm                   : out   std_logic_vector(3 downto 0);
      memory_oct_rzqin                : in    std_logic
    );
  end component soc_system_passthrough;

  -------------------------------------------------------------------------
  -- Tristate buffer with pullup for i2c lines
  -------------------------------------------------------------------------
  component alt_iobuf is
    generic (
      io_standard           : string  := "3.3-V LVTTL";
      current_strength      : string  := "maximum current";
      slew_rate             : integer := -1;
      slow_slew_rate        : string  := "NONE";
      location              : string  := "NONE";
      enable_bus_hold       : string  := "NONE";
      weak_pull_up_resistor : string  := "ON";
      termination           : string  := "NONE";
      input_termination     : string  := "NONE";
      output_termination    : string  := "NONE"
    );
    port (
      i  : in    std_logic;
      oe : in    std_logic;
      io : inout std_logic;
      o  : out   std_logic
    );
  end component;

  -------------------------------------------------------------------------
  -- Signal declarations
  -------------------------------------------------------------------------
  signal hps_and_fabric_reset    : std_logic;
  signal fabric_reset            : std_logic;
  signal i2c_0_i2c_serial_sda_in : std_logic;
  signal i2c_serial_scl_in       : std_logic;
  signal i2c_serial_sda_oe       : std_logic;
  signal serial_scl_oe           : std_logic;
  -- A better description of KEY input,
  -- which should really be labelled as KEY_n
  signal push_button             : std_logic_vector(1 downto 0);  

begin

  -------------------------------------------------------------------------
  -- Signal Renaming to make code more readable
  -------------------------------------------------------------------------
  -- Rename signal to push button, which is a better description of KEY 
  -- input (which should be labelled as KEY_n since it is active low).
  push_button          <= not key; 
  hps_and_fabric_reset <= push_button(1);
  fabric_reset         <= push_button(0);

  -------------------------------------------------------------------------
  -- Control Audio Mini LEDs using switches
  -------------------------------------------------------------------------
  audio_mini_leds <= audio_mini_switches;

  -------------------------------------------------------------------------
  -- AD1939
  -------------------------------------------------------------------------
  ad1939_rst_codec_n <= '1'; -- hold AD1939 out of reset

  -------------------------------------------------------------------------
  -- TPA6130
  -------------------------------------------------------------------------
  tpa6130_power_off <= '1'; --! Enable the headphone amplifier output

  -------------------------------------------------------------------------
  -- SoC System Connections
  -------------------------------------------------------------------------
  u0 : component soc_system_passthrough
    port map (
      -- clock and data connections to AD1939
      ad1939_physical_abclk_clk  => ad1939_adc_abclk,
      ad1939_physical_alrclk_clk => ad1939_adc_alrclk,
      ad1939_physical_mclk_clk   => ad1939_mclk,
      ad1939_physical_asdata2    => ad1939_adc_asdata2,
      ad1939_physical_dbclk      => ad1939_dac_dbclk,
      ad1939_physical_dlrclk     => ad1939_dac_dlrclk,
      ad1939_physical_dsdata1    => ad1939_dac_dsdata1,

      -- HPS SPI #0 connection to AD1939
      hps_spim0_txd          => ad1939_spi_cin,
      hps_spim0_rxd          => ad1939_spi_cout,
      hps_spim0_ss_in_n      => '1',
      hps_spim0_ssi_oe_n     => open,
      hps_spim0_ss_0_n       => ad1939_spi_clatch_n,
      hps_spim0_ss_1_n       => open,
      hps_spim0_ss_2_n       => open,
      hps_spim0_ss_3_n       => open,
      hps_spim0_sclk_out_clk => ad1939_spi_cclk,

      -- HPS I2C #1 connection to TPA6130
      hps_i2c0_out_data   => i2c_serial_sda_oe,
      hps_i2c0_sda        => i2c_0_i2c_serial_sda_in,
      hps_i2c0_clk_clk    => serial_scl_oe,
      hps_i2c0_scl_in_clk => i2c_serial_scl_in,

      -- HPS Clock and Resets
      hps_clk_clk                => fpga_clk1_50,
      hps_and_fabric_reset_reset => hps_and_fabric_reset,
      fabric_reset_reset         => fabric_reset,

      -- HPS Ethernet
      hps_io_hps_io_emac1_inst_tx_clk => hps_enet_gtx_clk,
      hps_io_hps_io_emac1_inst_txd0   => hps_enet_tx_data(0),
      hps_io_hps_io_emac1_inst_txd1   => hps_enet_tx_data(1),
      hps_io_hps_io_emac1_inst_txd2   => hps_enet_tx_data(2),
      hps_io_hps_io_emac1_inst_txd3   => hps_enet_tx_data(3),
      hps_io_hps_io_emac1_inst_rxd0   => hps_enet_rx_data(0),
      hps_io_hps_io_emac1_inst_mdio   => hps_enet_mdio,
      hps_io_hps_io_emac1_inst_mdc    => hps_enet_mdc,
      hps_io_hps_io_emac1_inst_rx_ctl => hps_enet_rx_dv,
      hps_io_hps_io_emac1_inst_tx_ctl => hps_enet_tx_en,
      hps_io_hps_io_emac1_inst_rx_clk => hps_enet_rx_clk,
      hps_io_hps_io_emac1_inst_rxd1   => hps_enet_rx_data(1),
      hps_io_hps_io_emac1_inst_rxd2   => hps_enet_rx_data(2),
      hps_io_hps_io_emac1_inst_rxd3   => hps_enet_rx_data(3),

      -- HPS USB OTG
      hps_io_hps_io_usb1_inst_d0  => hps_usb_data(0),
      hps_io_hps_io_usb1_inst_d1  => hps_usb_data(1),
      hps_io_hps_io_usb1_inst_d2  => hps_usb_data(2),
      hps_io_hps_io_usb1_inst_d3  => hps_usb_data(3),
      hps_io_hps_io_usb1_inst_d4  => hps_usb_data(4),
      hps_io_hps_io_usb1_inst_d5  => hps_usb_data(5),
      hps_io_hps_io_usb1_inst_d6  => hps_usb_data(6),
      hps_io_hps_io_usb1_inst_d7  => hps_usb_data(7),
      hps_io_hps_io_usb1_inst_clk => hps_usb_clkout,
      hps_io_hps_io_usb1_inst_stp => hps_usb_stp,
      hps_io_hps_io_usb1_inst_dir => hps_usb_dir,
      hps_io_hps_io_usb1_inst_nxt => hps_usb_nxt,

      -- HPS SD Card
      hps_io_hps_io_sdio_inst_cmd => hps_sd_cmd,
      hps_io_hps_io_sdio_inst_d0  => hps_sd_data(0),
      hps_io_hps_io_sdio_inst_d1  => hps_sd_data(1),
      hps_io_hps_io_sdio_inst_clk => hps_sd_clk,
      hps_io_hps_io_sdio_inst_d2  => hps_sd_data(2),
      hps_io_hps_io_sdio_inst_d3  => hps_sd_data(3),

      -- HPS SPI #1
      hps_io_hps_io_spim1_inst_clk  => hps_spim_clk,
      hps_io_hps_io_spim1_inst_mosi => hps_spim_mosi,
      hps_io_hps_io_spim1_inst_miso => hps_spim_miso,
      hps_io_hps_io_spim1_inst_ss0  => hps_spim_ss,

      -- HPS UART
      hps_io_hps_io_uart0_inst_rx => hps_uart_rx,
      hps_io_hps_io_uart0_inst_tx => hps_uart_tx,

      -- HPS I2C #2
      hps_io_hps_io_i2c1_inst_sda => hps_i2c1_sdat,
      hps_io_hps_io_i2c1_inst_scl => hps_i2c1_sclk,

      -- HPS GPIO
      hps_io_hps_io_gpio_inst_gpio09 => hps_conv_usb_n,
      hps_io_hps_io_gpio_inst_gpio35 => hps_enet_int_n,
      hps_io_hps_io_gpio_inst_gpio40 => hps_ltc_gpio,
      hps_io_hps_io_gpio_inst_gpio53 => hps_led,
      hps_io_hps_io_gpio_inst_gpio54 => hps_key,
      hps_io_hps_io_gpio_inst_gpio61 => hps_gsensor_int,

      -- HPS DDR3 DRAM
      memory_mem_a       => hps_ddr3_addr,
      memory_mem_ba      => hps_ddr3_ba,
      memory_mem_ck      => hps_ddr3_ck_p,
      memory_mem_ck_n    => hps_ddr3_ck_n,
      memory_mem_cke     => hps_ddr3_cke,
      memory_mem_cs_n    => hps_ddr3_cs_n,
      memory_mem_ras_n   => hps_ddr3_ras_n,
      memory_mem_cas_n   => hps_ddr3_cas_n,
      memory_mem_we_n    => hps_ddr3_we_n,
      memory_mem_reset_n => hps_ddr3_reset_n,
      memory_mem_dq      => hps_ddr3_dq,
      memory_mem_dqs     => hps_ddr3_dqs_p,
      memory_mem_dqs_n   => hps_ddr3_dqs_n,
      memory_mem_odt     => hps_ddr3_odt,
      memory_mem_dm      => hps_ddr3_dm,
      memory_oct_rzqin   => hps_ddr3_rzq
    );

  -------------------------------------------------------------------------
  -- Tri-state buffer the I2C signals
  -------------------------------------------------------------------------
  ubuf1 : component alt_iobuf
    port map (
      i  => '0',
      oe => i2c_serial_sda_oe,
      io => tpa6130_i2c_sda,
      o  => i2c_0_i2c_serial_sda_in
    );

  ubuf2 : component alt_iobuf
    port map (
      i  => '0',
      oe => serial_scl_oe,
      io => tpa6130_i2c_scl,
      o  => i2c_serial_scl_in
    );

  -------------------------------------------------------------------------
  -- DE10-Nano Board (terminate unused output signals)
  -- Note: Modify appropriately if you use these signals to avoid
  --       multiple driver errors.
  -------------------------------------------------------------------------
  led               <= (others => '0');
  audio_mini_gpio_0 <= (others => 'Z');
  audio_mini_gpio_1 <= (others => 'Z');
  arduino_io        <= (others => 'Z');
  arduino_reset_n   <= 'Z';
  adc_convst        <= '0';
  adc_sck           <= '0';
  adc_sdi           <= '0';

end architecture de10nano_arch;
