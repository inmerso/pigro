/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * arithmetic and logic unit
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

`define ZERO 32'd0
`define ONE  32'b11111111111111111111111111111111


module alu(
	// input
	data_a, data_b, opcode, enable,
	//output
	ALUout, overflow, error);

	// --- output
	output	[31:0]	ALUout;
	output			overflow, error;

	// --- inputs
	input	signed	[31:0]	data_a, data_b;
	input			[4:0]	opcode;
	input					enable;

	// --- internal
	reg		signed	[31:0]	iALUout;
	reg		signed  [32:0]  iSum;		// bit conservation law
	reg		signed	[63:0]	iProd;		
	reg						error, overflow;
	reg		signed 	[31:0]	ALUout;
	
	
	// --- processes
	always @(data_a or data_b or enable or opcode) begin
		if(enable == 1) begin
			case(opcode)
				
				`NOP : begin // do nothin'
						iALUout = 32'bz;
						error = 0;
						overflow = 0;
					end
				
				`NOT : begin // data_a negation
						iALUout = ~(data_a);
						error = 0;
						overflow = 0;
					end
				
				`AND : begin // bitwise and
						iALUout = data_a & data_b;
						error = 0;
						overflow = 0;
					end

				`OR  : begin // bitwise or
						iALUout = data_a | data_b;
						error = 0;
						overflow = 0;
					end

				`XOR : begin // bitwise xor
						iALUout = data_a ^ data_b;
						error = 0;
						overflow = 0;
					end

				`NAND : begin // bitwise nand
						iALUout = ~(data_a & data_b);
						error = 0;
						overflow = 0;
					end

				`NOR  : begin // bitwise nor
						iALUout = ~(data_a | data_b);
						error = 0;
						overflow = 0;
					end

				`NXOR : begin // bitwise nxor
						iALUout = data_a ~^ data_b;
						error = 0;
						overflow = 0;
					end					

				`LSH : begin // left shift
						iALUout = data_a << data_b;
						error = 0;
						overflow = 0;
					end					
					
				`RSH : begin // right shift
						iALUout = data_a >> data_b;
						error = 0;
						overflow = 0;
					end					

				`INC : begin // increment
						iALUout = data_a + 1;
						error = 0;
						overflow = 0;
					end					
					
				`DEC : begin // decrement
						iALUout = data_a - 1;
						error = 0;
						overflow = 0;
					end		
					
				`ADD : begin // adder
						iSum = data_a + data_b;
						iALUout = iSum[31:0];
						overflow = iSum[32] ^ iSum[31];
						error = 0; 
					end		
								
				`SUB : begin // subtraction
						iSum = data_a - data_b;
						iALUout = iSum[31:0];
						overflow = iSum[32] ^ iSum[31];
						error = 0;
					end	
									
				`MUL : begin // multiplication
						iProd = data_a * data_b;
						iALUout = iProd[31:0];
						//check overflow calculation
						overflow = ((iProd[63:32] != `ZERO) & (iProd[63:32] != `ONE)) | (iProd[32] ^ iProd[31]);
						error = 0;
					end		
					
				`ROTL : begin // rotate left by 1
						iALUout = {data_a[30:0], data_a[31]};
						error = 0;
						overflow = 0;
					end					
					
				`ROTR : begin // rotate right by 1 bit
						iALUout = {data_a[0], data_a[31:1]};
						error = 0;
						overflow = 0;
					end			

				`ALSH : begin // arithmetic left shift
						iALUout = data_a <<< data_b;
						error = 0;
						overflow = 0;
					end					
					
				`ARSH : begin // arithmetic right shift
						iALUout = data_a >>> data_b;
						error = 0;
						overflow = 0;
					end							
					
				default: 
					// if not comtemplated it's an error in opcode, set the flag
					error = 1;	
			endcase
		end
		else begin // disabled ALU
			ALUout		= 0;
			overflow	= 0;
			error		= 0;		// error -> validity
		end
	end // process
	
	// pass result to output
	always @(iALUout) begin
		ALUout <= iALUout;
	end
	
endmodule // alu
