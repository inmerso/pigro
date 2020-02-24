/* 
 * REGISTER FILE
 * taken and adapted from: Gray, Jan. (2002). Designing a Simple FPGA-Optimized RISC CPU and System-on-a-Chip. 
*/

`timescale 10ns / 1ns

module reg_file( 
        //in
        clk, wr_en, wr_ad, addr_a, addr_b, wr_data,
        //out
        o_a, o_b
    );

    input         clk;
    input         wr_en;   // wr_en=1 => write operation
    input   [3:0] wr_ad;   // write address
    input   [3:0] addr_a;
    input   [3:0] addr_b;
    input  [31:0] wr_data; // data to be written

    output [31:0] o_a;     // a and b will be input for read stage
    output [31:0] o_b;

    reg [31:0] mem[15:0];  // declaration of the memory space, 15 locations of 32 bits

    /* Set register file at unknown value */
    integer i;
    initial begin
        for(i=0; i<16; i = i+1)
            mem[i] = 32'bx;
    end

    // WRITE OPERATION -> LW instruction, destination of arithm|logical
    always @(posedge clk) begin
        if(wr_en == 1)
            mem[wr_ad] <= wr_data;
    end

    // READ OPERATION
    // Continuous assignments
    assign o_a = mem[addr_a];
    assign o_b = mem[addr_b];

endmodule
