
PORTA = $6001
PORTB = $6000
DDRB = $6002
DDRA = $6003

  .org $8000

reset:
  lda #$ff
  sta DDRB 
  ; set all PORTB to full output
  
  lda #$55
  sta PORTB
  ; set alternating bits on PORTB  

loop:
  lda #$aa
  sta PORTB
  ; set alternating bits on PORTB

  lda #$55
  sta PORTB
  ; set alternating bits on PORTB
  jmp loop

  ; insert reset vector
  .org $fffc
  .word reset
  .word $0000
