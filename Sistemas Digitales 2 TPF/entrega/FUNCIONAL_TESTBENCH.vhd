library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity RESTABCD_CPU_GENERAL_tb is
end;

architecture bench of RESTABCD_CPU_GENERAL_tb is

  component RESTABCD_CPU_GENERAL
  PORT(
  	CLK: IN STD_LOGIC;
  	INTS: IN STD_LOGIC;
  	START: IN STD_LOGIC
  );
  end component;

  signal CLK: STD_LOGIC;
  signal INTS: STD_LOGIC;
  signal START: STD_LOGIC ;

  constant clock_period: time := 10 ns;

BEGIN

  uut: RESTABCD_CPU_GENERAL port map ( CLK   => CLK,
                                       INTS  => INTS,
                                       START => START );

  CLOCK: process
  BEGIN
    CLK <= '0';
    WAIT FOR CLOCK_PERIOD;
    CLK <= '1';
    WAIT FOR CLOCK_PERIOD;
  END PROCESS;
    START <= '1';
    INTS <= '0'; --'1' AFTER 935 NS, '0' AFTER 1035 NS;
END;
