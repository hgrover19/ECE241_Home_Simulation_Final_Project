module nf_clapDetected (
  input clk,
  input audio_in,
  output clap_detected
);

  // Define threshold
  parameter THRESHOLD = 8'b00001000; // original threshhold was at 01000000. adjusted to be much lower to always run.

  // State definitions
  typedef enum logic [2:0] {
    IDLE,
    DETECTING,
    CLAP_DETECTED
  } State;

  // Registers
  State state, next_state;
  logic clap_detected_reg;

  always_ff @(posedge clk) begin
    // State machine logic
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

  always_ff @(posedge clk) begin
    // Output logic
    case (state)
      IDLE: begin
        clap_detected_reg = 0;
      end

      DETECTING: begin
        clap_detected_reg = 0;
      end

      CLAP_DETECTED: begin
        clap_detected_reg = 1;
      end
    endcase
  end

  // Update state
  always_ff @(posedge clk) begin
    state <= next_state;
  end

  // Output
  assign clap_detected = clap_detected_reg;

endmodule
