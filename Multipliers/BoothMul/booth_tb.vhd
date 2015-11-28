library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Testbench_di_Booth is
end Testbench_di_Booth;
architecture behavior of Testbench_di_Booth is
component booths
GENERIC(k : POSITIVE := 7); --input number word length less one
Port( a,b : in STD_LOGIC_VECTOR (k downto 0);
mul : out STD_LOGIC_VECTOR (2*k+1 downto 0));
end component;
--Inputs
signal A : STD_LOGIC_VECTOR (7 downto 0):= "00000011";
signal B : STD_LOGIC_VECTOR (7 downto 0):= "00000100";
--Outputs
signal MUL : STD_LOGIC_VECTOR(15 downto 0);
begin
--Instantiate the UnitUnder Test (UUT)
uut: booths PORT MAP
(a => A,
b => B,
mul => MUL);
--Stimulus process
stim_proc: process
begin
--insert stimulus here
A<="00000011"; B<="00000100"; wait for 500 fs;
A<="00000110"; B<="00000111"; wait for 500 fs;
A<="00001011"; B<="00000100"; wait for 500 fs;
wait;
end process;
end;