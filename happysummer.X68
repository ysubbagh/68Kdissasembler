*-----------------------------------------------------------
* Title      : Final Project
* Written by : Yasmine Subbagh, Slava Arovina, Chin Cheung Lam
* Date       : 
*   Created:        06/27/23
*   Last Modified:  08/10/23
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
INPUTSTART              LEA     INPUT_HEXSTR, A1
                        TRAP    #15
                        JSR     VALID_INPUT_SIZE              ; IF USER ACCIDENTALLY ENTER INVALID SIZE FOR THE INPUT (NEW)
                        ;BEQ     PRINTINPUTMSG                 ; LOOP BACK TO ASK USER INPUT AGAIN (NEW)
                        ;MOVE.L  STARTLOC,INPUT_HEXSTR        ; MOVE the Al to INPUT_HEXSTR convertor register (NEW), QUESTION!!!! should this be (A1?)
                        MOVE.B  D1, D2
                        JSR     HEXCONVERTOR            ;Converting the hex value from string (NEW)
                        MOVE.L  HEX_RESULT, STARTLOC    ; Store HEX_RESULT to STARTLOC (NEW)
                        
                                                
                        LEA     ENDLOCMSG, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        MOVE.B  #2, D0
INPUTEND                LEA     INPUT_HEXSTR, A1
                        TRAP    #15
                        ;MOVE.L  ENDLOC,INPUT_HEXSTR        ; MOVE the Al to INPUT_HEXSTR convertor register (NEW)
                        MOVE.B  D1, D2
                        JSR     HEXCONVERTOR            ; Converting the hex value from string (NEW)
                        MOVE.L  HEX_RESULT, ENDLOC      ; Store HEX_RESULT to ENDLOC (NEW)
                        JSR     CHECK_CONVERTED_HEXRESULT ; CHECK_ENDING_LOCATION_HEX_INPUT_RESULT
                                                                                                   ; <----------------------; I think we need write some code for user input machine code!!!!                                                                      
                        
                        
FINALMSGS               MOVE.B  #14, D0
                        LEA     NOTES, A1
                        TRAP    #15
                        
                        BRA     LOADSTARTADRDRESS              
                             
*-------------------------------

*-----------------INPUT_STRING_TO_HEX-------------------------
HEXCONVERTOR            LEA     INPUT_HEXSTR, A1
CONVLOOPT               CMP.B   #$00, (A1)
                        BEQ     BITSHIFT
                        CMP.B   #$39, (A1)
                        BLE     NUMBER                  
LETTER                  SUB.B   #55, (A1)+            
NUMBER                  SUB.B   #48, (A1)+   
                        BRA     CONVLOOPT   

BITSHIFT                CLR     D0
                        CLR     D1
                        LEA     INPUT_HEXSTR, A1
LOAD                    MOVE.B  (A1)+, D0
                        AND.B   #$0F, D0
                        LSL.L   #4, D1
                        OR.L    D0, D1
                        SUB.B   #1, D2
                        CMP.B   #0, D2  ;address limit
                        BEQ     HEX_DONE
                        BRA     LOAD
        
HEX_DONE                MOVE.L  D1, HEX_RESULT
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

;ADRCHECK                MOVE.L  STARTLOC, D0
;                        MOVE.L  ENDLOC, D1
;                        CMP.L   D0, D1
;                        BGT     VALIDADDRESS  ;startloc is less than end loc
                                                                
                        
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

*---------load each locaLR     
LOADSTARTADRDRESS       CLR     D0
                        CLR     D1
                        CLR     D2
                        LEA     ENDLOC, A0
                        MOVE.L  (A0),D0
                        LEA     STARTLOC, A1         ;Is this for current address?
                        MOVE.L  (A1), D1
                        ;MOVE.W  CURR_ADDRESS, A1  ;Is this for current address?(NEW+CHECK!!!!)James

                                                                                                     ; I think we need write some code for user input machine code!!!!
DIASSEMBLE              MOVE.L  D1, D2
                           

PRINTCURRADDR           ;JSR     PRINTADDR               
                                 
;CHECKFORNOP             CMP.W   #$4E71, D2
;                        BEQ     OPNOP
                        
;CHECKFORRTS             CMP.W   #$4E75, D2
;                        BEQ     OPRTS

GETFIRST8               
                        LSR.W   #4, D2


MOVEALLBITSOUT          LSR.W   #8, D2              ;clear all bits but first 4, moved into last byte
                        BRA     OPCODETABLE
                        
