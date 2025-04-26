
namespace Viewport
;    define self Viewport
    const Width = 320
    const Height = 200
    const WindowX = 24 , WindowY = 16
    
    section 'ZPAGE'
        MinXPos resw 1
        MinYPos resw 1
        MaxXPos resw 1
        MaxYPos resw 1

        XPos resw 1
        YPos resw 1
        
        XRegPos resw 1 ; value written to tile register
        YRegPos resw 1 ; value written to tile register
        BackgroundXRegPos resw 1 ; value written to tile register
        BackgroundYRegPos resw 1 ; value written to tile register
        
        ; 0=idle, 1=working, 2=ready
        BuildState resb 1
        BSTATE=enum(IDLE=0,WORKING,READY)
    endsection
    
    section 'BSS'
    endsection
    
    section 'CODE'
        proc Init

;            mwa Stages.MinMainXPos,MinXPos
;            mwa Stages.MinMainYPos,MinYPos
            
            sec
            sbcw Stages.MinMainXPos,#16,MinXPos
            sec
            sbcw Stages.MinMainYPos,#16,MinYPos

            ; calculate max xpos and ypos
            sec
            sbcw Stages.MainWidth,#Width,MaxXPos
            sec
            sbcw Stages.MaxMainYPos,#Height,MaxYPos

            ; reset x and y pos of map
            mwa #16,XPos
            mwa #16,YPos
            jsr RecalcXTileRegister
            jsr RecalcYTileRegister
            jsr WriteTileRegisters

            lda #BSTATE.IDLE
            sta BuildState
            rts
        endproc
        
        ; x-1
        ; returns:
        ;   [carry] clear=scrolled, set=no change, far left
        proc ScrollLeft
            lda XPos
            cmp MinXPos
            bne +
                lda XPos+1
                cmp MinXPos+1
                bne +
                    rts
            +
            decw XPos
            jsr RecalcXTileRegister
            rts
        endproc
        
        ; x+1
        proc ScrollRight
            lda XPos
            cmp MaxXPos
            bne +
                lda XPos+1
                cmp MaxXPos+1
                bne +
                    rts
            +
            incw XPos
            jsr RecalcXTileRegister
            rts
        endproc
        
        ; y-1
        proc ScrollUp
            lda YPos
            cmp MinYPos
            bne +
                lda YPos+1
                cmp MinYPos+1
                bne +
                    rts
            +
            decw YPos
            jsr RecalcYTileRegister
            rts
        endproc
        
        ; y+1
        proc ScrollDown
            lda YPos
            cmp MaxYPos
            bne +
                lda YPos+1
                cmp MaxYPos+1
                bne +
                    rts
            +
            incw YPos
            jsr RecalcYTileRegister
            rts
        endproc

        proc RecalcXTileRegister
            lda XPos
            sta XRegPos
            sta BackgroundXRegPos
            lda XPos+1
            sta XRegPos+1
            ; /8
            lsr : ror BackgroundXRegPos ; /2
            lsr : ror BackgroundXRegPos ; /4
            lsr : ror BackgroundXRegPos ; /8
            sta BackgroundXRegPos+1
;            jsr Viewport.ShowScrollPosition
            rts
        endproc

        proc RecalcYTileRegister
            lda YPos
            sta YRegPos
            sta BackgroundYRegPos
            lda YPos+1
            sta YRegPos+1
            ; /8
            lsr : ror BackgroundYRegPos ; /2
            lsr : ror BackgroundYRegPos ; /4
            lsr : ror BackgroundYRegPos ; /8
            sta BackgroundYRegPos+1
