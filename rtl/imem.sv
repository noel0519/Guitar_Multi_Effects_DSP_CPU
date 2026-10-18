`timescale 1ns / 1ps


module imem(
	input clk,
	input rst,
	input [10:0] rd_addr,
	output logic [31:0] rd_data
	);

	logic [31:0]imem_[0:2047];

	always@(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
		rd_data <= 32'h00000000;
		end
		else
		begin
			rd_data <= imem_[rd_addr];
		end
	end
	endmodule
			

			
