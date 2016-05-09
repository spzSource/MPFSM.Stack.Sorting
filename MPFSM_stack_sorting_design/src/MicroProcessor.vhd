library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MicroProcessor is
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		start : in  std_logic;
		stop  : out std_logic
	);
end MicroProcessor;

architecture Beh of MicroProcessor is
	component MROM is
		port(
			read_enabled : in  std_logic;
			address      : in  std_logic_vector(5 downto 0);
			data_out     : out std_logic_vector(9 downto 0)
		);
	end component;

	component MRAM is
		port(
			clk  : in  std_logic;
			read_write   : in  std_logic;
			address : in  std_logic_vector(5 downto 0);
			data_input  : in  std_logic_vector(7 downto 0);
			data_output : out std_logic_vector(7 downto 0)
		);
	end component;

	component DPATH is
		port(
			EN   : in  std_logic;
			-- synchronization
			CLK  : in  std_logic;
			-- operation type
			OT   : in  std_logic_vector(3 downto 0);
			-- operand
			OP   : in  std_logic_vector(7 downto 0);
			-- result
			RES  : out std_logic_vector(7 downto 0);
			-- zero flag
			ZF   : out std_logic;
			-- significant bit set flag
			SBF  : out std_logic;
			-- stop - the processing is finished
			Stop : out std_logic
		);
	end component;

	component Controller is
		port(
		clk, rst, start: in std_logic;
		Stop: out std_logic;
		
		rom_read_enabled: out std_logic;
		rom_address: out std_logic_vector(5 downto 0);
		rom_data_output: in std_logic_vector(9 downto 0);

		ram_read_write: out std_logic;
		ram_address: out std_logic_vector(5 downto 0);
		ram_data_input: out std_logic_vector(7 downto 0);
		ram_data_output: in std_logic_vector(7 downto 0);
		
		datapath_operand: out std_logic_vector(7 downto 0);
		datapath_operation: out std_logic_vector(3 downto 0);
		datapath_enabled: out std_logic;
		datapath_result: in std_logic_vector(7 downto 0);
		datapath_sign_bit_set: in std_logic;
		datapath_zero_flag: in std_logic;
		datapath_stop: in std_logic
	);
	end component;

	signal rom_read_enabled : std_logic;
	signal rom_address      : std_logic_vector(5 downto 0);
	signal rom_data_out     : std_logic_vector(9 downto 0);
	signal ram_rw           : std_logic;
	signal ram_addr         : std_logic_vector(5 downto 0);
	signal ram_din          : std_logic_vector(7 downto 0);
	signal ram_dout         : std_logic_vector(7 downto 0);
	signal dp_op            : std_logic_vector(7 downto 0);
	signal dp_ot            : std_logic_vector(3 downto 0);
	signal dp_en            : std_logic;
	signal dp_res           : std_logic_vector(7 downto 0);
	signal dp_zf            : std_logic;
	signal dp_sbf           : std_logic;
	signal dp_stop          : std_logic;
begin
	UMRAM : MRAM
		port map(
			clk  => CLK,
			read_write   => ram_rw,
			address => ram_addr,
			data_input  => ram_din,
			data_output => ram_dout
		);
	UMROM : entity MROM(Beh_Stack)
		port map(
			read_enabled => rom_read_enabled,
			address      => rom_address,
			data_out     => rom_data_out
		);
	UDPATH : DPATH
		port map(
			EN   => dp_en,
			CLK  => CLK,
			OT   => dp_ot,
			OP   => dp_op,
			RES  => dp_res,
			ZF   => dp_zf,
			SBF  => dp_sbf,
			STOP => dp_stop
		);
	UCTRL1 : Controller
		port map(
			clk      => CLK,
			rst      => RST,
			start    => Start,
			Stop     => STOP,
			rom_read_enabled   => rom_read_enabled,
			rom_address => rom_address,
			rom_data_output => rom_data_out,
			ram_read_write   => ram_rw,
			ram_address => ram_addr,
			ram_data_input  => ram_din,
			ram_data_output => ram_dout,
			datapath_enabled    => dp_en,
			datapath_operation    => dp_ot,
			datapath_operand    => dp_op,
			datapath_result   => dp_res,
			datapath_zero_flag    => dp_zf,
			datapath_sign_bit_set   => dp_sbf,
			datapath_stop  => dp_stop
		);
end Beh;
