`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]		in_data;
	input		[7:0]		data_rd;
	output 		reg		req;
	output 		reg	 	wen;
	output 		reg [12:0]	addr;
	output 		reg [7:0]	data_wr;
	output 				done;
reg  [2:0] state ;
reg  [6:0] x , y;
wire [12:0] position ;
assign position =   x  +  (y << 7);  // posiotion = 128*y + x
assign  done = (x == 1 && y == 63 )? 1 : 0;

reg  [15:0] data[4:0];

wire [7:0]D1,D2,D3;
assign D1 = (data[0] > data[4])? data[0] - data[4]: data[4] - data[0];
assign D2 = (data[1] > data[3])? data[1] - data[3]: data[3] - data[1];
assign D3 = (data[2] > data_rd)? data[2] - data_rd: data_rd - data[2];

wire [7:0] d1,d2;
MIN name1(D1,D2,D3,d1,d2);
wire [20:0]max1,max2,max3;
assign   max1 =500-d1;
assign   max2 =200-d2;
assign   max3 =4'd0;

always@(posedge clk , posedge rst)begin
if(rst == 1)begin
state <= 0;
x <= 0;
y <= 0;
end
else if(ready == 1)begin 
     case(state)
       0:begin
         req <= 1;
         wen <= 0;
         state <= state + 1; 
         end
       1:begin  // write Grayscale into Result
         req <= 0 ;
         wen <= 1 ; 
         addr    <= position ;
         data_wr   <= in_data  ;
         x <= x + 1;
         if( y == 62 && x == 127)begin     		
              y <= 1 ;
              state <= state + 1;    // end write
         end
         else if( x == 127) begin
              y <= y + 2;
              state <= state - 1 ;   // change line
         end

         end
       /*
        read order :
        X  |     2    |  4
           | position |
        X  |     1    |  3  

        save reg : 
        data[0]  |   data[1]  |  
                 |   position | 
        data[2]  |   data[3]  |   data[4]
        */
       2:begin    // calculate even line 
         wen  <= 0 ;
         addr <= position + 128 ;
         state <= state + 1 ;  
         end
       3:begin
         addr <= position - 128 ;
         data[3] <= data_rd ;
         state <= state + 1 ;
         end
       4:begin  
         if(x == 0 || x == 127)begin
              wen <= 1 ;
              addr <= position ;
              x <= x + 1;
              data[2] <= data[3];
              data[0] <= data_rd;    // left shift data
              state <= state - 2 ;
              data_wr <= (data[3]+ data_rd)>>1;
              if(x == 127)
                 y <= y + 2;
         end  
         else begin
              wen <= 0;
              addr <= position + 129 ;
              data[1] <= data_rd ;
              state <= state + 1 ;
              
         end
         end
       5:begin
         addr <= position - 127 ;
         data[4] <= data_rd ;
         state <= state + 1 ;
         end
       6:begin
         wen <= 1 ;
         addr <= position ;
         data[0] <= data[1];
         data[2] <= data[3];
         data[3] <= data[4];  // left shift data
         if(D2 <= D3 && D3 <= D1)begin  //D2 <= D3 <= D1
               data_wr <= ( max1*(data[1]+data[3])
                          + max2*(data[2]+data_rd) 
                          + max3*(data[0]+data[4]))/(2*(max1+max2+max3));
         end
         else if(D2 <= D3 && D2 <= D1 && D1 <= D3)begin //D2 <= D3 <= D1
                 data_wr <=( max1*(data[1]+data[3]) 
                           + max2*(data[0]+data[4]) 
                           + max3*(data[2]+data_rd))/(2*(max1+max2+max3));
         end
         else if(D1 <= D2 && D2 <= D3)begin  //D1 <= D2 <= D3
               data_wr <=( max1*(data[0]+data[4]) 
                         + max2*(data[1]+data[3]) 
                         + max3*(data[2]+data_rd))/(2*(max1+max2+max3));
         end
         else if(D1 <= D2 && D1 <= D3 && D3 <= D2)begin //D1 <= D3 <= D2
                 data_wr <=( max1*(data[0]+data[4]) 
                           + max2*(data[2]+data_rd) 
                           + max3*(data[1]+data[3]))/(2*(max1+max2+max3));
         end
         else if(D3 <= D1 && D1 <= D2)begin  //D3 <= D1 <= D2
               data_wr <=( max1*(data[2]+data_rd) 
                         + max2*(data[0]+data[4]) 
                         + max3*(data[1]+data[3]))/(2*(max1+max2+max3));
         end
         else begin //D3 <= D2 <= D1
                 data_wr <=( max1*(data[2]+data_rd) 
                           + max2*(data[1]+data[3])
                           + max3*(data[0]+data[4]))/(2*(max1+max2+max3));
         end
         x <= x + 1 ;
         state <= state - 2 ;
         end      
    endcase 
  
end  // end else
end // end always
endmodule


module MIN(D1,D2,D3,out1,out2);
input [7:0] D1;
input [7:0] D2;
input [7:0] D3;
output reg[7:0] out1; 
output reg[7:0] out2;
always@(*)begin
if(D2 <= D3 && D3 <= D1)begin  //D2 <= D3 <= D1
       out1 = D2;
       out2 = D3;
end
else if(D2 <= D3 && D2 <= D1 && D1 <= D3)begin //D2 <= D1 <= D3
       out1 = D2;
       out2 = D1;
end
else if(D1 <= D2 && D2 <= D3)begin  //D1 <= D2 <= D3
       out1 = D1;
       out2 = D2;
end
else if(D1 <= D2 && D1 <= D3 && D3 <= D2)begin //D1 <= D3 <= D2
       out1 = D1;
       out2 = D3;          
end
else if(D3 <= D1 && D1 <= D2)begin  //D3 <= D1 <= D2
       out1 = D3;
       out2 = D1;       
end
else begin //D3 <= D2 <= D1
       out1 = D3;
       out2 = D2;           
end


end
endmodule
