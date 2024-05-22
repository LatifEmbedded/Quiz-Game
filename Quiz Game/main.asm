;---------------------------------------------------------------------------------------------------
;CREATOR : DALI FETHI ABDELLATIF
;DATE : 22/05/2024
;PLATFORM : MICROCHIP PIC18F452
;SIMULATION : PROTEUS ISIS
;
;EXPLICATION :
;THIS IS A SIMPLE QUIZ GAME DISPLAYED ON THE LCD WHERE THE QUESTIONS AND DISPLAYED WITH 4 DIFFERENT ANSWERS ONE IS THE CORRECT
;THE USER MUST ENTER THE NUMBER OF THE ANSWER BETWEEN THE 4 ANSWERS AND IF THE RESULT IS CORRECT IT DISPLAYS CORRECT ELSE IT DISPLAYS FALSE AND IT CONTINUES TO NEXT
;QUESTION AND SO ON....
;FINALLY IT GIVES THE NUMBER OF QUESTIONS WITH THE TOTAL ANSWERS AND THE SCORE THAT YOU TAKE IT

;---------------------------------------------------------------------------------------------------
				CONFIG		WDT = OFF
				#INCLUDE	<p18F452.inc>
				LIST		P = 18F452
;---------------------------------------------------------------------------------------------------
#DEFINE 			RS			PORTC,RC0
#DEFINE 			RW			PORTC,RC1
#DEFINE 			EN			PORTC,RC2
;---------------------------------------------------------------------------------------------------
CBLOCK	0x00
STATE				; VARIABLE USED TO SWITCH BETWEEN COLUMNS
VALUE			
COUNTER
CHECK_START			; VARIABLE USED TO CHECK IF THE USER PRESSES THE START SWITCH OR NOT
RESULT			
SCORE				; THE SCORE 
NUMBER_OF_PLAY		; TOTAL OF QUESTIONS
USER_ENTER			; THE RESULT ENTERED BY USER IS STORED IN THAT VARIABLE
START_OK			
COUNTER_TRUE		; VARIABLE FOR COUNTING THE NUMBER OF THE CORRECT ANSWERS
ENDC
;---------------------------------------------------------------------------------------------------
					ORG			0x00500
ANSWER				DB			"CORRECT ANSWERS : \0"
;---------------------------------------------------------------------------------------------------
					ORG			0x00600
QUESTION			DB			"QUESTIONS : \0"
;---------------------------------------------------------------------------------------------------
					ORG			0x01000
QUIZ_GAME			DB			"QUIZ GAME!\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01010
PRESS_START			DB			"PRESS START!\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01020
FIRST_QUES			DB			"CAPITALE OF FRANCE?\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01050
ANSWER_1			DB			"1.MOSCOW; 2.NEW YORK\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01080
ANSWER_2			DB			"3.NEW DELHI; 4.PARIS\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x010A0
DECISION			DB			"ENTER CHOICE:\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x010B0
TRUE_DECISION		DB			"CORRECT\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x010C0
FALSE_DECISION		DB			"FALSE\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01100
SECOND_QUES			DB			"CAPITALE OF GERMANY?\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01150
ANSWER_2_1			DB			"1.CAIRO; 2.MOSCOW\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01180
ANSWER_2_2			DB			"3.TOKYO; 4.BERLIN\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01200
YOUR_SCORE			DB			"SCORE IS \0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x01250
THANKS				DB			"THANK YOU!\0"	
;---------------------------------------------------------------------------------------------------
					ORG			0x00
					BRA			MAIN				; BRANCH TO MAIN FUNCTION 
					ORG			0x08
					BRA			INTERRUPT			; BRACH TO INTERRUPT VECTOR TABLE WHEN AN INTERRUPT OCCURS
