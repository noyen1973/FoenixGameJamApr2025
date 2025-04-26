namespace ChickenWhite
    ;idle  $01,$02,$01,$03
    ;blink $04,$05
    ;walk  $06,$07,$08,$07
    ;fly   $09,$0a,$0b,$0c,$0d,$0e,$0d,$0c,$0b,$0a
//    const FRC=enum(SFX=$f9,LEFT=$fa,RIGHT=$fb,FLIP=$fc,STATE=$fd,LOOP=$fe,KILL=$ff)

    const   VELOCITY_WALK = 200 , 
            VELOCITY_FLY = 160 , 
            VELOCITY_FALL = 212 , 
            VELOCITY_FALLHURT = 500 ,
            FREEZEINPUTDELAY = 45
    section 'VRAMLEFT'
        LPCX=loadpcx('work\chicken_white.pcx',FLIPH)
        LData byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\chicken_white.pcx')
        RData byte RPCX
    endsection
    STATE=enum(DEAD=-1,IDLE,WALK,FLY,FALL,FALLH,DEATH)
    section 'DATA'
        Idle  byte FR32(1,60),FR32(2,10),FR32(1,60),FR32(3,10),FR32(1,60),FR32(2,10),FR32(1,60),FR32(3,10),FR32(4,60),FR32(5,5),FR32(4,10),FRC.LOOP,0
        Walk  byte FR32(7,6),FR32(8,6),FR32(7,6),FR32(6,6),FRC.LOOP,0
;        Walk  byte FR32(7,6),FRC.SFX,$ff,FR32(8,6),FR32(7,6),FR32(6,6),FRC.LOOP,0
        Fly   byte FR32(9,2),FRC.SFX,PSG.SFX.FlapWings,FR32(10,2),FR32(11,2),FR32(12,2),FR32(13,2),FR32(14,2),FR32(13,2),FR32(12,2),FR32(11,2),FR32(10,2),FRC.STATE,STATE.FALL
        Fall  byte FR32(9,3),FRC.SFX,PSG.SFX.FlapWings,FR32(10,3),FR32(11,3),FR32(12,3),FR32(13,3),FR32(14,3),FR32(13,3),FR32(12,3),FR32(11,3),FR32(10,3),FRC.LOOP,0
        FallH byte FR32(4,1),FRC.FLIP,FRC.SFX,PSG.SFX.BumpedSolid,FR32(4,8),FR32(5,9),FRC.FLIP,FR32(4,9),FRC.FLIP,FR32(5,9),FRC.FLIP,FRC.LOOP,0
        Death byte FR32(15,10),FRC.FLIP,FRC.LOOP,0
        StateAnimations word Idle,Walk,Fly,Fall,FallH,Death
    endsection
    section 'CODE'
        ;   Y = actor index, transfer to X
        proc SetXVelocityZero
            stz List.VelXSub,x
            stz List.VelXLo,x
            stz List.VelXHi,x
            rts
        endproc
        proc SetXVelocityLeft
            lda #<-VELOCITY_WALK
            sta List.VelXSub,x
            lda #>-VELOCITY_WALK
            sta List.VelXLo,x
            lda #`-VELOCITY_WALK
            sta List.VelXHi,x
            rts
        endproc
        proc SetXVelocityRight
            lda #<VELOCITY_WALK
            sta List.VelXSub,x
            lda #>VELOCITY_WALK
            sta List.VelXLo,x
            lda #`VELOCITY_WALK
            sta List.VelXHi,x
            rts
        endproc
        proc SetYVelocityZero
            stz List.VelYSub,x
            stz List.VelYLo,x
            stz List.VelYHi,x
            rts
        endproc
        proc SetYVelocityFly
            lda #<-VELOCITY_FLY
            sta List.VelYSub,x
            lda #>-VELOCITY_FLY
            sta List.VelYLo,x
            lda #`-VELOCITY_FLY
            sta List.VelYHi,x
            rts
        endproc
        proc SetYVelocityFall
            lda #<VELOCITY_FALL
            sta List.VelYSub,x
            lda #>VELOCITY_FALL
            sta List.VelYLo,x
            lda #`VELOCITY_FALL
            sta List.VelYHi,x
            rts
        endproc
        proc SetYVelocityFallHurt
            lda #<VELOCITY_FALLHURT
            sta List.VelYSub,x
            lda #>VELOCITY_FALLHURT
            sta List.VelYLo,x
            lda #`VELOCITY_FALLHURT
            sta List.VelYHi,x
            rts
        endproc
        proc PickupEgg
            phy
            lda #STATE.DEAD
            sta List.State,y
            lda #$01
            jsr HUD.AddEggs
            ldya #$00,#$10      ; 10 points
            jsr HUD.AddScore
            ply
            rts
        endproc
        proc PickupChick
            phy
            lda #STATE.DEAD
            sta List.State,y
            lda #$01
            jsr HUD.AddChicks
