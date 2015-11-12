-------------------------------------------------------------------------------
--
-- File: AllAdders.vhd
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
--   This is a wrapper file for all the components in this project. It contains:
--   --Ripple Carry Adder
--   --
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity AllAdders is
  generic(
    kDataLength  : natural := 16;
    kGroupLength : integer_vector := (0 => 4));
  port(
    Clk        : in  std_logic;
    aReset     : in  std_logic;

    --Inputs to the Adders
    cA         : in  std_logic_vector(kDataLength - 1 downto 0);
    cB         : in  std_logic_vector(kDataLength - 1 downto 0);

    --Outputs of the Ripple Carry Adder
    cResultRca : out std_logic_vector(kDataLength - 1 downto 0);
    cCoutRca   : out std_logic;

    --Outputs of the Naive Adder
    cResultNaive : out std_logic_vector(kDataLength - 1 downto 0);
    cCoutNaive   : out std_logic;

    --Outputs of the Naive Adder
    cResultCla : out std_logic_vector(kDataLength - 1 downto 0);
    cCoutCLa   : out std_logic
  );

end entity AllAdders;

architecture struct of AllAdders is

  --vhook_sigstart
  signal aCoutCla: std_logic;
  signal aCoutNaive: std_logic;
  signal aCoutRca: std_logic;
  signal aScla: std_logic_vector(kDataLength-1 downto 0);
  signal aSnaive: std_logic_vector(kDataLength-1 downto 0);
  signal aSrca: std_logic_vector(kDataLength-1 downto 0);
  signal cAin: std_logic_vector(kDataLength-1 downto 0);
  signal cBin: std_logic_vector(kDataLength-1 downto 0);
  --vhook_sigend

begin

  --Let's Latch the Inputs and the Outputs so we can bound each adder easier
  Registers: process (Clk, aReset) is
  begin
    if aReset = '1' then
      --Reset all of the Registers
      --Input
      cAin       <= (others => '0');
      cBin       <= (others => '0');
      --RippleCarryAdder
      cResultRca <= (others => '0');
      cCoutRca   <= '0';
      --Naive Adder
      cResultNaive <= (others => '0');
      cCoutNaive   <= '0';
      --Carry Look Ahead Adder
      cResultCla <= (others => '0');
      cCoutCla   <= '0';
    elsif rising_edge(Clk) then
      --We want the Inputs to be bounded between two know FF so we are adding
      --those FFs here
      cAin       <= cB;
      cBin       <= cA;

      --Latch the result of the Ripple Carry Adder
      cResultRca <= aSrca;
      cCoutRca   <= aCoutRca;

      --Latch the result of the Naive Adder
      cResultNaive <= aSnaive;
      cCoutNaive   <= aCoutNaive;

      --Latch the result of the Naive Adder
      cResultCla <= aScla;
      cCoutCla   <= aCoutCla;
    end if;
  end process Registers;

  --vhook_e RippleCarryAdder
  --vhook_a aCin '0'
  --vhook_a aCout aCoutRca
  --vhook_a aA cAin
  --vhook_a aB cBin
  --vhook_a aS aSrca
  --vhook_a aGroupProp open
  --vhook_a aGroupGen open
  RippleCarryAdderx: entity work.RippleCarryAdder (struct)
    generic map (kDataLength => kDataLength)  --natural:=16
    port map (
      aA         => cAin,      --in  std_logic_vector(kDataLength-1:0)
      aB         => cBin,      --in  std_logic_vector(kDataLength-1:0)
      aCin       => '0',       --in  std_logic
      aS         => aSrca,     --out std_logic_vector(kDataLength-1:0)
      aGroupGen  => open,      --out std_logic
      aGroupProp => open,      --out std_logic
      aCout      => aCoutRca); --out std_logic

  --vhook_e NaiveAdder
  --vhook_a aCin '0'
  --vhook_a aCout aCoutNaive
  --vhook_a aA cAin
  --vhook_a aB cBin
  --vhook_a aS aSnaive
  NaiveAdderx: entity work.NaiveAdder (rtl)
    generic map (kDataLength => kDataLength)  --natural:=16
    port map (
      aA    => cAin,        --in  std_logic_vector(kDataLength-1:0)
      aB    => cBin,        --in  std_logic_vector(kDataLength-1:0)
      aCin  => '0',         --in  std_logic
      aS    => aSnaive,     --out std_logic_vector(kDataLength-1:0)
      aCout => aCoutNaive); --out std_logic

  GroupDependentGen: for i in kGroupLength'range generate
    --vhook_e CarryLookAheadAdder
    --vhook_G kGroupLength kGroupLength(i)
    --vhook_a aCin '0'
    --vhook_a aCout aCoutCla
    --vhook_a aA cAin
    --vhook_a aB cBin
    --vhook_a aS aScla
    CarryLookAheadAdderx: entity work.CarryLookAheadAdder (struct)
      generic map (
        kDataLength  => kDataLength,      --natural:=4
        kGroupLength => kGroupLength(i))  --natural:=2
      port map (
        aA    => cAin,      --in  std_logic_vector(kDataLength-1:0)
        aB    => cBin,      --in  std_logic_vector(kDataLength-1:0)
        aCin  => '0',       --in  std_logic
        aS    => aScla,     --out std_logic_vector(kDataLength-1:0)
        aCout => aCoutCla); --out std_logic
  end generate GroupDependentGen;

end architecture struct;
