; 2020 Aaron Walsh
; Uses the timer T1
; of the WDC65C22 unit
; as a constant source of interrupts
; at an even amount of time
; the clk is 1Mhz so each count of T1 is 
; exactly 1us

; memory map:
; $0000 - $3FFF - 16kb SRAM location
; $6000 - $7FFF - WDC65C22 address location
; $8000 - $FFFF - AT28C256 ROM location
; $FFFC - $FFFD - initialization vector

; setup WDC65C22 memory mapping
PORTA = $6001
PORTB = $6000
  ; GPIO PORTA and PORTB
DDRB  = $6002
DDRA  = $6003
  ; data direction registers
IER   = $600E
  ; Interrupt Enable Register 
AUX   = $600B
  ; Aux control register
  ; bits 6-7 indicate T1 mode
T1L   = $6004
T1H   = $6005
  ; T1 counter register
  ; upon filling of T1H
  ; the 
IRQB = $fffe

  ; begin code
  .org $8000

reset:
  ldx #$FF
  txs
    ; reset the stack to FF 
    
  lda #%11111111
  sta DDRB
    ; set all pins of PORTB to output
  lda #%00000001
  sta DDRA
    ; set the top pin on PORTA to output

  lda #%00000001
  sta $0F
    ; store the LED bits 
    ; in OF. LED starts on
  
  lda #%11000000
  sta IER
    ; set the 6th bit of the IER
    ; to enable the T1 interrupt
    ; functionality
  
  lda #%01000000
  sta AUX
    ; set AUX register
    ; 6-7 T1 to free run, no PB7 toggle
    ; 5   T2 timed interrupt mode
    ; 4-2 shift register disabled
    ; 0-1 PB/PA input latching disabled
  
  lda #$FF
  sta T1L
  sta T1H
    ; set the maximum timeout for T1H/L
    ; this is 65535 us or 65.35ms
    ; countdown begins at T1H latch

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
  bit T1L
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
  
  .org $fffe
  .word isr
    ; IRQB vector
  .org $fffc
  .word reset
    ;reset vector