library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

entity MultiplexorS1 is --combinatorio, basado en 74F151
Port (
	Sel : in std_logic; --SELECTOR
	IN1 : in std_logic_vector (3 downto 0);--INPUT
	IN2 : in std_logic_vector (3 downto 0);--INPUT
	Z : out std_logic_vector (3 downto 0)--OUTPUT
);
end MultiplexorS1;

architecture estructural of MultiplexorS1 is
begin
    process (Sel)
	begin
		if (Sel = '0') then
			Z <= IN1;
		end if;
		if (Sel = '1') then
			Z <= IN2;
		end if;
	end process;
end estructural;