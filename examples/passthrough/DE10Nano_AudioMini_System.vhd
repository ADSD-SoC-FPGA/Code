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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

LIBRARY altera;
USE altera.altera_primitives_components.all;

---------------------------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
---------------------------------------------------------------------------
entity DE10Nano_AudioMini_System is
    port(
        -------------------------------------------------------------------
        --  CLOCK Inputs
        --  See DE10 Nano User Manual page 23
        -------------------------------------------------------------------
        FPGA_CLK1_50  :  in std_logic;	  -- 50 MHz clock input #1
        FPGA_CLK2_50  :  in std_logic;	  -- 50 MHz clock input #2
        FPGA_CLK3_50  :  in std_logic;    -- 50 MHz clock input #3
			
        -------------------------------------------------------------------
        --  Push Button Inputs (KEY) 
        --  See DE10 Nano User Manual page 24
        --  The KEY push button inputs produce a '0' when pressed (asserted)
        --  and produces a '1' in the rest (non-pushed) state
        --  a better name for KEY would be Push_Button_n 
        -------------------------------------------------------------------
        KEY : in std_logic_vector(1 downto 0);	-- Two Pushbuttons (active low)
				
        -------------------------------------------------------------------
        --  Slide Switch Inputs (SW) 
        --  See DE10 Nano User Manual page 25
        --  The slide switches produce a '0' when in the down position 
        --  (towards the edge of the board)
        -------------------------------------------------------------------
        SW  : in std_logic_vector(3 downto 0);	-- Four Slide Switches 
				
		----------------------------------------
		--  LED Outputs 
		--  See DE10 Nano User Manual page 26
		--  Setting LED to 1 will turn it on
		----------------------------------------
		LED : out std_logic_vector(7 downto 0);	 -- Eight LEDs
		
		
        -------------------------------------------------------------------
        --  GPIO Expansion Headers (40-pin)
        --  See DE10 Nano User Manual page 27
        --  Pin 11 = 5V supply (1A max)
        --  Pin 29 - 3.3 supply (1.5A max)
        --  Pins 12, 30 GND
        --  Note: the DE10-Nano GPIO_0 & GPIO_1 signals have been replaced
        --  by the signals Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1
        --  because of the DE10-Nano GPIO pins that have been dedicated to 
        --  the Audio Mini plug-in card.  The new signals 
        --  Audio_Mini_GPIO_0 & Audio_Mini_GPIO_1 contain the available GPIO.
        -------------------------------------------------------------------
        --GPIO_0 : inout std_logic_vector(35 downto 0);			      -- The 40 pin header on the top of the board
        --GPIO_1 : inout std_logic_vector(35 downto 0);			      -- The 40 pin header on the bottom of the board 
        Audio_Mini_GPIO_0 : inout std_logic_vector(33 downto 0);  -- 34 available I/O pins on GPIO_0
        Audio_Mini_GPIO_1 : inout std_logic_vector(12 downto 0);  -- 13 available I/O pins on GPIO_1 
	
        -------------------------------------------------------------------
        --  AD1939 Audio Codec Physical Connection Signals
        -------------------------------------------------------------------
        -- AD1939 clock and Reset
        AD1939_MCLK         : in  std_logic;   -- 12.288 MHz clock driving AD1939   
        AD1939_RST_CODEC_n  : out std_logic;  
        -- AD1939 SPI
        AD1939_spi_CIN      : out std_logic;   -- AD1939 SPI signal = mosi data to AD1939 registers     
        AD1939_spi_CLATCH_n : out std_logic;   -- AD1939 SPI signal = ss_n: slave select (active low)  
        AD1939_spi_CCLK     : out std_logic;   -- AD1939 SPI signal = sclk: serial clock               
        AD1939_spi_COUT     : in  std_logic;   -- AD1939 SPI signal = miso data from AD1939 registers  
        -- AD1939 ADC Serial Data
        AD1939_ADC_ABCLK    : in  std_logic;   -- Serial data from AD1939 pin 28 ABCLK,   Bit Clock for ADCs (Master Mode)
        AD1939_ADC_ALRCLK   : in  std_logic;   -- Serial data from AD1939 pin 29 ALRCLK,  LR Clock for ADCs  (Master Mode)
        AD1939_ADC_ASDATA2 	: in  std_logic;   -- Serial data from AD1939 pin 26 ASDATA2, ADC2 24-bit normal stereo serial mode
        -- AD1939 DAC Serial Data
        AD1939_DAC_DBCLK    : out std_logic;   -- Serial data to   AD1939 pin 21 DBCLK,   Bit Clock for DACs (Slave Mode)
        AD1939_DAC_DLRCLK   : out std_logic;   -- Serial data to   AD1939 pin 22 DLRCLK,  LR Clock for DACs  (Slave Mode)
        AD1939_DAC_DSDATA1  : out std_logic;   -- Serial data to   AD1939 pin 20 DSDATA1, DAC1 24-bit normal stereo serial mode
		
        -------------------------------------------------------------------
        --  Headphone Amplifier TI TPA6130 Physical connection signals
        -------------------------------------------------------------------
        TPA6130_i2c_SDA   : inout std_logic;
        TPA6130_i2c_SCL   : inout std_logic;
        TPA6130_power_off : out   std_logic;
				
        -------------------------------------------------------------------
        --  Digital Microphone INMP621 Physical connection signals
        -------------------------------------------------------------------
        INMP621_mic_CLK       : out std_logic;
        INMP621_mic_DATA      : in  std_logic;
	
        -------------------------------------------------------------------
        --  Audio Mini LEDs and Switches
        -------------------------------------------------------------------
        Audio_Mini_LEDs     : out std_logic_vector(3 downto 0);					
        Audio_Mini_SWITCHES : in  std_logic_vector(3 downto 0);					
		
        -------------------------------------------------------------------
        --  Arduino Uno R3 Expansion Header
        --  See DE10 Nano User Manual page 30
        --  500 ksps, 8-channel, 12-bit ADC
        -------------------------------------------------------------------
		ARDUINO_IO		  : inout STD_LOGIC_VECTOR(15 downto 0);  -- 16 Arduino I/O
		ARDUINO_RESET_N : inout STD_LOGIC;                      -- Reset signal, active low
		
        -------------------------------------------------------------------
        --  ADC
        --  See DE10 Nano User Manual page 33
        --  500 ksps, 8-channel, 12-bit ADC
        -------------------------------------------------------------------
        ADC_CONVST : out STD_LOGIC;   -- ADC Conversion Start
        ADC_SCK	   : out STD_LOGIC;   -- ADC Serial Data Clock
        ADC_SDI	   : out STD_LOGIC;   -- ADC Serial Data Input  (FPGA to ADC)
        ADC_SDO	   : in  STD_LOGIC;   -- ADC Serial Data Output (ADC to FPGA)
			
        -------------------------------------------------------------------
        --  Hard Processor System (HPS) 
        --  See DE10 Nano User Manual page 36
        -------------------------------------------------------------------
        HPS_CONV_USB_N          : inout STD_LOGIC;
        HPS_DDR3_ADDR           : out STD_LOGIC_VECTOR(14 downto 0);
        HPS_DDR3_BA             : out STD_LOGIC_VECTOR(2 downto 0);
        HPS_DDR3_CAS_N          : out STD_LOGIC;
        HPS_DDR3_CKE            : out STD_LOGIC;
        HPS_DDR3_CK_N           : out STD_LOGIC;
        HPS_DDR3_CK_P           : out STD_LOGIC;
        HPS_DDR3_CS_N           : out STD_LOGIC;
        HPS_DDR3_DM             : out STD_LOGIC_VECTOR(3 downto 0);
        HPS_DDR3_DQ             : inout STD_LOGIC_VECTOR(31 downto 0);
        HPS_DDR3_DQS_N          : inout STD_LOGIC_VECTOR(3 downto 0);
        HPS_DDR3_DQS_P          : inout STD_LOGIC_VECTOR(3 downto 0);
        HPS_DDR3_ODT            : out STD_LOGIC;
        HPS_DDR3_RAS_N          : out STD_LOGIC;
        HPS_DDR3_RESET_N        : out STD_LOGIC;
        HPS_DDR3_RZQ            : in STD_LOGIC;
        HPS_DDR3_WE_N           : out STD_LOGIC;
        HPS_ENET_GTX_CLK        : out STD_LOGIC;
        HPS_ENET_INT_N          : inout STD_LOGIC;
        HPS_ENET_MDC            : out STD_LOGIC;
        HPS_ENET_MDIO           : inout STD_LOGIC;
        HPS_ENET_RX_CLK			    : in STD_LOGIC;
        HPS_ENET_RX_DATA        : in STD_LOGIC_VECTOR(3 downto 0);
        HPS_ENET_RX_DV          : in STD_LOGIC;
        HPS_ENET_TX_DATA        : out STD_LOGIC_VECTOR(3 downto 0);
        HPS_ENET_TX_EN          : out STD_LOGIC;
        HPS_GSENSOR_INT         : inout STD_LOGIC;
        HPS_I2C0_SCLK           : inout STD_LOGIC;
        HPS_I2C0_SDAT           : inout STD_LOGIC;
        HPS_I2C1_SCLK           : inout STD_LOGIC;
        HPS_I2C1_SDAT           : inout STD_LOGIC;
        HPS_KEY             	  : inout STD_LOGIC;
        HPS_LED         		    : inout STD_LOGIC;
        HPS_LTC_GPIO            : inout STD_LOGIC;
        HPS_SD_CLK              : out STD_LOGIC;
        HPS_SD_CMD      		    : inout STD_LOGIC;
        HPS_SD_DATA             : inout STD_LOGIC_VECTOR(3 downto 0);
        HPS_SPIM_CLK            : out STD_LOGIC;
        HPS_SPIM_MISO       	  : in STD_LOGIC;
        HPS_SPIM_MOSI       	  : out STD_LOGIC;
        HPS_SPIM_SS     		    : inout STD_LOGIC;
        HPS_UART_RX             : in STD_LOGIC;
        HPS_UART_TX             : out STD_LOGIC;
        HPS_USB_DATA            : inout STD_LOGIC_VECTOR(7 downto 0);
        HPS_USB_CLKOUT          : in STD_LOGIC;
        HPS_USB_STP             : out STD_LOGIC;
        HPS_USB_DIR             : in STD_LOGIC;
        HPs_USB_NXT             : in STD_LOGIC
    );
