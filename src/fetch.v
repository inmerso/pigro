/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * fetch stage
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

module fetch(
    // inputs
    clk, rst, jump_dest, jumpflag, branch_dest, taken, hazard,
    //outputs
    oinstr, opc);
    
    input        clk;
    input        rst;
    input [4:0]  jump_dest;     // jump destination 
    input        jumpflag;      // take the jump
    input [4:0]  branch_dest;   // branch destination
    input        taken;         // take the branch
    input        hazard;
    
    output [31:0] oinstr;       // fetched instruction
    output [4:0]  opc;          // computed PC
    
    // internal register
    reg  [31:0] oinstr;
    reg  [4:0]  opc;
    
    wire [`DATA_WIDTH-1:0] instr_PM;	

    // external module
    prog_mem mem0(clk, opc, instr_PM);
    
    always @(posedge clk or rst) begin
        if(rst == 1) begin // reset
            opc <= 0;
            oinstr <= 0;
        end
        else begin
            if(jumpflag == 1) begin
                opc <= jump_dest; // have to jump
            end
            else begin
                if(taken == 1)
                    opc <= branch_dest; // branch taken
                else
                    if(hazard == 0)
                        opc <= opc + 1; // normal increment
            end
            oinstr <= instr_PM;
        end
    end
endmodule


// instruction|program memory: contains instructions in sequence
module prog_mem(clk, address, out_data);

    input       clk;
    input [4:0] address;
    
    output [`DATA_WIDTH-1:0] out_data;
    
    reg [`DATA_WIDTH-1:0] out_data;
    reg [`DATA_WIDTH-1:0] mem[31:0]; // 32 locations of 32 bits
    
    initial begin
        // store the instructions here
        mem[0]  = {`NOP, 27'bx};
        mem[1]  = {`LDW, 1'b0, 4'b1,  4'd1,  18'd0};           // LWD R1,mem[1]
        mem[2]  = {`LDW, 1'b0, 4'd2,  4'd2,  18'd0};           // LDW R2,mem[2]
        mem[3]  = {`LDW, 1'b0, 4'd3,  4'd3,  18'd0};           // LDW R3,mem[3]
        mem[4]  = {`LDW, 1'b0, 4'd4,  4'd4,  18'd0};           // LDW R4,mem[4]
        mem[5]  = {`LDW, 1'b0, 4'd5,  4'd5,  5'd12, 13'd0};    // LDW R5,mem[5]
        mem[6]  = {`LDW, 1'b1, 4'd10, 4'bx,  18'd0};           // LDWi R10, #0
        mem[7]  = {`LDW, 1'b1, 4'd11, 4'bx,  18'd2};           // LDWi R11, #2
        mem[8]  = {`LDW, 1'b0, 4'd12, 4'd12, 18'd0};           // LDW R12, mem[12]
        mem[9]  = {`NOP, 27'bx};
        mem[10] = {`MUL, 1'b0, 4'd1,  4'd2,  4'd3, 14'b0};     // R1 = 6 = 2 x 3
        mem[11] = {`ADD, 1'b0, 4'd5,  4'd1,  4'd4, 14'b0};     // R5 = 6 + 4 = 10   RAW!!
        mem[12] = {`NOT, 1'b0, 4'd3,  4'd3,  18'bx};           // NOT R3, R3;
        mem[13] = {`STR, 1'b0, 4'd1,  4'd3,  18'bx};           // STR R1, R3; → RAW!!
        mem[14] = {`SUB, 1'b1, 4'd7,  4'd12, 18'd11};          // SUBi R7, R12, #11;
        mem[15] = {`BRQ, 5'bx, 4'd10, 4'd11, 5'd23, 9'bx};     // BRQ R10, R11, @23;
        mem[16] = {`ADD, 1'b1, 4'd10, 4'd10, 18'd1};           // ADDi R10, R10, #1
        mem[17] = {`NOP, 27'bx};                               // necessary due to 'distance' of exe from fetch
        mem[18] = {`NOP, 27'bx};
        // mem[19] = {`JMP, 1'b0, 12'bx, 5'd3, 9'bx};             // JUMP pc+3; skip the 'for'
        mem[19] = {`JMP, 1'b1, 12'bx, 5'd15, 9'bx};            // JUMP @15 to do de 'for'
        mem[20] = {`NOP, 27'bx};
        mem[21] = {`NOP, 27'bx};
        mem[22] = {`NOP, 27'bx};
        mem[23] = {`NOP, 1'b0, 4'd15, 4'd1,  4'd2,  14'd16};   // Print out values 
        mem[24] = {`NOP, 1'b0, 4'd14, 4'd3,  4'd4,  14'd16};   //
        mem[25] = {`NOP, 1'b0, 4'd1,  4'd5,  4'd6,  14'd16};   // from simulation user can see all
        mem[26] = {`NOP, 1'b0, 4'd2,  4'd7,  4'd8,  14'd16};   // the values of ther reg file plus
        mem[27] = {`NOP, 1'b0, 4'd3,  4'd9,  4'd10, 14'd16};   // the data mem values with odd address
        mem[28] = {`NOP, 1'b0, 4'd4,  4'd11, 4'd12, 14'd16};   //
        mem[29] = {`NOP, 1'b0, 4'd5,  4'd13, 4'd14, 14'd16};   //
        mem[30] = {`NOP, 1'b0, 4'd6,  4'd15, 4'd0,  14'd16};   //
        mem[31] = 32'b00000000000000000000000000000000;        // 
    end

    always @(posedge clk) begin
        out_data = mem[address];
    end

endmodule
