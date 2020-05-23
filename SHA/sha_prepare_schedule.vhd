library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity PREPARE_SCHEDULE is
	port(
		Clk 			: in std_logic;

		--! input interface
		Word_input		: in DWORD;
		Word_in_id		: in natural range 0 to 15;
		Word_in_ready	: in std_logic;

		--! output interface
		Word_output		: out DWORD;
		Word_out_nr		: out natural range 0 to 64;
		Word_req_id		: in natural range 0 to 63;

		Reset			: in std_logic
	);
end PREPARE_SCHEDULE;

architecture Behavioral of PREPARE_SCHEDULE is

	signal schedule : message_schedule;
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
	begin

		if Reset = '0' then
			--! checks if requested word is already in the schedule
			if Word_req_id < ack then
				Word_output <= schedule(Word_req_id);
				Word_out_nr <= Word_req_id + 1;
			else
				Word_out_nr	<= 0;
			end if;

		elsif Reset = '1' then
			Word_out_nr	<= 0;
		end if;

	end process;


end Behavioral;