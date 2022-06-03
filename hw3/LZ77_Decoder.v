module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output   reg		encode;
output       	        finish;
output 	 reg	[7:0] 	char_nxt;
assign finish = (char_nxt == 36) ? 1: 0;   // " $ " signed

reg [3:0] search_buffer [8:0];
reg [2:0] counter;

always@( posedge clk)begin
if(reset) begin
encode <= 0;
counter <= 0;
end
else begin
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
                         
         search_buffer [1] <= search_buffer [0] ;
         search_buffer [2] <= search_buffer [1] ;
       	 search_buffer [3] <= search_buffer [2] ;
	 search_buffer [4] <= search_buffer [3] ;
	 search_buffer [5] <= search_buffer [4] ;
	 search_buffer [6] <= search_buffer [5] ;
	 search_buffer [7] <= search_buffer [6] ;
	 search_buffer [8] <= search_buffer [7] ;             	
end // end else
end // end always
endmodule

