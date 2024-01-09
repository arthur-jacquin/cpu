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
        enable_RAM:     out std_logic;
        in_index_RAM:   out std_logic_vector(11 downto 0);
        read_index_RAM: out std_logic_vector(11 downto 0);

        operation:      out std_logic_vector(5 downto 0);
        use_src2:       out std_logic;
        immediate:      out std_logic_vector(15 downto 0);

        src1:           out std_logic_vector(3 downto 0);
        src2:           out std_logic_vector(3 downto 0);

        valid:          out std_logic;
        dest:           out std_logic_vector(3 downto 0);
        use_ALU:        out std_logic;
    );
end Decoder;

architecture Decoder_arch of Decoder is

    signal SP:          std_logic_vector(11 downto 0);  -- stack pointer
    signal NB_WAIT:     std_logic_vector(2 downto 0);   -- nb of operations to wait
    signal ins:         std_logic_vector(25 downto 0);  -- operation to decode

begin

    process (clock, reset)
    begin
        -- calibrate the operation to decode
        if reset = '1' then
            SP <= 0;
            ins <= "10010000000000000000000000"; -- jump to 0
        elseif NB_WAIT = "000" then
            ins <= instruction;
        else
            ins <= "00000000000000100000000000"; -- or x0, x0, x0
        end if;

        -- simple unconditionnal extractions/operations (can be moved out of the process ?)
        conditions <= ins(19 downto 16);
        next_index <= index + 1;
        jump_index <= ins(15 downto 0);
        in_index_RAM <= SP;
        read_index_RAM <= SP - integer(ins(9 downto 0)) - 1;
        operation <= ins(23 downto 20) & ins(11 downto 10);
        src1 <= ins(15 downto 12);
        src2 <= ins(3 downto 0);
        dest <= ins(19 downto 16);
        if (ins(25 downto 24) = "01") then
            immediate <= resize(ins(9 downto 0), 16);
        else
            immediate <= ins(15 downto 0);
        end if;

        -- control signals
        jump <= (operation = "0100.." | operation = "0110.." | operation = "0111..");
        use_reg_imm <= not(operation = "0110..");
        enable_RAM = (operation = "001110" | operation = "0110..");
        use_RAM_index <= (operation = "0111..");
        use_src2 <= (ins(25 downto 24) = "00");
        valid <= (operation = "00...." | operation = "0101..");
        use_ALU <= not(operation = "00110.");

        -- intern signals update
        if rising_edge(clock) then
            if (NB_WAIT \= 0) then
                NB_WAIT <= NB_WAIT - 1;
            elseif (jump = '1') then
                NB_WAIT <= 5; -- TODO: number of stage
            end if;

            if (enable_RAM = '1') then
                SP <= SP + 1;
            else if (operation = "001100" | operation = "0111..") then
                SP <= SP - 1;
            end if;
        end if;
    end process;

end Decoder_arch;
