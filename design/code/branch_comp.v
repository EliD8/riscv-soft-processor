module branch_comp(
    input wire [31:0] branch_a,
    input wire [31:0] branch_b,
    input wire [6:0] opcode,
    input wire [14:12] funct3,
    input wire brun,
    output reg pcsel
);  

wire signed [31:0] signed_a;
wire signed [31:0] signed_b;

assign signed_a = $signed(branch_a);
assign signed_b = $signed(branch_b);

reg breq;
reg brlt;

always@(*) begin
    if(brun) begin
        if(branch_a [31:0] == branch_b[31:0]) begin
            breq = 1'b1;
            brlt = 1'b0;
        end else if(branch_a [31:0] < branch_b[31:0]) begin
            brlt = 1'b1;
            breq = 1'b0;
        end else begin
            brlt = 1'b0;
            breq = 1'b0;
        end
    end else begin
        if(signed_a == signed_b) begin
            breq = 1'b1;
            brlt = 1'b0;
        end else if (signed_a < signed_b) begin
            brlt = 1'b1;
            breq = 1'b0;
        end else begin
            brlt = 1'b0;
            breq = 1'b0;
        end

    end


    //Determining PC Select
    // if BEQ instr and breq is true
    if(opcode == 7'b1100011 && funct3 == 3'b000 && breq)
        pcsel = 1; // else if BLT and brlt is true
    else if(opcode == 7'b1100011 && (funct3 == 3'b100 || funct3 == 3'b110) && brlt)
        pcsel = 1; // else if BGE and !brlt
    else if(opcode == 7'b1100011 && (funct3 == 3'b101 || funct3 == 3'b111) && (!brlt)) 
        pcsel = 1; //else if BNE and beq is false
    else if(opcode == 7'b1100011 && funct3 == 3'b001 && !breq)
        pcsel = 1;
    else if(opcode == 7'b1101111 || opcode == 7'b1100111)
        pcsel = 1; //JAL or JALR
    else
        pcsel = 0;


end

endmodule
