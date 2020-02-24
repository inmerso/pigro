/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * execution stage
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

module ex_stage(
		data_out, outopcode, overflow, error, destinationAddr, dAdd_ward, immediate_in, pcout, read_reset, fetch_flag, fetch_new_pc, oisimm, o_r_a,
		clk, rst, data_a, data_b, dest_addr, opcode, PC, isimm, in_r_a, branch_target
	);

	// --- outputs
	output reg	signed	[31:0]	data_out;	// alu output
	output			[4:0]	outopcode;				// current opcode
	output 					overflow,error;			// alu flags
	output			[3:0]	destinationAddr;  		// destination address
	output			[3:0]	dAdd_ward;				// go as input of read stage Daddr_fromEX
	output			[4:0]	pcout;					// program counter output
	output					read_reset, fetch_flag;
	output			[4:0]	fetch_new_pc;	
	output					oisimm;
	output			[3:0]	o_r_a;
	
	// --- inputs
	input					clk, rst;	
	input	signed	[31:0]	data_a, data_b;				// operands values
	input			[3:0]	dest_addr;					// destination where to put data
	input 	signed	[31:0]	immediate_in;				// signed immediate value
	input			[4:0]	opcode;						// the operation to be performed
	input			[4:0]	PC;							// current program counter
	input					isimm;						// 1: immediate value
	input			[3:0]	in_r_a;						
	input			[4:0]	branch_target;
	

	// --- registers	
	reg		signed	[31:0]	data_a_i, data_b_i, data_out_i;
	reg						enable_ALUi, error_i, overflow_i;
	reg				[4:0]	opcode_i, pcout;	
	reg				[3:0]	destinationAddr, idest_addr, dAdd_ward;
	reg				[4:0]	outopcode;
	reg						error,overflow;
	reg						read_reset, fetch_flag;
	reg				[4:0]	fetch_new_pc;
	reg						iread_reset, ifetch_flag;
	reg				[4:0]	ifetch_new_pc;
	reg						oisimm,iisimm;
	reg				[3:0]	o_r_a, i_r_a;
	
	// output of comparator
	reg 	[1:0]	compout;
	reg		[4:0]	iPC;
	
	// wires
	wire signed	[31:0]	data_out_alu;
	wire				over,err;
	wire				done;
	wire 	[1:0]		cout;
	
	// --- modules
	alu			alu0(data_a_i, data_b_i, opcode_i, enable_ALUi, data_out_alu, over, err, done);
	comparator	cmp0(data_a, data_b, cout);
	// the previous is equal to the following line
	// comparator cmp0(.data_a(data_a_i), .data_b(data_b_i), .o(cout));
	
	initial begin 
		dAdd_ward = 0; 
	end
	
	always @(data_out_i) data_out = data_out_i;
	
	always @(data_out_alu) begin
		if(enable_ALUi) data_out_i = data_out_alu;
	end
	always @(over)          overflow_i = over;
	always @(err)           error_i = err;
	always @(cout)          compout <= cout;
	always @(iPC)           pcout = iPC;
	always @(opcode_i)      outopcode = opcode_i;
	always @(overflow_i)    overflow = overflow_i;
	always @(error_i)       error = error_i;
	always @(iread_reset)   read_reset = iread_reset; 
	always @(ifetch_flag)   fetch_flag = ifetch_flag;
	always @(ifetch_new_pc) fetch_new_pc = ifetch_new_pc;
	always @(iisimm)        oisimm = iisimm;
	always @(i_r_a)	        o_r_a = i_r_a;
	always @(idest_addr)    destinationAddr = idest_addr;
	
	always @(posedge clk or rst) begin
		if(rst == 1) begin
			data_out_i 	<= 0;
			data_a_i	<= 0;
			data_b_i	<= 0;
			opcode_i	<= 0;
			enable_ALUi <= 0;
		end // if reset
		else begin
			// normal execution
			opcode_i = opcode;
			idest_addr = dest_addr;
			dAdd_ward = dest_addr;
			iPC = PC;
			i_r_a = in_r_a;
			iisimm = isimm;
			data_a_i = data_a;
			data_b_i = data_b;
		end
	end
	
	always @(iPC or opcode_i ) begin
		if(opcode_i > `NOP & opcode_i <= `ARSH) begin // arithm or logic
			enable_ALUi = 1;
			data_a_i = data_a;
			if(iisimm == 0)		data_b_i = data_b;
			else				data_b_i = immediate_in;
			
			data_out_i = data_out_alu;
		end
		
		if(opcode_i == `LDW) begin 		// take value from data_mem and put it on Register file
			enable_ALUi = 0;
			if(iisimm == 1)  data_out_i = immediate_in;
			else			 data_out_i = 32'bx;
			
		end
		
		if(opcode_i == `STR) begin		// take value from RF and put it on data Memory		
			enable_ALUi = 0;
			if(iisimm == 0)		data_out <= data_a;
			else				data_out <= immediate_in;
		end
		
		if(opcode_i == `CMP) begin
			enable_ALUi = 0;
			data_out <= cout;
		end
		
		if(opcode == `BRQ | opcode == `BRG | opcode == `BRS) begin
			data_a_i = data_a;
			data_b_i = data_b;
			
			if((opcode == `BRQ && compout == 2'b00)|(opcode == `BRG && cout == 2'b01)|(opcode == `BRS && cout == 2'b10)) begin
				// it is like having a jump
				enable_ALUi = 0;
				// tell the fetch stage the new program counter value
				ifetch_flag = 1;
				iread_reset = 1;
				ifetch_new_pc = branch_target;
			end
			else begin // not taken
				// go ahead
				ifetch_flag = 0;
				iread_reset = 0;
			end
		end
		else begin
				iread_reset = 0;
				ifetch_flag = 0;
				ifetch_new_pc = 5'bz;
		end
					
		if(opcode == `NOP) begin
			enable_ALUi = 0;
			ifetch_flag = 0;
			iread_reset = 0;
		end
	end // reset process
endmodule


/*
	comparator, gives comparison between data_a and data_b
*/
module comparator(data_a, data_b, result);
	input	[31:0]	data_a, data_b;
	output	[1:0]	result;
	
	reg		[1:0]	o;
	
	always @(data_a or data_b) begin
			if(data_a > data_b)
				o = 1;
			if(data_a < data_b)
				o = 2;
			if(data_a == data_b)
				o = 0;
	end
	
	assign result = o;
	
endmodule
