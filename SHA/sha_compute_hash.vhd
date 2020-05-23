library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity COMPUTE_HASH is
	port(
		clk 				: in std_logic;
		
		--! input interface
		word_input 		: in  DWORD;
		word_in_nr	 	: in  natural range 0 to 64;
		word_req_id 	: out natural range 0 to 63;

		--! output interface
		hash_output 	: out hash_array;
		hash_ready		: out std_logic := '0';

		reset 			: in std_logic
	);
end COMPUTE_HASH;

architecture Behavioral of COMPUTE_HASH is

	--! working variables used in computation
	signal working_vars : hash_array := constants_initial;
	alias a	: DWORD is working_vars(0);
	alias b	: DWORD is working_vars(1);
	alias c	: DWORD is working_vars(2);
	alias d	: DWORD is working_vars(3);
	alias e	: DWORD is working_vars(4);
	alias f	: DWORD is working_vars(5);
	alias g	: DWORD is working_vars(6);
	alias h	: DWORD is working_vars(7);
	
	--! a working variable for computing hash
	signal hash 	: hash_array := constants_initial;
	
	type HASH_STATE is (COMPUTE, ADD, INITIALIZE);
	signal state 	: HASH_STATE := COMPUTE;

begin

	process(clk, reset) is

		variable K : DWORD;
		variable W : DWORD;
		
		variable iter 	: natural := 0;

	begin
	
		if reset = '0' then
		
			case state is
				
				when COMPUTE =>
			--! checks if requested word is on input
					if word_in_nr = (iter + 1) then

					hash_ready	<= '0';

					K := constants_value(iter);
					W := word_input;
					h <= g;
					g <= f;
					f <= e;
					e <= code_e(h, e, f, g, d, W, K);
					d <= c;
					c <= b;
					b <= a;
					a <= code_a(h, e, f, g, a, b, c, W, K);
					
					iter := iter + 1;
					if iter = 64 then
						state <= ADD;
					end if;
				end if;
			
				when ADD =>
						adding(hash, working_vars);
						hash_ready	<= '1';
						state 		<= INITIALIZE;
				
				when INITIALIZE =>
						working_vars <= hash;
						iter 			:= 0;
						state 		<= COMPUTE;
				
			end case;
				
			
			
			--! reqest for next word
			word_req_id <= iter;
			hash_output <= hash;

		elsif reset = '1' then
			working_vars <= constants_initial;
			iter := 0;
		end if;

	end process;
	
	
end Behavioral;

