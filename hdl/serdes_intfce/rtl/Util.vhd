------------------------------------------
------------------------------------------
-- Date        : Wed Mar 05 14:09:41 2003
--
-- Author      : J.C. Molendijk / T. Levens
--
-- Company     : CERN, BE-RF
--
-- Description : Utility functions
--
------------------------------------------
------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Util is

    -- Array types
    type natural_array_t is array (natural range <>) of natural;

    -- Conversion function
    function bool_to_stdlogic(InBool : boolean)
        return std_logic;

    function stdlogic_to_bool(InStdLogic : std_logic)
        return boolean;

    -- Binary logarithm -- NOTE: returns Log2(x+1)
    function Log2(x : natural)
        return natural;

    -- Functions to find max/min values
    function Max(x, y : natural)
        return natural;

    function Min(x, y : natural)
        return natural;

    -- Function to select between two values based on a boolean.
    function TFSel(t, f : natural; sel : boolean)
        return natural;

end;



------------------------------------------
------------------------------------------
-- Date        : Wed Mar 05 14:13:30 2003
--
-- Author      : J.C. Molendijk / T. Levens
--
-- Company     : CERN, BE-RF
--
-- Description : Utility functions
--
------------------------------------------
------------------------------------------

package body  Util  is

    -- Conversion from boolean to std_logic
    --   True  => '1'
    --   False => '0'
    function bool_to_stdlogic(InBool : boolean) return std_logic is
        variable result: std_logic;
    begin
        if InBool = true
            then result := '1';
            else result := '0';
        end if;
        return result;
    end bool_to_stdlogic;

    -- Conversion from std_logic to boolean
    --   '1' => True
    --   '0' => False
    function stdlogic_to_bool(InStdLogic : std_logic) return boolean is
        variable result: boolean;
    begin
        if InStdLogic = '1'
            then result := true;
            else result := false;
        end if;
        return result;
    end stdlogic_to_bool;

    -- Calculates the binary logarithm of a number.
    --
    -- NOTE: Unlike the mathematical log operator, this function returns the
    --       number of bits required to store the number specified. So be
    --       careful! For example, while this behaves as expected:
    --
    --          Log2(1023) => 10
    --
    --       But 10 bits only gives you the range 0..1023, so to store the
    --       value 1024 you need 11 bits! So:
    --
    --          Log2(1024) => 11
    --
    function Log2(x : natural) return natural is
        variable xx : natural := x;
        variable z  : natural := 0;
    begin
        while true loop
            if xx = 0 then
                exit;
            elsif xx > 0 then
                z := z + 1;
                xx := xx / 2;
            end if;
        end loop;
        return z;
    end Log2;

    -- Finds the minimum or maximum of two naturals
    function Max(x, y : natural) return natural is
    begin
        if x > y then
            return x;
        else
            return y;
        end if;
    end Max;

    function Min(x, y : natural) return natural is
    begin
        if x < y then
            return x;
        else
            return y;
        end if;
    end Min;

    -- Selects an input based on sel.
    function TFSel(t, f : natural; sel : boolean) return natural is
    begin
        if sel = true then
            return t;
        else
            return f;
        end if;
    end TFSel;

end Util;



