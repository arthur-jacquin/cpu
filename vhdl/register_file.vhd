library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is
    port (
        clock:          in std_logic;

        src1:           in std_logic_vector(3 downto 0);
        src2:           in std_logic_vector(3 downto 0);
        enable:         in std_logic;
        dest:           in std_logic_vector(3 downto 0);
        val:            in std_logic_vector(15 downto 0);

        val1:           out std_logic_vector(15 downto 0);
        val2:           out std_logic_vector(15 downto 0)
    );
end Register_File;

architecture Register_File_arch of Register_File is

    type register_file is array(0 to 16 - 1) of std_logic_vector(15 downto 0);
    signal registers : register_file;

begin

    val1 <= registers(to_integer(unsigned(src1)));
    val2 <= registers(to_integer(unsigned(src2)));

    process (clock)
    begin
        if rising_edge(clock) and enable = '1' then
            registers(to_integer(unsigned(dest))) <= val;
        end if;
    end process;

end Register_File_arch;