;---------------------------------------------------------------------------------------------------
MAIN
					; MAKE THEM OUTPUT
					CLRF		TRISD
					CLRF		TRISC
					; MAKE IT INPUT
					SETF		TRISB
					; CHANGE PORTA TO DIGITAL PORT
					MOVLW		0x07
					MOVWF		ADCON1
					CLRF		TRISA
					CLRF		VALUE
					CLRF		COUNTER
					CLRF		STATE
					CLRF		RESULT
					CLRF		CHECK_START
					CLRF		NUMBER_OF_PLAY
					CLRF		SCORE
					CLRF		USER_ENTER
					CLRF		START_OK
					CLRF		COUNTER_TRUE
					RCALL		INITIALIZATION			; INITIALIZE THE LCD
					RCALL		DISPLAY_INFO
					BSF			INTCON,GIE				; ACTIVATING THE GLOBAL INTERRUPT
					BSF			INTCON,PEIE				; ACTIVATING PERIPHERAL INTERRUPT ENABLE BIT
					BSF			INTCON,RBIE				; ACTIVATING PORTB CHANGE INTERRUPT 
					BCF			INTCON,RBIF
					BSF			PIE1,TMR1IE				; ACTIVATING TIMER1 INTERRUPT
					BCF			PIR1,TMR1IF
					MOVLW		0xE4					; CONFIGURING THE TIMER1
					MOVWF		T1CON
					MOVLW		0x3C
					MOVWF		TMR1H
					MOVLW		0xB0
					MOVWF		TMR1L
					BSF			T1CON,TMR1ON
					MOVLW		0x01	
					MOVWF		STATE
					MOVLW		0x03
					MOVWF		LATA	
;---------------------------------------------------------------------------------------------------
WAIT
					BRA			WAIT			
;---------------------------------------------------------------------------------------------------
INTERRUPT										
					BTFSC		PIR1,TMR1IF	
					BRA			TIMER1		
					BTFSC		INTCON,RBIF	
					BRA			TEST		
;---------------------------------------------------------------------------------------------------
TEST											
					RCALL		DELAY_50_US	
					MOVF		PORTB,W		
					BTFSS		LATA,RA0		
					BRA			COLUMN_1		
					BTFSS		LATA,RA1
					BRA			COLUMN_2
					BTFSS		LATA,RA2
					BRA			COLUMN_3	
COLUMN_1
					BTFSS		PORTB,RB4
					BRA			DIGIT_1		
					BTFSS		PORTB,RB5
					BRA			DIGIT_4
					BRA			FINALE
COLUMN_2
					BTFSS		PORTB,RB4
					BRA			DIGIT_2
					BTFSS		PORTB,RB5
					BRA			VALIDATE
					BRA			FINALE
COLUMN_3
					BTFSS		PORTB,RB4
					BRA			DIGIT_3
					BTFSS		PORTB,RB5
					BRA			START
					BRA			FINALE
;---------------------------------------------------------------------------------------------------
DIGIT_1	
					BTFSS		CHECK_START,0
					BRA			FINALE
					MOVLW		A'1'
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					BRA			FINALE_1
;---------------------------------------------------------------------------------------------------
DIGIT_2
					BTFSS		CHECK_START,0
					BRA			FINALE
					MOVLW		A'2'
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					BRA			FINALE_1
;---------------------------------------------------------------------------------------------------
DIGIT_3
					BTFSS		CHECK_START,0	
					BRA			FINALE
					MOVLW		A'3'
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					BRA			FINALE_1
;---------------------------------------------------------------------------------------------------
DIGIT_4
					BTFSS		CHECK_START,0	
					BRA			FINALE
					MOVLW		A'4'
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					BRA			FINALE_1
;---------------------------------------------------------------------------------------------------
VALIDATE		
					INCF		NUMBER_OF_PLAY,F		
					MOVF		USER_ENTER,W
					XORLW		A'4'
					BZ			TRUE
					RCALL		CLEAR_FORTH_LINE	
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0xC0			
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM	
					CLRF		USER_ENTER
					RCALL		DELAY_250_MS
					RCALL		DELAY_250_MS
					RCALL		CHECK_NUMBER
					BRA			FINALE	
TRUE
					INCF		COUNTER_TRUE,F
					RCALL		CLEAR_FORTH_LINE	
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0xB0			
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					MOVLW		D'1'
					ADDWF		SCORE,F
					CLRF		USER_ENTER
					RCALL		DELAY_250_MS
					RCALL		DELAY_250_MS
					RCALL		CHECK_NUMBER
					BRA			FINALE														
