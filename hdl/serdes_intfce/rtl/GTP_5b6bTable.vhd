----------------------------------------------------
----------------------------------------------------
-- THIS FILE WAS GENERATED BY VISUAL ELITE
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
----------------------------------------------------
----------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
----------------------------------------------------
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
----------------------------------------------------
----------------------------------------------------
--
--  Library Name :  GTP
--  Unit    Name :  GTP_5b6bTable
--  Unit    Type :  Truth Table
--
------------------------------------------------------

library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
entity GTP_5b6bTable is
  port (
        In5b : in std_logic_vector(4 downto 0 );
        Out6b : out std_logic_vector(5 downto 0 );
        DatFlip : out std_logic;
        DispFlip : out std_logic
        );

end GTP_5b6bTable;


architecture GTP_5b6bTable of GTP_5b6bTable is


begin
  GTP_5b6bTable:
  process (In5b)
  begin

    if (In5b = "00000") then
      Out6b <= "100111";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D0
    elsif (In5b = "00001") then
      Out6b <= "011101";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D1
    elsif (In5b = "00010") then
      Out6b <= "101101";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D2
    elsif (In5b = "00011") then
      Out6b <= "110001";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D3
    elsif (In5b = "00100") then
      Out6b <= "110101";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D4
    elsif (In5b = "00101") then
      Out6b <= "101001";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D5
    elsif (In5b = "00110") then
      Out6b <= "011001";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D6
    elsif (In5b = "00111") then
      Out6b <= "111000";
      DatFlip <= '1';
      DispFlip <= '0';
    --  D7
    elsif (In5b = "01000") then
      Out6b <= "111001";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D8
    elsif (In5b = "01001") then
      Out6b <= "100101";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D9
    elsif (In5b = "01010") then
      Out6b <= "010101";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D10
    elsif (In5b = "01011") then
      Out6b <= "110100";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D11
    elsif (In5b = "01100") then
      Out6b <= "001101";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D12
    elsif (In5b = "01101") then
      Out6b <= "101100";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D13
    elsif (In5b = "01110") then
      Out6b <= "011100";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D14
    elsif (In5b = "01111") then
      Out6b <= "010111";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D15
    elsif (In5b = "10000") then
      Out6b <= "011011";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D16
    elsif (In5b = "10001") then
      Out6b <= "100011";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D17
    elsif (In5b = "10010") then
      Out6b <= "010011";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D18
    elsif (In5b = "10011") then
      Out6b <= "110010";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D19
    elsif (In5b = "10100") then
      Out6b <= "001011";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D20
    elsif (In5b = "10101") then
      Out6b <= "101010";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D21
    elsif (In5b = "10110") then
      Out6b <= "011010";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D22
    elsif (In5b = "10111") then
      Out6b <= "111010";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D23
    elsif (In5b = "11000") then
      Out6b <= "110011";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D24
    elsif (In5b = "11001") then
      Out6b <= "100110";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D25
    elsif (In5b = "11010") then
      Out6b <= "010110";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D26
    elsif (In5b = "11011") then
      Out6b <= "110110";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D27
    elsif (In5b = "11100") then
      Out6b <= "001110";
      DatFlip <= '0';
      DispFlip <= '0';
    --  D28
    elsif (In5b = "11101") then
      Out6b <= "101110";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D29
    elsif (In5b = "11110") then
      Out6b <= "011110";
      DatFlip <= '1';
      DispFlip <= '1';
    --  D30
    elsif (In5b = "11111") then
      Out6b <= "101011";
      DatFlip <= '1';
      DispFlip <= '1';
    else
      --  D31

      Out6b <= "000000";
      DatFlip <= '0';
      DispFlip <= '0';
    end if ;
  end process GTP_5b6bTable;

end GTP_5b6bTable;

