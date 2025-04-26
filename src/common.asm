section 'BSS'
    KeyBegin = *
    KeyI resb 1
    KeyJ resb 1
    KeyK resb 1
    KeyL resb 1
    KeyCU resb 1
    KeyCL resb 1
    KeyCD resb 1
    KeyCR resb 1
    KeyComma resb 1
    KeyEnd = *
endsection

section 'CODE'
    proc ResetKeys
        ldx #0
        -
            stz KeyBegin,x
            inx
            cpx #KeyEnd-KeyBegin
            bne -
        rts
    endproc
    
    proc WaitForKernalEvents
        mwa #0,TempZ
        -
            jsr kernel.NextEvent
            incw TempZ
            cwbne TempZ,#$0800,-
        rts
    endproc

    ;   A = number of sof frames
    proc WaitForSOFDelay
        section 'BSS'
            countdown resb 1
            keypressed resb 1
        endsection
        sta countdown
        stz keypressed
        jsr Actors.ResetLastActorProcess
        jsr Timers.ResetSOF
        
        -
            ; always refresh player 1 and 2
            ldx #PLAYER1
            jsr Actors.ProcessActorNumber
            ldx #PLAYER2
            jsr Actors.ProcessActorNumber
            ; only refresh one npc per game cycle
            jsr Actors.ProcessNextActor

            lda kernel.event.pending
            bpl -

            jsr kernel.NextEvent
            lda KEvent[kernel.event.type]
            cmp #kernel.event.key.PRESSED
            bne +
                ; process key
                lda KEvent[kernel.results.key_type.ascii]
                cmp #' '
                bne ++
                    sta keypressed
                    bra -
                ++
                jsr ScanCommonInputPressed
                bra -
            +
            cmp #kernel.event.JOYSTICK
            bne +
                lda #FNX.JOY.BUT0
                bit KEvent[kernel.results.joystick_type.joy0]
                beq -
                    sta keypressed
                bit KEvent[kernel.results.joystick_type.joy1]
                beq -
                    sta keypressed
                bra -
            +
            cmp #kernel.event.timer.EXPIRED
            bne -

            lda KEvent[kernel.results.timer_type.cookie]
            cmp #Timers.COOKIES.SOF
            bne -

            jsr Actors.CopySpriteBufferToSpriteRegisters
            jsr Actors.Update
            jsr Viewport.Build
            jsr SID.SIDPLAY
            jsr PSG.UpdateChannels
;            jsr HUD.UpdateEggTimer
            dec countdown
            beq .exit
            jsr Timers.ResetSOF
            bra -
            
        .exit
        lda keypressed
        beq +
            sec
            rts
        +
        clc
        rts
    endproc

    proc ClearVickyRegisters
        vky.Clear_Registers()
        rts
    endproc

    ;   A = address/$2000 to map into bssbank
    proc MapBSSBank
        section 'BSS'
            tempctrl resb 1
            tempbank resb 1
        endsection
        pha
        lda FNX.MMU.MEM_CTRL
        sta tempctrl
        ora #FNX.MMU.EDIT_EN
        sta FNX.MMU.MEM_CTRL
        lda FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        sta tempbank
        pla ;lda #(aaddress/$2000)
        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        rts
    endproc
    
    proc UnmapBSSBank
        lda MapBSSBank.tempbank
        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        lda MapBSSBank.tempctrl
        sta FNX.MMU.MEM_CTRL
        rts
    endproc

    ;   TempZ = source ptr
    ;   TempZ+4 = size
    ;   TempDest = dest clut ptr
    proc Copy_VRAMCLUT
        .IO_GFX
        ; source lptr/$2000=slot#
        lda TempZ+1
        lsr TempZ+2 : ror
        lsr TempZ+2 : ror
        lsr TempZ+2 : ror
        lsr TempZ+2 : ror
        lsr TempZ+2 : ror
        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        lda TempZ+1
        and #$1f
        clc
        adc #>BSSBANK
        sta TempZ+1
        -
            lda (TempZ)
            sta (TempDest)
            incw Tempz
            lda TempZ+1
            cmp #>(BSSBANK+$2000)
            bne +
                inc FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
                lda #>BSSBANK
                sta TempZ+1
            +
            incw TempDest
            decw TempZ+4
            lda TempZ+4
            bne -
            lda TempZ+5
            bne -
        .IO_MAIN
        rts
    endproc
    
    proc Toggle_InputMode
        lda Player.InputMode+PLAYER1
        cmp #INPUTS.KEYBOARD0
        beq .joystick
        .keyboard:
            lda #INPUTS.KEYBOARD0
            sta Player.InputMode+PLAYER1
            lda #INPUTS.KEYBOARD1
            sta Player.InputMode+PLAYER2
            rts
        .joystick:
            lda #INPUTS.JOYPORT0
            sta Player.InputMode+PLAYER1
            lda #INPUTS.JOYPORT1
            sta Player.InputMode+PLAYER2
            rts
    endproc

    proc Play_Sample
        sei
        lda #(bawk_bin/$2000)
        jsr MapBSSBank
        mwa #BSSBANK,TempSrc
        -
            lda (TempSrc)
            lsr : lsr : lsr : lsr
            sta FNX.SID.RIGHT+24
            ldx #192
            --
                dex
                bne --
            incw TempSrc
            cwbne TempSrc,#(BSSBANK+sizeof(bawk_bin)),-
        jsr UnmapBSSBank
        cli
        rts
        
