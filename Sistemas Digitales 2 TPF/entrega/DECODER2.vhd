library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

ENTITY DECODER2 IS --74_LS_42 MODIFICADO 
PORT (
	ENABLE_DEC: IN STD_LOGIC;
	IND: IN STD_LOGIC_VECTOR(7 downto 0);
	OP1: OUT STD_LOGIC_VECTOR(2 downto 0);
	OP2: OUT STD_LOGIC_VECTOR (2 downto 0)
);
END DECODER2;
ARCHITECTURE ESTRUCTURAL OF DECODER2 IS
BEGIN
PROCESS (ENABLE_DEC, IND)
VARIABLE IND1: STD_LOGIC_VECTOR(2 DOWNTO 0);
VARIABLE IND2: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
    IND1 :=IND (7 DOWNTO 5);
    IND2 :=IND (4 DOWNTO 2); 
	OP1 <= IND1;
	OP2 <= IND2;
END PROCESS;
END ESTRUCTURAL;