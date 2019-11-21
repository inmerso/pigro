# pigro

This repository contains the implementation in Verilog of a 32-bit 5-stage
pipelined RISC microprocessor called PIGRO: Processor Implemented Grinding Red
Onions. 
No, just kidding. Pigro means lazy in Italian....


## Try it out
To use this code under Linux OS you'll need: the Icarus Verilog compiler and
GTKWave Analyzer.
In Ubuntu, if you haven't them installed, type the following in your terminal
and follow the instructions:

    sudo apt install iverilog
    sudo apt install gtkwave

The repository contains two script files to compile the design (compile.sh), and
to simulate it (simulate.sh).
The code it runs during simulation is contained in the pogram memory. 
You can modify it (it's in the fetch.v file insude the prog_mem module). 
