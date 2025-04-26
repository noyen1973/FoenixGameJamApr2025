namespace Egg
    ;idle  $01,$02,$01,$03
    ;hatch $03,$04,$05,$06,$07
    ;death
    section 'VRAMLEFT'
        LPCX=loadpcx('work\egg.pcx',FLIPH)
        LData byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\egg.pcx')
;        RData byte RPCX
    endsection
    section 'DATA'
        Idle  byte FR16(1,60),FR16(2,10),FR16(1,10),FR16(3,10),FRC.LOOP,0
        Hatch byte FR16(3,10),FRC.SFX,PSG.SFX.EggCracking,FR16(4,9),FR16(5,8),FR16(6,7),FR16(7,6),FRC.STATE,STATE.TRANSFORM
        Transform byte FR16(7,20),FRC.SFX,PSG.SFX.Chirp1,FRC.LOOP,0
        Death byte FR16(1,60),FR16(2,10),FR16(1,10),FR16(3,10),FRC.KILL,0
        StateAnimations word Idle,Hatch,Death
    endsection
    STATE=enum(DEAD=-1,IDLE,HATCH,TRANSFORM,DEATH)
    section 'CODE'
        proc DoStates
            lda EggTimerLo
            bne +
                lda EggTimerHi
                bne +
                    lda EggTimerSub
                    beq timerzero
            +
            rts
            ; time to hatch the egg
            timerzero:
                tya
                tax
                lda List.State,x
                cmp #STATE.TRANSFORM
                beq transform
                cmp #STATE.HATCH
                beq +
                    lda #STATE.HATCH
                    jsr InitState
                +
                rts
            transform:
                lda List.PosXLo,x
                sta InitActor.xpos
                lda List.PosXHi,x
                sta InitActor.xpos+1
                lda List.PosYLo,x
                sta InitActor.ypos
                lda List.PosYHi,x
                sta InitActor.ypos+1
                mwa #0,InitActor.xvel
                mwa #0,InitActor.yvel
                lda FNX.RNG.DAT
                and #1
                tay
                lda #ROLE.CHICK
                jsr InitActorNumber
                rts
        endproc
    endsection
endnamespace
