--library ieee;
--
--use ieee.numeric_std.all;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;  
--
--use commands.all;
--
--entity DataPath is	
--	generic(
--			DATA_SIZE    : integer := 8;
--			ADDRESS_SIZE : integer := 8
--		);
--	port(
--		clk                  : in  std_logic;
--		enabled              : in  std_logic;
--		operation_code       : in  std_logic_vector(3 downto 0);
--		operand              : in  std_logic_vector(7 downto 0);
--		result               : out std_logic_vector(7 downto 0);
--		zero_flag            : out std_logic;
--		significant_bit_flag : out std_logic;
--		stop                 : out std_logic
--	);
--end entity DataPath;
--
--architecture DataPath_Behavioural of DataPath is
--
--	component Stack
--		generic(
--			DATA_SIZE    : integer := 8;
--			ADDRESS_SIZE : integer := 8
--		);
--
--		port(
--			clk             : in  std_logic;
--			enabled         : in  std_logic;
--			read_write      : in  std_logic;
--			write_data_port : in  std_logic_vector(DATA_SIZE - 1 downto 0);
--			read_data_port  : out std_logic_vector(DATA_SIZE - 1 downto 0)
--		);
--	end component;
--
--	type states is (
--		IDLE,
--		POP_FIRTS,
--		POP_SECOND,
--		ADD,
--		SUB,
--		PUSH,
--		MOV_POP,
--		MOV_PUSH,
--		HALT	
--	);
--
--	signal next_state    : states;
--	signal current_state : states;
--
--	signal operation_result 		: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal first_operand    		: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal second_operand   		: std_logic_vector(DATA_SIZE - 1 downto 0);
--
--	signal datapath_operand 		: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal datapath_result  		: std_logic_vector(DATA_SIZE - 1 downto 0);
--
--	signal dp_enabled 				: std_logic;
--	signal dp_read_write 			: std_logic;
--	signal dp_result 				: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal dp_read_port         	: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal dp_write_port 		   	: std_logic_vector(DATA_SIZE - 1 downto 0);
--	signal dp_zero_flag            	: std_logic;
--	signal dp_significant_bit_flag 	: std_logic;
--
--	
--begin
--	U_STACK : Stack generic map(DATA_SIZE => 8, ADDRESS_SIZE => 8)
--		port map(
--			clk 			=> clk,
--			enabled 		=> dp_enabled,
--			read_write 		=> dp_read_write,
--			read_data_port  => dp_read_port,
--			write_data_port => dp_write_port
--		);
--
--	datapath_operand <= operand;
--
--	FSM: process(clk, next_state)
--	begin
--		if rising_edge(clk) then
--			current_state <= next_state;
--		end if;
--	end process;
--
--	FSM_COMB: process (current_state, enabled, operation_code)
--	begin
--		case current_state is 
--			when IDLE => 
--				if (enabled = '1') then
--					if (operation_code = ADD_OP) then
--						next_state <= POP_FIRTS;
--					elsif (operation_code = SUB_OP) then
--						next_state <= POP_FIRTS;
--					elsif (operation_code = POP_OP) then
--						next_state <= POP_FIRTS;
--					elsif (operation_code = POPI_OP) then
--						next_state <= POP_FIRTS;
--					else
--						next_state <= MOV_PUSH;
--					end if;
--				else
--					next_state <= IDLE;
--				end if;
--			when POP_FIRTS =>
--				if (operation_code = POP_OP) then
--					next_state <= MOV_POP;
--				elsif (operation_code = POPI_OP) then
--					next_state <= MOV_POP;
--				else
--					next_state <= POP_SECOND;
--				end if;
--			when POP_SECOND =>
--				if (operation_code = ADD_OP) then
--					next_state <= ADD;
--				else
--					next_state <= SUB;
--				end if;
--			when ADD | SUB | MOV_PUSH => next_state <= PUSH;
--			when MOV_POP => next_state <= HALT;
--			when PUSH => next_state <= HALT;
--			when HALT => next_state <= IDLE;
--			when others => next_state <= IDLE;
--		end case;
--	end process;
--
--	STOP_P : process (current_state)
--	begin
--		if (current_state = HALT) then
--			stop <= '1';
--		else 
--			stop <= '0';
--		end if;
--	end process;
--
--	DP_CONTROL: process (current_state, next_state)
--	begin
--		if (next_state = POP_FIRTS) then
--			dp_read_write <= '1';
--			dp_enabled <= '1';
--		elsif (next_state = POP_SECOND) then
--			dp_read_write <= '1';
--			dp_enabled <= '1';
--		elsif (next_state = PUSH) then
--			dp_read_write <= '0';
--			dp_enabled <= '1';
--		else
--			dp_read_write <= '1';
--			dp_enabled <= '0';
--		end if;
--	end process;
--	
--	OP1CTRL: process (current_state, dp_read_port)
--	begin
--		if (current_state = POP_FIRTS) then
--			first_operand <= dp_read_port;
--		end if;
--	end process;
--	
--	OP2CTRL: process (current_state, dp_read_port)
--	begin
--		if (current_state = POP_SECOND) then
--			second_operand <= dp_read_port;
--		end if;
--	end process;
--	
--	OPRESULTCTRL: process (current_state, first_operand, second_operand, datapath_operand)
--	begin
--		if (current_state = ADD) then
--			operation_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(first_operand) + CONV_INTEGER(second_operand), 8);
--		elsif (current_state = SUB) then
--			operation_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(first_operand) - CONV_INTEGER(second_operand), 8);
--		elsif (current_state = MOV_PUSH) then
--			operation_result <= datapath_operand;
--		end if;
--	end process;
--	
--	IRESCTRL: process (current_state, first_operand)
--	begin
--		if (current_state = MOV_POP) then
--			datapath_result <= first_operand;
--		end if;
--	end process;
--
--	FLAGS_PROCESS : process(operation_result)
--	begin
--		if operation_result = (operation_result'range => '0') then
--			dp_zero_flag <= '1';
--		else
--			dp_zero_flag <= '0';
--		end if;
--
--		if operation_result(7) = '1' then
--			dp_significant_bit_flag <= '1';
--		else
--			dp_significant_bit_flag <= '0';
--		end if;
--	end process;
--	
--	dp_write_port        <= operation_result;
--	result               <= dp_read_port;
--	zero_flag            <= dp_zero_flag;
--	significant_bit_flag <= dp_significant_bit_flag;
--
--end architecture DataPath_Behavioural;
--
--	 
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use commands.all;

entity DataPath is
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
end DataPath;

architecture Beh_Stack of DataPath is
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
	

	type states is (I, IPOP1, IPOP2, ADD, SUB, IPUSH, MOVERES, MOVERESOP, H);
	-- I - Idle - the initial state for operations
	-- IPOP1 - POP 1 - pop the value and put it into the first internal operand i_op1
	-- IPOP2 - POP 2 - pop the value and put it into the second internal operand i_op2
	-- ADD - res_op = i_op1 + i_op2
	-- SUB - res_op = i_op1 - i_op2
	-- IPUSH - PUSH - push the value of res_op to the stack
	-- MOVERES - i_res = i_op1 - used in external POP operation
	-- MOVERESOP - res_op = i_op - used in external push operation
	-- H - Halt - indicates that the processing has been completed
	signal nxt_state, cur_state: states;
	
	-- operation result
	signal res_op: std_logic_vector(7 downto 0);
	-- internal input operand value
	signal i_op: std_logic_vector(7 downto 0);
	-- internal first operand value
	signal i_op1: std_logic_vector(7 downto 0);
	-- internal second operand value
	signal i_op2: std_logic_vector(7 downto 0);
	-- the result of the data path
	signal i_res: std_logic_vector(7 downto 0);
	
	signal s_en: std_logic;
	signal s_wr: std_logic;
	signal s_res: std_logic_vector(7 downto 0);
	signal s_data: std_logic_vector(7 downto 0);
	
	signal t_sbf, t_zf: std_logic;
Begin
	USTACK: Stack
		generic map(
			DATA_SIZE => 8,
			ADDRESS_SIZE => 8
		)
		port map(
			clk => CLK,
			enabled => s_en,
			read_write => s_wr,
			read_data_port => s_res,
			write_data_port => s_data
		);
	
	i_op <= OP;
		
	FSM: process(CLK, nxt_state)
	begin
		if rising_edge(CLK) then
			cur_state <= nxt_state;
		end if;
	end process;
	
	-- Next state
	COMB: process(cur_state, EN, OT)
	begin
		case cur_state is 
			when I => 
				if (EN = '1') then
					if (OT = ADD_OP) then
						nxt_state <= IPOP1;
					elsif (OT = SUB_OP) then
						nxt_state <= IPOP1;
					elsif (OT = POP_OP) then
						nxt_state <= IPOP1;
					elsif (OT = POPI_OP) then
						nxt_state <= IPOP1;
					else
						nxt_state <= MOVERESOP;
					end if;
				else
					nxt_state <= I;
				end if;
			when IPOP1 =>
				if (OT = POP_OP) then
					nxt_state <= MOVERES;
				elsif (OT = POPI_OP) then
					nxt_state <= MOVERES;
				else
					nxt_state <= IPOP2;
				end if;
			when IPOP2 =>
				if (OT = ADD_OP) then
					nxt_state <= ADD;
				else
					nxt_state <= SUB;
				end if;
			when ADD | SUB | MOVERESOP => nxt_state <= IPUSH;
			when MOVERES => nxt_state <= H;
			when IPUSH => nxt_state <= H;
			when H => nxt_state <= I;
			when others => nxt_state <= I;
		end case;
	end process;
	
		-- stop signal handler
	PSTOP: process (cur_state)
	begin
		if (cur_state = H) then
			stop <= '1';
		else
			stop <= '0';
		end if;
	end process;
	
	STACKCTRL: process (cur_state, nxt_state)
	begin
		if (nxt_state = IPOP1) then
			s_wr <= '1';
			s_en <= '1';
		elsif (nxt_state = IPOP2) then
			s_wr <= '1';
			s_en <= '1';
		elsif (cur_state = IPUSH) then
			s_wr <= '0';
			s_en <= '1';
		else
			s_wr <= '1';
			s_en <= '0';
		end if;
	end process;
	
	OP1CTRL: process (cur_state, s_res)
	begin
		if (cur_state = IPOP1) then
			i_op1 <= s_res;
		end if;
	end process;
	
	OP2CTRL: process (cur_state, s_res)
	begin
		if (cur_state = IPOP2) then
			i_op2 <= s_res;
		end if;
	end process;
	
	OPRESULTCTRL: process (cur_state, i_op1, i_op2, i_op)
	begin
		if (cur_state = ADD) then
			res_op <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(i_op1) + CONV_INTEGER(i_op2), 8);
		elsif (cur_state = SUB) then
			res_op <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(i_op1) - CONV_INTEGER(i_op2), 8);
		elsif (cur_state = MOVERESOP) then
			res_op <= i_op;
		end if;
	end process;
	
	IRESCTRL: process (cur_state, i_op1)
	begin
		if (cur_state = MOVERES) then
			i_res <= i_op1;
		end if;
	end process;
	
	FLAGS: process(res_op)
	begin
		if res_op = (res_op'range => '0') then
            t_zf <= '1';
        else
            t_zf <= '0';
        end if;
		 
		if res_op(7) = '1' then
			t_sbf <= '1';
		else
			t_sbf <= '0';
		end if;
	end process;
	
	s_data <= res_op;
	RES <= i_res;
	SBF <= t_sbf;
	ZF <= t_zf;
End Beh_Stack;