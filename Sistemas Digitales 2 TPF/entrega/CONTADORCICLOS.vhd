LIBRARY ieee;
USE 	ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CONTADORCICLOS IS --74_LS_669
PORT
(
	LDCount: IN STD_LOGIC_VECTOR (7 downto 0); 
	LDEn: IN STD_LOGIC;
	clk	: IN STD_LOGIC;	--Reloj
	INcount	: IN STD_LOGIC;	--enable count
	Rcount: IN STD_LOGIC; 	--Reset count
	Q	: BUFFER  INTEGER;
	QBIT: OUT STD_LOGIC_VECTOR (7 downto 0) 
);
END CONTADORCICLOS;

ARCHITECTURE ESTRUCTURAL OF CONTADORCICLOS IS
    
BEGIN
	PROCESS(clk)
	BEGIN
		IF(clk'EVENT AND clk='1')THEN
			IF((INcount = '1') AND (Rcount = '0'))THEN --incremento natural
				Q <= Q + 1;
			END IF;
			IF (Rcount = '1') THEN --reseteo del contador
				Q <= 0;
			END IF;
			IF ((LDEn='1') AND (Rcount = '0')) THEN --Carga del contador
				Q <= to_integer(unsigned(LDCount));
			END IF;
			QBIT<= std_logic_vector(to_unsigned(Q,8));
		END IF;
	END PROCESS;
END ESTRUCTURAL;
