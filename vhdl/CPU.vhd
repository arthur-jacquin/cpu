-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"
-- CREATED		"Wed Jan 10 15:49:58 2024"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY CPU IS 
	PORT
	(
		reset :  IN  STD_LOGIC;
		clock :  IN  STD_LOGIC
	);
END CPU;

ARCHITECTURE bdf_type OF CPU IS 

COMPONENT indexreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT valbimux
	PORT(choose_b : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT operationreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT;

COMPONENT controlreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC;
		 prev_val : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT indexbimux
	PORT(choose_b : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT addrreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT valreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT instructionreg
	PORT(clock : IN STD_LOGIC;
		 val : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
	);
END COMPONENT;

COMPONENT downsize
GENERIC (in_size : INTEGER;
			out_size : INTEGER
			);
	PORT(input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT cache
	PORT(clock : IN STD_LOGIC;
		 valid : IN STD_LOGIC;
		 addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 prev_valid : OUT STD_LOGIC;
		 prev_addr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 prev_val : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT selector
	PORT(cache_valid : IN STD_LOGIC;
		 cache_addr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 cache_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 RF_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 src : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 val : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(clock : IN STD_LOGIC;
		 A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 operation : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		 flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 val : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ram
	PORT(clock : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 read_index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 write_index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 write_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 read_val : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT upsize
GENERIC (in_size : INTEGER;
			out_size : INTEGER
			);
	PORT(input : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fetch
	PORT(jump : IN STD_LOGIC;
		 conditions : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 fallback_index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 jump_index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 last_index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 index : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(clock : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 dest : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 src1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 src2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 val_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 val1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 val2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rom
	PORT(index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 instruction : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
	);
END COMPONENT;

COMPONENT decoder
	PORT(reset : IN STD_LOGIC;
		 clock : IN STD_LOGIC;
		 index : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 instruction : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 jump : OUT STD_LOGIC;
		 use_RAM_index : OUT STD_LOGIC;
		 use_reg_imm : OUT STD_LOGIC;
		 RAM_enable : OUT STD_LOGIC;
		 use_src2 : OUT STD_LOGIC;
		 valid : OUT STD_LOGIC;
		 use_ALU : OUT STD_LOGIC;
		 conditions : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 dest : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 immediate : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 jump_index : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 next_index : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 operation : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		 RAM_read_index : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 RAM_write_index : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		 src1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 src2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_94 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_95 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_96 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(25 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_30 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_32 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_33 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_35 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_36 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_37 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_38 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_39 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_40 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_97 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_98 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_43 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_45 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_46 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_47 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_48 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_49 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_50 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_99 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_100 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_101 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_102 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_103 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_104 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_57 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_58 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_62 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_63 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_64 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_66 :  STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_67 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_68 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_69 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_70 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_105 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_72 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_73 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_74 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_75 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_76 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_77 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_78 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_79 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_80 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_83 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_84 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_92 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_93 :  STD_LOGIC_VECTOR(25 DOWNTO 0);


BEGIN 



b2v_inst : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_94,
		 prev_val => SYNTHESIZED_WIRE_92);


b2v_inst10 : valbimux
PORT MAP(choose_b => SYNTHESIZED_WIRE_1,
		 a => SYNTHESIZED_WIRE_95,
		 b => SYNTHESIZED_WIRE_3,
		 output => SYNTHESIZED_WIRE_101);


b2v_inst11 : operationreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_4,
		 prev_val => SYNTHESIZED_WIRE_12);


b2v_inst12 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_5,
		 prev_val => SYNTHESIZED_WIRE_29);


b2v_inst13 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_6,
		 prev_val => SYNTHESIZED_WIRE_30);


b2v_inst14 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_7,
		 prev_val => SYNTHESIZED_WIRE_31);


b2v_inst15 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_8,
		 prev_val => SYNTHESIZED_WIRE_32);


b2v_inst16 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_9,
		 prev_val => SYNTHESIZED_WIRE_33);


b2v_inst17 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_10,
		 prev_val => SYNTHESIZED_WIRE_35);


b2v_inst18 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_11,
		 prev_val => SYNTHESIZED_WIRE_36);


b2v_inst19 : operationreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_12,
		 prev_val => SYNTHESIZED_WIRE_66);


b2v_inst2 : indexbimux
PORT MAP(choose_b => SYNTHESIZED_WIRE_13,
		 a => SYNTHESIZED_WIRE_14,
		 b => SYNTHESIZED_WIRE_15,
		 output => SYNTHESIZED_WIRE_80);


b2v_inst20 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_16,
		 prev_val => SYNTHESIZED_WIRE_43);


b2v_inst21 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_17,
		 prev_val => SYNTHESIZED_WIRE_34);


