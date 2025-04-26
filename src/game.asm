
namespace Game

    section 'CODE'
        proc CalculateStartPositions
            lda Stages.P1XStart
            stz Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            sta Actors.InitActor.xpos
            lda Stages.P1YStart
            stz Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            sta Actors.InitActor.ypos
            mwa #0,Actors.InitActor.xvel
            mwa #0,Actors.InitActor.yvel
            ldx #PLAYER1
            lda #Actors.Role.CHICKENWHITE
            ldy Stages.P1FacingStart
            jsr Actors.InitActorNumber
        
            lda Stages.P2XStart
            stz Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            asl : rol Actors.InitActor.xpos+1
            sta Actors.InitActor.xpos
            lda Stages.P2YStart
            stz Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            asl : rol Actors.InitActor.ypos+1
            sta Actors.InitActor.ypos
            mwa #0,Actors.InitActor.xvel
            mwa #0,Actors.InitActor.yvel
            ldx #PLAYER2
            lda #Actors.Role.CHICKENBROWN
            ldy Stages.P2FacingStart
            jsr Actors.InitActorNumber
            
            lda Stages.VPXStart
            stz Viewport.XPos+1
            asl : rol Viewport.XPos+1
            asl : rol Viewport.XPos+1
            asl : rol Viewport.XPos+1
            asl : rol Viewport.XPos+1
            sta Viewport.XPos
            lda Stages.VPYStart
            stz Viewport.YPos+1
            asl : rol Viewport.YPos+1
            asl : rol Viewport.YPos+1
            asl : rol Viewport.YPos+1
            asl : rol Viewport.YPos+1
            sta Viewport.YPos
            jsr Viewport.RecalcXTileRegister
            jsr Viewport.RecalcYTileRegister
            jsr Viewport.WriteTileRegisters
            
            lda Players
            cmp #1
            bne +
                lda #Actors.STATE.DEAD
                sta Actors.List.State+PLAYER2
            +
            rts
        endproc
            
        proc InitTestActors
            mwa #$16*16,Actors.InitActor.xpos
            mwa #3*16,Actors.InitActor.ypos
            mwa #0,Actors.InitActor.xvel
            mwa #0,Actors.InitActor.yvel
            ldx #PLAYER1
            lda #Actors.Role.CHICKENWHITE
            ldy #FACING.RIGHT
            jsr Actors.InitActorNumber
            lda Players
            cmp #2
            bne +
                mwa #10*16,Actors.InitActor.xpos
                mwa #11*16,Actors.InitActor.ypos
                mwa #0,Actors.InitActor.xvel
                mwa #0,Actors.InitActor.yvel
                ldx #PLAYER2
                lda #Actors.Role.CHICKENBROWN
                ldy #FACING.LEFT
                jsr Actors.InitActorNumber
            +
            rts
        endproc

        proc ShowStartTestInfo
            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)
            display.Set_CursorPosition(#0,#6)
            display.Print_HexWord(Stages.MinMainXPos)
            display.Set_CursorPosition(#0,#7)
            display.Print_HexWord(Stages.MinMainYPos)
            display.Set_CursorPosition(#0,#8)
            display.Print_HexWord(Stages.MaxMainXPos)
            display.Set_CursorPosition(#0,#9)
            display.Print_HexWord(Stages.MaxMainYPos)

            display.Set_CursorPosition(#5,#6)
            display.Print_HexWord(Viewport.MinXPos)
            display.Set_CursorPosition(#5,#7)
            display.Print_HexWord(Viewport.MinYPos)
            display.Set_CursorPosition(#5,#8)
            display.Print_HexWord(Viewport.MaxXPos)
            display.Set_CursorPosition(#5,#9)
            display.Print_HexWord(Viewport.MaxYPos)

            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)
            display.Set_CursorPosition(#0,#12)
            display.Print_HexByte(Actors.List.PosXHi+6)
            display.Print_HexByte(Actors.List.PosXLo+6)
            display.Set_CursorPosition(#5,#12)
            display.Print_HexByte(Actors.List.PosYHi+6)
            display.Print_HexByte(Actors.List.PosYLo+6)
            display.Set_CursorPosition(#0,#13)
            display.Print_HexByte(Actors.List.PosXHi+7)
            display.Print_HexByte(Actors.List.PosXLo+7)
            display.Set_CursorPosition(#5,#13)
            display.Print_HexByte(Actors.List.PosYHi+7)
            display.Print_HexByte(Actors.List.PosYLo+7)
            
            rts
        endproc
        
        proc ShowTestInfo
            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)
            display.Set_CursorPosition(#10,#6)
;            display.Print_HexWord(Viewport.XPos)
;            display.Set_CursorPosition(#10,#7)
;            display.Print_HexWord(Viewport.YPos)
;            display.Set_CursorPosition(#15,#6)
            lda Actors.List.State+PLAYER1
            jsr display.PrintHexByte
            lda Actors.List.Process+PLAYER1
            jsr display.PrintHexByte
;            lda Actors.List.AniDelay+PLAYER1
;            jsr display.PrintHexByte
;            lda Actors.List.AniFrame+PLAYER1
;            jsr display.PrintHexByte
;            lda Actors.List.DurationLo+PLAYER1
;            jsr display.PrintHexByte
            display.Set_CursorPosition(#15,#6)
            lda Actors.List.PosXHi+PLAYER1
            jsr display.PrintHexByte
            lda Actors.List.PosXLo+PLAYER1
            jsr display.PrintHexByte
            lda Actors.List.PosYHi+PLAYER1
            jsr display.PrintHexByte
            lda Actors.List.PosYLo+PLAYER1
            jsr display.PrintHexByte

            display.Set_CursorPosition(#10,#7)
            lda Actors.List.State+PLAYER2
            jsr display.PrintHexByte
            lda Actors.List.Process+PLAYER2
            jsr display.PrintHexByte
;            lda Actors.List.AniDelay+PLAYER2
;            jsr display.PrintHexByte
;            lda Actors.List.AniFrame+PLAYER2
;            jsr display.PrintHexByte
;            lda Actors.List.DurationLo+PLAYER2
;            jsr display.PrintHexByte
            display.Set_CursorPosition(#15,#7)
            display.Set_CursorColor(#C64.CYAN,#C64.BLACK)
            lda Actors.List.PosXHi+PLAYER2
            jsr display.PrintHexByte
            lda Actors.List.PosXLo+PLAYER2
            jsr display.PrintHexByte
            display.Set_CursorColor(#C64.YELLOW,#C64.BLACK)
            lda Actors.List.PosYHi+PLAYER2
            jsr display.PrintHexByte
            lda Actors.List.PosYLo+PLAYER2
            jsr display.PrintHexByte
            rts
        endproc

        proc ShowPlayerStats
            phx
            display.Set_CursorColor(#C64.CYAN,#C64.BLACK)
            display.Set_CursorPosition(#0,#5)
            ldy #0
            ldx #2
            -
                lda Actors.List.State,x
                bmi +
                    iny
                +
                inx
                cpx #Actors.MAX_ACTORS
                bne -
            tya
            display.Print_HexByte(A)
            plx
            display.Set_CursorColor(#C64.YELLOW,#C64.BLACK)
            display.Set_CursorPosition(#0,#6)
            display.Print_HexByte(Viewport.XPos)
            display.Set_CursorPosition(#5,#6)
            display.Print_HexByte(Viewport.YPos)

            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)
            display.Set_CursorPosition(#0,#7)
            display.Print_HexByte(Actors.List.PosXHi+PLAYER1)
            display.Print_HexByte(Actors.List.PosXLo+PLAYER1)
            display.Set_CursorPosition(#5,#7)
            display.Print_HexByte(Actors.List.PosYHi+PLAYER1)
            display.Print_HexByte(Actors.List.PosYLo+PLAYER1)

            display.Set_CursorPosition(#15,#7)
            display.Print_HexByte(Actors.List.PosXHi+PLAYER2)
            display.Print_HexByte(Actors.List.PosXLo+PLAYER2)
            display.Set_CursorPosition(#20,#7)
            display.Print_HexByte(Actors.List.PosYHi+PLAYER2)
            display.Print_HexByte(Actors.List.PosYLo+PLAYER2)
            rts
        endproc
        
        proc DecreaseFreezeInput
            lda Player.FreezeInputTimer+PLAYER1
            beq +
                dec Player.FreezeInputTimer+PLAYER1
            +
            lda Player.FreezeInputTimer+PLAYER2
            beq +
                dec Player.FreezeInputTimer+PLAYER2
            +
            rts
        endproc

        proc AddPlayerHearts
            lda #10
            jsr WaitForSOFDelay
            -
                lda Player.Health+PLAYER1
                cmp #3
                beq .exit

                ldx #PLAYER1
                jsr HUD.AddHeart
                lda Players
                cmp #2
                bne +
                    ldx #PLAYER2
                    jsr HUD.AddHeart
                +
                lda #25 ; ~1/2 of a second
                jsr WaitForSOFDelay
                bra -    
                
            .exit:
            lda #10
            jsr WaitForSOFDelay

;            ldx #PLAYER1
;            lda #PSG.SFX.PickupHeart
;            jsr HUD.MinusHeart
;            lda Players
;            cmp #1
;            beq +
;                ldx #PLAYER2
;                lda #PSG.SFX.PickupHeart
;                jsr HUD.MinusHeart
;            +
            rts
        endproc
        
        proc Main
            ; clear all kernel events
            jsr WaitForKernalEvents
        
            display.Clear_Screen()
            vky.Mode_Set(ENABLE,TEXT,TEXTOVERLAY,GRAPHICS,SPRITES,TILES,400P,FONT1,DOUBLEX,DOUBLEY)
;            vky.Border_Enable()
;            vky.Border_Width(#1)
;            vky.Border_Height(#0)
            stz Player.Health+PLAYER1
            stz Player.Health+PLAYER2
            stz Player.ScoreLo+PLAYER1
            stz Player.ScoreMd+PLAYER1  ;bcd
            stz Player.ScoreHi+PLAYER1  ;bcd
            stz Player.ScoreLo+PLAYER2  ;bcd
            stz Player.ScoreMd+PLAYER2  ;bcd
            stz Player.ScoreHi+PLAYER2  ;bcd
            stz Player.EggsLo+PLAYER1  ;bcd
            stz Player.EggsHi+PLAYER1  ;bcd
            stz Player.EggsLo+PLAYER2  ;bcd
            stz Player.EggsHi+PLAYER2  ;bcd
            stz Player.ChicksLo+PLAYER1  ;bcd
            stz Player.ChicksHi+PLAYER1  ;bcd
            stz Player.ChicksLo+PLAYER2  ;bcd
            stz Player.ChicksHi+PLAYER2  ;bcd
            stz Player.FreezeInputTimer+PLAYER1
            stz Player.FreezeInputTimer+PLAYER2


///            
            jsr PSG.Init
            jsr Actors.ClearList
            jsr Actors.ResetLastActorProcess
            jsr HUD.Init
            jsr Actors.Go.Init

            lda #1
            jsr Stages.Init
            jsr Viewport.Init
            jsr CalculateStartPositions
;            jsr InitTestActors
;            jsr ShowStartTestInfo
            
            jsr ResetKeys
            stz JoyStates+PLAYER1
            stz JoyStates+PLAYER2
            jsr HUD.Draw

            ; play intermission tune
            lda #2
            jsr SID.SIDINIT
//            jsr Timers.ResetSOF

            ; show animated heart lives
            jsr AddPlayerHearts

            ; show stage intermission
            jsr HUD.ShowStageTitle
            
            lda Stages.Song
            jsr SID.SIDINIT
            jsr Timers.ResetSOF

            Main10:
                lda Player.Health+PLAYER1
                bne +
                    lda Players
                    cmp #1
                    beq .alldead
                        lda Player.Health+PLAYER2
                        bne +
                        
                        .alldead:
                            lda #GAMEMODES.TITLE
                            sta GameMode
                            jsr WaitForKernalEvents
                            lda #60
                            jsr WaitForSOFDelay
                            jsr HUD.GameOver
                            jmp Exit
                +
;                jsr ShowTestInfo

                ; always refresh player 1 and 2
                ldx #PLAYER1
                jsr Actors.ProcessActorNumber
                ldx #PLAYER2
                jsr Actors.ProcessActorNumber
                ; only refresh one npc per game cycle
//                jsr Actors.ProcessNextActor
                ldx #MAX_PLAYERS
                -
                    phx
                    jsr Actors.ProcessActorNumber
                    plx
                    inx
                    cpx #Actors.MAX_ACTORS
                    bne -
                    
                ; process kernel events
                lda kernel.event.pending
                bpl Main10
                    jsr kernel.NextEvent
                    lda KEvent[kernel.event.type]
                    ; timer events
                    cmp #kernel.event.timer.EXPIRED
                    bne +
                        lda KEvent[kernel.results.timer_type.cookie]
                        cmp #Timers.COOKIES.SOF
                        bne ++
                            lda #255
                            sta FNX.VKY.BRDR_RED
                            jsr Viewport.WriteTileRegisters
                            jsr Actors.CopySpriteBufferToSpriteRegisters
                            stz FNX.VKY.BRDR_RED

                            lda #255
                            sta FNX.VKY.BRDR_GREEN
                            jsr Actors.Update
                            jsr SID.SIDPLAY ; play sid song
                            jsr PSG.UpdateChannels
                            stz FNX.VKY.BRDR_GREEN
;                            jsr Actors.Process

                            lda #255
                            sta FNX.VKY.BRDR_BLUE
                            jsr Viewport.Build
                            jsr HUD.UpdateEggTimer
;                            jsr HUD.TestAddEggsAndScore
                            stz FNX.VKY.BRDR_BLUE
                            lda #255
                            sta FNX.VKY.BRDR_RED

                            jsr Timers.ResetSOF
                            jsr DecreaseFreezeInput
                            jsr ParseCommonInput
//                        jsr Actors.ProcessNextActor
                            stz FNX.VKY.BRDR_RED
                            jmp Main10
                        ++
                    +
                    ; key pressed event
                    cmp #kernel.event.key.PRESSED
                    bne +
                        ; process key
                        lda KEvent[kernel.results.key_type.ascii]
                        cmp #KEYS.F3
                        bne ++
                            jsr Toggle_InputMode
;                            jsr Show_Input_Mode
                            jmp Main10
                        ++
                        cmp #'x'    ; 'x' to exit game
                        bne ++
                            lda #GAMEMODES.TITLE
                            sta GameMode
                            jmp Exit
                        ++
                        cmp #8      ; hard reset
                        bne ++
                            lda #-1
                            sta GameMode
                            jmp Exit
                        ++
                        cmp #'z'
                        bne ++
                            jsr ShowPlayerStats
                            jmp Main10
                        ++
                        jsr ScanCommonInputPressed
                        jmp Main10
                    +
                    ; key released event
                    cmp #kernel.event.key.RELEASED
                    bne +
                        ; process key
                        lda KEvent[kernel.results.key_type.ascii]
                        jsr ScanCommonInputReleased
                        jmp Main10
                    +
                    ; joystick event
                    cmp #kernel.event.JOYSTICK
                    bne +
                        lda #0
                        ldy Player.FreezeInputTimer+PLAYER1
                        bne ++
                            lda KEvent[kernel.results.joystick_type.joy0]
                        ++
                        sta JoyStates+PLAYER1

                        lda #0
                        ldy Player.FreezeInputTimer+PLAYER2
                        bne ++
                            lda KEvent[kernel.results.joystick_type.joy1]
                        ++
                        sta JoyStates+PLAYER2
                        jmp Main10
                    +
                    jmp Main10
        
            Exit:
            jsr Actors.ClearList
;            lda #Actors.STATE.DEAD
;            sta Actors.list.State+PLAYER1
;            sta Actors.list.State+PLAYER2
;            stz Actors.list.Process+PLAYER1
;            stz Actors.list.Process+PLAYER2
            jsr Viewport.Build
            jsr Actors.CopySpriteBufferToSpriteRegisters
            jsr SID.Reset
            jsr PSG.Init
            jsr WaitForKernalEvents
            rts
        endproc

    endsection

endnamespace