;            jsr Viewport.ShowScrollPosition
            rts
        endproc

        proc WriteTileRegisters
            lda YRegPos
            ldx 1+YRegPos
            sta FNX.VKY.TILEMAPS.YPOS+(1*sizeof(FNX.TILEMAP_TYPE))
            stx 1+FNX.VKY.TILEMAPS.YPOS+(1*sizeof(FNX.TILEMAP_TYPE))
            lda XRegPos
            ldx 1+XRegPos
            sta FNX.VKY.TILEMAPS.XPOS+(1*sizeof(FNX.TILEMAP_TYPE))
            stx 1+FNX.VKY.TILEMAPS.XPOS+(1*sizeof(FNX.TILEMAP_TYPE))
            lda BackgroundYRegPos
            ldx 1+BackgroundYRegPos
            sta FNX.VKY.TILEMAPS.YPOS+(2*sizeof(FNX.TILEMAP_TYPE))
            stx 1+FNX.VKY.TILEMAPS.YPOS+(2*sizeof(FNX.TILEMAP_TYPE))
            lda BackgroundXRegPos
            ldx 1+BackgroundXRegPos
            sta FNX.VKY.TILEMAPS.XPOS+(2*sizeof(FNX.TILEMAP_TYPE))
            stx 1+FNX.VKY.TILEMAPS.XPOS+(2*sizeof(FNX.TILEMAP_TYPE))
            rts
        endproc

        proc ShowScrollPosition
            display.Set_CursorPosition(#30,#0)
            lda XPos
            ldy 1+XPos
            jsr display.PrintHexWord
            display.Set_CursorPosition(#35,#0)
            lda YPos
            ldy 1+YPos
            jsr display.PrintHexWord
            rts
        endproc

        proc Build
            virtual TempZ
                lowxpos resw 1
                lowypos resw 1
                highxpos resw 1
                highypos resw 1
                unsortedlistcount resb 1

                NVAL resb 1
                WORK1 resb 1
                WORK2 resb 1
                WORK2hi resb 1
                WORK3 resb 1
                WORK3hi resb 1
                WORK4 resb 1
                WORK5 resb 1
            endvirtual

            section 'ZPAGE'
                unsortedlistactor resb Actors.MAX_ACTORS
            endsection
            
            section 'BSS'
                unsortedlistylo resb Actors.MAX_ACTORS
                unsortedlistyhi resb Actors.MAX_ACTORS
            endsection

            ; make sure idle=0 before building
            lda BuildState
            beq +   ; idle
                rts
            +
            lda #BSTATE.WORKING
            sta BuildState
            
            sec
            sbcw XPos,#16,lowxpos
            sec
            sbcw YPos,#16,lowypos
            clc
            adcw XPos,#Width+16,highxpos
            clc
            adcw YPos,#Height+16,highypos
            
            ldy #0
            ldx #0
            -
                lda Actors.List.State,x
                bmi +
                    lda Actors.List.PosXLo,x
                    cmp lowxpos
                    lda Actors.List.PosXHi,x
                    sbc 1+lowxpos
                    blt +
                    lda Actors.List.PosXLo,x
                    cmp highxpos
                    lda Actors.List.PosXHi,x
                    sbc 1+highxpos
                    bge +
                    lda Actors.List.PosYLo,x
                    cmp lowypos
                    lda Actors.List.PosYHi,x
                    sbc 1+lowypos
                    blt +
                    lda Actors.List.PosYLo,x
                    cmp highypos
                    lda Actors.List.PosYHi,x
                    sbc 1+highypos
                    bge +
                        txa
                        sta unsortedlistactor,y
                        lda Actors.List.PosYLo,x
                        sta unsortedlistylo,y
                        lda Actors.List.PosYHi,x
                        sta unsortedlistyhi,y
                        iny
                +
                inx
                cpx #Actors.MAX_ACTORS
                bne -
                ; check if anything in list
                cpy #0
                bne SortSprites
                
            ldx Actors.ActiveSpriteBuffer
            lda Actors.WorkingSpriteBufferPointersLo,x
            sta WORK2
            lda Actors.WorkingSpriteBufferPointersHi,x
            sta WORK2+1
            jmp Done
            
            SortSprites:
                sty unsortedlistcount
/*
; SORTING SUBROUTINE CODED BY MATS ROSENGREN (MATS.ROSENGREN@ESA.INT)
; http://www.6502.org/source/sorting/optimal.htm
    ; Y=number of elements to sort
                sty NVAL
            .SORT
                ldy NVAL
                lda unsortedlistactor-1,y
                sta WORK5
                lda unsortedlistylo-1,y
                sta WORK3
                lda unsortedlistyhi-1,y
                sta WORK3hi
                bra .L2
            .L1
                dey
                beq .L3
                lda unsortedlistylo-1,y
                cmp WORK2
                lda unsortedlistyhi-1,y
                sbc WORK2hi
                bge .L1
            .L2
                sty WORK1
                sta WORK2hi
                lda unsortedlistylo-1,y
                sta WORK2
                ldx unsortedlistactor-1,y
                bra .L1
            .L3
                ldy NVAL
                lda WORK2
                sta unsortedlistylo-1,y
                lda WORK2hi
                sta unsortedlistyhi-1,y
                stx unsortedlistactor-1,y
                ldy WORK1
                lda WORK3
                sta unsortedlistylo-1,y
                lda WORK3hi
                sta unsortedlistyhi-1,y
                lda WORK5
                sta unsortedlistactor-1,y
                dec NVAL
                bne .SORT

*/
        BuildSpriteBuffer:
;            clc
;            adcw #64,lowxpos
;            clc
;            adcw #64,lowypos
            
            ldx Actors.ActiveSpriteBuffer
            lda Actors.WorkingSpriteBufferPointersLo,x
            sta WORK2
            lda Actors.WorkingSpriteBufferPointersHi,x
            sta WORK2+1
            ldy #0
            -
                sty WORK1
                    ldx unsortedlistactor,y
                    ; control
                    ldy #0
                    lda Actors.List.Control,x
                    sta (WORK2),y
                    iny
                    ; vram
                    lda #0  ;Actors.List.VRAMLo,x
                    sta (WORK2),y
                    iny
                    lda Actors.List.VRAMHi,x
                    sta (WORK2),y
                    iny
                    lda Actors.List.VRAMBk,x
                    sta (WORK2),y
                    iny
                    ; xpos
                    sec
                    lda Actors.List.PosXLo,x
                    sbc lowxpos ; viewport xpos
                    sta (WORK2),y
                    iny
                    lda Actors.List.PosXHi,x
                    sbc 1+lowxpos ; viewport xpos
                    sta (WORK2),y
                    iny
                    ; ypos
                    sec
                    lda Actors.List.PosYLo,x
                    sbc lowypos ; viewport ypos
                    sta (WORK2),y
                    iny
                    lda Actors.List.PosYHi,x
                    sbc 1+lowypos ; viewport ypos
                    sta (WORK2),y

                    clc
                    adcw #sizeof(FNX.SPRITE_TYPE),WORK2
                ldy WORK1
                iny
                cpy unsortedlistcount
                bne -

            cpy #vky.MAX_SPRITES
            beq SwapSpriteBuffer

            Done:
            -
                lda #SPRITE_DISABLE
                sta (WORK2)
                clc
                adcw #sizeof(FNX.SPRITE_TYPE),WORK2
                iny
                cpy #vky.MAX_SPRITES
                bne -
            +

            SwapSpriteBuffer:
                ldx #BSTATE.IDLE
                lda Actors.ActiveSpriteBuffer
                eor #1
                sta Actors.ActiveSpriteBuffer
                stx BuildState
            rts
        endproc
    endsection

endnamespace

