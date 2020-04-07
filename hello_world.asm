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

ROM_TABLE = $05
  ; start of the ROM indexing table
  ; we will place various pointers to
  ; ROM data there 
  ; so we can use the indexing applications

STR_LOC = $ff01

  .org $ff01
  .string "HELLO WORLD"
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
  
  lda #<STR_LOC
  sta ROM_TABLE
    ; store the low bytes of STR_LOC in the ROM table
    ; at index 0 (IE 0)
  lda #>STR_LOC
  sta ROM_TABLE+1
    ; store the high bytes of STR_LOC in the ROM table
    ; at index 1 (IE $06)
  
  ldx #0
    ; clear the rom table index to 0
    ; indicating we would like to 
    ; print a string located in the table at index 0 and index 1
  jsr lcd_printstr
  
loop:
  wai
    ; use the WDC65C02 wai instruction
    ; which will halt the CPU and wait for an interrupt

; puts a null terminated string onto the LCD display
; at the current cursor location
; Blocks until the LCD driver has completed the 
; CGRAM write operation
; WARNING: max string length is limited to 254 chars
; as this is an 8 bit operation
; parameters: 
; X register contains ROM table index of pointer low byte
; which will be follwed by high byte of the string pointer
; in ROM
; returns: N/A
lcd_printstr:
  lda (ROM_TABLE,X)
    ; load the char at the value of the x register + the ROM table
  beq lcd_prinstr_done
    ; if its a null value, quit. 
  
  jsr lcd_putchar
    ; print the char to the LCD screen
  
  
lcd_printstr_done:
  ; TODO any other things?
  rts

; puts a single char onto the LCD display
; at the current cursor location.
; Blocks until the LCD driver has completed the 
; CGRAM write operation
; parameters:
; accumulator: contains valid ASCII char
; returns: N/A
lcd_putchar:
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
    ; wait until the LCD is ready for a new instruction or DRAM write
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
    ; wait until the LCD is ready for a new instruction or DRAM write
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