;---------------------------------------------------------------------------------------------------
CHECK_NUMBER
					MOVF		NUMBER_OF_PLAY,W
					XORLW		0x02
					BZ			DISPLAY_SCORE
					RCALL		CLEAR_FIRST_LINE
					RCALL		CLEAR_SECOND_LINE
					RCALL		CLEAR_THIRD_LINE
					RCALL		CLEAR_FORTH_LINE
					RCALL		FIRST_LINE
					MOVLW		0x11
					MOVWF		TBLPTRH
					MOVLW		0x00
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		SECOND_LINE
					MOVLW		0x11
					MOVWF		TBLPTRH
					MOVLW		0x50
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		THIRD_LINE
					MOVLW		0x11
					MOVWF		TBLPTRH
					MOVLW		0x80
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		FORTH_LINE
					MOVLW		0x10
					MOVWF		TBLPTRH
					MOVLW		0xA0
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RETURN
;---------------------------------------------------------------------------------------------------
DISPLAY_SCORE
					RCALL		CLEAR_FIRST_LINE
					RCALL		CLEAR_SECOND_LINE
					RCALL		CLEAR_THIRD_LINE
					RCALL		CLEAR_FORTH_LINE
					RCALL		FIRST_LINE		
					CLRF		COUNTER
JUMP
					RCALL		SHIFT_FORWARD
					INCF		COUNTER,F
					MOVF		COUNTER,W
					XORLW		0x05
					BNZ			JUMP
					MOVLW		0x06
					MOVWF		TBLPTRH		
					MOVLW		0x00
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM	
					MOVF		NUMBER_OF_PLAY,W
					ADDLW		0x30
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					CLRF		COUNTER
					RCALL		SECOND_LINE	
JUMP_HE
					RCALL		SHIFT_FORWARD
					INCF		COUNTER,F
					MOVF		COUNTER,W
					XORLW		0x01
					BNZ			JUMP_HE
					CLRF		COUNTER						
					MOVLW		0x05
					MOVWF		TBLPTRH		
					MOVLW		0x00
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					MOVF		COUNTER_TRUE,W
					ADDLW		0x30
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					CLRF		COUNTER
					RCALL		THIRD_LINE
JUMP_HER
					RCALL		SHIFT_FORWARD
					INCF		COUNTER,F
					MOVF		COUNTER,W
					XORLW		0x05
					BNZ			JUMP_HER
					CLRF		COUNTER
					MOVLW		0x12
					MOVWF		TBLPTRH		
					MOVLW		0x00
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					MOVF		SCORE,W
					ADDLW		0x30
					MOVWF		PORTD
					RCALL		DATTA
					RCALL		BUSYFLAG
					RCALL		FORTH_LINE
JUMP_HERE
					RCALL		SHIFT_FORWARD
					INCF		COUNTER,F
					MOVF		COUNTER,W
					XORLW		0x05
					BNZ			JUMP_HERE
					CLRF		COUNTER
					MOVLW		0x12
					MOVWF		TBLPTRH		
					MOVLW		0x50
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM				
					RETURN						
;---------------------------------------------------------------------------------------------------
START
					BTFSC		START_OK,0					; THIS VARIABLE IS USED TO ALLOW USER TO ONLY START ONCE 
					BRA		FINALE
					BSF			START_OK,0				
					BSF			CHECK_START,0				; THIS VARIABLE IS FOR ENSURING THAT THE USER WILL INPUT THE CHOICE AFTER PRESS START
					RCALL		CLEAR_SECOND_LINE
					RCALL		CLEAR_FIRST_LINE
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0x20			
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		SECOND_LINE
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0x50			
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		THIRD_LINE
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0x80			
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					RCALL		FORTH_LINE
					MOVLW		0x10			
					MOVWF		TBLPTRH
					MOVLW		0xA0		
					MOVWF		TBLPTRL
					RCALL		INDEXED_ROM
					BRA		FINALE											
;---------------------------------------------------------------------------------------------------
INITIALIZATION									; SUBROUTINE RESPONSINLE ABOUT INITIALIZING THE LCD
					RCALL		DELAY_250_MS	; WAIT 250 MS
					MOVLW		0x38			; TELL THE LCD CONTROLLER I NEED 2 LINES + 5*7 DOT
					MOVWF		PORTD
					RCALL		COMMAND
					RCALL		DELAY_250_MS
					MOVLW		0x01			; CLEAR THE ENTIRE SCREEN
					MOVWF		PORTD
					RCALL		COMMAND
					RCALL		DELAY_250_MS
					MOVLW		0x0F			; DISPLAY ON + CURSOR BLINKING
					MOVWF		PORTD
					RCALL		COMMAND
					RCALL		DELAY_250_MS
					RETURN
