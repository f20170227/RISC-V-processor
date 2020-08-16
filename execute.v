/// EX stage

module prealumux(input [31:0] shift, input [31:0]regdst, input alusrc, output reg [31:0]aluinp);
always@(*)
begin
if (alusrc==0)
begin
aluinp = regdst;
end

if (alusrc==1)
begin
aluinp = shift;
end
end
endmodule

module alu_assign_2 (input signed [31:0]aluinput1, input signed [31:0]aluinput2, input [3:0]aluop, input acc, output reg signed [31:0]result, output reg sat);
integer i;
integer j;
integer k;
integer temp;
always @(*)

begin

if (acc==0)
begin
case (aluop)
4'b0000: result = aluinput1+aluinput2;
4'b0001: result = aluinput1-aluinput2;
4'b0010: result = aluinput1<<aluinput2;
4'b0011: begin
	if (aluinput1<aluinput2)
	begin
	result = 1;
	end
	end
4'b0100: begin
	if (aluinput1<=aluinput2)
	begin
	result = 1;
	end
	end
4'b0101: result = aluinput1^aluinput2;
4'b0110: result = aluinput1>>>aluinput2;
4'b0111: result = aluinput1>>aluinput2;
4'b1000: result = aluinput1||aluinput2;
4'b1001: result = aluinput1&&aluinput2;
4'b1010: begin ///// modulus addition
	 if (aluinput1<0)
	begin
	j = 0-aluinput1;
	end
	if (aluinput2<0)
	begin
	k = 0-aluinput2;
	end
	result = j+k;
	end

  4'b1011 : begin ///// rotate cw
	  for (i=0;i<32;i=i+1)
	  begin
	  result[i] = aluinput1[(i+aluinput2)%32];
	  end
          end  
4'b1100 : begin ///// rotate acw
	  for (i=0;i<32;i=i+1)
	  begin
	  result[i] = aluinput1[(32+i-aluinput2)%32];
	  end
          end
4'b1101 : result = aluinput2;
4'b1110 : begin
			result = 0;
				
			result = result + ((aluinput1[7:0] * aluinput2[7:0]) + (aluinput1[15:8] * aluinput2[15:8]) + (aluinput1[23:16] * aluinput2[23:16]) + (aluinput1[31:24] * aluinput2[31:24]));
			
		  end

endcase


sat = 0;

if (aluinput1 > 0 && aluinput2>0 && result<0)
begin
result = 32'h7FFFFFFF;
sat = 1;
end

if (aluinput1 < 0 && aluinput2<0 && result>0)
begin
result = 32'h80000001;
sat = 1;
end
end
end
endmodule



module accumulator_x(input [31:0]inst_code, input signed [63:0]accumulator, input signed [31:0]input1, input signed [31:0]input2, input acc, output reg signed [63:0]res, output reg sat);
integer signed mid;
integer signed res1;
integer signed temp;
integer signed temp1;
always@(*)
begin

if (acc==1)
begin
if (inst_code[6:0] == 7'b0011111 || inst_code[6:0] ==7'b1111111)
begin
res =input1*input2;
sat = 0;
mid = 0;
mid = res/input1;
if (mid != input2)
begin
sat = 1;
res = 64'h7FFFFFFFFFFFFFFF;
end 
res1 = res;
res = accumulator + res;
if (accumulator>0 && res1>0 && res[63]==1)
begin
sat = 1;
res = 64'h7FFFFFFFFFFFFFFF;
end

if (accumulator<0 && res1<0 && res[63]==0)
begin
sat = 1;
res = 64'h7FFFFFFFFFFFFFFF;
end
end

if (inst_code[6:0] == 7'b0111111 && inst_code[14:12] == 3'b000)
begin
res = accumulator;
end

if (inst_code[6:0] == 7'b0111111 && inst_code[14:12] == 3'b111)
begin
res = 0;
end

