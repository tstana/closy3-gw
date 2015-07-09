--==============================================================================
-- GSI Helmholtz center for Heavy Ion Research GmbH
-- CLOSY3 CBM synchronization gateware
--==============================================================================
--
-- author: Theodor Stana (t.stana@gsi.de)
--
-- date of creation: 2015-06-24
--
-- version: 1.0
--
-- description:
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

entity closy3_cbm is
  generic
  (
    -- Number of bits for the phase -- might help fit your design into the CPLD
    g_phase_num_bits : natural := 4
  );
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
    
    phasediff_o   : out std_logic_vector(g_phase_num_bits-1 downto 0)
  );
end entity closy3_cbm;

architecture behav of closy3_cbm is

  --===========================================================================
  -- Functions
  --===========================================================================
  -- Copied from
  -- http://www.ohwr.org/projects/general-cores/repository/revisions/master/changes/modules/genrams/genram_pkg.vhd
  function f_log2_size (A : natural) return natural is
  begin
    for I in 1 to 64 loop               -- Works for up to 64 bits
      if (2**I >= A) then
        return(I);
      end if;
    end loop;
    return(63);
  end function f_log2_size;

  --===========================================================================
  -- Constants
  --===========================================================================
  -- Number of cycles between rising edges
  constant c_count1_top       : natural := 8;
  constant c_count2_top       : natural := 5;
  
  -- Use clk1 or clk2 for the epoch counter
  -- ** use_clk1 = false implies use_clk2
  constant c_epoch_use_clk1   : boolean := false;

  -- Number of clk1/2 cycles until epoch
  constant c_count_epoch_top  : natural := 4096;
  
  -- Use clk1 or clk2 for latching the PHASEDIFF and SYNCED signals
  -- ** use_clk1 = false implies use_clk2
  constant c_synced_use_clk1  : boolean := true;
  
  --===========================================================================
  -- Signals
  --===========================================================================
  -- Clock phase counters
  signal count1       : unsigned(f_log2_size(c_count1_top)-1 downto 0);
  signal count2       : unsigned(f_log2_size(c_count2_top)-1 downto 0);
  signal phase1       : unsigned(g_phase_num_bits-1 downto 0);
  signal phase2       : unsigned(g_phase_num_bits-1 downto 0);
  signal phasediff    : unsigned(g_phase_num_bits-1 downto 0);
  signal synced       : std_logic;

  -- Epoch counter and pulse on epoch
  signal count_epoch  : unsigned(f_log2_size(c_count_epoch_top)-1 downto 0);
  signal epoch_p1     : std_logic;
  
  -- Internally OR all reset sources
  signal reset_int    : std_logic;

  -- Signals to delay the phase counters after reset, to account for the
  -- AD9516's delay after SYNC
  signal delay1       : std_logic;
  signal delay2       : std_logic;

--=============================================================================
-- architecture begin
--=============================================================================
begin

  --===========================================================================
  -- AD9516 synchronization logic
  --===========================================================================
  p_ad9516_sync : process (syncclk_i)
  begin
    if rising_edge(syncclk_i) then
      sync_n_o <= sync_n_i;
    end if;
  end process p_ad9516_sync;

  --===========================================================================
  -- Reset sources
  --===========================================================================
  reset_int <= (not sys_rst_n_i) or (not sync_n_i) or (not reset_n_i) or
                  (not pw_down_n_i);
                  
  --===========================================================================
  -- Synchronization logic
  --===========================================================================
  -- Clock phase counters
  p_count1 : process (clk1_i, reset_int)
  begin
    if (reset_int = '1') then
      count1 <= (others => '0');
      phase1 <= (others => '0');
      delay1 <= '1';
    elsif rising_edge(clk1_i) then
      delay1 <= '0';
      if (lock_det_i = '1') and (delay1 = '0') then
        count1 <= count1 + 1;
        if (count1 = c_count1_top-1) then
          count1 <= (others => '0');
          phase1 <= phase1 + 1;
        end if;
      end if;
    end if;
  end process p_count1;
      
  p_count2 : process (clk2_i, reset_int)
  begin
    if (reset_int = '1') then
      count2 <= (others => '0');
      phase2 <= (others => '0');
      delay2 <= '1';
    elsif rising_edge(clk2_i) then
      delay2 <= '0';
      if (lock_det_i = '1') and (delay2 = '0') then
        count2 <= count2 + 1;
        if (count2 = c_count2_top-1) then
          count2 <= (others => '0');
          phase2 <= phase2 + 1;
        end if;
      end if;
    end if;
  end process p_count2;
  
  -- Phase difference and internal synced signal generation
gen_synced_phasediff_on_clk1 : if c_synced_use_clk1 generate
  p_synced_phasediff : process (clk1_i)
  begin
    if rising_edge(clk1_i) then
      phasediff <= phase1 - phase2;
      synced    <= '0';
      if (phasediff = 0) then
        synced <= '1';
      end if;
    end if;
  end process p_synced_phasediff;
end generate gen_synced_phasediff_on_clk1;
  
gen_synced_phasediff_on_clk2 : if not c_synced_use_clk1 generate
  p_synced_phasediff : process (clk2_i)
  begin
    if rising_edge(clk2_i) then
      phasediff <= phase1 - phase2;
      synced    <= '0';
      if (phasediff = 0) then
        synced <= '1';
      end if;
    end if;
  end process p_synced_phasediff;
end generate gen_synced_phasediff_on_clk2;
  
  --===========================================================================
  -- Epoch generation
  --===========================================================================
gen_epoch_on_clk1 : if c_epoch_use_clk1 generate
  p_epoch : process (clk1_i, reset_int)
  begin
    if (reset_int = '1') then
      count_epoch <= (others => '0');
      epoch_p1    <= '0';
    elsif rising_edge(clk1_i) then
      if (lock_det_i = '1') and (synced = '1') then
        count_epoch <= count_epoch + 1;
        epoch_p1    <= '0';
        if (count_epoch = c_count_epoch_top-1) then
          count_epoch <= count_epoch + 1;
          epoch_p1    <= '1';
        end if;
      end if;
    end if;
  end process p_epoch;
end generate gen_epoch_on_clk1;
      
gen_epoch_on_clk2 : if not c_epoch_use_clk1 generate
  p_epoch : process (clk2_i, reset_int)
  begin
    if (reset_int = '1') then
        count_epoch <= (others => '0');
        epoch_p1    <= '0';
    elsif rising_edge(clk2_i) then
      if (lock_det_i = '1') and (synced = '1') then
        count_epoch <= count_epoch + 1;
        epoch_p1    <= '0';
        if (count_epoch = c_count_epoch_top-1) then
          count_epoch <= count_epoch + 1;
          epoch_p1    <= '1';
        end if;
      end if;
    end if;
  end process p_epoch;
end generate gen_epoch_on_clk2;
      
  --===========================================================================
  -- Outputs
  --===========================================================================
  -- Non-clocked
  clkdbg1_o     <= clk1_i;
  clkdbg2_o     <= clk2_i;
  
  -- Clocked, see above
  synced_o      <= epoch_p1;
  synced_led_o  <= synced;
  phasediff_o   <= std_logic_vector(phasediff);

end architecture behav;
--=============================================================================
-- architecture end
--=============================================================================
