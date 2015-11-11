-------------------------------------------------------------------------------
--
-- File: PkgAddersUtilities.vhd
-- Author: Julian Ferrer
-- Original Project: Computer Arithmetic Components
-- Date: 11 November 2015
--
-------------------------------------------------------------------------------
-- (c) 2015 Copyright National Instruments Corporation
-- All Rights Reserved
-- National Instruments Internal Information
-------------------------------------------------------------------------------
--
-- Purpose:
--   Functions and constants used for the Adders
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package PkgAddersUtilities is
  -------------------------------------
  --Function Declaration
  -------------------------------------
  function AndVector(arg : std_logic_vector) return std_logic;

  function GenerateLogic (Gen, Prop : std_logic_vector) return std_logic;
end package PkgAddersUtilities;

package body PkgAddersUtilities is

  -------------------------------------
  --And Vector
  -------------------------------------
  --The And Vector function calculates the and between all of the elements
  --of a std_logic_vector
  function AndVector(arg : std_logic_vector) return std_logic is
    variable Result : std_logic;
  begin
    Result := '1';
    for i in arg'range loop
      Result := Result and arg(i);
    end loop;
    return Result;
  end function AndVector;

  -------------------------------------
  --Generate Logic
  -------------------------------------
  --The Generate Logic function obtains the Group Generate based on an array of
  --Generate and Propagate Signals. The Generate Logic follows the next scheme:
  --Gen = Gn-1 or Gn-2Pn-1 or Gn-3Pn-1Pn-2 ...
  function GenerateLogic (Gen, Prop : std_logic_vector) return std_logic is
    variable Result   : std_logic;
    variable PropTerm : std_logic;
    variable PropDesc : std_logic_vector(Prop'high downto Prop'low);
  begin
    -- The Prop variable should descending, let's ensure that
    PropDesc := Prop;
    --if Prop'ascending then
    --All of the terms of the OR contain the Propagate signals up to the MSB,
    --this means that the MSB doesn't need any Propagate signal. That's why
    --the Result will be at the very least the  Generate of the MSB.

    Result := Gen(Gen'high);

    --This last assignment issues a problem when the size of the vector is 1,
    --since there would be no Propagate terms to be used. This shouldn't happen
    --but we will still wrap the Propagate terms in a if statement to be safe.
    if Gen'length > 1 then
      for i in Gen'high - 1 downto Gen'low loop
        --Each term starts with the Generate and it Ands it with all the
        --Propagates above it.
        PropTerm := AndVector(PropDesc(Gen'high downto (i + 1)));
        PropTerm := Gen(i) and PropTerm;
        --The we accumalte it with the previously calculated terms.
        Result := Result or PropTerm;
      end loop;
    end if;
    return Result;
  end function GenerateLogic;

end PkgAddersUtilities;
