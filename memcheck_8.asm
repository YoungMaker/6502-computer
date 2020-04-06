; 2020 Aaron Walsh
; Performs a write loop onto RAM in the 6502
; only does an 8 bit section, didn't want to mess with
; trying to do 16 bit operations yet. 
; will in the future read it back to verify it

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

RAM_START   = $00
  ; RAM segment start
STACK_START_H = $01
STACK_START_L = $00
  ; stack segment start
STACK_END_H   = $02
  ; stack segment end
RAM_END_H    = $3F
RAM_END_L    = $FF
  ; RAM segment end

RAM_WRITING = %00000001
  ; output signal on PORTB indicating RAM is writing
RAM_VERIFY  = %00000010
  ; output signal on PORTB indicating RAM is reading back and comparing
RAM_NACK    = %10000000
  ; output signal on PORTB indicating RAM did not verify
  ; begin code
RAM_ACK    = %00000100
  ; output signal on PORTB indicating RAM did verify
  
  ; begin code
  .org $8000
  
reset:
  lda #$FF
  sta DDRB
    ; set all PORTB pins to output
  lda #RAM_WRITING
  sta PORTB
    ; put NACK on PORTB until memcheck completed 
  jsr setup
  
write:
  inx
    ; increase the x register by 1
  txa 
    ; move the value to the accumulator
  cmp $01
  beq verify
    ; compare the threshold to the loop variable
    ; if we're done quit
  iny 
    ; increase the Y register by one
    ; can't use accumulator b/c INA isn't supported
  sty STACK_END_H, X
    ; store the y value at STACK_END + X

  jmp write
    ; loop

verify:
  ; will jump here if we're done writing to ram
  ; verify the bits were written as required
  lda #RAM_VERIFY
  sta PORTB
  
  jsr setup
  inx
    ; increase the x register by 1
  txa 
    ; move the value to the accumulator
  cmp $01
  beq verify_ack
    ; compare the threshold to the loop variable
    ; if we're done quit
  iny 
    ; increase the Y register by one
    ; can't use accumulator b/c INA isn't supported
  tya 
    ; transfer x register to accumulator
  cmp STACK_END_H, X
    ; compare the value of x
  bne verify_nak
    ; if they didn't verify, set NAK LED and quit

  jmp verify

verify_ack:
  lda #RAM_ACK
  sta PORTB
    ; store ACK onto PORTB
  jmp dead
    ;quit
 
verify_nak:
    ; will jump here if we're done writing to ram
  lda #RAM_NACK
  sta PORTB
    ; store NACK onto PORTB
    
  jmp dead
    ;quit
  
dead:
  nop
  jmp dead
  ; loop forever
  
setup:
  ; loop setup subroutine
  ldx #$00
    ; put the low bits of the pointer into X
  ldy #$00
    ; setup the Y with 0 to start with (a=0)
    ; since we're using original 6502 assm we can't use inx
   
  lda #$FF
  sta $01
    ; store the threshold constant on ram addr 01 (zero page mode)
  rts
    
  .org $fffc
  .word reset
  .word $0000
    ;reset vector
