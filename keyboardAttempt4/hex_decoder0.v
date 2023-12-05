// pass in the specific HEX on the board for display
// pass in a 4 bit wide number corresponding to the info on the HEX guide
// Example instantiation: hex_decoder u1 (.c(SW[7:4]), .display(HEX2));

module hex_decoder0([9:6]SW, hex0_out); // for left most hex display
  input [9:6] SW;
  output [6:0] hex0_out;

  wire [3:0]c;

  c = SW; // connect the 2

  assign hex0_out[0] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex0_out[1] = !((c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex0_out[2] = !((c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) &
                 (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex0_out[3] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|c[2]|c[1]|!c[0]) & (!c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex0_out[4] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) &
                 (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|c[2]|c[1]|!c[0]));

  assign hex0_out[5] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|c[0]) & (c[3]|c[2]|!c[1]|!c[0]) &
                 (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex0_out[6] = !((c[3]|c[2]|c[1]|c[0]) & (c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]));

endmodule

module hex_decoder1([9:6]SW, hex1_out); // for left most hex display
  input [9:6] SW;
  output [6:0] hex1_out;

  wire [3:0]c;

  c = SW; // connect the 2

  assign hex1_out[0] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex1_out[1] = !((c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex1_out[2] = !((c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) &
                 (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex1_out[3] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|c[2]|c[1]|!c[0]) & (!c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex1_out[4] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) &
                 (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|c[2]|c[1]|!c[0]));

  assign hex1_out[5] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|c[0]) & (c[3]|c[2]|!c[1]|!c[0]) &
                 (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex1_out[6] = !((c[3]|c[2]|c[1]|c[0]) & (c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]));

endmodule



