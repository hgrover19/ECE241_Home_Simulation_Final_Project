// note: relies on hexDisplay to display on the hex-display,
// needs clap detection module

module keyboardEnd(num1, num2, select, clap, val1, val2); /// add output
    input [7:0] num1;
    input [7:0] num2;
    input select;
    input clap;
    

    // msb is 
    output reg [7:0]val1;
    output reg [7:0]val2;

    always @(*) begin
        case(clap) 
        begin
            0: // no clap, do nothing

            1: // clap, send out;
            if(select == 1'b1) 
            begin // send to fsm
                case(num1)
                    00100011: // d
                        val1 <= 8'b0;
                    01001011: // l
                        val1 <= 8'b11111111;
                    default: 
                        val1 <= 8'b01010000; // garbage value as default
                endcase

                case(num2)
                    00100011: // d
                        val2 <= 1'b0;
                    01001011: // l
                        val2 <= 1'b1;
                    default: 
                        val2 <= 8'b01010000; // garbage value as default
                endcase
            end

            else // display on HEX
                begin
                    hexDisplay(val1, val2);
                end

        end
        endcase
    end
endmodule