--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:09:16 06/24/2015
-- Design Name:   
-- Module Name:   D:/Projects/clos3-gw/closy3/syn/closy3_cbm/cbm_tb.vhd
-- Project Name:  closy3_cbm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: closy3_cbm
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cbm_tb IS
END cbm_tb;
 
ARCHITECTURE behavior OF cbm_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT closy3_cbm
    generic (
      g_phase_num_bits : natural := 1
    );
    PORT(
         clk1_i : IN  std_logic;
         clk2_i : IN  std_logic;
         extclk_i : IN  std_logic;
         syncclk_i : IN  std_logic;
         sys_rst_n_i : IN  std_logic;
         sync_n_i : IN  std_logic;
         pw_down_n_i : IN  std_logic;
         reset_n_i : IN  std_logic;
         refmon_i : IN  std_logic;
         lock_det_i : IN  std_logic;
         status_i : IN  std_logic;
         sync_n_o : OUT  std_logic;
         clkdbg1_o : OUT  std_logic;
         clkdbg2_o : OUT  std_logic;
         synced_o : OUT  std_logic;
         synced_led_o : OUT  std_logic;
         phasediff_o : OUT  std_logic_vector(g_phase_num_bits-1 downto 0)
        );
    END COMPONENT;
    

   constant c_num_bits : natural := 1;
   
   --Inputs
   signal clk1_i : std_logic := '0';
   signal clk2_i : std_logic := '0';
   signal extclk_i : std_logic := '0';
   signal syncclk_i : std_logic := '0';
   signal sys_rst_n_i : std_logic := '0';
   signal sync_n_i : std_logic := '0';
   signal pw_down_n_i : std_logic := '0';
   signal reset_n_i : std_logic := '0';
   signal refmon_i : std_logic := '0';
   signal lock_det_i : std_logic := '0';
   signal status_i : std_logic := '0';

 	--Outputs
   signal sync_n_o : std_logic;
   signal clkdbg1_o : std_logic;
   signal clkdbg2_o : std_logic;
   signal synced_o : std_logic;
   signal synced_led_o : std_logic;
   signal phasediff_o : std_logic_vector(c_num_bits-1 downto 0);

   -- Clock period definitions
   constant clk1_i_period : time := 4 ns;
   constant clk2_i_period : time := 6.4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: closy3_cbm
      generic map (
        g_phase_num_bits => c_num_bits
      )
      PORT MAP (
          clk1_i => clk1_i,
          clk2_i => clk2_i,
          extclk_i => extclk_i,
          syncclk_i => syncclk_i,
          sys_rst_n_i => sys_rst_n_i,
          sync_n_i => sync_n_i,
          pw_down_n_i => pw_down_n_i,
          reset_n_i => reset_n_i,
          refmon_i => refmon_i,
          lock_det_i => lock_det_i,
          status_i => status_i,
          sync_n_o => sync_n_o,
          clkdbg1_o => clkdbg1_o,
          clkdbg2_o => clkdbg2_o,
          synced_o => synced_o,
          synced_led_o => synced_led_o,
          phasediff_o => phasediff_o
        );

   -- Clock process definitions
   clk1_process :process
   begin
    if (sys_rst_n_i = '1') then
      clk1_i <= '1';
      wait for clk1_i_period/2;
      clk1_i <= '0';
      wait for clk1_i_period/2;
    else
      wait until sys_rst_n_i = '1';
      wait for 10 ns;
    end if;
   end process;
 
   clk2_process :process
   begin
    if (sys_rst_n_i = '1') then
      clk2_i <= '1';
      wait for clk2_i_period/2;
      clk2_i <= '0';
      wait for clk2_i_period/2;
    else
      wait until sys_rst_n_i = '1';
      wait for 10 ns;
    end if;
   end process;

   -- -- Simulate AD9516 sync operation (without the delay)   
   -- clk1_i <= clk1 when (sync_n_i = '1') else '0';
   -- clk1_i <= clk1 when (sync_n_i = '1') else '0';

   -- Stimulus process
   stim_proc: process
   begin
      lock_det_i <= '1';
      pw_down_n_i <= '1';
      reset_n_i   <= '1';
      sync_n_i <= '1';
      sys_rst_n_i <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;
      sys_rst_n_i <= '1';

      wait for clk1_i_period*10;
      lock_det_i <= '1';

      -- insert stimulus here 

      wait;
   end process;

END;
