library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

entity Multiplexor10 is --combinatorio, basado en 74F151
Port (
	Sel : in std_logic_vector (3 downto 0); --SELECTOR
	IN1 : in std_logic_vector (7 downto 0);--INPUT
	IN2 : in std_logic_vector (7 downto 0);--INPUT
	IN3 : in std_logic_vector (7 downto 0);--INPUT
	IN4 : in std_logic_vector (7 downto 0);--INPUT
	IN5 : in std_logic_vector (7 downto 0);--INPUT
	IN6 : in std_logic_vector (7 downto 0);--INPUT
	IN7 : in std_logic_vector (7 downto 0);--INPUT
	IN8 : in std_logic_vector (7 downto 0);--INPUT
	IN9 : in std_logic_vector (7 downto 0);--INPUT
	IN10 : in std_logic_vector (7 downto 0);--INPUT 
	Z : out std_logic_vector (7 downto 0)--OUTPUT
);
end Multiplexor10;

architecture estructural of Multiplexor10 is
begin
    process (Sel)
	begin
		if (Sel = "0000") then
			Z <= IN1;
		end if;
		if (Sel = "0001") then
			Z <= IN2;
		end if;
		if (Sel = "0010") then
			Z <= IN3;
		end if;
		if (Sel = "0011") then
			Z <= IN4;
		end if;
		if (Sel = "0100") then
			Z <= IN5;
		end if;
		if (Sel = "0101") then
			Z <= IN6;
		end if;
		if (Sel = "0110") then
			Z <= IN7;
		end if;
		if (Sel = "0111") then
			Z <= IN8;
		end if;
		if (Sel = "1000") then
			Z <= IN9;
		end if;
		if (Sel = "1001") then
			Z <= IN10;
		end if;
	end process;
end estructural;