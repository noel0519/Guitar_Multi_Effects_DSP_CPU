module alu(
	input [5:0] opcode,
	input signed [31:0] op1,op2,
	output logic signed [31:0] result,
	output logic zero_flag
);


always@(*)
begin
	if(result == 0)
	begin
		zero_flag = 1'b1;
	end
	logic signed [63:0] product;
	case(opcode)
	
		6'h01: result = op1 + op2;
		6'h02: result = op1 - op2;
		6'h03: begin
    		       product = op1 * op2;
    		       result = product[62:31];
                       end;
		6'h04: result = 32'h0;
		6'h05: result = op1 + op2;
		6'h06: result = op1 + op2;
		6'h07: result = op1 & op2;
		6'h08: result = op1 | op2;
		6'h09: result = op1 ^ op2;
		6'h0A: result = op1 << op2[4:0];
		6'h0B: result = op1 >> op2[4:0];
		default: result = 32'h0;
	endcase
end

endmodule


