/*
 * PIGRO, a super simple 32bit RISC microprocessor
 * 
 * definitions of opcodes
 *
 * date: December 2011
 * author: Luca Rizzon
 */

`ifndef _opcodes_vh_
`define _opcodes_vh_

    //--- opcode definitions	// hex
    // arithm & logic
    `define NOP  5'b00000
    `define NOT  5'b00001
    `define AND  5'b00010
    `define OR   5'b00011
    `define XOR  5'b00100
    `define NAND 5'b00101
    `define NOR  5'b00110
    `define NXOR 5'b00111
    `define LSH  5'b01000
    `define RSH  5'b01001
    `define INC  5'b01010
    `define DEC  5'b01011
    `define ADD  5'b01100
    `define SUB  5'b01101
    `define MUL  5'b01110
    `define	ROTL 5'b01111
    `define ROTR 5'b10000
    `define ALSH 5'b10001
    `define ARSH 5'b10010
    `define SQRT 5'b10011
    //branch
    `define JMP  5'b11000	
    `define CMP  5'b11001
    `define BRQ  5'b11010
    `define BRG  5'b11011
    `define BRS  5'b11100
    //load & store
    `define LDW  5'b11101
    `define STR  5'b11110
    `define SQRT 5'b11111

    //--- Instruction partitioning
    `define INS_OP	31:27	// opcode
    `define IMM		26		// if 1 => data_b receives immediate value <= sign ext
    `define INS_Rd	25:22	// rD address
    `define INS_Ra	21:18	// rA 
    `define INS_Rb	17:14	// rB 
    `define INS_IM	17:0	// immediate (17-bit)
    `define DISPL	13:9	// new program counter when jump is taken

`endif