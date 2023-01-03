LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RESTABCD_CPU_GENERAL IS
PORT(
	CLK: IN STD_LOGIC; --CLOCK
	INTS: IN STD_LOGIC; --INTERRUPT
	START: IN STD_LOGIC --START
);
END RESTABCD_CPU_GENERAL;

ARCHITECTURE FUNCIONAL OF RESTABCD_CPU_GENERAL IS
--****************************
--PARA EL ALGORITMO EN PARTICULAR SE SIGUIÓ UTILIZANDO EL ALGORITMO ORIGINAL DE 
--4 BITS, PARA ESTO SIMPLEMENTE CAMBIO, LA FORMA EN QUE IDENTIFICO LA BANDERA DE CARRY
--SIEMPRE SERÁ EL QUINTO BIT INDEPENDIENTEMENTE QUE SE TRABAJE CON 8 BITS EN TODO MOMENTO,
--LA RAZÓN POR LA QUE TRABAJAMOS TODO CON 8 BITS AHORA ES DEBIDO A LA FORMA EN ESPECÍFICO 
--QUE TIENE NUESTRA RUTA DE DATOS Y LA MEMORIA, YA QUE TODOS LOS COMPONENTES QUE INTERACTUAN
--CON EL BUS DE DATOS PRINCIPAL LO HACEN CON 8 BITS
--****************************************
--PARA EL CASO QUE QUERRAMOS HACER UNA SUMA DE 8 BITS CON ACARREO EN EL NOVENO BIT, DEBEMOS CAMBIAR
--NUESTRA FUNCIÓN CARRY Y SU BANDERA A:
--AUX3(8 BITS): OP1
--AUX4(8 BITS): OP2
--AUX5(9 BITS): OP1+OP2
--FLAGCARRY = AUX5(9)
--BANDERA [2(POSICIÓN 3, CARRY)] = FLAGC
--*********************
--PARA NUESTRO ALGORITMO USAMOS REGISTROS EXTRA UTILIZABLES POR EL PROGRAMADOR RAUX Y RAUX2 
--Y DOS INVICIBLES PARA EL QUE SON RA, RB , RC
--*************************
--PARA RECORDAR BANDERA(0-3) ES: Z-NZ-C-V EN ESE ORDEN
--****************************---
--TM ES UN ESTADO INTERMEDIO PARA LA ASIGNACIÓN DE LOS OPERANDOS (NO FORMA PARTE DEL ASM NI EL DISEÑO EN GENERAL)
--PERO QUEDA IMPLÍCITO, SIN EMBARGO, EN EL CÓDIGO, HAY QUE ESPECIFICAR, ESTO SE EXPLICA EN EN LA PARTE DE DISEÑO DE ASM DE NUESTRO PDF
--****************************---
--EL ALGORITMO NO HACE EL ÚLTIMO CAMBIO DE NÚMERO NEGATIVO EN COMPLEMENTO A BCD LEÍBLE POR LA PERSONA
--SIN EMBARGO SE PUEDE SEGUIR VIENDO EL NÚMERO NEGATIVO PERO EN COMPLEMENTO
--****************************---
	--REGISTRO DE INSTRUCCIONES
	SIGNAL OPCODE: STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL RI0, RI1: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL ADRS: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL MODE: STD_LOGIC;
	SIGNAL OP1F,OP2F: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL OP1, OP2, BANDEROTA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	--SEÑALES DE LAS MICRO INSTRUCCIONES Y RD
	SIGNAL AR,PC,SP: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL R1,R2,R3,R4,RA,RB,RC,TEMP, RAUX, RAUX2: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
	SIGNAL BANDERA: STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	SIGNAL FLAGC, FLAGZ, FLAGV: INTEGER;
	--ESTADOS
	TYPE ESTADO IS (T0,T1,T2,T3,T4,TM,TN,T5,T6,T7,T8,T9,T10,T11,TINT,T12,T13,T14,T15,T16,T17);
	SIGNAL EST: ESTADO;
	SIGNAL ENDF: STD_LOGIC:='0';
	TYPE OPERACION IS (ADD,ADDC,CMP,INC,NOTT,ANDD, MOVE, BZ, RETI, PUSH, POP, ST, LD, CLR, SHRR, SHLL, SUB, DEC, JMP);
	SIGNAL OPERATION: OPERACION;
	--MEMORIA
	TYPE VECTOR_ARRAY IS ARRAY (0 to 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL M: VECTOR_ARRAY :=(
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
PROCESS (CLK)
    VARIABLE AUX1,AUX2,AUX3, AUX4, AUX5, AUX6: INTEGER; --1 (PC), 2(AR), 3 (SP), 4 (OPERADOR), 5 (OPERADOR), 6 RESULTADO
    VARIABLE AUXV1: STD_LOGIC_VECTOR (7 DOWNTO 0);
    VARIABLE AUXV2: STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
    IF (CLK' EVENT AND CLK = '1') THEN
    IF(ENDF = '0') THEN
        IF (OP1F="111" AND OP2F= "111") THEN
			ENDF <= '1'; --PARA TERMINAR EL PROCESO PONEMOS AMBOS OPERADORES EN 111 Y 111
		END IF;
        IF (EST = T0) THEN
            AR <= "00000000";
            PC <= "00000000";
            IF (START = '1') THEN
                EST <= T1;
            ELSE 
                EST <= T0;
            END IF;
        END IF;
        -----------------------------------------------------------------
        IF (EST = T1) THEN
            AR <= PC;
            AUX1 := TO_INTEGER(UNSIGNED(PC));
            AUX1 := AUX1+1;
            PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
            EST <= T2;
        END IF;
        -----------------------------------------------------------------
        IF (EST = T2) THEN
            AUX2 := TO_INTEGER(UNSIGNED(AR));
            RI0 <= M(AUX2);
            EST <= T3;
        END IF;
        -----------------------------------------------------------------
        IF (EST = T3) THEN
            AR <= PC;
            AUX1 := TO_INTEGER(UNSIGNED(PC));
            AUX1 := AUX1+1;
            PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
            EST <= T4;
        END IF;
        -----------------------------------------------------------------
        IF (EST = T4) THEN
            AUX2 := TO_INTEGER(UNSIGNED(AR));
            RI1<=M(AUX2);
            EST <= TM;
        END IF;
        -----------------------------------------------------------------
        IF (EST = TM) THEN
         OPCODE <= RI0(7 DOWNTO 3);
         MODE <= RI0(2); 
         OP1F <= RI1 (7 DOWNTO 5);
         OP2F <= RI1 (4 DOWNTO 2);
         ADRS <= RI1 (7 DOWNTO 0);
         EST <= TN;
         BANDEROTA <= "0000"&BANDERA;
        END IF;
        ------------------------------------------------------------------
        IF ( EST = TN) THEN 
        CASE OP1F IS
               WHEN "000" => OP1 <= R1;
               WHEN "001" => OP1 <= R2;
               WHEN "010" => OP1 <= R3;
               WHEN "011" => OP1 <= R4;
               WHEN "100" => OP1 <= RAUX;
               WHEN "101" => OP1 <= RAUX2;
			   WHEN "110" => OP1 <= BANDEROTA; --FLAGC
			   WHEN OTHERS => 
           END CASE;
           CASE OP2F IS
               WHEN "000" => OP2 <= R1;
               WHEN "001" => OP2 <= R2;
               WHEN "010" => OP2 <= R3;
               WHEN "011" => OP2 <= R4;
               WHEN "100" => OP2 <= RAUX;
               WHEN "101" => OP2 <= RAUX2;
			   WHEN "110" => OP2 <= BANDEROTA; --FLAGC
			   WHEN OTHERS =>
           END CASE;
			CASE OPCODE IS
				WHEN "00000" => OPERATION <= ADD;
 				WHEN "00001" => OPERATION <= ADDC;
				WHEN "00010" => OPERATION <= CMP;
				WHEN "00011" => OPERATION <= INC;
				WHEN "00100" => OPERATION <= NOTT;
				WHEN "00101" => OPERATION <= ANDD;
				WHEN "00110" => OPERATION <= MOVE;
				WHEN "00111" => OPERATION <= BZ;
				WHEN "01000" => OPERATION <= RETI;
				WHEN "01001" => OPERATION <= PUSH;
				WHEN "01010" => OPERATION <= POP;
				WHEN "01011" => OPERATION <= ST;
				WHEN "01100" => OPERATION <= LD;
				WHEN "01101" => OPERATION <= CLR;
				WHEN "01110" => OPERATION <= SHRR;
				WHEN "01111" => OPERATION <= SHLL;
				WHEN "10000" => OPERATION <= SUB;
				WHEN "10001" => OPERATION <= DEC;
				WHEN "10010" => OPERATION <= JMP;
				WHEN OTHERS => 
			END CASE;
			EST <= T5;
		END IF;
        -----------------------------------------------------------------
        IF (EST = T5) THEN
            IF (OPCODE = "00000" OR OPCODE = "00001" OR OPCODE = "00010" OR OPCODE = "00101") THEN --ADD & ADDC & CMP & AND
                IF MODE = '0' THEN
                    RA <= OP1;
                END IF;
                IF MODE = '1' THEN
                    AR <=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "00011") THEN --INC
                IF MODE = '0' THEN
                     AUX4 := TO_INTEGER(UNSIGNED(OP1));
                     AUX4 := AUX4+1;
                     TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX4,8));
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "00100") THEN --NOT
                IF MODE = '0' THEN
                    TEMP <= NOT OP1;
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "00110") THEN --MOVE
                IF MODE = '0' THEN
                    OP1<=OP2;
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "00111") THEN --BZ
                IF BANDERA(0) = '0' THEN
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                ELSE
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "01000") THEN --RETI
                AUX3 := TO_INTEGER(UNSIGNED(SP));
                AUX3 := AUX3+1;
                SP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE = "01001") THEN --PUSH
                IF MODE = '0' THEN
                    M(TO_INTEGER(UNSIGNED(SP)))<=OP1;
                    AUX3 := TO_INTEGER(UNSIGNED(SP));
                    AUX3 := AUX3-1;
                    SP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "01010") THEN --POP
				M(TO_INTEGER(UNSIGNED(SP))) <= OP1;
                AUX3 := TO_INTEGER(UNSIGNED(SP));
                AUX3 := AUX3+1;
                SP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
				AUX1 := TO_INTEGER(UNSIGNED(PC));
                AUX1 := AUX1+1;
                PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
            END IF;
            IF (OPCODE = "01011" OR OPCODE ="01100") THEN --ST & LD
                AR<=PC;
                AUX1 := TO_INTEGER(UNSIGNED(PC));
                AUX1 := AUX1+1;
                PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
            END IF;
            IF (OPCODE = "01101") THEN --CLR
                IF MODE = '0' THEN
                    OP1<="00000000";
                END IF;
                IF MODE = '1' THEN
                    Temp <= "00000000";
                END IF;
            END IF;
            IF (OPCODE = "01110" OR OPCODE = "01111") THEN --SHR & SHL
                IF MODE = '0' THEN
                    TEMP<=OP1;
                END IF;
                IF MODE ='1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "10000") THEN --SUB
                IF MODE = '0' THEN
                    RA<=OP1;
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
            IF (OPCODE = "10001") THEN --DEC
                IF MODE = '0' THEN
                    AUX4 := TO_INTEGER(UNSIGNED(OP1));
                    AUX4 := AUX4-1;
                    TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX4,8));
                END IF;
                IF MODE = '1' THEN
                    AR<=PC;
                    AUX1 := TO_INTEGER(UNSIGNED(PC));
                    AUX1 := AUX1+1;
                    PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
                END IF;
            END IF;
			IF (OPCODE = "10010") THEN --JMP
				AR<=PC;
				AUX1 := TO_INTEGER(UNSIGNED(PC));
                AUX1 := AUX1+1;
                PC <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX1,8));
			END IF;
        ------REDIRECCIONAMIENTO----------------------------------------------
            IF ((OPCODE = "01001" AND MODE='0') OR --PUSH (0)
            (OPCODE = "00110" AND MODE='0') OR --MOVE(0)
            (OPCODE ="00111" AND BANDERA(0)='0') --BZ(Z=0)
            OR (OPCODE="01101" AND MODE='0') OR --CLR(0)
			(OPCODE = "01010")) THEN --POP(0)
                EST <= TINT;
            ELSE 
                EST <= T6;
            END IF;
        END IF;
        ----------------------------------------------------------------------
        IF (EST = T6) THEN
            IF (OPCODE = "00000" ) THEN --ADD 
                IF MODE = '0' THEN
                     AUX4 := TO_INTEGER(UNSIGNED(RA));
                     AUX5 := TO_INTEGER(UNSIGNED(OP2));
                     AUX6 := AUX4+AUX5;
                     TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
                IF MODE = '1' THEN
                    RA<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00001" ) THEN --ADDC 
                IF MODE = '0' THEN
                    AUX4 := TO_INTEGER(UNSIGNED(RA));
                    AUX5 := TO_INTEGER(UNSIGNED(OP2));
                    AUX6 := AUX4+AUX5+FLAGC;
                    TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
                IF MODE = '1' THEN
                    RA<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00010") THEN --CMP
                IF MODE = '0' THEN
                    AUX4 := TO_INTEGER(UNSIGNED(RA));
                    AUX5 := TO_INTEGER(UNSIGNED(OP2));
                    FLAGZ<=AUX4-AUX5; -- RESTA
                END IF;
                IF MODE = '1' THEN
                    RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00011") THEN --INC
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00100") THEN --NOT
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    TEMP <= NOT M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00101") THEN --AND
                IF MODE = '0' THEN
                    TEMP<=RA AND R2;
                END IF;
                IF MODE = '1' THEN
                    RA<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00110") THEN --MOVE
                IF MODE = '1' THEN
                    OP1<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "00111") THEN --BZ
                IF (MODE = '0' AND BANDERA(0)='1') THEN
                        RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
                IF (MODE = '1' AND BANDERA(0)='1') THEN
                        PC<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01000") THEN --RETI
                PC<=M(TO_INTEGER(UNSIGNED(AR)));
                AUX3 := TO_INTEGER(UNSIGNED(SP));
                AUX3 := AUX3 +1;
                SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE = "01001") THEN --PUSH
                IF MODE = '1' THEN
                    RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01011" OR OPCODE ="01100") THEN --ST & LD
                RB<=M(TO_INTEGER(UNSIGNED(AR)));
            END IF;
            IF (OPCODE = "01101") THEN --CLR
                IF MODE = '1' THEN
                    AR<=OP1;
                END IF;
            END IF;
            IF (OPCODE = "01110") THEN --SHR
                IF MODE = '0' THEN
                    TEMP <= '0' & TEMP (7 DOWNTO 1);
                END IF;
                IF MODE = '1' THEN 
                    RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01111") THEN --SHL
                IF MODE = '0' THEN
                    TEMP <= TEMP (6 DOWNTO 0) & '0';
                END IF;
                IF MODE = '1' THEN
                    RB<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "10000") THEN --SUB
                IF MODE = '0' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(RA));
                    AUX5:= TO_INTEGER(UNSIGNED(OP2));
                    AUX6:= AUX4-AUX5;
                    TEMP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
                IF MODE = '1' THEN
                    RA <= M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "10001") THEN --DEC
                IF MODE ='0' THEN
                    OP1<=Temp;
                END IF;
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(M(TO_INTEGER(UNSIGNED(AR)))));
                    AUX4:= AUX4-1;
                    Temp <=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX4,8));
                END IF;
            END IF;
			IF (OPCODE ="10010") THEN --JMP
				RB <= M(TO_INTEGER(UNSIGNED(AR)));
			END IF;
        -----------REDIRECCIONAMIENTO----------------------------------------------
            IF ((OPCODE = "10001" AND MODE ='0')OR --DEC (0)
            (OPCODE="00100" AND MODE='1') OR --MOVE(1)
            (OPCODE="00011" AND MODE='0') OR --INC(0)
            (OPCODE="00100" AND MODE='0') OR --NOT(0)
            (OPCODE="01010") OR --POP
            (OPCODE = "00111" AND MODE='1' AND BANDERA(0)='1') OR --BZ(1/1)
            (OPCODE = "00011" AND MODE='0')) THEN 
                EST <= TINT;
            ELSE 
                EST <= T7;
            END IF;
        END IF;
        ---------------------------------------------------------------------------
        IF (EST = T7) THEN
            IF (OPCODE = "00000") THEN --ADD
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(RA));
                    AUX5:= TO_INTEGER(UNSIGNED(OP2));
                    AUX6:= AUX4+AUX5;
                    TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
            END IF;
            IF (OPCODE = "00001") THEN --ADDC
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(RA));
                    AUX5:= TO_INTEGER(UNSIGNED(OP2));
                    AUX6:= AUX4+AUX5+FLAGC;
                    TEMP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
            END IF;
            IF (OPCODE = "00010") THEN --CMP
                IF MODE = '0' THEN
                    IF FLAGZ = 0 THEN
                        BANDERA(0) <= '1';
						BANDERA(1) <= '0';
                    ELSE
                        IF FLAGZ > 1 THEN
                            BANDERA(3)<='1';
                        END IF;
                        BANDERA(0) <= '0';
						BANDERA(1) <= '1';
                    END IF;
                END IF;
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(OP1));
                    AUX5:= TO_INTEGER(UNSIGNED(RA));
                    FLAGZ<=AUX4-AUX5;
                END IF;
            END IF;
            IF (OPCODE = "00011") THEN --INC
                IF MODE ='1' THEN
                    AR<=RB;
                END IF;
            END IF;
            IF (OPCODE = "00100") THEN --NOT
                IF MODE = '1' THEN
                    M (TO_INTEGER(UNSIGNED(AR))) <= TEMP;
                END IF;
            END IF;
            IF (OPCODE = "00101") THEN --AND
                IF MODE = '0' THEN
                    OP1 <= TEMP;
                END IF;
                IF MODE = '1' THEN
                    TEMP<=RA AND R2;
                END IF;
            END IF;
            IF (OPCODE = "00111") THEN --BZ
                IF (MODE = '0' AND BANDERA(0)='1') THEN
                        AR<=RB;
                END IF;
            END IF;
            IF (OPCODE = "01000") THEN --RETI
                AUXV1 := M(TO_INTEGER(UNSIGNED(SP)));
                AUXV2 := AUXV1 (3 DOWNTO 0);
                BANDERA <= AUXV2;
                AUX3:= TO_INTEGER(UNSIGNED(SP));
                AUX3:= AUX3+1;
                SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE = "01001" OR OPCODE ="01100") THEN --PUSH
                IF MODE = '1' THEN
                    M(TO_INTEGER(UNSIGNED(SP)))<=RB;
                    AUX3:= TO_INTEGER(UNSIGNED(SP));
                    AUX3:= AUX3-1;
                    SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
                END IF;
            END IF;
            IF (OPCODE = "01011") THEN --ST & LD
                AR<=RB;
            END IF;
            IF (OPCODE = "01110" OR OPCODE = "01111") THEN --SHR&SHL
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    AR <=RB;
                END IF;
            END IF;
            IF (OPCODE = "01101") THEN --CLR
                IF MODE = '1' THEN
                    M(TO_INTEGER(UNSIGNED(AR)))<=TEMP;
                END IF;
            END IF;
            IF (OPCODE = "10000") THEN --SUB
                IF MODE = '0' THEN
                    OP1<=TEMP;
                END IF;
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(OP1));
                    AUX5:= TO_INTEGER(UNSIGNED(RA));
                    AUX6:= AUX4+AUX5+FLAGC; 
                    TEMP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX6,8));
                END IF;
            END IF;
            IF (OPCODE = "10001") THEN --DEC
                IF MODE = '1'THEN
                    M(TO_INTEGER(UNSIGNED(AR)))<=TEMP;
                END IF;
            END IF;
			IF (OPCODE = "10010") THEN --JMP
				AR <= RB;
			END IF;
        ----------REDIRECCIONAMIENTO----------------------------------------------
        IF ((OPCODE = "00000" AND MODE = '0') --ADD(0)
            OR (OPCODE = "00010" AND MODE = '0') OR --CMP(0)
            (OPCODE = "01110" AND MODE = '0') OR --SHR(0)
            (OPCODE = "01111" AND MODE = '0') OR --SHL(0)
            (OPCODE = "01001" AND MODE = '0') OR --PUSH(0)
            (OPCODE = "10001" AND MODE = '1') OR --DEC(1)
            (OPCODE = "10000" AND MODE = '0') OR --SUB(0)
            (OPCODE = "00101" AND MODE = '0') OR --AND (0)
            (OPCODE = "00100" AND MODE = '1') OR --NOT (1)
            (OPCODE = "01101" AND MODE = '1')) THEN --CLR(1)
                    EST <= TINT;
                ELSE
                    EST <= T8;
                END IF;
            END IF;
        --------------------------------------------------------------------------
        IF (EST = T8) THEN
            IF (OPCODE = "00000") THEN --ADD 
                IF MODE = '1' THEN
                    R1<=TEMP;
                END IF;
            END IF;
            IF (OPCODE = "00001") THEN --ADDC 
                IF (TEMP (4)='1') THEN
                        FLAGC <= 1; --BANDERA DE CARRY
                        BANDERA(2) <= '1';
                END IF;
            END IF;
            IF (OPCODE = "00010") THEN --CMP
                IF MODE = '1' THEN
                    IF FLAGZ = 0 THEN
                        BANDERA (0) <= '1';
						BANDERA (1) <= '0';
                    ELSE
                        FLAGV <= FLAGZ;
						BANDERA (0) <= '0';
						BANDERA (1) <= '1';
                        BANDERA (3) <= '1';
                    END IF;
                END IF;
            END IF;
            IF (OPCODE = "00011") THEN --INC
                IF MODE = '1' THEN
                    AUX4:= TO_INTEGER(UNSIGNED(M(TO_INTEGER(UNSIGNED(AR)))));
                    AUX4:= AUX4-1;
                    TEMP <= STD_LOGIC_VECTOR(TO_UNSIGNED(AUX4, 8));
                END IF;
            END IF;
            IF (OPCODE = "00101") THEN --AND
                IF MODE = '1' THEN
                    OP1<=TEMP;
                END IF;
            END IF;
            IF (OPCODE = "00111") THEN --BZ
                IF (MODE = '0' AND BANDERA(0)='1') THEN
                        PC<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01000") THEN --RETI AQUÍ USAMOS REGISTROS ESTATICOS EN VEZ DE OPERADORES
                R4<=M(TO_INTEGER(UNSIGNED(SP)));
                AUX3:= TO_INTEGER(UNSIGNED(SP));
                AUX3:= AUX3+1;
                SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE = "01011" ) THEN --ST 
                IF MODE ='0' THEN
                    RC<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
                IF MODE = '1' THEN
                    M(TO_INTEGER(UNSIGNED(AR)))<=OP1;
                END IF;
            END IF;
            IF (OPCODE = "01100") THEN --LD
                IF MODE ='0' THEN
                    RC<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
               IF MODE = '1' THEN
                    OP1<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01110" OR OPCODE = "01111") THEN --SHR & SHL
                IF MODE = '1' THEN
                    TEMP<=M(TO_INTEGER(UNSIGNED(AR))) ;
                END IF;
            END IF;
            IF (OPCODE = "10000") THEN --SUB
                IF MODE = '1' THEN
                    OP1<=TEMP;
                END IF;
            END IF;
        ----------REDIRECCIONAMIENTO----------------------------------------------
            IF ((OPCODE = "00000" AND MODE='1') OR --ADD(1) 
            (OPCODE ="00001" AND MODE = '0') OR --ADDC(0)
            (OPCODE="00010" AND MODE ='1')OR --CMP(1)
            (OPCODE ="01011" AND MODE='1') OR  --ST(1)
            (OPCODE ="01100" AND MODE= '1') OR  --LD(1)
            (OPCODE = "00101" AND MODE='1') OR  --AND(1)
            (OPCODE = "00111" AND MODE='0' AND BANDERA(0)='1')OR --BZ(0/1)
			(OPCODE = "10010"))THEN --JMP
            EST <= TINT;
            ELSE
                EST <= T9;
            END IF;
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T9) THEN
            IF (OPCODE = "00001") THEN --ADDC
                IF MODE='1' THEN
                    OP1<=TEMP;
                END IF;
            END IF;
            IF (OPCODE = "00011")THEN --INC
                IF MODE='1' THEN
                    M (TO_INTEGER(UNSIGNED(AR)))<=TEMP;
                END IF;
            END IF;
            IF (OPCODE ="01000") THEN --RETI
                R3<=M(TO_INTEGER(UNSIGNED(SP)));
                AUX3:= TO_INTEGER(UNSIGNED(SP));
                AUX3:= AUX3+1;
                SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE ="01011" OR OPCODE ="01100") THEN --ST&LD
                IF MODE='0' THEN
                    AR<=RC;
                END IF;
            END IF;
            IF (OPCODE ="01110") THEN --SHR
                IF MODE='1' THEN
                    TEMP <= '0' & TEMP (7 DOWNTO 1);
                END IF;
            END IF;
            IF (OPCODE ="01110") THEN --SHR
                IF MODE='1' THEN
                    TEMP<= TEMP(6 DOWNTO 0)& '0';
                END IF;
            END IF;
			IF (OPCODE = "10010") THEN --JMP
				PC <= M(TO_INTEGER(UNSIGNED(AR)));
			END IF;
        ----------REDIRECCIONAMIENTO----------------------------------------------	
            IF ((OPCODE = "00001" AND MODE='1') OR --ADDC(1)
            (OPCODE ="00011" AND MODE='1')  --INC(1)
            ) THEN
                EST <= TINT;
            ELSE
                EST <= T10;
            END IF;
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T10) THEN
            IF (OPCODE ="01000") THEN --RETI
                R2<=M(TO_INTEGER(UNSIGNED(SP)));
                AUX3:= TO_INTEGER(UNSIGNED(SP));
                AUX3:= AUX3+1;
                SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
            END IF;
            IF (OPCODE ="01011") THEN --ST
                IF MODE = '0' THEN
                    M(TO_INTEGER(UNSIGNED(AR)))<=OP1;
                END IF;
            END IF;
            IF (OPCODE ="01100") THEN --LD
                IF MODE = '0' THEN
                    OP1<=M(TO_INTEGER(UNSIGNED(AR)));
                END IF;
            END IF;
            IF (OPCODE = "01111" OR OPCODE = "01110") THEN --SHR&SHL
                IF MODE ='0' THEN
                    M(TO_INTEGER(UNSIGNED(AR))) <= TEMP;
                END IF;
            END IF;
        ----------REDIRECCIONAMIENTO----------------------------------------------	
            IF ((OPCODE ="01110" AND MODE='1') OR --SHR(1)
            (OPCODE="01111" AND MODE='1') OR  --SHL(1)
            (OPCODE="01011" AND MODE='1') OR --ST(1)
            (OPCODE="01100" AND MODE='1'))THEN --LD(1)
                EST <= TINT;
            ELSE
                EST <=T11;
            END IF;
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T11) THEN
            IF (OPCODE ="01000") THEN --RETI
                R1 <=M(TO_INTEGER(UNSIGNED(SP)));
                EST <= TINT;
            END IF;
        END IF;
        --------------------------------------------------------------------------
        IF (EST = TINT) THEN
            IF (INTS ='1') THEN
                EST <= T12;
            ELSE
                EST <= T1;
            END IF;
            CASE OP1F IS
               WHEN "000" => R1 <= OP1;
               WHEN "001" => R2 <= OP1;
               WHEN "010" => R3 <= OP1;
               WHEN "011" => R4 <= OP1;
               WHEN "100" => RAUX <= OP1;
               WHEN "101" => RAUX2 <= OP1;
			   WHEN "110" => BANDEROTA <= OP1; --FLAGC
			   WHEN OTHERS => 
           END CASE;
           CASE OP2F IS
               WHEN "000" => R1 <= OP2;
               WHEN "001" => R2 <= OP2;
               WHEN "010" => R3 <= OP2;
               WHEN "011" => R4 <= OP2;
               WHEN "100" => RAUX <= OP2;
               WHEN "101" => RAUX2 <= OP2;
			   WHEN "110" => BANDEROTA <= OP2; --FLAGC
			   WHEN OTHERS =>
           END CASE;
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T12) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<=R1;
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T13) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<=R2;
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T14) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<=R3;
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T15) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<=R4; 
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T16) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<= "0000" & BANDERA (3 DOWNTO 0);
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
        --------------------------------------------------------------------------
        IF (EST = T17) THEN
            M(TO_INTEGER(UNSIGNED(SP)))<=PC;
            AUX3:= TO_INTEGER(UNSIGNED(SP));
            AUX3:= AUX3-1;
            SP<=STD_LOGIC_VECTOR(TO_UNSIGNED(AUX3,8));
        END IF;
    END IF;
	END IF;
END PROCESS;
END FUNCIONAL;