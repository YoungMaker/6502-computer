; 2020 Aaron Walsh
; Writes HELLO WORLD 
; to the 16x2 LCD display 
; attached to PORTB and part of PORTA 
; on the 65C22

; memory map:
; $0000 - $3FFF - 16kb SRAM location
; $6000 - $7FFF - WDC65C22 address location
; $8000 - $FFFF - AT28C256 ROM location
; $FFFC - $FFFD - initialization vector

; setup WDC65C22 memory mapping
PORTA = $6001
PORTB = $6000
DDRB  = $6002
DDRA  = $6003


; LCD connnections
; D0 - D7: Data bus -> PORB0-PORTB7
RS = %00100000
; RS - Register select -> PORTA5
RW = %01000000
; RW - Read/Write -> PORTA6
E  = %10000000
; E  - Enable -> PORTA7

reset:
	lda #%11111111
	sta #DDRB
		; set all pins of PORTB to output
	lda #%11100000
	sta #DDRA
		; set the top 3 pins of PORTA to output


setup_lcd:
	; setup the LCD for character output
	lda #%00111000
	sta #PORTB
		; stores FUNCTION SET command (001)
		; DL = 1 for 8 bit mode
		; N = 1 for two line display
		; F = 0 for 5x8 character font mode
	
	lda #E
	sta #PORTA
	
	lda #$00
	sta #PORTA
		; strobe the Enable pin to latch the command
		
	lda #%00001100
	sta #PORTB
		; stores DISPLAY ON command (00001)
		; D = 1 for display on
		; C = 0 for cursor off
		; B = 0 for blink off
	
loop:
	; write HELLO WORLD to LCD
	    

lcd_instruction:
	sta PORTB
	; store instruction at PORTB
	lda #$00
	sta
	
  .org $fffc
  .word reset
  .word $0000
    ;reset vector
