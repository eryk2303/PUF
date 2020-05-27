--! use standard library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

--! use work packages
use work.sha_function.all;
use work.constants.all;

entity UART_COMMANDER is
	generic(
			DATA_WIDTH 	: positive := 8
	);
	port(
		Clk 			: in std_logic;

		--! 	Rx interface
		--! Raw data from UART_RX
		RX_Data 		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		--! states if RX_Data is ready to be read
		RX_Ready 		: in std_logic;

		--! 	Output interface
		--! received data for hash calculation
		Output_data 	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		--! length of data counted from the highest bit
		Output_length 	: out positive range 1 to DATA_WIDTH;
		--! states is data on output is ready to be read
		Output_ready 	: out std_logic := '0';
		--! states if all data was transmited for hash calculation
		Output_finish 	: inout std_logic := '0';

		Reset			: in std_logic;
		--! resets blocks after receiving "RESET" command
		Reset_all 		: out std_logic := '1'
	);
end UART_COMMANDER;

architecture Behavioral of UART_COMMANDER is

	--! types of states for RX_COMMANDER
	type STATE_TYPE is (WAITING, RECEIVING);
	--! determinates the state of RX_COMMANDER
	signal state 	: STATE_TYPE := WAITING;

	--! flag for blocking condition
	signal f_ready 	: std_logic := '0';

begin

	RX_COMMANDER : process(Clk, Reset) is

		--! funcition which changes ascii digits to integers
		function ascii_to_integer(input : std_logic_vector) return integer is
			variable output : integer := 0;
		begin
			for i in (input'length / 8) downto 1 loop
				output := output * 10 + (to_integer(unsigned(input(i*8-1 downto i*8-8))) - 48);
			end loop;

			return output;
		end function ascii_to_integer;

		--! stores the length of incoming data, downcounted
		variable counter 		: natural range 0 to 512;
		--! buffer for storing last 8 bytes in WAITING state
		variable data_buffer 	: std_logic_vector(63 downto 0) := (others => '0');

	begin

		if Reset = '0' then

			Reset_all 	<= '0';

			if RX_Ready = '0' then
				f_ready 		<= '0';
				Output_ready 	<= '0';

			elsif RX_Ready = '1' and f_ready='0' then
				f_ready 		<= '1';

				case state is
					--! waiting for commands
					when WAITING =>

							--! for shifting new data bit after bit to detect commands in buffer
							for b in DATA_WIDTH - 1 downto 0 loop

								--! shifting buffer and appending with bit of new data
								data_buffer 	:= data_buffer(62 downto 0) & RX_Data(b);

								--! decoding ascii commands
								case data_buffer(8*8-1 downto 3*8) is
									when x"5354415254" => --! "START"
										counter 		:= ascii_to_integer(data_buffer(3*8-1 downto 0));
										state			<= RECEIVING;

									when x"46494e4953" => --! "FINIS"
										Output_finish 	<= '1';

									when x"5245534554" => --! "RESET"
										Reset_all 		<= '1';
										Output_finish 	<= '0';
										Output_ready	<= '0';
										data_buffer		:= (others => '0');
										counter			:= 0;

									when others => null;
								end case;

							end loop;

					--! passing data to SHA blocks
					when RECEIVING =>

							--! downcounting left bits
							if counter > DATA_WIDTH then
								Output_length 	<= DATA_WIDTH;
								counter 		:= counter - DATA_WIDTH;
							else
								Output_length 	<= counter;
								counter 		:= 0;
								state 			<= WAITING;
							end if;

							Output_data 	<= RX_Data;
							Output_ready 	<= '1';

				end case;
			end if;

		elsif Reset = '1' then
			Reset_all 		<= '1';
			Output_finish 	<= '0';
			Output_ready	<= '0';
			data_buffer		:= (others => '0');
			counter			:= 0;
		end if;

	end process;


end Behavioral;

