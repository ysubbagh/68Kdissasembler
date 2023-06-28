*-----------------------------------------------------------
* Title      : input and branching
* Written by : yasmine subbagh
* Date       : 6/25/23
* Description: input and brnaching tutorial
*-----------------------------------------------------------
CR          EQU     $0D
LF          EQU     $0A

START       ORG    $1000    ; first instruction of program

*output code
LOOP        LEA     MESSAGE, A1
            MOVE.L  #14,D0
            TRAP    #15

*input code
            MOVE.L  #4, D0
            TRAP    #15
            
            CMP.L   #2022263,D1
            BEQ     SCODE
            
            CMP.B   #20, D1
            BLT     INVALID
            CMP.B   #25, D1
            BGT     INVALID
            
            ;determine the entered number           
TWENTY      CMP     #20, D1
            BNE     TONE
            LEA     DISP20,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP
            
TONE        CMP     #21, D1
            BNE     TTWO
            LEA     DISP21,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP

TTWO        CMP     #22, D1
            BNE     TTHREE
            LEA     DISP22,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP 

TTHREE      CMP     #23, D1
            BNE     TFOUR
            LEA     DISP23,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP 
            
TFOUR       CMP     #24, D1
            BNE     TFIVE
            LEA     DISP24,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP

TFIVE       CMP     #25, D1
            BNE     INVALID
            LEA     DISP25,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     LOOP          
            
INVALID     LEA     INV, A1
            MOVE.B  #14, D0
            TRAP    #15
            BRA     LOOP
            
SCODE       LEA     EXIT, A1
            MOVE.B  #14, D0
            TRAP    #15
            BRA     DONE

DONE        MOVE.B  #9, D0
            TRAP    #15  

* variables
MESSAGE     DC.B    'Enter a number: ',0
INV         DC.B    'Invalid entry! Must be between 20 and 25.',CR,LF,0
EXIT        DC.B    'Student code entered, exiting...',0
DISP20      DC.B    ';)',CR,LF,0
DISP21      DC.B    '= 9 + 10',CR,LF,0
DISP22      DC.B    'Heyyy Taylor Swift!',CR,LF,0
DISP23      DC.B    'You lost how many tennis balls this week?!?',CR,LF,0
DISP24      DC.B    'YOU CAN FINALLY RENT A CAR!',CR,LF,0
DISP25      DC.B    ':{',CR,LF,0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