b2v_inst22 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_18,
		 prev_val => SYNTHESIZED_WIRE_98);


b2v_inst23 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_19,
		 prev_val => SYNTHESIZED_WIRE_97);


b2v_inst24 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_20,
		 prev_val => SYNTHESIZED_WIRE_40);


b2v_inst25 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_21,
		 prev_val => SYNTHESIZED_WIRE_44);


b2v_inst26 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_22,
		 prev_val => SYNTHESIZED_WIRE_45);


b2v_inst27 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_23,
		 prev_val => SYNTHESIZED_WIRE_46);


b2v_inst28 : valreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_24,
		 prev_val => SYNTHESIZED_WIRE_50);


b2v_inst3 : valbimux
PORT MAP(choose_b => SYNTHESIZED_WIRE_25,
		 a => SYNTHESIZED_WIRE_26,
		 b => SYNTHESIZED_WIRE_96,
		 output => SYNTHESIZED_WIRE_70);


b2v_inst30 : instructionreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_28,
		 prev_val => SYNTHESIZED_WIRE_93);


b2v_inst32 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_29,
		 prev_val => SYNTHESIZED_WIRE_72);


b2v_inst33 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_30,
		 prev_val => SYNTHESIZED_WIRE_73);


b2v_inst34 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_31,
		 prev_val => SYNTHESIZED_WIRE_25);


b2v_inst35 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_32,
		 prev_val => SYNTHESIZED_WIRE_67);


b2v_inst36 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_33,
		 prev_val => SYNTHESIZED_WIRE_37);


b2v_inst37 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_34,
		 prev_val => SYNTHESIZED_WIRE_100);


b2v_inst38 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_35,
		 prev_val => SYNTHESIZED_WIRE_99);


b2v_inst39 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_36,
		 prev_val => SYNTHESIZED_WIRE_1);


b2v_inst4 : valbimux
PORT MAP(choose_b => SYNTHESIZED_WIRE_37,
		 a => SYNTHESIZED_WIRE_38,
		 b => SYNTHESIZED_WIRE_39,
		 output => SYNTHESIZED_WIRE_96);


b2v_inst40 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_40,
		 prev_val => SYNTHESIZED_WIRE_105);


b2v_inst41 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_97,
		 prev_val => SYNTHESIZED_WIRE_63);


b2v_inst42 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_98,
		 prev_val => SYNTHESIZED_WIRE_58);


b2v_inst43 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_43,
		 prev_val => SYNTHESIZED_WIRE_75);


b2v_inst44 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_44,
		 prev_val => SYNTHESIZED_WIRE_83);


b2v_inst45 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_45,
		 prev_val => SYNTHESIZED_WIRE_69);


b2v_inst46 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_46,
		 prev_val => SYNTHESIZED_WIRE_68);


b2v_inst47 : valreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_47,
		 prev_val => SYNTHESIZED_WIRE_62);


b2v_inst49 : valreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_48,
		 prev_val => SYNTHESIZED_WIRE_57);


b2v_inst5 : downsize
GENERIC MAP(in_size => 16,
			out_size => 12
			)
PORT MAP(input => SYNTHESIZED_WIRE_49,
		 output => SYNTHESIZED_WIRE_15);


b2v_inst50 : valreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_50,
		 prev_val => SYNTHESIZED_WIRE_38);


b2v_inst55 : cache
PORT MAP(clock => clock,
		 valid => SYNTHESIZED_WIRE_99,
		 addr => SYNTHESIZED_WIRE_100,
		 val => SYNTHESIZED_WIRE_101,
		 prev_valid => SYNTHESIZED_WIRE_102,
		 prev_addr => SYNTHESIZED_WIRE_103,
		 prev_val => SYNTHESIZED_WIRE_104);


b2v_inst56 : selector
PORT MAP(cache_valid => SYNTHESIZED_WIRE_102,
		 cache_addr => SYNTHESIZED_WIRE_103,
		 cache_val => SYNTHESIZED_WIRE_104,
		 RF_val => SYNTHESIZED_WIRE_57,
		 src => SYNTHESIZED_WIRE_58,
		 val => SYNTHESIZED_WIRE_39);


