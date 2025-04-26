STARTMUTE=$00; $00 ; $80

namespace Title
    section 'DATA'
        TX_Title        bytez 'BawkBawk CluckCluck'
        TX_Players      bytez 'Players: '
        TX_PressF1      bytez 'Press F1 to Toggle Players'
        TX_PressF3      bytez 'Press F3 to Toggle Keyboard/Joystick'
        TX_PressSpace   bytez 'Press Spacebar to Start Game'
        TX_ByLine       bytez 'by Norman Yen'
        TX_beethead     bytez 'beethead'
    endsection

    section 'CODE'
        
        proc Toggle_Players
            dec Players
            bne +
                lda #2
                sta Players
            +
            rts
        endproc
        
        proc Show_Player_Count
            lda Players
            ora #$10
            sta HUD.Map+(12+8*20)*2
            rts
        endproc

        proc Show_Input_Mode
            lda #HUD.KeyboardTile       ; keyboard
            ldx Player.InputMode+PLAYER1
            cpx #INPUTS.KEYBOARD0
            beq +
                lda #HUD.JoystickTile   ; joystick
            +
            .keyboard:
            sta HUD.Map+(19+0*20)*2
            rts
        endproc

        proc Show_Players
            lda #Actors.STATE.DEAD
            sta Actors.List.State+PLAYER1
            sta Actors.List.State+PLAYER2
            lda Players
            cmp #1
            beq +
                mwa #15*16+8,Actors.InitActor.xpos
                mwa #8*16+8,Actors.InitActor.ypos
                mwa #0,Actors.InitActor.xvel
                mwa #Actors.ChickenBrown.VELOCITY_FALL,Actors.InitActor.yvel
                ldx #1
                lda #Actors.ROLE.CHICKENBROWN
                ldy #Actors.FACING.LEFT
                jsr Actors.InitActorNumber
;                lda #Actors.ChickenBrown.STATE.FALL
;                jsr Actors.InitState
            +
                mwa #7*16,Actors.InitActor.xpos
                mwa #8*16+8,Actors.InitActor.ypos
                mwa #0,Actors.InitActor.xvel
                mwa #Actors.ChickenWhite.VELOCITY_FALL,Actors.InitActor.yvel
                ldx #0
                lda #Actors.ROLE.CHICKENWHITE
                ldy #Actors.FACING.RIGHT
                jsr Actors.InitActorNumber
;                lda #Actors.ChickenWhite.STATE.FALL
;                jsr Actors.InitState
            ++
            rts
        endproc

        proc Main
            ; clear all kernel events
            jsr WaitForKernalEvents
        
            display.Clear_Screen()
            vky.Mode_Set(ENABLE,TEXT,TEXTOVERLAY,GRAPHICS,SPRITES,TILES,400P,FONT1,DOUBLEX,DOUBLEY)
            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)
            display.Set_CursorPosition(#1,#24)
            display.Print_Text(#TX_Title)
;            display.Set_CursorPosition(#13,#15)
;            display.Print_Text(#TX_ByLine)
            display.Set_CursorPosition(#15,#17)
            display.Print_Text(#TX_Players)
            display.Set_CursorPosition(#6,#18)
            display.Print_Text(#TX_PressF1)
            display.Set_CursorPosition(#2,#19)
            display.Print_Text(#TX_PressF3)
            display.Set_CursorPosition(#5,#21)
            display.Print_Text(#TX_PressSpace)
            display.Set_CursorColor(#C64.LTRED,#C64.BLACK)
            display.Set_CursorPosition(#31,#24)
            display.Print_Text(#TX_beethead)
            display.Set_CursorColor(#C64.WHITE,#C64.BLACK)

            jsr PSG.Init
            jsr Actors.ClearList
            jsr HUD.Init
            lda #0
            jsr Stages.Init
            jsr Viewport.Init


            jsr ResetKeys
            jsr Show_Player_Count
            jsr Show_Players
            jsr Show_Input_Mode
            jsr SID.Reset

;            jsr Play_ChickWAV
;            jsr Play_ChickWAV
;            jsr Play_ChickWAV
            
;            -
;                lda FNX.RNG.DAT
;                lsr : lsr : lsr : lsr : lsr
;                cmp #SID.MAX_SONGS
;                bge -
            lda #3+STARTMUTE
            jsr SID.SIDINIT
            stz JoyStates+PLAYER1
            stz JoyStates+PLAYER2

            jsr Timers.ResetSOF

            Main10:
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
                            jsr Actors.CopySpriteBufferToSpriteRegisters
                            jsr Actors.Update
;                            ; play sid song
                            jsr SID.SIDPLAY
                            jsr PSG.UpdateChannels
                            jsr Viewport.Build
                            jsr Timers.ResetSOF
                            stz FNX.VKY.BRDR_RED
                            bra Main10
                        ++
                    +
                    ; key pressed event
                    cmp #kernel.event.key.PRESSED
                    bne +
                        ; process key
                        lda KEvent[kernel.results.key_type.ascii]
                        cmp #KEYS.F1
                        bne ++
                            jsr Toggle_Players
                            jsr Show_Player_Count
                            jsr Show_Players
                            jmp Main10
                        ++
                        cmp #KEYS.F3
                        bne ++
                            jsr Toggle_InputMode
                            jsr Show_Input_Mode
                            jmp Main10
                        ++
                        cmp #' '    ; spacebar to start game
                        bne ++
                            lda #GAMEMODES.INGAME
                            sta GameMode
                            jmp Exit
                        ++
                        cmp #8
                        beq .sameasexit
                        cmp #'x'    ; 'x' to exit game
                        bne ++
                        .sameasexit:
                            lda #GAMEMODES.EXIT
                            sta GameMode
                            jmp Exit
                        ++
                        jsr ScanCommonInputPressed
                        jsr Show_Input_Mode
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
                        lda KEvent[kernel.results.joystick_type.joy0]
                        sta JoyStates+PLAYER1
                        bit #FNX.JOY.BUT0
                        beq ++
                            lda #GAMEMODES.INGAME
                            sta GameMode
                            jmp Exit
                        ++
                        lda KEvent[kernel.results.joystick_type.joy1]
                        sta JoyStates+PLAYER2
                        bit #FNX.JOY.BUT0
                        beq ++
                            lda #GAMEMODES.INGAME
                            sta GameMode
                            jmp Exit
                        ++
                        jmp Main10
                    +
                    jmp Main10
        
            Exit:
            jsr SID.Reset
            jsr PSG.Init
            jsr WaitForKernalEvents
            rts
        endproc
    endsection
endnamespace
