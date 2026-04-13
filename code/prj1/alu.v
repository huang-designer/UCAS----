`timescale 10 ns / 1 ns
`define DATA_WIDTH 32
module alu(
input [`DATA_WIDTH - 1:0] A,
input [`DATA_WIDTH - 1:0] B,
input [ 2:0] ALUop,
output Overflow,
output CarryOut,
output Zero,
output [`DATA_WIDTH - 1:0] Result
);
wire [`DATA_WIDTH - 1:0] B_mux;
wire op_sub;
wire [`DATA_WIDTH - 1:0] sum;
wire cout_tmp;
wire overflow_tmp;
wire slt_result;
// 减法控制
assign op_sub = (ALUop == 3'b110) || (ALUop == 3'b111);
assign B_mux = op_sub ? ~B : B;
// 32位加法器（ADD/SUB/SLT 复用）
assign {cout_tmp, sum} = A + B_mux + op_sub;
// 溢出判断
assign overflow_tmp = (A[31] == B_mux[31]) && (sum[31] != A[31]);
assign Overflow = ((ALUop == 3'b010) || (ALUop == 3'b110)) ? overflow_tmp : 1'b0;
// SLT 公式：有符号比较必须 = 溢出 ^ 符号位
assign slt_result = overflow_tmp ^ sum[31];
assign Result = (ALUop == 3'b000) ? A & B : // AND
(ALUop == 3'b001) ? A | B : // OR
(ALUop == 3'b010) ? sum : // ADD
(ALUop == 3'b110) ? sum : // SUB
(ALUop == 3'b111) ? {{31{1'b0}}, slt_result} : // SLT
{`DATA_WIDTH{1'b0}};
// 零标志
assign Zero = (Result == {`DATA_WIDTH{1'b0}});
assign CarryOut = (ALUop == 3'b010) ? cout_tmp : // ADD
(ALUop == 3'b110) ? ~cout_tmp : // SUB
1'b0; // 其他
endmodule
