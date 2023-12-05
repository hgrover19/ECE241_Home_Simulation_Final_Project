module hex_decoderStandard([9:6]SW, hex0_out); // for left most hex display
  input [7:0] input;
  output [6:0] hex0_out;

  wire [3:0]c;

  c = SW; // connect the 2

  assign hex6_out[0] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex6_out[1] = !((c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex6_out[2] = !((c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|c[0]) &
                 (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex6_out[3] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|c[2]|c[1]|!c[0]) & (!c[3]|c[2]|!c[1]|c[0]) & (!c[3]|!c[2]|!c[1]|!c[0]));

  assign hex6_out[4] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|!c[0]) & (c[3]|!c[2]|c[1]|c[0]) &
                 (c[3]|!c[2]|c[1]|c[0]) & (c[3]|!c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|c[2]|c[1]|!c[0]));

  assign hex6_out[5] = !((c[3]|c[2]|c[1]|!c[0]) & (c[3]|c[2]|!c[1]|c[0]) & (c[3]|c[2]|!c[1]|!c[0]) &
                 (c[3]|!c[2]|!c[1]|!c[0]) & (!c[3]|!c[2]|c[1]|!c[0]));

  assign hex6_out[6] = !((c[3]|c[2]|c[1]|c[0]) & (c[3]|c[2]|c[1]|!c[0]) & (c[3]|!c[2]|!c[1]|!c[0]) &
                 (!c[3]|!c[2]|c[1]|c[0]));

endmodule