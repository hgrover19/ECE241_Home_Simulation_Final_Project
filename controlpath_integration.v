module controlpath_integration(

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
	output reg [2:0] selsw,
	output reg commandaudioenable
	
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
				
				DONE: begin
					commandaudioenable = 1'b1;
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