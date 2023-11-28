// checks to see if the inputs are both numbers
module checkFor2num(num1, num2, is_true);
    input [7:0] num1;
    input [7:0] num2;
    output reg is_true;

    wire reg val1Num;
    wire reg val2Num;

    always @(*) 
        begin
            case(num1) begin
                00000000: val1Num = 1'b1;
                00000001: val1Num = 1'b1;
                00000010: val1Num = 1'b1;
                00000011: val1Num = 1'b1;
                00000100: val1Num = 1'b1;
                00000101: val1Num = 1'b1;
                00000110: val1Num = 1'b1;
                00000111: val1Num = 1'b1;
                00001000: val1Num = 1'b1;
                00001001: val1Num = 1'b1;
                 default: val1Num = 1'b0;
            end
            endcase
        end
    
    always @(*) 
        begin
            case(val2) begin
                00000000: val2Num = 1'b1;
                00000001: val2Num = 1'b1;
                00000010: val2Num = 1'b1;
                00000011: val2Num = 1'b1;
                00000100: val2Num = 1'b1;
                00000101: val2Num = 1'b1;
                00000110: val2Num = 1'b1;
                00000111: val2Num = 1'b1;
                00001000: val2Num = 1'b1;
                00001001: val2Num = 1'b1;
                 default: val2Num = 1'b0;
            end
            endcase
        end

    if(val1Num == 1'b1 && val2Num == 1'b1) begin
        // both numbers
        is_true <= 1;
    end
    else begin
        is_true <= 0;
    end
endmodule