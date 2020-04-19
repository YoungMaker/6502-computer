; 2020 Aaron Walsh
; Writes hex values
; Used to verify that the hex lookup table
; required by str_routines is valid.
; to the 16x2 LCD display 
; attached to PORTB and part of PORTA 
; on the 65C22

TEMP_VAR = $000F
STR_LOC  = $2000
; pointer to string 
; (MUST BE MUTIBLE and have at least 8 bytes)
; so it can't be in ROM dummy
STR2_LOC = $fe20

  .org STR2_LOC
  .string "lorem ipsum dol"
  ; begin code
  .org $8000
  
reset:
  ldx #$FF
  txs 
    ; reset stack to maximum position
  jsr setup_lcd 
    ; setup LCD on PORTA and PORTB
  ldy #0
    ; clear loop counter
    
loop:
  lda HEX_TABLE, y
  jsr lcd_putchar
    ; load character and print to LCD screen 
  iny 
  tya 
  cmp $10
  beq endloop$
    ; increment loop counter and check for exit condition
endloop$
  wai
  
  .include "include/lcd_routines.asm"
  .include "include/str_routines.asm"
  .include "include/rom_data.asm"
  ;.org $fffe
  ;.word isr
    ; IRQB vector
  .org $fffc
  .word reset
    ;reset vector
    