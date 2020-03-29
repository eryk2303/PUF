----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:02 03/28/2020 
-- Design Name: 
-- Module Name:    sha_tx - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sha_tx is
generic(
		Width_Data_Sha : INTEGER := 256;
		Width_Data_Uart : INTEGER := 8);
		
port(
	Clk_Sha_Uart		: in std_logic;
	Reset_Sha_Uart		: in std_logic;
	New_Data				: in std_logic;
	Data_In				: in std_logic_vector(Width_Data_Sha - 1 downto 0);
	Finish_Transmit	: out std_logic := '1');

end sha_tx;

architecture Behavioral of sha_tx is

    component uart_tx
    port(
         Clk 			: in  std_logic;
         Reset 		: in  std_logic;
         TX_Data_In 	: in  std_logic_vector(7 downto 0);
         TX_Go 		: in  std_logic;
         TX_Start 	: out  std_logic;
         Tx 			: out  std_logic);
    end component;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal TX_Data_Out : std_logic_vector(7 downto 0) := (others => '0');
   signal TX_Go : std_logic := '1';

 	--Outputs
   signal TX_Start : std_logic;
   signal Tx : std_logic;
	
	
	signal new_d : std_logic := '0';

	signal count : integer range 1 to 33 := 33;

begin
 
   sha_tx: uart_tx PORT MAP (
          Clk => Clk,
          Reset => Reset,
          TX_Data_In => TX_Data_Out,
          TX_Go => TX_Go,
          TX_Start => TX_Start,
          Tx => Tx
        );
		  
	process(Clk_Sha_Uart, Reset_Sha_Uart, New_Data)
	begin
		if rising_edge(Clk_Sha_Uart) then
			if Reset_Sha_Uart = '0' then
				if count > 0 then
					if count < 33 then 
						if TX_Start = '0' then
							TX_Go <= '1';
							Reset <= '0';
							Tx_Data_Out <= Data_In(count * (Width_Data_Uart - 1) downto (count-1)*(Width_Data_Uart - 1));
							count <= count + 1;
							Finish_Transmit <= '0';
						else 
							TX_Go <= '0';
							Finish_Transmit <= '0';
						end if;
					end if;
				end if;
				if count = 33 then 
					Finish_Transmit <= '1';
					if New_Data = '1' then
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

