----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:33:49 03/16/2020 
-- Design Name: 
-- Module Name:    sha256 - Behavioral 
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
use work.constants.all;
use work.sha_function.all;


entity sha256 is
	
	port(
			clk	: in std_logic;
			word_to_transform : in std_logic_vector(31 downto 0);
			transformed_word : out std_logic_vector(255 downto 0));
end sha256;

architecture Behavioral of sha256 is


		

component sha_tx
port(
		Clk_Sha_Uart : in  std_logic;
      Reset_Sha_Uart : in  std_logic;
      New_Data : in  std_logic;
      Data_In : in  std_logic_vector(255 downto 0);
      Finish_Transmit : out  std_logic);
end component;
    

   --Inputs
signal Clk_Sha_Uart : std_logic := '0';
signal Reset_Sha_Uart : std_logic := '0';
signal New_Data : std_logic := '0';
signal Data_In : std_logic_vector(255 downto 0) := (others => '0');

 	--Outputs
signal Finish_Transmit : std_logic;

signal tmp : std_logic_vector(7 downto 0);

begin

transmission: sha_tx port map (
          Clk_Sha_Uart => Clk_Sha_Uart,
          Reset_Sha_Uart => Reset_Sha_Uart,
          New_Data => New_Data,
          Data_In => Data_In,
          Finish_Transmit => Finish_Transmit);
		  
		  
		  
		  


end Behavioral;

