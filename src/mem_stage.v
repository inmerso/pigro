/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * memory stage
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

`include "opcodes.vh"

module mem_stage( clk,rst,
			aluout, destinationAddress, pc, opcode, isimm, mem_source,
			pc_out,LMD,outaluout,opcode_out,destAddr_out, omem_source
		);

	input					clk,rst;				
	input signed	[31:0]	aluout;					// value computed by alu
	input			[3:0]	destinationAddress;		// destination where to put the result
	input			[4:0]	pc;						// current program counter	
	input			[4:0]	opcode;					// current operation to be performed
	input					isimm;
	input			[3:0]	mem_source;				// for load only
	
	output			[4:0]	pc_out;					// forwardin' PC 
	output	signed	[31:0]	LMD;					// load memory data → contains value read from memory and has to be put into register in next stage 
	output	signed	[31:0]	outaluout;				// output aluout 
	output			[4:0]	opcode_out;				// ouput opcode
	output			[3:0]	destAddr_out;			// output dest_addr
	output			[3:0]	omem_source;
	
	reg				[4:0] 	opcode_i, opcode_out;
	reg		signed  [31:0]	aluout_i, outaluout;
	reg		signed  [31:0]	LMD, iLMD;
	reg				[3:0]	destAddr_out_i;
	
	reg	signed		[31:0]	tbw_data, itbw_data;
	reg				[3:0]	destAddr_out;
	reg						wrtEnable,wre_i;
	reg				[3:0]	dest_addr;
	reg				[4:0]	iPC, pc_out;
	reg						iisimm;
	reg				[3:0]	omem_source, imem_source;
	

	reg	signed		[31:0]  datatomem, routdata;
	wire signed		[31:0]	outdata;
	
	
	data_mem		dm(tbw_data, clk, dest_addr, imem_source, wrtEnable, outdata);
	
	
	always@(outdata) routdata = outdata;	

	always @(posedge clk) begin
		iPC = pc;
		opcode_i = opcode;
		aluout_i = aluout;
		imem_source = mem_source;
		iisimm = isimm;

		if(isimm == 1) 	begin   iLMD = aluout_i; end
			else		begin	iLMD = outdata; end
	end

	always @(iPC or opcode_i) begin
		if(opcode >= `NOP & opcode <= `ARSH) begin // arithm or logic
			destAddr_out_i = destinationAddress;
			wre_i = 0;
			itbw_data = 32'bx;
			dest_addr = 4'bx;
		end
		if(opcode == `LDW) begin 	// take value from data_mem and put it on Register file
			wre_i = 0;
			destAddr_out_i = destinationAddress;
			dest_addr = 4'bx;
		end
		if(opcode == `STR) begin	// take value from RF and put it on data Memory
			wre_i = 1;
			destAddr_out_i <= destinationAddress;
			itbw_data <= aluout;
			dest_addr = destinationAddress;
		end
	end
	
	always @(itbw_data)			tbw_data = itbw_data;
	always @(opcode_i)			opcode_out = opcode_i;
	always @(aluout_i) 			outaluout = aluout_i;
	always @(destAddr_out_i)	destAddr_out = destAddr_out_i;
	always @(imem_source)		omem_source = imem_source;
	always @(iLMD)				LMD = iLMD;
	always @(iPC)				pc_out = iPC;
	always @(wre_i)				wrtEnable = wre_i;
	always @(imem_source)		omem_source = imem_source;
	
endmodule
