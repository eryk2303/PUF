--! use standard library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

--! Definition of UART RX
entity UART_RX is
	generic(
			CLK_FREQUENCY	: positive := 12000000;
			--! UART message  length
			DATA_WIDTH 		: positive := 8;
			--! UART baud rate
			BAUD			: positive := 19200
			);
	port(
		Clk					: in std_logic;
		Reset				: in std_logic;
		--! Rx pin for receiving
		Rx					: in std_logic;
		--! received data
		RX_Data_Out			: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		--! determinates if data on output is ready
		RX_Ready			: out std_logic := '0'
		);
end UART_RX;

architecture Behavioral of UART_RX is

	--! length of one bit in clock cycles
	constant MAX_FREQ_COUNT	: positive := CLK_FREQUENCY / BAUD;

	--! used for counting clock cycles
	signal freq_count 	: natural range 0 to MAX_FREQ_COUNT - 1;
	--! counting received bits
	signal count 		: natural range 0 to DATA_WIDTH + 2;

	--! temporarily keeps last state of Rx input
	signal last_Rx 		: std_logic;
	--! determinates if process is in receiving state
	signal receiving 	: std_logic := '0';

	--! buffer for incoming uart frame, 'to' is used for reverse trick on output assignment
	signal data_buf 	: std_logic_vector(0 to DATA_WIDTH + 2);
	--! determinates if data is ready to send to the output
	signal data_ready 	: std_logic := '0';

begin

	RX_PROCESS : process(Clk, Reset) is
	begin

		if Reset = '1' then
			last_Rx 	<= '0';
			receiving 	<= '0';
			data_buf 	<= (others => '0');
			data_ready 	<= '0';

		elsif rising_edge(Clk) and Reset = '0' then

			last_Rx 	<= Rx;

			--! waiting for data frame
			if receiving = '0' then
				--! checking for starting bit
				if last_Rx = '1' and Rx = '0' then
					receiving 	<= '1';
					freq_count 	<= 1;
					count 		<= 0;
				end if;

				data_ready 		<= '0';

			--! receiving data frame
			elsif receiving = '1' then
				if freq_count < (MAX_FREQ_COUNT - 1) then
					freq_count <= freq_count + 1;

					if freq_count = (MAX_FREQ_COUNT / 2) then
						data_buf(data_buf'right-count) <= Rx;
					end if;

				else
					freq_count <= 0;

					if count < (DATA_WIDTH + 2) then
						count 		<= count + 1;
					elsif count >= (DATA_WIDTH + 2) then
						count 		<= 0;
						receiving 	<= '0';

						if (data_buf(data_buf'right) = '0' and data_buf(0 to 1) = "11") then
							data_ready <= '1';
						end if;
					end if;

				end if;
			end if;
		end if;

	end process;


	TO_OUTPUT : process(Clk) is
	begin

		if rising_edge(Clk) then
			if (data_ready = '1') then
				RX_Ready 	<= '1';
				RX_Data_Out <= data_buf(2 to data_buf'right-1);
			else
				RX_Ready 	<= '0';
			end if;
		end if;

	end process;

end Behavioral;

