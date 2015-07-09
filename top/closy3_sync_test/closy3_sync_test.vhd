--==============================================================================
-- GSI Helmholtz center for Heavy Ion Research GmbH
--==============================================================================
--
-- author: Theodor Stana (t.stana@gsi.de)
--
-- date of creation: 2015-07-03
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
--    2015-07-03   Theodor Stana     File created
--==============================================================================
-- TODO: -
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity closy3_sync_test is
  generic
  (
    -- Number of bits for the phase -- might help fit your design into the CPLD
    g_phase_num_bits : natural := 6
  );
  port
  (
    -- Clocks
    clk_i         : in  std_logic;
    syncclk_i     : in  std_logic; -- Note: NOT on GCLK pin
    
    -- Outputs
    sync_n_o      : out std_logic;
    dbg_o         : out std_logic;
    osc_o         : out std_logic
  );
end entity closy3_sync_test;

architecture behav of closy3_sync_test is

  --===========================================================================
  -- Signals
  --===========================================================================
  -- Clock phase counters
  signal count  : unsigned(18 downto 0) := (others => '0');
  signal sync_n : std_logic := '1';
  signal passed : std_logic := '0';
  signal state  : std_logic := '0';
  
  -- signal c : unsigned(25 downto 0);
  -- signal led : unsigned(2 downto 0);

--=============================================================================
-- architecture begin
--=============================================================================
begin

  p_count : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if (passed = '0') then
        count <= count + 1;
        case state is
          when '0' =>
            if (count = (count'range => '1')) then
              state <= '1';
            end if;
          when '1' =>
            if (count = 16383) then
              state <= '0';
              count <= (others => '0');
              passed <= '1';
            end if;
          when others =>
            count <= (others => '0');
            state <= '0';
        end case;
      end if;
    end if;
  end process p_count;

  sync_n <= not state;
  dbg_o  <= sync_n;

  p_ad9516_sync : process (syncclk_i)
  begin
    if rising_edge(syncclk_i) then
      sync_n_o <= sync_n;
      osc_o <= sync_n;
    end if;
  end process p_ad9516_sync;
  
  
  -- process (clk_i)
  -- begin
    -- if rising_edge(clk_i) then
      -- c <= c + 1;
      -- if (c = 39062500) then
        -- c   <= (others => '0');
        -- led <= led + 1;
        -- if (led = 3) then
          -- led <= (others => '0');
        -- end if;
      -- end if;
    -- end if;
  -- end process;
  
  -- led_o <= std_logic_vector(led);

end architecture behav;
--=============================================================================
-- architecture end
--=============================================================================
