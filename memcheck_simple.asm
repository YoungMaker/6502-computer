; 2020 Aaron Walsh
; Writes something to ram and verifies it

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
    ; put NACK on PORTB until memory check completed
  
  lda #$AA
  sta $01
    ; store at zero page address $0001
  cmp $01
    ; compare zero page address $0001 with $AA which we just stored in it
  beq done
 
loop:
  nop
  nop
  jmp loop

done:
  lda #RAM_ACK
  sta PORTB
  
  .org $fffc
  .word reset
  .word $0000
      ; insert reset vector