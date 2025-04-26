namespace ChickenBrown
    ;idle  $01,$02,$01,$03
    ;blink $04,$05
    ;walk  $06,$07,$08,$07
    ;fly   $09,$0a,$0b,$0c,$0d,$0e,$0d,$0c,$0b,$0a

    const   VELOCITY_WALK = 200 , 
            VELOCITY_FLY = 160 , 
            VELOCITY_FALL = 212 , 
            VELOCITY_FALLHURT = 500 ,
            FREEZEINPUTDELAY = 60*2
    section 'VRAMLEFT'
        LPCX=loadpcx('work\chicken_brown.pcx',FLIPH)
        LData = Actors.ChickenWhite.LData ; byte LPCX
    endsection
    section 'VRAMRIGHT'
        RPCX=loadpcx('work\chicken_brown.pcx')
        RData = Actors.ChickenWhite.RData ; byte RPCX
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
endnamespace