end entity DE10Nano_AudioMini_System;
---------------------------------------------------------------------------


---------------------------------------------------------------------------
architecture DE10Nano_arch of DE10Nano_AudioMini_System is

    --------------------------------------------------------------
    -- SoC Component from Intel Platform Designer
    --------------------------------------------------------------
    component soc_system is
        port (
            ad1939_physical_asdata2             : in    std_logic                     := 'X';             -- asdata2
            ad1939_physical_dbclk               : out   std_logic;                                        -- dbclk
            ad1939_physical_dlrclk              : out   std_logic;                                        -- dlrclk
            ad1939_physical_dsdata1             : out   std_logic;                                        -- dsdata1
            clk_clk                             : in    std_logic                     := 'X';             -- clk
            ad1939_abclk_clk                    : in    std_logic                     := 'X';             -- clk
            ad1939_alrclk_clk                   : in    std_logic                     := 'X';             -- clk
            ad1939_mclk_clk                     : in    std_logic                     := 'X';             -- clk
            hps_f2h_cold_reset_req_reset_n      : in    std_logic                     := 'X';             -- reset_n
            hps_f2h_debug_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
            hps_f2h_warm_reset_req_reset_n      : in    std_logic                     := 'X';             -- reset_n
            hps_h2f_reset_reset_n               : out   std_logic;                                        -- reset_n
            hps_hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_hps_io_hps_io_emac1_inst_RXD0   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_hps_io_hps_io_emac1_inst_MDIO   : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_hps_io_hps_io_emac1_inst_MDC    : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_hps_io_hps_io_emac1_inst_RX_CTL : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_hps_io_hps_io_emac1_inst_TX_CTL : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_hps_io_hps_io_emac1_inst_RX_CLK : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_hps_io_hps_io_emac1_inst_RXD1   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_hps_io_hps_io_emac1_inst_RXD2   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_hps_io_hps_io_emac1_inst_RXD3   : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
        	  hps_hps_io_hps_io_sdio_inst_CMD     : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_hps_io_hps_io_sdio_inst_D0      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_hps_io_hps_io_sdio_inst_D1      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_hps_io_hps_io_sdio_inst_CLK     : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_hps_io_hps_io_sdio_inst_D2      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_hps_io_hps_io_sdio_inst_D3      : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
    	    	hps_hps_io_hps_io_usb1_inst_D0      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_hps_io_hps_io_usb1_inst_D1      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_hps_io_hps_io_usb1_inst_D2      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_hps_io_hps_io_usb1_inst_D3      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_hps_io_hps_io_usb1_inst_D4      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_hps_io_hps_io_usb1_inst_D5      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_hps_io_hps_io_usb1_inst_D6      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_hps_io_hps_io_usb1_inst_D7      : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_hps_io_hps_io_usb1_inst_CLK     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_hps_io_hps_io_usb1_inst_STP     : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_hps_io_hps_io_usb1_inst_DIR     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_hps_io_hps_io_usb1_inst_NXT     : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_hps_io_hps_io_spim1_inst_CLK    : out   std_logic;                                        -- hps_io_spim1_inst_CLK
            hps_hps_io_hps_io_spim1_inst_MOSI   : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
            hps_hps_io_hps_io_spim1_inst_MISO   : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
            hps_hps_io_hps_io_spim1_inst_SS0    : out   std_logic;                                        -- hps_io_spim1_inst_SS0
            hps_hps_io_hps_io_uart0_inst_RX     : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_hps_io_hps_io_uart0_inst_TX     : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_hps_io_hps_io_i2c1_inst_SDA     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
            hps_hps_io_hps_io_i2c1_inst_SCL     : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
            hps_hps_io_hps_io_gpio_inst_GPIO09  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
            hps_hps_io_hps_io_gpio_inst_GPIO35  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
            hps_hps_io_hps_io_gpio_inst_GPIO40  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
            hps_hps_io_hps_io_gpio_inst_GPIO53  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
            hps_hps_io_hps_io_gpio_inst_GPIO54  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
            hps_hps_io_hps_io_gpio_inst_GPIO61  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
            hps_i2c0_out_data                   : out   std_logic;                                        -- out_data
            hps_i2c0_sda                        : in    std_logic                     := 'X';             -- sda
            hps_i2c0_clk_clk                    : out   std_logic;                                        -- clk
            hps_i2c0_scl_in_clk                 : in    std_logic                     := 'X';             -- clk
            hps_spim0_txd                       : out   std_logic;                                        -- txd
            hps_spim0_rxd                       : in    std_logic                     := 'X';             -- rxd
            hps_spim0_ss_in_n                   : in    std_logic                     := 'X';             -- ss_in_n
            hps_spim0_ssi_oe_n                  : out   std_logic;                                        -- ssi_oe_n
            hps_spim0_ss_0_n                    : out   std_logic;                                        -- ss_0_n
            hps_spim0_ss_1_n                    : out   std_logic;                                        -- ss_1_n
            hps_spim0_ss_2_n                    : out   std_logic;                                        -- ss_2_n
            hps_spim0_ss_3_n                    : out   std_logic;                                        -- ss_3_n
            hps_spim0_sclk_out_clk              : out   std_logic;                                        -- clk
            memory_mem_a                        : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                       : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                       : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                     : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                      : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                     : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                    : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                    : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                     : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n                  : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                       : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                      : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                    : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                      : out   std_logic;                                        -- mem_odt
            memory_mem_dm                       : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                    : in    std_logic                     := 'X';             -- oct_rzqin
            reset_reset_n                       : in    std_logic                     := 'X'              -- reset_n
        );
    end component soc_system;
	 
    -----------------------------------------------------------------------
    --Tristate buffer with pullup for i2c lines
    -----------------------------------------------------------------------
    component alt_iobuf
    generic(
        io_standard           : string  := "3.3-V LVTTL";
        current_strength      : string  := "maximum current";
        slew_rate             : integer := -1;
        slow_slew_rate        : string  := "NONE";
        location              : string  := "NONE";
        enable_bus_hold       : string  := "NONE";
        weak_pull_up_resistor : string  := "ON";
        termination           : string  := "NONE";
        input_termination     : string  := "NONE";
        output_termination    : string  := "NONE" );
    port(
        i  : in std_logic;
        oe : in std_logic;
        io : inout std_logic;
        o  : out std_logic);
    end component;
		
    -----------------------------------------------------------------------
    -- Signal declarations
    -----------------------------------------------------------------------  	
    signal hps_fpga_reset_n         : STD_LOGIC;
    signal hps_reset_req            : STD_LOGIC_VECTOR(2 downto 0);
    signal hps_cold_reset           : STD_LOGIC;
    signal hps_warm_reset           : STD_LOGIC;
    signal hps_debug_reset          : STD_LOGIC;
    signal hps_h2f_reset            : STD_LOGIC;
    signal i2c_0_i2c_serial_sda_in  : STD_LOGIC;
    signal i2c_serial_scl_in        : STD_LOGIC;
    signal i2c_serial_sda_oe        : STD_LOGIC;
    signal serial_scl_oe            : STD_LOGIC;
    signal system_rst               : std_logic;  --  Global reset pin
    signal Push_Button              : std_logic_vector(1 downto 0);  -- a better description of KEY input, which should really be labelled as KEY_n
    signal reset                    : std_logic;
      
