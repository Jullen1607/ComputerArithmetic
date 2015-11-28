library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity booths is
GENERIC(k : POSITIVE := 7); --input number word length less one
Port ( a,b : in STD_LOGIC_VECTOR (k downto 0);
mul : out STD_LOGIC_VECTOR (2*k+1 downto 0));
end booths;
architecture Behavioral of booths is
begin
process(a,b)
variable m: std_logic_vector (2*k+1 downto 0);
variable s: std_logic;
begin
m:="00000000"&b;
s:='0';
for i in 0 to k loop
if(m(0)='0' and s='1') then
m(k downto k-3):= m(k downto k-3)+a;
s:=m(0);
m(k-1 downto 0):=m(k downto 1);
elsif(m(0)='1' and s='0') then
m(k downto k-3):= m(k downto k-3)-a;
s:=m(0);
m(k-1 downto 0):=m(k downto 1);
else
s:=m(0);
m(k-1 downto 0):=m(k downto 1);
end if;
end loop;
mul<=m;
end process;
end Behavioral;
