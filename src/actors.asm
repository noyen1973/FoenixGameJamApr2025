
section add('VRAMLEFT',$040000,$05ffff,size=-1,save=1)
endsection
section add('VRAMRIGHT',$060000,$07ffff,size=-1,save=1)
endsection

namespace Actors
    define FR8(aframe,adelay) adelay,<(LData+(aframe-1)*8*8),>(LData+(aframe-1)*8*8),`(LData+(aframe-1)*8*8)
    define FR16(aframe,adelay) adelay,<(LData+(aframe-1)*16*16),>(LData+(aframe-1)*16*16),`(LData+(aframe-1)*16*16)
    define FR24(aframe,adelay) adelay,<(LData+(aframe-1)*24*24),>(LData+(aframe-1)*24*24),`(LData+(aframe-1)*24*24)
    define FR32(aframe,adelay) adelay,<(LData+(aframe-1)*32*32),>(LData+(aframe-1)*32*32),`(LData+(aframe-1)*32*32)
    
    ; frame commands
    ;   SFX     =$f9    play psg sfx, next byte is sound effect
    ;   LEFT    =$fa    set facing left
    ;   RIGHT   =$fb    set facing right
    ;   FLIP    =$fc    flip facing direction
    ;   STATE   =$fd    change new state, next byte is STATE
    ;   LOOP    =$fe    loop animation, next byte is frame
    ;   KILL    =$ff    kill actor, set to dead -1
    const FRC=enum(SFX=$f9,LEFT=$fa,RIGHT=$fb,FLIP=$fc,STATE=$fd,LOOP=$fe,KILL=$ff)
    const FACING=enum(LEFT,RIGHT)
    const STATE=enum(DEAD=-1)

    const MAX_ACTORS = 64
    const TACTORSIZE = 16
    
    struct TRole(acontrol,aspritesize,
                    acollisiontop,acollisionbottom,acollisionleft,acollisionright,
                    aedgetop,aedgebottom,aedgeleft,aedgeright)
        Control     byte acontrol
        ColT        byte acollisiontop
        ColB        byte acollisionbottom
        ColL        byte acollisionleft
        ColR        byte acollisionright
        ColXMid     byte acollisionleft+(acollisionright-acollisionleft)/2
        ColYMid     byte acollisiontop+(acollisionbottom-acollisiontop)/2
        EdgeT       byte aedgetop
        EdgeB       byte aedgebottom
        EdgeL       byte aedgeleft
        EdgeR       byte aedgeright
        EdgeXMid    byte aedgeleft+(aedgeright-aedgeleft)/2
        EdgeYMid    byte aedgetop+(aedgebottom-aedgetop)/2
    endstruct

    var RoleList='', RoleHandlerList='', RoleStateAnimationsList='', RoleCount=0
    macro AddRole('arole',asourcefile,'ahandler',
                    acontrol,aspritesize,
                    acollisiontop,acollisionbottom,acollisionleft,acollisionright,
                    aedgetop,aedgebottom,aedgeleft,aedgeright) noscope
        RoleList+=',arole'
        RoleHandlerList+=',ahandler'
        RoleCount+=1
        arole TRole(acontrol,aspritesize,
                    acollisiontop,acollisionbottom,acollisionleft,acollisionright,
                    aedgetop,aedgebottom,aedgeleft,aedgeright)
        include asourcefile
        RoleStateAnimationsList+=',arole.StateAnimations'
    endmacro
    
    section 'DATA'
        FacingVRAMBanks byte `___VRAMLEFT_SECTION_BEGIN___,`___VRAMRIGHT_SECTION_BEGIN___
        WorkingSpriteBufferPointersLo byte <SpriteBuffer2,<SpriteBuffer1
        WorkingSpriteBufferPointersHi byte >SpriteBuffer2,>SpriteBuffer1

        Roles   AddRole(ChickenWhite,'achickenwhite.asm',ChickenWhite.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ32|SPRITE_LYIN01|SPRITE_LUT0,32,
                        10,31,5,26,
                        11,31,10,22)
                AddRole(ChickenBrown,'achickenbrown.asm',ChickenWhite.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ32|SPRITE_LYIN01|SPRITE_LUT1,32,
                        10,31,5,26,
                        11,31,10,22)
                AddRole(Chick,'achick.asm',Chick.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ16|SPRITE_LYIN01|SPRITE_LUT1,16,
                        4,15,3,12,
                        3,16,2,13)
        ; one sided images go after here
        ; remember to balance vramleft and vramright
        ; ***vramleft
                AddRole(Egg,'aegg.asm',Egg.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ16|SPRITE_LYIN01|SPRITE_LUT0,16,
                        2,15,2,14,
                        1,16,1,15)
                AddRole(Heart,'aheart.asm',Heart.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ16|SPRITE_LYIN01|SPRITE_LUT0,16,
                        1,14,1,15,
                        1,15,0,16)
                AddRole(Spikes,'aspikes.asm',Spikes.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ32|SPRITE_LYIN01|SPRITE_LUT0,32,
                        15,31,2,30,
                        15,31,2,30)
        ; vramright
                AddRole(Go,'ago.asm',Go.DoStates,
                        SPRITE_ENABLE|SPRITE_SZ32|SPRITE_LYIN01|SPRITE_LUT0,32,
                        0,0,0,0,
                        0,0,0,0)
        RolePointersLo byte <({{ copy(RoleList,2) }})
        RolePointersHi byte >({{ copy(RoleList,2) }})
        RoleStateAnimationsPointersLo byte <({{ copy(RoleStateAnimationsList,2) }})
        RoleStateAnimationsPointersHi byte >({{ copy(RoleStateAnimationsList,2) }})
        RoleStateHandlers word {{ copy(RoleHandlerList,2) }}
    endsection

    ROLE=enum( {{ upcase(copy(RoleList,2)) }} )
    print 'RoleCount=',RoleCount
    print 'Roles: ',upcase(copy(RoleList,2))
    
    PROCESS=enum(NONE=0,MOVE,
                    HITXMIN=$10,HITXMAX,HITYMIN,HITYMAX,
                    HITSPRLEFT=$20,HITSPRRIGHT,HITSPRTOP,HITSPRBOTTOM,
                    HITTILELEFT=$40,HITTILERIGHT,HITTILETOP,HITTILEBOTTOM)

    section add('SPRBUF',$001000,$0013ff,size=-1,type='bss')
        SpriteBuffer1 FNX.SPRITE_TYPE() dup vky.MAX_SPRITES
        SpriteBuffer2 FNX.SPRITE_TYPE() dup vky.MAX_SPRITES
    endsection
    section add('ACTORBSS',$001400,$001fff,size=-1,type='bss')

        ListStart:
        namespace List
            State resb MAX_ACTORS
            Role resb MAX_ACTORS
            Facing resb MAX_ACTORS
            Process resb MAX_ACTORS   ;0=ready,1=waiting to process move
            DurationLo resb MAX_ACTORS
            DurationMd resb MAX_ACTORS
            DurationHi resb MAX_ACTORS
            
            VelXSub resb MAX_ACTORS
            VelXLo resb MAX_ACTORS
            VelXHi resb MAX_ACTORS
            VelYSub resb MAX_ACTORS
            VelYLo resb MAX_ACTORS
            VelYHi resb MAX_ACTORS

            PosXSub resb MAX_ACTORS
            PosXLo resb MAX_ACTORS
            PosXHi resb MAX_ACTORS
            PosYSub resb MAX_ACTORS
            PosYLo resb MAX_ACTORS
            PosYHi resb MAX_ACTORS

            NewXSub resb MAX_ACTORS
            NewXLo resb MAX_ACTORS
            NewXHi resb MAX_ACTORS
            NewYSub resb MAX_ACTORS
            NewYLo resb MAX_ACTORS
            NewYHi resb MAX_ACTORS
            
            AniFrame resb MAX_ACTORS
            AniDelay resb MAX_ACTORS
            
            Control resb MAX_ACTORS
            VRAMLo resb MAX_ACTORS
            VRAMHi resb MAX_ACTORS
            VRAMBk resb MAX_ACTORS

            ColT        resb MAX_ACTORS
            ColB        resb MAX_ACTORS
            ColL        resb MAX_ACTORS
            ColR        resb MAX_ACTORS
            ColXMid     resb MAX_ACTORS
            ColYMid     resb MAX_ACTORS
            EdgeT       resb MAX_ACTORS
            EdgeB       resb MAX_ACTORS
            EdgeL       resb MAX_ACTORS
            EdgeR       resb MAX_ACTORS
            EdgeXMid    resb MAX_ACTORS
            EdgeYMid    resb MAX_ACTORS
        endnamespace
        ListEnd:

        ActiveSpriteBuffer resb 1   ; 0=buffer1, 1=buffer2
    endsection

    section 'CODE'
        proc ClearList
            mwa #ListStart,TempZ
            lda #0
            -
                sta (TempZ)
                incw TempZ
                cxwbne TempZ,#ListEnd,-
            ldx #0
            lda #STATE.DEAD
            -
                sta List.State,x
                inx
                cpx #MAX_ACTORS
                bne -
            stz ActiveSpriteBuffer
            ldx #0
            -
                stz SpriteBuffer1+$000,x
                stz SpriteBuffer1+$100,x
                stz SpriteBuffer2+$000,x
                stz SpriteBuffer2+$100,x
                inx
                bne -
            rts
        endproc
        
        proc CopySpriteBufferToSpriteRegisters
            ldx ActiveSpriteBuffer
            beq +
                dex
                ; spritebuffer2 active
                -
                    lda SpriteBuffer2+$000,x
                    sta FNX.VKY.SPRITES+$000,x
                    lda SpriteBuffer2+$100,x
                    sta FNX.VKY.SPRITES+$100,x
                    inx
                    bne -
                rts
            +
                ; spritebuffer1 active
                -
                    lda SpriteBuffer1+$000,x
                    sta FNX.VKY.SPRITES+$000,x
                    lda SpriteBuffer1+$100,x
                    sta FNX.VKY.SPRITES+$100,x
                    inx
                    bne -
                rts
        endproc
        
        proc Update
            section 'ACTORBSS'
                newxsub resb 1
                newxlo resb 1
                newxhi resb 1
                newysub resb 1
                newylo resb 1
                newyhi resb 1
                vrambank resb 1
            endsection
            virtual TempZ
                workz resw 1
                workz2 resw 1
            endvirtual
            
            ldx #0
            -
                lda List.State,x
                bmi +   ; inactive
                    dec List.AniDelay,x
                    bne ++
                        jsr Animate
                    ++
                    inc List.DurationLo,x
                    bne ++
                        inc List.DurationMd,x
                        bne ++
                            inc List.DurationHi,x
                            bne ++
                    ++
                    lda List.Process,x
                    bne ++   ; waiting to be processed
                        jsr Move
