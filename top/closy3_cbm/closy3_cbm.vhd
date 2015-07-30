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
    -- Use clk1_i for synchronization mechanism; else, use clk2_i
    g_use_clk1 : boolean := true;
    
    -- clk_for_sync cycles between syncclk_i rising edges
    g_cycles_to_syncclk : natural := 6250;
    
    -- clk_for_sync cycles to epoch
    g_cycles_to_epoch   : natural := 4096
  );
  port
  (
    -- Clocks
    clk1_i        : in  std_logic;
    clk2_i        : in  std_logic;

    syncclk_i     : in  std_logic; -- Note: NOT on GCLK pin

    -- Inputs from microcontroller
    sync_n_i      : in  std_logic;

    -- Outputs
    sync_n_o      : out std_logic;
    
    clkdbg1_o     : out std_logic;
    clkdbg2_o     : out std_logic;
    synced_p_o    : out std_logic;
    synced_led_o  : out std_logic
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
  -- Types
  --===========================================================================
  type t_state is (
    CHECK_N_SYNC,
    DEASSERT_SYNC,
    COUNT,
    CHECK_COUNTER
  );

  --===========================================================================
  -- Signals
  --===========================================================================
  -- Sync. FSM state signal
  signal state        : t_state;

  -- Main clock for sync logic
  signal clk_for_sync : std_logic;
  
  -- Counter
  signal counter      : unsigned(f_log2_size(g_cycles_to_syncclk)-1 downto 0);
  signal counter_rst  : std_logic;
  
  -- Synced status signal
  signal synced       : std_logic;

  -- Pulse on epoch
  signal epoch_p      : std_logic;
  
--=============================================================================
-- architecture begin
--=============================================================================
begin

  --===========================================================================
  -- Synchronization FSM
  --===========================================================================
  p_fsm : process (syncclk_i, sync_n_i)
  begin
    if (sync_n_i = '0') then
      state  <= CHECK_N_SYNC;
      synced <= '0';
    elsif rising_edge(syncclk_i) then
      case state is
        when CHECK_N_SYNC =>
          sync_n_o <= '1';
          state <= DEASSERT_SYNC;
        when DEASSERT_SYNC =>
          counter_rst <= '0';
          state <= COUNT;
        when COUNT =>
          if (counter = 0) then --g_cycles_to_syncclk-1) then
            synced <= '1';
          else
            synced <= '0';
          end if;
          state <= CHECK_COUNTER;
        when CHECK_COUNTER =>
          if (synced = '0') then
            sync_n_o    <= '0';
            counter_rst <= '1';
          end if;
          state <= CHECK_N_SYNC;
      end case;
    end if;
  end process p_fsm;
  
  --===========================================================================
  -- Counter processes
  --===========================================================================
gen_use_clk1 : if g_use_clk1 generate
  clk_for_sync <= clk1_i;
end generate gen_use_clk1;
  
gen_use_clk2 : if not g_use_clk1 generate
  clk_for_sync <= clk2_i;
end generate gen_use_clk2;
  
  p_counter : process (clk_for_sync, counter_rst)
  begin
    if (counter_rst = '1') then
      counter <= (others => '0');
    elsif rising_edge(clk_for_sync) then
      counter <= counter + 1;
      if (counter = g_cycles_to_syncclk-1) then
        counter <= (others => '0');
      end if;
      
      epoch_p <= '0';
      if (synced = '1') and (counter = g_cycles_to_epoch-1) then
        epoch_p <= '1';
      end if;
    end if;
  end process p_counter;

  --===========================================================================
  -- Outputs
  --===========================================================================
  -- Non-clocked
  clkdbg1_o <= clk1_i;
  clkdbg2_o <= clk2_i;
  
  -- Clocked, see above
  synced_p_o   <= epoch_p;
  synced_led_o <= synced;

end architecture behav;
--=============================================================================
-- architecture end
--=============================================================================
