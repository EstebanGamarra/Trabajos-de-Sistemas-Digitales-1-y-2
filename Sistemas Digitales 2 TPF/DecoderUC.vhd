library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY DECODER1 IS --74_LS_42 MODIFICADO 
PORT (
	ENABLE_DEC: IN STD_LOGIC;
	IND: IN STD_LOGIC_VECTOR(7 downto 0);
	ADD, ADDC,CMP,INC,NOTT,ANDD,MOVE,BZ,RETI,PUSH,POP,ST,LD,CLR,SHR,SHL,SUB,DEC,JMP: OUT STD_LOGIC;
	MODE: OUT STD_LOGIC;
	ADRS: OUT STD_LOGIC;
	OP1: OUT STD_LOGIC_VECTOR(2 downto 0);
	OP2: OUT STD_LOGIC_VECTOR (2 downto 0)
);
END DECODER;
ARCHITECTURE ESTRUCTURAL OF DECODER IS
BEGIN
PROCESS (ENABLE_DEC)
	IF IND(7 downto 3) = "00000" THEN
	ADD <= '1';
	END IF;
	IF IND(7 downto 3) = "00001" THEN
		ADDC <= '1';
	END IF;
	IF IND(7 downto 3) = "00010" THEN
		CMP <= '1';
	END IF;
	IF IND(7 downto 3) = "00011" THEN
		INC <= '1';
	END IF;
	IF IND(7 downto 3) = "00100" THEN
		NOTT <= '1';
	END IF;
	IF IND(7 downto 3) = "00101" THEN
		ANDD <= '1';
	END IF;
	IF IND(7 downto 3) = "00110" THEN
		MOVE <= '1';
	END IF;
	IF IND(7 downto 3) = "00111" THEN
		BZ <= '1';
	END IF;
	IF IND(7 downto 3) = "01000" THEN
		RETI <= '1';
	END IF;
	IF IND(7 downto 3) = "01001" THEN
		PUSH <= '1';
	END IF;
	IF IND(7 downto 3) = "01010" THEN
		POP <= '1';
	END IF;
	IF IND(7 downto 3) = "01011" THEN
		ST <= '1';
	END IF;
	IF IND(7 downto 3) = "01100" THEN
		LD <= '1';
	END IF;
	IF IND(7 downto 3) = "01101" THEN
		CLR <= '1';
	END IF;
	IF IND(7 downto 3) = "01110" THEN
		SHR <= '1';
	END IF;
	IF IND(7 downto 3) = "01111" THEN
		SHL <= '1';
	END IF;
	IF IND(7 downto 3) = "10000" THEN
		SUB <= '1';
	END IF;
	IF IND(7 downto 3) = "10001" THEN
		DEC <= '1';
	END IF;
	IF IND(7 downto 3) = "10001" THEN
		JMP <= '1';
	END IF;
	IF IND(2) = '0' THEN
	MODE = '0'
	END IF;
	IF IND(2) ='1' THEN
		MODE = '1'
	END IF;
END PROCESS;
END ESTRUCTURAL;