;                        jsr Deaccelerate
                    ++
                +
                inx
                cpx #MAX_ACTORS
                bne -
            rts

            Move:
                clc
                lda List.PosXSub,x
                adc List.VelXSub,x
                sta List.NewXSub,x
                lda List.PosXLo,x
                adc List.VelXLo,x
                sta List.NewXLo,x
                lda List.PosXHi,x
                adc List.VelXHi,x
                sta List.NewXHi,x

                clc
                lda List.PosYSub,x
                adc List.VelYSub,x
                sta List.NewYSub,x
                lda List.PosYLo,x
                adc List.VelYLo,x
                sta List.NewYLo,x
                lda List.PosYHi,x
                adc List.VelYHi,x
                sta List.NewYHi,x

                lda #PROCESS.MOVE
                sta List.Process,x
                rts
                
;            Deaccelerate:
;                rts
            Animate:
                ldy List.Facing,x
                lda FacingVRAMBanks,y
                sta vrambank
                ldy List.Role,x
                lda RoleStateAnimationsPointersLo,y
                sta workz
                lda RoleStateAnimationsPointersHi,y
                sta workz+1

            .trystate:
                lda List.State,x
                asl
                tay
                lda (workz),y
                sta workz2
                iny
                lda (workz),y
                sta workz2+1
                ldy List.AniFrame,x
            .tryframe:
                ; delay/command
                ; const FRC=enum(SFX=$f9,LEFT=$fa,RIGHT=$fb,FLIP=$fc,STATE=$fd,LOOP=$fe,KILL=$ff)
                lda (workz2),y
                cmp #$f8    ; check if a frame command
                blt .dodelay
                    cmp #FRC.SFX
                    beq .dosfx
                    cmp #FRC.LEFT
                    beq .doleft
                    cmp #FRC.RIGHT
                    beq .doright
                    cmp #FRC.FLIP
                    beq .doflip
                    cmp #FRC.STATE
                    beq .dostate
                    cmp #FRC.LOOP
                    beq .doloop
                    cmp #FRC.KILL
                    beq .dokill
            .dodelay:
                sta List.AniDelay,x
                ; lo
                iny
                lda (workz2),y
                sta List.VRAMLo,x
                ; hi
                iny
                lda (workz2),y
                sta List.VRAMHi,x
                ; bank
                iny
                lda (workz2),y
                ora vrambank
                sta List.VRAMBk,x
                iny
                tya
                sta List.AniFrame,x
                rts
            .doloop:
                iny
                lda (workz2),y
                tay
                bra .tryframe
            .doleft:
                lda #FACING.LEFT
                -
                sta List.Facing,x
                inc List.AniFrame,x
                bra Animate
            .doright:
                lda #FACING.RIGHT
                bra -
            .doflip:
                lda List.Facing,x
                eor #1
                bra -
            .dostate:
                iny
                lda (workz2),y
                sta List.State,x
                jsr InitState
                jmp Animate
            .dokill:
                lda #STATE.DEAD
                sta List.State,x
                stz List.Control,x
                lda List.Role,x
                cmp #ROLE.GO
                bne +
                    stz Go.onscreen
                +
                rts
            .dosfx:
                iny
                lda (workz2),y
                bpl +
                    lda FNX.RNG.DAT
                    and #7
                    cmp #3
                    bcs ++
                        adc #PSG.SFX.Chirp1
                +
                jsr PSG.PlaySFX
                ++
                iny
                jmp .tryframe
        endproc

        ;   A = role
        ;   X = actor number
        ;   Y = facing
        ;   InitActor.xpos  = XPos lo/hi
        ;   InitActor.ypos  = YPos lo/hi
        ;   InitActor.xvel  = XVelocity sub/lo need to adjust for negative
        ;   InitActor.yvel  = YVelocity sub/lo
        proc InitActorNumber
            sta InitActor.role
            sty InitActor.facing
            stz InitActor.state ; start as state 0, usually IDLE
            jmp InitActor.FoundActor
        endproc
        ;   A = state
        ;   X = actor number
        proc InitState
            phy
            sta List.State,x
            ldy List.Role,x
            lda RolePointersLo,y
            sta InitActor.rolez
            lda RolePointersHi,y
            sta InitActor.rolez+1
            ldy #TRole.ColT
            lda (InitActor.rolez),y
            sta List.ColT,x
            ldy #TRole.ColB
            lda (InitActor.rolez),y
            sta List.ColB,x
            ldy #TRole.ColL
            lda (InitActor.rolez),y
            sta List.ColL,x
            ldy #TRole.ColR
            lda (InitActor.rolez),y
            sta List.ColR,x
            ldy #TRole.ColXMid
            lda (InitActor.rolez),y
            sta List.ColXMid,x
            ldy #TRole.ColYMid
            lda (InitActor.rolez),y
            sta List.ColYMid,x
            ldy #TRole.EdgeT
            lda (InitActor.rolez),y
            sta List.EdgeT,x
            ldy #TRole.EdgeB
            lda (InitActor.rolez),y
            sta List.EdgeB,x
            ldy #TRole.EdgeL
            lda (InitActor.rolez),y
            sta List.EdgeL,x
            ldy #TRole.EdgeR
            lda (InitActor.rolez),y
            sta List.EdgeR,x
            ldy #TRole.EdgeXMid
            lda (InitActor.rolez),y
            sta List.EdgeXMid,x
            ldy #TRole.EdgeYMid
            lda (InitActor.rolez),y
            sta List.EdgeYMid,x
            ldy #TRole.Control
            lda (InitActor.rolez),y
            sta List.Control,x

            ldy List.Role,x
            lda RoleStateAnimationsPointersLo,y
            sta InitActor.rolez
            lda RoleStateAnimationsPointersHi,y
            sta InitActor.rolez+1
            stz List.AniFrame,x
            stz List.Process,x
            lda List.State,x
            asl
            tay
            lda (InitActor.rolez),y
            sta InitActor.rolez2
            iny
            lda (InitActor.rolez),y
            sta InitActor.rolez2+1
            ldy List.Facing,x
            lda FacingVRAMBanks,y
            sta InitActor.vrambank
            ldy #0  ; frame 0, offset 0 is delay
            lda (InitActor.rolez2),y
            sta List.AniDelay,x
            iny
            lda (InitActor.rolez2),y
            sta List.VRAMLo,x
            iny
            lda (InitActor.rolez2),y
            sta List.VRAMHi,x
            iny
            lda (InitActor.rolez2),y
            ora InitActor.vrambank
            sta List.VRAMBk,x
            iny
            tya
            sta List.AniFrame,x
            stz List.DurationLo,x
            stz List.DurationMd,x
            stz List.DurationHi,x
            ply
            rts
        endproc
        ;   A = role
        ;   X = state
        ;   Y = facing
        proc InitActor
            section 'ACTORBSS'
                role resb 1
                state resb 1
                facing resb 1
                vrambank resb 1
            endsection
            section 'ZPAGE'
                xpos resw 1
                ypos resw 1
                xvel resw 1
                yvel resw 1
                rolez resw 1
                rolez2 resw 1
            endsection
            
            sta role
            stx state
            sty facing
            ldx #MAX_PLAYERS
            -
                lda List.State,x
                bpl +
                    jsr FoundActor
                    clc
                    rts
                +
                inx
                cpx #MAX_ACTORS
                bne -
            ; no free actor slots
            sec
            rts

            ; init actor data
            FoundActor:
                lda role
                sta List.Role,x
                lda facing
                sta List.Facing,x
                lda state
                jsr InitState

                lda xpos
                sta List.PosXLo,x
                lda xpos+1
                sta List.PosXHi,x
                stz List.PosXSub,x
                lda ypos
                sta List.PosYLo,x
                lda ypos+1
                sta List.PosYHi,x
                stz List.PosYSub,x

                lda xvel
                sta List.VelXSub,x
                ldy #0
                lda xvel+1
                sta List.VelXLo,x
                bpl +
                    ldy #$ff
                +
                tya
                sta List.VelXHi,x
                lda yvel
                sta List.VelYSub,x
                ldy #0
                lda yvel+1
                sta List.VelYLo,x
                bpl +
                    ldy #$ff
                +
                tya
                sta List.VelYHi,x
                
                lda #PROCESS.NONE
                sta List.Process,x
            clc
            rts
        endproc


        proc ResetLastActorProcess
            lda #MAX_PLAYERS
            sta ProcessNextActor.lastactor
            rts
        endproc
        
        ;   X = actor number
        proc ProcessNextActor
            section 'ACTORBSS'
                lastactor resb 1
            endsection

            ldx lastactor
            jsr ProcessActorNumber
            inx
            cpx #MAX_ACTORS
            bne +
                ldx #MAX_PLAYERS
            +
            stx lastactor
            rts
        endproc
        
        proc ProcessActorNumber
            section 'ACTORBSS'
                process resb 1
