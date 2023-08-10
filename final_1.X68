*-----------------------------------------------------------
* Title      : Final Project
* Written by : Yasmine Subbagh, Slava Arovina, Chin Cheung Lam
* Date       : 
*   Created:        06/27/23
*   Last Modified:  08/06/23
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
                        JSR     VALID_INPUT_SIZE              ; IF USER ACCIDENTALLY ENTER INVALID SIZE FOR THE INPUT (NEW)
                        ;BEQ     PRINTINPUTMSG                 ; LOOP BACK TO ASK USER INPUT AGAIN (NEW)
                        MOVE.L  A1, INPUT_HEXSTR        ; MOVE the Al to INPUT_HEXSTR convertor register (NEW)
                        JSR     HEXCONVERTOR            ;Converting the hex value from string (NEW)
                        MOVE.L  HEX_RESULT, STARTLOC    ; Store HEX_RESULT to STARTLOC (NEW)
                        
                                                
                        LEA     ENDLOCMSG, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        MOVE.B  #2, D0
INPUTEND                LEA     ENDLOC, A1
                        TRAP    #15
                        MOVE.L  A1, INPUT_HEXSTR        ; MOVE the Al to INPUT_HEXSTR convertor register (NEW)
                        JSR     HEXCONVERTOR            ; Converting the hex value from string (NEW)
                        MOVE.L  HEX_RESULT, ENDLOC      ; Store HEX_RESULT to ENDLOC (NEW)
                        JSR     CHECK_CONVERTED_HEXRESULT ; CHECK_ENDING_LOCATION_HEX_INPUT_RESULT

                        
FINALMSGS               MOVE.B  #14, D0
                        LEA     NOTES, A1
                        TRAP    #15
                             
*-------------------------------

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
                        BLE     ERROR_HEXRESULT
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
                        
                        
*-----------------CHECK_ENDING_LOCATION_HEX_INPUT_RESULT-------------------------(NEW)+(NOT USE YET)          
CHECK_CONVERTED_HEXRESULT
                        MOVE.L  ENDLOC, D5
                        MOVE.L  STARTLOC, D6
                        CMP.L   D5, D6               
                        BGT     GREATER_THAN_ENDINGLOC
                        RTS 
GREATER_THAN_ENDINGLOC  LEA     INVAILDENDLOCMSG,A1         
                        MOVE.B  #14, D0
                        TRAP    #15
                        CMP.L   #$FF00, D1       ; Clear the screen TASK 11   
                        BRA     PRINTINPUTMSG
                        
*---------------------------------------------------------------------------------------

ADRCHECK                MOVE.L  STARTLOC, D0
                        MOVE.L  ENDLOC, D1
                        CMP.L   D0, D1
                        BGT     VALIDADDRESS  ;startloc is less than end loc
                        
                        
                        
                        
*-----------------CHECK_INPUT_IF_VALID-------------------------                        
VALID_INPUT_SIZE        CMP.L   #0, D1              ; CHECK IF IT IS AN EMPTY INPUT
                        BEQ     EMPTY_INPUT         ; JSR TO EMPTY_INPUT
                                                    ; I deleted LESS_THAN_FOUR check.
                        RTS                        
                        
EMPTY_INPUT             LEA     EMPTYMSG,A1         
                        MOVE.B  #14, D0
                        TRAP    #15
                        CMP.L   #$FF00, D1          ; Clear the screen TASK 11 
                        BRA     PRINTINPUTMSG       ; Continue

                                                                                                          
                        
INVALIDADDRESS          LEA     INVADRMSG, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        CMP.L   #$FF00, D1          ; Clear the screen TASK 11
                        BRA     PRINTINPUTMSG       ;restart the program

VALIDADDRESS

*---------load each location in
                        MOVE.W  ENDLOC, (A2)
LOADSTARTADRDRESS       MOVE.W  STARTLOC, (A1)         ;Is this for current address?
                        MOVE.W  CURR_ADDRESS, (A1)  ;Is this for current address?(NEW+CHECK!!!!)James


DIASSEMBLE              CLR     D1
                        CLR     D2
                        MOVE.W  (A1),D1             ;unchanged
                        MOVE.W  D1, D2              ;modifyable                    
                                 
;CHECKFORNOP             CMP.W   #$4E71, D2
;                        BEQ     OPNOP
                        
;CHECKFORRTS             CMP.W   #$4E75, D2
;                        BEQ     OPRTS

GETFIRST8               
                        LSR.W   #4, D2


