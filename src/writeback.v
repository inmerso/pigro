/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * writeback stage
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


module writeback(
            clk,rst,aluoutput,loadmemorydata,cPC,destinationAddress,opcode,
            outALUout,outLMD,data_RF,outOpcode,outDestAddr,outPC,en_RF
    );

    input               clk;
    input               rst;
    input signed [31:0] aluoutput;
    input signed [31:0] loadmemorydata;
    input         [4:0] cPC;               // current program counter
    input         [3:0] destinationAddress;
    input         [4:0] opcode;

    output reg signed [31:0] outALUout;
    output reg signed [31:0] outLMD;
    output reg signed [31:0] data_RF;
    output reg         [4:0] outOpcode;
    output reg         [3:0] outDestAddr;   // goes as input of read Daddr_fromWB
    output reg         [4:0] outPC;
    output reg               en_RF;         // drive RF write op
    
    reg signed [31:0] iALUout;
    reg signed [31:0] iLMD;
    reg         [4:0] iOpcode;
    reg         [3:0] iDestAddr;
    reg         [4:0] iPC;
    reg               ien;

    initial begin iDestAddr = 4'bx; end
    
    always @(posedge clk or rst) begin
        if(rst == 0) begin
            iALUout = aluoutput;
            iOpcode = opcode;
            iLMD 	= loadmemorydata;
            iPC		= cPC;
            data_RF = aluoutput;
        end else
        begin //resetting
            iALUout		<= 0;
            iLMD		<= 0;
            iOpcode		<= 0;
            iDestAddr	<= 0;
            iPC			<= 0;
        end
    end
    
    always @(iPC or iOpcode) begin
            if(iOpcode == `NOP) begin
                ien = 0;
                iALUout = 32'bx;
                iDestAddr = 4'bx;
            end
            if(iOpcode > `NOP & iOpcode <= `ARSH) /*instruction is math|logical*/
            begin
                ien = 1;
                data_RF = iALUout; // aluoutput;
                iDestAddr = destinationAddress;
            end
            if(iOpcode == `LDW) begin
                outLMD = iLMD;
                ien = 1;
                data_RF = iLMD;
                iDestAddr = destinationAddress;
            end
            if(iOpcode == `STR) begin
                ien = 0;
                iDestAddr = destinationAddress;
            end
    end
    
    always @(iALUout)	outALUout 	= iALUout;
    always @(iLMD)		outLMD		= iLMD;
    always @(iOpcode)	outOpcode	= iOpcode;
    always @(iDestAddr)	outDestAddr	= iDestAddr;
    always @(iPC)		outPC		= iPC;
    always @(ien)		en_RF       = ien;
    
endmodule