*-----------------ADDRESS PRINTINTG-------------------------                         
PRINTADDR               MOVE.W  A1, D7
                        MOVE.B  #15, D1
                        MOVE.B  #16, D2
                        TRAP    #15
                        LEA  SPACE_STRING, A1
                        MOVE.B  #4, D0
                        TRAP    #15
             
                        RTS    
*-----------------------------------------------------------                         
                        
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
                        
                        BRA     OPINVALID           ;invalid line

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
                        BRA     EALEA 
                        
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
                        BRA     EANOP_RST

OPRTS
                        LEA     RTS_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EANOP_RST

OPNOTW
                        LEA     NOTW_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EANOT_JSR

OPNOTB
                        LEA     NOTB_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EANOT_JSR

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
                        BRA     EANOT_JSR

OPJSR
                        LEA     JSR_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_SPACE
                        BRA     EANOT_JSR

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
                
                        BRA     OPINVALID

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
                        
                        BRA     OPINVALID  

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

OPINVALID
                        LEA     INVALID_OPCODE_STRING, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                
                        JSR     DIRECTION_DETECTOR
                        JSR     PRINT_SPACE

                        BRA     EAINVALID

*---------------------------EA-------------------------------
EAINVALID
                        LEA     Dollar_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        MOVE.W  HEX_RESULT,D2
                        JSR     HEXCONVERTOR
                        
                        BRA     DISSDONE     ; NEED TO CHECK
                        
EAMOVEM               ;--------------------------------------------->NEED TO WORK


EAADD
                        CMP.B   #1, DESTINATION_MODE
                        BEQ     EAADD_FIRSTDn

                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     PRINT_COMMA
                        JSR     EATABLE_MODE
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        
                        BRA     DISSDONE

EAADD_FIRSTDn
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        
                        BRA     DISSDONE
EAADDA
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTAn_MODE
                        BRA     DISSDONE
EAADDQ
                        LEA     Hash_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        CLR.L   D6
                        MOVE.W  DESTINATION_REGISTER, D6
                        CMP.B   #%0000, D6
                        BEQ     OVERFLOW_ADDQ
                        
FIX_OVERFLOW_ADDQ       
                        JSR     PRINT_IMMEDIATE_SIGN
                        JSR     PRINT_COMMA
                        
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE
OVERFLOW_ADDQ                        
                        MOVE.W  #%1000, D6
                        BRA     FIX_OVERFLOW_ADDQ
                        
EA_SUB
                        CMP.B   #1, DESTINATION_MODE
                        BEQ     EASUB_FIRSTDn

                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA

                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE

                        BRA     DISSDONE
EASUB_FIRSTDn
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        
                        BRA     DISSDONE
                        
EALEA
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTAn_MODE
                        BRA     DISSDONE

EANOP_RST
                        BRA     DISSDONE
                        
EANOT_JSR               
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        
                        BRA     DISSDONE
                        
EALSL_LSR_ASL_ASR_ROL_ROR
                        MOVE.W  SOURCE_MODE, D6
                        LSR     #2, D6
                        
                        CMP.B   #0, D6
                        BEQ     SHIFT_IMMEDIATE
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     PRINTDn_MODE
                        BRA     DISSDONE

SHIFT_IMMEDIATE
                        CLR.L   D5
                        MOVE.W  DESTINATION_REGISTER, D5
                        CMP.B   #0000, D5
                        BEQ     OVERFLOWSHIFT_COUNT
FIX_OVERFLOW_SHIFT      LEA     Hash_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        JSR     PRINT_IMMEDIATE_SIGN
                        JSR     PRINT_COMMA
                        
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE
                              
OVERFLOWSHIFT_COUNT
                        MOVE.W  #%1000, D5
                        BRA     FIX_OVERFLOW_SHIFT
                        
EASHIFT_ADDRESS
                        MOVE.W  SOURCE_MODE, D5
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE

EACMP
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        BRA     DISSDONE
                        
EAAND_OR
                        CMP.B   #1, DESTINATION_MODE
                        BEQ     EAAND_OR_FIRSTDn
                        
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        BRA     DISSDONE

EAAND_OR_FIRSTDn
                        MOVE.W  DESTINATION_REGISTER, D7
                        JSR     PRINTDn_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_MODE, SIZE_OF_Dn
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE

EAMOVEB
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        MOVE.W  #%0001, SIZE_OF_Dn
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        MOVE.W  DESTINATION_MODE, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE
                        
