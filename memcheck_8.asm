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

RAM_NAK = %00000001
  ; output signal on PORTB indicating RAM did not verify
RAM_ACK = %00000010
  ; output signal on PORTB indicating RAM did verify. 

  ; begin code
  .org $8000
  
reset:
  lda #$FF
  sta DDRB
    ; set all PORTB pins to output
  lda #RAM_NAK
  sta PORTB
    ; put NACK on PORTB until memcheck completed 
    
  ldx #$00
    ; put the low bits of the pointer into X
  ldy #$00
    ; setup the Y with 0 to start with (a=0)
    ; since we're using original 6502 assm we can't use inx
  
loop:
  inx
    ;increment pointer lower byte
  bcs done
    ; if we overflowed we set 255 bytes and we're done
  iny 
    ; increase the Y register by one
    ; can't use accumulator b/c INA isn't supported
  sty STACK_END_H, X
    ; store the y value at STACK_END + X

  jmp loop
    ; loop
  
done:
    ; will jump here if we're done writing to ram
  lda #RAM_ACK
  sta PORTB
    ; store ACK onto PORTB
  
  .org $fffc
  .word reset
  .word $0000
    ;reset vector
