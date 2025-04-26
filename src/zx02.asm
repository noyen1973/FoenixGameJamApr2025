namespace zx02
    section 'ZPAGE' ;'BSS'
        ; Initial values for offset, source, destination and bitr
        zx0_ini_block resb 10    ;byte $00, $00, $00, <SrcSlot, >SrcSlot, `SrcSlot, <DestSlot, >DestSlot, `DestSlot, $80
        source=zx0_ini_block+3
        destination=zx0_ini_block+6
    endsection
; De-compressor for ZX02 files
; ----------------------------
;
; Decompress ZX02 data (6502 optimized format), optimized for speed and size
;  138 bytes code, 58.0 cycles/byte in test file.
;
; Compress with:
;    zx02 input.bin output.zx0
;
; (c) 2022 DMSC
; Code under MIT license, see LICENSE file.

    section 'CODE'
        proc full_decomp
            macro IncLPntr(aptr)
                inc aptr
                bne +
                inc aptr+1
                bne +
                inc aptr+2
                +
            endmacro
        
            virtual TempZ   ;ZP=$80
                offset          resl 1 ;equ ZP+0
                ZX0_src         resl 1 ;equ ZP+2
                ZX0_dst         resl 1 ;equ ZP+4
                bitr            resb 1 ;equ ZP+6
                pntr            resl 1 ;equ ZP+7
            endvirtual
;--------------------------------------------------
; Decompress ZX0 data (6502 optimized format)

            ; clear the initialization block
            stz zx0_ini_block
            stz zx0_ini_block+1
            stz zx0_ini_block+2
            lda #$80
            sta zx0_ini_block+9
    
              ; Get initialization block
              ldy #sizeof(zx0_ini_block)

copy_init     lda zx0_ini_block-1, y
              sta offset-1, y
              dey
              bne copy_init

; Decode literal: Ccopy next N bytes from compressed file
;    Elias(length)  byte[1]  byte[2]  ...  byte[N]
decode_literal
              jsr   get_elias

cop0
        mla ZX0_src,FarPeek.Address
        mla ZX0_dst,FarPoke.Address
        jsr FarPeek ;              lda   (ZX0_src)
        IncLPntr(ZX0_src)
        jsr FarPoke ;              sta   (ZX0_dst)
        IncLPntr(ZX0_dst)
              dex
              bne   cop0

              asl   bitr
              bcs   dzx0s_new_offset

; Copy from last offset (repeat N bytes from last offset)
;    Elias(length)
              jsr   get_elias
dzx0s_copy
              lda   ZX0_dst
              sbc   offset  ; C=0 from get_elias
              sta   pntr
              lda   ZX0_dst+1
              sbc   offset+1
              sta   pntr+1
              lda   ZX0_dst+2
              sbc   offset+2
              sta   pntr+2

cop1
        mla pntr,FarPeek.Address;        lda   (pntr)
        mla ZX0_dst,FarPoke.Address
        jsr FarPeek
        IncLPntr(pntr)
        jsr FarPoke;              sta   (ZX0_dst)
        IncLPntr(ZX0_dst)
              dex
              bne   cop1

              asl   bitr
        bcs +
            jmp decode_literal
        +
;              bcc   decode_literal

; Copy from new offset (repeat N bytes from new offset)
;    Elias(MSB(offset))  LSB(offset)  Elias(length-1)
dzx0s_new_offset
              ; Read elias code for high part of offset
              jsr   get_elias
              beq   exit  ; Read a 0, signals the end
              ; Decrease and divide by 2
              dex
              txa
              lsr
              sta   offset+1

              ; Get low part of offset, a literal 7 bits
        mla ZX0_src,FarPeek.Address
        jsr FarPeek ;              lda   (ZX0_src)
        IncLPntr(ZX0_src)
              ; Divide by 2
              ror
              sta   offset

              ; And get the copy length.
              ; Start elias reading with the bit already in carry:
              ldx   #1
              jsr   elias_skip1

              inx
              bcc   dzx0s_copy

; Read an elias-gamma interlaced code.
; ------------------------------------
get_elias
              ; Initialize return value to #1
              ldx   #1
              bne   elias_start

elias_get     ; Read next data bit to result
              asl   bitr
              rol
              tax

elias_start
              ; Get one bit
              asl   bitr
              bne   elias_skip1

              ; Read new bit from stream
        mla ZX0_src,FarPeek.Address
        jsr FarPeek ;              lda   (ZX0_src)
        IncLPntr(ZX0_src)
             ;sec   ; not needed, C=1 guaranteed from last bit
              rol
              sta   bitr

elias_skip1
              txa
              bcs   elias_get
              ; Got ending bit, stop reading
exit
              rts
        endproc
    endsection    
    
endnamespace
