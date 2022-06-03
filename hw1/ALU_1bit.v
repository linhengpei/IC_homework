`include "FA.v"
module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output  reg  result;
output   c_out;
output   set;                 
output   overflow;    

wire x,y;
assign x =(Ainvert == 1) ? !a : a;
assign y =(Binvert == 1) ? !b : b; 

wire wire0,wire1,wire2;
assign wire0 = x & y;
assign wire1 = x | y;

FA name( .s(set), .carry_out(c_out), .x(x), .y(y), .carry_in(c_in));

assign overflow = c_in ^ c_out;

always@( * )begin
  case(op)
   2'b00: result = wire0;
   2'b01: result = wire1;
   2'b10: result = set  ;
   2'b11: result = less ;
  endcase
end

endmodule


