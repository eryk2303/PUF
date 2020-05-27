-------------------------------------------------------------------------------
--! @file sha_function.vhdl
--! @brief Definition function used in sha algorithm
-------------------------------------------------------------------------------

--! Use standart library
library IEEE;
--! use logic elements
use IEEE.STD_LOGIC_1164.all;
--! use numeric elements
use ieee.numeric_std.all;
--! use constants value
use work.constants.all;

--! Packet with definition function used in sha algorithm
package sha_function is


--! Function with mathemeatical operations used in sha
function CH(x, y, z : std_logic_vector) return std_logic_vector;
--! Function with mathemeatical operations used in sha
function MAJ(x, y, z : std_logic_vector) return std_logic_vector;

--! function used because of lack unicode support
function EP0(x : std_logic_vector) return std_logic_vector;
--! function used because of lack unicode support
function EP1(x : std_logic_vector) return std_logic_vector;

--! function used because of lack unicode support
function SIG0(x : std_logic_vector) return std_logic_vector;
--! function used because of lack unicode support
function SIG1(x : std_logic_vector) return std_logic_vector;

--! Function with calculatete temporary values used to code value
function code_e(h, e, f, g, d, M, K : std_logic_vector) return std_logic_vector;
--! Function with calculatete temporary values used to code value
function code_a(h, e, f, g, a, b, c, M, K : std_logic_vector) return std_logic_vector;


--! add previous and current value
 procedure adding(
                --! Hash values from the previous iteration
                signal h : inout  hash_array;
                --! Hash values from the current iteration
                signal w_v : in  hash_array
                );


end sha_function;



package body sha_function is


    function CH(x, y, z : std_logic_vector) return std_logic_vector is
        begin

        return (x and y) xor ((not x) and z);
    end function CH;

    function MAJ(x, y, z : std_logic_vector) return std_logic_vector is
        begin

        return (x and y) xor (x and z) xor (y and z);
    end function MAJ;

    function EP0(x : std_logic_vector) return std_logic_vector is
        begin

        return std_logic_vector(rotate_right(unsigned(x), 2) xor rotate_right(unsigned(x), 13) xor rotate_right(unsigned(x), 22));
    end function EP0;

    function EP1(x : std_logic_vector) return std_logic_vector is
        begin

        return std_logic_vector(rotate_right(unsigned(x), 6) xor rotate_right(unsigned(x), 11) xor rotate_right(unsigned(x), 25));
    end function EP1;

    function SIG0(x : std_logic_vector) return std_logic_vector is
        begin

        return std_logic_vector(rotate_right(unsigned(x), 7) xor rotate_right(unsigned(x), 18) xor shift_right(unsigned(x), 3));
    end function SIG0;

    function SIG1(x : std_logic_vector) return std_logic_vector is
        begin

        return std_logic_vector(rotate_right(unsigned(x), 17) xor rotate_right(unsigned(x), 19) xor shift_right(unsigned(x), 10));
    end function SIG1;


    function code_e(h, e, f, g, d, M, K : std_logic_vector) return std_logic_vector is

        variable tmp1 : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(h) + unsigned(EP1(e)) + unsigned(CH(e,f,g)) + unsigned(K) + unsigned(M));
    begin

        return std_logic_vector(unsigned(d) + unsigned(tmp1));
    end function code_e;


    function code_a(h, e, f, g, a, b, c, M, K : std_logic_vector) return std_logic_vector  is

        variable tmp1 : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(h) + unsigned(EP1(e)) + unsigned(CH(e,f,g)) + unsigned(K) + unsigned(M));
        variable tmp2 : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(EP0(a)) + unsigned(MAJ(a,b,c)));
    begin

        return std_logic_vector(unsigned(tmp1) + unsigned(tmp2));
    end function code_a;


    procedure adding(
                    --! Hash values from the previous iteration
                    signal h : inout  hash_array;
                    --! Hash values from the current iteration
                    signal w_v : in  hash_array
                    ) is
        begin
            h(0) <= std_logic_vector(unsigned(w_v(0)) + unsigned(h(0)));
            h(1) <= std_logic_vector(unsigned(w_v(1)) + unsigned(h(1)));
            h(2) <= std_logic_vector(unsigned(w_v(2)) + unsigned(h(2)));
            h(3) <= std_logic_vector(unsigned(w_v(3)) + unsigned(h(3)));
            h(4) <= std_logic_vector(unsigned(w_v(4)) + unsigned(h(4)));
            h(5) <= std_logic_vector(unsigned(w_v(5)) + unsigned(h(5)));
            h(6) <= std_logic_vector(unsigned(w_v(6)) + unsigned(h(6)));
            h(7) <= std_logic_vector(unsigned(w_v(7)) + unsigned(h(7)));

    end procedure;
end sha_function;