b2v_inst57 : selector
PORT MAP(cache_valid => SYNTHESIZED_WIRE_102,
		 cache_addr => SYNTHESIZED_WIRE_103,
		 cache_val => SYNTHESIZED_WIRE_104,
		 RF_val => SYNTHESIZED_WIRE_62,
		 src => SYNTHESIZED_WIRE_63,
		 val => SYNTHESIZED_WIRE_64);


b2v_inst58 : alu
PORT MAP(clock => clock,
		 A => SYNTHESIZED_WIRE_64,
		 B => SYNTHESIZED_WIRE_96,
		 operation => SYNTHESIZED_WIRE_66,
		 flags => SYNTHESIZED_WIRE_74,
		 val => SYNTHESIZED_WIRE_3);


b2v_inst59 : ram
PORT MAP(clock => clock,
		 enable => SYNTHESIZED_WIRE_67,
		 read_index => SYNTHESIZED_WIRE_68,
		 write_index => SYNTHESIZED_WIRE_69,
		 write_val => SYNTHESIZED_WIRE_70,
		 read_val => SYNTHESIZED_WIRE_95);


b2v_inst6 : upsize
GENERIC MAP(in_size => 12,
			out_size => 16
			)
PORT MAP(input => SYNTHESIZED_WIRE_105,
		 output => SYNTHESIZED_WIRE_26);


b2v_inst60 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_72,
		 prev_val => SYNTHESIZED_WIRE_76);


b2v_inst61 : controlreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_73,
		 prev_val => SYNTHESIZED_WIRE_13);


b2v_inst62 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_74,
		 prev_val => SYNTHESIZED_WIRE_79);


b2v_inst63 : addrreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_75,
		 prev_val => SYNTHESIZED_WIRE_77);


b2v_inst65 : fetch
PORT MAP(jump => SYNTHESIZED_WIRE_76,
		 conditions => SYNTHESIZED_WIRE_77,
		 fallback_index => SYNTHESIZED_WIRE_78,
		 flags => SYNTHESIZED_WIRE_79,
		 jump_index => SYNTHESIZED_WIRE_80,
		 last_index => SYNTHESIZED_WIRE_94,
		 index => SYNTHESIZED_WIRE_84);


b2v_inst66 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_105,
		 prev_val => SYNTHESIZED_WIRE_78);


b2v_inst67 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_83,
		 prev_val => SYNTHESIZED_WIRE_14);


b2v_inst68 : indexreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_84,
		 prev_val => SYNTHESIZED_WIRE_94);


b2v_inst70 : valreg
PORT MAP(clock => clock,
		 val => SYNTHESIZED_WIRE_95,
		 prev_val => SYNTHESIZED_WIRE_49);


b2v_inst71 : register_file
PORT MAP(clock => clock,
		 enable => SYNTHESIZED_WIRE_99,
		 dest => SYNTHESIZED_WIRE_100,
		 src1 => SYNTHESIZED_WIRE_97,
		 src2 => SYNTHESIZED_WIRE_98,
		 val_in => SYNTHESIZED_WIRE_101,
		 val1 => SYNTHESIZED_WIRE_47,
		 val2 => SYNTHESIZED_WIRE_48);


b2v_inst8 : rom
PORT MAP(index => SYNTHESIZED_WIRE_94,
		 instruction => SYNTHESIZED_WIRE_28);


b2v_inst9 : decoder
PORT MAP(reset => reset,
		 clock => clock,
		 index => SYNTHESIZED_WIRE_92,
		 instruction => SYNTHESIZED_WIRE_93,
		 jump => SYNTHESIZED_WIRE_5,
		 use_RAM_index => SYNTHESIZED_WIRE_6,
		 use_reg_imm => SYNTHESIZED_WIRE_7,
		 RAM_enable => SYNTHESIZED_WIRE_8,
		 use_src2 => SYNTHESIZED_WIRE_9,
		 valid => SYNTHESIZED_WIRE_10,
		 use_ALU => SYNTHESIZED_WIRE_11,
		 conditions => SYNTHESIZED_WIRE_16,
		 dest => SYNTHESIZED_WIRE_17,
		 immediate => SYNTHESIZED_WIRE_24,
		 jump_index => SYNTHESIZED_WIRE_21,
		 next_index => SYNTHESIZED_WIRE_20,
		 operation => SYNTHESIZED_WIRE_4,
		 RAM_read_index => SYNTHESIZED_WIRE_23,
		 RAM_write_index => SYNTHESIZED_WIRE_22,
		 src1 => SYNTHESIZED_WIRE_19,
		 src2 => SYNTHESIZED_WIRE_18);


END bdf_type;