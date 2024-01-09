library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        clock:          in std_logic;

        operation:      in std_logic_vector(5 downto 0);
        A:              in std_logic_vector(15 downto 0);
        B:              in std_logic_vector(15 downto 0);

        val:            out std_logic_vector(15 downto 0);
        flags:          out std_logic_vector(3 downto 0)
    );
end ALU;

architecture ALU_arch of ALU is

    signal curr_flags:  std_logic_vector(3 downto 0);
    signal prev_flags:  std_logic_vector(3 downto 0);

begin

    -- TODO: manage operation, A, B, val and curr_flags

    flags <= curr_flags;

    process (clock)
    begin
        if rising_edge(clock) and operation = "001001" then
            prev_flags <= curr_flags;
        end if;
    end process;

end ALU_arch;
