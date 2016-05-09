library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MicroProcessor is
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		start : in  std_logic;
		stop  : out std_logic
	);
end MicroProcessor;

architecture MicroProcessor_Behavioural of MicroProcessor is
	component MicroROM is
		port(
			read_enable : in  std_logic;
			address     : in  std_logic_vector(5 downto 0);
			data_output : out std_logic_vector(9 downto 0)
		);
	end component;

	component DataRAM is
			port(
				read_write  : in  std_logic;
				address     : in  std_logic_vector(5 downto 0);
				data_input  : in  std_logic_vector(7 downto 0);
				data_output : out std_logic_vector(7 downto 0)
			);
		end component;

	component DataPath is 
		port(
			EN: in std_logic;
			-- synchronization
			CLK: in std_logic;
			-- operation type
			OT: in std_logic_vector(3 downto 0);
			-- operand
			OP: in std_logic_vector(7 downto 0);
			-- result
			RES: out std_logic_vector(7 downto 0);
			-- zero flag
			ZF: out std_logic;
			-- significant bit set flag
			SBF: out std_logic;
			-- stop - the processing is finished
			Stop: out std_logic
		);
	end component;

	component Controller is
		port(
			clk                     : in  std_logic;
			rst                     : in  std_logic;
			start                   : in  std_logic;
			stop                    : out std_logic;
			rom_enabled             : out std_logic;
			rom_address             : out std_logic_vector(5 downto 0);
			rom_data_output         : in  std_logic_vector(9 downto 0);
			ram_read_write          : out std_logic;
			ram_address             : out std_logic_vector(5 downto 0);
			ram_data_input          : out std_logic_vector(7 downto 0);
			ram_data_output         : in  std_logic_vector(7 downto 0);
			datapath_operand        : out std_logic_vector(7 downto 0);
			datapath_operation_code : out std_logic_vector(3 downto 0);
			datapath_enabled        : out std_logic;
			datapath_result         : in  std_logic_vector(7 downto 0);
			datapath_zero_flag      : in  std_logic;
			datapath_sign_bit_flag  : in  std_logic;
			datapath_stop           : in std_logic
		);
	end component;

	signal mp_ram_read_write  : std_logic;
	signal mp_ram_address     : std_logic_vector(5 downto 0);
	signal mp_ram_data_input  : std_logic_vector(7 downto 0);
	signal mp_ram_data_output : std_logic_vector(7 downto 0);

	signal mp_rom_read_enable : std_logic;
	signal mp_rom_address     : std_logic_vector(5 downto 0);
	signal mp_rom_data_output : std_logic_vector(9 downto 0);

	signal mp_datapath_enabled              : std_logic;
	signal mp_datapath_operation_code       : std_logic_vector(3 downto 0);
	signal mp_datapath_operand              : std_logic_vector(7 downto 0);
	signal mp_datapath_result               : std_logic_vector(7 downto 0);
	signal mp_datapath_zero_flag            : std_logic;
	signal mp_datapath_significant_bit_flag : std_logic;  
	signal mp_datapath_stop                 : std_logic;

begin
	U_RAM : entity DataRAM port map(
			read_write  => mp_ram_read_write,
			address     => mp_ram_address,
			data_input  => mp_ram_data_input,
			data_output => mp_ram_data_output
		);

	U_ROM : entity MicroROM port map(
			read_enable => mp_rom_read_enable,
			address     => mp_rom_address,
			data_output => mp_rom_data_output
		);
	U_DATAPATH : DataPath  
		port map(			
			CLK 				 => clk,
			EN              => mp_datapath_enabled,
			OT       => mp_datapath_operation_code,
			OP              => mp_datapath_operand,
			RES               => mp_datapath_result,
			ZF            => mp_datapath_zero_flag,
			SBF => mp_datapath_significant_bit_flag,
			Stop                 => mp_datapath_stop);		
			
	U_CONTROLLER : Controller port map(
			clk                     => clk,
			rst                     => rst,
			start                   => start,
			stop                    => stop,
			rom_enabled             => mp_rom_read_enable,
			rom_address             => mp_rom_address,
			rom_data_output         => mp_rom_data_output,
			ram_read_write          => mp_ram_read_write,
			ram_address             => mp_ram_address,
			ram_data_input          => mp_ram_data_input,
			ram_data_output         => mp_ram_data_output,
			datapath_operand        => mp_datapath_operand,
			datapath_operation_code => mp_datapath_operation_code,
			datapath_enabled        => mp_datapath_enabled,
			datapath_result         => mp_datapath_result,
			datapath_zero_flag      => mp_datapath_zero_flag,
			datapath_sign_bit_flag  => mp_datapath_significant_bit_flag,
			datapath_stop           => mp_datapath_stop
		);

end MicroProcessor_Behavioural;

		