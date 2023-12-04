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
	//wire [3:0] audoutput;
	
	
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
		.audin(audin),
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
		.audin(audin),
		.drawen(drawen),
		.MAX_X_PIXELS(MAX_X_PIXELS),
		.MAX_Y_PIXELS(MAX_Y_PIXELS),
		.xcoord(xcoord),
		.ycoord(ycoord),
		.plotcounter(plotcounter),
		.colour(colour),
		.clearxcounter(clearxcounter),
		.clearycounter(clearycounter)
		//.audout(audoutput)
	
	);
	

endmodule
