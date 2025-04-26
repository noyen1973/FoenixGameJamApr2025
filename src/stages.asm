////////// stages.asm

; actual maximum stage tile width and height are 126 & 62
; first column and line are filled with solid decode tile
const MAX_TILEWIDTH = 128 , MAX_TILEHEIGHT = 64
const TILEDECODE=enum(  EMPTY,SOLID,VIEWPORT,EXIT,WATER,HURT,DEATH,
                        EGG=8,HEART,
                        CHICKENWHITEL=16,CHICKENWHITER,
                        CHICKENBROWNL,CHICKENBROWNR,
                        CHICKL,CHICKR,
                        PIGSPEARL,PIGSPEARR,
                        SPIKES)
; all backgrounds use tileset #2 and clut #5
const BKGTSET = 2 , BKGCLUT = 3
const MAINTSET = 1 , MAINCLUT = 2
const FONTTSET = 0 , FONTCLUT = 0

; reserved memory area for the current stage main map and hud map
section add('VRAMSTAGE',$01c000,$01ffff,size=-1,type='bss')
    ; must be aligned to beginning of bank
    MainMap resw MAX_TILEWIDTH*MAX_TILEHEIGHT
    MainMapEnd = *
    MainMapSize = MainMapEnd - MainMap
endsection

namespace Stages
    
    section 'VRAM'
        ; stage 0 - title screen
        S00BKG_PCX=loadpcx('work\titlebkg.pcx')
        savebin 'work\titlebkg.bin',S00BKG_PCX
        
        S00BKG_TILE byte S00BKG_PCX
        S00BKG_PAL = HUD.Font_PAL   ;byte S00BKG_PCXPALBGRX
        S00BKG_WIDTH = 30
        S00BKG_HEIGHT = 13
        S00BKG_MAP word ({{ loadcsv('work\titlebkg.map') }})+(BKGTSET<<8+BKGCLUT<<11)

        S00Main_PCX=loadpcx('work\titlelogo.pcx')
        savebin 'work\titlelogo.bin',S00Main_PCX
        
        S00Main_TILE byte S00Main_PCX
        S00Main_PAL byte S00Main_PCXPALBGRA
        S00Main_WIDTH = 20
        S00Main_HEIGHT = 13
        ; main and decode will be copied with a one tile border around the map
        ; main and decode are same size
        S00Main_MAP byte    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,
                            $0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,
                            $15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,
                            $1f,$20,$21,$22,$23,$24,$25,$26,$27,$28,$1f,$20,$21,$22,$23,$24,$25,$26,$27,$28,
                            $29,$2a,$2b,$2c,$2d,$2e,$2f,$30,$31,$32,$29,$2a,$2b,$2c,$2d,$2e,$2f,$30,$31,$32,
                            $33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        ; decode is the same size as main
        S00Decode byte      $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
                            $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        S00Hints


        ; stage 1

        S01BKG_TILE = S01BKG_TILE
        S01BKG_PAL = HUD.Font_PAL   ;S01BKG_PAL
        S01BKG_WIDTH = 20
        S01BKG_HEIGHT = 13
        S01BKG_MAP = S00BKG_MAP ;word ({{ loadcsv('work\titlebkg.map') }})+(BKGTSET<<8+BKGCLUT<<11)

        S01Main_PCX=loadpcx('tiled\map01.pcx')
        savebin 'work\map01.bin',S01Main_PCX
        S01Main_TILE byte S01Main_PCX
        S01Main_PAL = HUD.Font_PAL    ;byte S01Main_PCXPALBGRA
        S01Main_WIDTH = 64
        S01Main_HEIGHT = 15
        ; main and decode will be copied with a one tile border around the map
        ; main and decode are same size
        S01Main_MAP byte ({{ loadcsv('tiled\map01.txt') }})
        ; decode is the same size as main
        S01Decode byte ({{ loadcsv('tiled\map01_decode.csv') }})
        S01Hints

        ; stage 2
