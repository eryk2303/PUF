library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity uart_commander is
	generic(
		DATA_WIDTH : positive := 8
	);
	port(
		clk 			: in std_logic;
		
		--! Rx interface
		RX_Data 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		RX_Ready 	: in std_logic;
		
		--! Tx interface
	--	TX_Data		: out std_logic_vector(DATA_WIDTH-1 downto 0);
	--	TX_Ready		: out std_logic := '0';
		
		--! output interface
		output_DATA 	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		output_length 	: out positive range 1 to DATA_WIDTH;
		output_ready 	: out std_logic := '0';
		output_finish 	: out std_logic := '0';
		
		--! calculated hash to transmit
		hash_input		: in hash_array;
		hash_ready		: in std_logic;
		
		reset				: in 	std_logic;
		reset_all 		: out std_logic := '1'
	);
end uart_commander;

architecture Behavioral of uart_commander is

	type STATE_TYPE is (WAITING, RECEIVING);
	signal state 	: STATE_TYPE := WAITING;
	
	--! flags
	signal f_ready : std_logic := '0';
	signal f_reset : std_logic := '0';

begin

	RX_COMMANDER : process(clk, reset) is
		--! stores the length of incoming data, downcounted
		variable counter 		: natural range 0 to 512;
		--! buffer for storing last 8 bytes in WAITING state
		variable data_buffer : std_logic_vector(63 downto 0);
		--! temporary buffer for decoded string
		variable command 		: string(8 downto 1);
	begin

		if rising_edge(clk) and reset = '0' then
			if RX_Ready = '0' then
				f_ready 			<= '0';
				output_ready 	<= '0';
				
				
			elsif RX_Ready = '1' and f_ready='0' then
				f_ready 			<= '1';
				
				case state is
					--! waiting for commands
					when WAITING =>
					
							--! for shifting new data bit after bit
							for b in DATA_WIDTH-1 downto 0 loop
								
								--! shifting buffer and appending with bit of new data
								data_buffer 	:= data_buffer(62 downto 0) & RX_Data(b);
								
								--! decoding data to ascii
								for id in 8 downto 1 loop
									command(id) := character'val(to_integer(unsigned(data_buffer(id*8-1 downto id*8-8))));
								end loop;
							
								--! commands in template: out <- XXXXXxxx <- in
								case command(8 downto 4) is
									when "START" =>
										counter 			:=	100 * (character'pos(command(3)) mod 48) +
																10  * (character'pos(command(2)) mod 48) +
																		(character'pos(command(1)) mod 48);
										state				<= RECEIVING;
										
									when "FINIS" =>
										output_finish 	<= '1';
										
									when "RESET" =>
										f_reset 			<= '1';
										reset_all 		<= '1';
										output_finish 	<= '0';
										output_ready	<= '0';
										data_buffer		<= (others => '0');
										counter			:= 0;
																	
									when others => null;
								end case;
							
							end loop;
					
					--! passing data to SHA blocks
					when RECEIVING =>
							
							--! downcounting left bits
							if counter > DATA_WIDTH then
								output_length 	<= DATA_WIDTH;
								counter 			:= counter - DATA_WIDTH;
							else
								output_length 	<= counter;
								counter 			:= 0;
								state 			<= WAITING;
							end if;
							
							output_DATA 	<= RX_Data;
							output_ready 	<= '1';
						
				end case;
			end if;
			
			if f_reset = '1' then
				reset_all 	<= '0';
				f_reset 		<= '0';
			end if;
			
		elsif reset = '1' then
			f_reset 			<= '1';
			reset_all 		<= '1';
			output_finish 	<= '0';
			output_ready	<= '0';
			data_buffer		<= (others => '0');
			counter			:= 0;
		end if;
	end process;
	
	TX_COMMANDER : process(clk) is
	begin
	end process;


end Behavioral;

