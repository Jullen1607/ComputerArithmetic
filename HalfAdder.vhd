-------------------------------------------------------------------------------
--
-- File: HalfAdder
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
--   The Half Added follows the same rules of an adder but doesn't have a carry
--   at the input. This component also exposes the Generate and Propagate
--   signals
--
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity HalfAdder is
  port(
    aA    : in  std_logic;
    aB    : in  std_logic;
    aS    : out std_logic;
    aCout : out std_logic;
    aGen  : out std_logic;
    aProp : out std_logic
  );

end entity HalfAdder;

architecture rtl of HalfAdder is

  --vhook_sigstart
  signal aGenInt: std_logic;
  signal aPropInt: std_logic;
  --vhook_sigend

begin

  --vhook_e GenPropCarryLogic
  --vhook_a aGen aGenInt
  --vhook_a aProp aPropInt
  GenPropCarryLogicx: entity work.GenPropCarryLogic (rtl)
    port map (
      aA    => aA,        --in  std_logic
      aB    => aB,        --in  std_logic
      aGen  => aGenInt,   --out std_logic
      aProp => aPropInt); --out std_logic

  aGen  <= aGenInt;
  aProp <= aPropInt;

  --The Sum Out bit is '1' when we are Propagating but not generating. It is
  --equivalent to an exclusive OR operation between the aA and aB.
  aS    <= aPropInt and not aGenInt;

  --The Carry Out will happen only when the inputs generate a carry.
  aCout <= aGenInt;



end architecture rtl;
