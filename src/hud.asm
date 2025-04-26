////////// hud.asm

charmap $20 to $7f = $00, $ff = $ff

namespace HUD
    const WIDTH = 20 , HEIGHT = 15
    const TitleLine = 5
    const IntermissionDuration = $1b0
    section 'VRAM'
Font_ZX02 incbin 'work\comicfont-tile.bin.zx02'
        Font_PCX=loadpcx('work\comicfont-tile.pcx')
//        savebin 'work\comicfont-tile.bin',Font_PCX
        Font_PAL byte Font_PCXPALBGRX
//        Font_TILE resb sizeof(Font_PCX)
        Font_TILE byte Font_PCX
        ; these tiles continue from the font, $60-$6c
        HUD_PCX=loadpcx('work\hud-tile.pcx')
//        savebin 'work\hud-tile.bin',HUD_PCX
        HUD_TILE byte HUD_PCX
        HUDTileStart = (HUD_TILE-Font_TILE)/256
        
        JoyKey_PCX=loadpcx('work\hud-joykey.pcx')
//        savebin 'work\hud-joykey.bin',JoyKey_PCX
        JoyKey_TILE byte JoyKey_PCX
        JoystickTile=(JoyKey_TILE-Font_TILE)/256
        KeyboardTile=JoystickTile+1
        
        TimerNum_PCX=loadpcx('work\eggtimernumbers.pcx')
//        savebin 'work\eggtimernumbers.bin',TimerNum_PCX
        TimerNum_TILE byte TimerNum_PCX
        TimerNum0=(TimerNum_TILE-Font_TILE)/256
    endsection
    HEART_TILE = $66
    
    section 'DATA'
        Top_MAP byte ($00,$01,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$02,$03,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$1fffffff,,
                      $04,$05,$06,$06,$06,$07,$08,$09,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$0a,$0b,$06,$06,$06,$07,$08,$09,,
                      $0c,$0d,$1fffffff,$1fffffff,$1fffffff,$0e,$1fffffff,$0f,$1fffffff,$1fffffff,$1fffffff,$1fffffff,$0c,$0d,$1fffffff,$1fffffff,$1fffffff,$0e,$1fffffff,$0f,
                     )+HUDTileStart
    
        ScoreOffset byte (2,14)*2
        HealthOffset byte (2,14)*2
        EggsOffset byte 12,36
        ChicksOffset byte 12,36
        EggTimerOffset byte 8*2
        TX_Egg bytez 'Egg'
        TX_Timer bytez 'Timer'
        TX_Stage char 'Stage 00',$ff
    endsection
    
    section 'BSS'
        align 2
        Map resw WIDTH*HEIGHT
        MapEnd = *
    endsection

    section 'CODE'
        proc Clear
            mwa #Map,TempDest
            lda #0
            -
                sta (TempDest)
                incw TempDest
                cxwbne TempDest,#MapEnd,-
            rts
        endproc
    
        proc Init
            jsr Clear
            mla #Font_PAL,TempZ
            mwa #sizeof(Font_PAL),TempZ+4
            mwa #FNX.VKY.CLUT0,TempDest         ; copy palette to clut0 - player 1
            lda #(Font_PAL/$2000)
            jsr MapBSSBank
            jsr Copy_VRAMCLUT                       
            jsr UnmapBSSBank

            mla #Font_PAL,TempZ
            mwa #sizeof(Font_PAL),TempZ+4
            mwa #FNX.VKY.CLUT1,TempDest         ; copy palette to clut1 - player 2
            lda #(Font_PAL/$2000)
            jsr MapBSSBank
            jsr Copy_VRAMCLUT                       
            jsr UnmapBSSBank
            ; modify clut1 for brown chicken
            .IO_GFX
            mla #$995806,FNX.VKY.CLUT1+(141*4) ;141
            mla #$6f5400,FNX.VKY.CLUT1+(142*4) ;142
            .IO_MAIN
    
            mla #Font_ZX02,zx02.source
            mla #Font_TILE,zx02.destination
