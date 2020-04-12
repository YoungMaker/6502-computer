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