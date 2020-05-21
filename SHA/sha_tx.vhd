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
	Hash_input			: in hash_array
	);

end sha_tx;
--! dividing the final sha result by eight bits and calling uart

architecture Behavioral of sha_tx is    

	--Inputs
	signal TX_Data_Out : std_logic_vector(7 downto 0) := (others => '0');
	signal TX_Go : std_logic := '1';

		--Outputs
	signal TX_Start : std_logic;
	signal Tx : std_logic;
	
	signal new_d : std_logic := '0';

	--! count to set when next uart packet should start 
	signal count : integer range 1 to 33 := 33;

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
		  
	process(Clk, Reset, Hash_ready)
	begin
		if rising_edge(Clk) then
			if Reset = '0' then
				if count > 0 then
					if count < 33 then 
						if TX_Start = '0' then
							TX_Go <= '1';
							Tx_Data_Out <= Hash_input(count-1);
							count <= count + 1;
						else 
							TX_Go <= '0';
						end if;
					end if;
				end if;
				if count = 33 then 
					if Hash_ready = '1' then
						count <= 1;
					end if;
				end if;
			else 
				Tx_Data_Out <= (others => '0');
				Reset <= '1';
			end if;
		end if;
	end process;

end Behavioral;

