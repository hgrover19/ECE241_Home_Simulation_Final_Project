module NF_audioHead(
    input adcdat, swt, clk, bclk,
    adclrck, daclrck, sdat,
    // output out, aud_xclk, sclk, dacdat, [7:0] gpio, yesClap
    output yesClap // only want to know if there is a clap, nothing else

);
    wire clap; // informs of clap detected

    output yesClap;

    audio u1(.aud_xclk(aud_xclk), .bclk(bclk), .adclrck(adclrck),
    .adcdat(adcadat), .daclrck(daclrck), .dacdat(dacdat), .sclk(sclk), 
    .sdat(sdat), .swt(swt), .clk(clk), .gpio(gpio));  

    serial_adc u2 (	.serial_adc(adcdat), .SADCL(serial_lf), 
    .SADCR(serial_rt), .adc_lr(adclrck), .clk(clk), 
    .enable(swt));

    newFile_clapDetected clapDetected(.SDACL(serial_lf), .SDACR(serial_rt),
    .clk(clk), . enable(enable), .clap_detected(clap));

    always @(*) begin
        case(clap) 
            1: assign yesClap = 1'b1;
            0: assign yesClap = 1'b0;
            default: assign yesClap = 1'b0; // shouldn't get here
        endcase 
    end
endmodule