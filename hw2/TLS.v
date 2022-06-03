module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output    reg   Gout;
output    reg   Yout;
output    reg   Rout;

reg [1:0] current_state,next_state;
parameter [1:0] green  = 2'b01 ,
                yellow = 2'b10 ,
                red    = 2'b11 ;

reg [3:0]g_duration;
reg [3:0]y_duration;
reg [3:0]r_duration;
reg [3:0]counter;

always@( * ) begin
  case(current_state)
    green  : next_state = yellow ;
    yellow : next_state = red    ;
    red    : next_state = green  ;
    default: next_state = green  ;
   endcase
end            // next state combination
 
always@(posedge clk , posedge reset)begin
if(reset)begin
g_duration  <= 0;
y_duration  <= 0;
r_duration  <= 0;
end
else if (Set == 1)begin
       g_duration  <= Gin;
       y_duration  <= Yin;
       r_duration  <= Rin;
       current_state   <= green;
       counter <= 0; 
end
else if (Jump == 1)begin
      current_state  <= red;
      counter <= 0;           
end
else if( Stop == 0)begin
     if(( current_state == green  && counter == g_duration-1 ) ||
        ( current_state == yellow && counter == y_duration-1 ) ||
        ( current_state == red    && counter == r_duration-1 ))begin  // 0 ~ N-1
           current_state <= next_state;
           counter <= 0;
     end
     else 
           counter <= counter + 1;
end 
end         // sequential 

always@( * ) begin
  case(current_state)
    green:begin
          Gout = 1;
          Yout = 0;
          Rout = 0;
          end
    yellow:begin
          Gout = 0;
          Yout = 1;
          Rout = 0;
          end
    red:begin
          Gout = 0;
          Yout = 0;
          Rout = 1;
          end
    default:begin
          Gout = 0;
          Yout = 0;
          Rout = 0;
          end
    endcase
end            //output logic combination

endmodule
