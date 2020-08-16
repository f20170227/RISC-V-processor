/// ID stage//
module reg_file(input res, input [6:0]opcode, input acc, input [63:0] write_data_acc, input [4:0] read_reg_1, input [4:0] read_reg_2, 
input[4:0] write_reg_num, input [31:0] write_data, input regwrite,output [31:0] read_data_1, output [31:0] read_data_2, 
output reg [63:0] accumulator);

reg [31:0] reg_mem [30:0];
reg [63:0] reg_mem_1;
integer i;
assign read_data_1 = reg_mem[read_reg_1];
assign read_data_2 = reg_mem[read_reg_2];


always @ (*)
begin

reg_mem[0] = 8'h00;
if (res==0)
begin

reg_mem[1] = 8'h01;
reg_mem[2] = 8'h02;
reg_mem[3] = 8'h03;
reg_mem[4] = 8'h04;
reg_mem[5] = 8'h05;
reg_mem[6] = 8'h06;
reg_mem[7] = 8'h07;
reg_mem[8] = 8'h08;
reg_mem[9] = 8'h09;
reg_mem[10] = 8'h04;
reg_mem[11] = 32'h0000848A;
reg_mem[12] = 32'h00003456;
reg_mem[13] = 8'h00;
reg_mem[14] = 8'h00;
reg_mem[15] = 8'h00;
reg_mem[16] = 8'h00;
reg_mem[17] = 8'h00;
reg_mem[18] = 8'h00;
reg_mem[19] = 8'h00;
reg_mem[20] = 32'h7FFFFFFF;
reg_mem[21] = 32'h7FFFFFFF;
reg_mem[22] = 8'h00;
reg_mem[23] = 8'h00;
reg_mem[24] = 8'h00;
reg_mem[25] = 8'h00;
reg_mem[26] = 8'h00;
reg_mem[27] = 8'h00;
reg_mem[28] = 8'h00;
reg_mem[29] = 8'h00;
reg_mem[30] = 8'h00;
reg_mem[31] = 8'h00;
reg_mem_1 = 8'h00;
end
//if (write_reg_num == 5'b11111)
if (opcode == 7'b1111111 || opcode == 7'b0011111 || opcode == 7'b0111111 || opcode == 7'b1011111)
begin
accumulator = reg_mem_1;

end

if (regwrite == 1 && acc == 0 && write_reg_num != 0)
begin
reg_mem[write_reg_num]= write_data;
end

if (regwrite == 1 && acc == 1 && write_reg_num != 0 && write_reg_num != 5'b11111)
begin
reg_mem[write_reg_num]= write_data_acc[31:0];
i=1+write_reg_num;
reg_mem[i]= write_data_acc[63:32];
end

if (regwrite == 1 && acc == 1 && write_reg_num == 5'b11111)
begin
reg_mem_1 = write_data_acc;

end

end
endmodule



module shifter(input [31:0]inst_code, input immsel, output reg [31:0]sign_ext);
always@(*)
begin 
if (immsel == 0)
begin
sign_ext[11:0] = inst_code[31:20];
sign_ext[31:12] = inst_code[31];
end

if (immsel == 1)
begin
sign_ext[4:0] = inst_code[11:7];
sign_ext[11:5] = inst_code[31:25];
sign_ext[31:12] = inst_code[31];
end

end
endmodule

///////////pipeline for ID/EX stage/////////////
module id_ex(input [31:0]inst_code, input clk, input res,input regwrite, input alusrc, input [3:0] alucontrol, 
input memread, input memwrite, input memtoreg, input acc, input [4:0]read_reg_1, input [4:0]read_reg_2, input [4:0]reg_dst,input [63:0]accumulator, 
input [31:0]shift,input [31:0]read_reg_1_data,input [31:0]read_reg_2_data, output reg regwrite_out , 
output reg alusrc_out , output reg [3:0] alucontrol_out , output reg memread_out , 
output reg memwrite_out , output reg memtoreg_out , output reg acc_out, output reg [4:0]read_reg_1_out, 
output reg [4:0]read_reg_2_out,output reg [63:0]accumulator_out, output reg [31:0]shift_out, output reg [4:0]reg_dst_out, 
output reg [31:0]read_reg_1_data_out,output reg [31:0]read_reg_2_data_out, output reg [31:0]inst_code_out);
always@(posedge clk, negedge res)
begin
if (res==0)
begin
regwrite_out  <= 0;
alusrc_out  <= 0 ;
alucontrol_out <= 0 ;
memread_out <= 0;
memwrite_out  <= 0;
memtoreg_out <= 0;
acc_out  <= 0 ;
reg_dst_out <= 0;
read_reg_1_out <= 0;
read_reg_2_out <= 0;
accumulator_out <= 0;
shift_out <= 0;
read_reg_1_data_out <= 0;
read_reg_2_data_out <= 0;
inst_code_out <= 0;
end
else
begin
regwrite_out  <= regwrite;
alusrc_out  <= alusrc ;
alucontrol_out <= alucontrol ;
memread_out <= memread ;
memwrite_out  <= memwrite;
memtoreg_out <= memtoreg ;
acc_out  <= acc ;
reg_dst_out <= reg_dst;
read_reg_1_out <= read_reg_1;
read_reg_2_out <= read_reg_2;
accumulator_out <= accumulator;
shift_out <= shift;
read_reg_1_data_out <= read_reg_1_data;
read_reg_2_data_out <= read_reg_2_data;
inst_code_out <= inst_code;
end
end
endmodule

