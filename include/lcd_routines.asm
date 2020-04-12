; 2020 Aaron Walsh
; functions for interacting 
; with the HD44780-based 16x2 LCD screen
; connected to PORTB and the top 3 pins of PORTA

; memory map:
; $0000 - $3FFF - 16kb SRAM location
; $6000 - $7FFF - WDC65C22 address location
; $8000 - $FFFF - AT28C256 ROM location
; $FFFC - $FFFD - initialization vector

  .include "include/via_routines.asm"
    ; include VIA symbols and routines

; LCD connnections
; D0 - D7: Data bus -> PORB0-PORTB7
RS = %00100000
; RS - Register select -> PORTA5
RW = %01000000
; RW - Read/Write -> PORTA6
E  = %10000000
; E  - Enable -> PORTA7

FIRST_LINE_S  = $00
; first line of the display starts at DDRAM address $00
FIRST_LINE_E  = $10
; and ends at DDRAM address $10 (inclusive)
SECOND_LINE_S = $40
; second line of the display starts at DDRAM address $40
SECOND_LINE_E = $50
; and ends at DDRAM address $50 (inclusive)


  ;.org $F100
    ; put this in the ROM at address F100, leaving 3,824 bytes before the reset vector

; Sets up and initialize the LCD connected to 
; PORTB and the top 3 pins of PORTA so it is ready for 
; outputting characters
; parameters: N/A
; NOTE: modifies DDR and blocks 4x the HD44780 wait time for the BF
; so this function is relatively expensive, at least 200us probably
; @1Mhz
setup_lcd:
  pha
  
  lda #%11111111
  sta DDRB
    ; set all pins of PORTB to output
  lda #%11100000
  sta DDRA
    ; set the top 3 pins of PORTA to output
  
; Setup the LCD for character output:
  lda #%00000001
  jsr lcd_instruction
    ; clear display and set DDRAM addres 0
  
  lda #%00111000
  jsr lcd_instruction
    ; stores FUNCTION SET command (001)
    ; DL = 1 for 8 bit mode
    ; N = 1 for two line display
    ; F = 0 for 5x8 character font mode
  
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
  pla
  rts

; Puts a null terminated string onto the LCD display
; at the current cursor location

; WARNING: max string length is limited to 254 chars
; as this is an 8 bit operation. Will cleanly exit if 
; wraparound is to occur
; parameters: 
; $F0 - $F1 string address (L, H)
; in ROM
; returns: $E0 contains length of string written
; NOTE:Blocks until the LCD driver has completed the 
; CGRAM write operation, about 50 us * length of the string
; average 800us for all 16 characters
lcd_printstr:
  pha
  phy
  ldy #0
    ; clear the index register
lcd_prinstr_loop:
  lda ($F0), y 
    ; load A register with value indexed by $F0 low byte and $F1 high byte
    ; then adds y to index the proper character in the string
  beq lcd_printstr_done
    ; quit if nullchar detected
  jsr lcd_putchar
  iny
  tya
  cmp #$FF
  beq lcd_printstr_done
    ; if we're expected to exceed a page worth
    ; quit to prevent wraparound
  jmp lcd_prinstr_loop
  
lcd_printstr_done:
  tya
    ; puts the length in the accumulator if requried for use
  sta $E0
    ; store the legnth in the return value $E0 location
  ply
  pla
  rts

; Puts a single char onto the LCD display
; at the current cursor location.
; Blocks until the LCD driver has completed the 
; DDRAM write operation
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

; Sets the DDRAM location which will move the cursor location
; to the location specified at that DDRAM address
; parameters: 
; $F0 - contains DDRAM address
; WARNING: only the bottom 6 bits of the specified DDRAM 
; address will be set, the top two bits will be ignored
; returns: N/A
lcd_set_ddram:
  lda $F0
  and #%01111111
    ; load the DDRAM addres from the parameter matrix index 0
    ; and the accumulator such that we ingore the top bit and set it to zero
  ora #%10000000
    ; or the bits such that the 8th bit is always set on 
  jsr lcd_instruction
    ; send the DDRAM instruction to the LCD
  rts

; Reads the DDRAM address, which can be used to 
; determine the current cusor location
; Parameters: N/A
; Returns: $E0 contains DDRAM address lower 7 bits 
lcd_read_ddram_addr:
  pha
  lda #%000000000
  sta DDRB
    ; set PORTB to input to read
    ; as we're gonna read the lower six bits
    ; which will be the DDRAM address
  
  lda #0
  sta PORTA 
    ; clear the RW, RS and E flags
    
  lda #(RW | E)
  sta PORTA
    ; store the RW = 1 bit and the enable, allowing us to read the busy flag
  
  nop ; very simple delay tactic
  nop 
  nop 
  nop
  
  lda PORTB
  and #%01111111
    ; read the DDRAM address and the BF, then and the accumulator 
    ; such that we ingore the BF and set it to zero. 
  sta $E0
    ; store the result at the evaluattion matrix, index 0
  
  lda #0
  sta PORTA
    ; clear enable pin 
    
  lda #%11111111
  sta DDRB
    ; reset the DDRB so that all pins of PORTB7
    ; are back to being outputs
  jsr wait_for_busy
  pla 
  rts


; Uploads an LCD instruction into the instruction
; RAM on the LCD driver module
; Blocks until the LCD driver has completed
; executing the instruction 
; parameters:
; accumulator: contains valid LCD commmand (8 bits)
; returns N/A
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
; when a busy-free interrupt is called ?

; Waits until the BF flag is cleared on the LCD
; this is a blocking function 
wait_for_busy:
  lda #%01111111
  sta DDRB
    ; set PORTB7 to input to read
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
