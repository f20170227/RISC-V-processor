

module riscv_proj(input clk, input res, output sat_alu, output sat_acc);

wire [31:0]pc;
wire [31:0]pc1;
wire [31:0]pc_4;
wire [31:0] pc_branch;
wire [31:0]inst_code;
wire branch;
wire regwrite; 
wire immsel;
wire alusrc;
wire [3:0] alucontrol;
wire memread;
wire memwrite;
wire memtoreg;  
wire acc;
wire [31:0]inst_code_out;
wire branch_out;
wire regwrite_out; 
wire immsel_out;
wire alusrc_out;
wire [3:0] alucontrol_out;
wire memread_out;
wire memwrite_out;
wire memtoreg_out;  
wire acc_out;


wire [63:0] write_data_acc; 
wire [4:0] read_reg_1; 
wire [4:0] read_reg_2; 
wire[4:0] write_reg_num; 
wire [31:0] write_data; 
wire [31:0] read_data_1; 
wire [31:0] read_data_2; 
wire [63:0] accumulator1; 
wire [31:0]sign_ext;
wire [31:0] read_reg_1_data;
wire [31:0] read_reg_2_data;
wire [31:0] read_reg_1_data_out;
wire [31:0] read_reg_2_data_out;
wire regwrite_out_1;
wire [3:0]alucontrol_out_1;
wire memread_out_1;
wire memwrite_out_1;
wire memtoreg_out_1;
wire acc_out_1;
wire alusrc_out_1;
wire [4:0]read_reg_1_out;
wire [4:0]read_reg_2_out;
wire [63:0]accumulator_out;
wire [31:0]sign_ext_out;
wire [4:0]reg_dst_out;
wire [2:0]fout1;
wire [2:0]fout2;
wire [1:0]fout3;
wire [31:0] read_reg_1_data_out_forward;
wire [31:0] read_reg_2_data_out_forward;
wire [63:0] acc_forward;


wire regwrite_out_2;
wire memread_out_2;
wire memwrite_out_2;
wire memtoreg_out_2;
wire acc_out_2;
wire [4:0]read_reg_1_out_1;
wire [4:0]read_reg_2_out_1;
wire [63:0]res_accu_1;
wire [31:0]alures_out_1;
wire [4:0]reg_dst_out_1;
wire [31:0]read_reg_2_data_out_1;
wire [63:0]accumulator;



wire [31:0]read_data;
wire regwrite_out_3;
wire memtoreg_out_3 ;
wire [4:0]reg_dst_out_2;
wire [31:0]read_data_out;
wire [31:0]alures_out_2;
wire [63:0]res_accu_2;
wire acc_out_3;

wire [31:0]aluinp;
wire [31:0]result; 
wire [63:0]res_accu;
wire [31:0] finale;
wire pcsrc;


wire [31:0]write_reg_data;
wire [31:0]inst_code_out_1;

wire [31:0]write_reg_data;
wire [31:0]inst_code_out_1;
wire mul;
wire mul_out;
wire mul_out_1;
wire [63:0]res_mul;
wire [63:0]res_mul_out;
wire mul_out_2;
wire [63:0]res_mul_out_1;
wire mul_out_3;
wire [63:0]mult_reg_out;
wire memread_out_3;


///// IF stage//////
inst_mem_assign_2 A1 ( pc,res,inst_code);
add_pc A2 (pc,pc_4);
pcc A3 (pc1,clk,res,pc);
control A4 (inst_code,branch,regwrite,immsel,alusrc,alucontrol,memread,memwrite,memtoreg,acc,mul);
add_gen A5 (pc,inst_code, pc_branch);
branch_mux A6 (pc_4, pc_branch,branch,pc1);
if_id A21 (clk,res, inst_code, regwrite, immsel,alusrc, alucontrol,memread,memwrite,memtoreg,acc, inst_code_out ,
regwrite_out ,immsel_out ,alusrc_out ,alucontrol_out ,memread_out ,memwrite_out , memtoreg_out ,acc_out);

///// ID stage//////
reg_file A7 (res,inst_code_out[6:0],acc_out_3, write_data_acc, inst_code_out[19:15], inst_code_out[24:20],  reg_dst_out_2, write_reg_data,
regwrite_out_3,read_reg_1_data,read_reg_2_data,accumulator);
shifter A8 (inst_code_out,immsel_out,sign_ext);
id_ex A9 (inst_code_out,clk,res,regwrite_out,alusrc_out,alucontrol_out, memread_out,memwrite_out,memtoreg_out,acc_out,inst_code_out[19:15],inst_code_out[24:20], inst_code_out[11:7],accumulator, 
sign_ext,read_reg_1_data,read_reg_2_data, regwrite_out_1 , alusrc_out_1 ,alucontrol_out_1 ,memread_out_1 , memwrite_out_1 ,
memtoreg_out_1 , acc_out_1,read_reg_1_out, read_reg_2_out,accumulator_out,sign_ext_out,reg_dst_out,read_reg_1_data_out,
read_reg_2_data_out,inst_code_out_1);

///////ex stage//////////
prealumux A10 (sign_ext_out,read_reg_2_data_out_forward,alusrc_out_1,aluinp);
alu_assign_2 A11 (read_reg_1_data_out_forward,aluinp, alucontrol_out_1,acc_out_1,result,sat_alu);
accumulator_x A12 (inst_code_out_1, acc_forward, read_reg_1_data_out_forward, aluinp, acc_out_1, res_accu, sat_acc);
forward A13 ( memread_out_3, memread_out_2, regwrite_out_2, reg_dst_out_1, read_reg_2_out, read_reg_1_out,
regwrite_out_3, reg_dst_out_2, acc_out_1, acc_out_2, acc_out_3, fout1, fout2,fout3);
mux_reg_1 A14 (read_data_out, read_data, read_reg_1_data_out, alures_out_1, alures_out_2,fout1, read_reg_1_data_out_forward);
mux_reg_2 A15 (read_data_out, read_data, read_reg_2_data_out, alures_out_1, alures_out_2, fout2, read_reg_2_data_out_forward);
mux_acc A16 (accumulator_out, res_accu_1, res_accu_2, fout3, acc_forward);
ex_mem A17 (clk,res,regwrite_out_1, memread_out_1, memwrite_out_1,memtoreg_out_1,acc_out_1, 
 reg_dst_out, res_accu, result,read_reg_2_data_out,
regwrite_out_2 ,memread_out_2 ,memwrite_out_2 , memtoreg_out_2 , 
acc_out_2,res_accu_1,
alures_out_1, reg_dst_out_1, read_reg_2_data_out_1);

/////mem stage//////////
mem A18 (alures_out_1,res,memwrite_out_2,memread_out_2,read_reg_2_data_out_1 ,read_data);
mem_wb A19 (memread_out_2,clk,res,regwrite_out_2,memtoreg_out_2,acc_out_2, 
alures_out_1, reg_dst_out_1, read_data, 
res_accu_1, regwrite_out_3 ,memtoreg_out_3 , reg_dst_out_2, read_data_out,
alures_out_2, res_accu_2, acc_out_3,memread_out_3);

/////wb stage///////
wb A20 (read_data_out,res_accu_2, alures_out_2, memtoreg_out_3, acc_out_3, write_reg_data, write_data_acc);
endmodule

module tb_comparch_proj();
reg clk;
reg res;
wire sat_acc;
wire sat_alu;

riscv_proj A25 (clk,res,sat_alu,sat_acc);
initial begin
res = 0;
#15 res = 1;
end

initial begin
clk = 0;
repeat(80)
#10 clk = ~clk;
end

endmodule