;                lastactor resb 1
            endsection
            
            lda List.State,x
            bmi +   ; inactive
                lda List.Process,x
                beq ++
                    jsr .doprocess
                ++
                phx
                jsr .dostatehandler
                plx
            +
            rts
            
            .dostatehandler:
                txa
                tay
                lda List.Role,x
                asl
                tax
                jmp (RoleStateHandlers,x)
                
            .doprocess:
                ; get collision
                ; check on platform

                ; commit new position
                cmp #PROCESS.MOVE
                bne +
                    jsr .domove
                    lda List.Process,x
                +
                cpx #MAX_PLAYERS
                bge .npcplayer
                    rts
            .npcplayer:
                cmp #PROCESS.HITXMIN
                bne +
                    .flipdirectionandvelocity:
                    lda List.Facing,x
                    eor #1
                    sta List.Facing,x
                    lda List.VelXSub,x
                    eor #$ff
                    sta List.VelXSub,x
                    lda List.VelXLo,x
                    eor #$ff
                    sta List.VelXLo,x
                    lda List.VelXHi,x
                    eor #$ff
                    sta List.VelXHi,x
                    inc List.VelXSub,x
                    bne ++
                        inc List.VelXLo,x
                        bne ++
                            inc List.VelXHi,x
                            bne ++
                    ++
                    stz List.Process,x
                    rts
                +
                cmp #PROCESS.HITXMAX
                bne +
                    bra .flipdirectionandvelocity
                +
                cmp #PROCESS.HITYMIN
                bne +
                    stz List.Process,x
                    rts
                +
                cmp #PROCESS.HITYMAX
                bne +
                    stz List.Process,x
                    rts
                +
                rts
                
            .domove:
                stz process
                ldy List.NewXLo,x
                cpy Stages.MinMainXPos  ;#<32
                lda List.NewXHi,x
                sbc Stages.MinMainXPos+1    ;#>32
                bge +
                    lda Stages.MinMainXPos
                    sta List.NewXLo,x
                    lda Stages.MinMainXPos+1
                    sta List.NewXHi,x
                    lda #PROCESS.HITXMIN
                    bra ++
                +
                cpy Stages.MaxMainXPos
                lda List.NewXHi,x
                sbc Stages.MaxMainXPos+1
                blt +
                    lda Stages.MaxMainXPos
                    sta List.NewXLo,x
                    lda Stages.MaxMainXPos+1
                    sta List.NewXHi,x
                    lda #PROCESS.HITXMAX
                    ++
                    sta process
                    stz List.NewXSub,x
                +
                ldy List.NewYLo,x
                cpy Stages.MinMainYPos
                lda List.NewYHi,x
                sbc Stages.MinMainYPos+1
                bge +
                    lda Stages.MinMainYPos
                    sta List.NewYLo,x
                    lda Stages.MinMainYPos+1
                    sta List.NewYHi,x
                    lda #PROCESS.HITYMIN
                    bra ++
                +
                cpy Stages.MaxMainYPos
                lda List.NewYHi,x
                sbc Stages.MaxMainYPos+1
                blt +
                    lda Stages.MaxMainYPos
                    sta List.NewYLo,x
                    lda Stages.MaxMainYPos+1
                    sta List.NewYHi,x
                    lda #PROCESS.HITYMAX
                    ++
                    sta process
                    stz List.NewYSub,x
                +

                cpx #MAX_PLAYERS
                bge +
                    ; calculate vp minx/maxx
                    clc
                    adcw Viewport.XPos,#Viewport.WindowX,vpminx
                    clc
                    adcw Viewport.XPos,#(Viewport.Width-Viewport.WindowX),vpmaxx
                    jsr Check_Player_XPositions
                    bcs ++
                +
                lda List.NewXSub,x
                sta List.PosXSub,x
                lda List.NewXLo,x
                sta List.PosXLo,x
                lda List.NewXHi,x
                sta List.PosXHi,x
                
                ++
                cpx #MAX_PLAYERS
                bge +
                    ; calculate vp miny/maxy
                    clc
                    adcw Viewport.YPos,#Viewport.WindowY,vpminy
                    clc
                    adcw Viewport.YPos,#(Viewport.Height-Viewport.WindowY),vpmaxy
                    jsr Check_Player_YPositions
                    bcs ++
                +
                lda List.NewYSub,x
                sta List.PosYSub,x
                lda List.NewYLo,x
                sta List.PosYLo,x
                lda List.NewYHi,x
                sta List.PosYHi,x
                ++
                lda process
                sta List.Process,x
                rts

            section 'ACTORBSS'
                vpminx resw 1
                vpmaxx resw 1
                vpminy resw 1
                vpmaxy resw 1
            endsection

            ; check horizontal movement
            Check_Player_XPositions:
                ; calculate offset to alternate player
                txa
                eor #1
                tay
            
                lda List.VelXHi,x
                bpl .right
                .left:
                    lda List.NewXLo,x
                    cmp vpminx
                    lda List.NewXHi,x
                    sbc vpminx+1
                    bge +
                        ; check if other player is out of bounds
                        lda List.State,y
                        bmi ++
                            lda List.PosXLo,y
                            cmp vpmaxx
                            lda List.PosXHi,y
                            sbc vpmaxx+1
                            bge .other_player_out_of_bounds
                        ++
                        jsr Viewport.ScrollLeft
                    +
                    clc
                    rts
                .right:
                    lda List.NewXLo,x
                    cmp vpmaxx
                    lda List.NewXHi,x
                    sbc vpmaxx+1
                    blt +
                        ; check if other player is out of bounds
                        lda List.State,y
                        bmi ++
                            lda List.PosXLo,y
                            cmp vpminx
                            lda List.PosXHi,y
                            sbc vpminx+1
                            blt .other_player_out_of_bounds
                        ++
                        jsr Viewport.ScrollRight
                    +
                    clc
                    rts
                .other_player_out_of_bounds:
                    jsr Go.Add
                    sec
                    rts
                
            ; check vertical movement
            Check_Player_YPositions:
                ; calculate offset to alternate player
                txa
                eor #1
                tay

                lda List.VelYHi,x
                bpl .down
                .up:
                    lda List.NewYLo,x
                    cmp vpminy
                    lda List.NewYHi,x
                    sbc vpminy+1
                    bge +
                        ; check if other player is out of bounds
                        lda List.State,y
                        bmi ++
                            lda List.PosYLo,y
                            cmp vpmaxy
                            lda List.PosYHi,y
                            sbc vpmaxy+1
                            bge .other_player_out_of_bounds
                        ++
                        jsr Viewport.ScrollUp
                    +
                    clc
                    rts

                .down:
                    lda List.NewYLo,x
                    cmp vpmaxy
                    lda List.NewYHi,x
                    sbc vpmaxy+1
                    blt +
                        ; check if other player is out of bounds
                        lda List.State,y
                        bmi ++
                            lda List.PosYLo,y
                            cmp vpminy
                            lda List.PosYHi,y
                            sbc vpminy+1
                            bge .other_player_out_of_bounds
                        ++
                        jsr Viewport.ScrollDown
                    +
                ++
                clc
                rts
            .other_player_out_of_bounds:
                jsr Go.Add
                sec
                rts
        endproc


        macro CalcCollisionToY(aleftmidright)
            clc
            lda List.PosXLo,x
            adc List.aleftmidright,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosXHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
        endmacro

        namespace Edge
            section 'ACTORBSS'
                Top resb 1
                Left resb 1
                Middle resb 1
                Right resb 1
                Bottom resb 1
                tempy resb 1
                TopOfs resb 1
                LeftOfs resb 1
                MiddleOfs resb 1
                RightOfs resb 1
                BottomOfs resb 1
                TopLine resb 1
                MiddleLine resb 1
                BottomLine resb 1
                virtual TempZ+12
                endvirtual
            endsection
            section 'ZPAGE'
                decodeptr resw 1
                TopPtr resw 1
                MiddlePtr resw 1
                BottomPtr resw 1
            endsection
        endnamespace
        
        ;   X = actor
        proc GetEdgeBottomDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to bottom
            clc
            lda List.PosYLo,x
            adc List.EdgeB,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.BottomPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.BottomPtr+1
            sty Edge.BottomLine
            
            ; get edgel
            CalcCollisionToY(EdgeL)
            lda (Edge.decodeptr),y
            sta Edge.Left
            sty Edge.LeftOfs
            
            ; get edgexmid
            CalcCollisionToY(EdgeXMid)
            lda (Edge.decodeptr),y
            sta Edge.Middle
            sty Edge.MiddleOfs
            ; get edger
            CalcCollisionToY(EdgeR)
            lda (Edge.decodeptr),y
            sta Edge.Right
            sty Edge.RightOfs
            rts
        endproc

        ;   X = actor
        proc GetEdgeTopDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to top
            clc
            lda List.PosYLo,x
            adc List.EdgeT,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.TopPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.TopPtr+1
            sty Edge.TopLine
            
            ; get edgel
            CalcCollisionToY(EdgeL)
            lda (Edge.decodeptr),y
            sta Edge.Left
            sty Edge.LeftOfs
            
            ; get edgexmid
            CalcCollisionToY(EdgeXMid)
            lda (Edge.decodeptr),y
            sta Edge.Middle
            sty Edge.MiddleOfs
            ; get edger
            CalcCollisionToY(EdgeR)
            lda (Edge.decodeptr),y
            sta Edge.Right
            sty Edge.RightOfs
            rts
        endproc

        ;   X = actor
        proc GetEdgeLeftDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to top
            clc
            lda List.PosYLo,x
            adc List.EdgeT,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.TopPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.TopPtr+1
            sty Edge.TopLine
            
            ; get edgel
            CalcCollisionToY(EdgeL)
            lda (Edge.decodeptr),y
            sta Edge.Top
            sty Edge.tempy
            sty Edge.LeftOfs
            ; get pointer to middle
            clc
            lda List.PosYLo,x
            adc List.EdgeYMid,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.MiddlePtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.MiddlePtr+1
            sty Edge.MiddleLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Middle

            ; get pointer to bottom
            clc
            lda List.PosYLo,x
            adc List.EdgeB,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.BottomPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.BottomPtr+1
            sty Edge.BottomLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Bottom
            rts
        endproc

        ;   X = actor
        proc GetEdgeRightDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to top
            clc
            lda List.PosYLo,x
            adc List.EdgeT,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.TopPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.TopPtr+1
            sty Edge.TopLine
            
            ; get edger
            CalcCollisionToY(EdgeR)
            lda (Edge.decodeptr),y
            sta Edge.Top
            sty Edge.tempy
            sty Edge.RightOfs
            
            ; get pointer to middle
            clc
            lda List.PosYLo,x
            adc List.EdgeYMid,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.MiddlePtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.MiddlePtr+1
            sty Edge.MiddleLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Middle

            ; get pointer to bottom
            clc
            lda List.PosYLo,x
            adc List.EdgeB,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.BottomPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.BottomPtr+1
            sty Edge.BottomLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Bottom
            rts
        endproc

        ;   X = actor
        proc GetCollisionLeftDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to top
            clc
            lda List.PosYLo,x
            adc List.ColT,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.TopPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.TopPtr+1
            sty Edge.TopLine
            
            ; get edgel
            CalcCollisionToY(ColL)
            lda (Edge.decodeptr),y
            sta Edge.Top
            sty Edge.tempy
            sty Edge.LeftOfs
            
            ; get pointer to middle
            clc
            lda List.PosYLo,x
            adc List.ColYMid,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.MiddlePtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.MiddlePtr+1
            sty Edge.MiddleLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Middle

            ; get pointer to bottom
            clc
            lda List.PosYLo,x
            adc List.ColB,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.BottomPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.BottomPtr+1
            sty Edge.BottomLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Bottom
            rts
        endproc

        ;   X = actor
        proc GetCollisionRightDecode
            ; setup math divider
            mwa #16,FNX.MATH.UDIV_DEM

            ; get pointer to top
            clc
            lda List.PosYLo,x
            adc List.ColT,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.TopPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.TopPtr+1
            sty Edge.TopLine
            
            ; get edger
            CalcCollisionToY(ColR)
            lda (Edge.decodeptr),y
            sta Edge.Top
            sty Edge.tempy
            sty Edge.RightOfs
            
            ; get pointer to middle
            clc
            lda List.PosYLo,x
            adc List.ColYMid,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.MiddlePtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.MiddlePtr+1
            sty Edge.MiddleLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Middle

            ; get pointer to bottom
            clc
            lda List.PosYLo,x
            adc List.ColB,x
            sta FNX.MATH.UDIV_NUM
            lda List.PosYHi,x
            adc #0
            sta FNX.MATH.UDIV_NUM+1
            ldy FNX.MATH.UDIV_QUO
            lda Stages.DecodeOffsetsLo,y
            sta Edge.decodeptr
            sta Edge.BottomPtr
            lda Stages.DecodeOffsetsHi,y
            sta Edge.decodeptr+1
            sta Edge.BottomPtr+1
            sty Edge.BottomLine
            
            ldy Edge.tempy
            lda (Edge.decodeptr),y
            sta Edge.Bottom
            rts
        endproc

        ;   X = actor number A
        ;   Y = actor number B
        ; returns:
        ;   [carry] clear=no nollision
        ;           set = collision
        proc DetectCollision
            section 'BSS'
                topA resw 1
                bottomA resw 1
                leftA resw 1
                rightA resw 1
                topB resw 1
                bottomB resw 1
                leftB resw 1
                rightB resw 1
            endsection

            ; sprite A top/bottom/left/right
            clc
            lda List.PosYLo,x
            adc List.ColT,x
            sta topA
            lda List.PosYHi,x
            adc #0
            sta topA+1
            clc
            lda List.PosYLo,x
            adc List.ColB,x
            sta bottomA
            lda List.PosYHi,x
            adc #0
            sta bottomA+1
            clc
            lda List.PosXLo,x
            adc List.ColL,x
            sta leftA
            lda List.PosXHi,x
            adc #0
            sta leftA+1
            clc
            lda List.PosXLo,x
            adc List.ColR,x
            sta rightA
            lda List.PosXHi,x
            adc #0
            sta rightA+1
            ; sprite B top/bottom/left/right
            clc
            lda List.PosYLo,y
            adc List.ColT,y
            sta topB
            lda List.PosYHi,y
            adc #0
            sta topB+1
            clc
            lda List.PosYLo,y
            adc List.ColB,y
            sta bottomB
            lda List.PosYHi,y
            adc #0
            sta bottomB+1
            clc
            lda List.PosXLo,y
            adc List.ColL,y
            sta leftB
            lda List.PosXHi,y
            adc #0
            sta leftB+1
            clc
            lda List.PosXLo,y
            adc List.ColR,y
            sta rightB
            lda List.PosXHi,y
            adc #0
            sta rightB+1
            
            cwbge topA,bottomB,.nocollision
            cwblt bottomA,topB,.nocollision
            cwbge leftA,rightB,.nocollision
            cwblt rightA,leftB,.nocollision
            
            .collision:
            sec
            rts
            
            .nocollision:
            clc
            rts
        endproc

    endsection

endnamespace