/*        
        S02BKG_PCX=loadpcx('work\bk2.pcx')
        savebin 'work\bk2.bin',S02BKG_PCX

        S02BKG_TILE byte S02BKG_PCX
        S02BKG_PAL byte S02BKG_PCXPALBGRX
        S02BKG_WIDTH = 20
        S02BKG_HEIGHT = 18
        S02BKG_MAP word ({{ loadcsv('work\bk2.map') }})+(BKGTSET<<8+BKGCLUT<<11)

        S02Main_PCX=loadpcx('tiled\map02.pcx')
        savebin 'work\map02.bin',S02Main_PCX
        S02Main_TILE byte S02Main_PCX
        S02Main_PAL = S02BKG_PAL ;byte S02Main_PCXPALBGRA
        S02Main_WIDTH = 31
        S02Main_HEIGHT = 127
        ; main and decode will be copied with a one tile border around the map
        ; main and decode are same size
        S02Main_MAP byte ({{ loadcsv('tiled\map02.txt') }})
        ; decode is the same size as main
        S02Decode byte ({{ loadcsv('tiled\map02_decode.csv') }})
        S02Hints
*/
        
    endsection
    section 'BSS'
;        Stage resb 1
        VPXStart resb 1 
        VPYStart resb 1
        P1XStart resb 1
        P1YStart resb 1
        P1FacingStart resb 1
        P2XStart resb 1
        P2YStart resb 1
        P2FacingStart resb 1

        MainTileWidth   resw 1
        MainTileHeight  resw 1
        MainWidth   resw 1
        MainHeight  resw 1
        MinMainXPos resw 1
        MinMainYPos resw 1
        MaxMainXPos resw 1
        MaxMainYPos resw 1
        Title       resb 20
        Song        resb 1
        BackgroundTileWidth     resw 1
        BackgroundTileHeight    resw 1
        align 2
        Decode  resb MAX_TILEWIDTH*MAX_TILEHEIGHT
        DecodeEnd = *
        DecodeOffsetsLo resb MAX_TILEHEIGHT
        DecodeOffsetsHi resb MAX_TILEHEIGHT
    endsection

    section 'DATA'
        struct TStage(  atitle,asong,atimer,
                        abkgtilewidth,abkgtileheight,abkgtile,abkgpal,abkgmap,
                        amaintilewidth,amaintileheight,amaintile,amainpal,amainmap,
                        adecode,
                        ahints)
            ; backgrounds are fixed 40x13
            BackgroundTileWidth word abkgtilewidth
            BackgroundTileHeight word abkgtileheight
            BackgroundTileLPtr long abkgtile           
            BackgroundPalLPtr long abkgpal
            BackgroundPalSize word sizeof(abkgpal)
            BackgroundMapLPtr long abkgmap

            MainTileWidth word amaintilewidth
            MainTileHeight word amaintileheight
            MainTileLPtr long amaintile
            MainPalLPtr long amainpal
            MainPalSize word sizeof(amainpal)
            MainMapLPtr long amainmap
            MainMapSize word amaintilewidth*amaintileheight

            DecodeLPtr long adecode

            HintsPtr word ahints

;            TileWidth word atilewidth
;            TileHeight word atileheight
            Song byte asong
            Timer word atimer  ; bcd number
            Title byte length(atitle)
                  char atitle,$ff
        endstruct

        S00 TStage( 'Title Screen',3,$0000,
                    S00BKG_WIDTH,S00BKG_HEIGHT,S00BKG_TILE,HUD.Font_PAL,S00BKG_MAP,
                    20,13,S00Main_TILE,S00Main_PAL,S00Main_MAP,
                    S00Decode,S00Hints)
        S01 TStage( 'THE BEGINNING',0,$0100,
                    S00BKG_WIDTH,S00BKG_HEIGHT,S00BKG_TILE,HUD.Font_PAL,S00BKG_MAP,
                    64,15,S01Main_TILE,HUD.Font_PAL,S01Main_MAP,
                    S01Decode,S01Hints)
