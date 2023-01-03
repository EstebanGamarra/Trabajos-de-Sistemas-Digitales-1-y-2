LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Registro IS -- de 5 bits
PORT
(
	clk : IN STD_LOGIC; 
	lod : IN STD_LOGIC; 
	D : IN STD_LOGIC_VECTOR(4 DOWNTO 0);  
	Q : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)  
);

END Registro;
ARCHITECTURE estructural OF Registro IS
BEGIN
	PROCESS(clk)
	BEGIN
		IF(clk'EVENT AND clk='1')THEN
			IF (lod = '1')THEN
				Q <= D;
			END IF;
		END IF;
	END PROCESS;
END estructural;