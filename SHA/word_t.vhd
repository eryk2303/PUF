library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity WORD_T is
	port(
		clk 		: in std_logic;
		
		word_in 	: in DWORD;
		iterator	: in natural;
		sched_in : inout message_schedule;
		
		ack 		: out integer
	);
end WORD_T;

architecture Behavioral of WORD_T is
begin

	process(clk) is
		variable schedule : message_schedule;
	begin
		schedule := sched_in;
		
		if iterator < 15 then
			schedule(iterator) := word_in;
			ack <= iterator;
		elsif iterator < 64 then
			schedule(iterator) := word_in;
			for i in iterator + 1 to 63 loop
				schedule(i) := std_logic_vector(unsigned(SIG1(schedule(i - 2))) + unsigned(schedule(i - 7)) + unsigned(SIG0(schedule(i - 15))) + unsigned(schedule(i - 16)));
				ack <= i;
			end loop;
		end if;
		
		sched_in <= schedule;
			
	end process;

end Behavioral;

