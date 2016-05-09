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

	component CTRL1 is
		port(
			CLK, RST, Start : in  std_logic;
			Stop            : out std_logic;

			-- ROM
			ROM_re          : out std_logic;
			ROM_addr        : out std_logic_vector(5 downto 0);
			ROM_dout        : in  std_logic_vector(9 downto 0);

			-- RAM
			RAM_rw          : out std_logic;
			RAM_addr        : out std_logic_vector(5 downto 0);
			RAM_din         : out std_logic_vector(7 downto 0);
			RAM_dout        : in  std_logic_vector(7 downto 0);

			--datapath
			DP_op           : out std_logic_vector(7 downto 0);
			DP_ot           : out std_logic_vector(3 downto 0);
			DP_en           : out std_logic;
			DP_res          : in  std_logic_vector(7 downto 0);
			DP_sbf          : in  std_logic;
			DP_zf           : in  std_logic;
			DP_stop         : in  std_logic
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
	UCTRL1 : CTRL1
		port map(
			CLK      => CLK,
			RST      => RST,
			START    => Start,
			STOP     => STOP,
			ROM_re   => rom_read_enabled,
			ROM_addr => rom_address,
			ROM_dout => rom_data_out,
			RAM_rw   => ram_rw,
			RAM_addr => ram_addr,
			RAM_din  => ram_din,
			RAM_dout => ram_dout,
			DP_en    => dp_en,
			DP_ot    => dp_ot,
			DP_op    => dp_op,
			DP_res   => dp_res,
			DP_zf    => dp_zf,
			DP_sbf   => dp_sbf,
			DP_stop  => dp_stop
		);
end Beh;
