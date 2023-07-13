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
PRINTINPUTMSG   LEA     WELCOME, A1
                MOVE.B  #14, D0
                TRAP    #15
                LEA     STARTLOCMSG, A1
                TRAP    #15               
                MOVE.B  #2, D0
INPUTSTART      LEA     STARTLOC, A1
                TRAP    #15               
                LEA     ENDLOCMSG, A1
                MOVE.B  #14, D0
                TRAP    #15
                MOVE.B  #2, D0
INPUTEND        LEA     ENDLOC, A1
                TRAP    #15
FINALMSGS       MOVE.B  #14, D0
                LEA     NOTES, A1
                TRAP    #15
                             
*-------------------------------

; a whole bunch of stufff

*------------output--------------



*--------------------------------
    

*------------WELCOME MESSAGES--------------
CR              EQU     $0D
LF              EQU     $0A

WELCOME         DC.B    'WELCOME to the 68k dissasembler!',CR,LF,0
                DC.B    'You will prompted to enter a starting and ending location for theprogram code you would like dissasembled.',CR,LF,0
                DC.B    'Please enter these values in hexadecimal!',CR, LF,0
                DC.B    'Ending location should be greater than starting location, and neither should be longer in length than 6 characters. You do not need to add $ or 0x',CR,LF,0
                DC.B    'EXAMPLE: 6006',CR,LF,0
                
STARTLOCMSG     DC.B    'Address of starting location: $',0 

ENDLOCMSG       DC.B    CR,LF,'Address of ending location: $',0

NOTES           DC.B    CR,LF,'LOADING...',CR,LF,0
                DC.B    'PS. Only one pages worth will display at a time, press ENTER to load another page.',CR,LF,0
                DC.B    'And anything that cannot be decoded will be displayed as "100 DATA $WXYZ"', CR,LF,0              
*------------------------------------------
*-----------------VARIABLES----------------
STARTLOC        DS.L    1
ENDLOC          DS.L    1
*------------------------------------------

DONE
                END    START        ; last line of source


=======
* Written by : Yasmine Subbagh, Slava Arovina, Chin Cheung Lam, Humamah Zahrah
* Date       : 
*   Created:        06/27/23
*   Last Modified:  06/27/23
* Description: 68k Assembly Dissasembler
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
