library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity uart_rx is
generic(
		Clk_Frequenty	: positive := 12000000;
		--! uart message  length
		Data_Width 		: positive := 8;
		--! UART baud rate
		Baud			: positive := 19200
		);
port(
	Clk			: in std_logic;
	Reset			: in std_logic;
	--! received data
	RX_Data_Out	: out std_logic_vector(Data_Width - 1 downto 0);
	--! determinates if data on ouutput is ready
	RX_Ready		: out std_logic := '0';
	--! Rx pin to receive
	Rx				: in std_logic
	);
end uart_rx;

architecture Behavioral of uart_rx is

	--! length of one bit in clock cycles
	constant max_freq_count	: positive := Clk_Frequenty / Baud;
	--! used for counting clock cycles
	signal freq_count : natural range 0 to max_freq_count - 1;
	--! counting received bits
	signal count : natural range 0 to Data_Width + 2;
	
	--! temporarily keeps last state of Rx input
	signal last_Rx : std_logic;
	--! determinates if process is in receiving state
	signal receiving : std_logic := '0';
	--! buffer for incoming data including extra bits

	signal data_buf : std_logic_vector(Data_Width + 2 downto 0);
	--! determinates if data is ready to send to the output
	signal data_ready : std_logic := '0';

begin

	RX_PROCESS : process(Clk, Reset) is
	begin

		if (Reset = '1') then
			last_Rx 	<= '0';
			receiving 	<= '0';
			data_buf 	<= (others => '0');
			data_ready 	<= '0';

		elsif (rising_edge(Clk) and Reset = '0') then

			last_Rx <= Rx;

			if (receiving = '0') then
				if (last_Rx = '1' and Rx = '0') then
					receiving 	<= '1';
					freq_count 	<= 1;
					count 		<= 0;
				end if;
				data_ready <= '0';

			elsif (receiving = '1') then
				
				if (freq_count < max_freq_count-1) then
					freq_count <= freq_count + 1;

					if (freq_count = max_freq_count/2) then
						data_buf(count) <= Rx;
					end if;

				else
					freq_count <= 0;

					if (count < Data_Width) then
						count <= count + 1;
					elsif (count = Data_Width) then
						receiving 	<= '0';
						count 		<= 0;
						if (data_buf(0) = '0' and data_buf(data_buf'left-1 to data_buf'left) = "11") then
							data_ready <= '1';
						end if;
					end if;
				end if;
			end if;
		end if;

	end process;


	TO_OUTPUT : process(Clk, data_ready) is
	begin

		if (data_ready = '1') then
			RX_Ready <= '1';
			RX_Data_Out <= data_buf(data_buf'left-2 downto 1);
		else
			RX_Ready <= '0';
		end if;

	end process;

end Behavioral;

