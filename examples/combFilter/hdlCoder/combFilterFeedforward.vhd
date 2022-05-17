-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\combFilterFeedforward\combFilterFeedforward.vhd
-- Created: 2022-04-25 17:51:16
-- 
-- Generated by MATLAB 9.10 and HDL Coder 3.18
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: combFilterFeedforward
-- Source Path: combFilterFeedforward/combFilterSystem/combFilterFeedforward
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY combFilterFeedforward IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        audioIn                           :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        delayM                            :   IN    std_logic_vector(15 DOWNTO 0);  -- uint16
        b0                                :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
        bM                                :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
        audioOut                          :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
        );
END combFilterFeedforward;


ARCHITECTURE rtl OF combFilterFeedforward IS

  -- Component Declarations
  COMPONENT Delay
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          audioIn                         :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
          delayM                          :   IN    std_logic_vector(15 DOWNTO 0);  -- uint16
          delayedAudioOut                 :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
          );
  END COMPONENT;

  -- Signals
  SIGNAL audioIn_signed                   : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Delay_out1                       : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL Delay_out1_signed                : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL b0_signed                        : signed(15 DOWNTO 0);  -- sfix16_En16
  SIGNAL Product1_mul_temp                : signed(39 DOWNTO 0);  -- sfix40_En39
  SIGNAL Product1_out1                    : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL bM_signed                        : signed(15 DOWNTO 0);  -- sfix16_En16
  SIGNAL Product_mul_temp                 : signed(39 DOWNTO 0);  -- sfix40_En39
  SIGNAL Product_out1                     : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Add_add_cast                     : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add_add_cast_1                   : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add_add_temp                     : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add_out1                         : signed(23 DOWNTO 0);  -- sfix24_En23

  ATTRIBUTE multstyle : string;

BEGIN
  -- Feedforward Comb Filter
  -- 
  -- 
  -- https://www.dsprelated.com/freebooks/pasp/Comb_Filters.htm
  -- 
  -- Since we are targeting the FPGA fabric, the z^-M delay is implemented with a circular buffer that uses a
  -- dual port memory.  The circularBufferDPRAM is a
  -- referenced subsystem in Simulink

  u_Delay : Delay
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              audioIn => audioIn,  -- sfix24_En23
              delayM => delayM,  -- uint16
              delayedAudioOut => Delay_out1  -- sfix24_En23
              );

  audioIn_signed <= signed(audioIn);

  Delay_out1_signed <= signed(Delay_out1);

  b0_signed <= signed(b0);

  Product1_mul_temp <= audioIn_signed * b0_signed;
  Product1_out1 <= Product1_mul_temp(39 DOWNTO 16);

  bM_signed <= signed(bM);

  Product_mul_temp <= Delay_out1_signed * bM_signed;
  Product_out1 <= Product_mul_temp(39 DOWNTO 16);

  Add_add_cast <= resize(Product1_out1, 25);
  Add_add_cast_1 <= resize(Product_out1, 25);
  Add_add_temp <= Add_add_cast + Add_add_cast_1;
  
  Add_out1 <= X"7FFFFF" WHEN (Add_add_temp(24) = '0') AND (Add_add_temp(23) /= '0') ELSE
      X"800000" WHEN (Add_add_temp(24) = '1') AND (Add_add_temp(23) /= '1') ELSE
      Add_add_temp(23 DOWNTO 0);

  audioOut <= std_logic_vector(Add_out1);

END rtl;
