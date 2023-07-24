*-----------------------------------------------------------
* Title      : Final Project
* Written by : Yasmine Subbagh, Slava Arovina, Chin Cheung Lam
* Date       : 
*   Created:        06/27/23
*   Last Modified:  07/12/23
* Description: 68k Assembly Dissasembler
*-----------------------------------------------------------

START           ORG     $1000
                
*------------input--------------
PRINTINPUTMSG           LEA     WELCOME, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        LEA     STARTLOCMSG, A1
                        TRAP    #15               
                        MOVE.B  #2, D0
INPUTSTART              LEA     STARTLOC, A1
                        TRAP    #15
                        MOVE.E  A1, INPUT_HEXSTR  ; MOVE the Al to ARG_HEXSTR
                        JSR     HEXCONVERTOR           
                        LEA     ENDLOCMSG, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        MOVE.B  #2, D0
INPUTEND                LEA     ENDLOC, A1
                        TRAP    #15
FINALMSGS               MOVE.B  #14, D0
                        LEA     NOTES, A1
                        TRAP    #15
                             
*-------------------------------

; a whole bunch of stufff

*------------output--------------



*--------------------------------
    

*------------WELCOME MESSAGES--------------
CR                      EQU     $0D
LF                      EQU     $0A

WELCOME                 DC.B    'WELCOME to the 68k dissasembler!',CR,LF,0
                        DC.B    'You will prompted to enter a starting and ending location for theprogram code you would like dissasembled.',CR,LF,0
                        DC.B    'Please enter these values in hexadecimal!',CR, LF,0
                        DC.B    'Ending location should be greater than starting location, and neither should be longer in length than 6 characters. You do not need to add $ or 0x',CR,LF,0
                        DC.B    'EXAMPLE: 6006',CR,LF,0
                
STARTLOCMSG             DC.B    'Address of starting location: $',0 

ENDLOCMSG               DC.B    CR,LF,'Address of ending location: $',0

NOTES                   DC.B    CR,LF,'LOADING...',CR,LF,0
                        DC.B    'PS. Only one pages worth will display at a time, press ENTER to load another page.',CR,LF,0
                        DC.B    'And anything that cannot be decoded will be displayed as "100 DATA $WXYZ"', CR,LF,0              
*------------------------------------------
*-----------------VARIABLES----------------
STARTLOC                DS.L    1
ENDLOC                  DS.L    1
*-----------------INPUT_STRING_TO_HEX_VARIABLES----------------
INPUT_HEXSTR            DS.L    1    ; longword of storage space for the input string to be converted
HEX_RESULT              DS.L    1    ; longword of storage for the resulting hexadecimal value
TRUNCATEDHEX            DS.B    1    ; byte of storage to indicate if the input string was truncated
INVALIDHEX              DS.B    1    ; byte of storage to indicate if the input string contained an invalid character
HEXSTR_ARRAY            DC.B    '0123456789ABCDEFabcdef',0  ;a byte array with all the valid hexadecimal characters
HEXVALUE_ARRAY          DC.B    '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,10,11,12,13,14,15,0'
*------------------------------------------
*-----------------INPUT_STRING_TO_HEX-------------------------
HEXCONVERTOR            MOVEM.L D0-D2/A0-A3,-(SP)
                        MOVE.B  #$0000,TRUNCATEDHEX
                        MOVE.B  #$0000,INVALIDHEX
                        CLR.L   D0
                        CLR.L   D1
                        MOVE.L  #$0000FFFC,D2
                        MOVEA.L INPUT_HEXSTR,A0
                        MOVEA.L A0,A1
LAST_INPUTCHAR          CMP.L   #0,(A0)+
                        BNE     LAST_INPUTCHAR
                        ADD.L   #$FFFFFFFF,A0
                        CMP.L   A1,A0
                        BLE     ERROR_HEX_RESULT
HEXCONVET_LOOP          ADDQ    #4,D2
                        CMP.L   #32,D2
                        BEQ     ERROR_TRUNCATEDHEX
                        CLR.L   D1
                        MOVE.B  -(A0),D1
                        MOVEA.L #HEXSTR_ARRAY,A2
                        MOVEA.L #HEXVALUE_ARRAY,A3
COMPARESTR_TO_HEXARR    CMP.B   (A2)+,D1
                        BEQ     HEXFOUND
                        ADDQ    #1,A3
                        CMP.B   #0,(A2)                        
                        BEQ     ERROR_HEXRESULT
                        BRA     COMPARESTR_TO_HEXARR
HEXFOUND                MOVE.B  (A3)+,D1
                        LSL.L   D2,D1
                        OR.L    D1,D0
                        CMP.L   A1,A0
                        BGT     HEXCONVET_LOOP
                        BRA     STOREDHEX                                                
ERROR_TRUNCATEDHEX      MOVE.B  #$0001,TRUNCATEDHEX
                        BRA     STOREDHEX
ERROR_HEXRESULT         MOVE.B  #$0001,HEX_RESULT
                        CLR.L   D0
STOREDHEX               MOVE.L  D0,HEX_RESULT
                        MOVEM.L (SP)+,D0-D2/A0-A3
                        RTS
*-----------------INPUT_STRING_TO_HEX-------------------------                        

DONE
                        END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
