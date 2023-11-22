/* Your Code Below! Enable the following define's
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                pc_f
`define F_INSN              inst_v

`define D_PC                pc_d
`define D_OPCODE            opcode_d
`define D_RD                rd_d
`define D_RS1               rs1_d
`define D_RS2               rs2_d
`define D_FUNCT3            funct3_d
`define D_FUNCT7            funct7_d
`define D_IMM               imm_d
`define D_SHAMT             shamt_d

`define R_WRITE_ENABLE      regwen_d
`define R_WRITE_DESTINATION rd_w
`define R_WRITE_DATA        data_rd_w
`define R_READ_RS1          rs1_d
`define R_READ_RS2          rs2_d
`define R_READ_RS1_DATA     data_rs1_d
`define R_READ_RS2_DATA     data_rs2_d

`define E_PC                pc_e
`define E_ALU_RES           alu_out_e
`define E_BR_TAKEN          pcsel_e

`define M_PC                pc_e
`define M_ADDRESS           alu_out_m
`define M_RW                dmem_write_m
`define M_SIZE_ENCODED      dmem_access_size_m
`define M_DATA              dmem_out_m

`define W_PC                pc_w
`define W_ENABLE            regwen_w
`define W_DESTINATION       rd_w
`define W_DATA              data_rd_w

`define IMEMORY             imemory0
`define DMEMORY             dmemory0

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
