library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity RESTABCD_CPU_tb is
end;

architecture bench of RESTABCD_CPU_tb is

  component RESTABCD_CPU
  PORT(
  	CLK: IN STD_LOGIC;
  	START: IN STD_LOGIC;
  	INTS: IN STD_lOGIC;
  	ENDD: BUFFER STD_LOGIC
  );
  end component;

  signal CLK: STD_LOGIC;
  signal START: STD_LOGIC;
  signal INTS: STD_lOGIC;

  constant clock_period: time := 10 ns;

begin

  uut: RESTABCD_CPU port map ( CLK   => CLK,
                               START => START,
                               INTS  => INTS
                               );

  CLOCKING:PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR CLOCK_PERIOD;
    CLK <= '1';
    WAIT FOR CLOCK_PERIOD;
  END PROCESS;
  START <= '1';
  INTS <= '0';
END;