;            lda #0
;            sta List.Control,y
            ldya #$00,#$30      ; 30 points
            jsr HUD.AddScore
            ply
            rts
        endproc
        proc PickupHeart
            phy
            lda #STATE.DEAD
            sta List.State,y
            jsr HUD.AddHeart
            ldya #$01,#$00      ; 100 points
            jsr HUD.AddScore
            ply
            rts
        endproc
        proc KilledBySpikes
            lda #PSG.SFX.DeathMarch
            jsr PSG.PlaySFX
            lda #PSG.SFX.Spiked
            jsr HUD.MinusHeart
            jsr SetYVelocityZero
            lda List.Facing,x
            cmp #FACING.RIGHT
            beq .right
            .left:
                lda #STATE.DEATH
                jsr InitState
                jsr SetXVelocityRight
                rts
            .right:
                lda #STATE.DEATH
                jsr InitState
                jsr SetXVelocityLeft
                rts
        endproc
        proc SetStateFallHurt
            lda #PSG.SFX.BumpedSolid
            jsr PSG.PlaySFX
            lda #FREEZEINPUTDELAY
            sta Player.FreezeInputTimer,x
            jsr SetXVelocityZero
            jsr SetYVelocityFallHurt
            lda #STATE.FALLH
            jsr InitState
            rts
        endproc
        
//                    HITXMIN=$10,HITXMAX,HITYMIN,HITYMAX,
        proc DoStates
            tya
            tax
            lda List.Process,x
            cmp #PROCESS.HITYMIN
            bne +
                jsr SetStateFallHurt
                rts
            +
            cpx #MAX_PLAYERS
            blt player
            npc:
                rts
            player:
                lda List.Process,x
                cmp #PROCESS.HITXMIN
                bne +
                    stz List.Process,x
                    bra ++
                +
                cmp #PROCESS.HITXMAX
                bne +
                    stz List.Process,x
                    bra ++
                +

                ++
                ; these states are invincible
                lda List.State,x
                cmp #STATE.DEATH
                jeq DoDeath

                ; check actor collisions
                ldy #MAX_PLAYERS
                -
                    lda List.State,y
                    bmi +
                        jsr DetectCollision
                        bcc +
                            lda List.Role,y
                            cmp #ROLE.EGG
                            bne ++
                                jsr PickupEgg
                                bra +
                            ++
                            cmp #ROLE.HEART
                            bne ++
                                jsr PickupHeart
                                bra +
                            ++
                            cmp #ROLE.SPIKES
                            bne ++
                                jsr KilledBySpikes
                                bra +
                            ++
                            cmp #ROLE.CHICK
                            bne ++
                                jsr PickupChick
                                bra +
                            ++
                    +
                    iny
                    cpy #MAX_ACTORS
                    bne -
                    
                lda List.State,x
                cmp #STATE.IDLE
                jeq DoIdle
                cmp #STATE.WALK
                jeq DoWalk
                cmp #STATE.FLY
                jeq DoFly
                cmp #STATE.FALL
                jeq DoFall
                cmp #STATE.FALLH
                jeq DoFallHurt
