library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity COMPUTE_HASH is
	port(
		clk 			: in std_logic;

		word_input 		: in DWORD;
		word_input_nr 	: in integer;
		word_nr 			: out integer;

		hash_output 	: out hash_array;

		reset 			: in std_logic
	);
end COMPUTE_HASH;

architecture Behavioral of COMPUTE_HASH is

	signal working_vars : hash_array := constants_initial;
	alias a	: DWORD is working_vars(0);
	alias b	: DWORD is working_vars(1);
	alias c	: DWORD is working_vars(2);
	alias d	: DWORD is working_vars(3);
	alias e	: DWORD is working_vars(4);
	alias f	: DWORD is working_vars(5);
	alias g	: DWORD is working_vars(6);
	alias h	: DWORD is working_vars(7);
	
	signal 	hash 	: hash_array := constants_initial;
	signal 	i 		: integer := 0;

	-- temporary for tests
--	signal 	clk 	: std_logic := '0';

begin

	GET_WORD : process(clk) is
	begin
		word_nr <= i;
	end process;

	MAIN_LOOP : process(clk, reset) is

		variable K : DWORD;
		variable W : DWORD;

	begin

		if (word_input_nr = i) and (reset = '0') then
			if i < 63 then
				K := constants_value(i);
				W := word_input;
				h <= g;
				g <= f;
				f <= e;
				e <= code_e(h, e, f, g, d, W, K);
				d <= c;
				c <= b;
				b <= a;
				a <= code_a(h, e, f, g, a, b, c, W, K);
				
				i <= i + 1;
			else
				i <= 0;
				adding(hash, working_vars);
				hash_output <= hash;
			end if;
		elsif (reset = '1') then
			initiation(a, b, c, d, e, f, g, h);
			i <= 0;
		end if;

	end process;
	
--	clk <= not clk after 100 ns;
	
end Behavioral;

