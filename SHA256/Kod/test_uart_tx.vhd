
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY test_uart_tx IS
END test_uart_tx;

ARCHITECTURE behavior OF test_uart_tx IS

   --! Inputs uart_tx 
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal TX_Data_In : std_logic_vector(7 downto 0) := (others => '0');
   signal TX_Ready : std_logic := '0';

 	--! Outputs uart_tx 
   signal TX_Start : std_logic;
   signal Tx : std_logic;

   --! Clock period definitions
   constant Clk_period : time := 83 ns;
	signal able : std_logic := '0';

BEGIN
	
	--! declaration uart_tx 
   uut: entity work.uart_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          TX_Data_In => TX_Data_In,
          TX_Ready => TX_Ready,
          TX_Start => TX_Start,
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
   stim_proc: process(Clk, TX_Start)
   begin
	if rising_edge(Clk) then
		TX_Ready <= '0';
		if TX_Start = '1' then
			if able = '0' then
				TX_Data_In <= "01001000";
				able <= '1';
				TX_Ready <= '1';
			end if;
		end if;
	
	end if;
   end process;

END;
