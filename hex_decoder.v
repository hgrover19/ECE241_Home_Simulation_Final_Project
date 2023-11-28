// pass in the specific HEX on the board for display
// pass in a 4 bit wide number corresponding to the info on the HEX guide
// Example instantiation: hex_decoder u1 (.c(SW[7:4]), .display(HEX2));

module hex_decoder(c, display);
  input [3:0] c;
  output [6:0] display;

  assign display[0] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|!c[0]));

  assign display[1] = !((c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign display[2] = !((c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) &
                 (!c[3]|!c[2]|!c[1]|!c[0]));

  assign display[3] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|c[2]|c[1]|!c[0]) & (!c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign display[4] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) &
                 (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|c[2]|c[1]|!c[0]));

  assign display[5] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|c[0]) & (c[3]|c[2]|!c[1]|!c[0]) &
                 (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|!c[2]|c[1]|!c[0]));

  assign display[6] = !((c[3]|c[2]|c[1]|c[0]) & (c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]));

endmodule