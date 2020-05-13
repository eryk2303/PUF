library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sha_function.all;
use work.constants.all;

entity uart_commander is
	generic(
		DATA_WIDTH : positive := 8
		);
	port(
		clk 			: in std_logic;
		
		RX_Data 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		RX_Ready 	: in std_logic;
		
	--	TX_Data		: out std_logic_vector(DATA_WIDTH-1 downto 0);
	--	TX_Ready		: out std_logic := '0';
		
		output_DATA 	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		output_length 	: out positive range 1 to DATA_WIDTH;
		output_ready 	: out std_logic := '0';
		output_finish 	: out std_logic := '0';
		
		Reset_All 		: out std_logic := '1'
		);
end uart_commander;

architecture Behavioral of uart_commander is

	type STATE_TYPE is (WAITING, RECEIVING);
	signal state 	: STATE_TYPE := WAITING;
	
	signal command : string(8 downto 1);
	
	signal f_ready : std_logic := '0';
	signal f_reset : std_logic := '0';
	

begin

	
	RX_COMMANDER : process(clk) is
		variable counter : natural range 0 to 512 := 0;
	begin
		if rising_edge(clk) then
			if RX_Ready = '0' then
				f_ready 			<= '0';
				output_ready 	<= '0';
				
				
			elsif RX_Ready = '1' and f_ready='0' then
				f_ready <= '1';
				
				case state is
					when WAITING =>
					
							case command(8 downto 4) is
								when "START" =>
									counter 	:=	100 * (character'pos(command(3)) mod 48) +
													10  * (character'pos(command(2)) mod 48) +
															(character'pos(command(1)) mod 48);
									state		<= RECEIVING;
									
								when others =>	null;
							end case;
							case command(5 downto 1) is
								when "FINIS" =>
									output_finish 	<= '1';
									
								when "RESET" =>
									f_reset 			<= '1';
									Reset_All 		<= '1';
									output_finish 	<= '0';
																
								when others => null;
							end case;
							
							command <= command(7 downto 1) & character'val(to_integer(unsigned(RX_Data)));
						
						
					when RECEIVING =>
					
							if counter > DATA_WIDTH then
								output_length 	<= DATA_WIDTH;
								counter 			:= counter - DATA_WIDTH;
							else
								output_length 	<= counter;
								counter 			:= 0;
								state 			<= WAITING;
							end if;
							
							output_DATA 	<= RX_Data;
							output_ready 	<= '1';
						
				end case;
			end if;
			
			
			if f_reset = '1' then
				Reset_All 	<= '0';
				f_reset 		<= '0';
			end if;
			
		end if;
	end process;
	
	TX_COMMANDER : process(clk) is
	begin
	end process;


end Behavioral;

