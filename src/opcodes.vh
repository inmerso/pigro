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

    `define DATA_WIDTH 32
    `define OPCODE_WIDTH 5
    `define IMMEDIATE_WIDTH 18
    `define REG_ADDR_WIDTH 4

    //--- opcode definitions
    // arithm & logic
    `define NOP   5'd0
    `define NOT   5'd1
    `define AND   5'd2
    `define OR    5'd3
    `define XOR   5'd4
    `define NAND  5'd5
    `define NOR   5'd6
    `define NXOR  5'd7
    `define LSH   5'd8
    `define RSH   5'd9
    `define INC   5'd10
    `define DEC   5'd11
    `define ADD   5'd12
    `define SUB   5'd13
    `define MUL   5'd14
    `define ROTL  5'd15
    `define ROTR  5'd16
    `define ALSH  5'd17
    `define ARSH  5'd18
    `define SQRT  5'd19
    
    //branch
    `define JMP   5'd25
    `define CMP   5'd26
    `define BRQ   5'd27
    `define BRG   5'd28
    `define BRS   5'd29
    
    //load & store
    `define LDW   5'd30
    `define STR   5'd31

    //--- Instruction partitioning
    `define INS_OP    31:27                // opcode
    `define IMM       26                   // if 1 => data_b receives immediate value <= sign ext
    `define INS_Rd    25:22                // rD address
    `define INS_Ra    21:18                // rA 
    `define INS_Rb    17:14                // rB 
    `define INS_IM    `IMMEDIATE_WIDTH-1:0 // immediate (17-bit)
    `define DISPL     13:9                 // new program counter when jump is taken

`endif