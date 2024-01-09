library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Cache is
    port (
        clock:          in std_logic;

        valid:          in std_logic;
        addr:           in std_logic_vector(3 downto 0);
        val:            in std_logic_vector(15 downto 0);

        prev_valid:     out std_logic;
        prev_addr:      out std_logic_vector(3 downto 0);
        prev_val:       out std_logic_vector(15 downto 0)
    );
end Cache;

architecture Cache_arch of Cache is

    signal valid_cache: std_logic;
    signal addr_cache:  std_logic_vector(3 downto 0);
    signal val_cache:   std_logic_vector(15 downto 0);

begin

    prev_valid <= valid_cache;
    prev_addr <= addr_cache;
    prev_val <= val_cache;

    process (clock)
    begin
        if rising_edge(clock) then
            valid_cache <= valid;
            addr_cache <= addr;
            val_cache <= val;
        end if;
    end process;

end Cache_arch;
