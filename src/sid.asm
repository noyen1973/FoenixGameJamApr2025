    
section add('SID1',$010000,$017FFF,size=-1,save=1)
        SIDFILE1 incbin 'sound\foll.sid',$7e
endsection
section add('SID2',$012000,$017FFF,size=-1,save=1)
        SIDFILE2 incbin 'sound\homer.sid',$7e
endsection
section add('SID3',$014000,$017FFF,size=-1,save=1)
        SIDFILE3 incbin 'sound\mask.sid',$7e
endsection
section add('SID4',$016000,$017FFF,size=-1,save=1)
        SIDFILE4 incbin 'sound\child.sid',$7e
endsection
section add('SID5',$018000,$019FFF,size=-1,save=1)
        SIDFILE5 incbin 'sound\cowboy.sid',$7e
endsection
section add('SID6',$01A000,$01BFFF,size=-1,save=1)
        SIDFILE6 incbin 'sound\inbr.sid',$7e
endsection

namespace SID
    section 'DATA'
        var MAX_SONGS = 0
        struct TSID(asong,asidfile,asubtune,ainit,aplay,adelay)
            MMUSlot byte asidfile/$2000
            Subtune byte asubtune
            Init    word ainit
            Play    word aplay
            Delay   byte adelay
            MAX_SONGS == asong+1
        endstruct align 8
        SongList    TSID(0,SIDFILE1,0,$a000,$a003,4,'Follin N Rollin')
                    TSID(1,SIDFILE2,0,$a000,$a003,4,'Homer the Runzi')
                    TSID(2,SIDFILE3,0,$a000,$a003,4,'Sir Duke')
                    TSID(3,SIDFILE3,2,$a000,$a003,4,'Chicken Dance')
                    TSID(4,SIDFILE3,3,$a000,$a003,4,'HillBilly?')
                    TSID(5,SIDFILE4,0,$a8ea,$a4ea,3,'Children Songs')
                    TSID(6,SIDFILE5,0,$a000,$a003,4,'O Susanna')
                    TSID(7,SIDFILE5,1,$a000,$a003,4,'Yankee Doodle')
                    TSID(8,SIDFILE5,2,$a000,$a003,4,'Dixie')
                    TSID(9,SIDFILE6,1,$a000,$a003,5,'Inbread')
    endsection

    section 'BSS'
        CurrentSong resb 1
        Frame resb 1
        Duration dword 0
    endsection
    
    section 'CODE'

        proc Reset
            lda #0
            ldx #0
            -
                sta FNX.SID.BOTH,x
                inx
                cpx #24
                bne -
            lda FNX.SYS.SYS1
            and #%11110011
            sta FNX.SYS.SYS1
            rts
        endproc
    
        ;   A = song
        proc SIDINIT
            ldx CurrentSong
            phx
            sta CurrentSong
            and #127
            asl : asl : asl ;*8
            tax
            lda SongList+TSID.MMUSlot,x
            jsr MapBSSBank
            lda SongList+TSID.Subtune,x
            jsr DoInit
            jsr UnmapBSSBank
            stz Frame
            stz Duration+0
            stz Duration+1
            stz Duration+2
            stz Duration+3
            pla
            bpl +
                lda CurrentSong
                ora #$80
                sta CurrentSong
            +
            rts
            DoInit:
                jmp (SongList+TSID.Init,x)
        endproc

        proc SIDPLAY
            lda CurrentSong
            bmi .exit   ; negative song number means paused
                asl : asl : asl ;*8
                tax
                inc Frame
                lda Frame
                cmp SongList+TSID.Delay,x
                bne +
                    stz Frame
                    rts
                +
                lda SongList+TSID.MMUSlot,x
                jsr MapBSSBank
                jsr DoPlay
                jsr UnmapBSSBank
            .exit:
                inc Duration+0
                bne +
                    inc Duration+1
                    bne +
                        inc Duration+2
                        bne +
                            inc Duration+3
                +
            rts
            DoPlay:
                jmp (SongList+TSID.Play,x)
        endproc
        
        proc Toggle_Pause
            lda CurrentSong
            eor #128
            sta CurrentSong
            bpl +
                stz FNX.SID.LEFT+24
            +
            rts
        endproc
    endsection
    
endnamespace

