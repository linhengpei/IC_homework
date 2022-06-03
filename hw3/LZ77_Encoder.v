module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);
input            clk;
input 		 reset;
input 	   [7:0] chardata;
output reg       valid;
output           encode;
output reg       finish;
output reg [3:0] offset;
output reg [2:0] match_len;
output reg [7:0] char_nxt;

reg [3:0]  string [2047:0];
reg [2:0]  state ; 

reg  [11:0] ahead_index;

reg  [10:0] index1;  //point to search_buffer
reg  [11:0] index2;  //point to look_ahead_buffer

reg  [2:0] len_buf;
assign    encode = 1;

parameter   search_len = 4'd9,
            ahead_len  = 4'd8;    
// debug
reg [3:0] search_buffer [8:0];
reg [3:0]  ahead_buffer [7:0];





always@(posedge clk , posedge reset)begin
if(reset)begin
valid  <= 0;
index2 <= 0;
state <= 0;
len_buf <=0;
ahead_index  <= 1;
finish <= 0;
end
else begin
   case(state)
       0:begin       
           string[index2] <= chardata;
           index2 <=   index2 + 1;
           if(  index2 == 2048)
              state <= 1;
         end    // save chardata in string
       1:begin 
           valid <= 1;
           offset <= 0;
           match_len<= 0;
           char_nxt <= string[0];   
           state <= 2;
         end   //first output
       2:begin  
           valid     <= 0;
           match_len <= 0;
    
           if( ahead_index < search_len)
               index1 <= 0;
           else
               index1 <= ahead_index - search_len; // index1 point to search_buffer[8] 
           index2 <=  ahead_index;                 // index1 point to look_ahead_buffer[7] 
           state <= 3;      
        // debug
          search_buffer [8] <= string [ahead_index - 9];
          search_buffer [7] <= string [ahead_index - 8];
          search_buffer [6] <= string [ahead_index - 7];
          search_buffer [5] <= string [ahead_index - 6];
          search_buffer [4] <= string [ahead_index - 5];
          search_buffer [3] <= string [ahead_index - 4];
          search_buffer [2] <= string [ahead_index - 3];
          search_buffer [1] <= string [ahead_index - 2];
          search_buffer [0] <= string [ahead_index - 1];
        

          ahead_buffer [7] <= string [ahead_index];
          ahead_buffer [6] <= string [ahead_index +1 ];
          ahead_buffer [5] <= string [ahead_index +2 ];
          ahead_buffer [4] <= string [ahead_index +3 ];
          ahead_buffer [3] <= string [ahead_index +4 ];
          ahead_buffer [2] <= string [ahead_index +5 ];
          ahead_buffer [1] <= string [ahead_index +6 ];
          ahead_buffer [0] <= string [ahead_index +7 ];
        // debug
          end
        /* 
           step 3 ~ 6
           string compare 

           when len_buf == 7 stop cnmparing because len_buf only have 3 bits
          
           In theory len_buf maximun is MIN( search_len , ahead_len )
        */
       3:begin 
           if(string[index1] == string[index2] && len_buf < 7 && index2 < 2048)begin 
               index1 <= index1 +1;
               index2 <= index2 +1;
               len_buf <= len_buf + 1;
           end
           else 
               state <= 4;      
           end			   
       4:begin  
               if(len_buf >  match_len  || match_len == 0)begin
                    match_len <= len_buf;

                    if(index2 ==2048)
                       char_nxt <= 36;
                    else
                       char_nxt <= string[index2];
                    offset <=  ahead_index - 1- index1  + len_buf ;
                end   // record maxium
                state <= 5;
           end
        5:begin   
                index1 <= index1 - len_buf+ 1;       // move index1 to next one
                index2 <= ahead_index;               // move index2 to ahead_buffer
                len_buf <= 0;                       
                if(index1 + 1  == index2 ) begin  //end of compare
                   state <= 6 ;
                   valid <= 1 ;
                end
                else
                   state <= 3 ;  
          end
       6:begin  
            valid <= 0;
            ahead_index  <=  ahead_index  + match_len + 1;  // move ahead_index
            if(char_nxt == 36)
                 state <= 7;  
            else
                 state <=2;
         end                 
       7: finish <= 1;   
  endcase                
end // end else
end // end always
endmodule
