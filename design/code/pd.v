module pd(
  input clock,
  input reset
);

//WIRE AND REG DECLARATIONS
/**************************/
//Fetch Stage wires & regs
reg [31:0] pc_f;
wire [31:0] inst_f ;
wire [31:0] pc_f_plus_4;
wire [31:0] muxPC_out_f;
wire [31:0] next_pc_f;

//Decode Stage wires and regs
//registering inputs from last stage
wire [31:0] inst_d;
reg [31:0] pc_d;
//Other registers and wires used in this stage
wire [6:0] opcode_d;
wire [4:0] rd_d;
wire [2:0] funct3_d;
wire [4:0] rs1_d;
wire [4:0] rs2_d;
wire [4:0] shamt_d;
wire [6:0] funct7_d;
wire [31:0] imm_d;
wire [31:0] data_rs1_d;
wire [31:0] data_rs2_d;
wire regwen_d;
wire brun_d;
wire muxA_sel_d;
wire muxB_sel_d;
wire dmem_write_d;
wire [1:0] WBsel_d;
wire [1:0] dmem_access_size_d;
//Stall Wires
wire fetch_stall;
wire decode_stall;
wire decode_nop;
reg decode_nop_d;
wire [1:0] rs1_bypass_d;
wire [2:0] rs2_bypass_d;

//Execute Stage wires and regs
//registering inputs from last stage
wire [31:0] data_rs1_imm_e;
wire [31:0] data_rs2_imm_e;
reg [4:0] rd_e;
reg [31:0] pc_e;
reg brun_e;
reg muxA_sel_e;
reg muxB_sel_e;
reg dmem_write_e;
reg [1:0] WBsel_e;
reg [1:0] dmem_access_size_e;
reg [6:0] opcode_e;
reg [2:0] funct3_e;
reg [6:0] funct7_e;
reg [31:0] imm_e;
reg regwen_e;
reg [1:0] rs1_bypass_e;
reg [2:0] rs2_bypass_e;
//wires/registers used in this stage
wire [31:0] alu_out_e;
wire pcsel_e_im;
wire pcsel_e;
wire [31:0] data_rs1_e;
wire [31:0] data_rs2_e;
wire [31:0] data_rs1_bypass;
wire [31:0] data_rs2_bypass;

//Memory Stage wires and regs
//registering inputs from last stage
reg [31:0] pc_m;
reg [4:0] rd_m;
reg dmem_write_m;
reg [1:0] WBsel_m;
reg [1:0] dmem_access_size_m;
reg regwen_m;
reg [31:0] alu_out_m;
reg [2:0] funct3_m;
reg [31:0] data_rs2_m;
reg rs2_bypass_m;
//wires/registers used in this stage
wire [31:0] dmem_out_m;
wire [31:0] data_rd_m;

//Write stage wires and regs
reg [31:0] data_rd_imm_w;
wire [31:0] data_rd_w;
reg [4:0] rd_w;
reg regwen_w;
(* dont_touch = "true" *) reg [31:0] pc_w; 
reg WBsel_w;
/**************************/

initial begin
  pc_f = 32'h01000000;
end

//FETCH STAGE
/**************************/
assign pc_f_plus_4 = pc_f + 4;

imemory imemory0(
  .clock(clock),
  .address(pc_f),
  .data_in(0),
  .read_write(0),
  .enable(~fetch_stall),
  .data_out(inst_f)
);

mux_two_input fetch_stall_mux(
  .in_a(pc_f_plus_4),
  .in_b(pc_f),
  .out(next_pc_f),
  .sel(fetch_stall)
);

mux_two_input muxPC(
  .in_a(next_pc_f),
  .in_b(alu_out_e),
  .out(muxPC_out_f),
  .sel(pcsel_e)
);

//Increase pc_f by 4
always @(posedge clock) begin
  if(reset) begin
    pc_f <= 32'h01000000;
  end else begin
    pc_f <= muxPC_out_f;
  end
end
/**************************/

//DECODE STAGE
/**************************/
always @(posedge clock) begin
  if(reset) begin
    // inst_d <= 0;
    pc_d <= 0;
    decode_nop_d <= 0;
  end else begin
    if(decode_nop) begin
      // inst_d <= 0;
      pc_d <= 0;
      decode_nop_d <= 1;
    end else begin
      // inst_d <= (fetch_stall) ? inst_d : inst_f;
      pc_d <= (fetch_stall) ? pc_d : pc_f;
      decode_nop_d <= 0;
    end
  end
end

