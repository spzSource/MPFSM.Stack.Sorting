library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Stack is
	generic(
		DATA_SIZE    : integer := 8;
		ADDRESS_SIZE : integer := 8
	);

	--
	-- read_write: 0 - write, 1 - read
	--
	port(
		clk             : in  std_logic;
		enabled         : in  std_logic;
		read_write      : in  std_logic;
		write_data_port : in  std_logic_vector(DATA_SIZE - 1 downto 0);
		read_data_port  : out std_logic_vector(DATA_SIZE - 1 downto 0)
	);
end entity Stack;

architecture Stack_behavioural of Stack is
	subtype ram_data is std_logic_vector(DATA_SIZE - 1 downto 0);
	type ram_t is array (0 to 2 ** ADDRESS_SIZE - 1) of ram_data;

	signal head       : integer := 0;
	signal ram        : ram_t;
	signal read_data  : ram_data;
	signal write_data : ram_data;

begin
	HEAD_CONTROL : process(clk) is
	begin
		if (enabled = '1') then
			if rising_edge(clk) then
				if (read_write = '0') then -- write
					head <= head + 1;
				elsif (read_write = '1') then -- read
					head <= head - 1;
				end if;
			end if;
		end if;
	end process HEAD_CONTROL;

	SWRITE : process(clk, head, write_data) is
	begin
		if (enabled = '1') then
			if rising_edge(clk) then
				if (read_write = '0') then
					ram(head) <= write_data;
				end if;
			end if;
		end if;
	end process SWRITE;

	SREAD : process(clk, head) is
	begin
		if (enabled = '1') then
			if rising_edge(clk) then
				if (read_write = '1') then
					read_data <= ram(head - 1);
				end if;
			end if;
		end if;
	end process SREAD;

	write_data     <= write_data_port;
	read_data_port <= read_data;

end architecture Stack_behavioural;

