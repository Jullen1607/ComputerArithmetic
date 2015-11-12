-------------------------------------------------------------------------------
--
-- File: CarryLookAheadAdder.vhd
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
--   The Carry LookAhead groups the Inputs into several groups of k bits,
--   those bits are added together using a Carry LookAhead Logic to figure out
--   what should be the Cin of each of the bits using only the information if
--   the any set of bits will Generate a carry or Propagate the Input Carry.
--   The general structure of the CLA adder is as follows (CLA stands for Carry
--   Look Ahead Logic and FA for Full Adder):
--    a b s       a b s    ...   a b s       a b s    ...   a b s       a b s
--   +-----+   . +-----+   ...  +-----+   . +-----+   ...  +-----+   . +-----+
--   | FA  +<+ . | FA  +<+ ...  | FA  +<+ . | FA  +<+ ...  | FA  +<+ . | FA  +<C
--   |-+---| | . |-+---| | ...  |-+---| | . |-+---| | ...  |-+---| | . |-+---| |
--     |     |   _/       \       |     |   _/       \       |     |   _/      |
--     |     |  /          .      |     |  /           .     |     |  /        |
--   GPn-1...GPn-k       ....   GPl-1...GPl-k       ....   GPk-1...GP0         |
--           <+                         <+                         <+          |
--     |  ... ||             |    |  ... ||             |    |  ... ||         |
--  |--+--...--+--|      ... \ |--+--...--+--|      ... \ |--+--...--+--|      |
--  |     CLA     +<-    ...  -+     CLA     +<+    ...  -+     CLA     +<-----+
--  +-----...--+--+  \   ...   +-----...--+--+  \   ...   +-----...--+--+      |
--             |      \                   |      \                   |         |
--             .    .  .   ...            .       .               .  .         |
--             .     <+|   ...           ...     ...               <+|         |
--             |      ||   ...           ...     ...                ||         |
--          |--+--...--+--|         ...                 | |--+--...--+--|      |
--          |     CLA     |         ...                 +-+     CLA     +<-----+
--          +-----...--+--+         ...                   +-----...--+--+      |
--                     |            ...                              |         |
--                     \            ...                              |         |
--                      .           ...                    .         .         |
--                       .          ...                     .        .         |
--                                                           \     <+|         |
--                                                           |      ||         |
--                                                        |--+--...--+--|      |
--                                                        |     CLA     +<-----+
--                                                        +-----...--+--+      |
--                                                                  G P-       |
--                                                                  |   \      |
--                                                                  |    v
--                                                                  |  |-+-|   |
--                                                                  |  |and+<--|
--                                                                  v  |-+-|
--                                                                |-+-|  |
--                                                                |or +<-+
--                                                                |-+-|
--                                                                  |
--                                                                 Cout
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;


entity CarryLookAheadAdder is
  generic(
    kDataLength  : natural := 4;
    kGroupLength : natural := 2);
  port(
    --Inputs
    aA    : in  std_logic_vector(kDataLength - 1 downto 0);
    aB    : in  std_logic_vector(kDataLength - 1 downto 0);
    aCin  : in  std_logic;
    --Outputs
    aS    : out std_logic_vector(kDataLength - 1 downto 0);
    aCout : out std_logic
  );

end entity CarryLookAheadAdder;

