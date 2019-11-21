/* 
 * REGISTER FILE
 * taken and adapted from: Gray, Jan. (2002). Designing a Simple FPGA-Optimized RISC CPU and System-on-a-Chip. 
*/

`timescale 10ns / 1ns

module reg_file( 
		//in
		clk,we,wr_ad,ad_a,ad_b,d,
		//out
		o_a,o_b,o_d
	);

	input 			clk,
					we;				// we=1 => write operation
	input	[3:0]	wr_ad;			// write address
	input	[3:0]	ad_a,
					ad_b;
	input	[31:0]	d;				// data to be written
	output	[31:0]	o_a,			// a and b will be input for read stage
					o_b,
					o_d;
	

	reg		[31:0]	mem[15:0];		// declaration of the memory space
									// 15 locations of 32 bits
	reg		[4:0]	i; 				// index for loop
	reg		[31:0]	o_d;
	
	
	initial begin
		for(i=0; i<16; i = i+1)
			mem[i] = 32'bx;			// Put unknow
	end
		
	
	// WRITE OPERATION -> LW instruction, destination of arithm|logical
	always @(posedge clk) begin
		if(we == 1)
			mem[wr_ad] <= d;
		else	// even if not used
			o_d <= mem[wr_ad];
	end
	
	// READ OPERATION
	// Continuous assignments
	assign o_a = mem[ad_a];
	assign o_b = mem[ad_b];
	
endmodule

