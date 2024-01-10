library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decoder is
    port (
        reset:          in std_logic;
        clock:          in std_logic;

        index:          in std_logic_vector(11 downto 0);
        instruction:    in std_logic_vector(25 downto 0);

        jump:           out std_logic;
        conditions:     out std_logic_vector(3 downto 0);
        next_index:     out std_logic_vector(11 downto 0);
        use_RAM_index:  out std_logic;
        jump_index:     out std_logic_vector(11 downto 0);

        use_reg_imm:    out std_logic;
        RAM_enable:     out std_logic;
        RAM_write_index:out std_logic_vector(11 downto 0);
        RAM_read_index: out std_logic_vector(11 downto 0);

        operation:      out std_logic_vector(5 downto 0);
        use_src2:       out std_logic;
        immediate:      out std_logic_vector(15 downto 0);

        src1:           out std_logic_vector(3 downto 0);
        src2:           out std_logic_vector(3 downto 0);

        valid:          out std_logic;
        dest:           out std_logic_vector(3 downto 0);
        use_ALU:        out std_logic
    );
end Decoder;

architecture Decoder_arch of Decoder is

    signal NB_WAIT:     natural range 0 to 5;       -- nb of operations to wait
    signal SP:          natural range 0 to 4095;    -- stack pointer

    signal ins:         std_logic_vector(25 downto 0);
    signal op:          std_logic_vector(3 downto 0);
    signal funct:       std_logic_vector(1 downto 0);
    signal jump_sig:    std_logic;
    signal enable_RAM_sig: std_logic;

begin

    -- operation to decode
    ins <=
        "10010000000000000000000000" when reset = '1' else      -- jmp 0
        "00000000000000100000000000" when not(NB_WAIT = 0) else -- or x0, x0, x0
        instruction;

    -- simple unconditionnal extractions/operations
    conditions <= ins(19 downto 16);
    next_index <= std_logic_vector(unsigned(index) + 1);
    jump_index <= ins(11 downto 0);
    RAM_write_index <= std_logic_vector(to_unsigned(SP, 12));
    RAM_read_index <=
        std_logic_vector(to_unsigned(SP, 12) - unsigned(ins(9 downto 0)) - 1);
    op <= ins(23 downto 20);
    funct <= ins(11 downto 10);
    operation <= op & funct;
    src1 <= ins(15 downto 12);
    src2 <= ins(3 downto 0);
    dest <= ins(19 downto 16);
    immediate <=
        "000000" & ins(9 downto 0) when ins(25 downto 24) = "01" else
        ins(15 downto 0);

    -- control signals
    jump_sig <= '1' when op = "0100" or op = "0110" or op = "0111" else '0';
    jump <= jump_sig;
    use_reg_imm <= '1' when not(op = "0110") else '0';
    enable_RAM_sig <= '1' when op & funct = "001110" or op = "0110" else '0';
    RAM_enable <= enable_RAM_sig;
    use_RAM_index <= '1' when op = "0111" else '0';
    use_src2 <= '1' when ins(25 downto 24) = "00" else '0';
    valid <= '1' when op(3 downto 2) = "00" or op = "0101" else '0';
    use_ALU <= '1' when not(op & funct(1) = "00110") else '0';

    -- intern signals update
    process (clock, reset)
    begin
        if rising_edge(clock) then
            if jump_sig = '1' then
                NB_WAIT <= 5;
            elsif not(NB_WAIT = 0) then
                NB_WAIT <= NB_WAIT - 1;
            end if;

            if reset = '1' then
                SP <= 0;
            elsif enable_RAM_sig = '1' then
                SP <= SP + 1;
            elsif op & funct = "001100" or op = "0111" then
                SP <= SP - 1;
            end if;
        end if;
    end process;

end Decoder_arch;
