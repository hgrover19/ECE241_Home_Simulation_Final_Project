/*
THE FOLLOWING ASSUMPTIONS ARE MADE:

audio input ON  = 1
audio input OFF = 0

function LIGHT = 1
function DOOR  = 0
*/

module project(

	input [5:0] SW,
	input [3:0] KEY,
	input CLOCK_50

); //top level module instantiation
	
	//input wires to controlpath and datapath
	wire keyboardin;
	wire audin;
	wire countDone; //FROM COUNTERS IN VGA DATAPATH
	
	//output wires from datapath
	wire [7:0] xcoordoutput;
	wire [6:0] ycoordoutput;
	wire [3:0] audoutput;
	wire loadkeyboard;
	wire roomnoreg;
	wire loadaudio;
	
	//
	wire [1:0] coordsel0;
	wire funct0;
	wire onoff0;
	
	//enable signal wires
	wire enable0;
	wire enable1;
	wire enable2;
	wire enable3;
	wire enable4;
	wire selonoffsignal;
	wire [1:0] selfunction;
	wire clearstart;
	wire drawenable;
	wire loadenable;
	wire [2:0] selsw;

	controlpath controlpath_inst(
		
		.loadinputs(KEY[1]),
		.clock(CLOCK_50),
		.reset(KEY[0]),
		.clear(KEY[2]),
		.keyboardin(keyboardin),
		.audin(audin),
		.room0(SW[0]),
		.room1(SW[1]),
		.room2(SW[2]),
		.room3(SW[3]),
		.room4(SW[4]),
		.alllocked(KEY[3]),
		.countDone(countDone),
		.enable0(enable0),
		.enable1(enable1),
		.enable2(enable2),
		.enable3(enable3),
		.enable4(enable4),
		.selonoff(selonoffsignal),
		.selfunct(selfunction),
		.clearinitsignal(clearstart),
		.loadenable(loadenable),
		.selsw(selsw)
		
	);
	

	datapath datapath_inst(
	
		.clock(CLOCK_50),
		.reset(KEY[0]),
		.loadenable(loadenable),
		.enable0(enable0),
		.enable1(enable1),
		.enable2(enable2),
		.enable3(enable3),
		.enable4(enable4),
		.room0(SW[0]),
		.room1(SW[1]),
		.room2(SW[2]),
		.room3(SW[3]),
		.room4(SW[4]),
		.selonoff(selonoffsignal),
		.selsw(selsw),
		.selfunct(selfunction),
		.clearinitsignal(clearstart),
		.keyboardin(keyboardin),
		.audin(audin),
		.xcoord(xcoordoutput),
		.ycoord(ycoordoutput),
		.audout(audoutput),
		.coordsel0(coordsel0),
		.funct0(funct0),
		.onoff0(onoff0),
		.loadkeyboard(loadkeyboard),
		.roomnoreg(roomnoreg),
		.loadaudio(loadaudio)
	
	);
	

endmodule


