--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:29:58 05/22/2020
-- Design Name:   
-- Module Name:   C:/Users/01131168/SHA/test_sha_tx.vhd
-- Project Name:  SHA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sha_tx
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
 
use work.sha_function.all;
use work.constants.all;

ENTITY test_sha_tx IS
END test_sha_tx;
 
ARCHITECTURE behavior OF test_sha_tx IS 

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Hash_ready : std_logic := '0';
   signal Hash_input : hash_array;

 	--Outputs
   signal Tx : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 83 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.sha_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Hash_ready => Hash_ready,
          Hash_input => Hash_input,
          Tx => Tx
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		Hash_ready <= '1';
      Hash_input <= constants_initial;
      wait for 100 ns;	

      wait for Clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
