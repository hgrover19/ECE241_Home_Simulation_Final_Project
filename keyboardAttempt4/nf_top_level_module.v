module nf_top_level_module(
aud_xclk,   // clock 12. MHz?
    bclk        , // bit stream clock
    adclrck , // left right clock ADC
    adcdat , // data stream ADC
    daclrck , // left right clock DAC
    dacdat , // data stream DAC
    sclk        , // serial clock I2C
    sdat        , // serail data I2C
    swt     ,
    clk     ,

    gpio,
    clap_detected
);

input adcdat;
input swt;
input clk;
input bclk;

input adclrck;
input daclrck;
inout sdat;

output aud_xclk;
output sclk;
output dacdat;
output[7:0] gpio;

output clap_detected;

// wire clap_detected;

audio u1( // generates the A-D audio signal
    .aud_xclk(aud_xclk), 
    .bclk(bclk) , 
    .adclrck(adclrck) , 
    .adcdat(adcdat) , 
    .daclrck(daclrck) , 
    .dacdat(dacdat) , // stream of data of audio
    .sclk(sclk)       ,
    .sdat(sdat)       , 
    .swt(swt)    ,
    .clk(clk)     ,
    .gpio(gpio)
);     

nf_clapDetected u2( // check if there was a clap detected
  .clk(clk),
  .audio_in(dacdat),
  .clap_detected(clap_detected)
);

endmodule

// there should be a final top level module connecting this top level module with the keyboard to approve/not approve the input.