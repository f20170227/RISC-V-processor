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

module control(input [31:0]inst_code, output reg branch, output reg regwrite, output reg immsel, output reg alusrc, output reg [3:0] alucontrol, 
output reg memread, output reg memwrite, output reg memtoreg, output reg acc, output reg mul);
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

//// multiplication without approximate multipliers
if (inst_code[6:0] == 7'b0110011 && inst_code[31:25] == 7'b0000001)
begin
branch = 0;
regwrite = 1;
alusrc = 0;
memtoreg = 0;
memread = 0;
memwrite = 0;
immsel = 0;
acc = 0;
mul = 1;
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
