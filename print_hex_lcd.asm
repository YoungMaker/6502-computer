; 2020 Aaron Walsh
; Writes HELLO WORLD 
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
  jsr setup_lcd 
    ; setup LCD on PORTA and PORTB
  
  lda #<STR_LOC
  sta $F0
  lda #>STR_LOC
  sta $F1
    ; put the STR LOC into the pararmter locations $F0 and $F1
  lda #$F4  
    ; convert $F4 into "F4"
  jsr bthex_ascii
    ; convert binary into ASCII hex string at STR_LOC
  
  lda #<STR_LOC
  sta $F0
  lda #>STR_LOC
  sta $F1
    ; put the STR LOC into the pararmter locations $F0 and $F1
  jsr lcd_printstr
    ; print the output string onto the LCD screen
  
loop:
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
    