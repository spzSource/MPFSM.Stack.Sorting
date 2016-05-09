library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM is
	port (
		clk: in std_logic;
		read_write: in std_logic;
		address: in std_logic_vector(5 downto 0);
		data_input: in std_logic_vector (7 downto 0);
		data_output: out std_logic_vector (7 downto 0)
	);
end MRAM;

architecture MRAM_Beh of MRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type tRAM is array (0 to 63) of byte;
	signal RAM: tRAM:= (
		"00000101",                     -- 5	a[0]  	
		"00000011",                     -- 3	a[1]
		"00000001",                     -- 1	a[2]
		"00000100",                     -- 4	a[3]
		"00000000",                     -- 0	a[4]  [-]
		"00000011",                     -- 3    a[5]  outer loop: max index value
		"00000100",                     -- 4	a[6]  inner loop: max index value
		"00000000",                     -- 0	a[7]  outer loop: current index
		"00000000",                     -- 0	a[8]  inner loop: current index    
		"00000001",                     -- 1	a[9]  constant one = 1	  
		"00000000",                     -- 0    a[10] constant zero = 0
		"00000000",                     -- 0    a[11] reserved cell (temp 1)
		"00000000",                     -- 0   	a[12] reserved cell (temp 2) 
		"00000000",						-- 0    a[13] reserved cell (temp 3)
		others => "00000000"
	);
	signal input: byte;
	signal output: byte;
Begin
	input <= data_input;
	
	WRITE: process (clk, read_write, address, input)
	begin
		if (read_write = '0') then
			if (rising_edge(clk)) then
				RAM(conv_integer(address)) <= input;
			 end if;
		end if;
	end process; 
	
	output <= RAM (conv_integer(address));
	
	RDP: process (read_write, RAM, output)
	begin
		if (read_write = '1') then
			data_output <= output;
		else
			data_output <= (others => 'Z');
		end if;
	end process;
end MRAM_Beh;