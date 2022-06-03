`timescale 1ns/10ps
module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input			clk;
	input			rst;
	input		 [7:0]	in_data;
	input		 [7:0]	data_rd;
	output	     reg        req;
	output	     reg	wen;
	output	     reg [9:0]	addr;
	output           [7:0]	data_wr;
	output       	        done;
	
reg  [2:0] state ;
reg  [4:0] x , y;
wire [9:0] position ;
assign position =   x  +  (y << 5);  // posiotion = 32*y + x
assign  done = (x == 1 && y == 31 )? 1 : 0;

reg  [7:0] data[4:0];

reg [8:0] data1,data2;
assign data_wr = ( data1 + data2 )>> 1;

reg  [7:0]min;
wire [7:0]min2;
reg  [7:0]temp;
assign min2 =(data_rd >temp)? data_rd - temp : temp - data_rd ;

always@(posedge clk , posedge rst)begin
if(rst == 1)begin
state <= 0;
x <= 0;
y <= 0;
end
else begin 
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
         data1   <= in_data  ;
         data2   <= in_data  ;
         x <= x + 1;
         if( y == 30 && x == 31)begin     		
              y <= 1 ;
              state <= state + 1;    // end write
         end
         else if( x == 31) begin
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
         addr <= position + 32 ;
         state <= state + 1 ;  
         end
       3:begin
         addr <= position - 32 ;
         data[3] <= data_rd ;
         state <= state + 1 ;
         temp <= data_rd;   //  save data[3] in temp
         end
       4:begin
          data1 <= data[3];
          data2 <= data_rd;    // data_wr <= ( data_rd + data[3] ) >> 1  	  
         if(x == 0 || x == 31)begin
              wen <= 1 ;
              addr <= position ;
              x <= x + 1;
              data[2] <= data[3];
              data[0] <= data_rd;    // left shift data
              state <= state - 2 ;
              
              if(x == 31)
                 y <= y + 2;
         end  
         else begin
              wen <= 0;
              addr <= position + 33 ;
              data[1] <= data_rd ;
              state <= state + 1 ;
              min <= min2;    // min = D2  min2 =(data_rd > data[3])? data_rd - data[3] : data[3] - data_rd 
              temp <= data[0];//
         end
         end
       5:begin
         addr <= position - 31 ;
         data[4] <= data_rd ;
         state <= state + 1 ;

         temp <= data[2];//
         if(min2 < min)begin      // min2 =(data_rd > data[0])? data_rd - data[0] : data[0] - data_rd 
                data1 <= data[0];
                data2 <= data_rd;  //  data_wr <= ( data[0] + data_rd ) >> 1  ;   // D1
                min <= min2;       // min <= ( data_rd > data[0])? data_rd - data[0] : data[0] - data_rd   
              end
         end
       6:begin
         wen <= 1 ;
         addr <= position ;
         if(min2 < min)begin     // min2 =(data_rd > data[2])? data_rd - data[2] : data[2] - data_rd  
               data1 <= data[2];
               data2 <= data_rd;     // data_wr <= ( data_rd + data[2] ) >> 1 
         end

         data[0] <= data[1];
         data[2] <= data[3];
         data[3] <= data[4];  // left shift data
         temp    <= data[4];  
         x <= x + 1 ;
         state <= state - 2 ;
         end
               
    endcase 
  
end  // end else
end // end always
endmodule

/* 221 26
module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input			clk;
	input			rst;
	input		 [7:0]	in_data;
	input		 [7:0]	data_rd;
	output	     reg        req;
	output	     reg	wen;
	output	     reg [9:0]	addr;
	output           [7:0]	data_wr;
	output       	        done;
	
reg  [2:0] state ;
reg  [4:0] x , y;
wire [9:0] position ;
assign position =   x  +  (y << 5);  // posiotion = 32*y + x
assign  done = (x == 1 && y == 31 )? 1 : 0;

reg  [7:0] data[4:0];

reg [8:0] data1,data2;
assign data_wr = ( data1 + data2 )>> 1;




reg  [7:0]min;
wire [7:0]min2;
reg  [7:0]temp;
assign min2 =(data_rd >temp)? data_rd - temp : temp - data_rd ;

always@(posedge clk , posedge rst)begin
if(rst == 1)begin
state <= 0;
x <= 0;
y <= 0;
end
else begin 
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
         data1   <= in_data  ;
         data2   <= in_data  ;
         x <= x + 1;
         if( y == 30 && x == 31)begin     		
              y <= 1 ;
              state <= state + 1;    // end write
         end
         else if( x == 31) begin
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
         
       2:begin    // calculate even line 
         wen  <= 0 ;
         addr <= position + 32 ;
         state <= state + 1 ;  
         end
       3:begin
         addr <= position - 32 ;
         data[3] <= data_rd ;
         state <= state + 1 ;
         temp <= data_rd;   //  save data[3] in temp
         end
       4:begin
          data1 <= data[3];
          data2 <= data_rd;    // data_wr <= ( data_rd + data[3] ) >> 1  	  
         if(x == 0 || x == 31)begin
              wen <= 1 ;
              addr <= position ;
              x <= x + 1;
              data[2] <= data[3];
              data[0] <= data_rd;    // left shift data
              state <= state - 2 ;
              
              if(x == 31)
                 y <= y + 2;
         end  
         else begin
              wen <= 0;
              addr <= position + 33 ;
              data[1] <= data_rd ;
              state <= state + 1 ;
              min <= min2;    // min = D2  min2 =(data_rd > data[3])? data_rd - data[3] : data[3] - data_rd 
              temp <= data[0];//
         end
         end
       5:begin
         addr <= position - 31 ;
         data[4] <= data_rd ;
         state <= state + 1 ;

         temp <= data[2];//
         if(min2 < min)begin      // min2 =(data_rd > data[0])? data_rd - data[0] : data[0] - data_rd 
                data1 <= data[0];
                data2 <= data_rd;  //  data_wr <= ( data[0] + data_rd ) >> 1  ;   // D1
                min <= min2;       // min <= ( data_rd > data[0])? data_rd - data[0] : data[0] - data_rd   
              end
         end
       6:begin
         wen <= 1 ;
         addr <= position ;
         if(min2 < min)begin     // min2 =(data_rd > data[2])? data_rd - data[2] : data[2] - data_rd  
               data1 <= data[2];
               data2 <= data_rd;     // data_wr <= ( data_rd + data[2] ) >> 1 
         end

         data[0] <= data[1];
         data[2] <= data[3];
         data[3] <= data[4];  // left shift data
         temp    <= data[4];  
         x <= x + 1 ;
         state <= state - 2 ;
         end
               
    endcase 
  
end  // end else
end // end always
endmodule
*/
