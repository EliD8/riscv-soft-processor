module mux_four_input(
  input wire [31:0] in_a,
  input wire [31:0] in_b,
  input wire [31:0] in_c,
  input wire [31:0] in_d,
  input wire [1:0] sel,
  output wire [31:0] out
);

assign out = sel[1] ? (sel[0] ? in_d : in_c) : (sel[0] ? in_b : in_a);

endmodule
