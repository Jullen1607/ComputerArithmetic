-------------------------------------------------------------------------------
--
-- File: RippleCarryAdder
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
--   The Ripple Carry Adder is the simplest Adder, it is composed by a Full
--   Adder for each pair of input bits, where the Carry In comes from the
--   previous Full Adder.
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.PkgAddersUtilities.all;

entity RippleCarryAdder is
  generic(
    kDataLength : natural := 16);
  port(
    aA         : in  std_logic_vector(kDataLength - 1 downto 0);
    aB         : in  std_logic_vector(kDataLength - 1 downto 0);
    aCin       : in  std_logic;
    aS         : out std_logic_vector(kDataLength - 1 downto 0);
    aGroupGen  : out std_logic;
    aGroupProp : out std_logic;
    aCout      : out std_logic
  );

end entity RippleCarryAdder;

architecture struct of RippleCarryAdder is

  --vhook_sigstart
  --vhook_sigend

  --We need an array to contain the Carries of each Full Adder
  signal aCint : std_logic_vector(kDataLength downto 0);
  signal aPropVector, aGenVector : std_logic_vector(aS'range);

begin
  aCint(0) <= aCin;
  aCout    <= aCint(aCint'high);
  RCA: for i in aS'range generate
    --vhook_e FullAdder
    --vhook_a aA    aA(i)
    --vhook_a aB    aB(i)
    --vhook_a aCin  aCint(i)
    --vhook_a aS    aS(i)
    --vhook_a aCout aCint(i + 1)
    --vhook_a aGen  aGenVector(i)
    --vhook_a aProp aPropVector(i)
    FullAdderx: entity work.FullAdder (struct)
      port map (
        aA    => aA(i),           --in  std_logic
        aB    => aB(i),           --in  std_logic
        aCin  => aCint(i),        --in  std_logic
        aS    => aS(i),           --out std_logic
        aCout => aCint(i + 1),    --out std_logic
        aGen  => aGenVector(i),   --out std_logic
        aProp => aPropVector(i)); --out std_logic

  end generate RCA;

  aGroupGen  <= GenerateLogic(Gen => aGenVector, Prop => aPropVector);
  aGroupProp <= AndVector(aPropVector);

end architecture struct;
