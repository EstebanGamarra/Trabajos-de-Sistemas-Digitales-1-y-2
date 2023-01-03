library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity MemoriaBCD is --basado en MCM6926A pero con muchas menos señales, simplemente dos señales de control read y write, y la dirección de la memoria. 100 bloques de 1 byte, bidimensional, en vez de 128 mil bloques, tridimensional.
Port (
	clk : in std_logic; 
	A : in std_logic_vector (7 downto 0); --Adress Input
	W : in std_logic; --Write Enable
	O : in std_logic; --Output Enable
	IBUS: in std_logic_vector (7 downto 0); --BUS input
	OBUS: out std_logic_vector (7 downto 0)
);
end MemoriaBCD;
architecture estructural of MemoriaBCD is
	TYPE MEMORIA IS ARRAY (0 TO 100) OF STD_LOGIC_VECTOR (7 DOWNTO 0); --UNSIGNED SE USA EN VEZ DE STD_LOGIC_VECTOR PARA OPERACIONES OJO
	SIGNAL MEMORY: MEMORIA :=
	(
	"00010000", --0 Pa (10)
	"00000010", --1 Na (2)
	"00010100", --2 Pb (14)
	"00000011", --3 Nb (3)
	"00011000", --4 Pr (18)
	"11010111", --5
	"11010111", --6
	"11010111", --7
	"11010111", --8
	"11010111", --9
	"00001000", --10 A= 28
	"00000010", --11 
	"00000100", --12 
	"11010111", --13
	"00000011", --14 B= 133
	"00000011", --15 
	"00000001", --16 
	"11010111", --17 
	"11010111", --18 Pr (se guarda en complemento en la memoria)
	"11010111", --19
	"11010111", --20
	"11010111", --21
	"11010111", --22
	"11010111", --23
	"11010111", --24
	"11010111", --25
	others => "10100010" --cualquier cosa
	);
    begin 
	process (clk)
	   variable var: integer;
	begin
	IF (clk'event and clk='1') THEN
	    var := to_integer(unsigned(A));
		if (W='0' AND O='1') then
			OBUS <= MEMORY(var)(7 downto 0);
		end if;
		if (W='1' AND O='0') then
			MEMORY (var)(7 downto 0) <= IBUS;
		end if;
	END IF;
	end process;
end estructural;