//        S02 TStage( 'THE BIG TREES',0,$1000,
//                    S02BKG_WIDTH,S02BKG_HEIGHT,S02BKG_TILE,S02BKG_PAL,S02BKG_MAP,
//                    31,127,S02Main_TILE,S02BKG_PAL,S02Main_MAP,
//                    S02Decode,S02Hints)
        StagePtrs word S00,S01
        const MAX_STAGES = sizeof(StagePtrs)/2
    endsection

    section 'CODE'
        ; parameters:
        ;   a = stage #
        proc Init
            section 'BSS'
                tempx resb 1
                tempy resb 1
            endsection
            sta Stage
            asl
            tax
            mwa StagePtrs+x,TempSrc
            
            ; invalidate start positions
            lda #-1
            sta P1XStart
            sta P1YStart
            stz P1FacingStart
            sta P2XStart
            sta P2YStart
            stz P2FacingStart
            
            ; fill Decode with solid tile
            mwa #Decode,TempDest
            lda #TILEDECODE.SOLID
            -
                sta (TempDest)
                incw TempDest
                cxwbne TempDest,#DecodeEnd,-

            ; fill MainMap with empty tiles
            lda #(MainMap/$2000)
            jsr MapBSSBank
            mwa #BSSBANK,TempDest
            mwa #MainMapSize,TempDest+2
            -
                lda #TILEDECODE.EMPTY
                sta (TempDest)
                incw TempDest
                lda #(MAINTSET+MAINCLUT<<3) ; attribute
                sta (TempDest)
                incw TempDest
                lda TempDest+1
                cmp #>(BSSBANK+$2000)
                bne +
                    inc FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
                    lda #>BSSBANK
                    sta TempDest+1
                +
                decw TempDest+2
                decw TempDest+2
                lda TempDest+2
                bne -
                lda TempDest+3
                bne -
            jsr UnmapBSSBank

            ldy #TStage.Song    ; song number for stage
            mva (TempSrc)+y,Song
            ldy #TStage.Timer   ; timer for stage
            mwa (TempSrc)+y,EggTimerLo
            stz EggTimerSub
            ; copy title of stage
            ldy #TStage.Title-1
            ldx #$ff
            -
                iny
                inx
                mva (TempSrc)+y,Title+x
                bpl -
             
            ; copy and build stage data
            ; background
            ldy #TStage.BackgroundTileWidth   ; stage tile width
            mwa (TempSrc)+y,BackgroundTileWidth
            ldy #TStage.BackgroundTileHeight  ; stage tile height
            mwa (TempSrc)+y,BackgroundTileHeight
            ldy #TStage.BackgroundTileLPtr      ; tileset 2
            vky.Tileset_Set(2,(TempSrc)+y,TILE_VERTICAL)
            ldy #TStage.BackgroundPalLPtr       ; palette
            mla (TempSrc)+y,TempZ
            ldy #TStage.BackgroundPalSize       ; size of palette
            mwa (TempSrc)+y,TempZ+4
            mwa #FNX.VKY.CLUT3,TempDest         ; copy palette to clut3
            lda #(MainMap/$2000)
            jsr MapBSSBank
            jsr Copy_VRAMCLUT
            jsr UnmapBSSBank
            ldy #TStage.BackgroundMapLPtr       ; tilemap
            mla (TempSrc)+y,TempZ
            vky.Tilemap_Set(2,TempZ,TILE_SZ16,BackgroundTileWidth,BackgroundTileHeight,Viewport.BackgroundXRegPos,Viewport.BackgroundYRegPos,TILE_ENABLE)
            vky.Layer_Set(2,TL2)

            ; main
            ldy #TStage.MainTileWidth   ; stage tile width
            mwa (TempSrc)+y,MainTileWidth
            incw MainTileWidth
            ldy #TStage.MainTileHeight  ; stage tile height
            mwa (TempSrc)+y,MainTileHeight
            incw MainTileHeight
            ldy #TStage.MainTileLPtr            ; tileset 1
            vky.Tileset_Set(1,(TempSrc)+y,TILE_VERTICAL)
            ldy #TStage.MainPalLPtr             ; palette
            mla (TempSrc)+y,TempZ
            ldy #TStage.MainPalSize             ; size of palette
            mwa (TempSrc)+y,TempZ+4
            mwa #FNX.VKY.CLUT2,TempDest         ; copy palette to clut2
            lda #(MainMap/$2000)
            jsr MapBSSBank
            jsr Copy_VRAMCLUT
            jsr UnmapBSSBank
            ldy #TStage.MainMapLPtr             ; tilemap
            mla (TempSrc)+y,TempZ
            ldy #TStage.MainMapSize             ; size of stored tilemap
            mwa (TempSrc)+y,TempZ+4
            lda #(MainMap/$2000)
            jsr MapBSSBank
            jsr Parse_Map                       ; copy/parse map to current map
            jsr UnmapBSSBank
            vky.Tilemap_Set(1,#MainMap,TILE_SZ16,MainTileWidth,MainTileHeight,Viewport.XRegPos,Viewport.YRegPos,TILE_ENABLE)
            vky.Layer_Set(1,TL1)

            ldy #TStage.DecodeLPtr
            mla (TempSrc)+y,TempZ
            ldy #TStage.MainMapSize             ; size of stored tilemap
            mwa (TempSrc)+y,TempZ+4
            ; source lptr/$2000=slot#
            lda TempZ+1
            lsr TempZ+2 : ror
            lsr TempZ+2 : ror
            lsr TempZ+2 : ror
            lsr TempZ+2 : ror
            lsr TempZ+2 : ror
            jsr MapBSSBank
            jsr Parse_Decode                    ; copy/parse decode to current decode
            jsr UnmapBSSBank
            
            ; convert tile width/height to pixels
            mwa #16,FNX.MATH.UMUL_B             ; *16
            mwa MainTileWidth,FNX.MATH.UMUL_A
            mwa FNX.MATH.UMUL_PROD,MainWidth    ; pixel width
            mwa MainTileHeight,FNX.MATH.UMUL_A 
            mwa FNX.MATH.UMUL_PROD,MainHeight   ; pixel height

            ; calculate min and max map x/y positions
            mwa #32,MinMainXPos
            mwa #32,MinMainYPos
            sec
            sbcw MainWidth,#16,MaxMainXPos
            clc
            adcw MainHeight,#16,MaxMainYPos
;            mwa MainHeight,MaxMainYPos

            jsr Calculate_Decode_Offsets
            rts

            ;   TempZ = source lptr
            ;   TempZ+4 = source end ptr
            ;   TempDest = dest clut ptr
            Parse_Map:
                lda FNX.MMU.MEM_BANK_0+(BSSBANK2/$2000)
                pha
                ; source lptr/$2000=slot#
                lda TempZ+1
                lsr TempZ+2 : ror
                lsr TempZ+2 : ror
                lsr TempZ+2 : ror
                lsr TempZ+2 : ror
                lsr TempZ+2 : ror
                sta FNX.MMU.MEM_BANK_0+(BSSBANK2/$2000)
                lda TempZ+1
                and #$1f
                clc
                adc #>BSSBANK2
                sta TempZ+1
                mwa #BSSBANK,TempDest
                clc
                adcw MainTileWidth,TempDest ; start on second line
                clc
                adcw MainTileWidth,TempDest
                ldy #1
                ldx #0
                -
                    cpx #0  ; skip column 0
                    bne +
                        incw TempDest
                        incw TempDest
                        inx
                        bra ++
                    +
                    decw TempZ+4    ; decrease size
                    lda (TempZ) ; tile
                    sta (TempDest)
                    incw TempZ
                    lda TempZ+1
                    cmp #>(BSSBANK2+$2000)
                    bne +
                        inc FNX.MMU.MEM_BANK_0+(BSSBANK2/$2000)
                        lda #>BSSBANK2
                        sta TempZ+1
                    +
                    incw TempDest
                    lda #(MAINTSET+MAINCLUT<<3) ; attribute
                    sta (TempDest)
                    incw TempDest
                    inx
                    ++
                    cpx MainTileWidth
                    bne +
                        iny
                        ldx #0
                    +
                    lda TempDest+1
                    cmp #>(BSSBANK+$2000)
                    bne +
                        inc FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
                        lda #>BSSBANK
                        sta TempDest+1
                    +
                    lda TempZ+4     ; repeat if size not equal to zero
                    bne -
                    lda TempZ+5
                    bne -
                pla
                sta FNX.MMU.MEM_BANK_0+(BSSBANK2/$2000)
                rts
            
            Parse_Decode:
                lda TempZ+1
                and #$1f
                clc
                adc #>BSSBANK
                sta TempZ+1
                mwa #Decode,TempDest
                clc
                adcw MainTileWidth,TempDest ; start on second line
                clc
                adcw MainTileWidth,TempDest
                ldy #1
                ldx #0
                -
                    cpx #0  ; skip column 0
                    beq ++
                    decw TempZ+4    ; decrease size
                    lda (TempZ)
                    stx tempx
                    sty tempy
                    inx
                    iny
                    jsr .parse_tile
                    ldy tempy
                    ldx tempx
                    sta (TempDest)
                    incw TempZ
                    lda TempZ+1
                    cmp #>(BSSBANK+$2000)
                    bne +
                        inc FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
                        lda #>BSSBANK
                        sta TempZ+1
                    +
                    ++
                    incw TempDest
                    inx
                    cpx MainTileWidth
                    bne +
                        iny
                        ldx #0
                    +
                    lda TempZ+4     ; repeat if size not equal to zero
                    bne -
                    lda TempZ+5
                    bne -
                rts
                .parse_tile:
                    cmp #TILEDECODE.VIEWPORT
                    bne +
                        stx VPXStart
                        sty VPYStart
                        lda #TILEDECODE.EMPTY
                        rts
                    +
                    cmp #TILEDECODE.EGG
                    bne +
                        jsr .convert_to_pixels
;                        txa
;                        stz Actors.InitActor.xpos+1
;                        asl : rol Actors.InitActor.xpos+1
;                        asl : rol Actors.InitActor.xpos+1
;                        asl : rol Actors.InitActor.xpos+1
;                        asl : rol Actors.InitActor.xpos+1
;                        sta Actors.InitActor.xpos
;                        tya
;                        stz Actors.InitActor.ypos+1
;                        asl : rol Actors.InitActor.ypos+1
;                        asl : rol Actors.InitActor.ypos+1
;                        asl : rol Actors.InitActor.ypos+1
;                        asl : rol Actors.InitActor.ypos+1
;                        sta Actors.InitActor.ypos
;                        stz Actors.InitActor.xvel
;                        stz Actors.InitActor.xvel+1
;                        stz Actors.InitActor.yvel
;                        stz Actors.InitActor.yvel+1
                        lda #Actors.Role.EGG
                        ldx #actors.Egg.STATE.IDLE
                        ldy #Actors.FACING.LEFT
                        jsr Actors.InitActor
                        clc
                        lda tempy
                        adc tempx
                        and #3  ; only 4 frames in idle
                        tay
                        lda .FrameOffsetsForIdle,y
                        sta Actors.List.AniFrame,x
                        lda #TILEDECODE.EGG
                        rts
                    +
                    cmp #TILEDECODE.HEART
                    bne +
                        jsr .convert_to_pixels
                        lda #Actors.Role.HEART
                        ldx #actors.Heart.STATE.IDLE
                        ldy #Actors.FACING.LEFT
                        jsr Actors.InitActor
                        clc
                        lda tempy
                        adc tempx
                        and #3  ; only 4 frames in idle
                        tay
                        lda .FrameOffsetsForIdle,y
                        sta Actors.List.AniFrame,x
                        lda #TILEDECODE.HEART
                        rts
                    +
                    cmp #TILEDECODE.CHICKENWHITEL
                    bne +
                        stx P1XStart
                        sty P1YStart
                        lda #FACING.LEFT
                        sta P1FacingStart
                        lda #TILEDECODE.EMPTY
                        rts
                    +
                    cmp #TILEDECODE.CHICKENWHITER
                    bne +
                        stx P1XStart
                        sty P1YStart
                        lda #FACING.RIGHT
                        sta P1FacingStart
                        lda #TILEDECODE.EMPTY
                        rts
                    +
                    cmp #TILEDECODE.CHICKENBROWNL
                    bne +
                        stx P2XStart
                        sty P2YStart
                        lda #FACING.LEFT
                        sta P2FacingStart
                        lda #TILEDECODE.EMPTY
                        rts
                    +
                    cmp #TILEDECODE.CHICKENBROWNR
                    bne +
                        stx P2XStart
                        sty P2YStart
                        lda #FACING.RIGHT
                        sta P2FacingStart
                        lda #TILEDECODE.EMPTY
                        rts
                    +
                    cmp #TILEDECODE.CHICKL
                    bne +
                        jsr .convert_to_pixels
                        lda #Actors.Role.CHICK
                        ldx #actors.CHICK.STATE.IDLE
                        ldy #Actors.FACING.LEFT
                        jsr Actors.InitActor
                        clc
                        lda tempy
                        adc tempx
                        and #3  ; only 2 frames in idle
                        tay
                        lda .FrameOffsetsForIdle,y
                        sta Actors.List.AniFrame,x
                        lda #TILEDECODE.CHICKL
                        rts
                    +
                    cmp #TILEDECODE.CHICKR
                    bne +
                        jsr .convert_to_pixels
                        lda #Actors.Role.CHICK
                        ldx #actors.CHICK.STATE.IDLE
                        ldy #Actors.FACING.RIGHT
                        jsr Actors.InitActor
                        clc
                        lda tempy
                        adc tempx
                        and #3  ; only 2 frames in idle
                        tay
                        lda .FrameOffsetsForIdle,y
                        sta Actors.List.AniFrame,x
                        lda #TILEDECODE.CHICKR
                        rts
                    +
                    cmp #TILEDECODE.PIGSPEARL
                    bne +
                    +
                    cmp #TILEDECODE.PIGSPEARR
                    bne +
                    +
                    cmp #TILEDECODE.SPIKES
                    bne +
                        jsr .convert_to_pixels
                        lda #Actors.Role.SPIKES
                        ldx #actors.Spikes.STATE.IDLE
                        ldy #Actors.FACING.LEFT
                        jsr Actors.InitActor
                        clc
                        lda tempy
                        adc tempx
                        and #7  ; only 8 frames in idle
                        tay
                        lda .FrameOffsetsForIdle,y
                        sta Actors.List.AniFrame,x
                        lda #TILEDECODE.SPIKES
                        rts
                    +
                    rts
                    ; no fancy shenanigans in idle frames or offsets will be off
                    ; use for randomizing the start frame so they don't all animate in syncronous
                    .FrameOffsetsForIdle byte @DUP*4 dup 8

                .convert_to_pixels:
                    txa
                    stz Actors.InitActor.xpos+1
                    asl : rol Actors.InitActor.xpos+1
                    asl : rol Actors.InitActor.xpos+1
                    asl : rol Actors.InitActor.xpos+1
                    asl : rol Actors.InitActor.xpos+1
                    sta Actors.InitActor.xpos
                    tya
                    stz Actors.InitActor.ypos+1
                    asl : rol Actors.InitActor.ypos+1
                    asl : rol Actors.InitActor.ypos+1
                    asl : rol Actors.InitActor.ypos+1
                    asl : rol Actors.InitActor.ypos+1
                    sta Actors.InitActor.ypos
                    stz Actors.InitActor.xvel
                    stz Actors.InitActor.xvel+1
                    stz Actors.InitActor.yvel
                    stz Actors.InitActor.yvel+1
                    rts
                    
//        DecodeOffsetsLo resb MAX_TILEHEIGHT
//        DecodeOffsetsHi resb MAX_TILEHEIGHT
            Calculate_Decode_Offsets:
                mwa #(Decode-1),TempZ
                ldx #0
                -
                    lda TempZ
                    sta DecodeOffsetsLo,x
                    lda TempZ+1
                    sta DecodeOffsetsHi,x
                    clc
                    adcw MainTileWidth,TempZ
                    inx
                    cpx #MAX_TILEHEIGHT
                    bne -
                rts
        endproc
    endsection
    
endnamespace
//////////
