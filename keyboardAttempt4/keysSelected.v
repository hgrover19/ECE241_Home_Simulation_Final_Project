module keysSelected([9:0]SW, [9:0]LEDR);
input reg [9:0]SW;
output [9:0]LEDR;

reg led[9:0];

always @(*) begin
    led[0] = SW[0];
    led[1] = SW[1];
    led[2] = SW[2];
    led[3] = SW[3];
    led[4] = SW[4];
    led[5] = SW[5];
    led[6] = SW[6];
    led[7] = SW[7];
    led[8] = SW[8];
    led[9] = SW[9];
end

assign LEDR[0] = led[0];
assign LEDR[1] = led[1];
assign LEDR[2] = led[2];
assign LEDR[3] = led[3];
assign LEDR[4] = led[4];
assign LEDR[5] = led[5];
assign LEDR[6] = led[6];
assign LEDR[7] = led[7];
assign LEDR[8] = led[8];
assign LEDR[9] = led[9];


endmodule

// this module allows the user to see which switch they have chosen based on the LED's picked.