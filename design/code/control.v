module control(
  input wire reset,
  input wire [6:0] opcode,
  input wire [14:12] funct3,
  input wire [19:15] rs1,
  input wire [24:20] rs2,
  input wire [24:20] shamt,
  input wire [31:25] funct7,
  input wire [31:0] imm,
  output reg brun,
  output reg regwen,
  output reg bsel,
  output reg asel,
  // output reg alusel,   not needed as ALU uses funct3 and funct7 to do this calc internally
  // these get implemented in pd4
  output reg memrw,
  output reg [1:0] wbsel,
  output reg [1:0] dmem_access_size
);

always @(*) begin

  //Determining Branch Unsigned
  if(opcode == 7'b1100011 && (funct3 == 3'b110 || funct3 == 3'b111))
    brun = 1;
  else
    brun = 0;


  //Determining Register write
  if(reset == 1'b1) begin
    regwen = 1'b0;
  end else if(opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b1101111 || opcode == 7'b0010111 || opcode == 7'b0110111 || opcode == 7'b1100111)begin
    regwen = 1'b1;
  end else begin
    regwen = 1'b0;
  end

  //Determining Mux A select
  //Select PC for a branch or jump instruction
  if(opcode == 7'b1100011 || opcode == 7'b1101111 || opcode == 7'b0010111)begin
    asel = 1'b1;
  end else begin
    asel = 1'b0;
  end

//Determining Mux B select
//Select immediate for instructions that use an immediate
  if((opcode == 7'b0010011) || (opcode != 7'b0010011 && opcode != 7'b1110011 && opcode != 7'b0110011)) begin
    bsel = 1'b1;
  end else begin
    bsel = 1'b0;
  end

  //Sets memrw to 1 if it is a store instruction
  if (opcode == 7'b0100011) begin
    memrw = 1'b1;
  end else begin
    memrw = 1'b0;
  end


  if (opcode == 7'b0000011) begin   //LOAD instructions
    wbsel = 2'b10;
  end else if (opcode == 7'b1100111 || opcode == 7'b1101111) begin    //JAL and JALR instructions
    wbsel = 2'b01;
  end else begin        //All other instructions, where output comes from ALU or is not used (default to ALU out)
    wbsel = 2'b00;
  end

  dmem_access_size = funct3[13:12];

end

endmodule