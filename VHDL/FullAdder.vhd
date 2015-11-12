-------------------------------------------------------------------------------
--
-- File: FullAdder
-- Author: Julian Ferrer
-- Original Project: Computer Arithmetic Components
-- Date: 24 September 2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright National Instruments Corporation
-- All Rights Reserved
-- National Instruments Internal Information
-------------------------------------------------------------------------------
--
-- Purpose:
--   The Full Added follows the next truth table
--   +----------+--------+
--   | A  B Cin | S Cout |
--   | 0  0  0  | 0   0  |
--   | 0  0  1  | 1   0  |
--   | 0  1  0  | 1   0  |
--   | 0  1  1  | 0   1  |
--   | 1  0  0  | 1   0  |
--   | 1  0  1  | 0   1  |
--   | 1  1  0  | 0   1  |
--   | 1  1  1  | 1   1  |
--   +----------+--------+
--  It is implemented trough two Half Adders to add first the two inputs and the
--  Input Carry and the Carry Out occurs when any Half Adders is Generating a
--  Carry.
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity FullAdder is
  port(
    aA    : in  std_logic;
    aB    : in  std_logic;
    aCin  : in  std_logic;
    aS    : out std_logic;
    aCout : out std_logic;
    aGen  : out std_logic;
    aProp : out std_logic
  );

end entity FullAdder;

architecture struct of FullAdder is

  --vhook_sigstart
  signal aGenInt: std_logic;
  signal aHalfS: std_logic;
  signal aHcinGen: std_logic;
  --vhook_sigend

begin

  --The first Half Adder creates the output generate and propagate signals
  --vhook_e HalfAdder AplusB
  --vhook_a aS aHalfS
  --vhook_a aCout open
  --vhook_a aGen  aGenInt
  AplusB: entity work.HalfAdder (rtl)
    port map (
      aA    => aA,       --in  std_logic
      aB    => aB,       --in  std_logic
      aS    => aHalfS,   --out std_logic
      aCout => open,     --out std_logic
      aGen  => aGenInt,  --out std_logic
      aProp => aProp);   --out std_logic

  --vhook_e HalfAdder HalfPlusCin
  --vhook_a aA aHalfS
  --vhook_a aB aCin
  --vhook_a aCout open
  --vhook_a aGen aHcinGen
  --vhook_a aProp open
  HalfPlusCin: entity work.HalfAdder (rtl)
    port map (
      aA    => aHalfS,    --in  std_logic
      aB    => aCin,      --in  std_logic
      aS    => aS,        --out std_logic
      aCout => open,      --out std_logic
      aGen  => aHcinGen,  --out std_logic
      aProp => open);     --out std_logic

  aGen  <= aGenInt;
  aCout <= aGenInt or aHcinGen;

end architecture struct;
