////////////////////////////
/// keyboard interface to DE2
/// Feb 13 2015
/// ps2 interface
/// proto type
///////////////////////////

module keyboardAttempt4 ( // 11 for d, 10 for L, msb holds go or don't go.
 hex0_out, 		// 7 bit binary Output
 hex1_out, 		// 7 bit binary Output
 hex2_out, 		// 7 bit binary Output
 hex3_out, 		// 7 bit binary Output
 hex4_out, 		// 7 bit binary Output
 hex5_out, 		// 7 bit binary Output
 clk		, 		// input 50 MHz clk
 ps_clk 	, 		// ps2 clock
 ps_data	, 		// ps2 data
 gpio,				// 40 pin header
 toFSM
 );			// ADDED: 1 or 0 to send to the FSM


 input clk;
 input ps_data;
 input ps_clk;
 
 wire thereIsAClap = 1'b1; //ADDED TEWMP TO TEST FUNCTIONALITY
 
 output[9:0] gpio;
 output[6:0] hex0_out ;
 output[6:0] hex1_out ;
 output[6:0] hex2_out ;
 output[6:0] hex3_out ;
 output[6:0] hex4_out ;
 output[6:0] hex5_out ;

  output [1:0] toFSM; // 2 bit. First if to send, second contains value. ADDED
 reg [1:0] regToFSM; // ADDED

 reg [9:0] gpio;
 reg [6:0] hex4_out ; // changed hex4_out from hex0_out (same for hex5_out)
 reg [6:0] hex5_out ;
 
 //internal registers
  
 reg [13:0] hex_out ;
 reg [7:0] counter;
 reg [10:0] data;
 reg valid;
 reg cnt;
 reg cnt2;

 /////////////////////////////////////////////////////////////////////////
 // characters and symbols created for displaying values on Hex display //
 // some require two HEX displays others don't                          // 
 // Note not all key codes from keyboard are here. Some are missing     //
 // from this list,you may create them by adding them                   //
 /////////////////////////////////////////////////////////////////////////
 
 parameter HEX_0 = 14'b11111111000000;		// zero
 parameter HEX_1 = 14'b11111111111001;		// one
 parameter HEX_2 = 14'b11111110100100;		// two
 parameter HEX_3 = 14'b11111110110000;		// three
 parameter HEX_4 = 14'b11111110011001;		// four
 parameter HEX_5 = 14'b11111110010010;		// five
 parameter HEX_6 = 14'b11111110000010;		// six
 parameter HEX_7 = 14'b11111111111000;		// seven
 parameter HEX_8 = 14'b11111110000000;		// eight
 parameter HEX_9 = 14'b11111110011000;		// nine
 parameter HEX_a = 14'b11111110001000;		// a
 parameter HEX_b = 14'b11111110000011;		// b
 parameter HEX_c = 14'b11111111000110;		// c
 parameter HEX_d = 14'b11111110100001;		// d
 parameter HEX_e = 14'b11111110000110;		// e
 parameter HEX_f = 14'b11111110001110;		// f
 parameter HEX_g = 14'b01100101000110;		// g
 parameter HEX_h = 14'b11111110001001;		// h
 parameter HEX_i = 14'b10001101110110;		// I
 parameter HEX_j = 14'b11111101100000;		// J
 parameter HEX_k = 14'b01101010001011;		// K
 parameter HEX_l = 14'b11111111000111; 	// L
 parameter HEX_m = 14'b10110001001100;		// M
 parameter HEX_n = 14'b11100010001011;		// N
 parameter HEX_o = 14'b11100001000110;		// O
 parameter HEX_p = 14'b11111110001100;		// P
 parameter HEX_q = 14'b11101111000000;		// Q
 parameter HEX_r = 14'b01001000001110;		// R
 parameter HEX_s = 14'b01100100010110;		// S
 parameter HEX_t = 14'b10011101111110;		// T
 parameter HEX_u = 14'b11111111000001;		// U
 parameter HEX_v = 14'b11011011011011;		// V
 parameter HEX_w = 14'b11000011000011; 	// w
 parameter HEX_x = 14'b01101010010011; 	// x
 parameter HEX_y = 14'b01111010011011; 	// y
 parameter HEX_z = 14'b01101000100110;		// Z
 parameter HEX_en = 14'b01010110000110; 	// enter
 parameter HEX_ec = 14'b10001100000110;	// ESC
 parameter HEX_bs = 14'b00100100000011;	// back space
 parameter left =  14'b01100000111111;		// left arrow
 parameter right = 14'b01111110000110;		// right arrow
 parameter up   =  14'b10011001011000;		// up arrow
 parameter down =  14'b10000111100001;		// down arrow
 parameter off   = 7'b1111111;		// display off
 

