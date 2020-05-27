library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity WORD_T is
	port(
		Clk 		: in std_logic;

		--! input data
		Word_in 	: in DWORD;
		Word_id		: in natural range 0 to 15;
		Ready		: in std_logic;
		Schedule 	: inout message_schedule;

		--! counts Ready words, 0 words Ready in Schedule at the beginning
		Ack 		: out integer range 0 to 64 := 0;

		Reset		: in std_logic
	);
end WORD_T;

architecture Behavioral of WORD_T is
begin

	process(Clk, Reset) is
		--! variable used as buffer to change contents of schedule in loop
		variable data : message_schedule;
	begin

		if Ready = '1' and Reset = '0' then
			data := Schedule;

			--! condition from 0 to 14
			if Word_id < 15 then
				data(Word_id) 	:= Word_in;
				Ack 		<= Word_id + 1;

			--! condition for last input word and then it calculates final words
			elsif Word_id = 15 then
				--! assignment of the last input word
				data(Word_id) 	:= Word_in;

				for i in 16 to 63 loop
					data(i) 	:= std_logic_vector(unsigned(SIG1(data(i - 2))) + unsigned(data(i - 7)) + unsigned(SIG0(data(i - 15))) + unsigned(data(i - 16)));
					--! on the last iteration it will assign '64' integer as it is meant to behave like a counter (64 words written in Schedule)
					Ack 		<= i + 1;
				end loop;
			end if;

			Schedule <= data;

		elsif Reset = '1' then
			Ack <= 0;

		end if;

	end process;


end Behavioral;

