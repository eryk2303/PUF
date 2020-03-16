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

use work.constants_sha256_definition.all;
use work.constants_sha256_definition.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sha256 is
	
	port(
			clk	: in std_logic;
			
			word_to_transform : in std_logic_vector(31 downto 0);
			
			transformed_word : out std_logic_vector(255 downto 0);


end sha256;

architecture Behavioral of sha256 is

begin


end Behavioral;

