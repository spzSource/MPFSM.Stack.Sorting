library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity microprocessor_tb is
end microprocessor_tb;

architecture TB_ARCHITECTURE of microprocessor_tb is
	-- Component declaration of the tested unit
	component MicroProcessor
	port(
		clk : in STD_LOGIC;
		rst : in STD_LOGIC;
		start : in STD_LOGIC;
		stop : out STD_LOGIC );
	end component;


	signal clk   : STD_LOGIC := '0';
	signal rst   : STD_LOGIC := '0';
	signal start : STD_LOGIC := '0';
	signal stop  : STD_LOGIC := '0';

	constant CLK_PERIOD : time := 10 ns;
	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : MicroProcessor
		port map (
			clk => clk,
			rst => rst,
			start => start,
			stop => stop
		);

	CLK_P : process
	begin
		clk <= '0';
		wait for CLK_PERIOD / 2;
		clk <= '1';
		wait for CLK_PERIOD / 2;
	end process;

	MAIN_P : process
	begin
		rst <= '1';
		wait for CLK_PERIOD;
		rst   <= '0';
		start <= '1';
		wait for 100 * CLK_PERIOD;
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_microprocessor of microprocessor_tb is
	for TB_ARCHITECTURE
		for UUT : MicroProcessor
			use entity work.microprocessor(Beh);
		end for;
	end for;
end TESTBENCH_FOR_microprocessor;

