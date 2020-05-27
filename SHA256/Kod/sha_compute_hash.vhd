library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity COMPUTE_HASH is
	port(
		Clk 				: in std_logic;

		--! 	input interface
		--! 32-bit inpuy word
		Word_input 		: in  DWORD;
		--! number of output word (id + 1, 0 means output is not ready)
		Word_in_nr	 	: in  natural range 0 to 64;
		--! id of requested word
		Word_req_id 	: out natural range 0 to 63;
		
		--! states if all data was already transmitted
		Output_finish	: in std_logic;

		--! 	output interface
		--! calculated hash on output
		Hash_output 	: out hash_array;
		--! states is hash on output is ready to be read
		Hash_ready		: out std_logic := '0';

		Reset 			: in std_logic
	);
end COMPUTE_HASH;

architecture Behavioral of COMPUTE_HASH is

	--! types of states for process of COMPUTE_HASH
	type STATE_TYPE is (COMPUTE, ADD, INITIALIZE);
	--! determinates the state of the process
	signal state 	: STATE_TYPE := COMPUTE;

	--! working variables used in computation
	signal working_vars : hash_array := constant_initials;
	alias a	: DWORD is working_vars(0);
	alias b	: DWORD is working_vars(1);
	alias c	: DWORD is working_vars(2);
	alias d	: DWORD is working_vars(3);
	alias e	: DWORD is working_vars(4);
	alias f	: DWORD is working_vars(5);
	alias g	: DWORD is working_vars(6);
	alias h	: DWORD is working_vars(7);

	--! a working variable for computing hash
	signal hash 	: hash_array := constant_initials;

begin

	process(Clk, Reset) is
		
		--! varaible for temporarly storing constant
		variable K : DWORD;
		--! variable for temporarly storing word from the schedule
		variable W : DWORD;
		--! iterator used in main "loop"
		variable iter : natural := 0;

	begin
		
		if Reset = '0' then

			case state is

				--! main "loop"
				when COMPUTE =>
					--! checks if requested word is on input
					if Word_in_nr = (iter + 1) then

						Hash_ready	<= '0';

						K := constant_values(iter);
						W := Word_input;
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
						if Output_finish = '1' then
							Hash_ready		<= '1';
						else 
							Hash_ready		<= '0';
						end if;
						state 			<= INITIALIZE;

				when INITIALIZE =>
						working_vars 	<= hash;
						iter 			:= 0;
						state 			<= COMPUTE;

			end case;

			--! reqest for next word
			Word_req_id <= iter;
			Hash_output <= hash;

		elsif Reset = '1' then
			working_vars <= constant_initials;
			iter := 0;
		end if;

	end process;


end Behavioral;

