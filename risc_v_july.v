//// IF stage///
module inst_mem_assign_2( input [31:0]pc,input res,output [31:0] inst_code);
reg [7:0] mem[100:0];
assign inst_code= {mem[pc+3],mem[pc+2],mem[pc+1],mem[pc]};
always @(res)
begin
if (res==0)
begin

mem[0]=8'hB3; mem[1]=8'h02; mem[2]=8'h73; mem[3]=8'h00; //add r5,r6,r7
mem[4]=8'hB3; mem[5]=8'h02; mem[6]=8'h13; mem[7]=8'h00; //add r5,r6,r1
mem[8]=8'hB3; mem[9]=8'h02; mem[10]=8'h23; mem[11]=8'h00; //add r5,r6,r2
mem[12]=8'h93; mem[13]=8'h00; mem[14]=8'h51; mem[15]=8'h00; //addi r1,r2,5
mem[16]=8'h93; mem[17]=8'h81; mem[18]=8'h40; mem[19]=8'h00; //addi r3,r1,4
mem[20]=8'h93; mem[21]=8'h91; mem[22]=8'h20; mem[23]=8'h00; //slli r3,r1,2  //both forwarding checked
mem[24]=8'h33; mem[25]=8'h40; mem[26]=8'h20; mem[27]=8'h00; //add r0,r1,r2  //check if r0 is working
mem[28]=8'h23; mem[29]=8'h21; mem[30]=8'h11; mem[31]=8'h00; //sw r1,2(r2)  // check if store is working
mem[32]=8'h07; mem[33]=8'h01; mem[34]=8'h10; mem[35]=8'h00;  //li r2,1;
mem[36]=8'h33; mem[37]=8'h40; mem[38]=8'h20; mem[39]=8'h00; //add r0,r1,r2
mem[40]=8'h83; mem[41]=8'h21; mem[42]=8'h31; mem[43]=8'h00;  //lw r3,3(r2)  //check if load is working
mem[44]=8'hB3; mem[45]=8'h07; mem[46]=8'h5A; mem[47]=8'h01;  //add r15,r20,r21  // to check if saturation bit is working
mem[48]=8'h33; mem[49]=8'h92; mem[50]=8'h20; mem[51]=8'h1E;  //rotacw r4,r1,r2
mem[52]=8'hE3; mem[53]=8'h00; mem[54]=8'h00; mem[55]=8'h00;  //jump 1   //skips 1 instruction from current PC
mem[56]=8'h33; mem[57]=8'h92; mem[58]=8'h20; mem[59]=8'h1E;  //rotacw r4,r1,r2  //barrel shifter checked
mem[60]=8'h93; mem[61]=8'h81; mem[62]=8'h40; mem[63]=8'h00; //addi r3,r1,4
mem[64]=8'hFF; mem[65]=8'h8F; mem[66]=8'h11; mem[67]=8'h00; //acc r3,r1    // accumulator
mem[68]=8'h9F; mem[69]=8'h8F; mem[70]=8'h21; mem[71]=8'h00;  //acci r3,2   // accumulator immediate   
mem[72]=8'hBF; mem[73]=8'h00; mem[74]=8'h00; mem[75]=8'h00;  //trans r1,ac  // transfers the accumulator value(first 32 bits from LSB) into r1 
mem[76]=8'hDF; mem[77]=8'h01; mem[78]=8'h05; mem[79]=8'h00;  //div r3,ac,r10 // Divides ac by r10 and stores the value in r3(rounded off value)
mem[80]=8'hBF; mem[81]=8'h7F; mem[82]=8'h00; mem[83]=8'h00;  //set ac,0  // sets the accumulator register to 0
mem[84]=8'h33; mem[85]=8'h83; mem[86]=8'hC5; mem[87]=8'hFE;  //dotp r6,r11,r12 // dot product (bytewise) of r11 and r12 and stores tresult in r6
mem[88]=8'h83; mem[89]=8'h21; mem[90]=8'h31; mem[91]=8'h00;  //lw r3,3(r2)
mem[92]=8'h33; mem[93]=8'h81; mem[94]=8'h51; mem[95]=8'h00;  //add r2,r3,r5 // no stall is required after load

