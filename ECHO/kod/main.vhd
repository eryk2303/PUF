--! use standard library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

entity main is
	generic(
		--! clock frequency
		CLK_FREQUENCY	: positive := 12000000;
		--! UART message  length
		DATA_WIDTH 		: positive := 8;
		--! UART baud rate
		BAUD			: positive := 19200
);
	port(
		Clk_input 		: in std_logic_vector(0 downto 0);
		Reset_input 	: in std_logic_vector(0 downto 0);
		--! RX pin to get signals
		Rx_input		: in std_logic_vector(0 downto 0);
		--! Tx pin for transmitting
		Tx_output		: out std_logic_vector(0 downto 0)
		
	);
end main;

architecture Behavioral of main is

	signal Clk			: std_logic;
	signal Reset		: std_logic;
	--! signal for get 
	signal Rx			: std_logic;
	--! signal for transmitting
	signal Tx			: std_logic;
	
	--! Inputs from uart_rx
	signal RX_Data 			: std_logic_vector(DATA_WIDTH - 1 downto 0);
	--! Inputs from uart_rx
	signal RX_Ready			: std_logic;
	
	--! Inputs from uart_tx
	signal TX_Data : std_logic_vector(7 downto 0);
	--! Inputs from uart_tx
	signal TX_Ready : std_logic :=  '0';

	--! Outputs from uart_tx
	signal TX_Start : std_logic;

begin

	Clk	<= Clk_input(0);
	Rx	<= Rx_input(0);
	Tx_output(0) <= Tx;
	
	--! declaration uart_rx
	UART_RX : entity work.UART_RX
		generic map(
			CLK_FREQUENCY	=> CLK_FREQUENCY,
			DATA_WIDTH 		=> DATA_WIDTH,
			BAUD			=> BAUD
		)
		port map(
			Clk 			=> Clk,
			Reset			=> Reset,
			Rx				=> Rx,
			RX_Data_Out		=> RX_Data,
			RX_Ready		=> RX_Ready
		);
	--! declaration uart_tx 
	UART_TX: entity work.UART_TX
		generic map(
			CLK_FREQUENCY	=> CLK_FREQUENCY,
			DATA_WIDTH 		=> DATA_WIDTH,
			BAUD			=> BAUD
		)
   		port map(
			Clk => Clk,
			Reset => Reset,
			TX_Data_In => TX_Data,
			TX_Ready => TX_Ready,
			TX_Start => TX_Start,
			Tx => Tx
        );
	process(Clk)
		begin
		if rising_edge(ClK) then
			if Reset_input(0) = '0' then
				if TX_Start <= '1' then 
					TX_Data <= RX_Data;
					TX_Ready <= RX_Ready;
				end if;
			else 
				TX_Ready <= '0';
			end if;
		end if;
	end process;
end Behavioral;

