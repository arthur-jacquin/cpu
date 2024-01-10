-- mux
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity BiMux is
    generic (
        size:           natural := 1
    );
    port (
        choose_b:       in std_logic;
        a:              in std_logic_vector(size - 1 downto 0);
        b:              in std_logic_vector(size - 1 downto 0);
        output:         out std_logic_vector(size - 1 downto 0)
    );
end BiMux;
architecture BiMux_arch of BiMux is
begin
    output <= b when choose_b = '1' else a;
end BiMux_arch;

-- index mux
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity IndexBiMux is
    port (
        choose_b:       in std_logic;
        a:              in std_logic_vector(12 - 1 downto 0);
        b:              in std_logic_vector(12 - 1 downto 0);
        output:         out std_logic_vector(12 - 1 downto 0)
    );
end IndexBiMux;
architecture IndexBiMux_arch of IndexBiMux is
begin
r: entity work.BiMux
    generic map (size => 12)
    port map (choose_b => choose_b, a => a, b => b, output => output);
end IndexBiMux_arch;

-- val mux
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ValBiMux is
    port (
        choose_b:       in std_logic;
        a:              in std_logic_vector(16 - 1 downto 0);
        b:              in std_logic_vector(16 - 1 downto 0);
        output:         out std_logic_vector(16 - 1 downto 0)
    );
end ValBiMux;
architecture ValBiMux_arch of ValBiMux is
begin
r: entity work.BiMux
    generic map (size => 16)
    port map (choose_b => choose_b, a => a, b => b, output => output);
end ValBiMux_arch;

-- downsize
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Downsize is
    generic (
        in_size:        natural := 1;
        out_size:       natural := 1
    );
    port (
        input:          in std_logic_vector(in_size - 1 downto 0);
        output:         out std_logic_vector(out_size - 1 downto 0)
    );
end Downsize;
architecture Downsize_arch of Downsize is
begin
    output <= input(out_size - 1 downto 0);
end Downsize_arch;

-- upsize
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Upsize is
    generic (
        in_size:        natural := 1;
        out_size:       natural := 1
    );
    port (
        input:          in std_logic_vector(in_size - 1 downto 0);
        output:         out std_logic_vector(out_size - 1 downto 0)
    );
end Upsize;
architecture Upsize_arch of Upsize is
begin
    output(out_size - 1 downto in_size) <= (others => '0');
    output(in_size - 1 downto 0) <= input;
end Upsize_arch;

-- control
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ControlReg is
    port (
        clock:          in std_logic;
        val:            in std_logic;
        prev_val:       out std_logic
    );
end ControlReg;
architecture ControlReg_arch of ControlReg is
begin
    process (clock)
    begin
        if rising_edge(clock) then
            prev_val <= val;
        end if;
    end process;
end ControlReg_arch;

-- generic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Reg is
    generic (
        size:           natural := 1
    );
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(size - 1 downto 0);
        prev_val:       out std_logic_vector(size - 1 downto 0)
    );
end Reg;
architecture Reg_arch of Reg is
begin
    process (clock)
    begin
        if rising_edge(clock) then
            prev_val <= val;
        end if;
    end process;
end Reg_arch;

-- addr
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity AddrReg is
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(4 - 1 downto 0);
        prev_val:       out std_logic_vector(4 - 1 downto 0)
    );
end AddrReg;
architecture AddrReg_arch of AddrReg is
begin
r: entity work.Reg
    generic map (size => 4)
    port map (clock => clock, val => val, prev_val => prev_val);
end AddrReg_arch;

-- index
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity IndexReg is
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(12 - 1 downto 0);
        prev_val:       out std_logic_vector(12 - 1 downto 0)
    );
end IndexReg;
architecture IndexReg_arch of IndexReg is
begin
r: entity work.Reg
    generic map (size => 12)
    port map (clock => clock, val => val, prev_val => prev_val);
end IndexReg_arch;

-- instruction
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity InstructionReg is
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(26 - 1 downto 0);
        prev_val:       out std_logic_vector(26 - 1 downto 0)
    );
end InstructionReg;
architecture InstructionReg_arch of InstructionReg is
begin
r: entity work.Reg
    generic map (size => 26)
    port map (clock => clock, val => val, prev_val => prev_val);
end InstructionReg_arch;

-- operation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity OperationReg is
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(6 - 1 downto 0);
        prev_val:       out std_logic_vector(6 - 1 downto 0)
    );
end OperationReg;
architecture OperationReg_arch of OperationReg is
begin
r: entity work.Reg
    generic map (size => 6)
    port map (clock => clock, val => val, prev_val => prev_val);
end OperationReg_arch;

-- val
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ValReg is
    port (
        clock:          in std_logic;
        val:            in std_logic_vector(16 - 1 downto 0);
        prev_val:       out std_logic_vector(16 - 1 downto 0)
    );
end ValReg;
architecture ValReg_arch of ValReg is
begin
r: entity work.Reg
    generic map (size => 16)
    port map (clock => clock, val => val, prev_val => prev_val);
end ValReg_arch;

