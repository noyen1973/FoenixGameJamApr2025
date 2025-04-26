;   $01,$02,$03,$04,$03,$02,$01
namespace Go
    ;idle  $01
    STATE=enum(DEAD=-1,IDLE)
    section 'VRAMLEFT'
        LPCX=loadpcx('work\go!.pcx',FLIPH)
        LData=RDATA ; byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\go!.pcx')
        RData byte RPCX
    endsection
    section 'DATA'
        Idle  byte FR32(1,4),FR32(2,6),FR32(3,8),FR32(4,10),FR32(3,8),FR32(2,6),FR32(1,4),FRC.KILL
        StateAnimations word Idle
    endsection
    section 'BSS'
        onscreen resb 1
    endsection
    section 'CODE'
        proc DoStates
            rts
        endproc

        proc Init
            stz onscreen
            rts
        endproc
        
        ;   Y = target actor being told to GO!
        proc Add
            lda onscreen
            bne .exit

                phx
                phy
                lda #PSG.SFX.Go
                jsr PSG.PlaySFX
                ;   A = role
                ;   X = actor number
                ;   Y = facing
                clc
                lda List.PosXLo,y       ; xpos
                adc #<16
                sta InitActor.xpos
                lda List.PosXHi,y
                adc #>16
                sta InitActor.xpos+1
                sec
                lda List.PosYLo,y       ; ypos
                sbc #<24
                sta InitActor.ypos
                lda List.PosYHi,y
                sbc #>24
                sta InitActor.ypos+1
                mwa #-208,InitActor.xvel    ; xvelocity
                mwa #224,InitActor.yvel     ; yvelocity
                lda #ROLE.GO
                ldx #STATE.IDLE
                ldy #FACING.RIGHT       ; right=1
                jsr InitActor
                lda #1
                sta onscreen
                ply
                plx
            .exit:
            rts
        endproc
    endsection
endnamespace
