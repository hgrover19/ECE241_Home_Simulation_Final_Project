module part2fortesting(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX; // Active low synchronous reset 
// iLoadX held high --> iXY_Coord value stored into an X register after every posedge clock
// iLoadX pulsed --> Y coord inout at iXY_Coord 
// loaded when input iPlotBox pulsed to start the drawing

// iPlotBox high --> iXY_Coord stored into "Y register"
                //--> iColour stored into "Colour register" after every posedge clock
//               filled square should be drawn when pulsed high and then low
//              connected to pushbutton

// iBlack --> when pulsed high and low --> entire screen to black (0, 0, 0)
//            connected to pushbutton

   input wire [2:0] iColour; // square should be filled w this color
   // loaded into register when input iPlotBox is pulsed

   input wire [6:0] iXY_Coord; // input x and y coord (coords of sqare's top left corner)
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates (0, 0) is top left corner
                                // set most significant bit to 0
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable (write enable signal)
                                // tells the controller to update the pixel specified by (X,Y) with the value Colour at the
                                // next clock edge.
   output wire       oDone;       // goes high when finished drawing frame
                                // must remain gigh until iPlotBox or iBlack pulsed high and then low

    wire x_en, y_en, memory_en, black_en;
    wire [3:0] plotClock;

    wire [7:0] black_x;
    wire [6:0] black_y;
   //
   // Your code goes here
   //

   controlpath cp1 (iClock, iResetn, iLoadX, iBlack, iPlotBox,
                x_en, y_en, memory_en, black_en, oPlot, oDone, plotClock, 
                X_SCREEN_PIXELS, Y_SCREEN_PIXELS, black_x, black_y);
    
    datapath dp1 (iClock, iResetn, iColour, iXY_Coord, X_SCREEN_PIXELS, Y_SCREEN_PIXELS,
                x_en, y_en, memory_en, black_en,
                oX, oY, oColour, plotClock, black_x, black_y);

endmodule // part2

module controlpath(Clock, ResetN, iLoadX, iBlack, iPlot, 
x_init_en, y_init_en, memory_init, black_init, draw_en, oDone, plotClock,
X_SCREEN_PIXELS, Y_SCREEN_PIXELS, black_x, black_y);

    input Clock, ResetN, iLoadX, iBlack, iPlot;
    input [3:0] plotClock;
    input [7:0] black_x;
    input [6:0] black_y;

    output reg x_init_en, y_init_en, memory_init, black_init, draw_en, oDone;

    reg [2:0] current_state, next_state;

    parameter load_x = 3'd0,
    load_x_wait = 3'd1,
    load_y = 3'd2,
    load_y_wait = 3'd3,
    memory = 3'd4,
    draw_wait = 3'd5,
    draw_black = 3'd6,
    draw_done = 3'd7;

    input [7:0] X_SCREEN_PIXELS;
    input [6:0] Y_SCREEN_PIXELS;
            

    always@(*)
        begin: state_table
            case (current_state)
            load_x: next_state = iLoadX ? load_x_wait : load_x;
            load_x_wait: next_state = iLoadX ? load_x_wait : load_y;
            
            load_y: next_state = iPlot ? load_y_wait : load_y; // checks if pressed & then unpressed
            load_y_wait: next_state = iPlot ? load_y_wait : memory;

            memory: begin
                if (plotClock == 4'd15) // plot 16 pixels
                    next_state = draw_wait;
                else
                    next_state = memory;
            end

            draw_wait: next_state = draw_done;
            draw_done: next_state = load_x;

            draw_black: begin
                if (black_x == (X_SCREEN_PIXELS - 1) && black_y == (Y_SCREEN_PIXELS - 1))
                    next_state = draw_wait;
                else
                    next_state = draw_black;
            end

            default: next_state = load_x;
            endcase
        end


    always @(*)
    begin: enable_signals

        // default make all to 0
        x_init_en = 1'b0;
        y_init_en = 1'b0;
        memory_init = 1'b0;
        black_init = 1'b0;
        draw_en = 1'b0;
        oDone = 1'b0;

        case (current_state)

        load_x: begin
            x_init_en = 1'b1;
        end

        load_y: begin
            y_init_en = 1'b1;
            // draw_en = 1'b1;
        end

        memory: begin
            memory_init = 1'b1;
            draw_en = 1'b1;
        end

        draw_black: begin
            black_init = 1'b1;
            draw_en = 1'b1;
        end

        draw_done: oDone = 1'b1;

        endcase
    end

    // current_state registers
    always@(posedge Clock)
    begin: state_FFs
        if(!ResetN)
            current_state <= load_x;
        else if(iBlack)
            current_state <= draw_black;
        else
            current_state <= next_state;

    end // state_FFS
endmodule

module datapath(Clock, ResetN, iColour, iXY, X_SCREEN_PIXELS, Y_SCREEN_PIXELS,
                x_init_en, y_init_en, memory_init, black_init, 
                oX, oY, oColour, plotClock, black_x, black_y);

    input Clock, ResetN, x_init_en, y_init_en, memory_init, black_init;
    input [7:0] X_SCREEN_PIXELS;
    input [6:0] Y_SCREEN_PIXELS;
    input [6:0] iXY;
    input [2:0] iColour;
    // X Register, Y Register, Colour Register
    // registers to hold cur_x and cur_y
    reg [7:0] X_register;
    reg [6:0] Y_register;
    reg [2:0] Colour_register;

    output reg [7:0] oX, black_x;
    output reg [6:0] oY, black_y;
    output reg [2:0] oColour;

    output reg [3:0] plotClock;

// adders to sweep accross dim cols and dim rows

// Registers a, b, c, x with respective input logic
    always@(posedge Clock) begin

        if(!ResetN) begin
            X_register <= 0;
            Y_register <= 0;
            Colour_register <= 0;
        end
        else begin
            if (x_init_en) X_register <= {1'b0, iXY}; // concat w 0 at MSB
            else if (y_init_en) begin
                Y_register <= iXY;
                Colour_register <= iColour;
            end

            else if(memory_init) begin
                oX <= X_register + plotClock[1:0]; // LSB
                oY <= Y_register + plotClock[3:2]; // MSB
                oColour <= Colour_register; // set to inputted colour
            end

            else if(black_init)begin
                oX <= black_x;
                oY <= black_y;
                oColour <= 0;
            end

        end

    end

    // clock increments for drawing & black plots
    always @(posedge Clock)
    begin
        if (!ResetN) 
        begin
            plotClock <= 4'd0;
            black_x <= 0;
            black_y <= 0;
        end

        else if (plotClock == 4'd15)
        begin
            plotClock = 4'd0;
        end

        else if(memory_init) plotClock <= plotClock +1; // drawn --> increment the pixel position

        else if ((black_x == X_SCREEN_PIXELS-1) & (black_y == Y_SCREEN_PIXELS-1)) // reached end
        begin
            black_x <= 0;
            black_y <= 0;
        end

        else if (black_x == X_SCREEN_PIXELS-1) //reached end of row
        begin
            black_x <= 0; // reset next row
            black_y <= black_y + 1 ;
        end

        else if(black_init)
            black_x <= black_x +1; // color each col in the row black
        end
        
endmodule

