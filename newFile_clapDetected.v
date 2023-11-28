module newFile_clapDetected(
    SDACL,          // Left channel audio data
    SDACR,          // Right channel audio data
    clk,            // Clock input
    enable,         // Master reset input
    clap_detected  // Output signal indicating clap detection
);

  output reg clap_detected;
  input [32:0] SDACL;
  input [32:0] SDACR;
  input clk;
  input enable;

  reg [7:0] clap_counter;  // Counter for clap detection

  always @(negedge enable or posedge clk) begin
    if (!enable) begin
        // reset
      clap_counter <= 8'b0;  // Reset clap counter
      clap_detected <= 1'b0; // Reset clap detection signal
    end
    else begin
      // check for clap
      // For simplicity, assume a clap when the audio level exceeds a threshold

      if (SDACL > 16'd50000 || SDACR > 16'd50000) begin // level of threshold
        clap_counter <= clap_counter + 1;
      end else begin
        clap_counter <= 8'b0;  // Reset counter if audio level is below threshold
      end

      // Clap detected when the counter reaches a certain value
      if (clap_counter == 8'd10) begin
        clap_detected <= 1'b1;
        clap_counter <= 8'b0;  // Reset counter after detection
      end
    end
  end

endmodule