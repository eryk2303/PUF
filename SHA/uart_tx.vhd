----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:27:11 03/26/2020 
-- Design Name: 
-- Module Name:    uart_tx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tx is
generic(
		Clk_Frequenty	: INTEGER:= 12000000;
		Width_Data : INTEGER := 8;
		Baud	: INTEGER := 19200);
		
port(
	Clk			: in std_logic;
	Reset			: in std_logic;
	TX_Data_In	: in std_logic_vector(Width_Data - 1 downto 0);
	TX_Go			: in std_logic;
	TX_Start		: out std_logic := '0';
	Tx				: out std_logic := '1');
	

end uart_tx;

architecture Behavioral of uart_tx is


constant max_freq_count	: integer := Clk_Frequenty / Baud;
signal freq_count : integer range 0 to max_freq_count;
signal count : integer range 0 to 10;


begin


TX_PROCESS: process(Clk, Reset,TX_Go)
	begin
		if rising_edge(ClK) then
			if Reset = '0' then
				if freq_count < max_freq_count then
					freq_count <= freq_count + 1;
					if count = 0 then
						Tx <= '0';
					end if;
					if count > 0 then
						if count < 9 then
							Tx <= TX_Data_In(count - 1);
						end if;
					end if;
					if count = 9 then
						TX_Start <= '1';
						Tx <= '1';
					else 
						TX_Start <= '0';
					end if;		
				else 
					freq_count <= 0;
					if count < 10 then
						count <= count + 1;
					end if;		
					if count = 10 then
						if TX_Go = '1' then
							count <=0;
							freq_count <= 0;
						end if;
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

