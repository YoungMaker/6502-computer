; 2020 Aaron Walsh
; String routines 
; general string ops


; Converts an 8 bit value at 
; the address stored in $F0-F1
; into an ASCII number stored 
; at the pointer specifed in $F2-F3
; Paramters: $F0-F1 input address, 
; $F2-F3 output address
; Returns: ASCII binary string at address
; specified in $F2-$F3
ebt_ascii:
  pha
  phy
  phx
  ldy #0
    ; setup loop index
  lda ($F0), y
    ; load the input value at $F0-$F1 into the A register
  
ebta_loop:
  tya
    ; move counter to accumulator
  cmp #$09
  bcs ebta_quit
    ; if the loop iterator reached 9 or higher, quit. We've tested alll bits
  txa
    ; transfer input value (shifted left y times) back into A
  bit #$01
    ; and the accumulator with 01 to see if the last bit is on
  bne cmp_1 
cmp_0:
  tax
  lda #"0"
  sta ($F2), y
  txa
    ; move input in A to X
    ; then put ascii 0 into A
    ; and store at specified index
    ; transfer X back into A
  iny 
    ; increase loop counter
  lsr a
    ; move the bits over by one to the right
    ; so we can test the next bit
  jmp ebta_loop
cmp_1:
  tax
  lda #"1"
  sta ($F2), y
  txa
    ; move input in A to X
    ; then put ascii 1 into A
    ; and store at specified index
    ; transfer X back into A
  iny 
  lsr a
    ; move the bits over by one to the right
    ; so we can test the next bit
  jmp ebta_loop
ebta_quit:
  plx
  ply
  pla
  rts