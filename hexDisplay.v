// may need to do.

module hexDisplay(num1, num2, hex0_out, hex1_out);
    input [7:0] num1;
    input [7:0] num2;

    output reg hex0_out;
    output reg hex1_out;

    /* num 1 is msb, num2 is lsb,.
        order:
            hex1->num1
            hex0->num2
    */

