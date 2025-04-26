
namespace PSG
    const   MAX_CHANNELS = 2 ,
            DEFAULT_DELAY = 4   ; 4=11khz, 2=22khz
    
    ; strips the vgm down to the raw bytes sent to the SN76489 per frame
    ; https://harmlesslion.com/sn_sfxr/
    ; raw vgm @ 11khz
    macro Add_SFX('aname',avgm) noscope
        s==avgm // vgm data
        o==''   // final output data
        d==''   // frame data
        repeat
            // get a command byte from vgm stream
            p==pos(' ' , s)
            if (p=0)
                ss==s
                s==''
            else
                ss==leftstr(s , p-1)
                s==copy(s , p+1)
            endif
            // data byte follows
            if (ss='50')
                // get a data byte from vgm stream
                p==pos(' ' , s)
                if (p=0)
                    d+=s
                    s==''
                else
                    d+=leftstr(s , p-1)
                    s==copy(s , p+1)
                endif
            // end of frame data
            elseif (ss='62')
                o+=hexstr(length(d)/2,2)+' '+d+' '
                d==''
            // end of vgm stream
            elseif (ss='66')
                s==''
            endif
        until (length(s) = 0)

        aname hex .. o .. 00
        SFX_LIST += ',aname'
    endmacro
    
    section 'DATA'
        Channel_Offset  byte    <FNX.PSG.LEFT, <FNX.PSG.RIGHT

        var SFX_LIST = ''

        ; https://harmlesslion.com/sn_sfxr/
        ; raw vgm @ 11khz
        ; arranged in order of priority
        Add_SFX(DeathMarch,
                '50 AA 50 04 50 BC 62 50 AD 50 03 50 B8 62 50 A3 50 03 50 B4 62 50 A1 50 04 50 B0 62 50 A9 50 04 50 B1 62 50 AA 50 03 50 B2 62 50 A4 50 03 50 B4 62 50 A0 50 04 50 B5 62 50 A3 50 04 50 B6 62 50 A3 50 03 50 B8 62 50 A2 50 03 50 B9 62 50 A2 50 04 50 BA 62 50 A1 50 04 50 BC 62 50 A2 50 03 50 BD 62 50 A5 50 03 50 BE 62 50 A4 50 04 50 BF 62 50 BF 66')
        Add_SFX(BumpedSolid,
                '50 CB 50 03 50 CC 62 50 C0 50 04 50 CF 62 50 CD 50 04 50 D2 62 50 C3 50 06 50 D5 62 50 CB 50 08 50 D9 62 50 C4 50 0D 50 DC 62 50 DF 66')
        Add_SFX(Spiked,
                '50 E7 50 CF 50 00 50 DF 50 F8 62 50 C0 50 03 50 DF 50 FA 62 50 C4 50 04 50 DF 50 FD 62 50 C4 50 04 50 DF 50 FF 62 50 FF 66')
        Add_SFX(EggCracking,
                '50 E7 50 C4 50 00 50 DF 50 EA 62 50 C2 50 00 50 DF 50 EE 62 50 C2 50 00 50 DF 50 F3 62 50 C3 50 00 50 DF 50 F7 62 50 C2 50 00 50 DF 50 FA 62 50 C1 50 00 50 DF 50 FD 62 50 FF 66')
        Add_SFX(PickupHeart,
                '50 8A 50 17 50 90 62 50 8D 50 34 50 90 62 50 88 50 13 50 93 62 50 8A 50 2B 50 97 62 50 82 50 10 50 9B 62 50 80 50 24 50 9E 62 50 9F 66')
        Add_SFX(TooManyHearts,
                '50 A4 50 3F 50 B0 62 50 A4 50 41 50 B2 62 50 AF 50 3D 50 B8 62 50 A7 50 42 50 BF 62 50 BF 66')
        Add_SFX(PickupChick,
                '50 88 50 01 50 8F 62 50 80 50 01 50 90 62 50 80 50 02 50 9A 62 50 9F 62 50 8F 50 02 50 90 62 50 85 50 04 50 96 62 50 86 50 06 50 9B 62 50 9F 66')
        Add_SFX(PickupEgg,
                '50 8B 50 04 50 92 62 50 85 50 04 50 93 62 50 85 50 04 50 94 62 50 85 50 04 50 95 62 50 85 50 04 50 96 62 50 85 50 04 50 98 62 50 85 50 04 50 99 62 50 85 50 04 50 9A 62 50 85 50 04 50 9B 62 50 85 50 04 50 9D 62 50 85 50 04 50 9E 62 50 85 50 04 50 9F 62 50 9F 66')
        Add_SFX(Go,
                '50 AC 50 17 50 B0 62 50 A9 50 17 50 BB 62 50 BF 66')
        Add_SFX(HitGround,
                '50 E7 50 C2 50 00 50 DF 50 F4 62 50 FF 66')
        Add_SFX(FlapWings,
                '50 E7 50 C3 50 00 50 DF 50 F5 62 50 FF 66')
        Add_SFX(Chirp1,
                '50 8E 50 02 50 95 62 50 8A 50 02 50 9B 62 50 9F 66')
        Add_SFX(Chirp2,
                '50 AC 50 03 50 B2 62 50 AC 50 06 50 B6 62 50 BF 66')
        Add_SFX(Chirp3,
                '50 8B 50 10 50 90 62 50 8F 50 3F 50 90 62 50 9F 66')

        const   SFX=enum(OFF=-1, .. copy(SFX_LIST,2) ..)

        SFX_PointersLo  byte <({{ copy(SFX_LIST,2) }})
        SFX_PointersHi  byte >({{ copy(SFX_LIST,2) }})

    endsection

    section 'BSS'
        Channel_Effect  resb MAX_CHANNELS,SFX.OFF
        Channel_Index   resb MAX_CHANNELS
        Channel_Delay   resb MAX_CHANNELS
        Next_Channel    resb 1
    endsection

    section 'CODE'
        proc UpdateChannels
            section 'ZPAGE'
                sfxsource resw 1
                sfxcount resb 1
            endsection
            
            ldx #0
            -
                ; check if channel has active effect, -1=inactive
                ldy Channel_Effect,x
                bmi .nextchannel
                    
                    ; check if delay is down to 0
                    lda Channel_Delay,x
                    bne .delaynotzero
                        lda SFX_PointersLo,y
                        sta sfxsource
                        lda SFX_PointersHi,y
                        sta sfxsource+1

                        ldy Channel_Index,x
                        lda (sfxsource),y   ; 00 length=end of vgm stream
                        beq .effectdone
                        sta sfxcount
                        iny
                        
                        lda Channel_Offset,x
                        phx
                            tax
                            --
                                lda (sfxsource),y
                                sta FNX.PSG.LEFT,x
                                iny
                                dec sfxcount
                                bne --
                        plx
                        tya
                        sta Channel_Index,x
                        
                        ; reset delay
                        lda #DEFAULT_DELAY+1

                    .delaynotzero:
                    dec
                    sta Channel_Delay,x

            .nextchannel:
                inx
                cpx #MAX_CHANNELS
                bne -
            rts

            .effectdone:
                lda #-1 ; disable channel effect
                sta Channel_Effect,x
                phx
                    lda Channel_Offset,x
                    tax
                    lda #%1.00.11111
                    sta FNX.PSG.LEFT,x
                    lda #%1.01.11111
                    sta FNX.PSG.LEFT,x
                    lda #%1.10.11111
                    sta FNX.PSG.LEFT,x
                    lda #%1.11.11111
                    sta FNX.PSG.LEFT,x
                plx
                bra .nextchannel
            
        endproc    
        
        ; parameters:
        ;   X   =   channel
        proc InitChannel
            phx
            lda Channel_Offset,x
            tax
            lda #%1.00.1.1111   ; volume off
            sta FNX.PSG.LEFT,x
            lda #%1.00.0.0000   ; 
            sta FNX.PSG.LEFT,x
            lda #0
            sta FNX.PSG.LEFT,x
            
            lda #%1.01.1.1111   ; volume off
            sta FNX.PSG.LEFT,x
            lda #%1.01.0.0000   ; 
            sta FNX.PSG.LEFT,x
            lda #0
            sta FNX.PSG.LEFT,x

            lda #%1.10.1.1111   ; volume off
            sta FNX.PSG.LEFT,x
            lda #%1.10.0.0000   ; 
            sta FNX.PSG.LEFT,x
            lda #0
            sta FNX.PSG.LEFT,x

            lda #%1.11.1.1111   ; volume off
            sta FNX.PSG.LEFT,x
            lda #%1.11.0.0000   ; 
            sta FNX.PSG.LEFT,x
            lda #0
            sta FNX.PSG.LEFT,x
            plx
            rts
        endproc
        
        proc Init
            ldx #0
            stx Next_Channel
            -
                lda #-1
                sta Channel_Effect,x
                stz Channel_Index,x
                stz Channel_Delay,x
                jsr InitChannel
                inx
                cpx #MAX_CHANNELS
                bne -
            rts
        endproc

        ; parameters:
        ;   A = sound effect
        proc PlaySFX
            section 'BSS'
                sfx word 0
            endsection
            ; check if disabled sound effect
            bit #$80
            beq +
                rts
            +
            phx
            phy
            sta sfx
            ldx #0
            -
                lda Channel_Effect,x
                bmi .foundfreechannel

                ; hijack channel if new sfx has higher priority
                cmp sfx
                bge .foundfreechannel
                
                inx
                cpx #MAX_CHANNELS
                bne -
            ; abort playing sound effect
            bra .exit

            ; no free channels, use next channel
            ldx Next_Channel
            
            .foundfreechannel:
            stz Channel_Index,x
            lda #DEFAULT_DELAY
            sta Channel_Delay,x
            lda sfx
            sta Channel_Effect,x
            jsr InitChannel
            stx Next_Channel
            
            ; alternate to next channel
            lda Next_Channel
            inc
            cmp #MAX_CHANNELS
            bne +
                lda #0
            +
            sta Next_Channel

            .exit:
            ply
            plx
            rts
        endproc
    endsection

endnamespace

