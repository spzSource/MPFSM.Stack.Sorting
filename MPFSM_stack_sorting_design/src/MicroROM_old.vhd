library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use commands.all;

entity MicroROM is
	port(
		read_enable : in  std_logic;
		address     : in  std_logic_vector(5 downto 0);
		data_output : out std_logic_vector(9 downto 0)
	);
end MicroROM;

architecture MicroROM_Behaviour of MicroROM is
	
	subtype ram_address is std_logic_vector(5 downto 0);
	
	--
	-- predefined addresses
	--
	constant OUTER_MAX_ADDR   : ram_address := "000101";
	constant INNER_MAX_ADDR   : ram_address := "000110";
	constant OUTER_INDEX_ADDR : ram_address := "000111";
	constant INNER_INDEX_ADDR : ram_address := "001000";
	
	constant ONE_ADDR         : ram_address := "001001";
	constant ZERO_ADDR        : ram_address := "001010";
	
	constant TEMP_1			  : ram_address := "001011";
	constant TEMP_2			  : ram_address := "001100";

	--
	-- type and sub-types declarations
	--
	subtype instruction_subType is std_logic_vector(9 downto 0);
	type ROM_type is array (0 to 63) of instruction_subType;

	--
	-- Represents the set of instructions as read only (constant) memory.
	--
	constant ROM : ROM_type := (
		PUSH_OP & "000000",
		PUSH_OP & "000001",	   
		PUSH_OP & "000001",
		others => HALT_OP & "000000"
	);

	signal data : instruction_subType;
begin
	--
	-- Move instruction to the output by specified address
	-- 
	data <= ROM(CONV_INTEGER(address));

	TRISTATE_BUFFERS : process(read_enable, data)
	begin
		if (read_enable = '1') then
			data_output <= data;
		else
			data_output <= (others => 'Z');
		end if;
	end process;

end MicroROM_Behaviour;

		