EAMOVEW
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        MOVE.W  #%0011, SIZE_OF_Dn
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        MOVE.W  DESTINATION_MODE, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE

EAMOVEAW
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        MOVE.W  #%0011, SIZE_OF_Dn
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        JSR     PRINTAn_MODE
                        BRA     DISSDONE

EAMOVEL
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        MOVE.W  #%0010, SIZE_OF_Dn
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        MOVE.W  DESTINATION_MODE, D7
                        JSR     EATABLE_MODE
                        BRA     DISSDONE

EAMOVEAL
                        MOVE.W  SOURCE_MODE, D6
                        MOVE.W  SOURCE_REGISTER, D7
                        MOVE.W  #%0010, SIZE_OF_Dn
                        JSR     EATABLE_MODE
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        JSR     PRINTAn_MODE                           
                        BRA     DISSDONE

EAMOVEQ                      
                        LEA     Hash_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        MOVE.L  HEX_RESULT, D2
                        CLR.L   D6
                        MOVE.B  D2, D5
                        
                        JSR     PRINT_IMMEDIATE_SIGN
                        JSR     PRINT_COMMA
                        
                        MOVE.W  DESTINATION_REGISTER, D6
                        JSR     PRINTDn_MODE
                        JSR     DISSDONE
                        
EABCC_BRA
                        CLR.L   D5
                        CLR.L   D6
                        CLR.L   D7
                        MOVE.W  HEX_RESULT, D7
                        LSL.W   #8, D7
                        LSR.W   #8, D7
                        CMP.B   #$00, D7
                        BEQ     FOR16BITSBRA
                        CMP.B   #$FF, D7
                        BEQ     FOR32BITSBRA
FORDISPLACE             CMP.B   #$0, D5
                        BEQ     NEGATIVE8_CHECK
                        CMP.B   #$1, D5
                        BEQ     NEGATIVE16_CHECK
                        CMP.B   #$2, D5
                        BEQ     NEGATIVE32_CHECK                       
DONEBCC_BRA             CMP.B   #1, D6
                        BNE     ADD_ONLY
                        
                        SUB.L   D7, CURR_ADDRESS
                        MOVE.L  CURR_ADDRESS, D7
                        BRA     PRINT_FORBCC_BRA
                        
ADD_ONLY                ADD.L   CURR_ADDRESS, D7     ; MOVE Branch address to D7

PRINT_FORBCC_BRA        LEA     Dollar_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        JSR     PRINT_TRAP
                        BRA     DISSDONE
                        
FOR16BITSBRA
                        MOVE.W  (A2)+, D7
                        MOVE.B  #1, D5                  ; Flag
                        BRA     FORDISPLACE
                              
FOR32BITSBRA                        
                        MOVE.W  (A2)+, D7
                        MOVE.B  #2, D5                  ; Flag
                        BRA     FORDISPLACE

NEGATIVE8_CHECK
                        CMP.B   #$80, D7
                        BLT     DONEBCC_BRA
                        MOVE.B  #1, D6
                        NOT.B   D7
                        ADD.B   #%1, D7
                        BRA     DONEBCC_BRA

NEGATIVE16_CHECK
                        CMP.W   #$8000, D7
                        BLT     DONEBCC_BRA
                        MOVE.B  #1, D6
                        NOT.B   D7
                        ADD.B   #%1, D7
                        BRA     DONEBCC_BRA
                        
NEGATIVE32_CHECK
                        CMP.L   #$80000000, D7
                        BLT     DONEBCC_BRA
                        MOVE.B  #1, D6
                        NOT.B   D7
                        ADD.B   #%1, D7
                        BRA     DONEBCC_BRA

*---------------------------EA Table----------------------------
EATABLE_MODE
                        CMP.B   #%0000, D6                  ; Data Register Direct
                        BEQ     PRINTDn_MODE
                        
                        CMP.B   #%0001, D6                  ; Address Register Direct
                        BEQ     PRINTAn_MODE
                        
                        CMP.B   #%0010, D6                  ; Address Register Indirect
                        BEQ     PRINTAn_MODE_INDIRECT
                        
                        CMP.B   #%0011, D6                  ; Address Register Indirect With Post Increment
                        BEQ     PRINTPOST_INCREMENT
                        
                        CMP.B   #%0100, D6                  ; Address Register Indirect With Pre Decrement
                        BEQ     PRINTPRE_DECREMENT
                        
                        CMP.B   #%0100,D7                   ; Immediate
                        BEQ     PRINTIMMEDIATE
                        
                        CMP.B   #%0001,D7                   ; Absolute Long Data
                        BEQ     PRINTABS_LONG
                        
                        CMP.B   #%0000,D7                   ; Absolute Word Data
                        BEQ     PRINTABS_WORD
                        
                        CMP.B   #%0111, D6
                        BNE     INVALID_DATA

