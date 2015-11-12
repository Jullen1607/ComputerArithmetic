-------------------------------------------------------------------------------
--
-- File: GenPropCarryLogic
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
--   This component Figures out if a set of bits will Generate or Propagate a
--   a carry. The Propagation ocurs when at least one input bit is '1' and 
--   generation when both bits are '1'
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity GenPropCarryLogic is
  port(
    aA    : in  std_logic;
    aB    : in  std_logic;
    aGen  : out std_logic;
    aProp : out std_logic);

end entity GenPropCarryLogic;

architecture rtl of GenPropCarryLogic is
  
begin
  --The Generation of a Carry occurs only when both inputs are '1'
  aGen  <= aA and aB;
  
  --The Propagation of a Carry occurs when any input is '1'
  aProp <= aA  or aB;
  
end architecture rtl;
