module alu(
    input wire [31:0] in_a,
    input wire [31:0] in_b,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [6:0] opcode,
    output reg [31:0] out
);

always@(*) begin
    case (funct3)
        3'b000 : begin  //0
            if(funct7 == 0)
                out = in_a + in_b;     //0: addition
            else
                out = in_a - in_b;     //0: subtraction
        end
        3'b001 : begin
            if(opcode == 7'b1100011 || opcode == 7'b0000011 || opcode == 7'b0100011) begin
                out = in_a + in_b;
            end else begin
            out = in_a << in_b[4:0];   //1: leftshift (logical)
            end
        end
        3'b010 : begin
            if(opcode == 7'b0000011 || opcode == 7'b0100011)
                out = in_a + in_b;
            else
                if($signed(in_a) < $signed(in_b))
                    out = 32'h00000001;
                else
                    out = 32'h0;
        end
        3'b011 : begin
            if(in_a < in_b)
                out = 32'h00000001;
            else
                out = 0;
        end    
        3'b100 : 
            if(opcode == 7'b1100011 || opcode == 7'b0000011) //BLT or LBU
                out = in_a + in_b;
            else
                out = in_a ^ in_b;    //4: XOR
        3'b101 : begin  //5
            if(opcode == 7'b1100011 || opcode == 7'b0000011)
                out = in_a + in_b;
            else if(funct7 == 7'b0)
                out = in_a >> in_b[4:0];    //5: rightshift (logical)
            else
                out = $signed(in_a) >>> in_b[4:0];    //5: rightshift (arithmatic, msb extends)
        end
        3'b110 : 
            if(opcode == 7'b1100011) //BLTU
                out = in_a + in_b;
            else
                out = in_a | in_b;    //6: OR
        3'b111 :
            if(opcode == 7'b1100011) //BGEU
                out = in_a + in_b;
            else
                out = in_a & in_b;    //7: AND
    endcase
end

endmodule
