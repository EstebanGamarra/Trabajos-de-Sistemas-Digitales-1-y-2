library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

entity MultiplexorS2 is --combinatorio, basado en 74F151
Port (
	Sel : in std_logic_vector (1 downto 0); --SELECTOR
	IN1 : in std_logic_vector (3 downto 0);--INPUT
	IN2 : in std_logic_vector (3 downto 0);--INPUT
	IN3 : in std_logic_vector (3 downto 0);--INPUT
	IN4 : in std_logic_vector (3 downto 0);--INPUT
	Z : out std_logic_vector (3 downto 0)--OUTPUT
);
end MultiplexorS2;

architecture estructural of MultiplexorS2 is
begin
    process (Sel)
	begin
		if (Sel = "00") then
			Z <= IN1;
		end if;
		if (Sel = "01") then
			Z <= IN2;
		end if;
		if (Sel = "10") then
			Z <= IN3;
		end if;
		if (Sel = "11") then
			Z <= IN4;
		end if;
	end process;
end estructural;