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
		
		input_DATA 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		input_length 	: in positive range 1 to DATA_WIDTH;
		input_ready 	: in std_logic;
		input_finish 	: in std_logic;
		
		word_output		: out DWORD;
		word_nr			: out natural range 0 to 15;
		word_ready		: out std_logic;
	
		reset			: in std_logic
	);
end PADDING_MESSAGE;

architecture Behavioral of PADDING_MESSAGE is

	type STATE_TYPE is (NORMAL, FINISH, STOP);
	signal state 	: STATE_TYPE := NORMAL;
	
	signal word_buffer : DWORD;
	signal word_counter : natural range 0 to 15 := 0;
	signal bit_counter : unsigned(63 downto 0) := (others => '0');
	
	signal f_ready : std_logic := '0';
	
begin

	process(clk) is
		-- pointer for buffer
		variable ptr_b : natural range 0 to 32 := 32;
		variable counter_zeros : natural range 0 to 511;
		variable last64_counter : natural := 0;
	begin
	
		if input_finish = '1' and state = NORMAL then
			state <= FINISH;
			counter_zeros := (448 - ( to_integer(unsigned(bit_counter)) + 1)) mod 512;
			word_buffer(ptr_b-1) <= '1';
			ptr_b := ptr_b - 1;
		end if;
	
		case state is
		
			when NORMAL =>	
			
					if input_ready = '0' then
						f_ready <= '0';
						word_ready <= '0';
					
					elsif input_ready = '1' and f_ready = '0' then
						bit_counter <= bit_counter + input_length;
						f_ready		<= '1';
						
						if (ptr_b - input_length) > 0 then
							word_buffer(ptr_b-1 downto ptr_b-input_length) <= input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-input_length);
							ptr_b := ptr_b - input_length;
						elsif (ptr_b - input_length) = 0 then
							word_output <= word_buffer(31 downto ptr_b) & input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-input_length);
							word_nr <= word_counter;
							word_ready <= '1';
							word_counter <= (word_counter + 1) mod 16;
							ptr_b := 32;
						else
							word_output <= word_buffer(31 downto ptr_b) & input_DATA(DATA_WIDTH-1 downto DATA_WIDTH-ptr_b);
							word_nr <= word_counter;
							word_ready <= '1';
							word_counter <= (word_counter + 1) mod 16;
							word_buffer(31 downto 32-input_length+ptr_b) <= input_DATA(DATA_WIDTH-ptr_b-1 downto DATA_WIDTH-input_length);
							ptr_b := 32 - input_length + ptr_b;
							
						end if;
						
					end if;
		
		
			when FINISH =>
			
					if f_ready = '1' then
						f_ready <= '0';
						word_ready <= '0';
					
					elsif f_ready = '0' then
						f_ready <= '1';
						
						word_nr <= word_counter;
						word_ready <= '1';
						word_counter <= (word_counter + 1) mod 16;
			
						if counter_zeros > 0 then
						
							if ptr_b < 32 then
								word_output <= word_buffer(31 downto ptr_b) & (ptr_b-1 downto 0 => '0');
							else
								word_output <= (others => '0');
							end if;
							
							
							counter_zeros := counter_zeros - ptr_b;
							ptr_b := 32;
						else
						
							case last64_counter is
								when 0 =>
									word_output <= std_logic_vector(bit_counter(63 downto 32));
									
								when 1 =>
									word_output <= std_logic_vector(bit_counter(32 downto 0));
									state <= STOP;
									
								when others => null;
							end case;
							
							last64_counter := last64_counter + 1;
							
						end if;
					
					end if;
				
			when STOP =>
			
					f_ready 		<= '0';
					word_ready 	<= '0';
					
		end case;
		
	end process;
	
end Behavioral;

