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

    signal logic_val:   std_logic_vector(15 downto 0);
    signal shift_val:   std_logic_vector(15 downto 0);
    signal arith_val:   std_logic_vector(15 downto 0);

    signal result:      std_logic_vector(15 downto 0);
    signal curr_flags:  std_logic_vector(3 downto 0);
    signal prev_flags:  std_logic_vector(3 downto 0);

begin

    with operation(1 downto 0) select
        logic_val <=
            std_logic_vector(not signed(A))             when "00",
            std_logic_vector(signed(A) and signed(B))   when "01",
            std_logic_vector(signed(A) or signed(B))    when "10",
            std_logic_vector(signed(A) xor signed(B))   when others;

    with operation(1 downto 0) select
        shift_val <=
            std_logic_vector(signed(A) sll to_integer(signed(B))) when "00",
            std_logic_vector(signed(A) srl to_integer(signed(B))) when others;

    with operation(1 downto 0) select
        arith_val <=
            std_logic_vector(signed(A) + signed(B)) when "00",
            std_logic_vector(signed(A) - signed(B)) when "01",
            std_logic_vector(resize(signed(A) * signed(B), 16)) when others;

    with operation(5 downto 2) select
        result <=
            logic_val when "0000",
            shift_val when "0001",
            arith_val when "0010",
            b         when "0101", -- mov
            (others => '0') when others;

    curr_flags(3) <= '1' when signed(result) = 0 else '0';
    curr_flags(2) <= '1' when curr_flags(3) = '0' else '0';
    curr_flags(1) <= '1' when signed(result) >= 0 else '0';
    curr_flags(0) <= '1' when curr_flags(1) = '0' or curr_flags(3) = '1' else '0';

    val <= result;
    flags <= curr_flags when operation = "001001" else prev_flags;

    process (clock)
    begin
        if rising_edge(clock) and operation = "001001" then
            prev_flags <= curr_flags;
        end if;
    end process;

end ALU_arch;
