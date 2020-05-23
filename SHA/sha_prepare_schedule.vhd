library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity PREPARE_SCHEDULE is
	port(
		clk 				: in std_logic;
		
		--! input interface
		word_input		: in DWORD;
		word_in_id		: in natural range 0 to 15;
		word_in_ready	: in std_logic;
		
		--! output interface
		word_output		: out DWORD;
		word_out_nr		: out natural range 0 to 64;
		word_req_id		: in  natural range 0 to 63;
		
		reset				: in std_logic
	);
end PREPARE_SCHEDULE;

architecture Behavioral of PREPARE_SCHEDULE is

	signal schedule 	: message_schedule;
	signal ack			: integer := 0;

begin

	--! module for preparing 64-long word schedule
	WORD_T : entity work.WORD_T
		port map(
			clk 		=> clk,
			word_in 	=> word_input,
			iter 		=> word_in_id,
			ready 	=> word_in_ready,
			schedule => schedule,
			ack 		=> ack,
			reset 	=> reset
		);
		
	--! handling COMPUTE_HASH requests
	OUTPUT : process(clk) is
		variable lock : std_logic := '0';
	begin
		
		--! checks if requested word is already in the schedule
		if word_req_id < ack and lock = '0' then
			word_output 	<= schedule(word_req_id);
			word_out_nr 	<= word_req_id + 1;
			--! locks next requests
			if word_req_id = 63 then
				lock 				:= '1';
			end if;
		elsif ack = 0 or reset = '1' then
			lock 				:= '0';
			word_out_nr		<= 0;
		end if;
		
		if ack = 1 then
			lock := '0';
		end if;
		
	end process;

end Behavioral;