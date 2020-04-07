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

  ; begin code
  .org $8000

reset:
  ldx #$FF
  txs
    ; reset the stack to FF 
    
	lda #%11111111
	sta DDRB
		; set all pins of PORTB to output
	lda #%11100000
	sta DDRA
		; set the top 3 pins of PORTA to output


setup_lcd:
	; setup the LCD for character output
	lda #%00000001
	jsr lcd_instruction
	; clear display and set DDRAM addres 0
	
	lda #%00111000
	jsr lcd_instruction
		; stores FUNCTION SET command (001)
		; DL = 1 for 8 bit mode
		; N = 1 for two line display
		; F = 0 for 5x8 character font mode
	
	lda #$00
	jsr lcd_instruction
		
	lda #%00001100
	jsr lcd_instruction
		; stores DISPLAY ON command (00001)
		; D = 1 for display on
		; C = 0 for cursor off
		; B = 0 for blink off
	
  lda #%00000110
  jsr lcd_instruction
    ; stores ENTRY MODE command (000001)
    ; I/D = 1 for increment left-to right
    ;   S = 0 for no scrolling
  
  ; messy way to print "HELLO WORLD
  ; TODO: use null terminated string in RAM somewhere
  ; develop function that will putchar until 0 is detected
  lda #"H"
  jsr lcd_putchar
  lda #"E"
  jsr lcd_putchar
  lda #"L"
  jsr lcd_putchar
  lda #"L"
  jsr lcd_putchar
  lda #"O"
  jsr lcd_putchar
  lda #" "
  jsr lcd_putchar
  lda #"W"
  jsr lcd_putchar
  lda #"O"
  jsr lcd_putchar
  lda #"R"
  jsr lcd_putchar
  lda #"L"
  jsr lcd_putchar
  lda #"D"
  jsr lcd_putchar
  lda #"!"
  jsr lcd_putchar
  
  
loop:
  nop 
  nop
  jsr loop
    ; infinite empty loop

 ; TODO: fix thse so that we can run at 1Mhz, wait for busy flag. 
lcd_putchar:
  ; accumulator used as parameter location
  sta PORTB
  lda #RS
	sta PORTA
    ; set RS to 1 to write to CGRAM
    ; set 
    
  lda #(RS | E)
  sta PORTA
  
  nop ; very simple delay tactic
  nop
  nop 
  nop
  
  lda #RS
	sta PORTA
    ; strobe enable pin and return RS to 1
    ; completes CGRAM write
  jsr wait_for_busy
  rts
  
lcd_instruction:
  sta PORTB
    ; store instruction from A at PORTB
    ; accumulator used as parameter location
	lda #0
	sta PORTA
    ; clear RS/RW/E pins
    
  lda #E
  sta PORTA
  
  nop ; very simple delay tactic
  nop
  nop 
  nop
  
  lda #0
	sta PORTA
    ; strobe enable pin 
  jsr wait_for_busy
  rts

; TODO in the future make this an interrupt based
; queue scheme such that when you write to the LCD
; you write to an internal command queue that is flushed
; when a busy-free interrupt is called  
wait_for_busy:
  lda #%01111111
	sta DDRB
		; set PORTA7 to input to read
    ; as we're gonna read the busy flag
   
  lda #RW
  sta PORTA
    ; store the RW = 1 bit, allowing us to read the busy flag

wait_for_loop:
  
  lda #(RW | E)
  sta PORTA
    ; set enable pin high and set RW = 1 
    
  nop ; very simple delay tactic  
  nop
  nop 
  nop
  
  lda PORTB
    ; read PORTB
  and #%10000000
    ; check to see if the 8th bit is set high
  beq lcd_free
    ; branch if it is not set high
  
  lda #RW
  sta PORTA
    ; set enable pin low
  jmp wait_for_loop
  
lcd_free:
  lda #0
  sta PORTA
    ; clear RW/E/RS bits
  
  lda #%11111111
	sta DDRB
		; reset all pins of PORTB to output
  rts
  
  .org $fffc
  .word reset
  .word $0000
    ;reset vector
