-------------------------------------------------------------------------------
--
-- File: CarryLookAheadLogic.vhd
-- Author: Julian Ferrer
-- Original Project: Computer Arithmetic Components
-- Date: 3 November 2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright National Instruments Corporation
-- All Rights Reserved
-- National Instruments Internal Information
-------------------------------------------------------------------------------
--
-- Purpose:
--   The Carry Look Ahead Logic receives the Generate and Propagate signals of
--   n Full Adders and comes up with a Carry in for each adder, a Carry Output,
--   a Group generate and a Group Propagate.
--   In general, the formula for any Carry is:
--   Cn = Gn-1 || (Cn-1 && Pn-1)
--
--   This method expands the logic of each carry with the previous carry formula
--   until it gets to the Initial Input Carry. The bigger the group the longer
--   the formula gets. The Group Generate and Propagate indicate if this
--   component as a whole will generate or propagate a carry.
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
library work;
  use work.PkgAddersUtilities.all;  


entity CarryLookAheadLogic is
  generic(
    kGroupLength : natural := 4);
  port(
    --Inputs
    aGen       : in  std_logic_vector(kGroupLength - 1 downto 0);
    aProp      : in  std_logic_vector(kGroupLength - 1 downto 0);
    aCin       : in  std_logic;
    --Outputs
    aC         : out std_logic_vector(kGroupLength - 1 downto 0);
    aGroupGen  : out std_logic;
    aGroupProp : out std_logic
  );

end entity CarryLookAheadLogic;

architecture rtl of CarryLookAheadLogic is
begin
  --The Carry of the LSB is just the Input Carry
  aC(aC'low) <= aCin;

  --The next carries are more interesting, for any bit we can say that the Carry
  --will be true if any of the previous bits is generating a carry and it is
  --able to propagate up to the current bit. This rule applies also for the
  --Input carry, where it will only get to the current bit if all of the
  --previous allow it to propagate. Therefore we can say that the Input Carry
  --is like a generate for the previous circuit.
  --Another consideration is that if the Group Length is 1, there is no point
  --on doing the for loop since it was taken care with the above statement, so
  --we have to skip that case.
  InputNotABitGen: if kGroupLength > 1 generate
    --The GenerateLogic works just fine for this as long as we use the Input
    --Carry as the LSB of the Generate Vector and we fake a Propagate since it
    --isn't used anyway by the formula.
    CarryGen: for i in 1 to aC'High generate
      signal aLclGen, aLclProp : std_logic_vector(i downto 0);
    begin
      aLclGen  <= aGen(i - 1 downto 0) & aCin;
      aLclProp <= aProp(i - 1 downto 0) & '1';
      aC(i) <= GenerateLogic(Gen  => aLclGen,
                             Prop => aLclProp);
    end generate CarryGen;
  end generate InputNotABitGen;

  --This circuit will Generate a carry if the generate signal of any bit
  --gets propagated up to the output or if the MSB generates a carry
  aGroupGen  <= GenerateLogic(Gen => aGen, Prop => aProp);

  --This circuit will propagate a carry only if all of the bits propagate the
  --carry
  aGroupProp <= AndVector(aProp);
end architecture rtl;
