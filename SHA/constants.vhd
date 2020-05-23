-------------------------------------------------------------------------------
--! @file constants.vhdl
--! @brief Definitions of new types of values and constant variables
-------------------------------------------------------------------------------

--! Use standart library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.all;
--! use numeric elements
use IEEE.NUMERIC_STD.ALL;


--! Packet with definitions of new types of values and constant variables
package constants is

--! Type definition of 32-bit word
subtype DWORD is std_logic_vector(31 downto 0);

--! Type definition for storing message block's array of 32-bit words
type message_block is array(0 to 15) of DWORD;

--! Type definition for storing message schedule's array of 32-bit words
type message_schedule is array (0 to 63) of DWORD;

--! Type definition for storing the constants array
type constant_values_sha256 is array(0 to 63) of DWORD;

--! Array of constant values used in sha algoritm
constant constant_values : constant_values_sha256 := (
			x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
			x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
			x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
			x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
			x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
			x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
			x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
			x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
		);

--! Type definition for constants initial hash values
type hash_array is array(0 to 7) of DWORD;

--! Initial hash values
constant constant_initials : hash_array := (
			x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a", x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
		);

--! Type definition for storing 5 ascii characters in binary
subtype command_type is std_logic_vector(39 downto 0);

--! Type definition for storing ascii strings in binary
type command_array_type is array(0 to 2) of command_type;

--! Array of constant ascii strings
constant command_array : command_array_type := (
			x"5354415254", --! "START"
			x"46494e4953", --! "FINIS"
			x"5245534554"  --! "RESET"
		);

--! Aliases for command array's elements
alias com_START : command_type is command_array(0);
alias com_FINIS : command_type is command_array(1);
alias com_RESET : command_type is command_array(2);

end constants;


