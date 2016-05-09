library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use commands.all;

entity Datapath is
	port(
		enabled: in std_logic;
		clk: in std_logic;
		operation: in std_logic_vector(3 downto 0);
		operation_parameter: in std_logic_vector(7 downto 0);
		result: out std_logic_vector(7 downto 0);
		zero_flag: out std_logic;
		sign_bit_flag: out std_logic;
		Stop: out std_logic
	);
end Datapath;

architecture Datapath_Beh of Datapath is
	component Stack
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
	end component;
	

	type states is (
		IDLE, 
		POP_FIRST, 
		POP_SECOND, 
		ADD, 
		SUB, 
		PUSH, 
		MOV_POP, 
		MOV_PUSH, 
		HALT);

	signal next_state, current_state: states;

	signal operation_result: std_logic_vector(7 downto 0);
	signal operand: std_logic_vector(7 downto 0);
	signal first_operand: std_logic_vector(7 downto 0);
	signal second_operand: std_logic_vector(7 downto 0);
	signal dp_result: std_logic_vector(7 downto 0);
	
	signal datapath_enabled: std_logic;
	signal datapath_write_data_port: std_logic;
	signal datapath_result: std_logic_vector(7 downto 0);
	signal datapath_read_data_port: std_logic_vector(7 downto 0);
	
	signal dp_sign_bit_flag, dp_zero_flag: std_logic;
Begin
	USTACK: Stack
		generic map(
			ADDRESS_SIZE => 8,
			DATA_SIZE => 8
		)
		port map(
			clk => clk,
			enabled => datapath_enabled,
			read_write => datapath_write_data_port,
			read_data_port => datapath_result,
			write_data_port => datapath_read_data_port
		);
	
	operand <= operation_parameter;
		
	FSM: process(clk, next_state)
	begin
		if rising_edge(clk) then
			current_state <= next_state;
		end if;
	end process;
	
	-- Next state
	COMB: process(current_state, enabled, operation)
	begin
		case current_state is 
			when IDLE => 
				if (enabled = '1') then
					if (operation = ADD_OP) then
						next_state <= POP_FIRST;
					elsif (operation = SUB_OP) then
						next_state <= POP_FIRST;
					elsif (operation = POP_OP) then
						next_state <= POP_FIRST;
					elsif (operation = POPI_OP) then
						next_state <= POP_FIRST;
					else
						next_state <= MOV_PUSH;
					end if;
				else
					next_state <= IDLE;
				end if;
			when POP_FIRST =>
				if (operation = POP_OP) then
					next_state <= MOV_POP;
				elsif (operation = POPI_OP) then
					next_state <= MOV_POP;
				else
					next_state <= POP_SECOND;
				end if;
			when POP_SECOND =>
				if (operation = ADD_OP) then
					next_state <= ADD;
				else
					next_state <= SUB;
				end if;
			when ADD | SUB | MOV_PUSH => next_state <= PUSH;
			when MOV_POP => next_state <= HALT;
			when PUSH => next_state <= HALT;
			when HALT => next_state <= IDLE;
			when others => next_state <= IDLE;
		end case;
	end process;
	
		-- stop signal handler
	PSTOP: process (current_state)
	begin
		if (current_state = HALT) then
			stop <= '1';
		else
			stop <= '0';
		end if;
	end process;
	
	STACKCTRL: process (current_state, next_state)
	begin
		if (next_state = POP_FIRST) then
			datapath_write_data_port <= '1';
			datapath_enabled <= '1';
		elsif (next_state = POP_SECOND) then
			datapath_write_data_port <= '1';
			datapath_enabled <= '1';
		elsif (current_state = PUSH) then
			datapath_write_data_port <= '0';
			datapath_enabled <= '1';
		else
			datapath_write_data_port <= '1';
			datapath_enabled <= '0';
		end if;
	end process;
	
	OP1CTRL: process (current_state, datapath_result)
	begin
		if (current_state = POP_FIRST) then
			first_operand <= datapath_result;
		end if;
	end process;
	
	OP2CTRL: process (current_state, datapath_result)
	begin
		if (current_state = POP_SECOND) then
			second_operand <= datapath_result;
		end if;
	end process;
	
	OPRESULTCTRL: process (current_state, first_operand, second_operand, operand)
	begin
		if (current_state = ADD) then
			operation_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(first_operand) + CONV_INTEGER(second_operand), 8);
		elsif (current_state = SUB) then
			operation_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(first_operand) - CONV_INTEGER(second_operand), 8);
		elsif (current_state = MOV_PUSH) then
			operation_result <= operand;
		end if;
	end process;
	
	IRESCTRL: process (current_state, first_operand)
	begin
		if (current_state = MOV_POP) then
			dp_result <= first_operand;
		end if;
	end process;
	
	FLAGS: process(operation_result)
	begin
		if operation_result = (operation_result'range => '0') then
            dp_zero_flag <= '1';
        else
            dp_zero_flag <= '0';
        end if;
		 
		if operation_result(7) = '1' then
			dp_sign_bit_flag <= '1';
		else
			dp_sign_bit_flag <= '0';
		end if;
	end process;
	
	datapath_read_data_port <= operation_result;
	result <= dp_result;
	sign_bit_flag <= dp_sign_bit_flag;
	zero_flag <= dp_zero_flag;
End Datapath_Beh;