end
end
endmodule

module add_pc (input [31:0]pc, output [31:0]pc1);
assign pc1 = pc+4;
endmodule

module  pcc(input [31:0]pc, input clk, input res, output reg [31:0]pc_1);
always@(posedge clk)
begin
if (res==1 )
begin
pc_1 <= pc;
end
if (res==0)
begin
pc_1<=0;
end
end
endmodule

module add_gen(input signed [31:0]pcinput, input [31:0]inst_code, output reg [31:0]pc);
reg signed [31:0] temp;
always@(*)
begin

temp = 0;
temp[24:0] = inst_code[31:7];
temp = temp<<2;
temp[31:27] = temp[24];
//pc[24:0] = temp;
//pc[31:25] = temp[24];
if (temp[31] == 0)
begin
pc = temp+pcinput+32'h00000004;
end
if (temp[31] == 1)
begin
pc = temp+pcinput-32'h00000004;
end
end
endmodule

module branch_mux(input [31:0]pc_4, input [31:0]shift, input branch, output reg [31:0]pcout);
always@(*)
begin
if (branch==1)
begin
pcout = shift;
end

if (branch==0)
begin
pcout = pc_4;
end
end
endmodule

module control(input [31:0]inst_code, output reg branch, output reg regwrite, output reg immsel, output reg alusrc, output reg [3:0] alucontrol, output reg memread, output reg memwrite, output reg memtoreg, output reg acc);
always@(*)
begin

