module register_file
(
    input clock, 
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2,
    input wire write_enable
);

 //instantiate 32 RISC-V registers
(* ram_style = "block" *) reg [31:0] riscv_registers [31:0];
integer x = 0;

initial begin
    //Set all registers equal to 0 except for x2
    for (x=0; x < 32; x = x + 1) begin
        if(x == 2) begin
            riscv_registers[x] = `MEM_DEPTH + 32'h01000000;
        end
        else begin
            riscv_registers[x] = 32'h0000;
        end
    end 
end


always @(posedge clock) begin
    // REGISTER WRITES
    if(write_enable && addr_rd != 0) begin
        riscv_registers[addr_rd] <= data_rd;
    end 
    //REGISTER READS
    data_rs1 = riscv_registers[addr_rs1];
    data_rs2 = riscv_registers[addr_rs2];
end

endmodule

