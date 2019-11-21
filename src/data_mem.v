/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * data memory
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

module data_mem(
		tbw_data,clk,dest_addr,source_add,wrtEnable,
		outdata
	);
	
	input	signed	[31:0]	tbw_data;
	input					clk,
							wrtEnable;
	input			[3:0]	dest_addr;
	input			[3:0]	source_add;
	
	output	signed	[31:0]	outdata;
	
	reg		[31:0]	mem[31:0];		// 32 location of 32bit space
	reg		[5:0]	i;
	
	reg	signed [31:0] itbw_data;
	
	initial begin	
		for(i=0; i<32; i = i+1)
			mem[i] = i;
	end
	
	// WRITE
	always @ (posedge clk) begin
		if(wrtEnable == 1)
			mem[dest_addr] <= tbw_data;
	end

	// READ
	assign outdata = mem[source_add];
	
endmodule
