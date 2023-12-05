module nf_clapDetected (
  input clk,
  input audio_in,
  output reg clap_detected
);

  // Define threshold
  parameter THRESHOLD = 8'b00010000; // original threshold was at 01000000. adjusted to be much lower to always run.

  // State definitions
  parameter IDLE = 3'b000;
  parameter DETECTING = 3'b001;
  parameter CLAP_DETECTED = 3'b010;

  // Registers
  reg [2:0] state, next_state;

  always @(posedge clk) begin
    // State machine 
    case (state)
      IDLE: begin
        if (audio_in > THRESHOLD) begin
          next_state = DETECTING;
        end else begin
          next_state = IDLE;
        end
      end

      DETECTING: begin
        if (audio_in > THRESHOLD) begin
          next_state = CLAP_DETECTED;
        end else begin
          next_state = IDLE;
        end
      end

      CLAP_DETECTED: begin
        next_state = IDLE;
      end
    endcase
  end

  always @(posedge clk) begin
    // Output logic
    case (state)
      IDLE: begin
        clap_detected = 1'b0;
      end

      DETECTING: begin
        clap_detected = 1'b0;
      end

      CLAP_DETECTED: begin
        clap_detected = 1'b1;
      end
    endcase
  end

  // Update state
  always @(posedge clk) begin
    state <= next_state;
  end

endmodule