;---------------------------------------------------------------------------------------------------
TIMER1											; SUBROUTINE RESPONSIBLE FOR ACTIVATING ONE COLUMN AT TIME(COLUMN IS ACTIVE LOW)
					BCF			PIR1,TMR1IF		
					MOVLW		0x3C
					MOVWF		TMR1H
					MOVLW		0xB0
					MOVWF		TMR1L	
					MOVF		STATE,W
					XORLW		0x00
					BZ			FIRST
					MOVF		STATE,W
					XORLW		0x01
					BZ			SECOND
					CLRF		STATE
					MOVLW		0x06
					MOVWF		LATA
					RETFIE					
FIRST
					MOVLW		0x01
					MOVWF		STATE
					MOVLW		0x03
					MOVWF		LATA
					RETFIE
SECOND
					MOVLW		0x02
					MOVWF		STATE
					MOVLW		0x05
					MOVWF		LATA
					RETFIE					
;---------------------------------------------------------------------------------------------------
TIMER_CALCULATING									; DELAY ROUTINE WITH THE POLLING METHOD
					BCF				INTCON,TMR0IF
					BSF				T0CON,TMR0ON
TESTX
					BTFSS			INTCON,TMR0IF	
					BRA				TESTX
					BCF				INTCON,TMR0IF
					BCF				T0CON,TMR0ON
					RETURN
;---------------------------------------------------------------------------------------------------
DELAY_250_MS
					MOVLW			0x01
					MOVWF			T0CON
					MOVLW			0x0B
					MOVWF			TMR0H
					MOVLW			0xDC
					MOVWF			TMR0L
					BRA				TIMER_CALCULATING			
;---------------------------------------------------------------------------------------------------
DELAY_3000_NS
					MOVLW			0x48
					MOVWF			T0CON
					MOVLW			0xFD
					MOVWF			TMR0L
					BRA				TIMER_CALCULATING
;---------------------------------------------------------------------------------------------------
DELAY_50_US
					MOVLW			0x48
					MOVWF			T0CON
					MOVLW			D'206'
					MOVWF			TMR0L
					BRA				TIMER_CALCULATING
;---------------------------------------------------------------------------------------------------
COMMAND												; SUBROUTINE FOR COMMANDS 
					BCF				RS
					BCF				RW
					BSF				EN
					RCALL			DELAY_3000_NS
					BCF				EN
					RETURN
;---------------------------------------------------------------------------------------------------
DATTA													; SUBROUTINE FOR DATA
					BSF				RS
					BCF				RW
					BSF				EN
					RCALL			DELAY_3000_NS
					BCF				EN
					RETURN
;---------------------------------------------------------------------------------------------------
BUSYFLAG												; CHECK BUSY FLAG 
					BSF				TRISD,RD7	
					BCF				RS
					BSF				RW
WAITA
					BCF				EN
					RCALL			DELAY_3000_NS
					BSF				EN
					BTFSC			PORTD,RD7
					BRA				WAITA
					BCF				EN
					BCF				TRISD,RD7
					RETURN
;---------------------------------------------------------------------------------------------------
FINALE_1
					MOVF			LATD,W	
					MOVWF			USER_ENTER										
FINALE
					BCF				INTCON,RBIF
					RETFIE		
;---------------------------------------------------------------------------------------------------
SECOND_LINE									; JUMP TO SECOND LINE
					MOVLW			0xC0		
					MOVWF			PORTD
					RCALL			COMMAND
					RCALL			BUSYFLAG	
					RETURN		
;---------------------------------------------------------------------------------------------------	
FIRST_LINE									; JUMP TO SECOND LINE
					MOVLW			0x80	
					MOVWF			PORTD
					RCALL			COMMAND
					RCALL			BUSYFLAG	
					RETURN		
;---------------------------------------------------------------------------------------------------	
CLEAR_FIRST_LINE							; CLEAR FIRST LINE
					CLRF			VALUE	
					RCALL			FIRST_LINE	
