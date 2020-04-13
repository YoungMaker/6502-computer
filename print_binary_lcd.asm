; 2020 Aaron Walsh
; Writes HELLO WORLD 
; to the 16x2 LCD display 
; attached to PORTB and part of PORTA 
; on the 65C22

STR_LOC  = $3000
; pointer to string 
; (MUST BE MUTIBLE and have at least 8 bytes)
; so it can't be in ROM dummy
STR2_LOC = $fe20

  .org STR2_LOC
  .string "lorem ipsum dol"
  ; begin code
  .org $8000
  .include "include/lcd_routines.asm"
  .include "include/str_routines.asm"
  
reset:
  jsr setup_lcd 
    ; setup LCD on PORTA and PORTB
    
  lda #%10101010
  sta $0F
    ; store alternating bits in $0F, our temporary input variable

  lda #$0F
  sta $F0
 
  lda #$00
  sta $F1
    ; store address of binary data ($0F) into $F0 and $F1
  
  lda #<STR_LOC
  sta $F2
  lda #>STR_LOC
  sta $F3
    
  ;jsr ebt_ascii
    ; convert binary into ASCII binary string at STR_LOC
  
  lda #<STR_LOC
  sta $F0
  lda #>STR_LOC
  sta $F1
    ; put the STR LOC into the pararmter locations $F0 and $F1
  jsr lcd_printstr
    ; print the output string onto the LCD screen
    
  lda #$40
  sta $F0
  jsr lcd_set_ddram
  
  lda #<STR2_LOC
  sta $F0
  lda #>STR2_LOC
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
    