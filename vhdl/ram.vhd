library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram is
    port (
        clock:          in std_logic;

        enable:         in std_logic;
        write_index:    in std_logic_vector(11 downto 0);
        read_index:     in std_logic_vector(11 downto 0);
        write_val:      in std_logic_vector(15 downto 0);

        read_val:       out std_logic_vector(15 downto 0)
    );
end Ram;

architecture Ram_arch of Ram is

    type memory is array(0 to 4096 - 1) of std_logic_vector(15 downto 0);
    signal ram : memory;

begin

    read_val <= ram(to_integer(unsigned(read_index)));

    process (clock)
    begin
        if rising_edge(clock) and enable = '1' then
            ram(to_integer(unsigned(write_index))) <= write_val;
        end if;
    end process;

end Ram_arch;