MOVEALLBITSOUT          LSR.W   #8, D2              ;clear all bits but first 4, moved into last byte
                        BRA     OPCODETABLE
                        
*-----------------OP CODE TABLE COMPARE-------------------------                           
OPCODETABLE             CMP.B   #%1001,D2
                        BEQ     OPSUB    

                        CMP.B   #%0100, D2
                        BEQ     OPLEA_NOP_NOT_JSR_RTS_MOVEM           (I changed)

                        CMP.B   #%1100, D2
                        BEQ     OPAND

                        CMP.B   #%1000, D2
                        BEQ     OPOR    
                        
                        CMP.B   #%1110, D2
                        BEQ     OPLSL_LSR_ASL_ASR_ROL_ROR      (I changed)
                        
                        ;CMP.B   #%1110, D2       (I think we only need one #%1110 for LSL, LSR, ASL, ASR, ROL, ROR) by Lam
                        ;BEQ     OPSHIFTROT


*-----------------------------NEW--------------------------------
                        CMP.B   #%1101, D2        
                        BEQ     OPADD_ADDA

                        CMP.B   #%0101, D2        
                        BEQ     OPADDQ

                        CMP.B   #%0001, D2
                        BEQ     OPMOVEB
                        
                        CMP.B   #%0011, D2
                        BEQ     OPMOVEW_MOVEAW

                        CMP.B   #%0010, D2
                        BEQ     OPMOVEL_MOVEAL
                        
                        CMP.B   #%0111, D2
                        BEQ     OPMOVEQ

                        CMP.B   #%0110, D2
                        BEQ     OPBRA_BCC

                        CMP.B   #%1011, D2
                        BEQ     OPCMP

*---------------------------------------------------------------  
OPSUB
                        LEA     SUB_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     AFTER_OPCODE
                        JSR     SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EA_SUB


OPLEA_NOP_NOT_JSR_RTS_MOVEM   
                        JSR     AFTER_OPCODE

                        MOVE.W  DESTINATION_MODE, D2
                        CMP.B   #%001, D2
                        BEQ     OPNOP_NOTW_RTS
                        
                        CMP.B   #%100, D2
                        BEQ     OPMOVEM_ADDRESS
                        
                        CMP.B   #%110, D2
                        BEQ     OPMOVEM_REGISTER

                        CMP.B   #%111, D2
                        BEQ     OPLEA

                        CMP.B   #%000, D2
                        BEQ     OPNOTB

                        CMP.B   #%010, D2
                        BEQ     OPNOTL_JSR 

                        BRA     OPINVALID

OPMOVEM_ADDRESS
                        LEA     MOVEM_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        
                        JSR     AFTER_OPCODE
                        JSR     MOVEM_SIZE_DETECTOR
                        JSR     PRINT_SPACE
                        BRA     EAMOVEM 

OPMOVEM_REGISTER
                        LEA     MOVEM_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        
                        JSR     AFTER_OPCODE
                        JSR     MOVEM_SIZE_DETECTOR
                        JSR     PRINT_SPACE
                        BRA     EAMOVEM 
                        
OPLEA
                        LEA     LEA_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_LEA 
                        
OPNOP_NOTW_RTS
                        MOVE.W  DESTINATION_REGISTER, D2
                        CMP.B   #%111, D2
                        BEQ     OPNOP_RTS

                        CMP.B   #%011, D2
                        BEQ     OPNOTW

                        BRA     OPINVALID

OPNOP_RTS               
                        MOVE.W  SOURCE_REGISTER, D2
                        CMP.B   #%001, D2
                        BEQ     OPNOP

                        CMP.B   #%101, D2
                        BEQ     OPRTS

                        BRA     OPINVALID

OPNOP                   
                        LEA     NOP_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOP_RST

OPRTS
                        LEA     RTS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOP_RST

OPNOTW
                        LEA     NOTW_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOT_JSR

OPNOTB
                        LEA     NOTB_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOT_JSR

OPNOTL_JSR
                        MOVE.W  DESTINATION_REGISTER, D2
                        CMP.B   #%011, D2
                        BEQ     OPNOTL

                        CMP.B   #%111, D2
                        BEQ     OPJSR

                        BRA     OPINVALID
                        
OPNOTL
                        LEA     NOTL_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOT_JSR

OPJSR
                        LEA     JSR_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EA_NOT_JSR

OPAND
                        LEA     AND_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                  
                        JSR     AFTER_OPCODE
                        JSR     SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAAND_OR

