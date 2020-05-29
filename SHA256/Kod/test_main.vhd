LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--! for reading/writing files
USE ieee.std_logic_textio.ALL;
LIBRARY std;
USE std.textio.all;

use work.sha_function.all;
use work.constants.all;

ENTITY test_main IS
END test_main;

ARCHITECTURE behavior OF test_main IS

	--! IO signals of 'sha_main.vhd'
	SIGNAL Clk 		: std_logic := '0';
	SIGNAL Reset 	: std_logic := '0';
	SIGNAL Rx		: std_logic := '1';
	SIGNAL Tx		: std_logic := '1';
	
	--! constatnts
	constant CLK_FREQUENCY	: positive := 12000000;
	constant DATA_WIDTH 	: positive := 8;
	constant BAUD			: positive := 19200;

	--! file type, constant filename and buffer
	type BYTE_FILE_TYPE is file of character;
	--! name of the read file
	constant FILENAME 		: string := "example.bin";
	--! buffer for storing chunks of input file
	SIGNAL file_buffer		: std_logic_vector(511 downto 0);
	
	--! uart transmitter for testing
	type UART_STATE_TYPE is (IDLE, START, DATA, STOP);
	--! determinates the state of the uart process
	SIGNAL state_uart 		: UART_STATE_TYPE := IDLE;
	--! locks pushing data to uart
	SIGNAL uart_enable 		: std_logic := '0';
	--! stores data for transmitting, 'to' is used for reverse trick on output assignment
	SIGNAL uart_data 		: std_logic_vector(0 to DATA_WIDTH-1);
	--! counts transmitted bits
	SIGNAL uart_counter		: natural range 0 to DATA_WIDTH+3 := 0;

	--! data received by uart rx from uart_tx
	SIGNAL TX_Data			: std_logic_vector(DATA_WIDTH-1 downto 0);
	--! states if TX_Data is ready to read
	SIGNAL TX_Ready			: std_logic := '0';
	--! buffer for received tx data (hash)
	SIGNAL Hash_Tx			: std_logic_vector(255 downto 0) := (others => '0');

	--! flag which states if file_buffer is full or finished
	SIGNAL f_full			: std_logic := '0';
	--! flag which states if all data was sent to MAIN module
	SIGNAL f_finish			: std_logic := '0';
	
	signal prehash_ready		: std_logic;

