# 68Kdissasembler

What is a disassembler?
• Disassembler (also called an Inverse Assembler):
– Scans a section of memory, and
– Attempts to convert the memory’s contents to a listing of valid
assembly language instructions
• Most disassemblers cannot recreate symbolic, or label information
• Disassemblers can be easily fooled by not starting on an instruction
boundary
• How it works:
– The disassembler program parses the op-code word of the
instruction and then decides how many additional words of
memory need to be read in order to complete the instruction
– If necessary, reads additional instruction words
– The disassembler program prints out the complete instruction
in ASCII-readable format
• Converts binary information to readable Hex



Below are the list of instructions and addressing modes assigned for this project. 

Effective Addressing Modes:
Data Register Direct
Address Register Direct
Address Register Indirect
Immediate Data
Address Register Indirect with Post incrementing
Address Register Indirect with Pre decrementing
Absolute Long Address
Absolute Word Address

Op codes:
NOP
MOVE, MOVEQ, MOVEM, MOVEA
ADD, ADDA,ADDQ
SUB
LEA
AND,OR,NOT
LSL, LSR, ASL, ASR
ROL,ROR
Bcc (BGT, BLE, BEQ)
JSR, RTS
BRA