OPOR
                        LEA     OR_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                  
                        JSR     AFTER_OPCODE
                        JSR     SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAAND_OR


OPLSL_LSR_ASL_ASR_ROL_ROR
                        JSR     AFTER_OPCODE
                        MOVE.W  DESTINATION_MODE, D2
                        MOVE.W  #14,D5
                        LSL     D5, D2
                        LSR     D5, D2
                        
                        CMP.B   #%00, D2
                        BEQ     SHIFT_REGISTER
                        CMP.B   #%01, D2
                        BEQ     SHIFT_REGISTER
                        CMP.B   #%10, D2
                        BEQ     SHIFT_REGISTER
                        CMP.B   #%11, D2
                        BEQ     OPSHIFT_ADDRESS
                        
                        BRA     OPINVALID
                        

SHIFT_REGISTER                        
                        MOVE.W  SOURCE_MODE, D2
                        LSL     D5, D2
                        LSR     D5, D2

                        CMP.B   #%00, D2
                        BEQ     OPREGISTER_ASL_ASR
                        CMP.B   #%01, D2
                        BEQ     OPREGISTER_LSL_LSR
                        CMP.B   #%11, D2
                        BEQ     OPREGISTER_ROL_ROR
                        
                        
                        BRA     OPINVALID

OPREGISTER_ASL_ASR
                        LEA     AS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     SHIFT_SIZE_DETECTOR
                        JSR     PRINT_SPACE
                        
                        BRA     EALSL_LSR_ASL_ASR_ROL_ROR

OPREGISTER_LSL_LSR
                        LEA     LS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     SHIFT_SIZE_DETECTOR
                        JSR     PRINT_SPACE
                        
                        BRA     EALSL_LSR_ASL_ASR_ROL_ROR
                        
OPREGISTER_ROL_ROR
                        LEA     RO_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     SHIFT_SIZE_DETECTOR
                        JSR     PRINT_SPACE
                        
                        BRA     EALSL_LSR_ASL_ASR_ROL_ROR
                        
OPSHIFT_ADDRESS
                        MOVE.W  DESTINATION_MODE, D2
                        CMP.B   #%000, D2
                        BEQ     OPADDRESS_ASL_ASR
                       
                        CMP.B   #%001, D2
                        BEQ     OPADDRESS_LSL_LSR
                
                        CMP.B   #%011, D2
                        BEQ     OPADDRESS_ROL_ROR             
                
                        BRA     INVALID_OPCODE

OPADDRESS_ASL_ASR
                        LEA     AS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EASHIFT_ADDRESS

OPADDRESS_LSL_LSR
                        LEA     LS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EASHIFT_ADDRESS

OPADDRESS_ROL_ROR
                        LEA     RO_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EASHIFT_ADDRESS

OPADD_ADDA
                        JSR     AFTER_OPCODE
                        MOVE.W  DESTINATION_MODE, D2
                        
                        CMP.B   #%000, D2
                        BEQ     OPADD
                       
                        CMP.B   #%001, D2
                        BEQ     OPADD
                
                        CMP.B   #%010, D2
                        BEQ     OPADD
                        
                        CMP.B   #%100, D2
                        BEQ     OPADD

                        CMP.B   #%101, D2
                        BEQ     OPADD
                        
                        CMP.B   #%110, D2
                        BEQ     OPADD
                        
                        CMP.B   #%011, D2
                        BEQ     OPADDA
                        
                        CMP.B   #%111, D2
                        BEQ     OPADDA
                        
                        BRA     INVALID_OPCODE  

OPADD
                        LEA     ADD_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAADD

OPADDA
                        LEA     ADD_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     ADDA_SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAADDA

OPADDQ
                        LEA     ADD_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     AFTER_OPCODE
                        JSR     SIZE_DETECTOR
                        JSR     PRINT_SPACE

                        MOVE.W  HEX_RESULT, D2
                        BRA     EAADDQ

OPMOVEB
                        LEA     MOVEB_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     AFTER_OPCODE
                        JSR     PRINT_SPACE
                        
                        BRA     EAMOVEB

OPMOVEW_MOVEAW
                        JSR     AFTER_OPCODE
                        MOVE.W  DESTINATION_MODE, D2

                        CMP.B   #%001, D2
                        BEQ     OPMOVEAW

                        LEA     MOVEW_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     PRINT_SPACE

                        BRA     EAMOVEW

OPMOVEAW
                        LEA     MOVEW_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                       
                        JSR     PRINT_SPACE

                        BRA     EAMOVEAW