BACKA
					MOVLW			A' '
					MOVWF			PORTD
					RCALL			DATTA
					RCALL			BUSYFLAG	
					INCF			VALUE,F
					MOVF			VALUE,W	
					XORLW			D'20'
					BTFSS			STATUS,Z
					BRA				BACKA
					RCALL			FIRST_LINE
					CLRF			VALUE					
					RETURN
;---------------------------------------------------------------------------------------------------
CLEAR_SECOND_LINE							
					CLRF			VALUE	
					RCALL			SECOND_LINE
BACK	
					MOVLW			A' '
					MOVWF			PORTD
					RCALL			DATTA
					RCALL			BUSYFLAG	
					INCF			VALUE,F
					MOVF			VALUE,W	
					XORLW			D'20'
					BTFSS			STATUS,Z
					BRA				BACK
					RCALL			SECOND_LINE
					CLRF			VALUE					
					RETURN
;---------------------------------------------------------------------------------------------------
CLEAR_THIRD_LINE						
					CLRF			VALUE	
					RCALL			THIRD_LINE
BA	
					MOVLW			A' '
					MOVWF			PORTD
					RCALL			DATTA
					RCALL			BUSYFLAG	
					INCF			VALUE,F
					MOVF			VALUE,W	
					XORLW			D'20'
					BTFSS			STATUS,Z
					BRA				BA
					RCALL			THIRD_LINE
					CLRF			VALUE					
					RETURN
;---------------------------------------------------------------------------------------------------
CLEAR_FORTH_LINE						
					CLRF			VALUE	
					RCALL			FORTH_LINE
BAR	
					MOVLW			A' '
					MOVWF			PORTD
					RCALL			DATTA
					RCALL			BUSYFLAG	
					INCF			VALUE,F
					MOVF			VALUE,W	
					XORLW			D'20'
					BTFSS			STATUS,Z
					BRA				BAR
					RCALL			FORTH_LINE
					CLRF			VALUE					
					RETURN
;---------------------------------------------------------------------------------------------------
DISPLAY_INFO
					MOVLW			0x10
					MOVWF			TBLPTRH
					MOVLW			0x00
					MOVWF			TBLPTRL
HERE_FOR
					RCALL			SHIFT_FORWARD
					INCF			COUNTER,F
					MOVF			COUNTER,W
					XORLW			0x05	
					BNZ				HERE_FOR
					CLRF			COUNTER
					RCALL			INDEXED_ROM
					RCALL			WAITING_FOR_USER_PRESS
					RETURN
;---------------------------------------------------------------------------------------------------
INDEXED_ROM
					TBLRD*+
					MOVF			TABLAT,W
					XORLW			'\0'
					BTFSC			STATUS,Z
					RETURN
					MOVF			TABLAT,W		
					MOVWF			PORTD
					RCALL			DATTA
					RCALL			BUSYFLAG
					BRA			INDEXED_ROM				
;---------------------------------------------------------------------------------------------------
SHIFT_FORWARD
					MOVLW			0x14
					MOVWF			PORTD
					RCALL			COMMAND
					RCALL			BUSYFLAG
					RETURN
;---------------------------------------------------------------------------------------------------
WAITING_FOR_USER_PRESS
					RCALL			SECOND_LINE
					MOVLW			0x10
					MOVWF			TBLPTRH
					MOVLW			0x10
					MOVWF			TBLPTRL
HERE_FORR
					RCALL			SHIFT_FORWARD
					INCF			COUNTER,F
					MOVF			COUNTER,W
					XORLW			0x04	
					BNZ				HERE_FORR
					CLRF			COUNTER
					RCALL			INDEXED_ROM
					RETURN
;---------------------------------------------------------------------------------------------------
THIRD_LINE
					MOVLW			0x94
					MOVWF			PORTD
					RCALL			COMMAND
					RCALL			BUSYFLAG
					RETURN
;---------------------------------------------------------------------------------------------------
FORTH_LINE
					MOVLW			0xD4
					MOVWF			PORTD
					RCALL			COMMAND
					RCALL			BUSYFLAG
					RETURN
;---------------------------------------------------------------------------------------------------
					END