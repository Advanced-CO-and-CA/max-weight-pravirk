  @ BSS section
      .bss

@ DATA SECTION
.data

data_start: .word 0x205A15E3; //(0010 0000 0101 1010 0001 0101 1101 0011 – 13)
            .word 0x256C8700; //(0010 0101 0110 1100 1000 0111 0000 0000 – 11)
data_end:   .word 0x295468F2; //(0010 1001 0101 0100 0110 1000 1111 0010 – 14)

NUM: .word 0
WEIGHT: .word 0

                         //0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F
BIT_SET_Count_TABLE: .word 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4

@ TEXT section
      .text

.globl _main

_main:
//Load the starting addres of BIT_SET_Count_TABLE
LDR R0, =BIT_SET_Count_TABLE

LDR R1, =data_start; //load the starting address of data items
LDR R6, =data_end;  //load the ending address of data items

LDR R7, [R1]; //R7<- Register to store the number having max weight
MOV R8, #0;   //R8<- Register to max weight

loop_get_max_weight:
  CMP R1, R6; // Exit the loop, if we have moved past the data_end
  BGT exit_loop_get_max_weight;

  LDR R2, [R1]; //get value of data item
  MOV R9, R2;   //save a copy of the data item
  MOV R4, #0;  //register to store weight

  /* In each iteration, get the 4LSB bits, and using lookup table,"BIT_SET_Count_TABLE"
  get the count of set bits.*/
  loop_get_weight:
    CMP R2, #0 //If data left is 0, exit the loop
    BEQ exit_loop_get_weight
    AND R5, R2, #0xF //R5<-  Get the LSB 4 bits of R2
    LDR R3, [R0, R5, LSL # 2] //R3(stores the number of set bits in 4LSB bits) <- BIT_SET_Count_TABLE[0] + ( 4 * R5 )
    ADD R4, R3 // R4<- R4 + R3, add to total count of set bits
    LSR R2, R2, #4; // Right shift data item by 4 bits
    B loop_get_weight
  exit_loop_get_weight:

  CMP R4, R8;
  BLE loop_invariance_get_max_weight
  MOV R8, R4;
  MOV R7, R9;
  loop_invariance_get_max_weight:
  ADD R1, #4 //get the address of next data_item
  B loop_get_max_weight

exit_loop_get_max_weight:
/*store results in memory*/
LDR R0, =NUM
STR R7, [R0]

LDR R0, =WEIGHT
STR R8, [R0]

