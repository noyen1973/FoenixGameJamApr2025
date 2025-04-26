
namespace zx0

    section 'CODE'
        virtual TempZ
            ZX0_INPUT resw 1
            ZX0_OUTPUT resw 1
            copysrc resw 1
            offsetL resb 1
            offsetH resb 1
            lenL resb 1
            lenH resb 1
        endvirtual

        macro Decompress('asrc','adest')
        ;    assert (~asize=16) and (~isize=16), error('acc and xy must be in 16bit mode')
            if leftstr('asrc',1)='#'
                movw #({{copy('asrc',2)}}),zx0.ZX0_INPUT
            else
                movw asrc,zx0.ZX0_INPUT
            endif
            if leftstr('adest',1)='#'
                movw #({{copy('adest',2)}}),zx0.ZX0_OUTPUT
            else
                movw adest,zx0.ZX0_OUTPUT
            endif
            jsr zx0.DZX0_Standard
        endmacro

        ; uses TempSrc, TempDest, TempZ
        proc DZX0_Standard
            lda #$ff
            sta offsetL
            sta offsetH
            ldy #$00
            sty lenL
            sty lenH
            lda #$80
        
            dzx0s_literals:
                jsr dzx0s_elias
                pha
            cop0:
                jsr get_byte
                ldy #$00
                sta (ZX0_OUTPUT),y
                incw ZX0_OUTPUT
                lda lenL
                bne +
                    dec lenH
                +
                dec lenL
                bne cop0
                    lda lenH
                    bne cop0
                pla 
                asl
                bcs dzx0s_new_offset
                    jsr dzx0s_elias
            dzx0s_copy:
                pha
                lda ZX0_OUTPUT
                clc
                adc offsetL
                sta copysrc
                lda ZX0_OUTPUT+1
                adc offsetH
                sta copysrc+1

                ldy #$00
                ldx lenH
                beq Remainder
            Page:
                lda (copysrc),y
                sta (ZX0_OUTPUT),y
                iny 
                bne Page
                    inc copysrc+1
                    inc ZX0_OUTPUT+1
                    dex
                    bne Page
            Remainder:
                ldx lenL
                beq copyDone
            copyByte:
                lda (copysrc),y
                sta (ZX0_OUTPUT),y
                iny
                dex
                bne copyByte
                tya 
                clc 
                adc ZX0_OUTPUT
                sta ZX0_OUTPUT
                bcc copyDone
                    inc ZX0_OUTPUT+1
            copyDone:
                stx lenH
                stx lenL
                pla
                asl
                bcc dzx0s_literals
            dzx0s_new_offset:
                ldx #$fe
                stx lenL
                jsr dzx0s_elias_loop
                pha
                php ; stream
                ldx lenL
                inx
                stx offsetH
                bne +
                    plp ; stream
                    pla
                    rts ; done, exit
                +
                jsr get_byte
                plp ; stream
                sta offsetL
                ror offsetH
                ror offsetL
                ldx #$00
                stx lenH
                inx
                stx lenL
                pla 
                bcs +
                    jsr dzx0s_elias_backtrack
                +
                inc lenL
                bne +
                    inc   lenH
                +
                jmp  dzx0s_copy
            dzx0s_elias:
                inc lenL
            dzx0s_elias_loop:
                asl
                bne dzx0s_elias_skip
                    jsr get_byte
                    sec ; stream
                    rol
            dzx0s_elias_skip:
                bcc dzx0s_elias_backtrack
                    rts
            dzx0s_elias_backtrack:
                asl
                rol lenL
                rol lenH
                jmp dzx0s_elias_loop
                    
            get_byte:
                lda (ZX0_INPUT)
                incw ZX0_INPUT
                rts
        endproc

endnamespace

endsection