BEGIN

	--! main clock signal
	clock:	Clk <= not Clk after 41 ns;

	--! entity of tested component
	uut: ENTITY work.MAIN
		GENERIC MAP(
			CLK_FREQUENCY	=> CLK_FREQUENCY,
			DATA_WIDTH 		=> DATA_WIDTH,
			BAUD			=> BAUD
		)
		PORT MAP(
			Clk_input(0) 		=> Clk,
			Reset_input(0) 		=> Reset,
			Rx_input(0)			=> Rx,
			Tx_output(0)		=> Tx,
			prehash_ready		=> prehash_ready
		);


	--! main process for reading files and sending data to work.MAIN
	COMMANDER : PROCESS(Clk) IS

		--! function which changes string (ascii) to std_logic_vector
		function to_std_logic_vector(input : string) return std_logic_vector is
			variable output : std_logic_vector(input'length*8 - 1 downto 0);
		begin
			for i in input'range loop
				output(i*8-1 downto i*8-8) := std_logic_vector(to_unsigned(character'pos(input(input'length-i+1)), 8));
			end loop;

			return output;

		end function to_std_logic_vector;

		--! file declaration in read mode
		file Data_File 			: BYTE_FILE_TYPE open read_mode is FILENAME;
		--! counts length of incoming data up to 512, used for dividing data into 512-bit long blocks
		variable data_length	: integer := 0;
		--! byte long buffer for reading files
		variable char_buffer 	: character;

		--! states of sending data to tested component
		type STATE_TYPE is (COMMAND, TRANSMIT, IDLE, STOP);
		--! determinates the state of testing
		variable state : STATE_TYPE := IDLE;

		--! buffer which holds ascii commands in binary
		variable command_buffer 	: std_logic_vector(63 downto 0);
		--! holds the length of command_buffer, downcounted while transmitting
		variable command_counter 	: integer;


	BEGIN

		--! when file_buffer is not full yet
		if f_full = '0' then

			--! wheter full buffer or the end of the file 
			if data_length = 512 or endfile(Data_File) then

				f_full <= '1';
				if data_length < 512 then
					--! shifting data to the beginning
					file_buffer <= file_buffer(data_length-1 downto 0) & (511-data_length downto 0 => '0');
				end if;

			end if;

			if not endfile(Data_File) then
				read(Data_File, char_buffer);

				file_buffer <= file_buffer(511-8 downto 0) & std_logic_vector(to_unsigned(character'pos(char_buffer),8));
				
				data_length := data_length + 8;
			end if;



		end if;

		--! if buffer is empty and file not yet
		if data_length <= 0 and not endfile(Data_File) then
			f_full <= '0';
		end if;



		case state is
			--! waits for prepared data buffer
			when IDLE =>
					if f_full = '1' and data_length > 0 then
						state := COMMAND;
						command_counter := 64;
						command_buffer	:= std_logic_vector(to_std_logic_vector("START")) &
												std_logic_vector(to_unsigned( 	(data_length / 100)  + 48, 			8)) &
												std_logic_vector(to_unsigned(	((data_length / 10) mod 10) + 48, 		8)) &
												std_logic_vector(to_unsigned( 	(data_length mod 10)  + 48, 			8));
					end if;
			--! transmitting command to work.MAIN
			when COMMAND =>
					if command_counter > 0 and state_uart = IDLE and uart_enable = '0' then
						uart_data 					<= command_buffer(64-1 downto 64-DATA_WIDTH);
						uart_enable 				<= '1';
						command_buffer(63 downto 0) := command_buffer(63-DATA_WIDTH downto 0) & (DATA_WIDTH-1 downto 0 => '0');
						command_counter 			:= command_counter - DATA_WIDTH;
					end if;

					if command_counter <= 0 and state_uart = IDLE then
					--! checks if it is the end of transmitted file
						if f_finish = '0' then
							state := TRANSMIT;
						elsif f_finish = '1' then
							state := STOP;
						end if;
					end if;
			--! follows transmitted command and sends data block to work.MAIN
			when TRANSMIT =>
					if data_length > 0 and state_uart = IDLE and uart_enable = '0' then
						uart_data				 	<= file_buffer(512-1 downto 512-DATA_WIDTH);
						uart_enable 				<= '1';
						file_buffer(511 downto 0) 	<= file_buffer(511-DATA_WIDTH downto 0) & (DATA_WIDTH-1 downto 0 => '0');
						data_length 				:= data_length - DATA_WIDTH;
						if f_full = '1' and data_length <= 0 then
							--! checks if there is more data in the file and decides about next state
							if endfile(Data_File) then
								f_finish 		<= '1';
								state 			:= COMMAND;
								command_counter := 64;
								command_buffer	:= std_logic_vector(to_std_logic_vector("FINISxxx"));
							else
								state 			:= IDLE;
							end if;
						end if;
					end if;

			--! does nothing, stuck after all job is done
			when STOP =>
					null;

		end case;

		--! unlocks uart_enable at the end of uart transmission
		if state_uart = STOP and uart_enable = '1' then
			uart_enable <= '0';
		end if;

	END PROCESS;

	--! transmitter which sends data to main.WORK Rx
	TRANSMITTER : PROCESS(Clk) IS
		--! length of one bit in clock cycles
		constant MAX_FREQ_COUNT	: positive := CLK_FREQUENCY / BAUD;
		--! used for counting clock cycles
		variable freq_count : natural range 0 to MAX_FREQ_COUNT - 1 := 0;
	BEGIN

		if rising_edge(Clk) then

			--! counts the length of one bit
			if freq_count < (MAX_FREQ_COUNT - 1) then
				freq_count := freq_count + 1;

			else
				freq_count := 0;

				--! states of uart transmission
				case state_uart is
					--! waits for trigger
					when IDLE =>
						Rx 				<= '1';
						if uart_enable = '1' then
							state_uart 	<= START;
							uart_counter <= DATA_WIDTH + 2;
						end if;
					--! transmits starting bit
					when START =>
						Rx 				<= '0';
						state_uart 		<= DATA;
					--! transmits data
					when DATA =>
						Rx 				<= uart_data(uart_counter-3);
						uart_counter 	<= uart_counter - 1;
						if uart_counter = 3 then
							state_uart 	<= STOP;
						end if;
					--! transmits stop bits
					when STOP =>
						Rx 				<= '1';
						uart_counter	<= uart_counter - 1;
						--! at the end goes into IDLE state
						if uart_counter = 1 then
							state_uart 	<= IDLE;
						end if;
				end case;

			end if;

		end if;

	END PROCESS;

	--! recieves data from Tx of work.MAIN
	TX_RECIEVER : ENTITY work.UART_RX
	GENERIC MAP(
		CLK_FREQUENCY	=> CLK_FREQUENCY,
		DATA_WIDTH 		=> DATA_WIDTH,
		BAUD			=> BAUD
	)
	PORT MAP(
		Clk 			=> Clk,
		Reset			=> Reset,
		Rx				=> Tx,
		RX_Data_Out		=> TX_Data,
		RX_Ready		=> TX_Ready
	);

	--! appends received data from TX_RECEIVER and stores in 256-long signal (as a hash)
	PROCESS(TX_Ready) IS
	BEGIN

		if rising_edge(TX_Ready) then
			Hash_Tx <= Hash_Tx(247 downto 0) & TX_Data;
		end if;

	END PROCESS;


END;
