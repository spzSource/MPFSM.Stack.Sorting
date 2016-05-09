library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use commands.all;

entity MROM is 
	port (
		read_enabled: in std_logic;
		address: in std_logic_vector(5 downto 0);
		data_out: out std_logic_vector(9 downto 0)
	);
end MROM;

architecture Beh_Stack of MROM is
	subtype inst is std_logic_vector(9 downto 0);
	type tROM is array (0 to 63) of inst;
	
	constant EMPTY_ADDR: std_logic_vector(5 downto 0) := "111111";
	constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
	constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
	constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
	constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
	constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
	constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
	constant ADDR_TEMP1: std_logic_vector(5 downto 0) := "010000";
	constant ADDR_TEMP2: std_logic_vector(5 downto 0) := "010001";
	constant ADDR_TEMP3: std_logic_vector(5 downto 0) := "010010";
	
	constant ROM: tROM :=(
	--  OP CODE   | RAM ADDR       |   N BIN       | N DEC  | Info	
	PUSH_OP   & "000001",
	PUSH_OP   & "000000",
	--	OP_PUSH   & ADDR_ZERO,     --  000000	   | 000    |
--		OP_POP    & ADDR_I,        --  000001      | 001    |
--		OP_PUSH   & ADDR_ZERO,     --  000010      | 002    |
--		OP_POP    & ADDR_J,        --  000011      | 003    |
--	--  Start: outer loop
--		OP_PUSH   & ADDR_I,        --  000100      | 004	| m2: [Start outer loop]
--		OP_PUSH   & ADDR_LENGTH_1, --  000101      | 005    |
--		OP_SUB    & EMPTY_ADDR,    --  000110      | 006    | 
--		OP_JZ     & "101110",      --  000111      | 007    | jump to m1 [if i == length - 1 - finish outer loop]
--	--  Start: inner loop
--		OP_PUSH   &	ADDR_ONE,      --  001000      | 008    |
--		OP_PUSH   & ADDR_I,        --  001001      | 009    |
--		OP_ADD    & EMPTY_ADDR,    --  001010      | 010    | 
--		OP_POP    & ADDR_J,        --  001011      | 011    | j = i + 1
--		OP_PUSH   & ADDR_J,        --  001100      | 012    | m4: [Start inner loop]
--		OP_PUSH   & ADDR_LENGTH,   --  001101      | 013    |
--		OP_SUB    & EMPTY_ADDR,    --  001110      | 014    |
--		OP_JZ     & "101000",      --  001111      | 015    | jump to m3
--		
--		OP_PUSHIN & ADDR_J,        --  010000      | 016    |
--		OP_POP    & ADDR_TEMP1,    --  010001      | 017    | temp1 stores value for arr[j]
--		OP_PUSHIN & ADDR_I,        --  010010      | 018    |
--		OP_POP    & ADDR_TEMP2,    --  010011      | 019    | temp2 stores value for arr[i]
--			
--		OP_PUSH   & ADDR_TEMP1,    --  010100      | 020    |
--		OP_PUSH   & ADDR_TEMP2,    --  010101      | 021    |
--		OP_SUB    & EMPTY_ADDR,    --  010110      | 022    | arr[i] - arr[j]
--		OP_JNSB   & "011110",      --  010111      | 023    | jump to m5
--	--  Swap values
--	    OP_PUSH   & ADDR_TEMP1,    --  011000      | 024    |
--		OP_POP    & ADDR_TEMP3,    --  011001      | 025    | temp3 = temp1
--		OP_PUSH   & ADDR_TEMP2,    --  011010      | 026    |
--		OP_POP    & ADDR_TEMP1,    --  011011      | 027    | temp1 = temp2
--		OP_PUSH   & ADDR_TEMP3,    --  011100      | 028    |
--		OP_POP    & ADDR_TEMP2,    --  011101      | 029    | temp2 = temp3
--	--  End swap	
--		OP_PUSH   & ADDR_TEMP1,    --  011110      | 030    | m5
--		OP_POPIN  & ADDR_J,        --  011111      | 031    | arr[j] = temp1
--		OP_PUSH   & ADDR_TEMP2,    --  100000      | 032    |
--		OP_POPIN  & ADDR_I,        --  100001      | 033    | arr[i] = temp2
--		
--		OP_PUSH   & ADDR_ONE,      --  100010      | 034    | [Start j++]
--		OP_PUSH   & ADDR_J,        --  100011      | 035    |
--		OP_ADD    & EMPTY_ADDR,    --  100100      | 036    |
--		OP_POP    & ADDR_J,        --  100101      | 037    | [End j++]
--		
--		OP_PUSH   & ADDR_ZERO,     --  100110      | 038    |
--		OP_JZ     & "001100",      --  100111      | 039    | go to m4: [End inner loop]
--	--  End: inner loop
--		OP_PUSH   & ADDR_ONE,      --  101000      | 040    | m3: [Start i++]
--		OP_PUSH   & ADDR_I,        --  101001      | 041    |
--		OP_ADD    & EMPTY_ADDR,    --  101010      | 042    |
--	    OP_POP    & ADDR_I,        --  101011      | 043    | [End i++]
--	
--		OP_PUSH   & ADDR_ZERO,     --  101100      | 044    |
--		OP_JZ     & "000100",      --  101101      | 045    | go to m2
--	--  End: outer loop
--		OP_PUSH   & ADDR_I,        --  101110      | 046    | m1
		others => HALT_OP & "000000"
	);
	signal data: inst;
begin
	data <= ROM(conv_integer(address));
	
	zbufs: process (read_enabled, data)
	begin
		if (read_enabled = '1') then
			data_out <= data;
		else
			data_out <= (others => 'Z');
		end if;
	end process;
end Beh_Stack;