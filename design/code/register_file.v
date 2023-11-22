module register_file #()
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
reg  [31:0] riscv_registers [32];

initial begin
    integer x;
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

// REGISTER WRITES
always @(posedge clock) begin
    if(write_enable && addr_rd != 0) begin
        riscv_registers[addr_rd] <= data_rd;
    end 
end

// REGISTER READS
assign data_rs1 = riscv_registers[addr_rs1];
assign data_rs2 = riscv_registers[addr_rs2];

endmodule

