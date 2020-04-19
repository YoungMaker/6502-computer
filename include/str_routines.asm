; 2020 Aaron Walsh
; String routines 
; general string ops


HEX_TABLE = $CF00

; Turns 8 bit number into hexidecimal string
; Parameters: 8 bit number is stored in A. $F0-$F1 is pointer to empty string area 
; Returns: 3 byte string is stored in address pointed to in $F0-$F1
; WARNING: at least three bytes must be allocated at the address pointed to in $F0-F1
; NOTE: HEX_TABLE must point to a lookup table in hexidecimal for nibbles
bthex_ascii:
  ldy #0
  tax 
    ; store original value of A into x
  and %11110000
    ; clip out the top nibble of the value stored in A
  lsr a
  lsr a
  lsr a
  lsr a
    ; move top nibble into bottom nibble
  tay
  lda HEX_TABLE, y
    ; load value starting at HEX_TABLE + y value, which is the upper nibble. 
    ; this will look the upper nibble in the hexidecimal lookup table
    ; the correct char is in A now
  ldy #$00
  sta ($F0), y
    ; store correct char at 0th location of string
  txa
    ; put original value of A back into A
  and %00001111
    ; clip out the bottom nibble of the value stored in A
  tay
  lda HEX_TABLE, y
    ; load value starting at HEX_TABLE + y value, which is the lower nibble. 
    ; this will look the lower nibble in the hexidecimal lookup table
    ; the correct char is in A now
  ldy #$01
  sta ($F0), y
    ; store correct char at 1st location of string
  lda #0
  ldy #$02
  sta ($F0), y
    ; store null terminator at 2nd location of string
  rts


; Compares the two strings pointed to
; Parameters: Two strings pointed to at $F0-F1 and $F2-$F3
; Returns: zero in A if equal, nonzero if not equal
; NOTE if either string is > 254 bytes, will return not equal. 
strcmp:
  ldy #0
    ; setup counter for string
strcloop$
  lda ($F0), y
  beq strcendcmp_1$
    ; load char from string 1, if zero, found end of string 1
  cmp ($F0), y
  bne strcend$
    ; compare with string 2, if not equal, quit with status 1
  iny
  tya
  cmp #$FF
  beq strcend$
    ; increment and check for wrap around, quit with status 1
  jmp strcloop$
strcendcmp_1$
  ; go here if end of string 1 is found
  lda ($F2), y
  bne strcend$
    ; load char from string 2, if its not at end (zero), quit with status 1
  lda #0
  rts
strcend$
  ; go here if chars are unequal, wrap around hit, or end 1 did not match end 2
  lda #$01
  rts
  

; Determines the length of a null-terminated
; String at the address pointed to by $F0 and $F1
; Parameters: $F0-$F1 contains address of string we want to test
; WARNING: String must be null terminated for this to exit cleanly
; NOTE: String cannot be larger than 255 bytes.
; Returns: A contains length of string
strlen:
  ldy #0
    ; setup counter for string
strlloop$
  lda ($F0), y 
    ; load character at address $F0-$F1 + Y value
  beq strlend$
    ; if null char exit
  iny
  tya
  cmp #$FF
  beq strlend$
    ; increment and check for wraparound, quit. 
  jmp strlloop$
strlend$
  tya
    ; transter counter to A and return
  rts

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

ebta_loop$
  tax 
  tya
  cmp #$08
  beq ebta_quit$
  txa
    ; copy value in X to A, move the counter to A
    ; compare counter against 9, quit if equal
    ; transfer X back into A if not.
  bit #%10000000
    ; and the accumulator with 01 to see if the last bit is on
  beq cmp_0$
    ; if the zero flag is set, put a zero in the ascii string
cmp_1$
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
  jmp ebta_loop$
cmp_0$
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
  jmp ebta_loop$
ebta_quit$
  lda #0
  sta ($F2), y
    ; add null terminator to string
  plx
  ply
  pla
  rts