mux_two_input mux_clear_inst(
  .in_a(inst_f),
  .in_b(0),
  .out(inst_d),
  .sel(decode_nop_d)
);

inst_decoder inst_decoder0(
  .inst(inst_d),
  .opcode(opcode_d),
  .rd(rd_d),
  .funct3(funct3_d),
  .rs1(rs1_d),
  .rs2(rs2_d),
  .shamt(shamt_d),
  .funct7(funct7_d),
  .imm(imm_d)
);

control control0(
  .reset(reset),
  .opcode(opcode_d),
  .funct3(funct3_d),
  .rs1(rs1_d),
  .rs2(rs2_d),
  .shamt(shamt_d),
  .funct7(funct7_d),
  .imm(imm_d),
  .brun(brun_d),
  .regwen(regwen_d),
  .asel(muxA_sel_d),
  .bsel(muxB_sel_d),
  .memrw(dmem_write_d),
  .wbsel(WBsel_d),
  .dmem_access_size(dmem_access_size_d)
);

//clock is only used for writes, so register clock should be aligned with writeback clock
register_file register_file0(
  .clock(clock),
  .addr_rs1(rs1_d),
  .addr_rs2(rs2_d),
  .addr_rd(rd_w),
  .data_rd(data_rd_w),
  .data_rs1(data_rs1_d),
  .data_rs2(data_rs2_d),
  .write_enable(regwen_w)
);

// assign fetch_stall = ((rs1_d != 0) && ((rs1_d == rd_e) || (rs1_d == rd_m) || (rs1_d == rd_w))) || ((rs2_d != 0) && ((rs2_d == rd_e) || (rs2_d == rd_m) || (rs2_d == rd_w)));
assign decode_nop = pcsel_e;
assign decode_stall = pcsel_e | fetch_stall;

stall_bypass stall_bypass0(
  .rs1_d(rs1_d),
  .rs2_d(rs2_d),
  .rd_e(rd_e),
  .rd_m(rd_m),
  .rd_w(rd_w),
  .opcode_d(opcode_d),
  .opcode_e(opcode_e),
  .reset(reset),
  .fetch_stall(fetch_stall),
  .rs1_bypass(rs1_bypass_d),
  .rs2_bypass(rs2_bypass_d)
);

/**************************/

//EXECUTE STAGE
/**************************/
always @(posedge clock) begin
  if(reset) begin
    // data_rs1_imm_e <= 0;
    // data_rs2_imm_e <= 0;
    rd_e <= 0;
    pc_e <= 0;
    brun_e <= 0;
    muxA_sel_e <= 0;
    muxB_sel_e <= 0;
    dmem_write_e <= 0;
    WBsel_e <= 0;
    dmem_access_size_e <= 0;
    opcode_e <= 0;
    funct3_e <= 0;
    funct7_e <= 0;
    imm_e <= 0;
    regwen_e <= 0;
    rs1_bypass_e <= 0;
    rs2_bypass_e <= 0;
  end else begin
    // data_rs1_imm_e <= (decode_stall) ? 0 : data_rs1_d;
    // data_rs2_imm_e <= (decode_stall) ? 0 : data_rs2_d;
    rd_e <= (decode_stall) ? 0 : rd_d;
    pc_e <= (decode_stall) ? 0 : pc_d;
    brun_e <= (decode_stall) ? 0 : brun_d;
    muxA_sel_e <= (decode_stall) ? 0 : muxA_sel_d;
    muxB_sel_e <= (decode_stall) ? 0 : muxB_sel_d;
    dmem_write_e <= (decode_stall) ? 0 : dmem_write_d;
    WBsel_e <= (decode_stall) ? 0 : WBsel_d;
    dmem_access_size_e <= (decode_stall) ? 0 : dmem_access_size_d;
    opcode_e <= (decode_stall) ? 0 : opcode_d;
    funct3_e <= (decode_stall) ? 0 : funct3_d;
    funct7_e <= (decode_stall) ? 0 : funct7_d;
    imm_e <= (decode_stall) ? 0 : imm_d;
    regwen_e <= (decode_stall) ? 0 : regwen_d;
    rs1_bypass_e <= (decode_stall) ? 0 : rs1_bypass_d;
    rs2_bypass_e <= (decode_stall) ? 0 : rs2_bypass_d;
  end
end

// mux_two_input decode_stall_data1(
//   .in_a(data_rs1_d),
//   .in_b(0),
//   .out(data_rs1_imm_e),
//   .sel(decode_stall)
// );

