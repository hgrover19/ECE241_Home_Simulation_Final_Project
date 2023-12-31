//////////////////////////////////
/// mouse interface to DE1-SoC ///
/// Feb 2016                   ///
/// ps2 transfer               ///
/// part 2 transmit module     ///
//////////////////////////////////

module transmit (
 hex_out0, 		// 7 bit binary Output
 hex_out1, 		// 7 bit binary Output
 hex_out2, 		// 7 bit binary Output
 hex_out3, 		// 7 bit binary Output
 hex_out4, 		// 7 bit binary Output
 hex_out5, 		// 7 bit binary Output
 x_value,		// 9 bit x direction value
 y_value,		// 9 bit y direction value
 b_value,		// 8 bit button and x/y sign value
 xy_counter,	// counter for serial shift register
 xyb_stop,		// indicates end of 3 bit transfer
 enable_send,  // stream load enabled
 clk,				// 50 KHz clock
 reset,			// master reset
 ps2_clk, 		// ps2 clock
 ps2_data,	 	// ps2 data
 LEDR // added
);

 
 // input signals
 
 input ps2_clk;
 input ps2_data;
 input reset;
 input clk;
 input enable_send;
 
 //output registers ;
 
 output reg [6:0] hex_out0 ;
 output reg [6:0] hex_out1 ;
 output reg [6:0] hex_out2 ;
 output reg [6:0] hex_out3 ;
 output reg [6:0] hex_out4 ;
 output reg [6:0] hex_out5;
 output reg [6:0] xy_counter; 
 output reg [8:0] x_value;
 output reg [8:0] y_value;
 output reg [7:0] b_value;
 
 output reg xyb_stop;
 
 // ADDED to display the lights. Need default .qsf course file
 output reg [3:0] LEDR; // led_left; 
 // output reg LEDR[1]; //led_right;
 // output reg LEDR[2]; //led_up;
 // output reg LEDR[3]; // led_down;

 
 // internal registers
 
 reg [2:0] counter_xy;	// counter for first and second value
 reg [2:0] state_value_y;// y state machine
 reg [2:0] state_value_x;// x state machine
 reg [8:0] x_first;		// store first x value
 reg [8:0] x_second;		// store second x value
 reg [8:0] y_first;		// store first y value
 reg [8:0] y_second;		// store second y value
 reg [32:0] xyb_value;	// serial shift register
 reg PSCLK;					// for ps2 clk
 reg [8:0] PS; 			//for ps2 data
 reg PSO;   				// stores serial data value
 
 
 // setting to create HEX value on display
 
 parameter HEX_0 = 7'b1000000;		// zero
 parameter HEX_1 = 7'b1111001;		// one
 parameter HEX_2 = 7'b0100100;		// two
 parameter HEX_3 = 7'b0110000;		// three
 parameter HEX_4 = 7'b0011001;		// four
 parameter HEX_5 = 7'b0010010;		// five
 parameter HEX_6 = 7'b0000010;		// six
 parameter HEX_7 = 7'b1111000;		// seven
 parameter HEX_8 = 7'b0000000;		// eight
 parameter HEX_9 = 7'b0011000;		// nine
 parameter HEX_10 = 7'b0001000;		// ten
 parameter HEX_11 = 7'b0000011;		// eleven
 parameter HEX_12 = 7'b1000110;		// twelve
 parameter HEX_13 = 7'b0100001;		// thirteen
 parameter HEX_14 = 7'b0000110;		// fourteen
 parameter HEX_15 = 7'b0001110;		// fifteen
 parameter zero   = 7'b1111111;		// all off	
 parameter right = 7'b0101111;      // right button push
 parameter left = 7'b1000111;			// left button push
 parameter middle = 7'b0101011;		// middle button push
 parameter dash = 7'b0111111; 		// dash (no button push)
 parameter tee =  7'b1111000;			// letter T
 parameter you = 7'b1000001;        // letter U
 parameter pee = 7'b0001100;        // letter P
 
 /////////////////////////////////////////////
 // state machine values for mouse movement //
 ///////////////////////////////////////////// 
 
 parameter load_value_y1 = 3'b000;
 parameter load_value_y2 = 3'b001;
 parameter test_sign_y = 3'b010;
 parameter compare_up = 3'b011;
 parameter compare_down = 3'b100;
 parameter no_change_y = 3'b101;
 
 parameter load_value_x1 = 3'b000;
 parameter load_value_x2 = 3'b001;
 parameter test_sign_x = 3'b010;
 parameter compare_left = 3'b011;
 parameter compare_right = 3'b100;
 parameter no_change_x = 3'b101;
 
  ////////////////////////////////////////
 // PS2 mouse value retrieve register  // 
 ////////////////////////////////////////

