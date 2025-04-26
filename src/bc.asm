cpu f256
opt casesensitive- ,
    reopenscopes+ ,
    colonlinecontinue+ ,
    showtickcount-
;display listing=%11111110   ; turn off statement numbers

include 'f256registers.asm'

const   DOPUSH = 0
const   TEXT_BANK = 'DATA'

const   FNX_SCREEN_WIDTH = 640 ,
        FNX_SCREEN_HEIGHT = 400 ,
        FNX_GFXSCREEN_WIDTH = 320 ,
        FNX_GFXSCREEN_HEIGHT = 200 ,
        FNX_BORDER_WIDTH = 0 ,
        FNX_BORDER_HEIGHT = 0 ,
        FNX_SCREEN_COLUMNS = 40 ,
        FNX_SCREEN_LINES = 30

const KEYS=enum(CR          = $0d ,
                CURSORUP    = $10 , 
                CURSORDOWN  = $0e ,
                CURSORLEFT  = $02 ,
                CURSORRIGHT = $06 ,
                SPACEBAR    = $20 ,
                F1          = $81 ,
                F2          = $82 ,
                F3          = $83 ,
                F4          = $84 ,
                F5          = $85 ,
                F6          = $86 ,
                F7          = $87 ,
                F8          = $88 )

const MAX_PLAYERS = 2
const PLAYER1 = 0, PLAYER2 = 1

section add('ZPAGE',$000020,$0000df,size=-1,type='bss')
	TempSrc resb 4
	TempDest resb 4
	TempIRQ resb 16
	TempZ resb 24
endsection

section add('F256LIB',$00800,$000fff,size=-1)
endsection

section add('CODE',$002000,$005fff,size=-1)
    ; F256 kup header
    byte   $f2,$56     ; signature
    byte   <(1+(___CODE_SECTION_NEXT_FREE___-___CODE_SECTION_BEGIN___) >> 13)   ; block count
    byte   <(___CODE_SECTION_BEGIN___) >> 13)                    ; start slot
    word   Main        ; exec addr
    byte   1                 ; CHANGED, structure version
    byte   0                 ; reserved
    byte   0                 ; reserved
    byte   0                 ; reserved
    bytez 'bawkbawkcluckcluck'; name
endsection

section add('DATA',$006000,$006fff,size=-1)
endsection

section add('BSS',$007000,$009fff,size=-1,type='bss')
    ; game modes are multiples of 2 to match absolute indirect jump
    GAMEMODES=enum(EXIT=-1,TITLE=0,INGAME=2,GAMEOVER=4)
    GameMode resb 1
;    SOFCounter dword 0
    
    ; player inputs
    const INPUTS=enum(  KEYBOARD0,KEYBOARD1,
                        JOYPORT0,JOYPORT1,
                        NESPORT0,NESPORT1,NESPORT2,NESPORT3,
                        SNESPORT0,SNESPORT1,SNESPORT2,SNESPORT3)
    JoyStates resb MAX_PLAYERS
;    FreezeInputTimer resb MAX_PLAYERS
    Players resb 1
    Stage resb 1
    EggTimerSub resb 1
    EggTimerLo resb 1
    EggTimerHi resb 1
    const FACING=enum(LEFT,RIGHT)
    namespace Player
        FreezeInputTimer resb MAX_PLAYERS
        InputMode resb MAX_PLAYERS
        ScoreLo resb MAX_PLAYERS
        ScoreMd resb MAX_PLAYERS
        ScoreHi resb MAX_PLAYERS
        Health resb MAX_PLAYERS
        EggsLo resb MAX_PLAYERS
        EggsHi resb MAX_PLAYERS
        ChicksLo resb MAX_PLAYERS
        ChicksHi resb MAX_PLAYERS
    endnamespace
    
endsection

; reserved work area for swapping banks slots
; do not put anything important in this memory region
section add('BSSBANK',$00a000,$00bfff,size=-1,save=0)
    BSSBANK = *
endsection
section add('BSSBANK2',$008000,$009fff,size=-1,save=0)
    BSSBANK2 = *
endsection
section add('BSSBANK3',$006000,$007fff,size=-1,save=0)
    BSSBANK3 = *
endsection
/*
;   X = slot address/$2000
macro MapBSSBank(aaddress)
    sei
    lda FNX.MMU.MEM_CTRL
    pha
    ora #FNX.MMU.EDIT_EN
    sta FNX.MMU.MEM_CTRL
    lda FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
    pha
    lda #(aaddress/$2000)
    sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
endmacro

macro UnmapBSSBank
    pla
    sta FNX.MMU.MEM_BANK_0+(BSSBANK/$2000)
    pla
    sta FNX.MMU.MEM_CTRL
    cli
endmacro
*/

section add('VRAM',$020000,$03ffff,size=-1,save=1)
endsection

section add('SAMPLE',$03e000,$03ffff,size=-1,save=1)
    bawk_bin incbin 'sound\bawk.bin'
endsection

include 'f256lib.asm'
include 'f256vicky_macros.asm'

include 'kernel.asm'
;include 'zx0.asm'
include 'display.asm'
include 'zx02.asm'

include 'stages.asm'
include 'timers.asm'
include 'sound.asm'