PRINTDn_MODE                                                ; Dn
                        LEA     D_Mode, A1                   
                        MOVE.B  #14, D0
                        TRAP    #15            
                        
                        MOVE.L  D7, D6
                        MOVE.L  #3, D0
                        TRAP    #15
                        
                        RTS
                        
PRINTAn_MODE                                                ; An
                        LEA     A_Mode, A1                   
                        MOVE.B  #14, D0
                        TRAP    #15            
                        
                        MOVE.L  D7, D6
                        MOVE.L  #3, D0
                        TRAP    #15
                        
                        RTS
                        
PRINTAn_MODE_INDIRECT                                       ; (An)
                        LEA     Open_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        LEA     A_Mode, A1                   
                        MOVE.B  #14, D0
                        TRAP    #15 
                        
                        MOVE.L  D7, D6
                        MOVE.L  #3, D0
                        TRAP    #15
                        
                        LEA     Close_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        RTS
                        
PRINTPOST_INCREMENT                                         ; (An)+
                        LEA     Open_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        LEA     A_Mode, A1                   
                        MOVE.B  #14, D0
                        TRAP    #15 
                        
                        MOVE.L  D7, D6
                        MOVE.L  #3, D0
                        TRAP    #15
                        
                        LEA     Close_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        LEA     Plus_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        RTS

PRINTPRE_DECREMENT                                          ; -(An)
                        LEA     Minus_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        LEA     Open_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        LEA     A_Mode, A1                   
                        MOVE.B  #14, D0
                        TRAP    #15 
                        
                        MOVE.L  D7, D6
                        MOVE.L  #3, D0
                        TRAP    #15

                        LEA     Close_pars, A1
                        MOVE.B  #14, D0
                        TRAP    #15

                        RTS
PRINTIMMEDIATE                        
                        LEA     Hash_sign, A1                   
                        MOVE.B  #14 , D0
                        TRAP    #15
                        
                        CMP.W   #%0010, SIZE_OF_Dn
                        BEQ     IMMEDIATE_LONG
                        
                        CMP.W   #%0110, SIZE_OF_Dn
                        BGE     IMMEDIATE_LONG              ; Immediate Long Size
                        BRA     IMMEDIATE_WORD              ; Immediate Word Size
                        
IMMEDIATE_LONG                        
                        CLR.L   D1
                        MOVE.L  (A2)+,D1                    
                        JSR     PRINT_IMMEDIATE_SIGN   
                        RTS 
IMMEDIATE_WORD                        
                        CLR.L   D1
                        MOVE.L  (A2)+,D1                    
                        JSR     PRINT_IMMEDIATE_SIGN   
                        RTS
                        
PRINT_IMMEDIATE_SIGN                                        ; $#
                        LEA     Dollar_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
              
                        JSR     PRINT_TRAP
                        RTS     

PRINTABS_LONG
                        LEA     Dollar_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        CLR.L   D5
                        MOVE.W  (A2)+, D5
                        JSR     PRINT_TRAP
                        CLR.L   D5
                        RTS
PRINTABS_WORD                        
                        LEA     Dollar_sign, A1
                        MOVE.B  #14, D0
                        TRAP    #15
                        
                        CLR.L   D5
                        MOVE.W  (A2)+, D5
                        JSR     PRINT_TRAP
                        CLR.L   D5
                        RTS
                        
PRINT_TRAP
                        MOVEQ   #15, D0
                        MOVEQ   #16, D4                     ; Display Data in Hex in D4
                        TRAP    #15
                        RTS

INVALID_DATA            BRA     PRINTINVALID_EA
                        RTS
                        
PRINTINVALID_EA
                        LEA     Invalid_EA, A1                  
                        MOVE.B  #14, D0
                        TRAP    #15                           
                        RTS      


            
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
                        
                        CMP.B   #1, D1
                        BEQ     PRINTINPUTMSG       ;user entered 1, restart the system
                        
                        CMP.B   #0, D1
                        BEQ     CLOSINGMESSAGES
                        
                        LEA     NOTBINARY, A1           ;user inputed wrong code
                        MOVE.B  #14, D0
                        TRAP    #15
                        BRA     DISSDONE                
                        
