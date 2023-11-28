module access_size(
  input wire [31:0] data_in,
  input wire [1:0] access_size,
  input wire sign_ext,
  output reg [31:0] data_out
);

always @(*) begin
    if(access_size == 2'b00) begin
        if(sign_ext) begin
            data_out = {{24{data_in[7]}}, data_in[7:0]};
        end else begin
            data_out [7:0] = data_in[7:0];
            data_out [31:8] = 0;
        end 
    end else if(access_size == 2'b01) begin
        if(sign_ext) begin
            data_out = {{16{data_in[15]}}, data_in[15:0]};
        end else begin
            data_out [15:0] = data_in[15:0];
            data_out [31:16] = 0;
        end
    end else begin
        data_out [31:0] = data_in[31:0];
    end
end

endmodule