architecture struct of CarryLookAheadAdder is
  --The Carry LookAhead performs reduction of kGroupLength to 1 using the Carry
  --Look Ahead Logic Block until it gets to 1 single Carry Look Ahead Logic
  --Block at the end.
  constant kClaLevels : natural := integer(Ceil(Log(real(kDataLength)) / Log(real(kGroupLength))));

  --Due to the reduction, each level will have the as many Carry Look Ahead
  --Logic components as the previous divided by the Group Length. We
  --are pre-calculating these in a convinient constant.
  type NaturalArray_t is array(natural range <>) of natural;

  function GetClasPerLevel (Levels, GroupLength : natural) return NaturalArray_t is
    variable Result      : NaturalArray_t(1 to kClaLevels);
    variable LevelLength : natural;
  begin
    --Get Level 0 length
    LevelLength := GroupLength**Levels;
    for i in Result'range loop
      --Calculate the level Length based on the previous length
      LevelLength := LevelLength / GroupLength;
      Result(i) := LevelLength;
    end loop;
    return Result;
  end function  GetClasPerLevel;

  constant kClaPerLevel : NaturalArray_t := GetClasPerLevel(kClaLevels, kGroupLength);

  --Ideally the Data Length should be an integer power of the Group Length,for
  --example with a Group of Length of 4, the ideal sizes for the Carry Look
  --Ahead is 4, 16, 64 ..., When there is a Data Length in between two Ideal
  --Lengths, we will pad the Inputs with zeros to the left This is ok since the
  --Carry Output doesn't need to propagate all the way to the MSB for this
  --particular algorithm. Also we are expecting the Compilation Tools to
  --optimize anything that it doesn't need.
  signal aAcla, aBcla, aScla : std_logic_vector((kGroupLength**kClaLevels) - 1 downto 0);

  --Each level will produce generate and propagate signals, which are a
  --reduction of the previous level, it would be nice to have a array of vectors
  --where the vectors are the exact size of each level's output. However the
  --language doesn't allow to have arrays of undefined vectors (at least on VHDL
  --2003), so we have to settle with an array of vectors of maximum size and we
  --will assume that the synthesis tools will optimize out the unused bits.
  type LvlOutMatrix_t is array (natural range <>) of std_logic_vector(aAcla'range);
  signal aGroupGen, aGroupProp, aCarries : LvlOutMatrix_t(0 to kClaLevels);

begin

  --Create the extended vectors
  aAcla <= std_logic_vector(resize(unsigned(aA), aAcla'length));
  aBcla <= std_logic_vector(resize(unsigned(aB), aBcla'length));
  aS    <= aScla(aS'range);

  --the first carry of the last carry will be our Input Carry,it will then
  --propagate all the way up.
  aCarries(aCarries'high)(0) <= aCin;

  --The Level 0 is the Full Adders for each bit.
  FullAddersGen: for i in aScla'range generate
    --vhook_e FullAdder
    --vhook_a aA    aAcla(i)
    --vhook_a aB    aBcla(i)
    --vhook_a aCin  aCarries(0)(i)
    --vhook_a aS    aScla(i)
    --vhook_a aCout open
    --vhook_a aGen  aGroupGen(0)(i)
    --vhook_a aProp aGroupProp(0)(i)
    FullAdderx: entity work.FullAdder (struct)
      port map (
        aA    => aAcla(i),          --in  std_logic
        aB    => aBcla(i),          --in  std_logic
        aCin  => aCarries(0)(i),    --in  std_logic
        aS    => aScla(i),          --out std_logic
        aCout => open,              --out std_logic
        aGen  => aGroupGen(0)(i),   --out std_logic
        aProp => aGroupProp(0)(i)); --out std_logic

  end generate FullAddersGen;

  --Now the levels
  LevelsGen: for level in 1 to kClaLevels generate
    --Each level is made of the previous components divided by the Group Length.
    --These numbers were pre calculated as a constant
    ClaGen: for i in 0 to kClaPerLevel(level) - 1 generate
      signal aGen, aProp, aC : std_logic_vector(kGroupLength - 1 downto 0);
    begin
      aGen  <= aGroupGen(level - 1)(((i + 1)*kGroupLength - 1) downto (i*kGroupLength));
      aProp <= aGroupProp(level - 1)(((i + 1)*kGroupLength - 1) downto (i*kGroupLength));
      aCarries(level - 1)(((i + 1)*kGroupLength - 1) downto (i*kGroupLength)) <= aC;
      --vhook_e CarryLookAheadLogic
      --vhook_a aCin       aCarries(level)(i)
      --vhook_a aGroupGen  aGroupGen(level)(i)
      --vhook_a aGroupProp aGroupProp(level)(i)
      CarryLookAheadLogicx: entity work.CarryLookAheadLogic (rtl)
        generic map (kGroupLength => kGroupLength)  --natural:=4
        port map (
          aGen       => aGen,                  --in  std_logic_vector(kGroupLength-1:0)
          aProp      => aProp,                 --in  std_logic_vector(kGroupLength-1:0)
          aCin       => aCarries(level)(i),    --in  std_logic
          aC         => aC,                    --out std_logic_vector(kGroupLength-1:0)
          aGroupGen  => aGroupGen(level)(i),   --out std_logic
          aGroupProp => aGroupProp(level)(i)); --out std_logic

    end generate ClaGen;
  end generate LevelsGen;

  --As long as the Number of bits is a power of the Group Length, the Carry Out
  --will depend on the last Carry Look Ahead Logic Group Generate and Propagate
  --signals. Where the Carry Out will be '1' if the gropu is generating it or
  --if there is a carry at the input and the group is propagating it
  BitsPowerOfGroupGen: if kDataLength = aScla'length generate
    aCout <= aGroupGen(aGroupGen'high)(aGroupGen'low) or
            (aGroupProp(aGroupProp'high)(aGroupProp'low) and aCin);
  end generate BitsPowerOfGroupGen;

  --If the Number of bits isn't a power of the Group Length, then we have to
  --get the Output Carry from the Carries of the Level 0, where the Output Carry
  --will be the Input Carry of the first Full Adder that won't make it to the
  --Result. This is definetely more inneficient, but it's easier to grab it
  --rather than calculating a new Group Generate and Propagate.
  BitsNotPowerOfGroupGen: if kDataLength < aScla'length generate
    aCout <= aCarries(0)(kDataLength);
  end generate BitsNotPowerOfGroupGen;

end architecture struct;
