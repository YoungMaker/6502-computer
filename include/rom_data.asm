; 2020 Aaron Walsh
; rom locations
; general ROM data
; include at the END of your asm file

  .org $CF00
  .string "01234566789ABCDEF"
    ; store hex lookup table at CF00-F