library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Selector is
    port (
        src:            in std_logic_vector(3 downto 0);
        RF_val:         in std_logic_vector(15 downto 0);
        cache_valid:    in std_logic;
        cache_addr:     in std_logic_vector(3 downto 0);
        cache_val:      in std_logic_vector(15 downto 0);

        val:            out std_logic_vector(15 downto 0)
    );
end Selector;

architecture Selector_arch of Selector is

begin

    val <=
        cache_val when cache_valid = '1' and src = cache_addr else
        RF_val;

end Selector_arch;
