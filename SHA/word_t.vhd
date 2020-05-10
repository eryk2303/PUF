library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity WORD_T is
	port(
		clk 		: in std_logic;
		
		word_in 	: in DWORD;
		i 			: in integer;
		schedule : inout message_schedule;
		
		ack 		: out integer
	);
end WORD_T;

architecture Behavioral of WORD_T is
begin

	process(clk) is
	begin
	
		if i < 16 then
			schedule(i) <= word_in;
		elsif i < 64 then
			schedule(i) <= std_logic_vector(unsigned(SIG1(schedule(i - 2))) + unsigned(schedule(i - 7)) + unsigned(SIG0(schedule(i - 15))) + unsigned(schedule(i - 16)));
		end if;
		
		ack <= i;
			
	end process;

end Behavioral;

