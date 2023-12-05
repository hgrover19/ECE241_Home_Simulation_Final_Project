`timescale 1ns/1ns
/*
THE FOLLOWING ASSUMPTIONS ARE MADE:

audio input ON  = 1
audio input OFF = 0

function LIGHT = 1
function DOOR  = 0
*/

module project_integration(

	input [8:0] SW,
	input [3:0] KEY,
	input CLOCK_50

); //top level module instantiation

	parameter MAX_X_PIXELS = 8'd160;
	parameter MAX_Y_PIXELS = 7'd120;
	
	//input wires to controlpath and datapath
	wire keyboardin;
	wire audin;
	wire [3:0] plotcounter; 
	
	//output wires from datapath
	wire [7:0] xcoordoutput;
	wire [6:0] ycoordoutput;
	wire [7:0] clearxcoord;
	wire [6:0] clearycoord;
	wire [7:0] clearxcounter;
	wire [8:0] clearycounter;
	//wire [3:0] audoutput;
	wire [2:0] loadkeyboard; //
	wire [7:0] startxcoord;
	wire [6:0] startycoord;
	wire [2:0] colour;
	
	
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
	wire drawen;

	controlpath controlpath_inst(
		
		.loadinputs(KEY[1]),
		.clock(CLOCK_50),
		.reset(KEY[0]),
		.clear(KEY[2]),
		.keyboardin(SW[8]),
		.audin(SW[6]),
		.room0(SW[0]),
		.room1(SW[1]),
		.room2(SW[2]),
		.room3(SW[3]),
		.room4(SW[4]),
		.plotcounter(plotcounter),
		.MAX_X_PIXELS(MAX_X_PIXELS),
		.MAX_Y_PIXELS(MAX_Y_PIXELS),
		.clear_x(clearxcoord),
		.clear_y(clearycoord),
		.enable0(enable0),
		.enable1(enable1),
		.enable2(enable2),
		.enable3(enable3),
		.enable4(enable4),
		.selonoff(selonoffsignal),
		.selfunct(selfunction),
		.clearinitsignal(clearstart),
		.loadenable(loadenable),
		.selsw(selsw),
		.commandaudioenable(commandaudioenable),
		.drawen(drawen)
		
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
		.keyboardin(SW[8]),
		.audin(SW[6]),
		.drawen(drawen),
		.MAX_X_PIXELS(MAX_X_PIXELS),
		.MAX_Y_PIXELS(MAX_Y_PIXELS),
		.xcoord(xcoordoutput), //output x coord to vga adapter
		.ycoord(ycoordoutput), //output y coord to vga adapter 
		
		//	output reg [7:0] startxcoord,
	//output reg [6:0] startycoord
		
		
		.plotcounter(plotcounter),
		.colour(colour),
		.clearxcounter(clearxcounter),
		.clearycounter(clearycounter),
		//.audout(audoutput)
		.loadkeyboard(loadkeyboard),
		.startxcoord(startxcoord),
		.startycoord(startycoord)
	
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
	input countDone, //VGA Datapath sends countDone = 1 when finished drawing
	input [3:0] plotcounter,
	input [7:0] MAX_X_PIXELS,
	input [6:0] MAX_Y_PIXELS,
	input [7:0] clear_x,
	input [6:0] clear_y,

	output reg enable0, enable1, enable2, enable3, enable4, //signals to select which room we load function and ON/OFF to
	output reg selonoff, //sort stored audio registers by ON/OFF for audio datapath
	output reg [1:0] selfunct, //sort stored audio registers by Light/Door function
	output reg clearinitsignal,
	output reg loadenable, //enable loading of inputs
	output reg [2:0] selsw,
	output reg commandaudioenable,
	output reg drawen
	
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
		
		DONE_DRAW = 6'd7, //Finish drawing VGA display image, so set Done = 1
		DONE = 6'd8,	//Reach this state when Done = 1
		CLEAR = 6'd9, //Clear VGA Display of everything
		DONE_CLEAR = 6'd10; //When finished clearing, set Done = 1
		
	
	//State table:
	
	always @(*)
		begin: state_table
			case(current_state)
				//IMPLEMENT SETUPSCREEN STATE
				
				INPUTS_WAIT: next_state = loadinputs ? LOAD_INPUTS : INPUTS_WAIT;
				
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
							
				end
				
				ROOM0: next_state = (plotcounter == 4'd15) ? DONE_DRAW : ROOM0;
				
				ROOM1: next_state = (plotcounter == 4'd15) ? DONE_DRAW : ROOM1;
				
				ROOM2: next_state = (plotcounter == 4'd15) ? DONE_DRAW : ROOM2;
				
				ROOM3: next_state = (plotcounter == 4'd15) ? DONE_DRAW : ROOM3;
				
				ROOM4: next_state = (plotcounter == 4'd15) ? DONE_DRAW : ROOM4;
				
				DONE_DRAW: next_state = DONE;
				
				DONE: next_state = INPUTS_WAIT;
				
				CLEAR: next_state = ((clear_x == MAX_X_PIXELS) && (clear_y == MAX_Y_PIXELS)) ? DONE_CLEAR : CLEAR;
				
				DONE_CLEAR: next_state = DONE;
				
				default: next_state = INPUTS_WAIT;
				
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
			commandaudioenable = 1'b0;
			drawen = 1'b0;
			
			
			case(current_state)
			
				LOAD_INPUTS: begin
					loadenable <= 1'b1;
					if (room0 == 1'b1) //when load is enabled, also send signal to multiplexer that inputs switch input into sw input register
						selsw <= 3'd0;
					else if (room1 == 1'b1)
						selsw <= 3'd1;
					else if (room2 == 1'b1)
						selsw <= 3'd2;
					else if (room3 == 1'b1)
						selsw <= 3'd3;
					else if (room4 == 1'b1)
						selsw <= 3'd4;
				end
				
				ROOM0: begin //When we have selected room 1, pass input function (L or D) and ON?OFF input to Room 0 registers
					enable0 <= 1'b1;
					drawen <= 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff <= 1'b0; //where 0 selects OFF
						selfunct <= 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff <= 1'b1; 	
						selfunct <= 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff <= 1'b0; 
						selfunct <= 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff <= 1'b1; 
						selfunct <= 2'b10; 
					end
					
				end 
				
				ROOM1: begin
					enable1 <= 1'b1;
					drawen  <= 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff <= 1'b0; //where 0 selects OFF
						selfunct <= 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff <= 1'b1; 
						selfunct <= 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff <= 1'b0; 
						selfunct <= 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff <= 1'b1; 
						selfunct <= 2'b10; 
					end
				end
				
				ROOM2: begin
					enable2 <= 1'b1;
					drawen <= 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff <= 1'b0; //where 0 selects OFF
						selfunct <= 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff <= 1'b1; 
						selfunct <= 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff <= 1'b0; 
						selfunct <= 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff <= 1'b1; 
						selfunct <= 2'b10; 
					end
				end
				
				ROOM3: begin
					enable3 <= 1'b1;
					drawen <= 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff <= 1'b0; //where 0 selects OFF
						selfunct <= 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff <= 1'b1; 
						selfunct <= 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff <= 1'b0; 
						selfunct <= 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff <= 1'b1; 
						selfunct <= 2'b10; 
					end
				end
				
				ROOM4: begin
					enable4 <= 1'b1;
					drawen <= 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff <= 1'b0; //where 0 selects OFF
						selfunct <= 2'b00; //where 1 selects Light function
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff <= 1'b1; 
						selfunct <= 2'b00; 
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff <= 1'b0; 
						selfunct <= 2'b10; 
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff <= 1'b1; 
						selfunct <= 2'b10; 
					end
				end
				
				DONE: begin
					commandaudioenable <= 1'b1;
				end
				
				CLEAR: begin
					clearinitsignal <= 1'b1;
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
	input drawen,
	input [7:0] MAX_X_PIXELS,
	input [6:0] MAX_Y_PIXELS,
	output reg [7:0] xcoord, 
	output reg [6:0] ycoord,
	output reg [3:0] plotcounter,
	output reg [2:0] colour,
	output reg [7:0] clearxcounter,
	output reg [8:0] clearycounter,
	output reg [2:0]loadkeyboard,
	output reg [7:0] startxcoord,
	output reg [6:0] startycoord
	//output reg [3:0] audout

);
	
	//declare storage registers
	//reg [2:0]loadkeyboard; //register storing keyboard input
	reg roomnoreg; //register storing room number
	reg loadaudio; //register storing audio input
	//reg [7:0] startxcoord;
	//reg [6:0] startycoord;
	
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
			startxcoord <= 0;
			startycoord <= 0;
			
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
			//audout <= 0;
			
		end
		
		else begin
			
			if (loadenable) begin
			
				loadkeyboard <= keyboardin;
				
				loadaudio <= loadaudio ^ audin;
				
				case (selsw) //select switch input to store into room number register
				
					3'd0: 
						roomnoreg <= room1;
					3'd1:
						roomnoreg <= room1;
					3'd2:
						roomnoreg <= room2;
					3'd3:
						roomnoreg <= room3;
					3'd4:
						roomnoreg <= room4;
						
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
				
			end
			
		
		end
		
	end
	
	always@ (posedge clock)
		begin
			
			if (reset) begin
				plotcounter <= 0;
				clearxcounter <= 0;
				clearycounter <= 0;
				xcoord <= 0;
				ycoord <= 0;
			end
			
				else if (clearinitsignal) begin
					
					xcoord <= startxcoord + clearxcounter;
					ycoord <= startycoord + clearycounter;
					colour <= 3'b0;
					
				end
				
				else if ((drawen == 1'b1) && (audin == 1'b1)) begin //when the door/light is ON
				
					xcoord <= startxcoord + plotcounter[1:0];
					ycoord <= startycoord + plotcounter[3:2];
					colour <= 3'b110; //colour = yellow
					plotcounter <= plotcounter + 1;
				
				end
				
				else if ((drawen == 1'b1) && (audin == 1'b0)) begin //when the door/light is OFF
				
					xcoord <= startxcoord + plotcounter[1:0];
					ycoord <= startycoord + plotcounter[3:2];
					colour <= 3'b111;
					plotcounter <= plotcounter + 1;
				
				end
				
				else if (plotcounter == 4'd15) begin
					
					plotcounter <= 0;
					
				end
				
				else if ((clearxcounter == (MAX_X_PIXELS - 1)) && (clearycounter == (MAX_Y_PIXELS - 1))) begin
					
					clearxcounter <= 0;
					clearycounter <= 0;
					
				end	
				
				else if (clearxcounter == (MAX_X_PIXELS - 1)) begin //reach end of row
				
					clearxcounter <= 0;
					clearycounter <= clearycounter + 1;
					
				end
				
				else if (clearinitsignal) begin
					
					clearxcounter <= clearxcounter + 1;
				
				end
		
		end
	


endmodule
