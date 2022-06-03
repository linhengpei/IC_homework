module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);
input 			clk;
input 			reset;
input			ready;
input 	     [4:0] 	code_pos;
input 	     [4:0] 	code_len;
input 	     [7:0] 	chardata;
output   reg		encode;
output  		finish;
output 	 reg [7:0] 	char_nxt;

assign finish = (char_nxt == 36) ? 1: 0;   // " $ " signed
reg [4:0] i;
reg [3:0] search_buffer [29:0];
reg [4:0] counter;

always@( posedge clk)begin
if(reset) begin
encode <= 0;
counter <= 0;
end
else if(ready == 1)begin
        if(code_len == 0  || counter == code_len )begin
            counter <= 0;  
       	    char_nxt <= chardata ;
            search_buffer [0] <= chardata ;
         end
       	 else begin
            counter <= counter + 1;                
            char_nxt <= search_buffer [code_pos] ;
            search_buffer [0] <=  search_buffer [code_pos] ;            
         end    //  if(counter != code_len)
                         
         for(  i = 1 ; i < 30 ; i = i + 1) begin
              search_buffer [i] <= search_buffer [i-1] ;
          end                 	
end // end else
end // end always
            
              
endmodule
