-------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : MPFSM_stack_sorting_design
-- Author      : sasha.popitich@outlook.com
-- Company     : home
--
-------------------------------------------------------------------------------
--
-- File        : F:\Dropbox\Magistracy\POCP\practice\MPFSM_stack_sorting\MPFSM_stack_sorting_design\compile\FSM.vhd
-- Generated   : 05/10/16 23:49:53
-- From        : F:\Dropbox\Magistracy\POCP\practice\MPFSM_stack_sorting\MPFSM_stack_sorting_design\src\FSM.asf
-- By          : FSM2VHDL ver. 5.0.7.2
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FSM is 
	port (
		CLK: in STD_LOGIC);
end FSM;

architecture FSM_arch of FSM is

-- SYMBOLIC ENCODED state machine: Sreg0
type Sreg0_type is (
    IDLE, FETCH, DECODE, HALT, READ, STORE, JNSB, JZ, READ_INDIRECT, LOAD_INDIRECT, DP_ACCEPT, DP_WAIT, NEXT
);
-- attribute enum_encoding of Sreg0_type: type is ... -- enum_encoding attribute is not supported for symbolic encoding

signal Sreg0: Sreg0_type;

begin


----------------------------------------------------------------------
-- Machine: Sreg0
----------------------------------------------------------------------
Sreg0_machine: process (CLK)
begin
	if CLK'event and CLK = '1' then
		-- Set default values for outputs, signals and variables
		-- ...
		case Sreg0 is
			when IDLE =>
				if Start=1 then	
					Sreg0 <= FETCH;
				end if;
			when FETCH =>
				rom_enabled=1
				Sreg0 <= DECODE;
			when DECODE =>
				IC=IC+1
				RO=RI[9:6]
				RA=RI[5:0]
				if RO=HALT then	
					Sreg0 <= HALT;
				elsif RO=JZ then	
					Sreg0 <= JZ;
				elsif RO=JNSF then	
					Sreg0 <= JNSB;
				elsif RO=ADD|SUB|POP then	
					Sreg0 <= DP_ACCEPT;
				else
					Sreg0 <= READ;
				end if;
			when HALT =>
				stop=1
			when READ =>
				RD=ram_data_output
				if RO=PUSH then	
					Sreg0 <= DP_ACCEPT;
				elsif RO=PUSHI|POPI then	
					Sreg0 <= LOAD_INDIRECT;
				end if;
			when STORE =>
				ram_read_write=0
				Sreg0 <= NEXT;
			when JNSB =>
				IC=Ra
				Sreg0 <= NEXT;
			when JZ =>
				IC=RA
				Sreg0 <= NEXT;
			when READ_INDIRECT =>
				RD=ram_data_output
				Sreg0 <= DP_ACCEPT;
			when LOAD_INDIRECT =>
				RA=RD[5:0]
				if RO=PUSHI then	
					Sreg0 <= READ_INDIRECT;
				end if;
			when DP_ACCEPT =>
				datapath_enabled=1
				Sreg0 <= DP_WAIT;
			when DP_WAIT =>
				if RO=POP|POPI then	
					Sreg0 <= STORE;
				elsif datapath_stop=0 then	
					Sreg0 <= DP_WAIT;
				end if;
			when NEXT =>
				Sreg0 <= FETCH;
--vhdl_cover_off
			when others =>
				null;
--vhdl_cover_on
		end case;
	end if;
end process;

end FSM_arch;
