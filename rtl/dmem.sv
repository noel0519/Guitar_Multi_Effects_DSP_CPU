module dmem(
	input clk,
	input rst,

	input [13:0] d1_addr,
	input [13:0] d2_addr,

	output logic [31:0] data1,
	output logic [31:0] data2,
	input [13:0] wr_addr,
	input [31:0] wr_data,
	input we
);

logic [31:0]dmem_[0:16383];


always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		data1 <= 32'h00000000;
		data2 <= 32'h00000000;
	end
	else
		

	begin
		data1 <= dmem_[d1_addr];

		data2 <= dmem_[d2_addr];
	
	
	if(we)
	
	begin dmem_[wr_addr] <= wr_data; end
end
end

endmodule
