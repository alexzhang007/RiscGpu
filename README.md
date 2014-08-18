RiscGpu
=======
Copyright (C) 2014 by GrAphics RISC Technology Company (GART). 

##1. Introduction
ORGFX and THEIA are two opencore GPU project. THEIA abstracts the common graphical operations into matrix
process and develop the vector ALU. The graphic core has adepted the pipelined RISC CPU concept. While the
ORGFX just has the fixed common graphical operations which are reorganized with a pipelined stages. Comparingly,
THEIA is more flexible than that of ORGFX. ORGFX is difficult to format SIMD architecture since the pipeline
stage has been fixed. 

##2. Architecture
GDMA will fetch the data containing the vertex information from DDR to the vexter buffer. <br \>
CPU has programmed the register with the operations like rotation, light diffusion, camera angle ,and color/texture. 
The registers programming is to global registers shared by multi graphical cores. 
Following, CPU will deliver the rendering, shading and blending command to the ALU of graphic core according the 
register setting.
GDMA will write the memory data back to Framebuffer that is accessed by VGA (Display). <br \>
Support the SIMD (Single Instruction Multiple Data), the ALU can receive several instruction after which have been 
processed and the data will be written back to memory. 

##3. Driver
Gart complier can parse Gart language into .so and generate the RISC assembly code and put into the memory. When OpenGL
API is called, the assembly code will be dispatched by CPU from DDR to GART GPU. 

##4. Status
* 08.18.2014 <br>
  Start the register spec definition, finish the Vertex Shader, Vertex Stream, Texture Unit. <br>
  Start the RTL coding for texture_unit_reg_top.v
