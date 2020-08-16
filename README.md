# RISC-V-processor
Verilog Code of a 5 stage pipelined, 32 bit RISC V processor - M extension with some DSP instructions also.

RISC-V_july is the first file I created for this project. RISC_V_august is the improved version of the RISC_v_july file with all the bugs removed. Verilog codes of 
individual modules are also provided.

This project is the verilog code of a 32 bit 5 stage pipelined RISC V processor with all the R type, I type, load/store type and jump instructions. Apart from these basic ALU
instructions, the execute stage also has an accumulator unit, a saturation unit, and a barrel shifter, a unit for division with rounding off for some DSP applications.
The processor is an integer type processor with 32 registers. The register R0 is the zero register, R1-R30 are 32 bit general purpose register and R31 is the 64 bit
accumulator register.
