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
module mem_wb(input [31:0]mem_read, input clk, input res, input regwrite, input memtoreg, input acc, 
 input [31:0]alures, input [4:0]reg_dst, input [31:0]read_mem, 
input [63:0]acc_res, output reg regwrite_out , output reg memtoreg_out , output reg [4:0]reg_dst_1, output reg [31:0]read_mem_out,
output reg [31:0]alures_out, output reg [63:0]acc_res_out, output reg acc_out, output reg [31:0]mem_read_out );
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
mem_read_out <= 0;
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
mem_read_out <= mem_read;
end
end
endmodule
