library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity WORD_T is
	port(
		clk 		: in std_logic;
		
		--! input data
		word_in 	: in DWORD;
		iter		: in natural;
		ready		: in std_logic;
		
		schedule : inout message_schedule;
		
		--! counts ready words, 0 words ready in schedule at the beginning
		ack 		: out integer range 0 to 64 := 0;
		
		reset		: in std_logic
	);
end WORD_T;

architecture Behavioral of WORD_T is
begin

	process(clk, reset) is
		variable data : message_schedule;
	begin
		
		if ready = '1' and reset = '0' then
			--! variable used for changing it's content every loop inside 'for'
			data := schedule;
			
			--! condition from 0 to 14
			if iter < 15 then
				data(iter) 	:= word_in;
				ack 			<= iter + 1;
			
			--! condition for last input word and then it calculates final words
			elsif iter = 15 then
				--! assignment of the last input word
				data(iter) 	:= word_in;
				
				for i in iter + 1 to 63 loop
					data(i) 	:= std_logic_vector(unsigned(SIG1(data(i - 2))) + unsigned(data(i - 7)) + unsigned(SIG0(data(i - 15))) + unsigned(data(i - 16)));
					--! on the last iteration it will assign '64' integer as it is meant to behave like a counter (64 words written in schedule)
					ack 		<= i + 1;
				end loop;
			end if;
			
			schedule <= data;
			
		elsif reset = '1' then
			ack <= 0;
			
		end if;
			
	end process;
	

end Behavioral;

