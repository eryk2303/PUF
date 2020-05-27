
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use work.sha_function.all;
use work.constants.all;

ENTITY test_sha_tx IS
END test_sha_tx;

ARCHITECTURE behavior OF test_sha_tx IS

   --!Inputs sha_tx
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Hash_ready : std_logic := '0';
   signal Hash_input : hash_array;

 	--!Outputs sha_tx
   signal Tx : std_logic;

   --! Clock period definitions
   constant Clk_period : time := 83 ns;

BEGIN

	--! declaration sha_tx 
   uut: entity work.sha_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Hash_ready => Hash_ready,
          Hash_input => Hash_input,
          Tx => Tx
        );

   --! Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;


   --! Stimulus process
   stim_proc: process
   begin
		Hash_ready <= '1';
      Hash_input <= constant_initials;
		
      wait for 100 ns;

      wait for Clk_period*10;

      wait;
   end process;

END;
