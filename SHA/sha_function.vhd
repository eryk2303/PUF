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

--! Function with calculatete temporary values used to code value
function code_M(
                --! expanded message blocks
                constant data :  	message_block;
                --! input word
                constant word_input : in std_logic_vector(31 downto 0);
                --! number of iteration
                constant iterator :  std_logic_vector(5 downto 0)
                ) return std_logic_vector;

--! compression function for current iteration
procedure transform(
                --! Hash values from the previous iteration
                signal h0, h1, h2, h3, h4, h5, h6, h7 : inout  std_logic_vector(31 downto 0);
                --! Expanded message block value for current intertion
                constant M : in std_logic_vector(31 downto 0);
                --! constants_value for current intertion
                constant K : in std_logic_vector(31 downto 0)
                );

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


    function code_M(
                constant data 	    :  message_block;
                constant word_input : in std_logic_vector(31 downto 0);
                constant iterator   :  std_logic_vector(5 downto 0)
                ) return std_logic_vector
    is
        variable i : integer := to_integer(unsigned(iterator));
    begin

        if i < 16 then
            return word_input;
        else
            return std_logic_vector(unsigned(SIG1(data(i - 2))) + unsigned(data(i - 7)) + unsigned(SIG0(data(i - 15))) + unsigned(data(i - 16)));
        end if;

    end function code_M;


    procedure transform(
                    signal h0, h1, h2, h3, h4, h5, h6, h7 : inout  std_logic_vector(31 downto 0);
                    constant M : in std_logic_vector(31 downto 0);
                    constant K : in std_logic_vector(31 downto 0)
                    ) is

		variable a, b, c, d, e, f, g, h : std_logic_vector(31 downto 0);

        begin


            a := h0;
            b := h1;
            c := h2;
            d := h3;
            e := h4;
            f := h5;
            g := h6;
            h := h7;


            h := g;
            g := f;
            f := e;
            e := code_e(h, e, f, g, d, M, K);
            d := c;
            c := b;
            b := a;
            a := code_a(h, e, f, g, a, b, c, M, K);

            h0 <= a;
            h1 <= b;
            h2 <= c;
            h3 <= d;
            h4 <= e;
            h5 <= f;
            h6 <= g;
            h7 <= h;

    end procedure;



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