// mux_two_input decode_stall_data2(
//   .in_a(data_rs2_d),
//   .in_b(0),
//   .out(data_rs2_imm_e),
//   .sel(decode_stall)
// );
assign data_rs1_imm_e = data_rs1_d;
assign data_rs2_imm_e = data_rs2_d;

mux_two_input rs1_bypass_in_mux(
  .in_a(alu_out_m),
  .in_b(data_rd_w),
  .out(data_rs1_bypass),
  .sel(rs1_bypass_e[1])
);

mux_two_input rs1_bypass_mux(
  .in_a(data_rs1_imm_e),
  .in_b(data_rs1_bypass),
  .out(data_rs1_e),
  .sel(rs1_bypass_e[0])
);

mux_two_input rs2_bypass_in_mux(
  .in_a(alu_out_m),
  .in_b(data_rd_w),
  .out(data_rs2_bypass),
  .sel(rs2_bypass_e[1])
);

mux_two_input rs2_bypass_mux(
  .in_a(data_rs2_imm_e),
  .in_b(data_rs2_bypass),
  .out(data_rs2_e),
  .sel(rs2_bypass_e[0])
);

//TODO: Not sure if E_BR_TAKEN is set correctly in signals.h
branch_comp branch_comp0(
  .branch_a(data_rs1_e),
  .branch_b(data_rs2_e),
  .opcode(opcode_e),
  .funct3(funct3_e),
  .brun(brun_e),
  .pcsel(pcsel_e)
);

wire [31:0] muxA_out_e;
mux_two_input muxA(
  .in_a(data_rs1_e),
  .in_b(pc_e),
  .out(muxA_out_e),
  .sel(muxA_sel_e)
);

wire [31:0] muxB_out_e;
mux_two_input muxB(
  .in_a(data_rs2_e),
  .in_b(imm_e),
  .out(muxB_out_e),
  .sel(muxB_sel_e)
);

alu alu0(
  .in_a(muxA_out_e),
  .in_b(muxB_out_e),
  .funct3(funct3_e),
  .funct7(funct7_e),
  .opcode(opcode_e),
  .out(alu_out_e)
);

/**************************/

//Memory STAGE
/**************************/
always @(posedge clock) begin
  if(reset) begin
    pc_m <= 0;
    rd_m <= 0;
    dmem_write_m <= 0;
    WBsel_m <= 0;
    dmem_access_size_m <= 0;
    regwen_m <= 0;
    alu_out_m <= 0;
    funct3_m <= 0;
    data_rs2_m <= 0;
    rs2_bypass_m <= 0;
  end else begin
    pc_m <= pc_e;
    rd_m <= rd_e;
    dmem_write_m <= dmem_write_e;
    WBsel_m <= WBsel_e;
    dmem_access_size_m <= dmem_access_size_e;
    regwen_m <= regwen_e;
    alu_out_m <= alu_out_e;
    funct3_m <= funct3_e;
    data_rs2_m <= data_rs2_e;
    rs2_bypass_m <= rs2_bypass_d[2];
  end
end

dmemory dmemory0(
  .clock(clock),
  .address(alu_out_m),
  .data_in(data_rs2_m),
  .read_write(dmem_write_m),
  .access_size(dmem_access_size_m),
  .data_out(dmem_out_m)
);

mux_two_input MuxMem(
  .in_a(alu_out_m),
  .in_b(pc_m + 4),
  .out(data_rd_m),
  .sel(WBsel_m[0])
);

// mux_four_input MuxWB(
//   .in_a(dmem_out_m),
//   .in_b(alu_out_m),
//   .in_c(pc_m + 4),
//   .in_d(),
//   .out(data_rd_m),
//   .sel(WBsel_m)
// );
/**************************/

//Write STAGE
/**************************/
always @(posedge clock) begin
  if(reset) begin
    data_rd_imm_w <= 0;
    // data_rd_w <= 0;
    rd_w <= 0;
    regwen_w <= 0;
    pc_w <= 0;
    WBsel_w <= 0;
  end else begin
    data_rd_imm_w <= data_rd_m;
    // data_rd_w <= data_rd_m;
    rd_w <= rd_m;
    regwen_w <= regwen_m;
    pc_w <= pc_m;
    WBsel_w <= WBsel_m[1];
  end
end

mux_two_input MuxWrite(
  .in_a(data_rd_imm_w),
  .in_b(dmem_out_m),
  .out(data_rd_w),
  .sel(WBsel_w)
);
/**************************/

endmodule

