library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use commands.all;

entity Controller is
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
end Controller;

architecture Controller_Beh of Controller is
	type states is (
		IDLE, 
		FETCH, 
		DECODE, 
		READ, 
		STORE, 
		HALT, 
		JUMP_IF_NOT_SIGN_BIT, 
		READ_INDIRECT, 
		LOAD_INDIRECT, 
		JUMP_IF_ZERO, 
		DP_ACCEPT, 
		DP_WAIT
	);

	signal next_state, current_state: states;

	signal RI: std_logic_vector(9 downto 0);
	signal IC: std_logic_vector(5 downto 0);
	signal RO: std_logic_vector(3 downto 0);
	signal RA: std_logic_vector(5 downto 0);
	signal RD: std_logic_vector(7 downto 0);
begin
	FSM: process(clk, rst, next_state)
	begin
		if (rst = '1') then
			current_state <= IDLE;
		elsif rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;

	COMB: process(current_state, start, RO, datapath_stop)
	begin
		case current_state is 
			when IDLE => 
				if (start = '1') then 
					next_state <= FETCH;
				else
					next_state <= IDLE;
				end if;
			when FETCH => next_state <= DECODE;
			when DECODE => 
				if (RO = HALT_OP) then
					next_state <= HALT;
				elsif (RO = ADD_OP) then
					next_state <= DP_ACCEPT;
				elsif (RO = SUB_OP) then
					next_state <= DP_ACCEPT;
				elsif (RO = POP_OP) then
					next_state <= DP_ACCEPT;
				elsif (RO = JZ_OP) then
					next_state <= JUMP_IF_ZERO;
				elsif (RO = JNSB_OP) then
					next_state <= JUMP_IF_NOT_SIGN_BIT;
				else
					next_state <= READ;
				end if;
			when READ => 
				if (RO = PUSH_OP) then 
					next_state <= DP_ACCEPT;
				elsif (RO = PUSHI_OP) then
					next_state <= LOAD_INDIRECT;
				elsif (RO = POPI_OP) then
					next_state <= LOAD_INDIRECT;
				else
					next_state <= IDLE;
				end if;
			when LOAD_INDIRECT =>
				if (RO = PUSHI_OP) then
					next_state <= READ_INDIRECT;
				else
					next_state <= DP_ACCEPT;
				end if;
			when READ_INDIRECT => next_state <= DP_ACCEPT;
			when DP_ACCEPT => next_state <= DP_WAIT;
			when DP_WAIT =>
				if (datapath_stop = '0') then
					next_state <= DP_WAIT;
				else
					if (RO = POP_OP) then
						next_state <= STORE;
					elsif (RO = POPI_OP) then
						next_state <= STORE;
					else
						next_state <= FETCH;
					end if;
				end if;
			when STORE | JUMP_IF_NOT_SIGN_BIT | JUMP_IF_ZERO => next_state <= FETCH;
			when HALT => next_state <= HALT;
			when others => next_state <= IDLE;
		end case;
	end process;
	
	PSTOP: process (current_state)
	begin
		if (current_state = HALT) then
			stop <= '1';
		else
			stop <= '0';
		end if;
	end process;
	
	PMC: process (clk, rst, current_state)
	begin
		if (rst = '1') then
			IC <= "000000";
		elsif falling_edge(clk) then
			if (current_state = DECODE) then
				IC <= IC + 1;
			elsif (current_state = JUMP_IF_ZERO and datapath_zero_flag = '1') then
				IC <= RA;
			elsif (current_state = JUMP_IF_NOT_SIGN_BIT and datapath_sign_bit_set = '0') then
				IC <= RA;
			end if;
		end if;
	end process;
	
	rom_address <= IC;
	
	PROMREAD: process (next_state, current_state)
	begin
		if (next_state = FETCH or current_state = FETCH) then
			rom_read_enabled <= '1';
		else
			rom_read_enabled <= '0';
		end if;
	end process;
	
	PROMDAT: process (rst, current_state, rom_data_output)
	begin
		if (rst = '1') then
			RI <= (others => '0');
		elsif (current_state = FETCH) then
			RI <= rom_data_output;
		end if;
	end process;
	
	PRORA: process (rst, next_state, RI)
	begin
		if (rst = '1') then
			RO <= (others => '0');
			RA <= (others => '0');
		elsif (next_state = DECODE) then
			RO <= RI (9 downto 6);
			RA <= RI (5 downto 0);
		elsif (next_state = LOAD_INDIRECT) then
			RA <= RD (5 downto 0);
		end if;
	end process;
	
	PRAMST: process (RA)
	begin
		if (current_state /= JUMP_IF_NOT_SIGN_BIT and current_state /= JUMP_IF_ZERO) then
			ram_address <= RA;
		end if;
	end process;
	
	PRAMREAD: process (current_state)
	begin
		if (current_state = STORE) then
			ram_read_write <= '0';
		else
			ram_read_write <= '1';
		end if;
	end process;
	
	PRAMDAR: process (current_state)
	begin
		if (current_state = READ or current_state = READ_INDIRECT) then
			RD <= ram_data_output;
		end if;
	end process;
	
	ram_data_input <= datapath_result;
	datapath_operand <= RD;
	datapath_operation <= RO;
	
	pdpathen: process (current_state)
	begin
		if (current_state = DP_ACCEPT) then
			datapath_enabled <= '1';
		else
			datapath_enabled <= '0';
		end if;
	end process;
end Controller_Beh;