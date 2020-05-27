library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity PREPARE_SCHEDULE is
	port(
		Clk 			: in std_logic;

		--! 	input interface
		--! 32-bit input word
		Word_input		: in DWORD;
		--! id of the word in the message block
		Word_in_id		: in natural range 0 to 15;
		--! states if output word is ready to be read
		Word_in_ready	: in std_logic;

		--! 	output interface
		--! 32-bit output word
		Word_output		: out DWORD;
		--! number of output word (id + 1, 0 means output is not ready)
		Word_out_nr		: out natural range 0 to 64;
		--! id of requested word
		Word_req_id		: in natural range 0 to 63;

		Reset			: in std_logic
	);
end PREPARE_SCHEDULE;

architecture Behavioral of PREPARE_SCHEDULE is

	--! message schedule with 64 32-bit wordsjak
	signal schedule : message_schedule;
	--! acknowledgement which returns number of prepared words in schedule
	signal ack		: integer := 0;

begin

	--! module for preparing 64-long word schedule
	WORD_T : entity work.WORD_T
		port map(
			Clk 		=> Clk,
			Word_in 	=> Word_input,
			Word_id 	=> Word_in_id,
			Ready 		=> Word_in_ready,
			Schedule 	=> schedule,
			Ack 		=> ack,
			Reset 		=> Reset
		);

	--! handling COMPUTE_HASH requests
	OUTPUT : process(Clk) is
		--! locks output when all words were already sent
		variable lock : std_logic := '0';
	begin

		if Reset = '0' then
			--! checks if requested word is already in the schedule
			if Word_req_id < ack and lock = '0' then
				Word_output <= schedule(Word_req_id);
				Word_out_nr <= Word_req_id + 1;
				if lock = '0' and Word_req_id = 63 then
					lock := '1';
				end if;
			else
				Word_out_nr	<= 0;
			end if;
			
			if ack < 63 then
				lock := '0';
			end if;

		elsif Reset = '1' then
			Word_out_nr	<= 0;
		end if;

	end process;


end Behavioral;