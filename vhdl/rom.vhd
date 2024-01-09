library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rom is
    port (
        reset:          in std_logic;
        clock:          in std_logic;

        index:          in std_logic_vector(11 downto 0);

        out:            out std_logic_vector(25 downto 0);
    );
end Rom;

architecture Rom_arch of Rom is

    type memory is array(0 to 4096 - 1) of std_logic_vector(25 downto 0);
    signal rom : memory;

begin

    process (clock, reset)
    begin
        out <= rom(to_integer(unsigned(index)));
    end process;

end Rom_arch;
