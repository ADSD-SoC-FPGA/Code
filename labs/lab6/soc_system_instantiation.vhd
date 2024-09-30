  u0 : component soc_system
    port map (
      -- ethernet
      hps_io_hps_io_emac1_inst_tx_clk => hps_enet_gtx_clk,
      hps_io_hps_io_emac1_inst_txd0   => hps_enet_tx_data(0),
      hps_io_hps_io_emac1_inst_txd1   => hps_enet_tx_data(1),
      hps_io_hps_io_emac1_inst_txd2   => hps_enet_tx_data(2),
      hps_io_hps_io_emac1_inst_txd3   => hps_enet_tx_data(3),
      hps_io_hps_io_emac1_inst_mdio   => hps_enet_mdio,
      hps_io_hps_io_emac1_inst_mdc    => hps_enet_mdc,
      hps_io_hps_io_emac1_inst_rx_ctl => hps_enet_rx_dv,
      hps_io_hps_io_emac1_inst_tx_ctl => hps_enet_tx_en,
      hps_io_hps_io_emac1_inst_rx_clk => hps_enet_rx_clk,
      hps_io_hps_io_emac1_inst_rxd0   => hps_enet_rx_data(0),
      hps_io_hps_io_emac1_inst_rxd1   => hps_enet_rx_data(1),
      hps_io_hps_io_emac1_inst_rxd2   => hps_enet_rx_data(2),
      hps_io_hps_io_emac1_inst_rxd3   => hps_enet_rx_data(3),
      hps_io_hps_io_gpio_inst_gpio35  => hps_enet_int_n,

      -- sd card
      hps_io_hps_io_sdio_inst_cmd => hps_sd_cmd,
      hps_io_hps_io_sdio_inst_clk => hps_sd_clk,
      hps_io_hps_io_sdio_inst_d0  => hps_sd_data(0),
      hps_io_hps_io_sdio_inst_d1  => hps_sd_data(1),
      hps_io_hps_io_sdio_inst_d2  => hps_sd_data(2),
      hps_io_hps_io_sdio_inst_d3  => hps_sd_data(3),

      -- usb
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

      -- UART
      hps_io_hps_io_uart0_inst_rx    => hps_uart_rx,
      hps_io_hps_io_uart0_inst_tx    => hps_uart_tx,
      hps_io_hps_io_gpio_inst_gpio09 => hps_conv_usb_n,

      -- LTC connector
      hps_io_hps_io_gpio_inst_gpio40 => hps_ltc_gpio,
      hps_io_hps_io_spim1_inst_clk   => hps_spim_clk,
      hps_io_hps_io_spim1_inst_mosi  => hps_spim_mosi,
      hps_io_hps_io_spim1_inst_miso  => hps_spim_miso,
      hps_io_hps_io_spim1_inst_ss0   => hps_spim_ss,
      hps_io_hps_io_i2c1_inst_sda    => hps_i2c1_sdat,
      hps_io_hps_io_i2c1_inst_scl    => hps_i2c1_sclk,

      -- I2C for accelerometer
      hps_io_hps_io_gpio_inst_gpio61 => hps_gsensor_int,
      hps_io_hps_io_i2c0_inst_sda    => hps_i2c0_sdat,
      hps_io_hps_io_i2c0_inst_scl    => hps_i2c0_sclk,

      -- HPS user I/O
      hps_io_hps_io_gpio_inst_gpio53 => hps_led,
      hps_io_hps_io_gpio_inst_gpio54 => hps_key,

      -- DDR3
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
      memory_oct_rzqin   => hps_ddr3_rzq,

      clk_clk       => fpga_clk1_50,
      reset_reset_n => -- hook up to your reset signal; note that reset_reset_n is *active-low*
    );

