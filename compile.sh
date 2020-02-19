#!/bin/sh
iverilog src/toplev.v src/reg_file.v src/ex_stage.v src/alu.v src/fetch.v src/mem_stage.v src/data_mem.v src/writeback.v src/read.v src/clkGen.v -o pigro

##debug
#iverilog src/toplev.v src/reg_file.v src/ex_stage.v src/alu.v src/fetch.v src/mem_stage.v src/data_mem.v src/writeback.v src/read.v src/clkGen.v -o pigro -Wall
