library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetch is
    port (
        last_index:     in std_logic_vector(11 downto 0);
        jump:           in std_logic;
        conditions:     in std_logic_vector(3 downto 0);
        fallback_index: in std_logic_vector(11 downto 0);
        jump_index:     in std_logic_vector(11 downto 0);
        flags:          in std_logic_vector(3 downto 0);

        index:          out std_logic_vector(11 downto 0)
    );
end Fetch;

architecture Fetch_arch of Fetch is

begin

    index <=
        std_logic_vector(unsigned(last_index) + 1) when not(jump = '1') else
        jump_index when (not(conditions) or flags) = "1111" else
        fallback_index;

end Fetch_arch;
