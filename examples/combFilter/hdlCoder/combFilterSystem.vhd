-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\combFilterFeedforward\combFilterSystem.vhd
-- Created: 2022-04-25 17:51:16
-- 
-- Generated by MATLAB 9.10 and HDL Coder 3.18
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: 1.01725e-08
-- Target subsystem base rate: 1.01725e-08
-- Explicit user oversample request: 2048x
-- 
-- 
-- Clock Enable  Sample Time
-- -------------------------------------------------------------
-- ce_out        2.08333e-05
-- -------------------------------------------------------------
-- 
-- 
-- Output Signal                 Clock Enable  Sample Time
-- -------------------------------------------------------------
-- audioOut                      ce_out        2.08333e-05
-- -------------------------------------------------------------
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: combFilterSystem
-- Source Path: combFilterFeedforward/combFilterSystem
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY combFilterSystem IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        audioIn                           :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
        delayM                            :   IN    std_logic_vector(15 DOWNTO 0);  -- uint16
        b0                                :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
        bM                                :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
        wetDryMix                         :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16_En16
        ce_out                            :   OUT   std_logic;
        audioOut                          :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
        );
END combFilterSystem;


ARCHITECTURE rtl OF combFilterSystem IS

  -- Component Declarations
  COMPONENT combFilterSystem_tc
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          clk_enable                      :   IN    std_logic;
          enb                             :   OUT   std_logic;
          enb_1_1_1                       :   OUT   std_logic;
          enb_2048_1_0                    :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT combFilterFeedforward
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          audioIn                         :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
          delayM                          :   IN    std_logic_vector(15 DOWNTO 0);  -- uint16
          b0                              :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
          bM                              :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En16
          audioOut                        :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
          );
  END COMPONENT;

  COMPONENT wetDryMixer
    PORT( dryAudio                        :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
          wetAudio                        :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En23
          wetDryMix                       :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16_En16
          audioOut                        :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En23
          );
  END COMPONENT;

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL enb_1_1_1                        : std_logic;
  SIGNAL enb_2048_1_0                     : std_logic;
  SIGNAL combFilterFeedforward_out1       : std_logic_vector(23 DOWNTO 0);  -- ufix24
  SIGNAL wetDryMixer_out1                 : std_logic_vector(23 DOWNTO 0);  -- ufix24

BEGIN
  -- 
  -- Dry signal = unprocessed (raw) signal
  -- Wet signal = processed signal
  -- 
  -- wetDryMix = ratio of wet to dry signals
  -- wetDryMix = 1     (audioOut = all Wet)
  -- wetDryMix = 0     (audioOut = all Dry)
  -- wetDryMix = 0.5  (audioOut = 50/50 Wet/Dry)

  u_combFilterSystem_tc : combFilterSystem_tc
    PORT MAP( clk => clk,
              reset => reset,
              clk_enable => clk_enable,
              enb => enb,
              enb_1_1_1 => enb_1_1_1,
              enb_2048_1_0 => enb_2048_1_0
              );

  u_combFilterFeedforward : combFilterFeedforward
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              audioIn => audioIn,  -- sfix24_En23
              delayM => delayM,  -- uint16
              b0 => b0,  -- sfix16_En16
              bM => bM,  -- sfix16_En16
              audioOut => combFilterFeedforward_out1  -- sfix24_En23
              );

  u_wetDryMixer : wetDryMixer
    PORT MAP( dryAudio => audioIn,  -- sfix24_En23
              wetAudio => combFilterFeedforward_out1,  -- sfix24_En23
              wetDryMix => wetDryMix,  -- ufix16_En16
              audioOut => wetDryMixer_out1  -- sfix24_En23
              );

  ce_out <= enb_1_1_1;

  audioOut <= wetDryMixer_out1;

END rtl;

