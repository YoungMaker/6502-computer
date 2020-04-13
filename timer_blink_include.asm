; 2020 Aaron Walsh
; Uses the timer T1
; of the WDC65C22 unit
; as a constant source of interrupts
; at an even amount of time
; the clk is 1Mhz so each count of T1 is 
; exactly 1us
; This version uses the in progress BIOS include files

; memory map:
; $0000 - $3FFF - 16kb SRAM location
; $6000 - $7FFF - WDC65C22 address location
; $8000 - $FFFF - AT28C256 ROM location
; $FFFC - $FFFD - initialization vector

  .org $8000
  .include "include/via_routines.asm"
  
reset:
  ldx #$FF
  txs
    ; reset the stack to FF 
  
  lda #%00000001
  sta DDRA
    ; set the top pin on PORTA to output

  lda #%00000001
  sta $0F
    ; store the LED bits 
    ; in OF. LED starts on
  sta PORTA
  
  lda #$01
  sta $F0 
    ; set argument T1 IER enable = true
  jsr set_t1_ier
  
  lda #$FF
  sta $F0
  sta $F1
    ; set the counter value to FFFF for T1
  
  jsr set_t1_free
  
  cli
    ; clear interrupt disable bit to enable IRQB response

loop:
  lda $0F
  sta PORTA
  wai
    ; set the PORTA PA7 to the $0F contents
    ; $OF contains the LED/Square wave value
    ; then wait until the ISR has completed
  jsr loop
  


; Interrupt service routine
; the Interrupt vector will jump to here
; when servicing an IRQB interrupt
isr:
  pha
  phx
  bit T1C_L
    ; read the low bits of the counter
    ; so that we clear the interrupt flag
  lda $0F
  eor #%0000001
    ; exclusive or, flip bit 0 stored in A
  sta $0F
    ; load and flip bit 7 at $0F, store
  plx
  pla 
  rti
  
  ;.org $fffe
  ;.word isr
  
  .org $fffc
  .word reset
    ;reset vector
  .word isr
    ; IRQB vector