--! use standard library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

--! use work packages
use work.sha_function.all;
use work.constants.all;

entity MAIN is
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
		Rx_input		: in std_logic_vector(0 downto 0);
		Tx_output		: out std_logic_vector(0 downto 0)
	);
end MAIN;

architecture Behavioral of MAIN is

	signal Clk			: std_logic;
	signal Reset		: std_logic;
	signal Rx			: std_logic;
	signal Tx			: std_logic;

	signal Reset_All 		: std_logic;

	signal RX_Data 			: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal RX_Ready			: std_logic;

	signal Hash				: hash_array;
	signal Hash_ready		: std_logic;


	signal UC_Output_data 	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal UC_Output_length : positive range 1 to DATA_WIDTH;
	signal UC_Output_ready 	: std_logic;
	signal UC_Output_finish : std_logic;

	signal S1_Word_output	: DWORD;
	signal S1_Word_id		: natural range 0 to 15;
	signal S1_Word_ready	: std_logic;


	signal S2_Word_output	: DWORD;
	signal S2_Word_out_nr	: natural range 0 to 64;
	signal S3_Word_req_id	: natural range 0 to 63;


begin

	Clk				<= Clk_input(0);
	Reset			<= Reset_All;

	Rx				<= Rx_input(0);
	Tx_output(0)	<= Tx;


	U1 : entity work.UART_RX
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

	U2 : entity work.SHA_TX
		generic map(
			CLK_FREQUENCY	=> CLK_FREQUENCY,
			DATA_WIDTH 		=> DATA_WIDTH,
			BAUD			=> BAUD
		)
		port map(
			Clk				=> Clk,
			Reset			=> Reset,
			Hash_ready		=> Hash_ready,
			Hash_input		=> Hash,
			Tx				=> Tx
		);

	UC : entity work.UART_COMMANDER
		generic map(
			DATA_WIDTH 		=> DATA_WIDTH
		)
		port map(
			Clk 			=> Clk,
			RX_Data 		=> RX_Data,
			RX_Ready 		=> RX_Ready,
			Output_data 	=> UC_Output_data,
			Output_length 	=> UC_Output_length,
			Output_ready 	=> UC_Output_ready,
			Output_finish 	=> UC_Output_finish,
			Hash_input		=> Hash,
			Hash_ready		=> Hash_ready,
			Reset			=> Reset_input(0),
			Reset_all 		=> Reset_All
		);

	S1 : entity work.PADDING_MESSAGE
		generic map(
			DATA_WIDTH 		=> DATA_WIDTH
		)
		port map(
			Clk				=> Clk,
			Input_data 		=> UC_Output_data,
			Input_length 	=> UC_Output_length,
			Input_ready 	=> UC_Output_ready,
			Input_finish 	=> UC_Output_finish,
			Word_output		=> S1_Word_output,
			Word_id			=> S1_Word_id,
			Word_ready		=> S1_Word_ready,
			Reset			=> Reset
		);


	S2 : entity work.PREPARE_SCHEDULE
		port map(
			Clk 			=> Clk,
			Word_input		=> S1_Word_output,
			Word_in_id		=> S1_Word_id,
			Word_in_ready	=> S1_Word_ready,
			Word_output		=> S2_Word_output,
			Word_out_nr		=> S2_Word_out_nr,
			Word_req_id		=> S3_Word_req_id,
			Reset			=> Reset
		);

	S3 : entity work.COMPUTE_HASH
		port map(
			Clk 			=> Clk,
			Word_input 		=> S2_Word_output,
			Word_in_nr	 	=> S2_Word_out_nr,
			Word_req_id 	=> S3_Word_req_id,
			Hash_output 	=> Hash,
			Hash_ready		=> Hash_ready,
			Reset 			=> Reset
		);



end Behavioral;