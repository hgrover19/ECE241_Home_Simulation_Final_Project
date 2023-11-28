module store8bits(
  input [7:0] input_data,
    clock, select, resetn,
  output reg [7:0] stored_data
);

  // Always block to store the 8-bit number
  always @(posedge clock or posedge resetn) begin
    if (~resetn || ~select) begin
      // Store nothing
      stored_data <= 8'b00000000;
    end else begin
      // Store the 8-bit number
      stored_data <= input_data;
    end
  end

endmodule







/* module store1bit(bitToStore, clock, select, result);
input 
    bitToStore,
    clock,
    select;
output
    reg result;

always @(posedge clock) begin
    case(select) 
        1: assign result = 1'b1;
        default: assign result = 1'b0;
    endcase
end

endmodule */