wire sync_time = (xy_counter < 7'd32)? 1'b0 : 1'b1; // end of each load cycle
 
 always @(negedge enable_send or posedge ps2_clk) begin
 
 	if  (!enable_send)
	
	begin
	xy_counter = 7'b0; // reset counter
	end
	
	else begin
	
	if ( sync_time) 
	xy_counter = 7'b0;
	
	else
	xy_counter = xy_counter + 1;
	end
	
	end

 
 
 
 
 always @ (negedge enable_send or negedge ps2_clk) begin
 
 if (!enable_send) begin xyb_stop = 0 ; end
 else
 case (xy_counter)
 
		// begin load byte 0
		7'd0	: begin xyb_value[0] = ps2_data ; xyb_stop = 0; end // bit 0 - start
 
		7'd1	: begin xyb_value[1] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 0 (left button)
		
		7'd2	: begin xyb_value[2] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 1 (right button)
		
		7'd3	: begin xyb_value[3] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 2 (middle button)
		
		7'd4	: begin xyb_value[4] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 3 (always high)
		
		7'd5	: begin xyb_value[5] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 4 (x sign)
		
		7'd6	: begin xyb_value[6] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 5 (y sign)
		
		7'd7	: begin xyb_value[7] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 6 (x over)
		
		7'd8	: begin xyb_value[8] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 7 (y over)
		
		7'd9	: begin xyb_value[9] = ps2_data ; xyb_stop = 0; end // bit 9 - end 1
		
		7'd10	: begin xyb_value[10] = ps2_data ; xyb_stop = 0; end // bit 10 - end 2
		
		// begin load byte 1
		
		7'd11	: begin xyb_value[11] = ps2_data ; xyb_stop = 0; end // bit 0 - valid bit 0

		7'd12	: begin xyb_value[12] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 1
		
		7'd13	: begin xyb_value[13] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 2
		
		7'd14	: begin xyb_value[14] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 3
		
		7'd15	: begin xyb_value[15] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 4
		
		7'd16	: begin xyb_value[16] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 5
		
		7'd17	: begin xyb_value[17] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 6
		
		7'd18	: begin xyb_value[18] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 7
		
		7'd19	: begin xyb_value[19] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 8
		
		7'd20	: begin xyb_value[20] = ps2_data ; xyb_stop = 0; end // bit 9 -  end 1
		
		7'd21	: begin xyb_value[21] = ps2_data ; xyb_stop = 0; end // bit 10 - end 2
		
		// begin load byte 2
		
		7'd22	: begin xyb_value[22] = ps2_data ; xyb_stop = 0; end // bit 0 - valid bit 0

		7'd23	: begin xyb_value[23] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 1
		
		7'd24	: begin xyb_value[24] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 2
		
		7'd25	: begin xyb_value[25] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 3
		
		7'd26	: begin xyb_value[26] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 4
		
		7'd27 : begin xyb_value[27] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 5
		
		7'd28	: begin xyb_value[28] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 6
		
		7'd29	: begin xyb_value[29] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 7
		
		7'd30	: begin xyb_value[30] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 8
		
		7'd31	: begin xyb_value[31] = ps2_data ; xyb_stop = 0; end // bit 9 -  end 1
		
		7'd32	: begin xyb_value[32] = ps2_data ; xyb_stop = 1; end // bit 10 - end 2
		
			
		endcase
		
		end
////////////////////////////////////////////
/// store values in 8 bit register for  ////
/// button pushes middle left right     ////
/// x and y value                       ////
////////////////////////////////////////////		
		
		
	always @ ( posedge clk ) begin
	
		if (xyb_stop) begin
		
		 b_value [7:0] <= xyb_value [8:1];
		 x_value [8:0] <= xyb_value [19:11];
		 y_value [8:0] <= xyb_value [30:22];
		 
		 end	
	 end
	 
	
////////////////////////////////////////////////
/// Testing to see which button was pushed   ///
////////////////////////////////////////////////	
	 always @  ( posedge clk or negedge enable_send ) begin
	 
	 if (!enable_send) begin
// default setting		 
	 hex_out5 = dash;
	 hex_out4 = dash;
	 end
	 
	 else
	 
	 case (b_value [3:0])  
	 
	 4'b1100: begin  hex_out5 = HEX_11; hex_out4 = middle; end // middle button
	 4'b1010: begin  hex_out5 = HEX_11; hex_out4 = right; end  // right button
	 4'b1001: begin  hex_out5 = HEX_11; hex_out4 = left; end // left button
	 4'b1000: begin  hex_out5 = dash; hex_out4 = dash; end // no button push
	 
	 endcase
	 
	 end
	 
/////////////////////////////////////
////   counter  for ps2 clock    //// 	
/////////////////////////////////////

 always @ ( posedge xyb_stop ) begin
	
	if (!reset) begin counter_xy = 2'b0; end	
	
		else 
		
		counter_xy = counter_xy +1;
	 end

// remove y-movenet to ignore changes in y-direction of the mouse.
/* /////////////////////////////////
////   testing y movement    //// 	
/////////////////////////////////
 

 always @	( posedge clk or negedge enable_send ) begin
	
	if  (!enable_send)
// default setting	
	begin
	state_value_y = load_value_y1;
	y_first = 8'b1;
	y_second = 8'b1;
	hex_out1 = dash;
	hex_out0 = dash;
	end
	
	else
	
	case (state_value_y)
	load_value_y1: //000
// load first y value	
	begin
	
	 if (!counter_xy[0])
	 y_first = y_value;	 
	 else 	 
	 state_value_y = load_value_y2;
	 end
///////////////////////////////////////////////////////	 
	 load_value_y2://001
// load second y value	 
	 begin
	 
	 if (counter_xy[0] & xyb_stop)
	 y_second = y_value;
	 else
	 state_value_y = test_sign_y;
	 end
///////////////////////////////////////////////////////	 
	 test_sign_y: //010
// compare to find direction	 
	 begin
	 
	 if (y_first[8] & y_second[8]) // both high values 
	  state_value_y = compare_down;
	  else if
	   (!y_first[8] & y_second[8] ) // first low and second high
		state_value_y = compare_down;
		else if
		(y_first[8] & !y_second[8]) // first high and second low
		state_value_y = compare_up;
		else if
		(!y_first[8] & !y_second[8]) // both low values
	   state_value_y = compare_up;
		
		else 
		
		state_value_y = test_sign_y; // once condition must be met
		
		end

///////////////////////////////////////////////////////		
		compare_up: //011
// display HEX value			
		begin				
		hex_out1 = you;
		hex_out0 = pee;
	   state_value_y = no_change_y;
		end

///////////////////////////////////////////////////////		
		compare_down: // 100
// display HEX value		
		begin
	   
		hex_out1 = HEX_13;
		hex_out0 = middle;
		state_value_y = no_change_y;
		end
////////////////////////////////////////////////////////		
		no_change_x: //101
// wait for next movement check		
		begin
		
		if (!counter_xy[0])
		state_value_y = load_value_y1;
		else
		state_value_y = no_change_y;		
		end
		endcase
		
		end */
		
		



/////////////////////////////////
////   testing x movement    //// 	
/////////////////////////////////		

 always @	( posedge clk or negedge enable_send ) begin
	
	if  (!enable_send)
// default setting		
	begin
	state_value_x = load_value_x1;
	x_first = 8'b1;
	x_second = 8'b1;
	hex_out3 = dash;
	hex_out2 = dash;
	end
	
	else
	
	case (state_value_x)
	load_value_x1: //000
	
	begin
	
	 if (!counter_xy[0])
	 x_first = x_value;	// load first x value 
	 else 	 
	 state_value_x = load_value_x2;
	 end
///////////////////////////////////////////////////////	 
	 load_value_x2://001
	 
	 begin
	 
	 if (counter_xy[0] & xyb_stop )
	 x_second = x_value; // load second x value
	 else
	 state_value_x = test_sign_x;
	 end
///////////////////////////////////////////////////////	 
	 test_sign_x://010
// compare to find direction	 
	 begin
	 
	 if (x_first[8] & x_second[8]) // both high values 
	  state_value_x = compare_left;
	  else if
	   (!x_first[8] & x_second[8] ) // first low and second high
		state_value_x = compare_left;
		else if
		(x_first[8] & !x_second[8]) // first high and second low
		state_value_x = compare_right ;
		else if
		(!x_first[8] & !x_second[8]) // both low values
	   state_value_x = compare_right;
		
		else 
		
		state_value_x = test_sign_x; // once condition must be met
		
		end

///////////////////////////////////////////////////////		
		compare_right: // 101
// display value on HEX display		
		begin				
		hex_out3 = right;
		hex_out2 = tee;
	   state_value_x = no_change_x;
		end

///////////////////////////////////////////////////////		
		compare_left: // 110
// display value on HEX display		
		begin
	   
		hex_out3 = left;
		hex_out2 = HEX_15;
		state_value_x = no_change_x;
		end
//////////////////////////////////////////////////////		
		no_change_x:
// wait for next movement check  		
		begin
		
		if (!counter_xy[0])
		state_value_x = load_value_x1;
		else
		state_value_x = no_change_x;		
		end
		
		endcase
		
		end
		
always @(posedge clk or negedge enable_send) begin
   if (!enable_send) begin
      // Default LED, set off
      LEDR[0] = 1'b0;
      LEDR[1] = 1'b0;
      LEDR[2] = 1'b0;
      LEDR[3] = 1'b0;
   end else begin
      case (state_value_x) // movement 
         compare_left: begin
            LEDR[0] = 1'b1;
            LEDR[1] = 1'b0;
            LEDR[2] = 1'b0;
            LEDR[3] = 1'b0;
         end
         compare_right: begin
            LEDR[0] = 1'b0;
            LEDR[1] = 1'b1;
            LEDR[2] = 1'b0;
            LEDR[3] = 1'b0;
         end
         no_change_x: begin
            // No movement in the x-direction
            LEDR[0] = x_value[8] ? 1'b1 : 1'b0;
            LEDR[1] = x_value[8] ? 1'b0 : 1'b1;
            LEDR[2] = 1'b0;
            LEDR[3] = 1'b0;
         end
         // Add cases for other conditions as needed
         default: begin
            // Default case
            LEDR[0] = 1'b0;
            LEDR[1] = 1'b0;
            LEDR[2] = 1'b0;
            LEDR[3] = 1'b0;
         end
      endcase
   end
end

 endmodule		