if (inst_code[6:0] == 7'b1011111)
begin
res = accumulator/input1;
temp = accumulator%input1;
temp1 = input1/2;
if (temp > temp1)
begin
res = res+1;
end
end

end
end
endmodule


module forward(input memread_1, input memread, input ex_mem_regwrite, input [4:0] ex_mem_reg_dst, input [4:0] id_ex_reg_rs2, input [4:0]id_ex_reg_rs1,
input mem_wb_regwrite, input [4:0]mem_wb_reg_dst, input id_ex_acc, input ex_mem_acc, input mem_wb_acc, output reg [2:0]fout1,
 output reg [2:0]fout2, output reg [1:0]fout3);
always@(*)

begin
fout1 = 3'b000;
fout2 = 3'b000;
fout3 = 2'b00;
if (ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs1 )
begin
fout1 = 3'b001;
end

if (ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs2)
begin
fout2 = 3'b001;
end


if (!(ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs1 ) && mem_wb_regwrite == 1 && mem_wb_reg_dst != 0 && mem_wb_reg_dst == id_ex_reg_rs1)
begin
fout1 = 3'b010;
end

if (!(ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs2 ) && mem_wb_regwrite == 1 && mem_wb_reg_dst != 0 && mem_wb_reg_dst == id_ex_reg_rs2)
begin
fout2 = 3'b010;
end

if ((memread==1 && (ex_mem_reg_dst == id_ex_reg_rs1))
begin
fout1 = 3'b011;
end

if ((memread==1 && (ex_mem_reg_dst == id_ex_reg_rs2))
begin
fout2 = 3'b011;
end

if (!(memread==1 && (ex_mem_reg_dst == id_ex_reg_rs1)) && (memread_1==1 &&  mem_wb_reg_dst == id_ex_reg_rs1))
begin
fout1 = 3'b100;
end

if (!(memread==1 && (ex_mem_reg_dst == id_ex_reg_rs2)) && (memread_1==1 &&  mem_wb_reg_dst == id_ex_reg_rs2))
begin
fout2 = 3'b100;
end



if (id_ex_acc == 1 &&ex_mem_acc==1 && id_ex_acc ==ex_mem_acc)
begin
fout3 = 2'b01;
end

if(id_ex_acc == 1 && mem_wb_acc==1 && id_ex_acc != ex_mem_acc)
begin
fout3 = 2'b10;
end


end
endmodule

module mux_reg_1(input [31:0]mem_data_1, input [31:0]mem_data, input [31:0]ex_1, input [31:0]mem_1, input [31:0]wb_1, input [2:0]fout1, output reg [31:0]reg1);
always@(*)
begin
if (fout1 == 3'b000)
begin
reg1 = ex_1;
end

if (fout1 == 3'b001)
begin
reg1 = mem_1;
end

if (fout1 == 3'b010)
begin
reg1 = wb_1;
end

if (fout1 == 3'b011)
begin
reg1 = mem_data;
end

if (fout1 == 3'b100)
begin
reg1 = mem_data_1;
end

end
endmodule

module mux_reg_2(input [31:0]mem_data_1, input [31:0]mem_data, input [31:0]ex_2, input [31:0]mem_2, input [31:0]wb_2, input [2:0]fout2, output reg [31:0]reg2);
always@(*)
begin
if (fout2 == 3'b000)
begin
reg2 = ex_2;
end

if (fout2 == 3'b001)
begin
reg2 = mem_2;
end

if (fout2 == 3'b010)
begin
reg2 = wb_2;
end

if (fout2 == 3'b011)
begin
reg2 = mem_data;
end


if (fout1 == 3'b100)
begin
reg1 = mem_data_1;
end

end

end
endmodule

module mux_acc(input [63:0]ex_acc, input [63:0]mem_acc, input [63:0]wb_acc, input [1:0]fout3, output reg [63:0]acc);
always@(*)
begin
if (fout3 == 2'b00)
begin
acc = ex_acc;
end

if (fout3 == 2'b01)
begin
acc = mem_acc;
end

if (fout3 == 2'b10)
begin
acc = wb_acc;
end

end
endmodule








///////////pipeline for Ex/mem stage/////////////
module ex_mem(input clk, input res, input regwrite,  input memread, input memwrite, input memtoreg, input acc, 
 input [4:0]reg_dst, input [63:0]accumulator, input [31:0]alures, 
input [31:0]read_reg_2_data,
output reg regwrite_out , output reg memread_out , output reg memwrite_out , output reg memtoreg_out , 
output reg acc_out, output reg [63:0]accumulator_out,
 output reg [31:0]alures_out, output reg [4:0]reg_dst_out, output reg [31:0]read_reg_2_data_out);
always@(posedge clk, negedge res)
begin
if (res==0)
begin
regwrite_out  <= 0;
memread_out <= 0;
memwrite_out  <= 0;
memtoreg_out <= 0;
acc_out  <= 0 ;
accumulator_out <= 0;
alures_out <= 0;
reg_dst_out <= 0;
read_reg_2_data_out <= 0;
end
else
begin

regwrite_out  <= regwrite;
memread_out <= memread ;
memwrite_out  <= memwrite;
memtoreg_out <= memtoreg ;
acc_out  <= acc ;
accumulator_out <= accumulator;
reg_dst_out <= reg_dst;
alures_out <= alures;
read_reg_2_data_out <= read_reg_2_data;
end
end
endmodule

