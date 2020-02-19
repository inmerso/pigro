/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * decode instructions stage
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

`include "src/opcodes.vh"

module read(
	//in	
			clk, rst, instruction_in, pc_in,
			data_a_RF, data_b_RF,
			Daddr_fromEX, Daddr_fromWB,	Daddr_fromMEM,
	// out		
			data_a, data_b, immediate, dest_addr, opcode, pc, jump_flag, jump_dest, stall, isimmediate,
			addr_a_RF, addr_b_RF, o_addr_a, BTA
	);
	
	// inputs and outputs
	input					clk, rst;
	input			[31:0]	instruction_in;								// instruction to be executed (coming from fetch)
	input			[4:0]	pc_in;										// pcounter of the current instruction (coming from fetch)
	input	signed	[31:0]	data_a_RF, data_b_RF; 						// coming from the register file, declared in toplev
	input			[3:0]   Daddr_fromEX,Daddr_fromWB, Daddr_fromMEM; 	// used to detect Hazards
	
	output	signed 	[31:0]	data_a, data_b;		// current operands values
	output	signed 	[31:0]	immediate;			
	output			[3:0]	dest_addr;			// destination address
	output			[4:0]	opcode;				// output opcode
	output			[4:0]	pc, jump_dest;
	output					jump_flag;			// it's the if zero branch, goto fetch
	output					stall;				// to insert bubbles -> `NOP
	output					isimmediate;
	output			[3:0]	o_addr_a;
	
	output			[3:0]	addr_a_RF, addr_b_RF;	// goto regfile
	
	output			[4:0]	BTA;
	
	// registers
	reg signed	[31:0]	data_a, data_b, immediate;
	reg			[3:0]	dest_addr;	
	reg			[4:0]	opcode;
	reg			[4:0]	pc, jump_dest;
	reg			[1:0]	comp;
	reg					jump_flag;
	reg					RAWHazard;
	reg					isimmediate;
	reg			[3:0]	o_addr_a;
	
	reg			[3:0]	addr_a_RF, addr_b_RF;
	reg			[4:0]	BTA, BTAi;
	reg			[31:0]	instr_i;
	reg signed	[31:0]	data_a_i, data_b_i, immediate_i;
	reg			[3:0]	dest_addr_i;	
	reg			[4:0]	opcode_i;
	reg			[4:0]	pc_i, jump_dest_i;
	reg					isimmediate_i;
	
	reg			[3:0]	Daddr_fromEX_i, Daddr_fromWB_i, Daddr_fromMEMi; 
	reg					RAW_i;


	// wires
	wire	signed	[31:0] 	data_imm;
	wire			RAW;
	
	reg 			stall;
	reg		[17:0]	imminstr;
	
	// internal modules 
	SignExtension se0(imminstr, data_imm);
	RAWDetector   RAWd(instr_i[`INS_Ra], instr_i[`INS_Rb], Daddr_fromEX_i, Daddr_fromWB_i, Daddr_fromMEMi, RAW);
	
	
	initial begin	instr_i = 32'b0; end	
		
	always @(Daddr_fromEX or Daddr_fromWB or Daddr_fromMEM) begin
		Daddr_fromEX_i <= Daddr_fromEX;
		Daddr_fromWB_i <= Daddr_fromWB;
		Daddr_fromMEMi <= Daddr_fromMEM;
	end
	
	always @(RAW) begin
		RAW_i <= RAW;
	end
	
	always @ (posedge clk or rst) begin
		if(rst == 0)begin
			if(RAW == 0) begin
				instr_i 	= instruction_in;
				pc_i		= pc_in;
			end
		end
		else begin
			instr_i = `NOP;
			pc_i <= 0;
		end
	end	
	
	always @(data_a_RF) begin
		data_a_i = data_a_RF;
	end
	
	always @(instr_i) begin

		if(stall == 0) begin
			addr_a_RF 	= instr_i[`INS_Ra];
			
			data_a_i 	= data_a_RF;
			
			if(instr_i[`IMM] == 1) begin
				data_b_i = 32'bx;
				addr_b_RF = 4'bx;
			end
			else begin
				addr_b_RF 	= instr_i[`INS_Rb];
				data_b_i 	= data_b_RF;
			end

			dest_addr_i = instr_i[`INS_Rd];
			if (instr_i[`IMM]) begin
				isimmediate_i = 1;
			end 
			else begin
				isimmediate_i = 0;
			end
			imminstr 	= instr_i[`INS_IM];
			o_addr_a 	= instr_i[`INS_Ra]; 
			BTAi		= instr_i[`DISPL];
	
			// jump is performed at this stage, and it is forwarded as a NOP!
			if(instr_i[`INS_OP] == `JMP) begin
				//feedback
				jump_flag = 1;
				if(isimmediate_i == 1) 
					jump_dest_i = instr_i[`DISPL];
				else
					jump_dest_i = pc_i + instr_i[`DISPL];
					
				// flush the pipeline
				opcode_i	= `NOP;
			end 
			else begin
				jump_flag = 0;
				jump_dest_i = 5'bx;
				opcode_i = instr_i[`INS_OP];
			end 
		end
		else begin // there's a RAW Hazard to deal with
			/* rise the alert to stop fetching instructions and forward a NOP */
			opcode_i	=	`NOP;
			jump_flag	=	0;
		end
	end
	
	//propagate to output
	always @(data_a_i) data_a = data_a_i;
	always @(data_b_i) data_b = data_b_i;
	always @(opcode_i) opcode = opcode_i;
	always @(data_imm) begin 
		if(isimmediate_i == 1) 
			immediate = data_imm; 
		else 
			immediate = 32'bx;
	end
	always @(dest_addr_i)   dest_addr = dest_addr_i;
	always @(pc_i)          pc = pc_i;
	always @(jump_dest_i)   jump_dest = jump_dest_i;
	always @(isimmediate_i) isimmediate = isimmediate_i;
	always @(BTAi)          BTA = BTAi;
	always @ (RAW_i ) begin
		//if(opcode_i != `STR) 
			stall = RAW_i;
			// opcode = 0;
	end
	always @(stall) begin
		if (stall == 1) opcode = 0; else opcode = opcode_i;

	end 
endmodule 


/*
 perform sign extension to extend immediate value up to 32 bits 
*/
module SignExtension(a, result); 
	input			[17:0] a; 		// 18-bit input 
	output 	signed 	[31:0] result; 	// 32-bit output 
	
	assign result = { { 14{a[17]} }, a };
endmodule 


/*
	detecting RAW by register address comparison
*/
module RAWDetector(
	Raddr_a, Raddr_b, Daddr_fromEX, Daddr_fromWB, Daddr_fromMEM, 
	RAW_o	);
	
	input [3:0]	Raddr_a, Raddr_b,
				Daddr_fromEX, Daddr_fromWB, Daddr_fromMEM;
	
	output	RAW_o; // RAW = 1 when there's a write hazard 
	reg		RAW_o;
	
	reg haz1, haz2, haz3, haz4, haz5, haz6;
		
	always @* begin
	
		if(Raddr_a !== 4'bx | Daddr_fromEX !== 4'bx) begin
			if(Raddr_a == Daddr_fromEX) haz1 = 1;
			else						haz1 = 0;
		end else haz1 = 0;
		if(Raddr_b !== 4'bx | Daddr_fromEX !== 4'bx) begin
			if(Raddr_b == Daddr_fromEX) haz2 = 1;
			else						haz2 = 0;
		end else haz2 = 0;
		if(Raddr_a !== 4'bx | Daddr_fromWB !== 4'bx) begin
			if(Raddr_a == Daddr_fromWB) haz3 = 1;
			else						haz3 = 0;
		end else haz3 = 0;
		if(Raddr_b !== 4'bx | Daddr_fromWB !== 4'bx) begin
			if(Raddr_b == Daddr_fromWB) haz4 = 1;
			else						haz4 = 0;
		end else haz4 = 0;
		if(Raddr_a !== 4'bx | Daddr_fromMEM !== 4'bx) begin
			if(Raddr_a == Daddr_fromMEM) haz5 = 1;
			else						haz5 = 0;
		end else haz5 = 0;
		if(Raddr_b !== 4'bx | Daddr_fromMEM !== 4'bx) begin
			if(Raddr_b == Daddr_fromMEM) haz6 = 1;
			else						haz6 = 0;
		end 
		else haz6 = 0;
	end
	
	always @* begin	
		RAW_o = haz1 | haz2 | haz3 | haz4 | haz5 | haz6;
	end
endmodule
