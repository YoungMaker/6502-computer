; 2020 Aaron Walsh
; Symbols and routines pertaning to controlling the
; WDC65C22S via chip attached at address $6000

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
  ; set GPIO PORTA and PORTB,
  ; plus their data direction registers

IER   = $600E
  ; Interrupt Enable Register 
IFR   = $600D
  ; Interrupt Flag Register
  ; bits will be set here to indicate
  ; the source of an interrupt from the VIA
  
AUX   = $600B
  ; Aux control register
  ; bits 6-7 indicate T1 mode
T1C_L = $6004
T1C_H = $6005
  ; T1 counter register
  ; upon filling of T1C_H
  ; the T1 counter begins counting down
  ; reading T1_H (such as with a BIT instr) will
  ; clear the IFR6 register 
  
T1L_L = $6006
T1L_H = $6007
  ; T1 latch register H/L
  ; upon 

T2C_L = $6008
T2C_H = $6009
  ; T2 counter register
  ; upon filling of T2C_H
  ; the T2 counter begins counting down


; Sets the appropriate IER bit 
; so that T1 flags a hardware interrupt
; when the T1 count reaches zero
; NOTE: call set_t1_free or set_t1_oneshot
; to set the counter and begin the countdown
; Parameters: if $F0 contains 0 IER for T1 will be turned off, otherwise turned on
; Returns: N/A
set_t1_ier:
  pha
  lda $F0
  beq t1_off
t1_on:
  lda IER
  eor #%11000000
    ; load whatever the status of the IER is and set the top two bits high
  sta IER
  pla
  rts
t1_off:
  lda IER
  and #%10111111
    ; load whatever the status of the IER is and set the 6th bit low 
    ; setting the 7th bit low disables all interrupts
  sta IER
    ; set the 6th bit of the IER to disable the T1 interrupt
  pla
  rts

; Sets the appropriate IER bit 
; so that T2 flags a hardware interrupt
; when the T2 count reaches zero
; NOTE: call set_t2_oneshot
; to set the counter and begin the countdown
; Parameters: if $F0 contains 0 IER for T1 will be turned off, otherwise turned on
; Returns: N/A
set_t2_ier
  pha
  lda $F0
  beq t2_off
t2_on:
  lda IER
  eor #%10100000
    ; load whatever the status of the IER is and set the top bit and the 6th bit high
  sta IER
    ; set the IER accordingly
    ; T2 interrupt will now be enabled 
  pla
  rts
t2_off:
  lda IER
  and #%11011111
    ; load whatever the status of the IER is and set the 6th bit low
  sta IER
    ; set the IER accordingly
    ; T2 interrupt will now be enabled 
  pla
  rts

; Sets timer 1 on the VIA to free-run mode
; sets the appropriate AUX register mode for free run mode on T1
; with no PORTB07 square wave out
; this will latch the argument contents into the 
; counter and begin the countdown immediately after rts
; Parameters $F0-$F1 contain L and H bits to be set in the counter
; Returns: N/A
set_t1_free:
  pha
  lda AUX
  eor #%01000000
    ; set bit 6 on the AUX register to 1
  and #%01111111
    ; set bit 7 on the AUX register to 0
  sta AUX
    ; 6-7 T1 to free run, no PORTB07 toggle
  
  lda $F0 
  sta T1C_L
  lda $F1 
  sta T1C_H 
    ; stores low then high bits in the T1 counter register
    ; this immeditately begins the countdown of T1
  pla
  rts