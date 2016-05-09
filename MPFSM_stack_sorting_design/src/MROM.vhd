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
	subtype ram_address is std_logic_vector(5 downto 0);

	subtype instrunction_t is std_logic_vector(9 downto 0);
	type ROM_t is array (0 to 63) of instrunction_t;
	
	constant I_ADDR_MAX      : ram_address := "000101";
	constant J_ADDR_MAX      : ram_address := "000110";
	constant I_ADDR          : ram_address := "000111";
	constant J_ADDR          : ram_address := "001000";

	constant ONE_ADDR        : ram_address := "001001";
	constant ZERO_ADDR       : ram_address := "001010";

	constant TEMP_1_ADDR     : ram_address := "001011";
	constant TEMP_2_ADDR     : ram_address := "001100";
	constant TEMP_3_ADDR     : ram_address := "001101";

	constant Z_ADDR          : ram_address := "111111";
	
	constant ROM: ROM_t :=(
		PUSH_OP   & "000001",
		PUSH_OP   & "000000",
		others => HALT_OP & "000000"
	);
	signal data: instrunction_t;
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