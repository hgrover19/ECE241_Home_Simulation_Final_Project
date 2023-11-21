/*
THE FOLLOWING ASSUMPTIONS ARE MADE:

audio input ON  = 1
audio input OFF = 0

function LIGHT = 1
function DOOR  = 0

*/



module controlpath(

	input loadinputs, //the pushbutton, loadinputs
	input clock, 
	input reset,
	input clear,
	input keyboardin, //keyboard input (L or D)
	input audin,	//Audio input (on or off, 1/0)
	input room0, room1, room2, room3, room4, room5, room6, room7, room8, room9, //switch input (select room number 0-9)
	input countDone, //VGA Datapath sends countDone = 1 when finished drawing
	
	output reg enable0, enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8, enable9, //signals to select which room we load function and ON/OFF to
	output reg [1:0] 0coordsel, 1coordsel, 2coordsel, 3coordsel, 4coordsel, 5coordsel, 6coordsel, 7coordsel, 8coordsel, 9coordsel, //select x, y coord for each room
	output reg selonoff, //sort stored audio registers by ON/OFF for audio datapath
	output reg selLD,//sort stored audio registers by Light/Door function
	output reg [3:0] selroomno, //sort audio registers by room number
	output reg clearinitsignal,
	output reg drawen,
	output reg Donesig,
	output reg loadenable; //enable loading of inputs
	
	);

	reg [5:0] current_state, next_state;
	
	localparam
		SETUPSCREEN = 6'd0; //SEFLOORPLAN
		LOAD_INPUTS = 6'd1; //enable input registers
		INPUTS_WAIT = 6'd2; //button for loading inputs pressed, load data onto input registers
		
		ROOM0 = 6'd3;
		ROOM1 = 6'd4;
		ROOM2 = 6'd5;
		ROOM3 = 6'd6;
		ROOM4 = 6'd7;
		ROOM5 = 6'd8;
		ROOM6 = 6'd9;
		ROOM7 = 6'd10;
		ROOM8 = 6'd11;
		ROOM9 = 6'd12;

		/*
		//ROOM 0 DRAW STATES
		DRAW_L00 = 6'd3; //Draw light off in room 0
		DRAW_L01 = 6'd4; //Draw Light on in room 0
		DRAW_D00 = 6'd3; //Draw Door closed in room 0
		DRAW_D01 = 6'd4; //Draw Door open in room 0
		
		//ROOM 1 DRAW STATES
		DRAW_L10 = 6'd5;
		DRAW_L11 = 6'd6;
		DRAW_D10 = 6'd7;
		DRAW_D11 = 6'd8;
		
		//ROOM 2 DRAW STATES
		DRAW_L20 = 6'd9;
		DRAW_L21 = 6'd10;
		DRAW_D20 = 6'd11;
		DRAW_D21 = 6'd12;
		
		//ROOM 3 DRAW STATES
		DRAW_L30 = 6'd13;
		DRAW_L31 = 6'd14;
		DRAW_D30 = 6'd15;
		DRAW_D31 = 6'd16;
		
		//ROOM 4 DRAW STATES
		DRAW_L40 = 6'd17;
		DRAW_L41 = 6'd18;
		DRAW_D40 = 6'd19;
		DRAW_D41 = 6'd20;
		
		//ROOM 5 DRAW STATES
		DRAW_L50 = 6'd21;
		DRAW_L51 = 6'd22;
		DRAW_D50 = 6'd23;
		DRAW_D51 = 6'd24;
		
		//ROOM 6 DRAW STATES
		DRAW_L60 = 6'd25;
		DRAW_L61 = 6'd26;
		DRAW_D60 = 6'd27;
		DRAW_D61 = 6'd28;
		
		//ROOM 7 DRAW STATES
		DRAW_L70 = 6'd29;
		DRAW_L71 = 6'd30;
		DRAW_D70 = 6'd31;
		DRAW_D71 = 6'd32;
		
		//ROOM 8 DRAW STATES
		DRAW_L80 = 6'd33;
		DRAW_L81 = 6'd34;
		DRAW_D80 = 6'd35;
		DRAW_D81 = 6'd36;
		
		//ROOM 9 DRAW STATES
		DRAW_L90 = 6'd37;
		DRAW_L91 = 6'd38;
		DRAW_D90 = 6'd39;
		DRAW_D91 = 6'd40;
		*/
		
		DONE_DRAW = 6'd13; //Finish drawing VGA display image, so set Done = 1
		DONE = 6'd14;	//Reach this state when Done = 1
		CLEAR = 6'd15; //Clear VGA Display of everything
		DONE_CLEAR = 6'd16; //When finished clearing, set Done = 1
	
	//State table:
	
	always @(*)
		begin: state_table
			case(current_state)
				//IMPLEMENT SETUPSCREEN STATE
				
				LOAD_INPUTS: next_state = loadinputs ? INPUTS_WAIT : LOAD_INPUTS;
				
				INPUTS_WAIT: begin
					if (loadinputs) //if input button on, keep waiting
						next_state = INPUTS_WAIT;
						
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
						else if (room5 == 1'b1)
							next_state = ROOM5;
						else if (room6 == 1'b1)
							next_state = ROOM6;
						else if (room7 == 1'b1)
							next_state = ROOM7;
						else if (room8 == 1'b1)
							next_state = ROOM8;
						else if (room9 == 1'b1)
							next_state = ROOM9;
				end
				
				ROOM0: next_state = countDone ? DONE_DRAW : ROOM0;
				
				ROOM1: next_state = countDone ? DONE_DRAW : ROOM1;
				
				ROOM2: next_state = countDone ? DONE_DRAW : ROOM2;
				
				ROOM3: next_state = countDone ? DONE_DRAW : ROOM3;
				
				ROOM4: next_state = countDone ? DONE_DRAW : ROOM4;
				
				ROOM5: next_state = countDone ? DONE_DRAW : ROOM5;
				
				ROOM6: next_state = countDone ? DONE_DRAW : ROOM6;
				
				ROOM7: next_state = countDone ? DONE_DRAW : ROOM7;
				
				ROOM8: next_state = countDone ? DONE_DRAW : ROOM8;
				
				ROOM9: next_state = countDone ? DONE_DRAW : ROOM9;
				
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
			enable5 = 1'b0;
			enable6 = 1'b0;
			enable7 = 1'b0;
			enable8 = 1'b0;
			enable9 = 1'b0;
			0coordsel = 2'b0;
			1coordsel = 2'b0;
			2coordsel = 2'b0;
			3coordsel = 2'b0;
			4coordsel = 2'b0;
			5coordsel = 2'b0;
			6coordsel = 2'b0;
			7coordsel = 2'b0;
			8coordsel = 2'b0;
			9coordsel = 2'b0;
			selonoff = 1'b0;
			selLD = 1'b0;
			selroomno = 4'b0;
			clearinitsignal = 1'b0;
			drawen = 1'b0;
			Donesig = 1'b0;
			
			case(current_state)
			
				LOAD_INPUTS: begin
					loadenable = 1'b1;
				end
				
				ROOM0: begin //When we have selected room 1, pass input function (L or D) and ON?OFF input to Room 0 registers
					enable0 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selLD = 1'b1; //where 1 selects Light function
						selroomno = 4'b0000;	//where 0000 selects room 0
					end
					
					else if (keyboardin == 1 && audin == 1) begin//select audio message for L11
						selonoff = 1'b1; 
						selLD = 1'b1; 
						selroomno = 4'b0000;	
					end
					
					else if (keyboardin == 0 && audin == 0) begin//select audio message for D00
						selonoff = 1'b0; 
						selLD = 1'b0; 
						selroomno = 4'b0000;	
					end
					
					else if (keyboardin == 0 && audin == 1) begin//select audio message for D01
						selonoff = 1'b1; 
						selLD = 1'b0; 
						selroomno = 4'b0000;	
					end
					
				end 
				
				ROOM1: begin
					enable1 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selLD = 1'b1; //where 1 selects Light function
						selroomno = 4'b0000;	//where 0000 selects room 0
					end
				end
				
				ROOM2: begin
					enable2 = 1'b1;
					if (keyboardin == 1 && audin == 0) begin//Enable signals for audio output
						selonoff = 1'b0; //where 0 selects OFF
						selLD = 1'b1; //where 1 selects Light function
						selroomno = 4'b0000;	//where 0000 selects room 0
					end
				end
				
				ROOM3: begin
					enable3 = 1'b1;
				end
				
				ROOM4: begin
					enable4 = 1'b1;
				end
				
				ROOM5: begin
					enable5 = 1'b1;
				end
				
				ROOM6: begin
					enable6 = 1'b1;
				end
				
				ROOM7: begin
					enable7 = 1'b1;
				end
				
				ROOM8: begin
					enable8 = 1'b1;
				end
				
				ROOM9: begin
					enable9 = 1'b1;
				end
				
				DONE_DRAW: begin
					Donesig = 1'b1;
				end
				
				
				
				
				
			
		
	
	
endmodule
				
		
module coordselect_FSM(
	
	input plot,
	output reg [1:0] 0coordsel, 1coordsel, 2coordsel, 3coordsel, 4coordsel, 5coordsel, 6coordsel, 7coordsel, 8coordsel, 9coordsel; //select x, y coord for each room
	
)
		

module datapath(

	input clock,
	input reset,
	input loadenable,
	input enable0, enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8, enable9,
	input [1:0] 0coordsel, 1coordsel, 2coordsel, 3coordsel, 4coordsel, 5coordsel, 6coordsel, 7coordsel, 8coordsel, 9coordsel, //select x, y coord for each room
	input selonoff,
	input [3:0] selroomno,
	input selLD,
	input clearinitsignal,
	input drawen,
	input Donesig,
	input keyboardin, //keyboard input (L or D)
	input audin;	//Audio input (on or off, 1/0)

)

	//declare storage registers
	reg loadkeyboard; //register storing keyboard input
	reg loadroomno; //register storing room number
	reg loadaudio //register storing audio input
	
	//ROOM 0 REGISTERS
	reg funct0;
	reg onoff0;
	
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
	
	//ROOM 5 REGISTERS
	reg funct5;
	reg onoff5;
	
	//ROOM 6 REGISTERS
	reg funct6;
	reg onoff6;
	
	//ROOM 7 REGISTERS
	reg funct7;
	reg onoff7;
	
	//ROOM 8 REGISTERS
	reg funct8;
	reg onoff8;
	
	//ROOM 9 REGISTERS
	reg funct9;
	reg onoff9;
	
	//datapath logic
	always@ (posedge clock) begin
		
		
		
	

endmodule