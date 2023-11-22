module mux_two_input(
  input wire [31:0] in_a,
  input wire [31:0] in_b,
  input wire sel,
  output wire [31:0] out
);

// select of  makes out become a, 1 sets it to b
assign out = (sel) ? in_b : in_a;

endmodule
