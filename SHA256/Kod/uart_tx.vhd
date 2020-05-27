--! use standart library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

--! use work packages
use work.sha_function.all;
use work.constants.all;

--! Definition of UART TX
entity uart_tx is
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
		--! data to transmit
		TX_Data_In			: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		--! definition when new data come
		TX_Ready				: in std_logic;
		--! Tx pin for transmitting
		Tx					: out std_logic := '1';
		--! definition when new data can come
		TX_Start			: out std_logic := '1'
		);
end uart_tx;

architecture Behavioral of uart_tx is

--! length of one bit in clock cycles
constant MAX_FREQ_COUNT	: positive := CLK_FREQUENCY / BAUD;

--! used for counting clock cycles
signal freq_count 	: natural range 0 to MAX_FREQ_COUNT - 1;
--! counting received bits
signal count 		: natural range 0 to 11 := 11;


begin

TX_PROCESS: process(Clk, Reset)
	begin
		if rising_edge(ClK) then
			if count = 11 then
				TX_Start <= '1';
					if TX_Ready = '1' then
						TX_Start <= '0';
						count <=0;
						freq_count <= 0;
			end if;
			end if;
			if Reset = '0' then
				if freq_count < (MAX_FREQ_COUNT - 1) then
					freq_count <= freq_count + 1;
					if count = 0 then
						Tx <= '0';
					end if;
					if count > 0 then
						if count < 9 then
							Tx <= TX_Data_In(count - 1);
						end if;
					end if;
					if count = 10 then
						Tx <= '1';
					end if;
					if count = 9 then
						Tx <= '1';
					end if;
				else
					freq_count <= 0;
					if count < 11 then
						count <= count + 1;
					end if;
				end if;
			else
				TX_Start <= '1';
				count <= 0;
				Tx <= '1';
				freq_count <= 0;
			end if;
		end if;
	end process;



end Behavioral;