;                cmp #STATE.DEATH
;                jeq DoDeath
                rts

            DoIdle:
                jsr SetYVelocityZero
                jsr GetEdgeBottomDecode
                ldy List.Facing,x
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                beq .onground
                cpy #FACING.RIGHT
                beq .faceright
                .faceleft:
                    cmp Edge.Right
                    beq .onground
                    jsr SetXVelocityLeft
                    bra .falling
                .faceright:
                    cmp Edge.Left
                    beq .onground
                    jsr SetXVelocityRight
                .falling:
                    jsr SetYVelocityFall
                    lda #STATE.FALL
                    jsr InitState
                    rts
                .onground:
                lda JoyStates,x
                bit #FNX.JOY.BUT0
                beq +
                    lda #STATE.FLY
                    jsr InitState
                    jsr SetYVelocityFly
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.LFT
                beq +
                    lda #FACING.LEFT
                    sta List.Facing,x
                    lda #STATE.WALK
                    jsr InitState
                    jsr SetXVelocityLeft
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.RGT
                beq +
                    lda #FACING.RIGHT
                    sta List.Facing,x
                    lda #STATE.WALK
                    jsr InitState
                    jsr SetXVelocityRight
                    rts
                +
                jsr SetXVelocityZero
                jsr SetYVelocityZero
                rts

            DoWalk:
                jsr SetYVelocityZero
                jsr GetEdgeBottomDecode
                ldy List.Facing,x
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                beq .onground
                cpy #FACING.RIGHT
                beq .faceright
                .faceleft:
                    cmp Edge.Right
                    beq .onground
                    jsr SetXVelocityLeft
                    bra .falling
                .faceright:
                    cmp Edge.Left
                    beq .onground
                    jsr SetXVelocityRight
                .falling:
                    jsr SetYVelocityFall
                    lda #STATE.FALL
                    jsr InitState
                    rts
                .onground:
                lda JoyStates,x
                bit #FNX.JOY.BUT0
                beq +
                    lda #STATE.FLY
                    jsr InitState
                    jsr SetYVelocityFly
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.LFT
                beq +
                    lda #FACING.LEFT
                    cmp List.Facing,x
                    beq ++
                        sta List.Facing,x
                        lda #STATE.WALK
                        jsr InitState
                    ++
                    jsr SetXVelocityLeft
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.RGT
                beq +
                    lda #FACING.RIGHT
                    cmp List.Facing,x
                    beq ++
                        sta List.Facing,x
                        lda #STATE.WALK
                        jsr InitState
                    ++
                    jsr SetXVelocityRight
                    rts
                +
                lda #STATE.IDLE
                jsr InitState
                jsr SetXVelocityZero
                jsr SetYVelocityZero
                rts
            DoFly:
                jsr SetYVelocityFly
                jsr GetEdgeTopDecode
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                bne +
                .hitsolid:
                    jsr SetStateFallHurt
                    rts
                +
                cmp Edge.Left
                beq .hitsolid
                cmp Edge.Right
                beq .hitsolid

                .flying:
                lda JoyStates,x
                bit #FNX.JOY.LFT
                beq +
                    lda #FACING.LEFT
                    sta List.Facing,x
                    jsr SetXVelocityLeft
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.RGT
                beq +
                    lda #FACING.RIGHT
                    sta List.Facing,x
                    jsr SetXVelocityRight
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.DWN
                beq +
                    lda #STATE.FALL
                    sta List.State,x
                    jsr SetYVelocityFall
                    rts
                +
                jsr SetXVelocityZero
                rts
            DoFall:
                jsr SetYVelocityFall

                jsr GetEdgeTopDecode
                ldy List.Facing,x
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                bne +
                .hitsolid:
                    jsr SetStateFallHurt
                    rts
                +
                cmp Edge.Left
                beq .hitsolid
                cmp Edge.Right
                beq .hitsolid

                jsr GetEdgeBottomDecode
                ldy List.Facing,x
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                bne .falling
;                cpy #FACING.RIGHT
;                beq .faceright
;                .faceleft:
                    cmp Edge.Right
                    beq .onground
;                    bne .falling
;                    bra .onground
;                .faceright:
                    cmp Edge.Left
                    bne .falling
                .onground:
                    lda #PSG.SFX.HitGround
                    jsr PSG.PlaySFX
                    jsr SetXVelocityZero
                    jsr SetYVelocityZero
                    lda #STATE.IDLE
                    jsr InitState
                    stz Player.FreezeInputTimer,x
                    ; realign to platform
                    lda List.PosYLo,x
                    and #%11110000
                    ora #%00000001
                    sta List.PosYLo,x
                    rts
                .falling:
                lda JoyStates,x
                bit #FNX.JOY.BUT0
                beq +
                    lda #STATE.FLY
                    jsr InitState
                    jsr SetYVelocityFly
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.LFT
                beq +
                    lda #FACING.LEFT
                    sta List.Facing,x
                    jsr SetXVelocityLeft
                    rts
                +
                lda JoyStates,x
                bit #FNX.JOY.RGT
                beq +
                    lda #FACING.RIGHT
                    sta List.Facing,x
                    jsr SetXVelocityRight
                    rts
                +
                jsr SetXVelocityZero
                rts
            DoFallHurt:
                jsr GetEdgeBottomDecode
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                bne .falling
                cmp Edge.Right
                beq .onground
;                bne .falling
                cmp Edge.Left
                bne .falling
                .onground:
                    lda #PSG.SFX.HitGround
                    jsr PSG.PlaySFX
                    jsr SetXVelocityZero
                    jsr SetYVelocityZero
                    lda #STATE.IDLE
                    jsr InitState
                    stz Player.FreezeInputTimer,x
                    ; realign to platform
                    lda List.PosYLo,x
                    and #%11110000
                    ora #%00000001
                    sta List.PosYLo,x
                    rts
                .falling:
                    lda Player.FreezeInputTimer,x
                    bne +
                        jsr SetYVelocityFall
                        lda #STATE.FALL
                        jsr InitState
                    +
                    rts
            DoDeath:
                lda List.DurationLo,x
                cmp #48
                beq .kill
                tay
                lda #<-VELOCITY_FALLHURT
                sta List.VelYSub,x
                lda #>-VELOCITY_FALLHURT
                sta List.VelYLo,x
                lda #`-VELOCITY_FALLHURT
                sta List.VelYHi,x
                rts
                .kill:
                    jsr SetStateFallHurt
                    lda Player.Health,x
                    bne +
                        stz List.Control,x
                        lda #STATE.DEAD
                        sta List.State,x
                    +
                    rts
        endproc

    endsection

endnamespace