//            sei
//        lda FNX.MMU.MEM_CTRL
//        pha
//        ora #FNX.MMU.EDIT_EN
//        sta FNX.MMU.MEM_CTRL
//        lda FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
//        pha
//            jsr zx02.full_decomp
//        pla
//        sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
//        pla
//        sta FNX.MMU.MEM_CTRL
//            cli
            
; removed since the palette was moved to vram, this only works if the palette is in mapped 64kb memory
;            vky.ColorLUT_Set(0,#Font_PAL,#sizeof(Font_PAL))
            vky.Tileset_Set(0,#Font_TILE,TILE_VERTICAL)
            vky.Tilemap_Set(0,#Map,TILE_SZ16,#WIDTH,#HEIGHT,#0,#0,TILE_ENABLE)
            vky.Layer_Set(0,TL0)
            rts
        endproc

        proc Draw
            display.Set_CursorColor(#C64.LTRED,#C64.BLACK)
            display.Set_CursorPosition(#19,#0)
            display.Print_Text(#TX_Egg)
            display.Set_CursorPosition(#18,#3)
            display.Print_Text(#TX_Timer)
            .IO_TEXT
            lda #$fe
            sta 19+FNX.VKY.TEXT_MEM+1*40
            lda #$ff
            sta 19+FNX.VKY.TEXT_MEM+2*40
            .IO_COLOR
            lda #C64.WHITE<<4
            sta 19+FNX.VKY.TEXT_MEM+1*40
            sta 19+FNX.VKY.TEXT_MEM+2*40

            sta 17+FNX.VKY.TEXT_MEM+2*40
            sta 18+FNX.VKY.TEXT_MEM+2*40
            sta 19+FNX.VKY.TEXT_MEM+2*40
            sta 37+FNX.VKY.TEXT_MEM+2*40
            sta 38+FNX.VKY.TEXT_MEM+2*40
            sta 39+FNX.VKY.TEXT_MEM+2*40

            sta 12+FNX.VKY.TEXT_MEM+3*40
            sta 13+FNX.VKY.TEXT_MEM+3*40
            sta 36+FNX.VKY.TEXT_MEM+3*40
            sta 37+FNX.VKY.TEXT_MEM+3*40

            lda #C64.YELLOW<<4
            sta 12+FNX.VKY.TEXT_MEM+2*40
            sta 13+FNX.VKY.TEXT_MEM+2*40
            sta 36+FNX.VKY.TEXT_MEM+2*40
            sta 37+FNX.VKY.TEXT_MEM+2*40

            .IO_MAIN

            ldx #0
            ldy #0
            -
                lda Top_MAP,x
                cmp #<($ff+HUDTileStart)
                beq +
                    sta Map,y
                +
                iny
                iny
                inx
                cpx #sizeof(Top_MAP)
                bne -

            jsr ShowEggTimer
            ldx #0
            jsr ShowHealth
            jsr ShowEggs
            jsr ShowChicks
            jsr ShowScore
            lda Players
            cmp #MAX_PLAYERS
            bne +
                ldx #1
                jsr ShowHealth
                jsr ShowEggs
                jsr ShowChicks
                jsr ShowScore
            +
            rts
        endproc

        
        ;   X = player
        proc ShowHealth
            phx
            phy
            lda Player.Health,x
            sta TempZ
            ldy HealthOffset,x
            cpx #PLAYER2
            beq .player2
            .player1:
                lda #0
                sta 0+(1*WIDTH)*2+Map,y
                sta 2+(1*WIDTH)*2+Map,y
                sta 4+(1*WIDTH)*2+Map,y
                lda TempZ
                beq ++
                    lda #HEART_TILE
                    -
                        sta (1*WIDTH)*2+Map,y
                        iny
                        iny
                        dec TempZ
                        bne -
                ++
                ply
                plx
                rts
            
            .player2:
                lda #0
                sta 0+(1*WIDTH)*2+Map,y
                sta 2+(1*WIDTH)*2+Map,y
                sta 4+(1*WIDTH)*2+Map,y
                lda TempZ
                beq ++
                    lda #HEART_TILE
                    -
                        sta (1*WIDTH)*2+Map,y
                        iny
                        iny
                        dec TempZ
                        bne -
                ++
                ply
                plx
                rts
        endproc
        
        ;   X = player
        proc AddHeart
            lda Player.Health,x
            cmp #3
            beq +
                lda #PSG.SFX.PickupHeart
                jsr PSG.PlaySFX
                inc Player.Health,x
                jsr ShowHealth
            rts
            +
            lda #PSG.SFX.TooManyHearts   
            jsr PSG.PlaySFX
            rts
        endproc
        ;   A = sound effect to play
        ;   X = player
        proc MinusHeart
            jsr PSG.PlaySFX
            dec Player.Health,x
            beq +
                jsr ShowHealth
                clc
                rts
            +
            jsr ShowHealth
            sta JoyStates,x
            sec
            rts
        endproc
        
        ;   X = player
        proc ShowEggs
            phx
            phy
            ldy #0
;            ; 100's
;            lda Player.EggsHi,x
;            and #15
;            sta TempZ+0
;            bne +
;                iny
;            +
            ; 10's
            lda Player.EggsLo,x
            lsr : lsr : lsr : lsr
            and #15
            sta TempZ+1
            bne +
                cpy #1
                bne +
                    iny
            +
            ; 1's
            lda Player.EggsLo,x
            and #15
            sta TempZ+2
            tya
            ldy EggsOffset,x
            tax
            .IO_TEXT
            lda TempZ+1,x
            beq +
                ora #$30
                sta FNX.VKY.TEXT_MEM+3*40,y
                iny
            +
            lda TempZ+2,x
            ora #$30
            sta FNX.VKY.TEXT_MEM+3*40,y
            iny
            lda #' '
            sta FNX.VKY.TEXT_MEM+3*40,y
 ;           -
 ;               lda TempZ,x
 ;               ora #$30
 ;               sta FNX.VKY.TEXT_MEM+2*40,y
 ;               iny
 ;               inx
 ;               cpx #3
 ;               bne -
 ;           lda #' '
 ;           sta 0+FNX.VKY.TEXT_MEM+2*40,y
 ;           sta 1+FNX.VKY.TEXT_MEM+2*40,y
            .IO_MAIN
            ply
            plx
            rts
        endproc
        
        ;   X = player
        proc ShowChicks
            phx
            phy
            ldy #0
            ; 10's
            lda Player.ChicksLo,x
            lsr : lsr : lsr : lsr
            and #15
            sta TempZ+1
            bne +
                cpy #1
                bne +
                iny
            +
            ; 1's
            lda Player.ChicksLo,x
            and #15
            sta TempZ+2
            tya
            ldy ChicksOffset,x
            tax
            .IO_TEXT
            lda TempZ+1,x
            beq +
                ora #$30
                bra ++
                +
                lda #' '
            ++
            sta FNX.VKY.TEXT_MEM+2*40,y
            iny

            lda TempZ+2,x
            ora #$30
            sta FNX.VKY.TEXT_MEM+2*40,y
            .IO_MAIN
            ply
            plx
            rts
        endproc
        
        ;   A = egg coins
        ;   X = player
        proc AddChicks
            phx
            phy
            lda #PSG.SFX.PickupChick
            jsr PSG.PlaySFX
            sed
            clc
            adc Player.ChicksLo,x
            sta Player.ChicksLo,x
            lda Player.ChicksHi,x
            adc #0
            sta Player.ChicksHi,x
            cld
            jsr ShowChicks
            ply
            plx
            rts
        endproc
        
        ;   X = player
        proc ShowScore
            phx
            phy
            ldy #0
            ; 100000's
            lda Player.ScoreHi,x
            lsr : lsr : lsr : lsr
            and #15
            sta TempZ+0
            bne +
                iny
            +
            ; 10000's
            lda Player.ScoreHi,x
            and #15
            sta TempZ+1
            bne +
                cpy #1
                bne +
                    iny
            +
            ; 1000's
            lda Player.ScoreMd,x
            lsr : lsr : lsr : lsr
            and #15
            sta TempZ+2
            bne +
                cpy #2
                bne +
                    iny
            +
            ; 100's
            lda Player.ScoreMd,x
            and #15
            sta TempZ+3
            bne +
                cpy #3
                bne +
                    iny
            +
            ; 10's
            lda Player.ScoreLo,x
            lsr : lsr : lsr : lsr
            and #15
            sta TempZ+4
            bne +
                cpy #4
                bne +
                    iny
            +
            ; 1's
            lda Player.ScoreLo,x
            and #15
            sta TempZ+5
;            bne +
;                cpy #5
;                bne +
;                    iny
;            +
            tya
            ldy ScoreOffset,x
            tax
            phx
            -
                lda TempZ,x
                ora #$10
                sta Map+(0*WIDTH)*2,y
                iny
                iny
                inx
                cpx #6
                bne -
            plx
;            beq +
//            lda #$00
//            -
//                sta HUD_map+(0*WIDTH)*2,y
//                iny
//                iny
//                dex
//                bne -
//            +
            ply
            plx
            rts
        endproc
        
        ;   A = egg coins
        ;   X = player
        proc AddEggs
            phx
            phy
            lda #PSG.SFX.PickupEgg
            jsr PSG.PlaySFX
            sed
            clc
            adc Player.EggsLo,x
            sta Player.EggsLo,x
            lda Player.EggsHi,x
            adc #0
            sta Player.EggsHi,x
            cld
            jsr ShowEggs
            ply
            plx
            rts
        endproc
        
        ;   Y:A = points
        ;   X = player
        proc AddScore
            sed
            clc
            adc Player.ScoreLo,x
            sta Player.ScoreLo,x
            tya
            adc Player.ScoreMd,x
            sta Player.ScoreMd,x
            lda Player.ScoreHi,x
            adc #0
            sta Player.ScoreHi,x
            cld
            jsr HUD.ShowScore
            rts
        endproc

        proc TestAddEggsAndScore
            ldx #0
                lda #1
            jsr AddEggs
                lda #<$0007 ; 7 points
                ldy #>$0007
            jsr AddScore
            ldx #1
                lda #1
            jsr AddEggs
                lda #<$0003 ; 3 points
                ldy #>$0003
            jsr AddScore
            rts
        endproc

        proc ShowEggTimer
            ldx EggTimerOffset
            lda EggTimerHi
            pha
            lsr : lsr : lsr : lsr
            and #15
            bne +
                lda #$00
                sta Map+(0+0*WIDTH)*2,x
                bra ++
            +
            clc
            adc #TimerNum0
            sta Map+(0+0*WIDTH)*2,x
            adc #10
            ++
            sta Map+(0+1*WIDTH)*2,x
            pla
            and #15
            clc
            adc #TimerNum0
            sta Map+(1+0*WIDTH)*2,x
            adc #10
            sta Map+(1+1*WIDTH)*2,x

            lda EggTimerLo
            pha
            lsr : lsr : lsr : lsr
            and #15
            clc
            adc #TimerNum0
            sta Map+(2+0*WIDTH)*2,x
            adc #10
            sta Map+(2+1*WIDTH)*2,x
            pla
            and #15
            clc
            adc #TimerNum0
            sta Map+(3+0*WIDTH)*2,x
            adc #10
            sta Map+(3+1*WIDTH)*2,x
            rts
        endproc
        
        ; call per start of frame, 60 times will decrease the timer
        proc UpdateEggTimer
            inc EggTimerSub
            lda EggTimerSub
            cmp #60;10;60;20;60
            beq +
                rts
            +
            stz EggTimerSub ; reset sub counter

            ; check if counter already zero
            lda EggTimerLo
            bne +
            lda EggTimerHi
            bne +
                rts
            +
            ; decrease by 1
            sed
            sec
            lda EggTimerLo
            sbc #1
            sta EggTimerLo
            lda EggTimerHi
            sbc #0
            sta EggTimerHi
            cld
            lda EggTimerLo
            cmp #$99
            bne +
                lda #$59
                sta EggTimerLo
            +
            jsr ShowEggTimer
            rts
        endproc

        ;   TempSrc = pointer to source text, $ff=end
        ;   TempDest = pointer to location in HUD.Map
        proc ShowTextInFont10
            incw TempSrc
            sta (TempDest)
            incw TempDest
            lda #(FONTTSET+FONTCLUT<<3)
            sta (TempDest)
            incw TempDest
        endproc
        proc ShowTextInFont
            lda (TempSrc)
            cmp #$ff
            bne ShowTextInFont10
            rts
        endproc

        proc ClearStageTitle
            ldx #0
            -
                lda #$00
                sta HUD.Map+(TitleLine+0)*WIDTH*2,x
                sta HUD.Map+(TitleLine+2)*WIDTH*2,x
                inx
                lda #(FONTTSET+FONTCLUT<<3)
                sta HUD.Map+(TitleLine+0)*WIDTH*2,x
                sta HUD.Map+(TitleLine+2)*WIDTH*2,x
                inx
                ; delay
                lda #60
                ldy #0
                --
                    dey
                    bne --
                    dec
                    bne --
                cpx #(WIDTH*2)
                bne -
            rts
        endproc

        proc ShowStageTitle
;            jsr WaitForKernalEvents
            ldx #6
            lda #$00
            sta TX_Stage+0,x
            sta TX_Stage+1,x

            lda Stage
            pha
            lsr : lsr : lsr : lsr
            and #15
            beq +
                ora #$10
                sta TX_Stage,x
                inx
            +
            pla
            and #15
            ora #$10
            sta TX_Stage,x
            
            mwa #TX_Stage,TempSrc
            mwa #(Map+(6+(TitleLine+0)*WIDTH)*2),TempDest
            jsr ShowTextInFont
            
            mwa #Stages.Title,TempSrc
            mwa #(Map+(TitleLine+2)*WIDTH*2),TempDest
            ; print to center of line
            sec
            lda #WIDTH
            sbc (TempSrc)   ; first byte is length
            and #$fe        ; (a/2)*2 make even number
            clc
            adc TempDest
            sta TempDest
            lda TempDest+1
            adc #0
            sta TempDest+1
            incw TempSrc
            jsr ShowTextInFont

//            ; play intermission tune
//            lda #2
//            jsr SID.SIDINIT
            jsr Timers.ResetSOF
            -
                lda kernel.event.pending
                bpl +
                    jsr kernel.NextEvent
                    lda KEvent[kernel.event.type]
                    cmp #kernel.event.timer.EXPIRED
                    bne ++
                        lda KEvent[kernel.results.timer_type.cookie]
                        cmp #Timers.COOKIES.SOF
                        bne -
                            jsr SID.SIDPLAY
                            jsr Timers.ResetSOF
                            bra -
                    ++
                    cmp #kernel.event.key.PRESSED
                    beq .exit
                    cmp #kernel.event.JOYSTICK
                    bne +
                        lda KEvent[kernel.results.joystick_type.joy0]
                        bit #FNX.JOY.BUT0
                        bne .exit
                        lda KEvent[kernel.results.joystick_type.joy1]
                        bit #FNX.JOY.BUT0
                        bne .exit
                +
                ; 
                cwblt SID.Duration,#IntermissionDuration,-

            .exit:
            jsr ClearStageTitle
            jsr WaitForKernalEvents
            rts
        endproc

        proc GameOver
            jsr WaitForKernalEvents
            -
                ;   TempSrc = pointer to source text, $ff=end
                ;   TempDest = pointer to location in HUD.Map
                mwa #TX_GameOver,TempSrc
                mwa #(Map+(6+(TitleLine+0)*WIDTH)*2),TempDest
                jsr ShowTextInFont
                lda #90
                jsr WaitForSOFDelay
                bcs .exit
                
                ldx #0
                lda #$00
                --
                    sta HUD.Map+(TitleLine+0)*WIDTH*2,x
                    inx
                    inx
                    cpx #(WIDTH*2)
                    bne --

                lda #40
                jsr WaitForSOFDelay
                bcc -

            .exit:
            jsr SID.Reset
            jsr PSG.Init
            jsr WaitForKernalEvents
            jsr ClearStageTitle
            rts
            
            section 'DATA'
                TX_GameOver char 'GAME OVER',$ff
            endsection
        endproc
        
    endsection

endnamespace

//////////
