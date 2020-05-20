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
		clk				: in std_logic;
		
		--! input interface
		input_DATA 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		input_length 	: in positive range 1 to DATA_WIDTH;
		input_ready 	: in std_logic;
		input_finish 	: in std_logic;
		
		--! output interface
		word_output		: out DWORD;
		word_nr			: out natural range 0 to 15;
		word_ready		: out std_logic;
	
		reset				: in std_logic
	);
end PADDING_MESSAGE;

architecture Behavioral of PADDING_MESSAGE is

	type STATE_TYPE is (NORMAL, FINISH, STOP);
	signal state 	: STATE_TYPE := NORMAL;
	
	--! buffer used for forming output word
	signal word_buffer 	: DWORD;
	--! for counting the number of all formed words 
	signal word_counter 	: natural range 0 to 15 := 0;
	--! for counting the length of the message
	signal bit_counter 	: unsigned(63 downto 0) := (others => '0');
	--! flag for blocking conditions
	signal f_ready 		: std_logic := '0';
	
begin

	process(clk) is
		--! pointer for the buffer, informs how many bits are free in the buffer
		variable ptr_b : natural range 0 to 32 := 32;
		--! stores the number of zeros which will be appended
		variable counter_zeros : natural range 0 to 511;
		--! counts the number of appended dwords
		variable last64_counter : natural := 0;
	begin
	
		if reset = '0' then

			--! checks if should change into 'padding' mode
			if input_finish = '1' and state = NORMAL then
				--! calculates the number of zeros which will append the message
				counter_zeros 			:= (448 - ( to_integer(unsigned(bit_counter)) + 1)) mod 512;
				--! bit '1' is appended to the end of the message
				word_buffer(ptr_b-1) <= '1';
				ptr_b := ptr_b - 1;
				state <= FINISH;
			end if;
		
			case state is
			
				--! state when incoming data is formed to 32-bit words
				when NORMAL =>	
				
						if input_ready = '0' then
							f_ready 		<= '0';
							word_ready 	<= '0';
						
						elsif input_ready = '1' and f_ready = '0' then
							bit_counter <= bit_counter + input_length;
							f_ready		<= '1';
							
							--! checks wheter input data fits in the buffer or not
							if (ptr_b - input_length) > 0 then
								word_buffer(ptr_b-1 downto ptr_b-input_length) <= input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-input_length);
								ptr_b 			:= ptr_b - input_length;
							--! when input data entirely fits to the end of the buffer
							elsif (ptr_b - input_length) = 0 then
								word_output 	<= word_buffer(31 downto ptr_b) & input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-input_length);
								word_nr 			<= word_counter;
								word_ready 		<= '1';
								word_counter 	<= (word_counter + 1) mod 16;
								ptr_b 			:= 32;
							--! when input data ovefills the buffer
							else
								word_output 	<= word_buffer(31 downto ptr_b) & input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-ptr_b);
								word_nr 			<= word_counter;
								word_ready 		<= '1';
								word_counter 	<= (word_counter + 1) mod 16;
								word_buffer(31 downto 32-input_length+ptr_b) <= input_DATA(DATA_WIDTH-ptr_b-1 downto DATA_WIDTH-input_length);
								ptr_b 			:= 32 - input_length + ptr_b;
							end if;
							
						end if;
			
				--! state when the message is padded to 512-bit long
				when FINISH =>
				
						if f_ready = '1' then
							f_ready 		<= '0';
							word_ready 	<= '0';
						
						elsif f_ready = '0' then
							f_ready 		<= '1';
							
							--! appending zeros			
							if counter_zeros > 0 then
								--! this should work only once, when there is waiting data inside the buffer
								if ptr_b < 32 then
									word_output <= word_buffer(31 downto ptr_b) & (ptr_b-1 downto 0 => '0');
								else
									word_output <= (others => '0');
								end if;
								
								counter_zeros 	:= counter_zeros - ptr_b;
								ptr_b 			:= 32;
								
							--! eventually appending with 64-bit long block
							else
								case last64_counter is
									when 0 =>
										word_output <= std_logic_vector(bit_counter(63 downto 32));
										
									when 1 =>
										word_output <= std_logic_vector(bit_counter(32 downto 0));
										state 		<= STOP;
										
									when others => null;
								end case;
								
								last64_counter 	:= last64_counter + 1;
								
							end if;
							
							word_nr 			<= word_counter;
							word_ready 		<= '1';
							word_counter 	<= (word_counter + 1) mod 16;
							
						end if;
						
				--! state at the end when all job is done
				when STOP =>
				
						f_ready 		<= '0';
						word_ready 	<= '0';
						
			end case;
			
		elsif reset = '1' then
			word_ready 		<= '0';
			word_counter 	<= 0;
			bit_counter 	<= (others => '0');
			f_ready 			<= '0';	
			ptr_b 			:= 32;
			last64_counter := 0;
		end if;
		
	end process;
	
end Behavioral;

