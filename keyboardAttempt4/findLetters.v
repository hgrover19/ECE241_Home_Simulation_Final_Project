module isD(
    data,
    isD,
)

input [10:0] data;

output isD;

assign isD = (data[1] & 1'b1) & (data[2] & 1'b1) & (!data[3] & !(1'b0)) & (!data[4] & !(1'b0)) & (!data[5] & !(1'b0)) & (data[6] & 1'b1) & (!data[7] & !(1
b0)) &(!data[8] & !(1'b0));

endmodule

module isL(
    data,
    isF
)

input [10:0] data;

output isD;

assign isD = (data[1] & 1'b1) & (data[2] & 1'b1) & (!data[3] & !(1'b0)) & (data[4] & 1'b1) & (!data[5] & !(1'b0)) & (!data[6] & !(1'b0)) & (data[7] & 1
b1) &(!data[8] & !(1'b0));

endmodule 