module controlpath(

	input loadinputs, //the pushbutton, loadinputs
	input clock, 
	input reset,
	input clear,
	input keyboardin, //keyboard input (L or D)
	input audin,	//Audio input (on or off, 1/0)
	input room0, room1, room2, room3, room4, //switch input (select room number 0-9)
	input alllocked, //switch input (for "all locked")
	input countDone, //VGA Datapath sends countDone = 1 when finished drawing
	
	output reg enable0, enable1, enable2, enable3, enable4, //signals to select which room we load function and ON/OFF to
	output reg selonoff, //sort stored audio registers by ON/OFF for audio datapath
	output reg [1:0] selfunct, //sort stored audio registers by Light/Door function
	output reg clearinitsignal,
	output reg loadenable, //enable loading of inputs
	output reg [2:0] selsw
	
);

	reg [5:0] current_state, next_state;
	
	localparam
		INPUTS_WAIT = 6'd0, //enable input registers
		LOAD_INPUTS = 6'd1, //button for loading inputs pressed, load data onto input registers
		
		ROOM0 = 6'd2,
		ROOM1 = 6'd3,
		ROOM2 = 6'd4,
		ROOM3 = 6'd5,
		ROOM4 = 6'd6,
		ALLLOCKED = 6'd7,
		
		DONE_DRAW = 6'd8, //Finish drawing VGA display image, so set Done = 1
		DONE = 6'd9,	//Reach this state when Done = 1
		CLEAR = 6'd10, //Clear VGA Display of everything
		DONE_CLEAR = 6'd11; //When finished clearing, set Done = 1
		
	
	//State table:
	
	always @(*)
		begin: state_table
			case(current_state)
				//IMPLEMENT SETUPSCREEN STATE
				
				INPUTS_WAIT: next_state = !loadinputs ? INPUTS_WAIT : LOAD_INPUTS;
				
				LOAD_INPUTS: begin
					if (loadinputs) //if input button on, keep waiting
						next_state = LOAD_INPUTS;
						
					else if (!loadinputs) //if input button off, draw VGA display image based on what is in register
						if (room0 == 1'b1)
							next_state = ROOM0;
						else if (room1 == 1'b1)
							next_state = ROOM1;
						else if (room2 == 1'b1)
							next_state = ROOM2;
						else if (room3 == 1'b1)
							next_state = ROOM3;
						else if (room4 == 1'b1)
							next_state = ROOM4;
						else if (alllocked == 1'b1)
							next_state = ALLLOCKED;
				end
				
				ROOM0: next_state = countDone ? DONE_DRAW : ROOM0;
				
				ROOM1: next_state = countDone ? DONE_DRAW : ROOM1;
				
				ROOM2: next_state = countDone ? DONE_DRAW : ROOM2;
				
				ROOM3: next_state = countDone ? DONE_DRAW : ROOM3;
				
				ROOM4: next_state = countDone ? DONE_DRAW : ROOM4;
				
				ALLLOCKED: next_state = DONE;
				
				DONE_DRAW: next_state = DONE;
				
				DONE: next_state = LOAD_INPUTS;
				
				CLEAR: next_state = countDone ? DONE_CLEAR : CLEAR;
				
				DONE_CLEAR: next_state = DONE;
				
				default: next_state = LOAD_INPUTS;
				
			endcase
		end
	
	//enable signals for each case
	
	
	always @(*)
		begin: enable_signals
			
			//by default, make all enable signals 0
			enable0 = 1'b0;
			enable1 = 1'b0;
			enable2 = 1'b0;
			enable3 = 1'b0;
			enable4 = 1'b0;
			selonoff = 1'b0;
			selfunct = 1'b0;
			clearinitsignal = 1'b0;
			loadenable = 1'b0;
			
			case(current_state)
			
				LOAD_INPUTS: begin
					loadenable = 1'b1;
					if (room0 == 1'b1) //when load is enabled, also send signal to multiplexer that inputs switch input into sw input register
						selsw = 3'd0;
					else if (room1 == 1'b1)
						selsw = 3'd1;
					else if (room2 == 1'b1)
						selsw = 3'd2;
					else if (room3 == 1'b1)
						selsw = 3'd3;
					else if (room4 == 1'b1)
						selsw = 3'd4;
				end
				
				ROOM0: begin //When we have selected room 1, pass input function (L or D) and ON?OFF input to Room 0 registers
					enable0 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selfunct = 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 	
						selfunct = 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selfunct = 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selfunct = 2'b10; 
					end
					
				end 
				
				ROOM1: begin
					enable1 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selfunct = 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 
						selfunct = 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selfunct = 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selfunct = 2'b10; 
					end
				end
				
				ROOM2: begin
					enable2 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selfunct = 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 
						selfunct = 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selfunct = 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selfunct = 2'b10; 
					end
				end
				
				ROOM3: begin
					enable3 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selfunct = 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 
						selfunct = 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selfunct = 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selfunct = 2'b10; 
					end
				end
				
				ROOM4: begin
					enable4 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selfunct = 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 
						selfunct = 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selfunct = 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selfunct = 2'b10; 
					end
				end
				
				ALLLOCKED: begin
					selfunct = 2'b01;
				end
				
				CLEAR: begin
					clearinitsignal = 1'b1;
				end
			
			endcase
		
		end
		
	
	//FFs controlling transition between states
	always@ (posedge clock)
		begin: state_transitions_FFs
		
			if (reset)
				current_state <= INPUTS_WAIT;
				
			else if (clear)
				current_state <= CLEAR;
			
			else
				current_state <= next_state;
		end
				
	
endmodule	
		

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
	output reg [7:0] xcoord, 
	output reg [6:0] ycoord,
	output reg [3:0] audout,
	output reg [1:0] coordsel0,
	output reg funct0,
	output reg onoff0,
	output reg loadkeyboard,
	output reg roomnoreg,
	output reg loadaudio

);
	
	//declare storage registers
	//reg loadkeyboard; //register storing keyboard input
	//reg roomnoreg; //register storing room number
	//reg loadaudio; //register storing audio input
	
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
	
	reg [1:0] coordsel1, coordsel2, coordsel3, coordsel4; //to select x and y coordinates for each room (add back coordsel0)
	
	//load audio signal registers
	reg [3:0] L1aud;
	reg [3:0] L0aud;
	reg [3:0] D1aud;
	reg [3:0] D0aud;
	reg [3:0] alllockedaud;
			
	//also, load x and y coordinates for each vga display image
	reg [7:0] L00x;
	reg [6:0] L00y;
	reg [7:0] L01x;
	reg [6:0] L01y;
	reg [7:0] D00x;
	reg [6:0] D00y;
	reg [7:0] D01x;
	reg [6:0] D01y;
			
	reg [7:0] L10x;
	reg [6:0] L10y;
	reg [7:0] L11x;
	reg [6:0] L11y;
	reg [7:0] D10x;
	reg [6:0] D10y;
	reg [7:0] D11x;
	reg [6:0] D11y;
			
	reg [7:0] L20x;
	reg [6:0] L20y;
	reg [7:0] L21x;
	reg [6:0] L21y;
	reg [7:0] D20x;
	reg [6:0] D20y;
	reg [7:0] D21x;
	reg [6:0] D21y;
			
	reg [7:0] L30x;
	reg [6:0] L30y;
	reg [7:0] L31x;
	reg [6:0] L31y;
	reg [7:0] D30x;
	reg [6:0] D30y;
	reg [7:0] D31x;
	reg [6:0] D31y;
			
	reg [7:0] L40x;
	reg [6:0] L40y;
	reg [7:0] L41x;
	reg [6:0] L41y;
	reg [7:0] D40x;
	reg [6:0] D40y;
	reg [7:0] D41x;
	reg [6:0] D41y;	
	
	//datapath logic
	always@ (posedge clock) begin
	
		if (reset) begin

			loadkeyboard <= 0;
			roomnoreg <= 0;
			loadaudio <= 0;
			funct0 <= 0;
			onoff0 <= 0;
			funct1 <= 0;
			onoff1 <= 0;
			funct2 <= 0;
			onoff2 <= 0;
			funct3 <= 0;
			onoff3 <= 0;
			funct4 <= 0;
			onoff4 <= 0;
			
			//load audio signal registers
			L1aud <= 3'b000;
			L0aud <= 3'b001;
			D1aud <= 3'b010;
			D0aud <= 3'b011;
			alllockedaud <= 3'b100;
			
			//also, load x and y coordinates for each vga display image
			L0x <= 8'd60;
			L0y <= 7'd73;
			D0x <= 8'd69;
			L0y <= 7'd69;
			
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
			audout <= 0;
			
		end
		
		else begin
			
			if (loadenable) begin
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
				
				loadkeyboard <= keyboardin;
				
				loadaudio <= audin;
				
			end
			
			else if (enable0) begin //store function and on/off into room 0 registers
				
				funct0 <= loadkeyboard;
				
				onoff0 <= onoff0^audin;
				
				coordsel0 <= {~loadkeyboard, onoff0}; //DEBUG THIS LINE : possible solution is to verify if funct0, onoff0 actually store values correctly
				
				case (coordsel0) //multiplexer choosing x and y coordinates for printing in room 0
				
					2'b00: begin
						xcoord <= L00x;
						ycoord <= L00y;
					end
					
					2'b01: begin
						xcoord <= L01x;
						ycoord <= L01y;
					end
					
					2'b10: begin
						xcoord <= D00x;
						ycoord <= D00y;
					end
					
					2'b11: begin
						xcoord <= D01x;
						ycoord <= D01y;
					end
					
					default: begin
						xcoord <= 0;
						ycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable1) begin
				
				coordsel1 <= {loadkeyboard, audin};
				
				case (coordsel1) //multiplexer choosing x and y coordinates for printing in room 1
				
					2'b: begin
						xcoord <= L10x;
						ycoord <= L10y;
					end
					
					2'b01: begin
						xcoord <= L11x;
						ycoord <= L11y;
					end
					
					2'b10: begin
						xcoord <= D10x;
						ycoord <= D10y;
					end
					
					2'b11: begin
						xcoord <= D11x;
						ycoord <= D11y;
					end
					
					default: begin
						xcoord <= 0;
						ycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable2) begin
							
				funct2 <= loadkeyboard;
				
				onoff2 <= onoff2^audin;
				
				coordsel2 <= {~funct2, onoff2};
				
				case (coordsel2) //multiplexer choosing x and y coordinates for printing in room 2
				
					2'b00: begin
						xcoord <= L20x;
						ycoord <= L20y;
					end
					
					2'b01: begin
						xcoord <= L21x;
						ycoord <= L21y;
					end
					
					2'b10: begin
						xcoord <= D20x;
						ycoord <= D20y;
					end
					
					2'b11: begin
						xcoord <= D21x;
						ycoord <= D21y;
					end
					
					default: begin
						xcoord <= 0;
						ycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable3) begin
				
				funct3 <= loadkeyboard;
				
				onoff3 <= onoff3^audin;
				
				coordsel3 <= {~funct3, onoff3};
				
				case (coordsel3) //multiplexer choosing x and y coordinates for printing in room 1
				
					2'b00: begin
						xcoord <= L30x;
						ycoord <= L30y;
					end
					
					2'b01: begin
						xcoord <= L31x;
						ycoord <= L31y;
					end
					
					2'b10: begin
						xcoord <= D30x;
						ycoord <= D30y;
					end
					
					2'b11: begin
						xcoord <= D31x;
						ycoord <= D31y;
					end
					
					default: begin
						xcoord <= 0;
						ycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (enable4) begin
				
				funct4 <= loadkeyboard;
				
				onoff4 <= onoff4^audin;
				
				coordsel4 <= {~funct4, onoff4};
				
				case (coordsel4) //multiplexer choosing x and y coordinates for printing in room 1
				
					2'b00: begin
						xcoord <= L40x;
						ycoord <= L40y;
					end
					
					2'b01: begin
						xcoord <= L41x;
						ycoord <= L41y;
					end
					
					2'b10: begin
						xcoord <= D40x;
						ycoord <= D40y;
					end
					
					2'b11: begin
						xcoord <= D41x;
						ycoord <= D41y;
					end
					
					default: begin
						xcoord <= 0;
						ycoord <= 0;
					end
				
				endcase
			
			end
			
			else if (clearinitsignal) begin
				xcoord <= 0;
				ycoord <= 0;
			end
		
		end
		
	end
	
		
		//multiplexers for audio output
		
		always@(*) begin
		
			case (selfunct)
				
				2'b00: begin //case: L mode
					
					case (selonoff)
						
						1'b0: begin //output L0 audio
							audout <= L0aud;
						end
						
						1'b1: begin //output L1 audio
							audout <= L1aud;
						end
						
					endcase
					
				end
				
				2'b10: begin //case: D mode
				
					case (selonoff)
						
						1'b0: begin
							audout <= D0aud;
						end
						
						1'b1: begin
							audout <= D1aud;
						end
						
					endcase
				
				end
				
				2'b01: begin //case all locked mode
				
					audout <= alllockedaud;
				
				end
				
				default: begin
				
					audout <= 4'b0;
					
				end
					
			
			endcase
		
		end


endmodule
