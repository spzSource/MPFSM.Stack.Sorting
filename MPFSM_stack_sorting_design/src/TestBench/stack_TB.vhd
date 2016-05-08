library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity stack_tb is
	generic(
		DATA_SIZE    : INTEGER := 8;
		ADDRESS_SIZE : INTEGER := 8);
end stack_tb;

architecture TB_ARCHITECTURE of stack_tb is
	component stack
		generic(
			DATA_SIZE    : INTEGER := 8;
			ADDRESS_SIZE : INTEGER := 8);
		port(
			clk             : in  STD_LOGIC;
			enabled         : in  STD_LOGIC;
			read_write      : in  STD_LOGIC;
			write_data_port : in  STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);
			read_data_port  : out STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0));
	end component;

	signal clk             : STD_LOGIC;
	signal enabled         : STD_LOGIC;
	signal read_write      : STD_LOGIC;
	signal write_data_port : STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);
	signal read_data_port  : STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);

begin
	UUT : stack
		generic map(
			DATA_SIZE    => DATA_SIZE,
			ADDRESS_SIZE => ADDRESS_SIZE
		)
		port map(
			clk             => clk,
			enabled         => enabled,
			read_write      => read_write,
			write_data_port => write_data_port,
			read_data_port  => read_data_port
		);

	CLK_Process : process
	begin
		CLK <= '0';
		wait for 10 ns;
		CLK <= '1';
		wait for 10 ns;
	end process;

	main : process
	begin
		enabled <= '1';

		wait for 20 ns;
		read_write      <= '0';
		write_data_port <= "00000011";
		wait for 20 ns;
		write_data_port <= "00000010";
		wait for 20 ns;
		write_data_port <= "00000001";
		wait for 20 ns;

		read_write <= '1';
		wait for 20 ns;
		wait for 20 ns;
		wait for 20 ns;
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_stack of stack_tb is
	for TB_ARCHITECTURE
		for UUT : stack
			use entity work.stack(stack_behavioural);
		end for;
	end for;
end TESTBENCH_FOR_stack;

