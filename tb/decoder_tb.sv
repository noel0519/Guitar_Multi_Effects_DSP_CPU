`timescale 1ns/1ps

module decoder_tb;

    logic [31:0] instr;
    logic [5:0]  rs1_addr, rs2_addr, rd_addr;
    logic [5:0]  alu_op;
    logic [13:0] immediate;
    logic        reg_write_enable;

    integer tests  = 0;
    integer errors = 0;

    decoder DUT (
        .instr(instr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .alu_op(alu_op),
        .immediate(immediate),
        .reg_write_enable(reg_write_enable)
    );

    // R-type: checks alu_op, rd, rs1, rs2, reg_write_enable
    task check_rtype(input [8*20-1:0] name, input [31:0] i,
                     input [5:0] e_op, e_rd, e_rs1, e_rs2,
                     input e_we);
        begin
            instr = i;
            #10;
            tests = tests + 1;
            if (alu_op !== e_op || rd_addr !== e_rd || rs1_addr !== e_rs1 ||
                rs2_addr !== e_rs2 || reg_write_enable !== e_we) begin
                errors = errors + 1;
                $display("FAIL %0s  instr=%h", name, i);
                $display("     alu_op=%h (exp %h)  rd=%0d (exp %0d)  rs1=%0d (exp %0d)  rs2=%0d (exp %0d)  we=%b (exp %b)",
                         alu_op, e_op, rd_addr, e_rd, rs1_addr, e_rs1,
                         rs2_addr, e_rs2, reg_write_enable, e_we);
            end else
                $display("PASS %0s", name);
        end
    endtask

    // I-type: checks alu_op, rd, rs1, immediate, reg_write_enable
    // rs2_addr is not checked, because bits [13:8] belong to the immediate
    task check_itype(input [8*20-1:0] name, input [31:0] i,
                     input [5:0] e_op, e_rd, e_rs1,
                     input [13:0] e_imm, input e_we);
        begin
            instr = i;
            #10;
            tests = tests + 1;
            if (alu_op !== e_op || rd_addr !== e_rd || rs1_addr !== e_rs1 ||
                immediate !== e_imm || reg_write_enable !== e_we) begin
                errors = errors + 1;
                $display("FAIL %0s  instr=%h", name, i);
                $display("     alu_op=%h (exp %h)  rd=%0d (exp %0d)  rs1=%0d (exp %0d)  imm=%0d (exp %0d)  we=%b (exp %b)",
                         alu_op, e_op, rd_addr, e_rd, rs1_addr, e_rs1,
                         immediate, e_imm, reg_write_enable, e_we);
            end else
                $display("PASS %0s", name);
        end
    endtask

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_tb);

        $display("--- R-type ---");
        //           name                instr (opcode|rd|rs1|rs2|unused)              op    rd  rs1 rs2 we
        check_rtype("ADD r1,r2,r3",  {6'h01, 6'd1,  6'd2,  6'd3,  8'h00}, 6'h01, 6'd1,  6'd2,  6'd3,  1'b1);
        check_rtype("SUB r5,r7,r9",  {6'h02, 6'd5,  6'd7,  6'd9,  8'h00}, 6'h02, 6'd5,  6'd7,  6'd9,  1'b1);
        check_rtype("MUL r15,r0,r15",{6'h03, 6'd15, 6'd0,  6'd15, 8'h00}, 6'h03, 6'd15, 6'd0,  6'd15, 1'b1);
        check_rtype("MAC r1,r2,r3",  {6'h04, 6'd1,  6'd2,  6'd3,  8'h00}, 6'h04, 6'd1,  6'd2,  6'd3,  1'b1);
        check_rtype("AND r3,r1,r2",  {6'h07, 6'd3,  6'd1,  6'd2,  8'h00}, 6'h07, 6'd3,  6'd1,  6'd2,  1'b1);
        check_rtype("OR r2,r4,r5",   {6'h08, 6'd2,  6'd4,  6'd5,  8'h00}, 6'h08, 6'd2,  6'd4,  6'd5,  1'b1);
        check_rtype("XOR, unused=FF",{6'h09, 6'd3,  6'd1,  6'd2,  8'hFF}, 6'h09, 6'd3,  6'd1,  6'd2,  1'b1);
        check_rtype("SHL r0,r15,r1", {6'h0A, 6'd0,  6'd15, 6'd1,  8'h00}, 6'h0A, 6'd0,  6'd15, 6'd1,  1'b1);
        check_rtype("SHR r8,r6,r2",  {6'h0B, 6'd8,  6'd6,  6'd2,  8'h00}, 6'h0B, 6'd8,  6'd6,  6'd2,  1'b1);

        $display("--- I-type ---");
        //           name                instr (opcode|rd|rs1|imm)                   op    rd  rs1 imm     we
        check_itype("LD r1,[r2+512]",   {6'h05, 6'd1,  6'd2,  14'd512},             6'h05, 6'd1,  6'd2, 14'd512,  1'b1);
        check_itype("LD imm max",       {6'h05, 6'd3,  6'd4,  14'h3FFF},            6'h05, 6'd3,  6'd4, 14'h3FFF, 1'b1);
        check_itype("LD imm zero",      {6'h05, 6'd0,  6'd0,  14'd0},               6'h05, 6'd0,  6'd0, 14'd0,    1'b1);
        check_itype("ST [r2+100]",      {6'h06, 6'd1,  6'd2,  14'd100},             6'h06, 6'd1,  6'd2, 14'd100,  1'b0);
        check_itype("JMP +20",          {6'h10, 6'd0,  6'd0,  14'd20},              6'h10, 6'd0,  6'd0, 14'd20,   1'b0);
        check_itype("BRZ r3, +4",       {6'h11, 6'd0,  6'd3,  14'd4},               6'h11, 6'd0,  6'd3, 14'd4,    1'b0);
        check_itype("CALL +8",          {6'h12, 6'd0,  6'd0,  14'd8},               6'h12, 6'd0,  6'd0, 14'd8,    1'b0);
        check_itype("RET",              {6'h13, 6'd0,  6'd0,  14'd0},               6'h13, 6'd0,  6'd0, 14'd0,    1'b0);

        $display("--- Summary: %0d tests, %0d failures ---", tests, errors);
        $finish;
    end

endmodule
