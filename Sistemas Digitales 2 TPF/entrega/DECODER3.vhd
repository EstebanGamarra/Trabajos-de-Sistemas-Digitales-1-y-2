library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

ENTITY DECODER3 IS --74_LS_42 MODIFICADO 
PORT (
	ENABLE_DEC: IN STD_LOGIC;
	IND: IN STD_LOGIC_VECTOR(7 downto 0);
	E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, EINT: OUT STD_LOGIC
);
END DECODER3;
ARCHITECTURE ESTRUCTURAL OF DECODER3 IS
BEGIN
PROCESS (ENABLE_DEC, IND)
BEGIN
	IF IND = "00000000" THEN
		E0 <= '1';
	END IF;
	IF IND = "00000001" THEN
		E1 <= '1';
	END IF;
	IF IND = "00000010" THEN
		E2 <= '1';
	END IF;
	IF IND = "00000011" THEN
		E3 <= '1';
	END IF;
	IF IND = "00000100" THEN
		E4 <= '1';
	END IF;
	IF IND = "00000101" THEN
		E5 <= '1';
	END IF;
	IF IND = "00000110" THEN
		E6 <= '1';
	END IF;
	IF IND = "00000111" THEN
		E7 <= '1';
	END IF;
	IF IND = "00001000" THEN
		E8 <= '1';
	END IF;
	IF IND = "00001001" THEN
		E9 <= '1';
	END IF;
	IF IND = "00001010" THEN
		E10 <= '1';
	END IF;
	IF IND = "00001011" THEN
		E11 <= '1';
	END IF;
	IF IND = "00001100" THEN --12 BINARIO
		EINT <= '1';
	END IF;
	IF IND = "00001101" THEN
		E12 <= '1';
	END IF;
	IF IND = "00001110" THEN
		E13 <= '1';
	END IF;
	IF IND = "00001111" THEN
		E14 <= '1';
	END IF;
	IF IND = "00010000" THEN
		E15 <= '1';
	END IF;
	IF IND = "00010001" THEN
		E16 <= '1';
	END IF;
	IF IND = "00010010" THEN
		E17 <= '1';
	END IF;
END PROCESS;
END ESTRUCTURAL;