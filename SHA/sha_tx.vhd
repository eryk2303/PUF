--! use standard library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

--! divides the final sha result by eight bits and sending to uart
entity SHA_TX is
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
		--! input SHA-256 hash
		Hash_input			: in hash_array;
		--! states if incoming data is ready
		Hash_ready			: in std_logic;
		--! Tx pin for transmitting
		Tx 					: out std_logic
	);
end SHA_TX;


architecture Behavioral of SHA_TX is

	--! Inputs
	signal TX_Data_Out : std_logic_vector(7 downto 0);
	signal TX_Ready : std_logic :=  '0';

	--! Outputs
	signal TX_Start : std_logic;

	signal new_d : std_logic := '0';



	signal hash_is_ready : std_logic;

begin

	--! declaration uart_tx component
	UART_TX: entity work.UART_TX
		generic map(
			CLK_FREQUENCY	=> CLK_FREQUENCY,
			DATA_WIDTH 		=> DATA_WIDTH,
			BAUD			=> BAUD
		)
   		port map(
			Clk => Clk,
			Reset => Reset,
			TX_Data_In => TX_Data_Out,
			TX_Ready => TX_Ready,
			TX_Start => TX_Start,
			Tx => Tx
        );

	process(Clk, Reset, Hash_ready) is

	--! count to set when next uart packet should start
	variable count_array 	: natural range 0 to 8 := 0;
	variable count_dword 	: natural range 0 to 4 := 4;
	variable tmp 				: DWORD;
	begin
	if Hash_ready = '0' then
		hash_is_ready <= '0';
		count_array := 0;
	end if;
	
		if rising_edge(Clk) then
			TX_Ready <= '0';
			if Reset = '0' then
				if Hash_ready = '1' then
					hash_is_ready <= '1';
				end if;
				if hash_is_ready = '1' then
					if TX_Start = '1' then
						if count_array < 8 then
							if count_dword > 0 then
								TX_Ready <= '1';
								tmp := Hash_input(count_array);
								TX_Data_Out <= tmp(count_dword*8-1 downto count_dword*8-8);
								count_dword := count_dword - 1;
							end if;
							if count_dword = 0 then
								count_array := count_array + 1;
								count_dword := 4;
							end if;
							if count_array = 8 then
								count_array := 0;
								hash_is_ready <= '0';
							end if;

						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

end Behavioral;

