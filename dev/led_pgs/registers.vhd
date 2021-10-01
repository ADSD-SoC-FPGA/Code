-- SPDX-License-Identifier: MIT
-- Copyright (c) 2020 Ross K. Snider.  All rights reserved.
--------------------------------------------------------------------------------
-- Description:  VHDL template for creating registers in Platform Designer
--               Appropriate modification is needed to implement more registers
--------------------------------------------------------------------------------
-- Author:       Ross K. Snider
-- Company:      Montana State University
-- Create Date:  September 30, 2021
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
--------------------------------------------------------------------------------


-----------------------------------------------------------------
-- Register signal declarations with default power up values
-----------------------------------------------------------------
signal left_gain  : std_logic_vector(31  downto 0) :=  "00000100110011001100110011001101"; -- 0.3  fixed point value (W=32, F=28)
signal right_gain : std_logic_vector(31  downto 0) :=  "00000100110011001100110011001101"; -- 0.3  fixed point value (W=32, F=28)


----------------------------------------
-- Avalon Register Read Process
----------------------------------------
avalon_register_read : process(clk)
begin
    if rising_edge(clk) and avs_s1_read = '1' then
        case avs_s1_address is
            when "00"   => avs_s1_readdata <= left_gain;
            when "01"   => avs_s1_readdata <= right_gain;
            when others => avs_s1_readdata <= (others => '0'); -- return zeros for unused registers
        end case;
    end if;
end process;

  
----------------------------------------
-- Avalon Register Write Process
----------------------------------------
avalon_register_write : process(clk, reset)
begin
    if reset = '1' then
        left_gain   <=  "00000100110011001100110011001101"; -- 0.3  reset default value
        right_gain  <=  "00000100110011001100110011001101"; -- 0.3  reset default value
    elsif rising_edge(clk) and avs_s1_write = '1' then
        case avs_s1_address is
            when "00"   => left_gain   <= avs_s1_writedata(31 downto 0);
            when "01"   => right_gain  <= avs_s1_writedata(31 downto 0);
            when others => null; -- ignore writes to unused registers
        end case;
    end if;
end process;
