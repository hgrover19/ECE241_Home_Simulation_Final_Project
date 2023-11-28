module head_module(
    clk, 		// input 50 MHz clk
    ps_clk, 		// ps2 clock
    ps_data,
    toOutput,		// ps2 data
    return_msb,
    return_lsb
    );			// 40 pin header

    input clk;
    input ps_data;
    input ps_clk;

    output reg [7:0]toOutput; 
    //internal registers
    output [7:0]return_msb;
    output [7:0]return_lsb;
    
    reg [13:0] hex_out ;
    reg [7:0] counter;
    reg [10:0] data;

    wire [7:0] wire1;
    wire [7:0] wire2;
    wire [7:0] msb;
    wire [7:0] lsb;
    wire displayOrFsm;
    wire yesClap;

    // for keyboard operations
    keyboardRead u1(.ps_clk(ps_clk), .ps_data(ps_data), .clk(clk), .toOutput(wire1));

    store8bits u2(.input_data(wire1), .clock(clk), .select(1'b1), .resetn(1), .stored_data(msb));

    keyboardRead u3(.ps_clk(ps_clk), .ps_data(ps_data), .clk(clk), .toOutput(wire2));

    store8bits u4(.input_data(wire2), .clock(clk), .select(1'b1), .resetn(1), .stored_data(lsb));

    checkFor2num u5(.num1(msb), .num2(lsb), .is_true(displayOrFsm)); // decides hex or FSM with "true?" component

    // add module to detect sound input *********************

    NF_audioHead u6(.adcdat(adcdat), .swt(swt), .clk(clk), .bclk(bclk), .adclrck(adclrck), .daclrck(daclrck), .sdat(sdat),
    .yesClap(yesClap)); // yesclap is the output

    // sound header module **********************************

    keyboardEnd u7(.num1(msb), .num2(lsb), .select(displayOrFsm), .clap(yesClap), .val1(return_msb), .val2(return_lsb));
    // keyboardEnd sends to internal hexModule (need implementation)
    
endmodule