--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:42 07/03/2015
-- Design Name:   
-- Module Name:   D:/Projects/closy3-gw/closy3/syn/closy3_sync_test/testbench.vhd
-- Project Name:  closy3_sync_test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: closy3_sync_test
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
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT closy3_sync_test
    PORT(
         clk_i : IN  std_logic;
         syncclk_i : IN  std_logic;
         sync_n_o : OUT  std_logic;
         dbg_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal syncclk_i : std_logic := '0';

 	--Outputs
   signal sync_n_o : std_logic;
   signal dbg_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 6.4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: closy3_sync_test PORT MAP (
          clk_i => clk_i,
          syncclk_i => syncclk_i,
          sync_n_o => sync_n_o,
          dbg_o => dbg_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '1';
		wait for clk_i_period/2;
		clk_i <= '0';
		wait for clk_i_period/2;
   end process;
 
   process
   begin
     syncclk_i <= '1';
     wait for 10 us;
     syncclk_i <= '0';
     wait for 90 us;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_i_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
