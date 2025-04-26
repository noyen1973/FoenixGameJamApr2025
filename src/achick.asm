namespace Chick
    ;idle  $01,$03
    ;walk  $01,$02,$01,$03,
    ;death $01,$04,$05,$06
    const   VELOCITY_WALK = 208 , 
            VELOCITY_FLY = 160 , 
            VELOCITY_FALL = 212 , 
            VELOCITY_FALLHURT = 500 ,
            VELOCITY_DEATH = -192 , 
            FREEZEINPUTDELAY = 45
    section 'VRAMLEFT'
        LPCX=loadpcx('work\chick.pcx',FLIPH)
        LData byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\chick.pcx')
        RData byte RPCX
    endsection
    STATE=enum(DEAD=-1,IDLE,WALK,FALL,DEATH)
    section 'DATA'
        Idle  byte FR16(1,9),FR16(3,9),FR16(1,10),FR16(3,11),FRC.FLIP,FRC.LOOP,0
        Walk  byte FR16(1,8),FR16(2,8),FR16(1,8),FR16(3,8),FRC.LOOP,0
        Fall  byte FR16(1,9),FR16(3,9),FR16(1,10),FR16(3,11),FRC.LOOP,0
        Death byte FR16(1,9),FRC.SFX,PSG.SFX.Chirp2,FR16(4,9),FR16(5,9),FR16(6,16),FRC.FLIP,FR16(6,12),FRC.FLIP,FR16(6,12),FRC.FLIP,FR16(6,8),FRC.FLIP,FR16(6,8),FRC.KILL
        StateAnimations word Idle,Walk,Fall,Death
    endsection
    section 'CODE'
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
        proc SetYVelocityDeath
            lda #<VELOCITY_DEATH
            sta List.VelYSub,x
            lda #>VELOCITY_DEATH
            sta List.VelYLo,x
            lda #`VELOCITY_DEATH
            sta List.VelYHi,x
            rts
        endproc

        proc DoStates
            tya
            tax

            lda List.State,x
            cmp #STATE.DEATH
            bne +
                rts
            +
            cmp #STATE.FALL
            bne +
                jsr GetEdgeBottomDecode
                ldy List.Facing,x
                lda #TILEDECODE.SOLID
                cmp Edge.Middle
                bne .falling
                cmp Edge.Right
                beq .hitground
                cmp Edge.Left
                bne .stillfalling
                .hitground:
                    lda #PSG.SFX.Chirp3
                    jsr PSG.PlaySFX
                    jsr SetXVelocityZero
                    jsr SetYVelocityZero
                    lda #STATE.IDLE
                    jsr InitState
                    ; realign to platform
                    lda List.PosYLo,x
                    and #%11110000
                    ora #%00000001
                    sta List.PosYLo,x
                .stillfalling:
                    rts
            +
;            jsr SetYVelocityZero
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
                jsr SetXVelocityZero
                jsr SetYVelocityFall
                lda #STATE.FALL
                jsr InitState
                rts
            .onground:
            lda List.DurationMd,x
            beq ++
            .makeadecision:
                lda FNX.RNG.DAT
            .makeadecision2:
                cmp #100
                bcc .goleft
                cmp #200
                bcc .goright
                cmp #220
                bcc .goidle
            .nochange:
                stz List.DurationLo,x
                stz List.DurationMd,x
                rts
            .goleft:
                lda #FACING.LEFT
                sta List.Facing,x
                jsr SetXVelocityLeft
                lda #STATE.WALK
                jsr InitState
                rts
            .goright:
                lda #FACING.RIGHT
                sta List.Facing,x
                jsr SetXVelocityRight
                lda #STATE.WALK
                jsr InitState
                rts
            .goidle:
                jsr SetXVelocityZero
                lda #STATE.IDLE
                jsr InitState
                rts
            +
            ; check actor collisions
            ldy #MAX_PLAYERS
            -
                lda List.State,y
                bmi +
                    lda List.Role,y
                    cmp #ROLE.EGG
                    bne ++
                    .checkcollision_turnaround:
                        jsr DetectCollision
                        bcc +
                            lda List.Facing,x
                            eor #1
                            lsr : ror : lsr
                            jmp .makeadecision2
                    ++
;                    cmp #ROLE.CHICK
;                    beq .checkcollision_turnaround
                    cmp #ROLE.SPIKES
                    bne ++
                    .checkcollision_dodeath:
                        jsr DetectCollision
                        bcc +
                            jsr SetYVelocityDeath
                            lda #STATE.DEATH
                            jsr InitState
                            rts
                    ++
                +
                iny
                cpy #MAX_ACTORS
                bne -
            rts
                
        endproc
        
    endsection
endnamespace
