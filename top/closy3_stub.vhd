--==============================================================================
-- GSI Helmholz center for Heavy Ion Research GmbH
-- CLOSY3 top-level file
--==============================================================================
--
-- author: Theodor Stana (t.stana@gsi.de)
--
-- date of creation: 2015-06-24
--
-- version: 1.0
--
-- description:
--    Top-level file for the gateware running on the CLPD on-board the CLOSY3
--    clock synthesizer. This file declares the interface CPLD I/O, that is in
--    accordance to the declarations in the UCF file.
--
--    Designers should start implementing custom gateware from here. Examples
--    of readily-implemented gateware can be found in the other top-level files
--    in the folder of the current source file.
--
--    NOTE: PLEASE COPY AND ADAPT THIS FOLDER, DO NOT CHANGE DIRECTLY.
--
--==============================================================================
-- GNU LESSER GENERAL PUBLIC LICENSE
--==============================================================================
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
--==============================================================================
-- last changes:
--    2015-06-24   Theodor Stana     File created
--==============================================================================
-- TODO: -
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity closy3_stub is
  port
  (
    -- Clocks
    clk1_i        : in  std_logic;
    clk2_i        : in  std_logic;
    extclk_i      : in  std_logic;
    syncclk_i     : in  std_logic; -- Note: NOT on GCLK pin
    
    -- System reset input on GSR pin
    sys_rst_n_i   : in  std_logic;
    
    -- Inputs from microcontroller
    sync_n_i      : in  std_logic;
    pw_down_n_i   : in  std_logic;
    reset_n_i     : in  std_logic;
    
    -- Inputs from AD9516
    refmon_i      : in  std_logic;
    lock_det_i    : in  std_logic;
    status_i      : in  std_logic;
    
    -- Outputs
    sync_n_o      : out std_logic;
    
    clkdbg1_o     : out std_logic;
    clkdbg2_o     : out std_logic;
    synced_o      : out std_logic;
    synced_led_o  : out std_logic;
    
    phase_diff_o  : out std_logic_vector(5 downto 0)
  );
end entity closy3_stub;

architecture behav of closy3_stub is

--=============================================================================
-- architecture begin
--=============================================================================
begin

end architecture behav;
--=============================================================================
-- architecture end
--=============================================================================
