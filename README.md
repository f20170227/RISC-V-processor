# RISC-V-processor
Verilog Code of a 5 stage pipelined, 32 bit RISC V processor - M extension with some DSP instructions also.

This is a bit different from the general RISC V processor. The total number of registers are 32 ranging from R0 to R31 in which R0 is the zeroth register, its value will always
remain 0, R1-R30 are 32 bit general purpose register and R31 is the 64 bit accumulator register. It has a jump instruction to the absolute address. The execution stage, apart from ALU has an accumulator unit, a saturation unit, 
a division operation with round off implementation and a barrel shifter. These units can be useful for some DSP applications like FIR filter. The control signals are generated 
in the instruction fetch stage only. Individual codes for the five stages of pipeline is also given.

The main advantage of this processor is that there will be no data hazard so there is no need of stalling clock for data dependent instructions. The forwarding unit has been 
modified with respect to the forwarding unit given in text books and the load type data hazards are also prevented in this processor.