//        mwa #Chick_WAV,TempSrc
//        -
//            lda (TempSrc)
//            lsr : lsr : lsr : lsr
//            sta FNX.SID.BOTH+24
//            ldx #192
//            --
//                dex
//                bne --
//            incw TempSrc
//            cwbne TempSrc,#(Chick_WAV+sizeof(Chick_WAV)),-
//        rts
//        Chick_WAV incbin 'sound\chick.wav',44,$3000
    endproc
    
    proc ScanCommonInputPressed
        cmp #'m'
        bne +
            jsr SID.Toggle_Pause
            rts
        +
        cmp #'1'
        bne +
            .changesong:
                dec
                and #15
                pha
                jsr SID.Reset
                pla
                jsr SID.SIDINIT
                rts
        +
        cmp #'2'
        beq .changesong
        cmp #'3'
        beq .changesong
        cmp #'4'
        beq .changesong
        cmp #'5'
        beq .changesong
        cmp #'6'
        beq .changesong
        cmp #'7'
        beq .changesong
        cmp #'8'
        beq .changesong
        cmp #'9'
        beq .changesong
        cmp #'0'
        bne +
            lda #10
            bra .changesong
        +
        cmp #'i'
        bne +
            sta KeyI
        +
        cmp #'j'
        bne +
            sta KeyJ
        +
        cmp #'k'
        bne +
            sta KeyK
        +
        cmp #'l'
        bne +
            sta KeyL
        +
        cmp #KEYS.CURSORUP
        bne +
            sta KeyCU
        +
        cmp #KEYS.CURSORLEFT
        bne +
            sta KeyCL
        +
        cmp #KEYS.CURSORDOWN
        bne +
            sta KeyCD
        +
        cmp #KEYS.CURSORRIGHT
        bne +
            sta KeyCR
        +
        cmp #','
        bne +
            sta KeyComma
        +
        cmp #'p'
        bne +
            lda #PSG.SFX.BumpedSolid
            jsr PSG.PlaySFX
            rts
        +
        cmp #'c'
        bne +
            jsr SID.Reset
            jsr Play_Sample
            jsr Play_Sample
            jsr Play_Sample
            rts
        +
        rts
    endproc
    proc ScanCommonInputReleased
        cmp #'i'
        bne +
            stz KeyI
        +
        cmp #'j'
        bne +
            stz KeyJ
        +
        cmp #'k'
        bne +
            stz KeyK
        +
        cmp #'l'
        bne +
            stz KeyL
        +
        cmp #KEYS.CURSORUP
        bne +
            stz KeyCU
        +
        cmp #KEYS.CURSORLEFT
        bne +
            stz KeyCL
        +
        cmp #KEYS.CURSORDOWN
        bne +
            stz KeyCD
        +
        cmp #KEYS.CURSORRIGHT
        bne +
            stz KeyCR
        +
        cmp #','
        bne +
            stz KeyComma
        +
    endproc
    
    proc ParseCommonInput
        lda KeyI
        beq +
            jsr Viewport.ScrollUp
        +
        lda KeyJ
        beq +
            jsr Viewport.ScrollLeft
        +
        lda KeyK
        beq +
            jsr Viewport.ScrollDown
        +
        lda KeyL
        beq +
            jsr Viewport.ScrollRight
        +
        lda #0
        ldx Player.FreezeInputTimer+PLAYER2
        bne ++
            ldx KeyCU
            beq +
                ora #FNX.JOY.UP
            +
            ldx KeyCL
            beq +
                ora #FNX.JOY.LFT
            +
            ldx KeyCD
            beq +
                ora #FNX.JOY.DWN
            +
            ldx KeyCR
            beq +
                ora #FNX.JOY.RGT
            +
            ldx KeyComma
            beq +
                ora #FNX.JOY.BUT0
            +
        ++
        sta JoyStates+PLAYER2
        rts
    endproc
        

    ; uses BSSBANK as the mmuslot
    ;   Address = address to get byte from
    ; returns:
    ;   A = byte from address
    proc FarPeek
        section 'ZPAGE'
            Address resl 1
        endsection
        phx
        ; save mmu state and enable edit
;        lda FNX.MMU.MEM_CTRL
;        pha
;        ora #FNX.MMU.EDIT_EN
;        sta FNX.MMU.MEM_CTRL
;        lda FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
;        pha

        ; save a copy of address+1 as we'll be using it as a work area
        ldx Address+1
        ; calculate the mmu slot for the far address
        lda Address+2
        asl Address+1 : rol
        asl Address+1 : rol
        asl Address+1 : rol
        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        txa
        and #$1f
        clc
        adc #>BSSBANK
        sta Address+1
        lda (Address)   ; finally we peek the value
        
        ; restore address+1
;        stx Address+1

        ; restore mmu state using 'x' se we do not clobber the peek value
;        plx
;        stx FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
;        plx
;        stx FNX.MMU.MEM_CTRL
        plx
        rts
    endproc

    ; uses BSSBANK as the mmuslot
    ;   A = byte to poke into address
    ;   Address = address to put byte into
    proc FarPoke
        section 'ZPAGE'
            Address resl 1
        endsection
        phx
        phy
        tay
        ; save mmu state and enable edit
;        lda FNX.MMU.MEM_CTRL
;        pha
;        ora #FNX.MMU.EDIT_EN
;        sta FNX.MMU.MEM_CTRL
;        lda FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
;        pha

        ; save a copy of address+1 as we'll be using it as a work area
        ldx Address+1
        ; calculate the mmu slot for the far address
        lda Address+2
        asl Address+1 : rol
        asl Address+1 : rol
        asl Address+1 : rol
        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
        txa
        and #$1f
        clc
        adc #>BSSBANK
        sta Address+1
        tya
        sta (Address)   ; finally we peek the value
        
        ; restore address+1
;        stx Address+1

        ; restore mmu state using 'x' se we do not clobber the peek value
;        plx
;        stx FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
;        plx
;        stx FNX.MMU.MEM_CTRL
        ply
        plx
        rts
    endproc
    
endsection