;include 'map.asm'
;include 'player.asm'
;include 'gameover.asm'
include 'common.asm'
include 'sid.asm'
include 'hud.asm'
include 'title.asm'
include 'viewport.asm'
include 'game.asm'
include 'actors.asm'


section 'CODE'
    proc Init_Codec
    CODEC_LOW   = FNX.CODEC.LO
    CODEC_HI    = FNX.CODEC.HI
    CODEC_CTRL  = FNX.CODEC.CTRL
    
    ;/////////////////////////
    ;// CODEC
    ;/////////////////////////
    ;CODEC_LOW        = $D620
    ;CODEC_HI         = $D621
    ;CODEC_CTRL       = $D622
    ;INIT_CODEC 
                ;                LDA #%00011010_00000000     ;R13 - Turn On Headphones
                lda #%00000000
                sta CODEC_LOW
                lda #%00011010
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ; LDA #%0010101000000011       ;R21 - Enable All the Analog In
                lda #%00000011
                sta CODEC_LOW
                lda #%00101010
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ; LDA #%0010001100000001      ;R17 - Enable All the Analog In
                lda #%00000001
                sta CODEC_LOW
                lda #%00100011
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ;   LDA #%0010110000000111      ;R22 - Enable all Analog Out
                lda #%00000111
                sta CODEC_LOW
                lda #%00101100
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ; LDA #%0001010000000010      ;R10 - DAC Interface Control
                lda #%00000010
                sta CODEC_LOW
                lda #%00010100
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ; LDA #%0001011000000010      ;R11 - ADC Interface Control
                lda #%00000010
                sta CODEC_LOW
                lda #%00010110
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                ; LDA #%0001100111010101      ;R12 - Master Mode Control
                lda #%01000101
                sta CODEC_LOW
                lda #%00011000
                sta CODEC_HI
                lda #$01
                sta CODEC_CTRL ; 
                jsr CODEC_WAIT_FINISH
                rts
    
    CODEC_WAIT_FINISH
    CODEC_Not_Finished:
                lda CODEC_CTRL
                and #$01
                cmp #$01 
                beq CODEC_Not_Finished
                rts 
    endproc

    ; replace char #254/255 with the dots for the egg timer colon
    proc InitEggTimerColonCharacterMap
        .IO_GFX
        ldx #0
        -
            lda dotmap,x
            sta FNX.VKY.FONT1+254*8,x
            inx
            cpx #2*8
            bne -
        .IO_MAIN
        rts
        
        section 'DATA'
            dotmap byte %00000000 ,
                        %00000000 ,
                        %00000000 ,
                        %00000000 ,
                        %00001110 ,
                        %00011100 ,
                        %00000000 ,
                        %00000000
                   byte %00000000 ,
                        %00000000 ,
                        %00001110 ,
                        %00011100 ,
                        %00000000 ,
                        %00000000 ,
                        %00000000 ,
                        %00000000
        endsection
    
    endproc
    
    proc Main
        ; invalidate kup signature
        stz ___CODE_SECTION_BEGIN___
        
        .IO_MAIN
        jsr Kernel.Init
        
        ; enable rng
        lda FNX.RNG.CTRL
        ora #1
        sta FNX.RNG.CTRL
        
        jsr Init_Codec
        jsr ClearVickyRegisters
        jsr display.Init
        jsr InitEggTimerColonCharacterMap
        vky.Mode_Set(ENABLE,TEXT,TEXTOVERLAY,GRAPHICS,SPRITES,TILES,400P,FONT1,DOUBLEX,DOUBLEY)
;        vky.Border_Enable()
;        vky.Border_Width(#1)
;        vky.Border_Height(#0)

        lda #GAMEMODES.TITLE
        sta GameMode
        lda #INPUTS.KEYBOARD0
        sta Player.InputMode+PLAYER1
        lda #INPUTS.KEYBOARD1
        sta Player.InputMode+PLAYER2
        lda #1
        sta Players
        stz SID.CurrentSong
        
        ; delay to wait for syncing to 400P mode
        lda #30
        ldx #0
        ldy #0
        -
            dex
            bne -
                dey
                bne -
                    dec
                    bne -
        
        Main10:
            ldx GameMode
            bmi Exit
                jsr CallGameMode
                jmp Main10
                
        CallGameMode:
            jmp (GameModeVectors,x)

        Exit:
            ; return to SuperBasic
            jsr SID.Reset
            jsr PSG.Init
            jsr WaitForKernalEvents
            jsr ClearVickyRegisters
            vky.Mode_Set(ENABLE,TEXT,480P,FONT0)
            jsr Init_Codec
    
            ; F256 hard reset
            lda #>$DEAD
            sta FNX.SYS.RST
            lda #<$DEAD
            sta FNX.SYS.RST+1
            lda FNX.SYS.SYS0
            ora #%10000000
            sta FNX.SYS.SYS0
            and #%01111111
            sta FNX.SYS.SYS0
;            jmp ($fffc) ; reset vector

        Dummy:
            rts
        GameModeVectors word Title.Main,Game.Main,Dummy
;        GameModeVectors word Title.Main,InGame.Main,GameOver.Main
    endproc

endsection

savebin 'bc.pgz',pgz=Main
