library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity PREPARE_SCHEDULE is
	port(
		clk 				: in std_logic;

		data 				: in message_block;
		data_reset 		: in std_logic;
		test_output 	: out message_schedule;
		
		word_output		: out DWORD;
		word_out_nr		: out integer;
		req_word_nr		: in integer;
		
		reset				: in std_logic
	);
end PREPARE_SCHEDULE;

architecture Behavioral of PREPARE_SCHEDULE is

	signal schedule 	: message_schedule;
	signal iterator 	: integer := 0;
	signal ack_output : integer := 0;

begin

	MAIN_LOOP : process(clk) is
	begin

		if (data_reset = '0') then
			if ((iterator < 64) and (ack_output = iterator)) then
				iterator <= iterator + 1;
			end if;
		elsif (data_reset = '1') then
			iterator <= 0;
		end if;
		
	end process;

	WORD_T : entity work.WORD_T
		port map(clk, data, iterator, schedule, ack_output);
		
	OUTPUT : process(clk) is
	begin
		
		if (req_word_nr >= 0) and (req_word_nr < ack_output) then
			word_output 	<= schedule(req_word_nr);
			word_out_nr 	<= req_word_nr;
		end if;
		
	end process;
		
	test_output <= schedule;

end Behavioral;