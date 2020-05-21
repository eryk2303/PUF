-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;
LIBRARY std;
USE std.textio.all;

use work.sha_function.all;
use work.constants.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	SIGNAL Clk 		: std_logic := '0';
	SIGNAL Rx		: std_logic := '1';
	SIGNAL Tx		: std_logic := '1';
	SIGNAL Reset 	: std_logic := '0';
		
	SIGNAL File_buffer	: std_logic_vector(511 downto 0);
	
	SIGNAL f_full		: std_logic := '0';
	SIGNAL f_finish	: std_logic := '0';

	type ByteFileType is file of character;
	
	constant FileName : string := "example.bin";

	constant	Clk_Frequenty	: positive := 12000000;
	constant DATA_WIDTH 		: integer := 8;
	constant Baud				: positive := 19200;

	
	type UART_STATE_TYPE is (IDLE, START, DATA, STOP);
	SIGNAL state_uart 	: UART_STATE_TYPE := IDLE;
	SIGNAL uart_enable 	: std_logic := '0';
	SIGNAL uart_data 		: std_logic_vector(DATA_WIDTH-1 downto 0);
	SIGNAL uart_counter	: natural range 0 to DATA_WIDTH+3 := 0;
	
	
	SIGNAL TX_Data			: std_logic_vector(DATA_WIDTH-1 downto 0);
	SIGNAL TX_Ready		: std_logic := '0';
	SIGNAL Hash_Tx			: std_logic_vector(255 downto 0) := (others => '0');



BEGIN

	clock:		Clk <= not Clk after 100 ns;

   uut: entity work.MAIN PORT MAP(
         Clk_input(0) 		=> Clk,
         Rx_input(0)			=> Rx,
         Tx_input(0)			=> Tx,
         Reset_input(0) 	=> Reset
   );


	
	COMMANDER : PROCESS(Clk) IS

		function to_std_logic_vector(input : string) return std_logic_vector is
			variable output : std_logic_vector(input'length*8 - 1 downto 0);
		begin

			for i in input'range loop
				output(i*8-1 downto i*8-8) := std_logic_vector(to_unsigned(character'pos(input(input'length-i+1)), 8));
			end loop;
			return output;
			
		end function to_std_logic_vector;
		
		file DataFile 			: ByteFileType open read_mode is FileName;
		variable Data_length	: integer := 0;
		variable char_buffer : character;
		
		
		type STATE_TYPE is (COMMAND, TRANSMIT, IDLE, STOP);
		variable state : STATE_TYPE := IDLE;

		variable command_buffer 	: std_logic_vector(63 downto 0);
		variable command_counter 	: integer;


	BEGIN
			
		if f_full = '0' then
		
			if Data_length = 512 or endfile(DataFile) then

				f_full <= '1';
				if Data_length < 512 then
					File_buffer <= File_buffer(Data_length-1 downto 0) & (511-Data_length downto 0 => '0');
				end if;

			end if;
		
			if not endfile(DataFile) then
				read(DataFile, char_buffer);

				File_buffer <= File_buffer(511-8 downto 0) & std_logic_vector(to_unsigned(character'pos(char_buffer),8));

				Data_length := Data_length + 8;
			end if;
			


		end if;

		if Data_length <= 0 and not endfile(DataFile) then
			f_full <= '0';
		end if;
			
			
			
		case state is

			when IDLE =>
					if f_full = '1' and Data_length > 0 then
						state := COMMAND;
						command_counter := 64;
						command_buffer	:= std_logic_vector(to_std_logic_vector("START")) & 
												std_logic_vector(to_unsigned( 	(Data_length / 100)  + 48, 			8)) & 
												std_logic_vector(to_unsigned(	((Data_length / 10) mod 10) + 48, 		8)) & 
												std_logic_vector(to_unsigned( 	(Data_length mod 10)  + 48, 			8));
					end if;

			when COMMAND =>
					if command_counter > 0 and state_uart = IDLE and uart_enable = '0' then
						uart_data <= command_buffer(64-1 downto 64-DATA_WIDTH);
						uart_enable <= '1';
						command_buffer(63 downto 0) := command_buffer(63-DATA_WIDTH downto 0) & (DATA_WIDTH-1 downto 0 => '0');
						command_counter := command_counter - DATA_WIDTH;
					end if;

					if command_counter <= 0 and state_uart = IDLE then
						if f_finish = '0' then
							state := TRANSMIT;
						elsif f_finish = '1' then
							state := STOP;
						end if;
					end if;

			when TRANSMIT =>
					if Data_length > 0 and state_uart = IDLE and uart_enable = '0' then
						uart_data <= File_buffer(512-1 downto 512-DATA_WIDTH);
						uart_enable <= '1';
						File_buffer(511 downto 0) <= File_buffer(511-DATA_WIDTH downto 0) & (DATA_WIDTH-1 downto 0 => '0');
						Data_length := Data_length - DATA_WIDTH;
						if f_full = '1' and Data_length <= 0 then
							if endfile(DataFile) then
								f_finish <= '1';
								state := COMMAND;
								command_counter := 64;
								command_buffer	:= std_logic_vector(to_std_logic_vector("FINISxxx"));
							else
								state := IDLE;
							end if;
						end if;
					end if;
					
					
				when STOP =>
						null;

		end case;

		if state_uart = STOP and uart_enable = '1' then
			uart_enable <= '0';
		end if;
				
	END PROCESS;

	TRANSMITTER : PROCESS(Clk) IS
		--! length of one bit in clock cycles
		constant max_freq_count	: positive := Clk_Frequenty / Baud;
		--! used for counting clock cycles
		variable freq_count : natural range 0 to max_freq_count - 1 := 0;
	BEGIN
				
			if rising_edge(Clk) then
				
				if freq_count < (max_freq_count - 1) then
					freq_count := freq_count + 1;

				else
					freq_count := 0;
					
					case state_uart is

						when IDLE =>
							Rx 				<= '1';
							if uart_enable = '1' then
								state_uart 	<= START;
								uart_counter <= DATA_WIDTH + 2;
							end if; 

						when START =>
							Rx 				<= '0';
							state_uart 		<= DATA;

						when DATA =>
							Rx 				<= uart_data(uart_counter-3);
							uart_counter 	<= uart_counter - 1;
							if uart_counter = 3 then
								state_uart 	<= STOP;
							end if;

						when STOP =>
							Rx 				<= '1';
							uart_counter	<= uart_counter - 1;
							if uart_counter = 1 then
								state_uart 	<= IDLE;
							end if;
					end case;
				
				end if;

			end if;
	END PROCESS;
	
	
	
	TX_RECIEVER : entity work.uart_rx
	port map(
		Clk 				=> Clk,
		Reset				=> Reset,
		RX_Data_Out		=> TX_Data,
		RX_Ready			=> TX_Ready,
		Rx					=> Tx
	);
	
	PROCESS(TX_Ready) IS
	BEGIN
				
		if rising_edge(TX_Ready) then
			Hash_Tx <= Hash_Tx(247 downto 0) & TX_Data;
		end if;
			

	END PROCESS;

END;
