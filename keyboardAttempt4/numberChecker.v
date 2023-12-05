module numberChecker (
  input wire clk,
  input wire reset,
  input wire [3:0] input1,
  input wire [3:0] input2,
  output reg isNumber
);

// Define states
typedef enum logic [2:0] {
  IDLE,
  VALIDATE
} state_type;

// Define signals
reg [2:0] state, next_state;

// State register
always_ff @(posedge clk or posedge reset) begin
  if (reset) begin
    state <= IDLE;
  end else begin
    state <= next_state;
  end
end

// Next state logic
always_comb begin
  case (state)
    IDLE: begin
      if (input1[3:0] != 4'bxxxx && input2[3:0] != 4'bxxxx) begin
        next_state = VALIDATE;
      end else begin
        next_state = IDLE;
      end
    end

    VALIDATE: begin
      if ((input1[3:0] >= 4'b0000 && input1[3:0] <= 4'b1001) &&
          (input2[3:0] >= 4'b0000 && input2[3:0] <= 4'b1001)) begin
        isNumber = 1'b1;
      end else begin
        isNumber = 0;
      end
      next_state = IDLE;
    end

    default: next_state = IDLE;
  endcase
end

endmodule