OPMOVEL_MOVEAL
                        JSR     AFTER_OPCODE
                        MOVE.W  DESTINATION_MODE, D2

                        CMP.B   #%001, D2
                        BEQ     OPMOVEAL

                        LEA     MOVEL_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     PRINT_SPACE

                        BRA     EAMOVEL

OPMOVEAL
                        LEA     MOVEAL_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                       
                        JSR     PRINT_SPACE

                        BRA     EAMOVEAL

OPMOVEQ
                        LEA     MOVEQ_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     AFTER_OPCODE        
                        JSR     PRINT_SPACE

                        BRA     EAMOVEQ
                        
OPBRA_BCC
                        ADD.L   #$2, CURR_ADDRESS        ; This is PC value
                        MOVE.L  HEX_RESULT, D2
                        
                        LSL     #4, D2
                        MOVE.w  #12, D7
                        LSR     D7, D2
                        
                        CMP.B   #%0000, D2
                        BEQ     OPBRA

                        CMP.B   #%0111, D2
                        BEQ     OPBEQ
                        
                        CMP.B   #%1110, D2
                        BEQ     OPBGT
                        
                        CMP.B   #%1111, D2
                        BEQ     OPBLE

                        BRA     OPINVALID
                        
OPBRA
                        LEA     BRA_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
       
                        JSR     PRINT_SPACE

                        BRA     EABCC_BRA

OPBEQ
                        LEA     BEQ_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
       
                        JSR     PRINT_SPACE

                        BRA     EABCC_BRA
                        
OPBGT
                        LEA     BGT_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
       
                        JSR     PRINT_SPACE

                        BRA     EABCC_BRA

OPBLE
                        LEA     BLE_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
       
                        JSR     PRINT_SPACE

                        BRA     EABCC_BRA
                        
OPCMP
                        LEA     CMP_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     AFTER_OPCODE
                        JSR     SIZE_DETECTOR        
                        JSR     PRINT_SPACE

                        BRA     EACMP

OPMOVEM                                                                    ; NEED TO WORK ON MOVEM!!!!


OPINVALID
                        LEA     INVALID_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAINVALID

*---------------------------EA-------------------------------



















*---------------------------Tools----------------------------
AFTER_OPCODE
                        MOVE.W  HEX_RESULT, D2
                        LSL     #4, D2
                        MOVE.W  #13,D7
                        LSR     D7, D2
                        MOVE.W  D2, DESTINATION_REGISTER

                        MOVE.W  HEX_RESULT, D2
                        LSL     #7, D2
                        LSR     D7, D2
                        MOVE.W  D2, DESTINATION_MODE

                        MOVE.W  HEX_RESULT, D2
                        MOVE.W  #10,D7
                        LSL     D5, D2
                        MOVE.W  #13,D7
                        LSR     D7, D2
                        MOVE.W  D2, SOURCE_MODE

                        MOVE.W  HEX_RESULT, D2
                        MOVE.W  #13,D7
                        LSL     D7, D2
                        LSR     D7, D2
                        MOVE.W  D2, SOURCE_REGISTER

                        MOVE.W  HEX_RESULT, D2
                        RTS

SIZE_DETECTOR              
                        CLR     D6
                        MOVE.W  DESTINATION_MODE, D2
                        CMP.B   #%100, D2
                        BLT     UNCHANGE_SIZE

                        MOVE.B  #1, D6
                        
                        CMP.B   #%100, D2
                        BEQ     PRINT_BYTE
                        CMP.B   #%101, D2
                        BEQ     PRINT_WORD
                        CMP.B   #%110, D2
                        BEQ     PRINT_LONG

UNCHANGE_SIZE           
                        CMP.B   #%000, D2
                        BEQ     PRINT_BYTE
                        CMP.B   #%001, D2
                        BEQ     PRINT_WORD
                        CMP.B   #%010, D2
                        BEQ     PRINT_LONG
                        RTS

ADDA_SIZE_DETECTOR
                        MOVE.W  DESTINATION_MODE, D2
                        CMP.B   #%011, D2
                        BEQ     PRINT_WORD

                        CMP.B   #%111, D2
                        BEQ     PRINT_LONG
                        RTS
SHIFT_SIZE_DETECTOR
                        MOVE.W  DESTINATION_MODE, D2
                        MOVE.W  #14,D7
                        LSL     D7, D2
                        LSR     D7, D2
                        
                        CMP.B   #%00, D2
                        BEQ     PRINT_BYTE
                        CMP.B   #%01, D2
                        BEQ     PRINT_WORD
                        CMP.B   #%10, D2
                        BEQ     PRINT_LONG
                        RTS
                        