//// jump ////
if (inst_code[6:0] == 7'b1100011)
begin
branch = 1;
regwrite = 0;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
alucontrol = 0;
acc = 0;
end


/// register type////
if (inst_code[6:0] == 7'b0110011)
begin
branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 0;
if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b000)
begin
alucontrol = 4'b0000;
end

if (inst_code[31:25] == 7'b0100000 && inst_code[14:12] == 3'b000)
begin
alucontrol = 4'b0001;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b001) 
begin
alucontrol = 4'b0010;
end

if (inst_code[31:25] == 7'b0100000 && inst_code[14:12] == 3'b010)
begin
alucontrol = 4'b0011;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b011)
begin
alucontrol = 4'b0100;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b100)
begin
alucontrol = 4'b0101;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b101)
begin
alucontrol = 4'b0110;
end

if (inst_code[31:25] == 7'b0100000 && inst_code[14:12] == 3'b101)
begin
alucontrol = 4'b0111;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b110)
begin
alucontrol = 4'b1000;
end

if (inst_code[31:25] == 7'b0000000 && inst_code[14:12] == 3'b111)
begin
alucontrol = 4'b1001;
end

if (inst_code[31:25] == 7'b0001111 && inst_code[14:12] == 3'b000)
begin
alucontrol = 4'b1011;
end

if (inst_code[31:25] == 7'b0001111 && inst_code[14:12] == 3'b001)
begin
alucontrol = 4'b1100;
end

if (inst_code[31:25] == 7'b1111111 && inst_code[14:12] == 3'b000)
begin
alucontrol = 4'b1110;
end

end

/////// I type instructions/////
if (inst_code[6:0] == 7'b0010011)
begin

branch = 0;
regwrite = 1;
alusrc = 1;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 0;

if (inst_code[14:12] == 3'b000)
begin
alucontrol = 4'b0000;
end

if (inst_code[14:12] == 3'b010)
begin
alucontrol = 4'b0011;
end

if (inst_code[14:12] == 3'b001)
begin
alucontrol = 4'b0010;
end

if (inst_code[14:12] == 3'b101)
begin
alucontrol = 4'b0110;
end

if (inst_code[14:12] == 3'b011)
begin
alucontrol = 4'b0100;
end

if (inst_code[14:12] == 3'b100)
begin
alucontrol = 4'b0101;
end

if (inst_code[14:12] == 3'b110)
begin
alucontrol = 4'b1000;
end

if (inst_code[14:12] == 3'b111)
begin
alucontrol = 4'b1001;
end
end

///// load immediate/////
if (inst_code[6:0] == 7'b0000111)
begin

branch = 0;
regwrite = 1;
alusrc = 1;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
alucontrol = 4'b1101;
acc = 0;
end

///// load /////
if (inst_code[6:0] == 7'b0000011)
begin

branch = 0;
regwrite = 1;
alusrc = 1;
memtoreg = 1;
memread = 1;
memwrite = 0;
immsel = 0;
alucontrol = 4'b0000;
acc = 0;
end


///// store type/////
if (inst_code[6:0] == 7'b0100011)
begin

branch = 0;
regwrite = 0;
alusrc = 1;
memtoreg = 0;
memread = 0;
memwrite = 1;
immsel = 1;
alucontrol = 4'b0000;
acc = 0;
end

//// accumulator type R
if (inst_code[6:0] == 7'b1111111)
begin

branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 1;
end

//// accumulator I
if (inst_code[6:0] == 7'b0011111)
begin
branch = 0;
regwrite = 1;
alusrc = 1;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 1;
end

//// transfer value from accumulator to normal register
if (inst_code[6:0] == 7'b0111111 && inst_code[14:12] == 3'b000)
begin
branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 1;
end

/// set accumulator register to 0
if (inst_code[6:0] == 7'b0111111 && inst_code[14:12] == 3'b111)
begin
branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 1;
end

//// division of accumulator and a normal register and storing value into a different register
if (inst_code[6:0] == 7'b1011111)
begin
branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 1;
end
end
endmodule



/// pipeline for IF/ID stage///
module if_id(input clk, input res, input [31:0]inst_code, input regwrite, input immsel,
input alusrc, input [3:0] alucontrol, input memread, input memwrite, input memtoreg, input acc, 
output reg [31:0]inst_code_out ,output reg regwrite_out , output reg immsel_out ,
output reg alusrc_out , output reg [3:0] alucontrol_out , output reg memread_out , output reg memwrite_out , 
output reg memtoreg_out , output reg acc_out);
always@(posedge clk, negedge res)
begin
if (res==0)
begin
inst_code_out <= 0;
regwrite_out  <= 0;
immsel_out <= 0;
alusrc_out  <= 0 ;
alucontrol_out <= 0 ;
memread_out <= 0;
memwrite_out  <= 0;
memtoreg_out <= 0;
acc_out  <= 0 ;
end
else
begin
inst_code_out <= inst_code;
regwrite_out  <= regwrite;
immsel_out <= immsel;
alusrc_out  <= alusrc ;
alucontrol_out <= alucontrol ;
memread_out <= memread ;
memwrite_out  <= memwrite;
memtoreg_out <= memtoreg ;
acc_out  <= acc ;
end
end
endmodule



/// ID stage//
module reg_file(input res, input [6:0]opcode, input acc, input [63:0] write_data_acc, input [4:0] read_reg_1, input [4:0] read_reg_2, 
input[4:0] write_reg_num, input [31:0] write_data, input regwrite,output [31:0] read_data_1, output [31:0] read_data_2, 
output reg [63:0] accumulator);

reg [31:0] reg_mem [30:0];
reg [63:0] reg_mem_1;
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


module forward(input memread, input ex_mem_regwrite, input [4:0] ex_mem_reg_dst, input [4:0] id_ex_reg_rs2, input [4:0]id_ex_reg_rs1,
input mem_wb_regwrite, input [4:0]mem_wb_reg_dst, input id_ex_acc, input ex_mem_acc, input mem_wb_acc, output reg [1:0]fout1,
 output reg [1:0]fout2, output reg [1:0]fout3);
always@(*)

begin
fout1 = 2'b00;
fout2 = 2'b00;
fout3 = 2'b00;
if (ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs1 )
begin
fout1 = 2'b01;
end

if (ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs2)
begin
fout2 = 2'b01;
end


if (!(ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs1 ) && mem_wb_regwrite == 1 && mem_wb_reg_dst != 0 && mem_wb_reg_dst == id_ex_reg_rs1)
begin
fout1 = 2'b10;
end

if (!(ex_mem_regwrite == 1 && ex_mem_reg_dst !=0 && ex_mem_reg_dst == id_ex_reg_rs2 ) && mem_wb_regwrite == 1 && mem_wb_reg_dst != 0 && mem_wb_reg_dst == id_ex_reg_rs2)
begin
fout2 = 2'b10;
end

if (memread==1 && ex_mem_reg_dst == id_ex_reg_rs1)
begin
fout1 = 2'b11;
end

if ( memread==1 && ex_mem_reg_dst == id_ex_reg_rs2)
begin
fout2 = 2'b11;
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

module mux_reg_1(input [31:0]mem_data, input [31:0]ex_1, input [31:0]mem_1, input [31:0]wb_1, input [1:0]fout1, output reg [31:0]reg1);
always@(*)
begin
if (fout1 == 2'b00)
begin
reg1 = ex_1;
end

if (fout1 == 2'b01)
begin
reg1 = mem_1;
end

if (fout1 == 2'b10)
begin
reg1 = wb_1;
end

if (fout1 == 2'b11)
begin
reg1 = mem_data;
end

end
endmodule

module mux_reg_2(input [31:0]mem_data, input [31:0]ex_2, input [31:0]mem_2, input [31:0]wb_2, input [1:0]fout2, output reg [31:0]reg2);
always@(*)
begin
if (fout2 == 2'b00)
begin
reg2 = ex_2;
end

if (fout2 == 2'b01)
begin
reg2 = mem_2;
end

if (fout2 == 2'b10)
begin
reg2 = wb_2;
end

if (fout2 == 2'b11)
begin
reg2 = mem_data;
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

/// mem stage

module mem(input [31:0]address, input reset, input memwrite, input memread, input [31:0]write_data, output reg [31:0]read_data);
reg [7:0] mem [31:0];
reg [7:0]add1;
reg [7:0]add2;
reg [7:0]add3;
reg [7:0]add4;
always @(*)
begin
if (reset==0)
begin

mem[0] = 8'h00;
mem[1] = 8'h00;
mem[2] = 8'h00;
mem[3] = 8'h00;
mem[4] = 8'h00;
mem[5] = 8'h00;
mem[6] = 8'h00;
mem[7] = 8'h00;
mem[8] = 8'h00;
mem[9] = 8'h00;
mem[10] = 8'h00;
mem[11] = 8'h00;
mem[12] = 8'h00;
mem[13] = 8'h00;
mem[14] = 8'h00;
mem[15] = 8'h00;
mem[16] = 8'h00;
mem[17] = 8'h00;
mem[18] = 8'h00;
mem[19] = 8'h00;
mem[20] = 8'h00;
mem[21] = 8'h00;
mem[22] = 8'h00;
mem[23] = 8'h00;
mem[24] = 8'h00;
mem[25] = 8'h00;
mem[26] = 8'h00;
mem[27] = 8'h00;
mem[28] = 8'h00;
mem[29] = 8'h00;
mem[30] = 8'h00;
mem[31] = 8'h00;
end

add2 = address+1;
add3 = address+2;
add4 = address+3;

if (memwrite==1)
begin
mem[address]=write_data [7:0] ;
mem[add2]=write_data [15:8] ;
mem[add3]=write_data [23:16] ;
mem[add4]=write_data [31:24] ;
end

if (memread==1)
begin
read_data [7:0] = mem[address];
read_data [15:8] = mem[add2];
read_data [23:16] = mem[add3];
read_data [31:24] = mem[add4];
end
end
endmodule

///////////pipeline for mem/wb stage/////////////
module mem_wb(input clk, input res, input regwrite, input memtoreg, input acc, 
 input [31:0]alures, input [4:0]reg_dst, input [31:0]read_mem, 
input [63:0]acc_res, output reg regwrite_out , output reg memtoreg_out , output reg [4:0]reg_dst_1, output reg [31:0]read_mem_out,
output reg [31:0]alures_out, output reg [63:0]acc_res_out, output reg acc_out );
always@(posedge clk, negedge res)
begin
if (res==0)
begin
regwrite_out  <= 0;
memtoreg_out <= 0;
acc_out  <= 0 ;
alures_out <= 0;
acc_res_out <= 0;
reg_dst_1 <= 0;
read_mem_out <= 0;
end
else
begin

regwrite_out  <= regwrite;
memtoreg_out <= memtoreg ;
acc_out  <= acc ;
alures_out <= alures;
acc_res_out <= acc_res;
reg_dst_1 <= reg_dst;
read_mem_out <= read_mem;
end
end
endmodule


// WB stage//
module wb(input [31:0]read_data, input[63:0]accumulator, input [31:0]alu_res, input memtoreg, input acc, output reg [31:0]write_data, output reg[63:0]accumul);
always @(*)
begin
if (memtoreg==1)
begin
write_data = read_data;
end

if (memtoreg==0 && acc==1)
begin
accumul = accumulator;
end

if (memtoreg == 0 && acc==0)
begin
write_data = alu_res;
end
end
endmodule




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
wire [1:0]fout1;
wire [1:0]fout2;
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



///// IF stage//////
inst_mem_assign_2 A1 ( pc,res,inst_code);
add_pc A2 (pc,pc_4);
pcc A3 (pc1,clk,res,pc);
control A4 (inst_code,branch,regwrite,immsel,alusrc,alucontrol,memread,memwrite,memtoreg,acc);
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
forward A13 ( memread_out_2, regwrite_out_2, reg_dst_out_1, read_reg_2_out, read_reg_1_out,
regwrite_out_3, reg_dst_out_2, acc_out_1, acc_out_2, acc_out_3, fout1, fout2,fout3);
mux_reg_1 A14 (read_data, read_reg_1_data_out, alures_out_1, alures_out_2,fout1, read_reg_1_data_out_forward);
mux_reg_2 A15 (read_data, read_reg_2_data_out, alures_out_1, alures_out_2, fout2, read_reg_2_data_out_forward);
mux_acc A16 (accumulator_out, res_accu_1, res_accu_2, fout3, acc_forward);
ex_mem A17 (clk,res,regwrite_out_1, memread_out_1, memwrite_out_1,memtoreg_out_1,acc_out_1, 
 reg_dst_out, res_accu, result,read_reg_2_data_out,
regwrite_out_2 ,memread_out_2 ,memwrite_out_2 , memtoreg_out_2 , 
acc_out_2,res_accu_1,
alures_out_1, reg_dst_out_1, read_reg_2_data_out_1);

/////mem stage//////////
mem A18 (alures_out_1,res,memwrite_out_2,memread_out_2,read_reg_2_data_out_1 ,read_data);
mem_wb A19 (clk,res,regwrite_out_2,memtoreg_out_2,acc_out_2, 
alures_out_1, reg_dst_out_1, read_data, 
res_accu_1, regwrite_out_3 ,memtoreg_out_3 , reg_dst_out_2, read_data_out,
alures_out_2, res_accu_2, acc_out_3);

/////wb stage///////
wb A20 (read_data_out,res_accu_2, alures_out_2, memtoreg_out_3, acc_out_3, write_reg_data, write_data_acc);
endmodule

module tb_extra();
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

