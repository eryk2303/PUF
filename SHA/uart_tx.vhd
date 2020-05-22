----------------------------------------------------------------------------------
-- Engineer: EW, JP
--! Create Date:    18:27:11 03/26/2020  
--! Module Name:    uart_tx - Behavioral 
--! Project Name: SHA256
--! @brief Definition UART TX
----------------------------------------------------------------------------------

--! Use standart library 
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use ieee.numeric_std.all;

--! Definition UART TX
entity uart_tx is
generic(
		Clk_Frequenty	: INTEGER:= 12000000;
		--! message uart length
		Width_Data : INTEGER := 8;
		--! Baud UART definition
		Baud	: INTEGER := 19200);
		
port(
	Clk			: in std_logic;
	Reset			: in std_logic;
	--! data to transmit
	TX_Data_In	: in std_logic_vector(Width_Data - 1 downto 0);
	--! definition when new data come
	TX_Go			: in std_logic;
	--! definition when new data can come
	TX_Start		: out std_logic := '1';
	--! Tx pin transmit 
	Tx				: out std_logic := '1');
	

end uart_tx;

architecture Behavioral of uart_tx is

--!  what freq count should have value to have right value of frequency
constant max_freq_count	: integer := Clk_Frequenty / Baud;

--! counts how long the byte is transmitted
signal freq_count : integer range 0 to max_freq_count - 1;
--! count to set when next byte should start 
signal count : integer range 0 to 11 := 11;


begin

TX_PROCESS: process(Clk, Reset,TX_Go)
	begin
	if count = 11 then
		TX_Start <= '1';
			if TX_Go = '1' then
				TX_Start <= '0';
				count <=0;
				freq_count <= 0;
			end if;
	end if;
		if rising_edge(ClK) then
			if Reset = '0' then
				if freq_count < (max_freq_count - 1) then
					freq_count <= freq_count + 1;
					if count = 0 then
						TX_Start <= '0';
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