MOVEM_SIZE_DETECTOR
                        MOVE.W  DESTINATION_MODE, D2
                        ;MOVE.W  #14,D7
                        ;LSL     D7, D2
                        ;LSR     D7, D2
                        
                        CMP.B   #%10, D2
                        BEQ     PRINT_WORD
                        CMP.B   #%11, D2
                        BEQ     PRINT_LONG
                        RTS

DIRECTION_DETECTOR
                        MOVE.W  DESTINATION_MODE, D2
                        LSR     #2, D2
                        
                        CMP.B   #%001, D2
                        BEQ     PRINT_LEFT

                        CMP.B   #%001, D2
                        BEQ     PRINT_RIGHT
                        RTS
                        
DISSDONE                
                        LEA     RESTARTQUESTION, A1
                        MOVE.B  #18, D0
                        TRAP    #15
                        
                        CMP.B   #0, D1
                        BEQ     PRINTINPUTMSG       ;user entered 0, restart the system
                        
                        LEA     EXITITING, A1       ;user entered 1, end program
                        MOVE.B  #14, D0
                        TRAP    #15
                        BRA     DONE               
                                                                
*------------output--------------
PRINT_LEFT              LEA     LEFT_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS
                
PRINT_RIGHT             LEA     RIGHT_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS
                
PRINT_BYTE              LEA     BYTE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS
                
PRINT_WORD              LEA     WORD_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS
                
PRINT_LONG              LEA     LONG_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS
COMMA_PRINT             
                        LEA Comma, A1                       
                        MOVE.B #14, D0
                        TRAP #15
                        RTS                        
PRINT_SPACE                                                    ; (NEW)
                        LEA     SPACE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        RTS


*--------------------------------
    

*------------WELCOME MESSAGES--------------
CR                      EQU     $0D
LF                      EQU     $0A

WELCOME                 DC.B    'WELCOME to the 68k dissasembler!',CR,LF,0
                        DC.B    'You will prompted to enter a starting and ending location for theprogram code you would like dissasembled.',CR,LF,0
                        DC.B    'Please enter these values in hexadecimal!',CR,LF,0
                        DC.B    'Ending location should be greater than starting location, and neither should be longer in length than 6 characters. You do not need to add $ or 0x',CR,LF,0
                        DC.B    'EXAMPLE: 6006',CR,LF,0
                
STARTLOCMSG             DC.B    'Address of starting location: $',0 

ENDLOCMSG               DC.B    CR,LF,'Address of ending location: $',0

NOTES                   DC.B    CR,LF,'LOADING...',CR,LF,0
                        DC.B    'PS. Only one pages worth will display at a time, press ENTER to load another page.',CR,LF,0
                        DC.B    'And anything that cannot be decoded will be displayed as "100 DATA $WXYZ"',CR,LF,0              
*----------------MESSAGES----------------------
INVADRMSG               DC.B    'The address entered are invalid.',CR,LF,0
                        DC.B    'Please try again!',CR,LF,0
                        
INVAILDENDLOCMSG        DC.B    'Ending location should be greater than starting location!',CR,LF,0
                        DC.B    'Please try again!',CR,LF,0                        
                        
EMPTYMSG                DC.B    'Input cannot be empty!',CR,LF,0        ; New 
                        DC.B    'Please try again!',CR,LF,0             ; New
                        
RESTARTQUESTION         DC.B    'Would you like to disassemble another program?',CR,LF,0
                        DC.B    'If yes, please enter 1.',CR,LF,0
                        DC.B    'If no, please enter 0.',CR,LF,0
                        
EXITITING               DC.B    'Thank you for using our disassembler! Goodbye...',CR,LF,0


*----------------68K_CODE_STRING----------------------(NEW)
LEFT_STRING             DC.B    'L',0
RIGHT_STRING            DC.B    'R',0

BYTE_STRING             DC.B    '.B',0
WORD_STRING             DC.B    '.W',0
LONG_STRING             DC.B    '.L',0

