library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity MAIN is
	generic(
		Clk_Frequenty	: positive := 12000000;
		
		DATA_WIDTH 		: positive := 8;
		
		Baud			: positive := 19200
	);
	port(
		Clk 	: in std_logic_vector(0 downto 0);
		Rx		: in std_logic_vector(0 downto 0);
		Tx		: out std_logic_vector(0 downto 0);
		Reset : in std_logic_vector(0 downto 0)
	);
end MAIN;

architecture Behavioral of MAIN is

	signal RX_Data 	: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal RX_Ready	: std_logic;

	signal UC_Output_DATA 	: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal UC_Output_length : positive range 1 to DATA_WIDTH;
	signal UC_Output_ready 	: std_logic;
	signal UC_Output_finish : std_logic;

	signal S1_Word_output	: DWORD;
	signal S1_Word_id		: natural range 0 to 15;
	signal S1_Word_ready	: std_logic;

	
	signal S2_Word_output	: DWORD;
	signal S2_Word_out_nr	: natural range 0 to 64;
	signal S2_Word_req_id	: natural range 0 to 63;

	signal Finish_Transmit	: std_logic;

	signal Hash				: hash_array;
	signal Hash_ready		: std_logic;
	
	signal Reset_All 		: std_logic;
	
begin

	U1 : entity work.uart_rx
		port map(
			Clk 			=> Clk,
			Reset			=> Reset,
			RX_Data_Out		=> RX_Data,
			RX_Ready		=> RX_Ready,
			Rx				=> Rx
		);

	UC : entity work.uart_commander
		port map(
			clk 			=> Clk,
			RX_Data 		=> RX_Data,
			RX_Ready 		=> RX_Ready,
			output_DATA 	=> UC_Output_DATA,
			output_length 	=> UC_Output_length,
			output_ready 	=> UC_Output_ready,
			output_finish 	=> UC_Output_finish,
			hash_input		=> Hash,
			hash_ready		=> Hash_ready,
			reset			=> Reset,
			reset_all 		=> Reset_All
		);

	S1 : entity work.PADDING_MESSAGE
		port map(
			clk				=> Clk,		
			input_DATA 		=> UC_Output_DATA,
			input_length 	=> UC_Output_length,
			input_ready 	=> UC_Output_ready,
			input_finish 	=> UC_Output_finish,
			word_output		=> S1_Word_output,
			word_id			=> S1_Word_id,
			word_ready		=> S1_Word_ready,
			reset			=> Reset
		);	


	S2 : entity work.PREPARE_SCHEDULE
		port map(
			clk 			=> Clk,
			word_input		=> S1_Word_output,
			word_in_id		=> S1_Word_id,
			word_in_ready	=> S1_Word_ready,
			word_output		=> S2_Word_output,
			word_out_nr		=> S2_Word_out_nr,
			word_req_id		=> S2_Word_req_id,
			reset			=> Reset
		);

	S3 : entity work.COMPUTE_HASH
		port map(
			clk 			=> Clk,
			word_input 		=> S2_Word_output,
			word_in_nr	 	=> S2_Word_out_nr,
			word_req_id 	=> S2_Word_req_id,
			hash_output 	=> Hash,
			hash_ready		=> Hash_ready,
			reset 			=> Reset
		);


	U2 : entity work.sha_tx	
		port map(
			Clk_Sha_Uart	=> Clk,
			Reset_Sha_Uart	=> Reset,
			New_Data		=> Hash_ready,
			Data_In			=> hash_array, -- konflikt typów danych póki co
			Finish_Transmit	=> Finish_Transmit
		);

end Behavioral;