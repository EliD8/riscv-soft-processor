module inst_decoder(
  input wire [31:0] inst,
  output reg [6:0] opcode,
  output reg [11:7] rd, 
  output reg [14:12] funct3,
  output reg [19:15] rs1,
  output reg [24:20] rs2,
  output reg [24:20] shamt,
  output reg [31:25] funct7,
  output reg [31:0] imm
);

always@(*) begin
    //All instructions use opcode
    opcode = inst[6:0];
    //Always reset immediate to avoid latch
    imm = 32'h00000000;

    //R-Format Register-Register instructions
    if(inst[6:0] == 7'b0110011) begin
        rd = inst[11:7];
        funct3 = inst[14:12];
        rs1 = inst[19:15];
        rs2 = inst[24:20];
        funct7 = inst[31:25];

        //shamt and imm aren't used in R-Format Register-Register instructions
        imm = 32'h00000000;
        shamt = 5'b00000;

    end
    //I-Format Arithmetic Instructions
    else if(inst[6:0] == 7'b0010011) begin
        rd = inst[11:7];
        funct3 = inst[14:12];
        rs1 = inst [19:15];
        //If we're shifting by an immediate
        if(inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
            shamt = inst[24:20];
            imm = {27'h0, inst[24:20]};
            funct7 = inst[31:25];
        end
        //If we're not shifting, just using the immediate
        else begin
            imm = {{20{inst[31]}}, inst[31:20]};
            shamt = 5'b00000;
            funct7 = 7'b0000000;
        end

        //rs2 isn't used in I-Format Arithmetic Instructions
        rs2 = 5'b00000;
        
    end
    //I-Format Load Instructions
    else if(inst[6:0] == 7'b0000011) begin
        rd = inst[11:7];
        funct3 = inst[14:12];
        rs1 = inst[19:15];
        imm = {{21{inst[31]}}, inst[30:20]};

        //Bit formats that aren't used for I-Format Load Instructions
        shamt = 5'b00000;
        rs2 = 5'b00000;
        funct7 = 7'b0000000;
    end
    //S-Format Store Instructions
    else if(inst[6:0] == 7'b0100011) begin
        funct3 = inst[14:12];
        rs1 = inst[19:15];
        rs2 = inst[24:20];
        imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};

        //Bit formats not used by S-Format Store Instructions
        rd = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end
    //B-Format Branch Instructions
    else if(inst[6:0] == 7'b1100011) begin
        funct3 = inst[14:12];
        rs1 = inst[19:15];
        rs2 = inst[24:20];
        imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

        //Bit formats not used by B-Format Branch Instructions
        rd = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end
    //LUI & AUIPC Instructions
    else if(inst[6:0] == 7'b0110111 || inst[6:0] == 7'b0010111) begin
        rd = inst[11:7];
        imm = {inst[31:12], 12'b000000000000};

        //Bit formats not used by LUI & AUIPC instructions
        funct3 = 3'b000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end
    //JAL instruction (J-Format)
    else if(inst[6:0] == 7'b1101111) begin
        rd = inst[11:7];
        imm[31:21] = {11{inst[31]}};
        imm[20] = inst[31];
        imm[19:12] = inst[19:12];
        imm[11] = inst[20];
        imm[10:1] = inst[30:21];
        imm[0] = 1'b0;
        
        

        //Bit formats not used for JAL instruction
        funct3 = 3'b000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end 
    // JALR instruction (J-Format)
    else if (inst[6:0] == 7'b1100111) begin
        rd = inst[11:7];
        rs1 = inst[19:15];
        imm = {{21{inst[31]}}, inst[30:20]};

        //Bit formats not used for JAL instruction
        funct3 = 3'b000;
        rs2 = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end
    //ECALL
    else if(inst[6:0] == 7'b1110011) begin
        rd = 5'b00000;
        imm = 32'h00000000;
        funct3 = 3'b000;
        rs1 = 5'b00000;
        rs2 = 5'b00000;
        shamt = 5'b00000;
        funct7 = 7'b0000000;
    end

    else begin
        rd = 0;
        funct3 = 0;
        rs1 = 0;
        rs2 = 0;
        shamt = 0;
        funct7 = 0;
        imm = 0;
    end

end

endmodule
