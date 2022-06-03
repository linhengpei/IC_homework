`include "ALU_1bit.v"

module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

assign zero= ~(result[0] | result[1] | result[2] | result[3] |result[4] | result[5] |result[6] | result[7]);

wire cout[7:0];
wire set [7:0];
wire Overflow [7:0];
assign less = set[7] ^ overflow ;  //if overflow == 1 , change the set[7]

ALU_1bit name_0(result[0], cout[0], set[0], Overflow[0], ALU_src1[0], ALU_src2[0], less, Ainvert, Binvert, Binvert,op);
ALU_1bit name_1(result[1], cout[1], set[1], Overflow[1], ALU_src1[1], ALU_src2[1], 0   , Ainvert, Binvert, cout[0],op);
ALU_1bit name_2(result[2], cout[2], set[2], Overflow[2], ALU_src1[2], ALU_src2[2], 0   , Ainvert, Binvert, cout[1],op);
ALU_1bit name_3(result[3], cout[3], set[3], Overflow[3], ALU_src1[3], ALU_src2[3], 0   , Ainvert, Binvert, cout[2],op);
ALU_1bit name_4(result[4], cout[4], set[4], Overflow[4], ALU_src1[4], ALU_src2[4], 0   , Ainvert, Binvert, cout[3],op);
ALU_1bit name_5(result[5], cout[5], set[5], Overflow[5], ALU_src1[5], ALU_src2[5], 0   , Ainvert, Binvert, cout[4],op);
ALU_1bit name_6(result[6], cout[6], set[6], Overflow[6], ALU_src1[6], ALU_src2[6], 0   , Ainvert, Binvert, cout[5],op);
ALU_1bit name_7(result[7], cout[7], set[7], overflow   , ALU_src1[7], ALU_src2[7], 0   , Ainvert, Binvert, cout[6],op);

endmodule

