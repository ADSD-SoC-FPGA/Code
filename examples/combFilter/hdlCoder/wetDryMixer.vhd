-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\combFilterFeedforward\wetDryMixer.vhd
-- Created: 2022-04-25 17:51:16
-- 
-- Generated by MATLAB 9.10 and HDL Coder 3.18
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: wetDryMixer
-- Source Path: combFilterFeedforward/combFilterSystem/wetDryMixer
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY wetDryMixer IS
  PORT( dryAudio                          :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        wetAudio                          :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        wetDryMix                         :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16_En16
        audioOut                          :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
        );
END wetDryMixer;


ARCHITECTURE rtl OF wetDryMixer IS

  -- Signals
  SIGNAL dryAudio_signed                  : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Constant_out1                    : std_logic;  -- ufix1
  SIGNAL wetDryMix_unsigned               : unsigned(15 DOWNTO 0);  -- ufix16_En16
  SIGNAL Subtract_sub_cast                : signed(17 DOWNTO 0);  -- sfix18_En16
  SIGNAL Subtract_sub_cast_1              : signed(17 DOWNTO 0);  -- sfix18_En16
  SIGNAL Subtract_sub_temp                : signed(17 DOWNTO 0);  -- sfix18_En16
  SIGNAL Subtract_out1                    : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Product1_mul_temp                : signed(47 DOWNTO 0);  -- sfix48_En46
  SIGNAL Product1_out1                    : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL wetAudio_signed                  : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Product2_cast                    : signed(16 DOWNTO 0);  -- sfix17_En16
  SIGNAL Product2_mul_temp                : signed(40 DOWNTO 0);  -- sfix41_En39
  SIGNAL Product2_cast_1                  : signed(39 DOWNTO 0);  -- sfix40_En39
  SIGNAL Product2_out1                    : signed(23 DOWNTO 0);  -- sfix24_En23
  SIGNAL Add1_add_cast                    : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add1_add_cast_1                  : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add1_add_temp                    : signed(24 DOWNTO 0);  -- sfix25_En23
  SIGNAL Add1_out1                        : signed(23 DOWNTO 0);  -- sfix24_En23

  ATTRIBUTE multstyle : string;

BEGIN
  -- wet signal mix
  -- 
  -- dry signal mix

  dryAudio_signed <= signed(dryAudio);

  Constant_out1 <= '1';

  wetDryMix_unsigned <= unsigned(wetDryMix);

  Subtract_sub_cast <= signed(resize(unsigned'(Constant_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0'), 18));
  Subtract_sub_cast_1 <= signed(resize(wetDryMix_unsigned, 18));
  Subtract_sub_temp <= Subtract_sub_cast - Subtract_sub_cast_1;
  Subtract_out1 <= Subtract_sub_temp(16 DOWNTO 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0';

  Product1_mul_temp <= dryAudio_signed * Subtract_out1;
  Product1_out1 <= Product1_mul_temp(46 DOWNTO 23);

  wetAudio_signed <= signed(wetAudio);

  Product2_cast <= signed(resize(wetDryMix_unsigned, 17));
  Product2_mul_temp <= Product2_cast * wetAudio_signed;
  Product2_cast_1 <= Product2_mul_temp(39 DOWNTO 0);
  Product2_out1 <= Product2_cast_1(39 DOWNTO 16);

  Add1_add_cast <= resize(Product1_out1, 25);
  Add1_add_cast_1 <= resize(Product2_out1, 25);
  Add1_add_temp <= Add1_add_cast + Add1_add_cast_1;
  
  Add1_out1 <= X"7FFFFF" WHEN (Add1_add_temp(24) = '0') AND (Add1_add_temp(23) /= '0') ELSE
      X"800000" WHEN (Add1_add_temp(24) = '1') AND (Add1_add_temp(23) /= '1') ELSE
      Add1_add_temp(23 DOWNTO 0);

  audioOut <= std_logic_vector(Add1_out1);

END rtl;

