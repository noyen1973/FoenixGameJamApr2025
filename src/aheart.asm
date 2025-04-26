namespace Heart
    ;idle  $01,$02,$01,$03
    ;hatch
    ;death
    STATE=enum(DEAD=-1,IDLE,DEATH)
    section 'VRAMLEFT'
        LPCX=loadpcx('work\heartlife.pcx',FLIPH)
        LData byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\heartlife.pcx')
;        RData byte RPCX
    endsection
    section 'DATA'
        Idle  byte FR16(1,60),FR16(2,10),FR16(1,10),FR16(3,10),FRC.LOOP,0
        Death byte FR16(1,60),FR16(2,10),FR16(1,10),FR16(3,10),FRC.KILL,0
        StateAnimations word Idle,Death
    endsection
    section 'CODE'
        proc DoStates
            rts
        endproc
    endsection
endnamespace
