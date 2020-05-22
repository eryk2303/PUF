----------------------------------------------------------------------------------
--! Engineer: EW, JP 
-- 
--! Create Date:    10:50:02 03/28/2020 
--! Design Name: sha_tx
--! Module Name:    sha_tx - Behavioral 
--! Project Name: SHA256
--!  @brief dividing the final sha result by eight bits and calling uart
--
----------------------------------------------------------------------------------

--! Use standart library 
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.ALL;

use work.sha_function.all;
use work.constants.all;

--! dividing the final sha result by eight bits and calling uart
entity sha_tx is
generic(
	--! message uart length
	Width_Data_Uart : INTEGER := 8
	);
		
port(
	Clk					: in std_logic;
	Reset				: in std_logic;
	--! informs if incoming data is ready
	Hash_ready			: in std_logic;
	--! sha data
	Hash_input			: in hash_array;
	Tx 					: out std_logic
	);

end sha_tx;
--! dividing the final sha result by eight bits and calling uart

architecture Behavioral of sha_tx is    

	--Inputs
	signal TX_Data_Out : std_logic_vector(7 downto 0);
	signal TX_Go : std_logic :=  '0';

		--Outputs
	signal TX_Start : std_logic;
	
	signal new_d : std_logic := '0';

	
	
	signal hash_is_ready : std_logic;

begin
 
	--! declaration uart_tx component 
   sha_tx: entity work.uart_tx
   		port map(
			Clk => Clk,
			Reset => Reset,
			TX_Data_In => TX_Data_Out,
			TX_Go => TX_Go,
			TX_Start => TX_Start,
			Tx => Tx
        );
		  
	process(Clk, Reset, Hash_ready) is 
	
	--! count to set when next uart packet should start 
	variable count_array 	: natural range 0 to 8 := 0;
	variable count_dword 	: natural range 0 to 4 := 4;
	variable tmp 				: DWORD;
	begin
		if rising_edge(Clk) then
			TX_Go <= '0';
			if Reset = '0' then
				if Hash_ready = '1' then
					hash_is_ready <= '1';
				end if;
				if hash_is_ready = '1' then
					if TX_Start = '1' then				
						if count_array < 8 then 
							if count_dword > 0 then 
								TX_Go <= '1';
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

