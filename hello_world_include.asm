; 2020 Aaron Walsh
; Writes HELLO WORLD 
; to the 16x2 LCD display 
; attached to PORTB and part of PORTA 
; on the 65C22

STR_LOC = $ff00
; pointer to string
STR2_LOC= $ff20

  .org STR_LOC
  .string "HELLO WORLD!"
  .org STR2_LOC
  .string "lorem ipsum dol"
  ; begin code
  .org $8000
  .include "include/lcd_routines.asm"
  
reset:
  jsr setup_lcd 
    ; setup LCD on PORTA and PORTB
    
  lda #<STR_LOC
  sta $F0
  
  lda #>STR_LOC
  sta $F1
  
  jsr lcd_printstr

loop:
  wai
  

  ;.org $fffe
  ;.word isr
    ; IRQB vector
  .org $fffc
  .word reset
    ;reset vector
    