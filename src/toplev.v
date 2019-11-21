/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * top-level entity
 *
 * date: December 2011
 * author: Luca Rizzon
 *
 * Copyright (C) 2019 Luca Rizzon
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

`timescale 10ns / 1ns

module toplev(
	aluout_WB, lmdout_WB,opcode_WB,pc_WB,destaddr_WB,e_WB
);
	
	output		[31:0]	aluout_WB,lmdout_WB;
	output		[4:0]	opcode_WB,pc_WB;
	output		[3:0]	destaddr_WB;
	output				e_WB;
	
	// wires, to connect modules
	wire 			clk; 
	wire			we_WB_RF, wait_in;
	wire	[3:0]	wadd_WB_RF, add_a_RE_RF, add_b_RE_RF;
	wire	[4:0]	pc_RE_FE, pc_FE_RE, pc_RE_EX, pc_EX_ME,pc_ME_WB;
	wire			cond_RE_FE;
	wire	[31:0]	instr_FE_RE;
	wire	[3:0]	dAdd_EX_RE, dAdd_WB_RE, dAdd_RE_EX, dAdd_EX_ME,dAdd_ME_WB, dAdd_WB_RF, hazfrommem;
	wire	[31:0]	data_a_RF_RE, data_b_RF_RE;
	wire	[31:0]	data_a_RE_EX, data_b_RE_EX,o_data;
	wire	[31:0]	immd_RE_EX, data_b_EX_ME;
	wire	[4:0]	opcode_RE_EX,opcode_EX_ME,opcode_ME_WB;
	wire	[1:0]	comp_RE_EX;
	wire			imm_RE_EX;
	wire	[31:0]	data_EX_ME;
	wire			overflowflag, errorflag;
	wire 	[31:0]	data_WB_RF;
	wire	[31:0]	aluout_EX_ME;
	wire	[31:0]	lmd_ME_WB,aluout_ME_WB;
	wire	[31:0]	aluout_WB,lmdout_WB;
	wire	[4:0]   opcode_WB,pc_WB;
	wire	[3:0]	add_a_RE_EX;
	wire	[3:0]	sadd_RE_EX, load_dest;
	wire 	[4:0]	bta_re_ex, bta_ex_fe;
	wire			bubble,rst_read, imm_EX_ME;
	
	// internal registers
	reg 		rst;

	
	// external modules
	clkGen		mclkgen(clk);
	
	reg_file	rf0(
				clk, we_WB_RF, dAdd_WB_RF, add_a_RE_RF, add_b_RE_RF, data_WB_RF,
				data_a_RF_RE, data_b_RF_RE, o_data
			);

	fetch	mfetch(
				clk, rst, pc_RE_FE, cond_RE_FE, bta_ex_fe, bubble, wait_in,
				instr_FE_RE, pc_FE_RE
			);
	
	read	mread(
				clk, rst_read, instr_FE_RE, pc_FE_RE, data_a_RF_RE, data_b_RF_RE, dAdd_EX_RE, dAdd_WB_RF, dAdd_ME_WB,
				data_a_RE_EX, data_b_RE_EX, immd_RE_EX, dAdd_RE_EX, opcode_RE_EX, pc_RE_EX, cond_RE_FE, pc_RE_FE, wait_in ,imm_RE_EX,
				add_a_RE_RF, add_b_RE_RF, add_a_RE_EX, bta_re_ex
			);
	
	
	ex_stage	mexe(
				data_EX_ME, opcode_EX_ME, overflowflag, errorflag, dAdd_EX_ME, dAdd_EX_RE, 
				immd_RE_EX, pc_EX_ME, bubble, rst_read, bta_ex_fe, imm_EX_ME, load_dest,
				clk, rst, data_a_RE_EX, data_b_RE_EX, dAdd_RE_EX, opcode_RE_EX, pc_RE_EX, imm_RE_EX, add_a_RE_EX, bta_re_ex
			);
	
	mem_stage	mmem(
				clk, rst, data_EX_ME, dAdd_EX_ME, pc_EX_ME, opcode_EX_ME, imm_EX_ME, load_dest,
				pc_ME_WB, lmd_ME_WB, aluout_ME_WB, opcode_ME_WB, dAdd_ME_WB,  
			);
	
	writeback	mwbk(
				clk, rst, aluout_ME_WB, lmd_ME_WB, pc_ME_WB, dAdd_ME_WB, opcode_ME_WB, 
				aluout_WB, lmdout_WB, data_WB_RF, opcode_WB, dAdd_WB_RF, pc_WB, we_WB_RF
			);
	
	// processes
	initial begin
	
		// Save the waveform in dump file
		$dumpfile("dump.lxt");
		$dumpvars(0,toplev);
		
		// testbench
				rst = 1;			// initial reset
		#100 	rst = 0;
		#5500						// modify here to change simulation time
			$finish;
		
	end
	
	always
		@(posedge clk or rst) 
			$display($time,,,"clk=%d, rst=%d, aluout_ME_WB = %H", clk, rst, aluout_ME_WB);

endmodule
