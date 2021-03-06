library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity PADDING_MESSAGE is
	generic(
			DATA_WIDTH : positive := 8
	);
	port(
		Clk				: in std_logic;

		--! 	input interface
		--! received data for hash calculation
		Input_data 		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		--! length of data counted from the highest bit
		Input_length 	: in positive range 1 to DATA_WIDTH;
		--! states is data on output is ready to be read
		Input_ready 	: in std_logic;
		--! states if all data was transmited for hash calculation
		Input_finish 	: in std_logic;

		--! 	output interface
		--! input data merged into 32-bit word
		Word_output		: out DWORD;
		--! id of the word in the message block
		Word_id			: out natural range 0 to 15;
		--! states if output word is ready to be read
		Word_ready		: out std_logic;
		--! states if all data was transmited for hash calculation
		Word_finish 	: inout std_logic := '0';

		Reset			: in std_logic
	);
end PADDING_MESSAGE;

architecture Behavioral of PADDING_MESSAGE is

	--! types of states for process of PADDING_MESSAGE
	type STATE_TYPE is (NORMAL, FINISH, STOP);
	--! determinates the state of the process
	signal state 	: STATE_TYPE := NORMAL;

	--! buffer used for forming output word
	signal word_buffer 	: DWORD := (others => '0');
	--! for counting the number of all formed words
	signal word_counter : natural range 0 to 15 := 0;
	--! for counting the length of the message
	signal bit_counter 	: unsigned(63 downto 0) := (others => '0');
	--! flag for blocking conditions
	signal f_ready 		: std_logic := '0';

begin

	process(Clk) is
		--! pointer for the buffer, informs how many bits are free in the buffer
		variable ptr_b : natural range 0 to 32 := 32;
		--! stores the number of zeros which will be appended
		variable counter_zeros : natural range 0 to 511;
		--! counts the number of appended dwords
		variable last64_counter : natural := 0;
	begin

		if Reset = '0' then

			--! checks if should change into 'padding' mode after reciving all data
			if Input_finish = '1' and state = NORMAL then
				--! calculates the number of zeros which will be appended to the message
				counter_zeros 			:= (448 - ( to_integer(unsigned(bit_counter(31 downto 0))) + 1)) mod 512;
				--! bit '1' is appended to the end of the message
				word_buffer(ptr_b-1) 	<= '1';
				--! decrementing due to the previous appended bit '1'
				ptr_b 					:= ptr_b - 1;
				state 					<= FINISH;
			end if;

			case state is

				--! state when incoming data is formed to 32-bit words
				when NORMAL =>

						if Input_ready = '0' then
							f_ready 	<= '0';
							Word_ready 	<= '0';
							Word_output <= (others => '0');

						elsif Input_ready = '1' and f_ready = '0' then
							bit_counter <= bit_counter + Input_length;
							f_ready		<= '1';

							--! checks wheter input data fits in the buffer or not
							if (ptr_b - Input_length) > 0 then
								word_buffer(ptr_b-1 downto ptr_b-Input_length) <= Input_data(DATA_WIDTH-1 downto DATA_WIDTH-Input_length);
								ptr_b 			:= ptr_b - Input_length;
							--! when input data entirely fits to the end of the buffer
							elsif (ptr_b - Input_length) = 0 then
								Word_output 	<= word_buffer(31 downto ptr_b) & Input_data(DATA_WIDTH-1 downto DATA_WIDTH-Input_length);
								Word_id 		<= word_counter;
								Word_ready 		<= '1';
								word_counter 	<= (word_counter + 1) mod 16;
								ptr_b 			:= 32;
							--! when input data ovefills the buffer
							else
								Word_output 	<= word_buffer(31 downto ptr_b) & Input_data(DATA_WIDTH-1 downto DATA_WIDTH-ptr_b);
								Word_id 		<= word_counter;
								Word_ready 		<= '1';
								word_counter 	<= (word_counter + 1) mod 16;
								word_buffer 	<= (others => '0');
								word_buffer(31 downto 32-Input_length+ptr_b) <= Input_data(DATA_WIDTH-ptr_b-1 downto DATA_WIDTH-Input_length);
								ptr_b 			:= 32 - Input_length + ptr_b;
							end if;

						end if;

				--! state when the message is padded to 512-bit long
				when FINISH =>

						if f_ready = '1' then
							f_ready 	<= '0';
							Word_ready 	<= '0';

						elsif f_ready = '0' then
							f_ready 	<= '1';

							--! appending zeros
							if counter_zeros > 0 then

								--! this should work only once, when there is waiting data inside the buffer
								if ptr_b > 0 and ptr_b < 32 then
									Word_output(31 downto ptr_b) <= word_buffer(31 downto ptr_b);
								--! this should work in all next cases
								else
									Word_output <= (others => '0');
								end if;

								counter_zeros 	:= counter_zeros - ptr_b;
								ptr_b 			:= 32;

							--! eventually appending with 64-bit long block
							else

								case last64_counter is
									when 0 =>
										Word_output <= std_logic_vector(bit_counter(63 downto 32));

									when 1 =>
										Word_output <= std_logic_vector(bit_counter(31 downto 0));
										state 		<= STOP;

									when others => null;
								end case;

								last64_counter 	:= last64_counter + 1;

							end if;

							Word_id 		<= word_counter;
							Word_ready 		<= '1';
							word_counter 	<= (word_counter + 1) mod 16;

						end if;

				--! state at the end when all job is done
				when STOP =>

						f_ready 	<= '0';
						Word_finish <= '1';
						Word_ready 	<= '0';

			end case;

		elsif Reset = '1' then
			Word_ready 		<= '0';
			Word_finish		<= '0';
			word_counter 	<= 0;
			bit_counter 	<= (others => '0');
			f_ready 		<= '0';
			ptr_b 			:= 32;
			last64_counter 	:= 0;
		end if;

	end process;

end Behavioral;

