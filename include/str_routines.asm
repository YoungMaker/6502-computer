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
; WARNING: must be 8 bytes availabe starting at the address
; specified in $F2-F3
ebt_ascii:
  pha
  phy
  phx
  ldy #0
    ; setup loop index
  lda ($F0), y
    ; load the input value at $F0-$F1 into the A register

ebta_loop:
  tax 
  tya
  cmp #$08
  beq ebta_quit
  txa
    ; copy value in X to A, move the counter to A
    ; compare counter against 9, quit if equal
    ; transfer X back into A if not.
  bit #%10000000
    ; and the accumulator with 01 to see if the last bit is on
  beq cmp_0
    ; if the zero flag is set, put a zero in the ascii string
cmp_1:
  tax
  lda #"1"
  sta ($F2), y
  txa
    ; move input in A to X
    ; then put ascii 0 into A
    ; and store at specified index
    ; transfer X back into A
  iny 
    ; increase loop counter
  asl a
    ; move the bits over by one to the right
    ; so we can test the next bit
  jmp ebta_loop
cmp_0:
  tax
  lda #"0"
  sta ($F2), y
  txa
    ; move input in A to X
    ; then put ascii 1 into A
    ; and store at specified index
    ; transfer X back into A
  iny 
  asl a
    ; move the bits over by one to the right
    ; so we can test the next bit
  jmp ebta_loop
ebta_quit:
  lda #0
  sta ($F2), y
    ; add null terminator to string
  plx
  ply
  pla
  rts