library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is
    port (
        reset:          in std_logic;
        clock:          in std_logic;

        src1:           in std_logic_vector(3 downto 0);
        src2:           in std_logic_vector(3 downto 0);
        enable:         in std_logic;
        dest:           in std_logic_vector(3 downto 0);
        in:             in std_logic_vector(15 downto 0);

        out1:           out std_logic_vector(15 downto 0);
        out2:           out std_logic_vector(15 downto 0);
    );
end Register_File;

architecture Register_File_arch of Register_File is

    type register_file is array(0 to 16 - 1) of std_logic_vector(15 downto 0);
    signal registers : register_file;

begin

    process (clock, reset)
    begin
        out1 <= registers(to_integer(unsigned(src1)));
        out2 <= registers(to_integer(unsigned(src2)));

        if rising_edge(clock) then
            if enable = '1' then
                registers(to_integer(unsigned(dest))) <= in;
            end if;
        end if;
    end process;

end Register_File_arch;
