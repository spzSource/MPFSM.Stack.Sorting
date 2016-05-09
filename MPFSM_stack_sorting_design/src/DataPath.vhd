library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use commands.all;

entity DPATH is
	port(
		EN: in std_logic;
		CLK: in std_logic;
		OT: in std_logic_vector(3 downto 0);
		OP: in std_logic_vector(7 downto 0);
		RES: out std_logic_vector(7 downto 0);
		ZF: out std_logic;
		SBF: out std_logic;
		-- stop - 
		Stop: out std_logic
	);
end DPATH;

architecture Beh_Stack of DPATH is
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
			ADDRESS_SIZE => 8,
			DATA_SIZE => 8
		)
		port map(
			clk => clk,
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