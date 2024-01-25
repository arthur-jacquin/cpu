library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TESTBENCH is
end TESTBENCH;

architecture TESTBENCH_arch of TESTBENCH is

    component CPU
        port (
            reset:  in std_logic;
            clock:  in std_logic
        );
    end component;

    signal testreset:  std_logic := '1';
    signal testclock:  std_logic := '0';

begin

    testreset <= '0' after 50 ns;
    testclock <= not(testclock) after 5 ns;

    cpu_inst : CPU
        port map (
            reset => testreset,
            clock => testclock
        );

end TESTBENCH_arch;
