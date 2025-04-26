namespace Spikes
    ;idle  $01,$02,$03,$01,$04,$01,$05,$01
    STATE=enum(DEAD=-1,IDLE)
    section 'VRAMLEFT'
        LPCX=loadpcx('work\spikes.pcx',FLIPH)
        LData byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\spikes.pcx')
        RData=LDATA ; byte RPCX
    endsection
    section 'DATA'
        Idle  byte FR32(1,7),FR32(2,9),FR32(3,6),FR32(1,8),FR32(4,5),FR32(1,10),FR32(5,6),FR32(1,7),FRC.LOOP,0
        StateAnimations word Idle
    endsection
    section 'CODE'
        proc DoStates
            rts
        endproc
    endsection
endnamespace
