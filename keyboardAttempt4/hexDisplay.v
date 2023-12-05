module hexDisplay(letter, display, hex0_out); // for left most hex display
  input letter;
  input display;
  output [6:0] hex0_out;

  assign hex0_out[0] = !(1'b0);
  assign hex0_out[1] = !((!letter) & display);
  assign hex0_out[2] = !(!letter & display);
  assign hex0_out[3] = !(!letter & display);
  assign hex0_out[4] = !(!display);
  assign hex0_out[5] = !(letter & display);
  assign hex0_out[6] = !(!letter & display);

endmodule