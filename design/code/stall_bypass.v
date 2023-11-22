module stall_bypass(
  input wire [4:0] rs1_d,
  input wire [4:0] rs2_d,
  input wire [4:0] rd_e,
  input wire [4:0] rd_m,
  input wire [4:0] rd_w,
  input wire [6:0] opcode_d,
  input wire [6:0] opcode_e,
  output reg fetch_stall,
  output reg [1:0] rs1_bypass,
  output reg [2:0] rs2_bypass
);

reg stall_1;
reg stall_2;

always@(*) begin
  if(rs1_d != 0) begin
    if(rs1_d == rd_e) begin
      //rs1 is only ever needed in E, see if we can bypass from M to E, else stall
      if((opcode_e == 7'b0000011) || (opcode_e == 7'b1101111) || (opcode_e == 7'b1100111)) begin
        //required output not availible from M, stall
        stall_1 = 1;
        rs1_bypass = 0;
      end else begin
        //bypass M to E
        stall_1 = 0;
        rs1_bypass = 1;
      end
    end else if (rs1_d == rd_m) begin
      //bypass from W to E
      stall_1 = 0;
      rs1_bypass = 3;
    end else if (rs1_d == rd_w) begin
      //stall
      stall_1 = 1;
      rs1_bypass = 0;
    end else begin
        stall_1 = 0;
        rs1_bypass = 0;
    end
  end else begin
    stall_1 = 0;
    rs1_bypass = 0;
  end

  if(rs2_d != 0) begin
    if(rs2_d == rd_e) begin
      if(opcode_d == 7'b0000011) begin
        //this is a store instruction, bypass from W to M
        stall_2 = 0;
        rs2_bypass = 4;
      end else if((opcode_e == 7'b0000011) || (opcode_e == 7'b1101111) || (opcode_e == 7'b1100111)) begin
        //required output not availible from M, stall
        stall_2 = 1;
        rs2_bypass = 0;
      end else begin
        //bypass M to E
        stall_2 = 0;
        rs2_bypass = 1;
      end
    end else if (rs2_d == rd_m) begin
      //bypass from W to E
      stall_2 = 0;
      rs2_bypass = 3;
    end else if (rs2_d == rd_w) begin
      //stall
      stall_2 = 1;
      rs2_bypass = 0;
    end else begin
        stall_2 = 0;
        rs2_bypass = 0;
    end
  end else begin
    stall_2 = 0;
    rs2_bypass = 0;
  end

  fetch_stall = stall_1 | stall_2;
end

endmodule
