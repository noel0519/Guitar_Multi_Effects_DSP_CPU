module reg_file (
	input clk,
	input rst,

	// Read Ports
	
	input [5:0] rs1_addr,
	output [31:0] rs1_data,

	input [5:0] rs2_addr,
	output [31:0] rs2_data,

	// Write Ports
	
	input [5:0] wr_addr,
	input [31:0] wr_data,
	input we
);



	
	reg [31:0] regs[0:15];
	assign rs1_data = regs[rs1_addr[3:0]];
	assign rs2_data = regs[rs2_addr[3:0]];

	always@(posedge clk)
	begin
		if(!rst)
		begin
			integer i;
			for(i = 0; i< 16; i = i + 1)
				regs[i] <= 32'h0000_0000;
		end
		else
			if(we)
			begin
				regs[wr_addr[3:0]] <= wr_data;

			end
		end

		endmodule