INVALID_OPCODE_STRING   DC.B    '??(OpCode)??',0
CMP_OPCODE_STRING       DC.B    'CMP',0
ADD_OPCODE_STRING       DC.B    'ADD',0
ADDA_OPCODE_STRING      DC.B    'ADDA',0
ADDQ_OPCODE_STRING      DC.B    'ADDQ',0
SUB_OPCODE_STRING       DC.B    'SUB',0
AND_OPCODE_STRING       DC.B    'AND',0
OR_OPCODE_STRING        DC.B    'OR',0
MOVEB_OPCODE_STRING     DC.B    'MOVE.B',0
MOVEQ_OPCODE_STRING     DC.B    'MOVEQ',0
MOVEW_OPCODE_STRING     DC.B    'MOVE.W',0
MOVEAW_OPCODE_STRING    DC.B    'MOVEA.W',0
MOVEL_OPCODE_STRING     DC.B    'MOVE.L',0
MOVEAL_OPCODE_STRING    DC.B    'MOVEA.L',0
MOVEM_OPCODE_STRING     DC.B    'MOVEM',0
BRA_OPCODE_STRING       DC.B    'BRA',0
BEQ_OPCODE_STRING       DC.B    'BEQ',0
BGT_OPCODE_STRING       DC.B    'BGT',0
BLE_OPCODE_STRING       DC.B    'BLE',0
LEA_OPCODE_STRING       DC.B    'LEA',0
NOTB_OPCODE_STRING      DC.B    'NOT.B',0
NOTW_OPCODE_STRING      DC.B    'NOT.W',0
NOTL_OPCODE_STRING      DC.B    'NOT.L',0
JSR_OPCODE_STRING       DC.B    'JSR',0
RTS_OPCODE_STRING       DC.B    'RTS',0
NOP_OPCODE_STRING       DC.B    'NOP',0
LS_OPCODE_STRING        DC.B    'LS',0
AS_OPCODE_STRING        DC.B    'AS',0
RO_OPCODE_STRING        DC.B    'RO',0

D_Mode                  DC.B    'D',0  * DATA REGISTER DIRECT 
A_Mode                  DC.B    'A',0  * ADDRESS REGISTER DIRECT
Plus_sign               DC.B    '+',0
Minus_sign              DC.B    '-',0
Open_pars               DC.B    '(',0  * OPEN PARENTHESIS
Close_pars              DC.B    ')',0  * CLOSE PARENTHIS
Hash_sign               DC.B    '#',0  * HASH SIGN
Dollar_sign             DC.B    '$',0  * DOLLAR SIGN
Comma                   DC.B    ',',0  * COMMA
Invalid_EA              DC.B    '??(EA)??', 0

SPACE_STRING            DC.B    ' ',0

0_STRING	            DC.B    '0',0
1_STRING	            DC.B    '1',0
2_STRING	            DC.B    '2',0
3_STRING	            DC.B    '3',0
4_STRING	            DC.B    '4',0
5_STRING	            DC.B    '5',0
6_STRING	            DC.B    '6',0
7_STRING	            DC.B    '7',0
8_STRING	            DC.B    '8',0
9_STRING	            DC.B    '9',0
A_STRING	            DC.B    'A',0
B_STRING	            DC.B    'B',0
C_STRING	            DC.B    'C',0
D_STRING	            DC.B    'D',0
E_STRING	            DC.B    'E',0
F_STRING	            DC.B    'F',0


*-----------------VARIABLES----------------
STARTLOC                DS.L    1    ; Longword of storage space for the address of the starting location for disassembly
ENDLOC                  DS.L    1    ; Longword of storage space for the address of the ending location for disassembly

DESTINATION_REGISTER    DS.L    1    ; Longword of storage space for the Destination Register
DESTINATION_MODE        DS.L    1    ; Longword of storage space for the Destination Mode
SOURCE_MODE             DS.L    1    ; Longword of storage space for the Source Mode
SOURCE_REGISTER         DS.L    1    ; Longword of storage space for the Source Register

CURR_ADDRESS            DS.L    1    ; Longword of storage space for the CURRENT_ADDRESS

*-----------------INPUT_STRING_TO_HEX_VARIABLES----------------
INPUT_HEXSTR            DS.L    1    ; longword of storage space for the input string to be converted
HEX_RESULT              DS.L    1    ; longword of storage for the resulting hexadecimal value
TRUNCATEDHEX            DS.B    1    ; byte of storage to indicate if the input string was truncated
INVALIDHEX              DS.B    1    ; byte of storage to indicate if the input string contained an invalid character
HEXSTR_ARRAY            DC.B    '0123456789ABCDEFabcdef',0  ;a byte array with all the valid hexadecimal characters
HEXVALUE_ARRAY          DC.B    '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,10,11,12,13,14,15,0'
*------------------------------------------
              

DONE
                        END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