///////////////////////////////////////
/////// counters enables       ////////
///////////////////////////////////////	

wire cnt1 = (counter >= 8'd11 )? 1'b1 : 1'b0;

/////////////////////////////
/// clock for PS2      //////
/////////////////////////////	

	 always @ (negedge ps_clk or posedge cnt1 )
	 
	 begin 
	 
		if (cnt1)
		begin
			counter <= 0;
			cnt <= 1;
		end
		
			else
			
		begin
			
			counter <= counter + 1;
			cnt <= 0;
			
		end	
	end
	
	
/////////////////////////////////////////////////////////////////////
/// Serial shift register to reteive data from the PS_data line   ///
/////////////////////////////////////////////////////////////////////

	
always @ (negedge ps_clk or  posedge cnt )

 begin
 
 if (cnt) begin  valid <= 1; end
 
 else
 
 case (counter)
 	
		8'd0	: begin valid = 1; data[0] = ps_data; end // start
		8'd1	: begin valid = 0; data[1] = ps_data; end // bit 0
		8'd2	: begin valid = 0; data[2] = ps_data; end // bit 1
		8'd3	: begin valid = 0; data[3] = ps_data; end // bit 2 	
		8'd4	: begin valid = 0; data[4] = ps_data; end // bit 3
		
		8'd5	: begin valid = 0; data[5] = ps_data; end // bit 4
		8'd6	: begin valid = 0; data[6] = ps_data; end // bit 5		
		8'd7	: begin valid = 0; data[7] = ps_data; end // bit 6
		8'd8	: begin valid = 0; data[8] = ps_data; end // bit 7
		
		8'd9	: begin valid = 1; data[9] = ps_data; end // parity
		8'd10 : begin valid = 1; data[10] = ps_data; end // stop
		8'd11	: begin valid = 1; end 
		8'd12	: begin valid = 1; end

	endcase
end
	
 
///////////////////////////////////////////////////////////////////////////
/// compare and select key code value to be displayed on HEX displays   ///
///////////////////////////////////////////////////////////////////////////

 always @(posedge clk )	
 
	begin
	
		
		hex_out = 14'b11111111111111;   // default setting
	
		
		if (data[8:1] == 8'b01000101) begin		
		 hex_out <= HEX_0; 
		 end
		 
		 else		 
		 
		 if (data[8:1] == 8'b00010110) begin	
		 hex_out <= HEX_1; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00011110) begin  
		 hex_out <= HEX_2; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00100110) begin 
		 hex_out <= HEX_3; 
		 end 
		 
		 else 
		 
		 if (data[8:1] == 8'b00100101) begin
		  hex_out <= HEX_4; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00101110) begin 
		 hex_out <= HEX_5; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00110110) begin
		 hex_out <= HEX_6; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00111101) begin
		 hex_out <= HEX_7; 
		 end
		 
		 else
		 
		 if (data[8:1] == 8'b00111110) begin
		 hex_out <= HEX_8;
		 end
		 
		 else
		 		 
		 if (data[8:1] == 8'b01000110) begin  
		 hex_out <= HEX_9; 
		 end
		
		else
		
		if (data[8:1] == 8'b00011100) begin   
		hex_out <= HEX_a; 
		end
		
		else
		
		if (data[8:1] == 8'b00110010) begin
		hex_out <= HEX_b;
		end
		
		else
		
		if (data[8:1] == 8'b00100001) begin  
		hex_out <= HEX_c; 
		end
		
		else
		
		if (data[8:1] == 8'b00100011) begin  
		hex_out <= HEX_d; 
			regToFSM[0] = 1'b1; // ADDED. Add MSB later
			if(thereIsAClap == 1'b1) begin
				 regToFSM[1] = 1'b1;
			end else begin
				 regToFSM[1] = 1'b0;
			end
		end
		
		if (data[8:1] == 8'b00100100) begin  
		hex_out <= HEX_e; 
		end
		
		else
		
		if (data[8:1] == 8'b00101011) begin  
		hex_out <= HEX_f; 
		end
		
		else
		
		if (data[8:1] == 8'b00110100) begin  
		hex_out <= HEX_g; 
		end
		
		else

		if (data[8:1] == 8'b00110011) begin  
		hex_out <= HEX_h; 
		end
		
		else
		
		if (data[8:1] == 8'b01000011) begin  
		hex_out <= HEX_i; 
		end
		
		else
		
		if (data[8:1] == 8'b00111011) begin  
		hex_out <= HEX_j; 
		end
		
		else
		
		if (data[8:1] == 8'b01000010) begin  
		hex_out <= HEX_k; 
		end
		
		else 
		
		if (data[8:1] == 8'b01001011) begin  
		hex_out <= HEX_l; 
		
		 regToFSM[0] = 1'b0; // ADDED

			if(thereIsAClap == 1'b1) begin
				 regToFSM[1] = 1'b1;
			end else begin
				 regToFSM[1] = 1'b0;
			end
		end
		
		else
		
		if (data[8:1] == 8'b00111010) begin  
		hex_out <= HEX_m; 
		end
		
		else
		
		if (data[8:1] == 8'b00110001) begin  
		hex_out <= HEX_n; 
		end
		
		else
		
		if (data[8:1] == 8'b01000100) begin  
		hex_out <= HEX_o; 
		end
		
		else
		
		if (data[8:1] == 8'b01001101) begin  
		hex_out <= HEX_p; 
		end
		
		else
		
		if (data[8:1] == 8'b00010101) begin  
		hex_out <= HEX_q; 
		end
		
		else
		
		if (data[8:1] == 8'b00101101) begin  
		hex_out <= HEX_r; 
		end
		
		else
		
		if (data[8:1] == 8'b00011011) begin  
		hex_out <= HEX_s; 
		end
		
		if (data[8:1] == 8'b00101100) begin  
		hex_out <= HEX_t; 
		end
		
		else
		
		if (data[8:1] == 8'b00111100) begin  
		hex_out <= HEX_u; 
		end
		
		else
		
		if (data[8:1] == 8'b00101010) begin  
		hex_out <= HEX_v; 
		end
		
		else
		
		if (data[8:1] == 8'b00011101) begin  
		hex_out <= HEX_w; 
		end
		
		else
		
		if (data[8:1] == 8'b00100010) begin  
		hex_out <= HEX_x; 
		end
		
		else
		
		if (data[8:1] == 8'b00110101) begin  
		hex_out <= HEX_y; 
		end
		
		else
		
		if (data[8:1] == 8'b00011010) begin  
		hex_out <= HEX_z; 
		end
		
		else
		
		if (data[8:1] == 8'b01101011) begin  
		hex_out <= right; 
		end
		
		else
		
		if (data[8:1] == 8'b01110100) begin  
		hex_out <= left; 
		end
		
	   if (data[8:1] == 8'b01110101) begin  
		hex_out <= up; 
		end
		
		else
		
		if (data[8:1] == 8'b01110010) begin  
		hex_out <= down; 
		end
		
		else
		
		if (data[8:1] == 8'b01011010) begin  
		hex_out <= HEX_en; 
		end
		
	   if (data[8:1] == 8'b01110110) begin  
		hex_out <= HEX_ec; 
		end
		
		else
		
		if (data[8:1] == 8'b01100110) begin  
		hex_out <= HEX_bs; 
		end
	end
	
/////////////////////////////////////
// 40 pin header signal for scope  //
/////////////////////////////////////

always gpio[0] <= valid;
always gpio[1] <= ps_clk;
always gpio[2] <= ps_data;
always gpio[3] <= cnt;
always gpio[4] <= cnt1;
always gpio[5] <= counter[0];
always gpio[6] <= counter[1];
always gpio[7] <= counter[2];
always gpio[8] <= counter[3];
always gpio[9] <= counter[4];
////////////////////////////////////
// values for HEX display       ////
////////////////////////////////////

hexDisplay u10(regToFSM[0], regToFSM[1], hex0_out);

assign toFSM[1:0] = regToFSM[1:0]; // ADDED: converts the registe value to a wire for the output

always hex4_out <= hex_out[6:0]; // ADDED (Changed) to hex5
always hex5_out <= hex_out[13:7]; // ADDED (changed) to hex 5
// assign hex0_out = off;
assign hex1_out = off;
assign hex2_out = off;
assign hex3_out = off;

endmodule
