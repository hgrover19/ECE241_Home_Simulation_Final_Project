module datapath( //note: instantiate room coordinate selection FSMs inside datapath

	input clock,
	input reset,
	input loadenable,
	input enable0, enable1, enable2, enable3, enable4,
	input room0, room1, room2, room3, room4, //switch input (select room number 0-9)
	input selonoff,
	input [2:0] selsw,
	input [1:0] selfunct,
	input clearinitsignal,
	input keyboardin, //keyboard input (L or D)
	input audin,	//Audio input (on or off, 1/0)
	input drawen,
	input [7:0] MAX_X_PIXELS,
	input [6:0] MAX_Y_PIXELS,
	output reg [7:0] xcoord, 
	output reg [6:0] ycoord,
	output reg [3:0] plotcounter,
	output reg [2:0] colour,
	output reg [7:0] clearxcounter,
	output reg [8:0] clearycounter
	//output reg [3:0] audout

);
	
	//declare storage registers
	reg [2:0]loadkeyboard; //register storing keyboard input
	reg roomnoreg; //register storing room number
	reg loadaudio; //register storing audio input
	reg [7:0] x_register;
	reg [6:0] y_register;
	reg [7:0] startxcoord;
	reg [6:0] startycoord;
	
	//ROOM 0 REGISTERS
	//reg funct0;
	//reg onoff0;
	
	//ROOM 1 REGISTERS
	reg funct1;
	reg onoff1;
	
	//ROOM 2 REGISTERS
	reg funct2;
	reg onoff2;
	
	//ROOM 3 REGISTERS
	reg funct3;
	reg onoff3;
	
	//ROOM 4 REGISTERS
	reg funct4;
	reg onoff4;
	
	reg [5:0] coordsel0, coordsel1, coordsel2, coordsel3, coordsel4; //to select x and y coordinates for each room (add back coordsel0)
	
	//load audio signal registers
	/*
	reg [3:0] L1aud;
	reg [3:0] L0aud;
	reg [3:0] D1aud;
	reg [3:0] D0aud;
	*/
			
	//also, load x and y coordinates for each vga display image
	reg [7:0] L0x;
	reg [6:0] L0y;
	reg [7:0] D0x;
	reg [6:0] D0y;
			
	reg [7:0] L1x;
	reg [6:0] L1y;
	reg [7:0] D1x;
	reg [6:0] D1y;
			
	reg [7:0] L2x;
	reg [6:0] L2y;
	reg [7:0] D2x;
	reg [6:0] D2y;
			
	reg [7:0] L3x;
	reg [6:0] L3y;
	reg [7:0] D3x;
	reg [6:0] D3y;
			
	reg [7:0] L4x;
	reg [6:0] L4y;
	reg [7:0] D4x;
	reg [6:0] D4y;	
	
	//datapath logic
	always@ (*) begin
	
		if (reset) begin

			loadkeyboard <= 0;
			roomnoreg <= 0;
			loadaudio <= 0;
			
			//load audio signal registers
			//L1aud <= 3'b000;
			//L0aud <= 3'b001;
			//D1aud <= 3'b010;
			//D0aud <= 3'b011;
			
			//also, load x and y coordinates for each vga display image
			L0x <= 8'd60;
			L0y <= 7'd73;
			D0x <= 8'd69;
			D0y <= 7'd69;
			
			L1x <= 8'd69;
			L1y <= 7'd69;
			D1x <= 8'd69;
			D1y <= 7'd69;
			
			L2x <= 8'd69;
			L2y <= 7'd69;
			D2x <= 8'd69;
			D2y <= 7'd69;
			
			L3x <= 8'd69;
			L3y <= 7'd69;
			D3x <= 8'd60;
			D3y <= 7'd69;
			
			L4x <= 8'd69;
			L4y <= 7'd69;
			D4x <= 8'd69;
			D4y <= 7'd69;

			//reset output signals
			xcoord <= 0;
			ycoord <= 0;
			//audout <= 0;
			
		end
		
		else begin
			
			if (loadenable) begin
			
				loadkeyboard <= keyboardin;
				
				loadaudio <= loadaudio ^ audin;
				
				case (selsw) //select switch input to store into room number register
				
					3'd0: 
						roomnoreg = room1;
					3'd1:
						roomnoreg = room1;
					3'd2:
						roomnoreg = room2;
					3'd3:
						roomnoreg = room3;
					3'd4:
						roomnoreg = room4;
						
					default: roomnoreg =1'b0;
					
				endcase
				
			end
			
			else if (enable0) begin //store function and on/off into room 0 registers
				
				coordsel0 <= {loadkeyboard, selsw}; //DEBUG THIS LINE : possible solution is to verify if funct0, onoff0 actually store values correctly
				
				case (coordsel0) //multiplexer choosing x and y coordinates for printing in room 0
				
					6'b000000: begin //room 0, function D
						startxcoord <= D0x;
						startycoord <= D0y;
					end
					
					6'b001000: begin //room 0, function L
						startxcoord <= L0x;
						startycoord <= L0y;
					end
					
					default: begin
						startxcoord <= 0;
						startycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable1) begin
				
				coordsel1 <= {loadkeyboard, selsw};
				
				case (coordsel1) //multiplexer choosing x and y coordinates for printing in room 1
				
					6'b000001: begin
						startxcoord <= D1x;
						startycoord <= D1y;
					end
					
					6'b001001: begin
						startxcoord <= L1x;
						startycoord <= L1y;
					end
					
					default: begin
						startxcoord <= 0;
						startycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable2) begin
				
				coordsel2 <= {loadkeyboard, selsw};
				
				case (coordsel2) //multiplexer choosing x and y coordinates for printing in room 2
				
					6'b000010: begin
						startxcoord <= D2x;
						startycoord <= D2y;
					end
					
					6'b001010: begin
						startxcoord <= L2x;
						startycoord <= L2y;
					end
					
					default: begin
						startxcoord <= 0;
						startycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable3) begin
				
				coordsel3 <= {loadkeyboard, selsw};
				
				case (coordsel3) //multiplexer choosing x and y coordinates for printing in room 1
				
					6'b000011: begin
						startxcoord <= D3x;
						startycoord <= D3y;
					end
					
					6'b001011: begin
						startxcoord <= L3x;
						startycoord <= L3y;
					end
					
					default: begin
						startxcoord <= 0;
						startycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable4) begin
				
				coordsel4 <= {loadkeyboard, selsw};
				
				case (coordsel4) //multiplexer choosing x and y coordinates for printing in room 1
				
					6'b001100: begin
						startxcoord <= L4x;
						startycoord <= L4y;
					end
					
					6'b000100: begin
						startxcoord <= D4x;
						startycoord <= D4y;
					end
					
					default: begin
						startxcoord <= 0;
						startycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (clearinitsignal) begin
				startxcoord <= 0;
				startycoord <= 0;
				
				xcoord <= clearxcounter;
				ycoord <= clearycounter;
				colour <= 3'b0;
				
			end
			
			else if ((drawen == 1'b1) && (loadkeyboard == 1'b1)) begin //when the door/light is ON
			
				xcoord <= x_register + plotcounter[1:0];
				ycoord <= y_register + plotcounter[3:2];
				colour <= 3'b110;
			
			end
			
			else if ((drawen == 1'b1) && (loadkeyboard == 1'b0)) begin //when the door/light is OFF
			
				xcoord <= x_register + plotcounter[1:0];
				ycoord <= y_register + plotcounter[3:2];
				colour <= 3'b111;
			
			end
			
		
		end
		
	end
	
	always@ (posedge clock)
		begin
			
			if (reset) begin
				plotcounter <= 0;
				clearxcounter <= 0;
				clearycounter <= 0;
			end
			
			else if (drawen) begin
				
				plotcounter <= plotcounter + 1;
				
			end
			
			else if (plotcounter == 4'd15) begin
				
				plotcounter <= 0;
				
			end
			
			else if ((clearxcounter == (MAX_X_PIXELS - 1)) && (clearycounter == (MAX_Y_PIXELS - 1))) begin
				
				clearxcounter <= 0;
				clearycounter <= 0;
				
			end	
			
			else if ((clearxcounter == (MAX_X_PIXELS - 1)) && (clearycounter < (MAX_Y_PIXELS - 1))) begin //reach end of row
			
				clearxcounter <= 0;
				clearycounter <= clearycounter + 1;
				
			end
			
			else if ((clearxcounter < (MAX_X_PIXELS - 1)) && (clearycounter < (MAX_Y_PIXELS - 1))) begin
				
				clearxcounter <= clearxcounter + 1;
			
			end
		
		end
	


endmodule
