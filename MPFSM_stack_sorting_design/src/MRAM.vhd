library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM is
	port (
		CLK: in std_logic;
		RW: in std_logic;
		ADDR: in std_logic_vector(5 downto 0);
		DIN: in std_logic_vector (7 downto 0);
		DOUT: out std_logic_vector (7 downto 0)
	);
end MRAM;

architecture Beh_Sorting of MRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type tRAM is array (0 to 63) of byte;
	signal RAM: tRAM:= (
	--        BIN |	DEC   | ADR BIN | ADR DEC | Meaninng
		"00000011", -- 3  | 000000	|     0   | a[0]
		"00000001", -- 1  | 000001  |     1   | a[1]
		"00000111", -- 7  | 000010	|     2   | a[2]
		"00010011", -- 19 | 000011  |     3   | a[3]
		"00000000", -- 0  | 000100  |     4   | [empty]
		"00000000", -- 0  | 000101	|     5   | [empty]
		"00000000", -- 0  | 000110  |     6   | [empty]
		"00000000", -- 0  | 000111  |     7   | [empty]
		"00000000", -- 0  | 001000  |     8   | [empty]
		"00000000", -- 0  | 001001  |     9   | [empty]
		"00000100", -- 4  | 001010  |    10   | array length
		"00000011", -- 3  | 001011  |    11   | outer loop length [array length - 1]
		"00000000", -- 0  | 001100	|    12   | i: outer loop index [address for array element] [for (int i = 0; i < outer loop index; ++i)]
		"00000000", -- 0  | 001101  |    13   | j: inner loop index [address for array element]	[for (int j = i + 1; j < array length; ++j)]
		"00000001", -- 1  | 001110  |    14   | 1 for add
		"00000000", -- 0  | 001111	|    15	  | 0 for initialization
		"00000000", -- 0  | 010000  |    16   | temp1
		"00000000", -- 0  | 010001  |    17   | temp2
		"00000000", -- 0  | 010010  |    18   | temp3
		others => "00000000"
	);
	signal data_in: byte;
	signal data_out: byte;
Begin
	data_in <= Din;
	
	WRITE: process (CLK, RW, ADDR, data_in)
	begin
		if (RW = '0') then
			if (rising_edge(CLK)) then
				RAM(conv_integer(ADDR)) <= data_in;
			 end if;
		end if;
	end process; 
	
	data_out <= RAM (conv_integer(ADDR));
	
	RDP: process (RW, RAM, data_out)
	begin
		if (RW = '1') then
			DOUT <= data_out;
		else
			DOUT <= (others => 'Z');
		end if;
	end process;
end Beh_Sorting;