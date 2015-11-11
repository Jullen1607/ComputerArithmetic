-------------------------------------------------------------------------------
--
-- File: NaiveAdder
-- Author: Julian Ferrer
-- Original Project: Computer Arithmetic Components
-- Date: 21 October 2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright National Instruments Corporation
-- All Rights Reserved
-- National Instruments Internal Information
-------------------------------------------------------------------------------
--
-- Purpose:
--   The Naive Adder lets the Compilation tools decide what to do, it cannot
--   get any more simpler than S = A + B
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity NaiveAdder is
  generic(
    kDataLength : natural := 16);
  port(
    --Inputs
    aA    : in  std_logic_vector(kDataLength - 1 downto 0);
    aB    : in  std_logic_vector(kDataLength - 1 downto 0);
    aCin  : in  std_logic;
    --Outputs
    aS    : out std_logic_vector(kDataLength - 1 downto 0);
    aCout : out std_logic
  );

end entity NaiveAdder;

architecture rtl of NaiveAdder is
  signal aExtendedSum : unsigned (kDataLength downto 0);
  signal aCinNatural  : natural;
begin
  --Transform the Carry In to a Natural
  aCinNatural <= 0 when aCin = '0' else 1;
  
  --The Result is actually an extra bit so we need to exted A and B
  aExtendedSum <= unsigned('0' & aA) + unsigned('0' & aB) + aCinNatural;
  --Where all but the MSB form the result
  aS <= std_logic_vector(aExtendedSum(aS'range));
  --And the MSB is the Carry Out
  aCout <= aExtendedSum(kDataLength);

end architecture rtl;
