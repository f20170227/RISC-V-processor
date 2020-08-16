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
