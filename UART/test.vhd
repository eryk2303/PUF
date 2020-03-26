--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:37:38 03/26/2020
-- Design Name:   
-- Module Name:   /home/eryk/Pulpit/UART/test.vhd
-- Project Name:  UART
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
 
ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart_tx
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         TX_Data_In : IN  std_logic_vector(7 downto 0);
         TX_Go : IN  std_logic;
         TX_Start : OUT  std_logic;
         Tx : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal TX_Data_In : std_logic_vector(7 downto 0) := (others => '0');
   signal TX_Go : std_logic := '0';

 	--Outputs
   signal TX_Start : std_logic;
   signal Tx : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart_tx PORT MAP (
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
		TX_Go	<= '1';
		Reset	<= '0';
		TX_Data_In	<= "11111111";
		     -- hold reset state for 100 ns.
     


      wait;
   end process;

END;
