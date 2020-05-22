--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:48:42 05/22/2020
-- Design Name:   
-- Module Name:   C:/Users/01131168/SHA/test_uart_tx.vhd
-- Project Name:  SHA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart_tx
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
 
ENTITY test_uart_tx IS
END test_uart_tx;
 
ARCHITECTURE behavior OF test_uart_tx IS 
    
   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal TX_Data_In : std_logic_vector(7 downto 0) := (others => '0');
   signal TX_Go : std_logic := '0';

 	--Outputs
   signal TX_Start : std_logic;
   signal Tx : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 83 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.uart_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          TX_Data_In => TX_Data_In,
          TX_Go => TX_Go,
          TX_Start => TX_Start,
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
      TX_Data_In <= "01001000";
		
      wait for 1 ms;	

		if TX_Start = '1' then 
			TX_Data_In <= "01000000";
		end if;
      wait for Clk_period*10;

      -- insert stimulus here 

      wait;
   end process;
	
	process(TX_Start)
	begin
	
	if TX_Start = '0' then 
			TX_Go <= '0';
	end if;
	if TX_Start = '1' then 
			TX_Go <= '1';
	end if;
	end process;

END;
