library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ram is
    port (
        reset:          in std_logic;
        clock:          in std_logic;

        enable:         in std_logic;
        in_index:       in std_logic_vector(11 downto 0);
        out_index:      in std_logic_vector(11 downto 0);
        in:             in std_logic_vector(15 downto 0);

        out:            out std_logic_vector(15 downto 0);
    );
end Ram;

architecture Ram_arch of Ram is

    type memory is array(0 to 4096 - 1) of std_logic_vector(15 downto 0);
    signal ram : memory;

begin

    process (clock, reset)
    begin
        out <= ram(to_integer(unsigned(out_index)));

        if rising_edge(clock) then
            if enable = '1' then
                ram(to_integer(unsigned(in_index))) <= in;
            end if;
        end if;
    end process;

end Ram_arch;
