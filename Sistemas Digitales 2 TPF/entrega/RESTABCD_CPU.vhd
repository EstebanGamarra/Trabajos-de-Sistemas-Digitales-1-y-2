LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY WORK;
USE WORK.LIBRERIA_TPFINAL.ALL;

ENTITY RESTABCD_CPU IS
PORT(
	CLK: IN STD_LOGIC; --CLOCK
	START: IN STD_LOGIC; --START
	INTS: IN STD_lOGIC; --INTERRUPT
	ENDD: BUFFER STD_LOGIC --END
);
END RESTABCD_CPU;

ARCHITECTURE ESTRUCTURAL OF RESTABCD_CPU IS
	--SE�ALES GLOBALES
	SIGNAL BUS_TS: STD_LOGIC_VECTOR(7 DOWNTO 0):= "00000000";
	--SE�ALES DE LA UNIDAD DE CONTROL
	SIGNAL E0,E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16, E17, EINT: STD_LOGIC := '0';
	SIGNAL ADD, ADDC, CMP, INC, NOTT, MOVE, BZ, ST, LD, CLR, SUB, DEC, JMP, RETI: STD_LOGIC :='0';
	SIGNAL M: STD_LOGIC;
	SIGNAL ADRS: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL OP1, OP2: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL LD_RI0, LD_RI1: STD_LOGIC;
	SIGNAL DI0, DI1, DI2, QI0, QI1: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL OP1_LD, OP1_CLR, OP1_OE: STD_LOGIC; ---ESTE USAMOS PARA R1 EN NUESTRA TABLA DE SE�ALES DE CONTROL, R1=DESTINO=OP1 =/= REGISTRO EST�TICO 1
	SIGNAL OP2_LD, OP2_OE: STD_LOGIC; --ESTE USAMOS PARA R2 EN NUESTRA TABLA DE SE�ALES DE CONTROL, R2=OPERANDO=OP2 =/= REGISTRO EST�TICO 2
	SIGNAL OUT_COUNT_CICLOS, LD_COUNT_CICLOS: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL LD_EN_CICLOS: STD_LOGIC;
	--SE�ALES DE LA RUTA DE DATOS
	--R1
	SIGNAL R1_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL R1_OP1: STD_LOGIC;
	SIGNAL R1_CLR: STD_LOGIC;
	SIGNAL R1_OUT_ENABLE: STD_LOGIC; 
	SIGNAL R1_LOAD_ENABLE: STD_LOGIC; 
	--R2
	SIGNAL R2_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL R2_OP1: STD_LOGIC;
	SIGNAL R2_CLR: STD_LOGIC;
	SIGNAL R2_OUT_ENABLE: STD_LOGIC;
	SIGNAL R2_LOAD_ENABLE: STD_LOGIC; 
	--R3
	SIGNAL R3_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL R3_OP1: STD_LOGIC;
	SIGNAL R3_CLR: STD_LOGIC;
	SIGNAL R3_OUT_ENABLE: STD_LOGIC;
	SIGNAL R3_LOAD_ENABLE: STD_LOGIC; 
	--R4
	SIGNAL R4_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL R4_OP1: STD_LOGIC;
	SIGNAL R4_CLR: STD_LOGIC;
	SIGNAL R4_OUT_ENABLE: STD_LOGIC;
	SIGNAL R4_LOAD_ENABLE: STD_LOGIC; 
	--RAUX
	SIGNAL RAUX_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RAUX_OP1: STD_LOGIC;
	SIGNAL RAUX_CLR: STD_LOGIC;
	SIGNAL RAUX_OUT_ENABLE: STD_LOGIC;
	SIGNAL RAUX_LOAD_ENABLE: STD_LOGIC; 
	--RAUX2
	SIGNAL RAUX2_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RAUX2_OP1: STD_LOGIC;
	SIGNAL RAUX2_CLR: STD_LOGIC;
	SIGNAL RAUX2_OUT_ENABLE: STD_LOGIC;
	SIGNAL RAUX2_LOAD_ENABLE: STD_LOGIC; 
	--RA
	SIGNAL RA_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RA_LOAD_ENABLE: STD_LOGIC; 
	SIGNAL RA_OUT_ENABLE: STD_LOGIC;
	SIGNAL RA_OUT: STD_LOGIC_VECTOR (7 DOWNTO 0);
	--RB
	SIGNAL RB_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RB_OP1: STD_LOGIC;
	SIGNAL RB_CLR: STD_LOGIC;
	SIGNAL RB_OUT_ENABLE: STD_LOGIC;
	SIGNAL RB_LOAD_ENABLE: STD_LOGIC; 
	--RC
	SIGNAL RC_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RC_OP1: STD_LOGIC;
	SIGNAL RC_CLR: STD_LOGIC;
	SIGNAL RC_OUT_ENABLE: STD_LOGIC;
	SIGNAL RC_LOAD_ENABLE: STD_LOGIC; 
	--TEMP
	SIGNAL TEMP_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL TEMP_OUT_ENABLE: STD_LOGIC;
	SIGNAL TEMP_LOAD_ENABLE: STD_LOGIC;
	SIGNAL TEMP_CLR: STD_LOGIC;
	--BANDERAS
	SIGNAL BANDERA_DATA: STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL Z,NZ,C,V: STD_LOGIC;
	SIGNAL BANDERA_LOAD:STD_LOGIC;
	SIGNAL BANDERA_OUT: STD_LOGIC;
	-- Z,NZ,C,V -> 0000 EN ESE ORDEN
	--ALU
	SIGNAL FUN: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL ALU_OUT: STD_LOGIC_VECTOR(7 DOWNTO 0);
	--PC
	SIGNAL PC_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL OE_PC: STD_LOGIC; --OUTPC
	SIGNAL INC_PC: STD_LOGIC; --PCINC
	SIGNAL LD_PC: STD_LOGIC; --LDPC
	SIGNAL CLR_PC: STD_LOGIC; --CLRPC
	--AR
	SIGNAL LD_AR: STD_LOGIC;
	SIGNAL CLR_AR: STD_LOGIC;
	SIGNAL AR_DATA: STD_LOGIC_VECTOR(7 DOWNTO 0);
	--SP
	SIGNAL INC_SP: STD_LOGIC;
	SIGNAL DEC_SP: STD_LOGIC;
	SIGNAL SP_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	--MEMORIA
	SIGNAL MEM_OE_SP: STD_LOGIC;
	SIGNAL MEM_OE_AR: STD_LOGIC;
	SIGNAL MEM_WE_SP: STD_LOGIC;
	SIGNAL MEM_WE_AR: STD_LOGIC;
	TYPE VECTOR_ARRAY IS ARRAY (0 to 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL MEMORIA: VECTOR_ARRAY :=(
		--- ADDRESSES:
	---Pa = 232
	---Na = 233
	---Pb = 234
	---Nb = 235
	---Pr = 236
	---Nr = 237
	---Ph = 238
		"01100100", --0 LD M=1
		"00000000", --1 R1
		"11101001", --2 Na
		"01100100", --3 LD M=1 
		"00100000", --4 R2
		"11101011", --5 Nb
		"01100100", --6 LD M=1
		"01000000", --7 R3
		"11101000", --8 Pa
		"01100100", --9 LD M=1
		"01100000", --10 R4
		"11101010", --11 Pb
		"00010000", --12 CMP M=0
		"00000100", --13 R1,R2
		"00111100", --14 BRANCH Z (SI ES UNO SALTO) M=1
		"00000000", --15 -
		"01000100", --16 -68 --DESTINO 1
		"00111100", --17 BRANCH Z (SI ES UNO SALTO) M=1
		"00000000", --18 - 
		"00101100", --19 -44
		"01011100", --20 ST M=1 -- SI V=0
		"00000100", --21 R2
		"11101101", --22 Nr
		"10000000", --23 SUB M=0
		"00000100", --24 R1,R2
		"00000000", --25 ADD M=0
		"00001100", --26 R1,R3
		"00110100", --27 MOVE M=1
		"10000000", --28 RAUX
		"00000000", --29 '0'
		"00000000", --30 ADD M=0
		"00010000", --31 R1,RAUX
		"01101100", --32 CLR M=1
		"00000000", --33 R1
		"00010000", --34 CMP M=0
		"00110000", --35 R2,RAUX
		"00111100", --36 BRANCH Z M=1
		"00000000", --37 -
		"01000111", --38 71 -- DESTINO 2
		"00011000", --39 INC M=0
		"10000000", --40 RAUX
		"10010100", --41 JMP 
		"11100100", --42 -
		"00011110", --43 30
		"01011100", --44 ST M=1 --DESTINO BRANCH V SI ES 1
		"00000000", --45 R1
		"11101101", --46 Nr
		"10000000", --47 SUB M=0
		"00000100", --48 R1,R2
		"00000000", --49 ADD
		"00101100", --50 R2,R4
		"00110100", --51 MOVE M=1
		"10000000", --52 RAUX
		"00000000", --53 '0'
		"00000000", --54 ADD M=0
		"11000100", --55 R2,RAUX
		"01101100", --56 CLR M=1
		"00100000", --57 R2
		"00010000", --58 CMP M=0
		"00010000", --59 R1 RAUX
		"00111100", --60 BRANCH Z M=1
		"01001000", --61 -
		"01000111", --62 71 - DESTINO 2
		"00011000", --63 INC M=0
		"10000000", --64 RAUX
		"10010100", --65 JMP
		"00000000", --66 -
		"00110111", --67 55
		"01011100", --68 ST M=1 --DESTINO 1
		"00000000", --69 R1
		"11101101", --70 Nr
		"01100100", --71 LD M=1 --DESTINO 2
		"01000000", --72 R3
		"11101101", --73 Nr
		"10001000", --74 DEC M=0
		"01000000", --75 R3
		"00110100", --76 MOVE M=1
		"10100000", --77 RAUX2
		"00000000", --78 '0'
		"01100100", --79 LD M=1
		"01100000", --80 R4
		"11101100", --81 Pr
		"01100000", --82 LD M=0
		"00000000", --83 R1
		"11101000", --84 M[Pa]
		"01100000", --85 LD M=0
		"00100000", --86 R2
		"11101010", --87 M[Pb]
		"00100100", --88 NOT M=1
		"00100000", --89 R2
		"00010100", --90 CMP M=1
		"10100000", --91 RAUX2
		"00000000", --92 '0'
		"00111100", --93 BRANCH Z M=1
		"00000000", --94 -
		"01100011", --95-- 99 -- DESTINO 3
		"00001100", --96 ADDC M=1
		"00100000", --97 R2
		"00001001", --98 '9'
		"00001100", --99 ADDC M=1
		"00100000", --100 R2
		"00001010", --101 '10'
		"00010100", --102 CMP M=1
		"00100000", --103 R2
		"00000000", --104 '0'
		"00111100", --105 BRANCH Z M=1
		"00000000", --106 -
		"01111110", --107- 126-- DESTINO 4
		"00010100", --108 CMP M=1
		"00100000", --109 R2
		"00001001", --110 '9'   "#OP2"  --EMPIEZO EN 9 VOY HASTA 15
		"00111100", --111 BRANCH Z M=1
		"00000000", --112 - 
		"01111110", --113 -126- DESTINO 4
		"00011100", --114 INC OP2 M=1
		"00000000", --115 -
		"01101110", --116 *110* "OP2"
		"00010100", --117 CMP M=1
		"00100000", --118 R2
		"00001111", --119 '15'
		"00111100", --120 BRANCH Z M=1
		"00000000", --121 -
		"10000001", --122 -129-DESTINO 5
		"10010100", --123 JMP
		"00000000", --124 -
		"01101100", --125 108
		"00001100", --126- ADDC M=1 --DESTINO 4
		"00100000", --127 R2
		"00000110", --128 '6'
		"01011100", --129 ST M=1--DESTINO 5
		"00100000", --130 R2
		"11101100", --131 Pr
		"00010000", --132 CMP M=0
		"10101000", --133 RAUX2,R3
		"00111100", --134 BRANCH Z M=1
		"00000000", --135 -
		"10010111", --136- 151 --DESTINO 6
		"00011100", --137 INC M=1
		"11001010", --138 -
		"11101000", --139 Pa
		"00011100", --140 INC M=1
		"00000000", --141 -
		"11101010", --142 Pb
		"00011100", --143 INC M=1
		"00000000", --144 -
		"11101100", --145 Pr
		"00011000", --146 INC M=0
		"10100000", --147 RAUX2
		"10010100", --148 JMP 
		"00000000", --149 -
		"01001111", --150 -79
		"00011000", --151  INC M=0 --DESTINO 6
		"10100000", --152- RAUX2
		"00011100", --153 INC M=1
		"00000000", --154 -
		"11101100", --155 Pr
		"01011000", --156 ST M=0
		"11000000", --157 FLAGC
		"11101100", --158 Pr
		"00011000", --159 INC M=0
		"01000000", --160 R3
		"00110000", --161 MOVE M=0
		"10001000", --162 RAUX, R3
		"00000000", --163 ADD M=0
		"10001100", --164 RAUX, R4
		"00000100", --165 ADD M=1
		"10000000", --166 RAUX
		"00001010", --167 '10'
		"01011100", --168 ST M=1
		"10000000", --169 RAUX
		"11101110", --170 Ph
		"01101000", --171 CLR M=0
		"11000000", --172 FLAGC 
		"01101000", --173 CLR M=0
		"10100000", --174 RAUX2
		"01100000", --175 LD M=0
		"00100000", --176 R2
		"11101100", --177 Pr
		"00010100", --178 CMP M=1
		"00100000", --179 R2
		"00000000", --180 '0'
		"00111100", --181 BRANCH Z M=1
		"00000000", --182 -
		"10111000", --183 184--DESTINO 7 (190 PARA CONTINUAR EL ALGORITMO)
		"00110000", --184 MOVE M=0
		"11111100", --185 OP1,OP2 (111 Y 111 PARA TERMINAR)
		"00000000", --186
		"00000000", --187 
		"00000000", --188 
		"00000000", --189
		"10000100", --190-// PARA CONTINUAR EL ALGORITMO: SUB M=1--DESTINO 7 // PARA TERMINAR POR FALTA DE MEMORIA: SE APLICA END
		"01000000", --191 R3
		"11101100", --192 Pr
		"10001000", --193 DEC M=0
		"01000000", --194 R3
		"01101000", --195 CLR M=0
		"11000000", --196 FLAGC
		"01100100", --197 LD M=1
		"00000000", --198 R1
		"11101100", --199 Pr
		"00100000", --200 NOT M=0
		"00000000", --201 R1
		"00011000", --202 INC M=0
		"00000000", --203 R1
		"00010100", --204 CMP M=1
		"10100000", --205 RAUX2
		"00000000", --206 '0'
		"00111100", --207 BRANCH Z M=1
		"00000000", --208 -
		"11010101", --209- 213 --DESTINO 8
		"00001100", --210 ADDC M=1
		"00000000", --211 R1
		"00001001", --212 '9'
		"00001100", --213-ADDC M=1 --DESTINO 8
		"00000000", --214 R1
		"00001010", --215 '10'
		"00010100", --216 CMP M=1
		"00000000", --217 R1 
		"00000000", --218 '0'
		"00111100", --219 BRANCH Z M=1
		"00000001", --220 -
		"11110000", --221- 240 --DESTINO 9 (YA NO CONCUERDA)
		"00010100", --222 CMP M=1 
		"00000000", --223 R1
		"00001001", --224 '9' (#OP2)
		"00111100", --225 BRANCH Z M=1
		"00000000", --226 -
		"11110000", --227 - 240--DESTINO 9 (YA NO CONCUERDA)
		"00011100", --228 INC OP2 M=1
		"00000000", --229 -
		"11100000", --230 224 "OP2"
		"11001101", --231  -- NO ALCANZA LA MEMORIA PARA CONTINUAR
		"11110000", --232 Pa (240)
		"00000010", --233 Na (2)
		"11110101", --234 Pb (245)
		"00000011", --235 Nb (3)
		"11111011", --236 Pr (251)
		"00000000", --237 Nr (3) (DEBE CAMBIAR SOLO)
		"00000000", --238 Ph (YA NO USAMOS)
		"00000000", --239 
		"00000011", --240 3 M[Pa]
		"00000010", --241 2
		"00000000", --242 
		"00000000", --243 
		"00000000", --244 
		"00001000", --245 8  M[Pb]
		"00000100", --246 4
		"00000001", --247 1
		"00000000", --248 
		"00000000", --249 
		"00000000", --250
		"00000000", --251 Resultado 1 M(Pr)
		"00000000", --252 Resultado 2 
		"00000000", --253 Resultado 3 
		"00000000", --254 Resultado 4 
		"00000000" --255 -- MAS ABAJO PR+NR+10 HUBIERA HABIDO PH Y EL RESULTADO TRANSFORMADO DE COMPLEMENTO A BCD EN LENGUAJE HUMANO
);
BEGIN 
	--CONEXION DE SE�ALES
	--SE�ALES DE CONTROL
	--PC
	V <= BANDERA_DATA(3);
	C <=BANDERA_DATA(2);
	Z <=BANDERA_DATA(0);
	LD_PC <=(E6 AND RETI)OR(NOT(M) AND BZ AND E8 AND Z)OR(E8 AND JMP) OR (M AND E6 AND Z AND BZ);
	CLR_PC <= E0;
	INC_PC <=  E1 OR E3 OR (M AND E5 AND (ADD OR ADDC OR CMP OR INC OR NOTT OR MOVE OR SUB OR DEC)) OR (E5 AND (BZ OR ST OR LD OR JMP));
	OE_PC <= E1 OR E3 OR (M AND E5 AND (ADD OR ADDC OR CMP OR INC OR NOTT OR MOVE OR SUB  OR 
    DEC)) OR (E5 AND (ST  OR LD  OR JMP)) OR (BZ AND E5 AND Z) OR (INTS AND E17);
	--TEMP
	TEMP_LOAD_ENABLE <= (NOT(M) AND E5 AND (INC OR NOTT OR DEC))  OR  (NOT(M) AND E6 AND (ADD OR ADDC
	 OR NOTT  OR SUB)) OR (M AND E6 AND DEC)  OR (M AND E7 AND (ADD OR ADDC OR SUB));
	TEMP_CLR <= M AND E5 AND CLR;
	TEMP_OUT_ENABLE <= (NOT(M) AND E6 AND (INC OR NOTT OR DEC))OR(NOT(M) AND E7 AND (ADD OR ADDC OR SUB)) OR
	(M AND E7 AND (NOTT OR CLR OR DEC))OR (M AND E8 AND (ADD OR INC OR SUB)) OR (M AND E9 AND (ADDC OR INC));
	--ALU
	FUN(2) <= (M AND E5 AND INC) OR (NOT(M) AND E5 AND (NOTT OR DEC)) OR (M AND E6 AND (ADD OR ADDC OR CMP OR NOTT OR DEC)) OR
	(NOT(M) AND E6 AND SUB) OR (NOT(M) AND E7 AND (ADD OR ADDC OR CMP)) OR (M AND E7 AND SUB) OR (NOT (M) AND E8 AND INC);
	FUN(1) <= (NOT(M) AND E5 AND (INC OR DEC)) OR (M AND E5 AND NOTT) OR (M AND E6 AND(ADD AND ADDC  AND DEC)) OR
	(NOT(M) AND E6 AND (CMP OR NOTT OR SUB)) OR (NOT(M) AND E7 AND (ADD OR ADDC)) OR (M AND E7 AND (CMP OR SUB)) OR (M AND E8 AND INC);
	FUN(0) <= (NOT(M) AND E5 AND (INC OR NOTT OR DEC)) OR (M AND E6 AND (ADD OR CMP OR NOTT OR SUB OR DEC))
	OR (NOT(M) AND E6 AND ADDC) OR (NOT(M) AND E7 AND (ADD AND CMP AND SUB)) OR (M AND E7 AND ADDC) OR (M AND E8 AND INC);
	--BANDERAS
	BANDERA_LOAD <=(NOT(M) AND E7 AND CMP) OR (M AND E8 AND CMP) OR (E8 AND ADDC) OR (E7 AND RETI);
	BANDERA_OUT <= (NOT(M) AND E6 AND ADDC) OR (M AND E7 AND ADDC) OR (INTS AND E16);
	--RI -- AQU� HAGO LA DISTINCI�N DE RI PORQUE CARGO MI DATO EN DOS REGISTRO DIFERENTES DE ACUERDO A MI UNIDAD DE CONTROL
	LD_RI0 <= E2;
	LD_RI1 <= E4;
	--AR
	LD_AR <= E1 OR E3 OR (M AND E5 AND (ADD OR ADDC OR CMP OR INC OR NOTT OR MOVE OR SUB OR 
	DEC)) OR (E5 AND (ST OR LD OR JMP)) OR (BZ AND E5 AND Z) OR (M AND CLR AND E6) OR (M AND E7 AND INC
	) OR (E7 AND (ST OR LD OR JMP)) OR (NOT(M) AND BZ AND E7 AND Z) OR (NOT(M) AND E9 AND (ST OR LD));
	CLR_AR <= E0;
	--SP
	INC_SP <= RETI AND (E5 OR E6 OR E7 OR E8 OR E9 OR E10);
	DEC_SP <= INTS AND (E12 OR E13 OR E14 OR E15 OR E16 OR E17);
	--MEMORIA
	MEM_OE_AR <= E2 OR E4 OR (M AND E6 AND (ADD OR ADDC OR CMP OR INC OR NOTT  OR
	MOVE OR SUB OR DEC)) OR (E6 AND (ST OR LD OR JMP)) OR (BZ AND E6 AND Z AND NOT(M)) OR 
	(M AND E8 AND INC) OR  (E8 AND (JMP OR LD)) OR (
	NOT(M) AND E8 AND ST) OR (NOT (M) AND BZ AND E8 AND Z) OR (NOT(M) AND E10 AND LD);
	MEM_OE_SP <= RETI AND (E6 OR E7 OR E8 OR E9 OR E10 OR E11);
	MEM_WE_AR <= (M AND E7 AND ((NOTT OR CLR OR DEC))) OR (M AND E8 AND ST) OR (M AND E9 AND INC) OR (NOT(M) AND E10 AND ST);
	MEM_WE_SP <= INTS AND (E12 OR E13 OR E14 OR E15 OR E16 OR E17);
	--OP1 **AQUI SEPARO R1 DE OP1, OSEA CUANDO SE HACE UNA INTERRUPCI�N O LLAMA A RETI, EL REGISTRO 1 ES EL QUE SE DEBE GUARDAR O LEER, LO MISMO PARA OP2
	OP1_LD <=  (NOT(M) AND E5 AND MOVE) OR (NOT (M) AND E6 AND(INC OR NOTT OR DEC)) OR (M AND E6 AND MOVE)
	OR (NOT(M) AND E7 AND (ADD OR ADDC OR SUB)) OR (M AND E8 AND (ADD OR LD OR SUB))
	OR (M AND E9 AND ADDC) OR (NOT(M) AND E10 AND LD) OR (RETI AND E11);
	OP1_CLR <= NOT(M) AND CLR AND E5;
	OP1_OE <= (NOT(M) AND E5 AND (ADD OR ADDC OR INC OR CMP OR NOTT OR  
	SUB OR DEC)) OR (M AND E6 AND CLR) OR (M AND E7 AND (ADD OR ADDC OR CMP OR SUB))
	OR (M AND E8 AND ST) OR (NOT(M) AND E10 AND ST)  OR (INTS AND E12);
	R1_OUT_ENABLE <= (INTS AND E12);
	R1_LOAD_ENABLE <= (RETI AND E11);
	--OP2
	OP2_LD <= E10 AND RETI;
	OP2_OE <= (NOT(M) AND E5 AND MOVE)OR(NOT(M) AND E6 AND(ADD OR ADDC OR CMP OR SUB)) OR (INTS AND E13);
	R2_OUT_ENABLE <= E10 AND RETI;
	R2_LOAD_ENABLE <= INTS AND E13;
	--R3
	R3_LOAD_ENABLE <= E9 AND RETI;
	R3_OUT_ENABLE <= E14 AND INTS;
	--R4
	R4_LOAD_ENABLE <= E10 AND RETI;
	R4_OUT_ENABLE <=  E15 AND INTS;
	--RA
	RA_LOAD_ENABLE<= (NOT(M) AND E5 AND (ADD OR ADDC OR CMP OR SUB)) OR (M AND E6 AND (ADD OR ADDC OR CMP OR SUB));
	RA_OUT_ENABLE <= (NOT(M) AND E6 AND (ADD OR ADDC OR CMP OR SUB)) OR (M AND E7 AND (ADD OR ADDC OR CMP OR SUB));
	--RB
	RB_LOAD_ENABLE <= (M AND E6 AND (CMP OR INC OR MOVE)) OR (E6 AND (ST OR LD OR JMP)) OR (BZ AND NOT (M) AND E6 AND Z);
	RB_OUT_ENABLE <= (M AND E7 AND INC) OR (E7 AND (ST OR LD OR JMP)) OR (NOT(M) AND BZ AND E7 AND Z);
	--RC
	RC_LOAD_ENABLE <= NOT(M) AND E8 AND (ST OR LD);
	RC_OUT_ENABLE <= NOT(M) AND E9 AND (ST OR LD);
	--SE�ALES DE LA M�QUINA DE CONTROL
    --DECODERS
	DECODER_RI0: DECODER
	PORT MAP (
		ENABLE_DEC => '1',
		IND => QI0,
		ADD => ADD,
		ADDC => ADDC,  
		CMP => CMP,
		INC => INC,
		NOTT => NOTT,
		MOVE => MOVE,
		BZ => BZ,
		RETI => RETI,
		ST => ST,
		LD => LD,
		CLR => CLR,
		SUB => SUB,
		DEC => DEC,
		JMP => JMP,
		MODE => M
	);
	DECODER_RI1: DECODER2
	PORT MAP(
		ENABLE_DEC => '1',
		IND => QI1,
		OP1 => OP1,
		OP2 => OP2
	);
	DECODER_3: DECODER3
	PORT MAP(
		ENABLE_DEC => '1',
		IND => OUT_COUNT_CICLOS,
		E0 => E0,
		E1 => E1,
		E2 => E2,
		E3 => E3,
		E4 => E4,
		E5 => E5,
		E6 => E6,
		E7 => E7,
		E8 => E8,
 		E9 => E9,
		E10 => E10,
		E11 => E11,
		E12 => E12,
		E13 => E13,
		E14 => E14,
		E15 => E15,
		E16 => E16,
		E17 => E17,
		EINT => EINT
	);
	--REGISTROS DE INSTRUCCION
	RI0: REGISTROINS
	PORT MAP(
		clk => CLK,
		lod => '1',
		D => BUS_TS,
		Q => QI0
	);
	RI1: REGISTROINS
	PORT MAP(
		clk => CLK,
		lod => '1',
		D => BUS_TS,
		Q => QI1
	);
	CONTADOR_DE_CICLOS: CONTADORCICLOS
	PORT MAP(
		LDCount => LD_COUNT_CICLOS, 
		LDEn => LD_EN_CICLOS,
		clk	=> CLK,
		INcount	=> '1',
		Rcount => '0',
		QBIT => OUT_COUNT_CICLOS
	);
	LD_EN_CICLOS <= (E5 AND ((BZ AND NOT(Z)) OR (NOT (M) AND CLR) OR (NOT (M) AND MOVE))) OR
	(E6 AND ((NOT(M) AND INC) OR (NOT (M) AND DEC) OR (NOT(M) AND NOTT) OR (M AND MOVE) OR (M AND BZ AND Z)))
	OR (E7 AND ((NOT(M) AND (ADD OR CMP OR SUB)) OR (M AND (DEC OR SUB OR NOTT))))
	OR	(E8 AND ((M AND (ADD OR CMP OR LD OR ST OR SUB)) OR (NOT(M) AND (ADDC OR (BZ AND Z))) OR JMP))
	OR (E9 AND M AND (ADDC OR INC)) OR (E10 AND (NOT (M)) AND (ST OR LD)) OR (E11 AND RETI);
	PROCESS (CLK)
	VARIABLE AUX1, AUX2, AUX3, AUX4: INTEGER;
	VARIABLE AUXV: STD_LOGIC_VECTOR(7 DOWNTO 0);
	VARIABLE AUXB: STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
	IF (CLK' EVENT AND CLK = '1') THEN
    --INTERRUPCI�N
	IF (INTS = '0' AND EINT='1') THEN
		LD_COUNT_CICLOS <= "00000001";
	END IF;
	IF (INTS = '1' AND EINT='1') THEN
		LD_COUNT_CICLOS <= "00001100";
    END IF;
	--RUTA DE DATOS
	--ALU
	IF (START = '1' ) THEN
	   E1 <= '1';
	   ENDD <= '0';
	END IF;
	IF (ENDD = '0') THEN
		CASE FUN IS
			WHEN "000" => --ADD
				AUX1:= TO_INTEGER(UNSIGNED(RA_OUT));
				AUX2:= TO_INTEGER(UNSIGNED(BUS_TS));
				AUX3:=AUX1+AUX2;
				ALU_OUT <= STD_lOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
			WHEN "001" => --ADDC
				AUX1:= TO_INTEGER(UNSIGNED(RA_OUT));
				AUX2:= TO_INTEGER(UNSIGNED(BUS_TS));
				AUXB:= "00"&C;
				AUX3:= TO_INTEGER(UNSIGNED(AUXB));
				AUX4:= AUX1+AUX2+AUX3;
				ALU_OUT <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX4,8));
				IF (C='1')THEN
					BANDERA_LOAD <= '1';
					BANDERA_DATA(2) <= '1'; --FLAGC
				END IF;
			WHEN "010" => --CMP 
				IF M='0' THEN --RA-OP2
				AUX1:= TO_INTEGER(UNSIGNED(RA_OUT));
				AUX2:= TO_INTEGER(UNSIGNED(BUS_TS));
				AUX3:= AUX2-AUX1;
				END IF;
				IF M='1' THEN --OP1-RA
				AUX1:= TO_INTEGER(UNSIGNED(RA_OUT));
				AUX2:= TO_INTEGER(UNSIGNED(BUS_TS));
				AUX3:= AUX1-AUX2;
				END IF;
				IF (AUX3=0) THEN
					BANDERA_DATA(0)<='1'; --FLAGZ
				END IF;
				IF (AUX3>0) THEN
					BANDERA_DATA(1)<='1'; --FLAGNZ
					BANDERA_DATA(3)<='1'; --FLAGV
				END IF;
			WHEN "011" => --INC -
				IF M='0' THEN --DEL BUS
				AUX1 := TO_INTEGER(UNSIGNED(BUS_TS));
				AUX1 := AUX1-1;
				ALU_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
			END IF;
			IF M='1' THEN --DEL REGISTRO B
				AUX1 := TO_INTEGER(UNSIGNED(RB_DATA));
				AUX1 := AUX1-1;
				ALU_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
			END IF;
			WHEN "101" => --NOT -- AMBOS DEL BUS
				AUXV := NOT(BUS_TS);
				ALU_OUT  <= AUXV;
			WHEN "110" => --SUB
			IF M='0' THEN --RA-OP2
				AUX1 := TO_INTEGER(UNSIGNED(RA_DATA));
				AUX2 := TO_INTEGER(UNSIGNED(BUS_TS));
				AUX3 := AUX1-AUX2;
				ALU_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
			END IF;
			IF M='1' THEN --OP1-RA
				AUX1 := TO_INTEGER(UNSIGNED(RA_DATA));
				AUX2 := TO_INTEGER(UNSIGNED(BUS_TS));
				AUX3 := AUX2-AUX1;
				ALU_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
			END IF;
			WHEN "111" => --DEC
			IF M='0' THEN --DEL BUS AMBOS
				AUX1 := TO_INTEGER(UNSIGNED(BUS_TS));
				AUX1 := AUX1-1;
				ALU_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
			END IF;
			WHEN OTHERS => --NO SE USA EN REALIDAD PORQUE ES "AND" PERO PIDE EL COMPILADOR
			     AUX1:= AUX2;
		END CASE;
    --MEMORIA 
        IF (MEM_WE_SP = '1') THEN
            MEMORIA(TO_INTEGER(UNSIGNED(SP_DATA))) <= BUS_TS;
        END IF;
        IF (MEM_WE_AR = '1') THEN
             MEMORIA(TO_INTEGER(UNSIGNED(AR_DATA))) <= BUS_TS;
        END IF;
        IF (MEM_OE_AR = '1') THEN
             BUS_TS <= MEMORIA(TO_INTEGER(UNSIGNED(AR_DATA)));
        END IF;
        IF (MEM_OE_SP = '1') THEN
             BUS_TS <= MEMORIA(TO_INTEGER(UNSIGNED(SP_DATA)));
        END IF;
	--REGISTROS
	CASE OP1 IS
		WHEN "000" => --R1 
			R1_LOAD_ENABLE <= OP1_LD;
			R1_OUT_ENABLE <= OP1_OE;
			R1_CLR <= OP1_CLR;
		WHEN "001" => --R2
			R2_LOAD_ENABLE <= OP1_LD;
			R2_OUT_ENABLE <= OP1_OE;
			R2_CLR <= OP1_CLR;
		WHEN "010" => --R3
			R3_LOAD_ENABLE <= OP1_LD;
			R3_OUT_ENABLE <= OP1_OE;
			R3_CLR <= OP1_CLR;
		WHEN "011" => --R4
			R4_LOAD_ENABLE <= OP1_LD;
			R4_OUT_ENABLE <= OP1_OE;
			R4_CLR <= OP1_CLR;
		WHEN "100" => --RAUX
			RAUX_LOAD_ENABLE <= OP1_LD;
			RAUX_OUT_ENABLE <= OP1_OE;
			RAUX_CLR <= OP1_CLR;
		WHEN "101" => --RAUX2
			RAUX2_LOAD_ENABLE <= OP1_LD;
			RAUX2_OUT_ENABLE <= OP1_OE;
			RAUX2_CLR <= OP1_CLR;
		WHEN "110" => --BANDERA
			BANDERA_LOAD<= OP1_LD;
			BANDERA_OUT <= OP1_OE;
		WHEN OTHERS => 
		 IF (OP2 = "111") THEN
		      ENDD <= '1';
		 END IF;
	   END CASE;
	   CASE OP2 IS
		WHEN "000" => --R1
			R1_LOAD_ENABLE <= OP2_LD;
			R1_OUT_ENABLE <= OP2_OE;
		WHEN "001" => --R2
			R2_LOAD_ENABLE <= OP2_LD;
			R2_OUT_ENABLE <= OP2_OE;
		WHEN "010" => --R3
			R3_LOAD_ENABLE <= OP2_LD;
			R3_OUT_ENABLE <= OP2_OE;
		WHEN "011" => --R4
			R4_LOAD_ENABLE <= OP2_LD;
			R4_OUT_ENABLE <= OP2_OE;
		WHEN "100" => --RAUX
			RAUX_LOAD_ENABLE <= OP2_LD;
			RAUX_OUT_ENABLE <= OP2_OE;
		WHEN "101" => --RAUX2
			RAUX2_LOAD_ENABLE <= OP2_LD;
			RAUX2_OUT_ENABLE <= OP2_OE;
		WHEN "110" => --BANDERA
			BANDERA_LOAD<= OP2_LD;
			BANDERA_OUT <= OP2_OE;
		WHEN OTHERS => 
		  IF (OP1 = "111") THEN
		      ENDD <= '1';
		  END IF;
	END CASE;
	--R1
	IF (R1_LOAD_ENABLE = '1' ) THEN
		R1_DATA <= BUS_TS;
	END IF;
	IF (R1_OUT_ENABLE = '1') THEN
		BUS_TS <= R1_DATA;
	END IF;
	--R2
	IF (R2_LOAD_ENABLE = '1' ) THEN
		R2_DATA <= BUS_TS;
	END IF;
	IF (R2_OUT_ENABLE = '1' ) THEN
		BUS_TS <= R2_DATA;
	END IF;
	--R3
	IF (R3_LOAD_ENABLE = '1' ) THEN
		R3_DATA <= BUS_TS;
	END IF;
	IF (R3_OUT_ENABLE = '1' ) THEN
		BUS_TS <= R3_DATA;
	END IF;
	--R4
	IF (R4_LOAD_ENABLE = '1' ) THEN
		R4_DATA <= BUS_TS;
	END IF;
	IF (R4_OUT_ENABLE = '1' ) THEN
		BUS_TS <= R4_DATA;
	END IF;
	--RAUX
	IF (RAUX_LOAD_ENABLE = '1' ) THEN
		RAUX_DATA <= BUS_TS;
	END IF;
	IF (RAUX_OUT_ENABLE = '1' ) THEN
		BUS_TS <= RAUX_DATA;
	END IF;
	--RAUX2
	IF (RAUX2_LOAD_ENABLE = '1' ) THEN
		RAUX2_DATA <= BUS_TS;
	END IF;
	IF (RAUX2_OUT_ENABLE = '1' ) THEN
		BUS_TS <= RAUX2_DATA;
	END IF;
	--TEMP
	IF (TEMP_LOAD_ENABLE = '1') THEN
		TEMP_DATA <= ALU_OUT;
	END IF;
	IF (TEMP_OUT_ENABLE = '1') THEN
		BUS_TS <= TEMP_DATA;
	END IF;
	IF (TEMP_CLR = '1') THEN
		TEMP_DATA <= "00000000";
	END IF;
	--RA
	IF (RA_LOAD_ENABLE = '1') THEN
		RA_DATA <= BUS_TS;
	END IF;
	IF (RA_OUT_ENABLE = '1') THEN 
		RA_OUT <= RA_DATA; 
	END IF;
	--RB
	IF (RB_LOAD_ENABLE = '1') THEN
		RB_DATA  <= BUS_TS;
	END IF;
	IF (RB_OUT_ENABLE = '1') THEN
		BUS_TS <= RB_DATA;
	END IF;
	--RC
	IF (RC_LOAD_ENABLE = '1') THEN
		RC_DATA <= BUS_TS;
	END IF;
	IF (RC_OUT_ENABLE = '1') THEN
		BUS_TS <= RC_DATA;
	END IF;
	--PC
	IF (INC_PC ='1') THEN
		AUX1:= TO_INTEGER(UNSIGNED(PC_DATA));
		AUX1:= AUX1+1;
		PC_DATA <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
	END IF;
	IF (CLR_PC = '1') THEN
		PC_DATA <= "00000000";
	END IF;
	IF (LD_PC = '1') THEN
		PC_DATA <= BUS_TS;
	END IF;
	IF (OE_PC = '1') THEN
		BUS_TS <= PC_DATA;
	END IF;
	--AR
	IF (CLR_AR = '1') THEN
		AR_DATA <= "00000000";
	END IF;
	IF (LD_AR = '1') THEN
		AR_DATA <= BUS_TS;
	END IF;
	--MEMORIA
	IF (MEM_OE_AR = '1') THEN
		BUS_TS <= MEMORIA(TO_INTEGER(UNSIGNED(AR_DATA)));
	END IF;
	IF (MEM_OE_SP = '1') THEN
		BUS_TS <= MEMORIA(TO_INTEGER(UNSIGNED(SP_DATA)));
	END IF;
	IF (MEM_WE_AR = '1') THEN
		 MEMORIA(TO_INTEGER(UNSIGNED(AR_DATA))) <= BUS_TS;
	END IF;
	IF (MEM_WE_SP = '1') THEN
		MEMORIA(TO_INTEGER(UNSIGNED(SP_DATA))) <= BUS_TS;
	END IF;
	--SP
	IF (INC_SP = '1') THEN
		AUX1:= TO_INTEGER(UNSIGNED(SP_DATA));
		AUX1:= AUX1+1;
		SP_DATA <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
	END IF;
	IF (DEC_SP = '1') THEN
		AUX1:= TO_INTEGER(UNSIGNED(SP_DATA));
		AUX1:= AUX1-1;
		SP_DATA <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
	END IF;
	--BANDERAS RECORDANDO QUE TIENE SOLO 4 BITS
	IF (BANDERA_LOAD = '1') THEN
		BANDERA_DATA <= BUS_TS (3 DOWNTO 0);
	END IF;
	IF (BANDERA_OUT = '1') THEN
		BUS_TS <= "0000" & BANDERA_DATA;
	END IF;
	END IF;
	END IF;
END PROCESS;
END ESTRUCTURAL;