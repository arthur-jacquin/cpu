library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rom is
    port (
        index:          in std_logic_vector(11 downto 0);

        instruction:    out std_logic_vector(25 downto 0)
    );
end Rom;

architecture Rom_arch of Rom is

    type memory is array(0 to 4096 - 1) of std_logic_vector(25 downto 0);
    signal rom : memory;

begin

    rom(0) <= "10010000000000000000001101";
    rom(1) <= "10010101100000000000000000";
    rom(2) <= "10010101110000000000000001";
    rom(3) <= "01001000000010010000000000";
    rom(4) <= "10010010000000000000001011";
    rom(5) <= "01001000100010010000000001";
    rom(6) <= "00010110000000000000000111";
    rom(7) <= "00001001110111000000000110";
    rom(8) <= "00010101100000000000001000";
    rom(9) <= "01001000000010010000000000";
    rom(10) <= "10010001100000000000000101";
    rom(11) <= "00010100010000000000000110";
    rom(12) <= "00011100000000000000000000";
    rom(13) <= "10010100100000000000001100";
    rom(14) <= "10011000000000000000000001";
    rom(15) <= "10010000000000000000001111";

    instruction <= rom(to_integer(unsigned(index)));

end Rom_arch;