CLOSINGMESSAGES         LEA     EXITITING, A1       ;user entered , end program
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
PRINT_COMMA             
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

WELCOME                 DC.B    'WELCOME to the 68k dissasembler!',CR,LF
                        DC.B    'You will prompted to enter a starting and ending location for the program',CR,LF 
                        DC.B    'code you would like dissasembled.',CR,LF
                        DC.B    'Please enter these values in hexadecimal!',CR,LF
                        DC.B    'Ending location should be greater than starting location.',CR,LF
                        DC.B    'Neither should be longer in length than 6 characters. You do not need to add $',CR,LF
                        DC.B    'EXAMPLE: 6006',CR,LF,0
                
STARTLOCMSG             DC.B    CR,LF,'Address of starting location: $',0 

ENDLOCMSG               DC.B    'Address of ending location: $',0

NOTES                   DC.B    CR,LF,'LOADING...',CR,LF
                        DC.B    'PS. Only one pages worth will display at a time.',CR,LF
                        DC.B    'Press ENTER to load another pages worth.',CR,LF
                        DC.B    'And anything that cannot be decoded will be displayed as "100 DATA $WXYZ"',CR,LF,CR,LF,0              
*----------------MESSAGES----------------------
INVADRMSG               DC.B    'The address entered are invalid.',CR,LF
                        DC.B    'Please try again!',CR,LF,0
                        
INVAILDENDLOCMSG        DC.B    'Ending location should be greater than starting location!',CR,LF
                        DC.B    'Please try again!',CR,LF,0                        
                        
EMPTYMSG                DC.B    'Input cannot be empty!',CR,LF        ; New 
                        DC.B    'Please try again!',CR,LF,0             ; New
                        
RESTARTQUESTION         DC.B    CR,LF,CR,LF,'Would you like to disassemble another program?',CR,LF
                        DC.B    'If yes, please enter 1.',CR,LF
                        DC.B    'If no, please enter 0.',CR,LF,0
                        
EXITITING               DC.B    'Thank you for using our disassembler! Goodbye...',CR,LF,0

NOTBINARY               DC.B    'Invalid input!',0


*----------------68K_CODE_STRING----------------------(NEW)
LEFT_STRING             DC.B    'L',0
RIGHT_STRING            DC.B    'R',0

BYTE_STRING             DC.B    '.B',0
WORD_STRING             DC.B    '.W',0
LONG_STRING             DC.B    '.L',0

INVALID_OPCODE_STRING   DC.B    'DATA $WYYZ',0
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

STRING_NUM0	            DC.B    '0',0
STRING_NUM1	            DC.B    '1',0
STRING_NUM2	            DC.B    '2',0
STRING_NUM3	            DC.B    '3',0
STRING_NUM4	            DC.B    '4',0
STRING_NUM5	            DC.B    '5',0
STRING_NUM6	            DC.B    '6',0
STRING_NUM7	            DC.B    '7',0
STRING_NUM8	            DC.B    '8',0
STRING_NUM9	            DC.B    '9',0
STRING_NUMA	            DC.B    'A',0
STRING_NUMB	            DC.B    'B',0
STRING_NUMC	            DC.B    'C',0
STRING_NUMD	            DC.B    'D',0
STRING_NUME	            DC.B    'E',0
STRING_NUMF	            DC.B    'F',0


*-----------------VARIABLES----------------
STARTLOC                DS.L    1    ; Longword of storage space for the address of the starting location for disassembly
ENDLOC                  DS.L    1    ; Longword of storage space for the address of the ending location for disassembly

DESTINATION_REGISTER    DS.L    1    ; Longword of storage space for the Destination Register
DESTINATION_MODE        DS.L    1    ; Longword of storage space for the Destination Mode
SOURCE_MODE             DS.L    1    ; Longword of storage space for the Source Mode
SOURCE_REGISTER         DS.L    1    ; Longword of storage space for the Source Register
SIZE_OF_Dn

CURR_ADDRESS            DS.L    1    ; Longword of storage space for the CURRENT_ADDRESS

*-----------------INPUT_STRING_TO_HEX_VARIABLES----------------
INPUT_HEXSTR            DS.W    3    ; longword of storage space for the input string to be converted
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





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
