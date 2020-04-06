; 2020 Aaron Walsh
; Alternating bits on PORTB of the 65C22

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

  .org $8000

reset:
  lda #$ff
  sta DDRB 
      ; set all PORTB to full output
  
  lda #$55
  sta PORTB
      ; set alternating bits on PORTB  

loop:
  jsr sub_odd
  jsr sub_even
  jmp loop


sub_odd:
  lda #$55
  sta PORTB
  nop
      ; set alternating bits on PORTB
  rts
  
sub_even:
  lda #$aa
  sta PORTB
  nop
      ; set alternating bits on PORTB
  rts
  
  
  .org $fffc
  .word reset
  .word $0000
      ; insert reset vector