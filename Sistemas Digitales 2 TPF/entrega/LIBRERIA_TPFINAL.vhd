LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY work;
USE work.all;

PACKAGE LIBRERIA_TPFINAL IS
	COMPONENT DECODER IS
	PORT
	(
		ENABLE_DEC: IN STD_LOGIC;
		IND: IN STD_LOGIC_VECTOR(7 downto 0);
		ADD, ADDC,CMP,INC,NOTT,MOVE,BZ,RETI: OUT STD_LOGIC;
		ST,LD,CLR,SHRR,SHLL,SUB,DEC,JMP: OUT STD_LOGIC; 
		MODE: OUT STD_LOGIC
	);
	END COMPONENT;
	COMPONENT CONTADORCICLOS IS
	PORT
	(
		LDCount: IN STD_LOGIC_VECTOR (7 downto 0); 
		LDEn: IN STD_LOGIC;
		clk	: IN STD_LOGIC;	--Reloj
		INcount	: IN STD_LOGIC;	--enable count
		Rcount: IN STD_LOGIC; 	--Reset count
		Q	: BUFFER  INTEGER;
		QBIT: OUT STD_LOGIC_VECTOR (7 downto 0) --Corregir la salida correcta en la RestaBCD
	);
	END COMPONENT;
	COMPONENT REGISTROINS IS
	PORT
	(
		clk : IN STD_LOGIC; 
		lod : IN STD_LOGIC; 
		D : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  
		Q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  
	);
	END COMPONENT;
	COMPONENT DECODER2 IS
	PORT (
		ENABLE_DEC: IN STD_LOGIC;
		IND: IN STD_LOGIC_VECTOR(7 downto 0);
		OP1: OUT STD_LOGIC_VECTOR(2 downto 0);
		OP2: OUT STD_LOGIC_VECTOR (2 downto 0)
	);
	END COMPONENT;
	COMPONENT DECODER3 IS
	PORT(
		ENABLE_DEC: IN STD_LOGIC;
		IND: IN STD_LOGIC_VECTOR(7 downto 0);
		E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, EINT: OUT STD_LOGIC
	);
	END COMPONENT;
END LIBRERIA_TPFINAL;