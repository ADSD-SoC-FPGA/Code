entity de10nano_top is
  port (
    ----------------------------------------
    --  Clock inputs
    --  See DE10 Nano User Manual page 23
    ----------------------------------------
    fpga_clk1_50 : in    std_ulogic;
    fpga_clk2_50 : in    std_ulogic;
    fpga_clk3_50 : in    std_ulogic;

    ----------------------------------------
    --  HDMI
    --  See DE10 Nano User Manual page 34
    ----------------------------------------
    hdmi_i2c_scl : inout std_logic;
    hdmi_i2c_sda : inout std_logic;
    hdmi_i2s     : inout std_logic;
    hdmi_lrclk   : inout std_logic;
    hdmi_mclk    : inout std_logic;
    hdmi_sclk    : inout std_logic;
    hdmi_tx_clk  : out   std_logic;
    hdmi_tx_d    : out   std_logic_vector(23 downto 0);
    hdmi_tx_de   : out   std_logic;
    hdmi_tx_hs   : out   std_logic;
    hdmi_tx_int  : in    std_logic;
    hdmi_tx_vs   : out   std_logic;

    ----------------------------------------
    --  DDR3
    --  See DE10 Nano User Manual page 39
    ----------------------------------------
    hps_ddr3_addr    : out   std_logic_vector(14 downto 0);
    hps_ddr3_ba      : out   std_logic_vector(2 downto 0);
    hps_ddr3_cas_n   : out   std_logic;
    hps_ddr3_ck_n    : out   std_logic;
    hps_ddr3_ck_p    : out   std_logic;
    hps_ddr3_cke     : out   std_logic;
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

    ----------------------------------------
    --  Ethernet
    --  See DE10 Nano User Manual page 36
    ----------------------------------------
    hps_enet_gtx_clk : out   std_logic;
    hps_enet_int_n   : inout std_logic;
    hps_enet_mdc     : out   std_logic;
    hps_enet_mdio    : inout std_logic;
    hps_enet_rx_clk  : in    std_logic;
    hps_enet_rx_data : in    std_logic_vector(3 downto 0);
    hps_enet_rx_dv   : in    std_logic;
    hps_enet_tx_data : out   std_logic_vector(3 downto 0);
    hps_enet_tx_en   : out   std_logic;

    ----------------------------------------
    --  HPS i2c
    --  See DE10 Nano User Manual page 34
    ----------------------------------------
    hps_i2c1_sclk : inout std_logic;
    hps_i2c1_sdat : inout std_logic;

    ----------------------------------------
    --  HPS user I/O
    --  See DE10 Nano User Manual page 36
    ----------------------------------------
    hps_key : inout std_logic;
    hps_led : inout std_logic;

    ----------------------------------------
    --  HPS SD card
    --  See DE10 Nano User Manual page 42
    ----------------------------------------
    hps_sd_clk  : out   std_logic;
    hps_sd_cmd  : inout std_logic;
    hps_sd_data : inout std_logic_vector(3 downto 0);

    ----------------------------------------
    --  HPS UART
    --  See DE10 Nano User Manual page 38
    ----------------------------------------
    hps_uart_rx    : in    std_logic;
    hps_uart_tx    : out   std_logic;
    hps_conv_usb_n : inout std_logic;

    ----------------------------------------
    --  HPS USB OTG
    --  See DE10 Nano User Manual page 43
    ----------------------------------------
    hps_usb_clkout : in    std_logic;
    hps_usb_data   : inout std_logic_vector(7 downto 0);
    hps_usb_dir    : in    std_logic;
    hps_usb_nxt    : in    std_logic;
    hps_usb_stp    : out   std_logic;

    ----------------------------------------
    --  HPS accelerometer
    --  See DE10 Nano User Manual page 44
    ----------------------------------------
    hps_gsensor_int : inout std_logic;
    hps_i2c0_sclk   : inout std_logic;
    hps_i2c0_sdat   : inout std_logic;

    ----------------------------------------
    --  LTC connector
    --  See DE10 Nano User Manual page 45
    ----------------------------------------
    hps_ltc_gpio  : inout std_logic;
    hps_spim_clk  : out   std_logic;
    hps_spim_miso : in    std_logic;
    hps_spim_mosi : out   std_logic;
    hps_spim_ss   : inout std_logic;

    ----------------------------------------
    --  Push button inputs (KEY[0] and KEY[1])
    --  See DE10 Nano User Manual page 24
    --  The KEY push button inputs produce a '0'
    --  when pressed (asserted)
    --  and produce a '1' in the rest (non-pushed) state
    ----------------------------------------
    push_button_n : in    std_ulogic_vector(1 downto 0);

    ----------------------------------------
    --  Slide switch inputs (SW)
    --  See DE10 Nano User Manual page 25
    --  The slide switches produce a '0' when
    --  in the down position
    --  (towards the edge of the board)
    ----------------------------------------
    sw : in    std_ulogic_vector(3 downto 0);

    ----------------------------------------
    --  LED outputs
    --  See DE10 Nano User Manual page 26
    --  Setting LED to 1 will turn it on
    ----------------------------------------
    led : out   std_ulogic_vector(7 downto 0);

    ----------------------------------------
    --  GPIO expansion headers (40-pin)
    --  See DE10 Nano User Manual page 27
    --  Pin 11 = 5V supply (1A max)
    --  Pin 29 = 3.3 supply (1.5A max)
    --  Pins 12, 30 = GND
    ----------------------------------------
    gpio_0 : inout std_ulogic_vector(35 downto 0);
    gpio_1 : inout std_ulogic_vector(35 downto 0);

    ----------------------------------------
    --  Arudino headers
    --  See DE10 Nano User Manual page 30
    ----------------------------------------
    arduino_io      : inout std_ulogic_vector(15 downto 0);
    arduino_reset_n : inout std_ulogic;

    ----------------------------------------
    --  ADC header
    --  See DE10 Nano User Manual page 32
    ----------------------------------------
    adc_convst : out   std_ulogic;
    adc_sck    : out   std_ulogic;
    adc_sdi    : out   std_ulogic;
    adc_sdo    : in    std_ulogic
  );
end entity de10nano_top;

