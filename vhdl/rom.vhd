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

    instruction <= rom(to_integer(unsigned(index)));

end Rom_arch;