begin

    -----------------------------------------------------------------------
    -- Signal Renaming to make code more readable
    -----------------------------------------------------------------------
    Push_Button    <= not KEY;  -- Rename signal to push button, which is a better description of KEY input (which really should be labelled as KEY_n since it is active low).
    reset          <= Push_Button(1);
    hps_cold_reset <= reset;
	
    -----------------------------------------------------------------------
    -- Control Audio Mini LEDs using switches
    -----------------------------------------------------------------------
    Audio_Mini_LEDs <= Audio_Mini_switches;

    -----------------------------------------------------------------------
    -- AD1939
    -----------------------------------------------------------------------
    AD1939_RST_CODEC_n <= '1'; -- hold AD1939 out of reset
	
    -----------------------------------------------------------------------
    -- TPA6130
    -----------------------------------------------------------------------
    TPA6130_power_off <= '1';  --! Enable the headphone amplifier output
  
    -----------------------------------------------------------------------
    -- HPS
    -----------------------------------------------------------------------
    hps_debug_reset <= '0';
    hps_warm_reset  <= '0';
	
    -----------------------------------------------------------------------
    -- SoC System Connections
    -----------------------------------------------------------------------
    u0 : component soc_system
        port map (
            -- clock and data connections to AD1939
            ad1939_abclk_clk                    => AD1939_ADC_ABCLK,
            ad1939_alrclk_clk                   => AD1939_ADC_ALRCLK,
            ad1939_mclk_clk                     => AD1939_MCLK,                     
            ad1939_physical_asdata2             => AD1939_ADC_ASDATA2,
            ad1939_physical_dbclk               => AD1939_DAC_DBCLK,
            ad1939_physical_dlrclk              => AD1939_DAC_DLRCLK,
            ad1939_physical_dsdata1             => AD1939_DAC_DSDATA1,
				
            -- HPS SPI #0 connection to AD1939
            hps_spim0_txd                       => AD1939_spi_CIN,                                                        
            hps_spim0_rxd                       => AD1939_spi_COUT,                                                        
            hps_spim0_ss_in_n                   => '1',                                                 
            hps_spim0_ssi_oe_n                  => open,                                                  
            hps_spim0_ss_0_n                    => AD1939_spi_CLATCH_n,                                                    
            hps_spim0_ss_1_n                    => open,                                                     
            hps_spim0_ss_2_n                    => open,                                                    
            hps_spim0_ss_3_n                    => open,                                                     
            hps_spim0_sclk_out_clk              => AD1939_spi_CCLK,
				
            -- HPS I2C #1 connection to TPA6130
            hps_i2c0_out_data                   => i2c_serial_sda_oe,           
            hps_i2c0_sda                        => i2c_0_i2c_serial_sda_in,       
            hps_i2c0_clk_clk                    => serial_scl_oe,               
            hps_i2c0_scl_in_clk                 => i2c_serial_scl_in,       
				
            -- HPS Clock and Reset
            clk_clk                             => FPGA_CLK1_50,
            reset_reset_n                       => not hps_cold_reset,
            hps_f2h_cold_reset_req_reset_n      => not hps_cold_reset,
            hps_f2h_debug_reset_req_reset_n     => not hps_debug_reset,
            hps_f2h_warm_reset_req_reset_n      => not hps_warm_reset,
            hps_h2f_reset_reset_n               => hps_h2f_reset,
				
            -- HPS Ethernet
            hps_hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK,
            hps_hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),
            hps_hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),
            hps_hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2), 
            hps_hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),
            hps_hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),
            hps_hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,
            hps_hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,
            hps_hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV,
            hps_hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN,
            hps_hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK,
            hps_hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),
            hps_hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),
            hps_hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),
				
            -- HPS USB OTG
            hps_hps_io_hps_io_usb1_inst_D0      => HPS_USB_DATA(0),
            hps_hps_io_hps_io_usb1_inst_D1      => HPS_USB_DATA(1),
            hps_hps_io_hps_io_usb1_inst_D2      => HPS_USB_DATA(2),
            hps_hps_io_hps_io_usb1_inst_D3      => HPS_USB_DATA(3),
            hps_hps_io_hps_io_usb1_inst_D4      => HPS_USB_DATA(4),
            hps_hps_io_hps_io_usb1_inst_D5      => HPS_USB_DATA(5),
            hps_hps_io_hps_io_usb1_inst_D6      => HPS_USB_DATA(6),
            hps_hps_io_hps_io_usb1_inst_D7      => HPS_USB_DATA(7),
            hps_hps_io_hps_io_usb1_inst_CLK     => HPS_USB_CLKOUT,
            hps_hps_io_hps_io_usb1_inst_STP     => HPS_USB_STP,
            hps_hps_io_hps_io_usb1_inst_DIR     => HPS_USB_DIR,
            hps_hps_io_hps_io_usb1_inst_NXT     => HPS_USB_NXT,
				
            -- HPS SD Card
            hps_hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,
            hps_hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),
            hps_hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),
            hps_hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,
            hps_hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),
            hps_hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),
				
            -- HPS SPI #1
            hps_hps_io_hps_io_spim1_inst_CLK    => HPS_SPIM_CLK,
            hps_hps_io_hps_io_spim1_inst_MOSI   => HPS_SPIM_MOSI,
            hps_hps_io_hps_io_spim1_inst_MISO   => HPS_SPIM_MISO,
            hps_hps_io_hps_io_spim1_inst_SS0    => HPS_SPIM_SS,
				
            -- HPS UART
            hps_hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,
            hps_hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,
				
            -- HPS I2C #2
            hps_hps_io_hps_io_i2c1_inst_SDA     => HPS_I2C1_SDAT,
            hps_hps_io_hps_io_i2c1_inst_SCL     => HPS_I2C1_SCLK,
				
            -- HPS GPIO
            hps_hps_io_hps_io_gpio_inst_GPIO09  => HPS_CONV_USB_N,
            hps_hps_io_hps_io_gpio_inst_GPIO35  => HPS_ENET_INT_N,
            hps_hps_io_hps_io_gpio_inst_GPIO40  => HPS_LTC_GPIO,
            hps_hps_io_hps_io_gpio_inst_GPIO53  => HPS_LED,
            hps_hps_io_hps_io_gpio_inst_GPIO54  => HPS_KEY,
            hps_hps_io_hps_io_gpio_inst_GPIO61  => HPS_GSENSOR_INT,
				
            -- HPS DDR3 DRAM
            memory_mem_a                        => HPS_DDR3_ADDR,
            memory_mem_ba                       => HPS_DDR3_BA,
            memory_mem_ck                       => HPS_DDR3_CK_P,
            memory_mem_ck_n                     => HPS_DDR3_CK_N,
            memory_mem_cke                      => HPS_DDR3_CKE,
            memory_mem_cs_n                     => HPS_DDR3_CS_N,
            memory_mem_ras_n                    => HPS_DDR3_RAS_N,
            memory_mem_cas_n                    => HPS_DDR3_CAS_N,
            memory_mem_we_n                     => HPS_DDR3_WE_N,
            memory_mem_reset_n                  => HPS_DDR3_RESET_N,
            memory_mem_dq                       => HPS_DDR3_DQ,
            memory_mem_dqs                      => HPS_DDR3_DQS_P,
            memory_mem_dqs_n                    => HPS_DDR3_DQS_N,
            memory_mem_odt                      => HPS_DDR3_ODT,
            memory_mem_dm                       => HPS_DDR3_DM,
            memory_oct_rzqin                    => HPS_DDR3_RZQ				
        );

    -----------------------------------------------------------------------
    -- Tri-state buffer the I2C signals
    -----------------------------------------------------------------------
    ubuf1 : component alt_iobuf
    port map(
        i   => '0',
        oe  => i2c_serial_sda_oe,
        io  => TPA6130_i2c_SDA,
        o   => i2c_0_i2c_serial_sda_in
    );
	
    ubuf2 : component alt_iobuf
    port map(
        i   => '0',
        oe  => serial_scl_oe,
        io  => TPA6130_i2c_SCL,
        o   => i2c_serial_scl_in
    );	
		
	
    -----------------------------------------------------------------------
    -- DE10-Nano Board (terminate unused output signals)
    -- Note: Modify appropriately if you use these signals to avoid
    --       multiple driver errors.
    -----------------------------------------------------------------------
    LED               <= (others => '0');
    Audio_Mini_GPIO_0 <= (others => 'Z');
    Audio_Mini_GPIO_1 <= (others => 'Z');
    ARDUINO_IO		    <= (others => 'Z');
    ARDUINO_RESET_N   <= 'Z';
    ADC_CONVST	      <= '0'; 				
    ADC_SCK           <= '0';			
    ADC_SDI			      <= '0';
		
end architecture DE10Nano_arch;
