library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetch is
    port (
        reset:          in std_logic;
        clock:          in std_logic;

        last_index:     in std_logic_vector(11 downto 0);
        jump:           in std_logic;
        conditions:     in std_logic_vector(3 downto 0);
        fallback_index: in std_logic_vector(11 downto 0);
        jump_index:     in std_logic_vector(11 downto 0);
        flags:          in std_logic_vector(3 downto 0);

        index:          out std_logic_vector(11 downto 0);
    );
end Fetch;

architecture Fetch_arch of Fetch is

begin

    process (clock, reset)
    begin
        if jump = '1' then
            if (or(not(conditions), flags) = "1111") then
                index <= jump_index;
            else
                index <= fallback_index;
            end if;
        else
            index <= last_index + 1;
        end if;
    end process;

end Fetch_arch;
