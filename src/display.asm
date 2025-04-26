
include 'zx0.asm'

namespace display

    const   DEFAULT_VKY_PIXEL_WIDTH = 320 ,
            DEFAULT_VKY_PIXEL_HEIGHT = 200 ,
            MAX_COLUMNS = 40 ,
            MAX_ROWS = 30 ,
            DEFAULT_COLUMNS = 40 ,
            DEFAULT_ROWS = 30 ,
            DEFAULT_CURSOR_COLOR = C64.WHITE<<4+C64.BLACK
        
    section 'ZPAGE'
        CursorColor byte 0
        CursorOffset word 0
        CursorTextPointer word 0
        CursorColorPointer word 0
        CursorColumn byte 0
        CursorRow byte 0
        Columns byte 0
        Rows byte 0
;        PrintTextPointer dword 0
    endsection

    section 'DATA'
        HEXTABLE byte '0123456789ABCDEF'
    endsection

    section 'CODE'
        ; Fills TEXT_MEM with spaces and COLOR_MEM with current CursorColor.
        ;
        ; clobbers:
        ;   A, X, Y, TempDest
        proc ClearScreen
            ldx #' '
        Custom:
            ldy CursorColor
            movw #FNX.VKY.TEXT_MEM,TempDest
            -
                .IO_TEXT
                txa
                sta (TempDest)
                .IO_COLOR
                tya
                sta (TempDest)
                incw TempDest
                lda TempDest
                cmp #<(FNX.VKY.TEXT_MEM+MAX_COLUMNS*MAX_ROWS)
                bne -
                lda TempDest+1
                cmp #>(FNX.VKY.TEXT_MEM+MAX_COLUMNS*MAX_ROWS)
                bne -
            .IO_MAIN
            
        Reset_Cursor:
            lda #0  ; top left
            sta CursorColumn
            sta CursorRow
            sta CursorOffset
            rts
        endproc
        
        macro Clear_Screen(achar,'afgcolor','abkcolor')
            if DOPUSH=1 : pha : phx : endif
            if ~argcount=1
                setas
                ldx achar
                jsr display.ClearScreen.Custom
            elseif ~argcount=2
                setas
                if leftstr('afgcolor',1)='#'
                    lda #{{copy('afgcolor',2)}}<<4
                else
                    lda afgcolor
                    asl : asl : asl : asl
                endif
                sta CursorColor
                ldx achar
                jsr display.ClearScreen.Custom
            elseif ~argcount=3
                setas
                if leftstr('afgcolor',1)='#'
                    lda #{{copy('afgcolor',2)}}<<4
                else
                    lda afgcolor
                    asl : asl : asl : asl
                endif
                if leftstr('abkcolor',1)='#'
                    ora #{{copy('abkcolor',2)}}
                else
                    ora abkcolor
                endif
                xba
                lda achar
                jsr display.ClearScreen.Custom
            else
                jsr display.ClearScreen
            endif
            if DOPUSH=1 : plx : pla : endif
        endmacro
    
        proc Init
            ; initialize default display settings 80x60
            lda #DEFAULT_COLUMNS
            sta Columns
            lda #DEFAULT_ROWS
            sta Rows
            lda #DEFAULT_CURSOR_COLOR
            sta CursorColor
        
            ; move cursor to top left corner (0,0)
            jsr ClearScreen.Reset_Cursor
            jsr ClearScreen
            
            ; initialize display mode
            lda #(FNX.VKY.TEXT_MODE_EN) ;(FNX.VKY.TEXT_MODE_EN|FNX.VKY.TEXT_OVERLAY|FNX.VKY.GRAPH_EN|FNX.VKY.BITMAP_EN)
            sta FNX.VKY.MSTR_CTRL0
            lda #0  ;(1*FNX.VKY.FONT_BANK_SET|FNX.VKY.TEXT_XDOUBLE|FNX.VKY.TEXT_YDOUBLE)
            sta FNX.VKY.MSTR_CTRL1
            
            ; set all layers to bitmap0, disabled
            lda #0
            sta FNX.VKY.LAYER_CTRL0
            sta FNX.VKY.LAYER_CTRL1
            lda #0
            sta FNX.VKY.BITMAPS.CONTROL+0*sizeof(FNX.BITMAP_TYPE)
            
            ; disable border
            vky.Border_Disable()
            
            ; background color #000000
            vky.Background_RGB(#$000000)
        
            ; initialize default Colodore text palette
            ldx #0
            -
                lda Colodore_Palette_Data,x
                sta FNX.VKY.TCLUT_FG,x
                sta FNX.VKY.TCLUT_BG,x
                inx
                cpx #sizeof(Colodore_Palette_Data)
                bne -
            
            ; decompress font std and bold
            .IO_GFX
        ;    zx0.Decompress(#F256_Font_STD_ZX0,#FNX.VKY.FONT0)
            zx0.Decompress(#F256_Font_Thicke_ZX0,#FNX.VKY.FONT1)
            .IO_MAIN
            rts
        
            Colodore_Palette_Data dword $00000000 , $00FFFFFF , $00813338 , $0075CEC8 ,
                                        $008E3C97 , $0056AC4D , $00242C9B , $00EDF171 ,
                                        $008E5029 , $00553800 , $00C46C71 , $004A4A4A ,
                                        $007B7B7B , $00A9FF9F , $00706DEB , $00B2B2B2  
        ;    F256_Font_STD_ZX0 incbin 'assets\f256jr_std-charset.fnt.zx0'
        ;    F256_Font_Bold_ZX0 incbin 'assets\f256_std_bold.fnt.zx0'
            F256_Font_Thicke_ZX0 incbin 'assets\f256jr_thicke-charset.fnt.zx0'
        endproc
    
        ; Updates the CursorOffset value based on the CursorRow and CursorColumn.
        ; Calculation uses Foenix hardware math coprocessor registers.
        ;
        ; parameters:
        ;   display.CursorRow = 16 bit
        ;   display.CursorColumn = 16 bit
        ;   display.Rows = 16 bit
        ;   display.Columns = 16 bit
        ; returns:
        ;   A = offset
        ; clobbers:
        ;   A, MATH.UMUL_A, MATH.UMUL_B, MATH.UMUL_PROD
        proc UpdateCursorPointers
            lda CursorRow
            sta FNX.MATH.UMUL_A
            stz FNX.MATH.UMUL_A+1
            lda Columns
            sta FNX.MATH.UMUL_B
            stz FNX.MATH.UMUL_B+1
            lda FNX.MATH.UMUL_PROD
            sta CursorOffset
            lda FNX.MATH.UMUL_PROD+1
            sta CursorOffset+1
        
            lda CursorOffset
            sta CursorTextPointer
            sta CursorColorPointer
            lda CursorOffset+1
            clc
            adc #>(FNX.VKY.TEXT_MEM)
            sta CursorTextPointer+1
            sta CursorColorPointer+1
            rts
        endproc
    
        ; Set cursor row and column.
        ;   A = row
        ;   X = column
        proc SetCursorPosition
            stx display.CursorColumn
            sta display.CursorRow
            rts
        endproc
        
        macro Set_CursorPosition(acolumn,arow)
[]          ConvertParamToA(acolumn)
            sta display.CursorColumn
[]          ConvertParamToA(arow)
            sta display.CursorRow
        endmacro
    
    
        ; Prints a null ending string of characters.
        ; Does not check for line and screen overruns.
        ; parameters:
        ;   A = address low byte of text to print
        ;   Y = address high byte of text to print
        ; clobbers:
        ;   A,X,Y, TempSrc (32 bit)
        proc PrintString
            sta @srcaddr
            sty @srcaddr+1
            jsr UpdateCursorPointers
            .IO_TEXT
            ldx #0
            ldy CursorColumn
            -
                @srcaddr = *+1
                lda $1234,x
                beq .exit
                inx
                cmp #13
                beq .newline
                sta (CursorTextPointer),y
                inc FNX.MMU.IO_CTRL ;.IO_COLOR
                lda CursorColor
                sta (CursorColorPointer),y
                dec FNX.MMU.IO_CTRL ;.IO_TEXT
                iny
                cpy Columns
                bne -
                .newline:
                    clc
                    lda CursorOffset
                    adc Columns
                    sta CursorOffset
                    sta CursorTextPointer
                    sta CursorColorPointer
                    lda CursorOffset+1
                    adc #0
                    sta CursorOffset+1
                    clc
                    adc #>(FNX.VKY.TEXT_MEM)
                    sta CursorTextPointer+1
                    sta CursorColorPointer+1
                    inc CursorRow
                    ldy #0
                bra -
            .exit:
            sty CursorColumn
            .IO_MAIN
            rts
        endproc
    
        macro Set_CursorColor('afgcolor','abkcolor')
            if DOPUSH=1 : pha : endif
            if (leftstr('afgcolor',1)='#') and (leftstr('abkcolor',1)='#')
                lda #({{copy('afgcolor',2)}}<<4)|{{copy('abkcolor',2)}}
            else
                if leftstr('afgcolor',1)='#'
                    lda #{{copy('afgcolor',2)}}<<4
                else
                    lda afgcolor
                    asl : asl : asl : asl
                endif
                if length('abkcolor')>0
                    if leftstr('abkcolor',1)='#'
                        ora #{{copy('abkcolor',2)}}
                    else
                        ora abkcolor
                    endif
                endif
            endif
            sta display.CursorColor
            if DOPUSH=1 : pla : endif
        endmacro
        
        macro Print_Text('asrc',acolumn,arow,afgcolor,abkcolor)
        ;    assert (~asize=16) and (~isize=16), error('acc and xy must be in 16bit mode')
[]          @argcount=~argcount
            if DOPUSH=1 : pha : phx : phy : endif
            if @argcount>=3
                display.Set_CursorPosition(acolumn,arow)
            endif
            if @argcount>=4
                display.Set_CursorColor(afgcolor,abkcolor)
            endif
            if leftstr('asrc',1)='#'
                lda #lobyte({{copy('asrc',2)}})
                ldy #hibyte({{copy('asrc',2)}})
            elseif (leftstr('asrc',1)='"') or (leftstr('asrc',1)="'")
                section 'DATA'
                    @temp bytez asrc
                endsection
                lda #lobyte(@temp)
                ldy #hibyte(@temp)
            else
                lda asrc
                ldy asrc+1
            endif
            jsr display.PrintString
            if DOPUSH=1 : ply : plx : pla : endif
        endmacro
    
        ; parameters
        ;	A	=	byte to print
        ; returns
        ;	Y	=	upper nibble ascii
        ;	A	=	lower nibble ascii
        proc HexByteToASCII
            phx
            tax
            lsr : lsr : lsr : lsr
            and #$0f
            tay
            lda HEXTABLE,y
            tay
            txa
            and #$0f
            tax
            lda HEXTABLE,x
            plx
            rts
        endproc
        
        ;   A = byte
        proc PrintHexByte
            if DOPUSH=1 : phx : phy : endif
            jsr HexByteToASCII
            sty TempZ
            sta TempZ+1
            stz TempZ+2
            Print_Text(#TempZ)
            if DOPUSH=1 : ply : plx : endif
            rts
        endproc
        
        ;   A = lobyte
        ;   Y = hibyte
        proc PrintHexWord
        ;	if DOPUSH=1 : phx : phy : endif
            pha
            tya
            jsr HexByteToASCII
            sty TempZ
            sta TempZ+1
            pla
            jsr HexByteToASCII
            sty TempZ+2
            sta TempZ+3
            stz TempZ+4
            Print_Text(#TempZ)
        ;	if DOPUSH=1 : ply : plx : endif
            rts
        endproc
        
        ;   A = lobyte
        ;   Y = hibyte
        ;   X = bankbyte
        proc PrintHexLong
        ;	if DOPUSH=1 : phy : endif
            pha
            phy
            txa
            jsr HexByteToASCII
            sty TempZ
            sta TempZ+1
            pla
            jsr HexByteToASCII
            sty TempZ+2
            sta TempZ+3
            pla
            jsr HexByteToASCII
            sty TempZ+4
            sta TempZ+5
            stz TempZ+6
            Print_Text(#TempZ)
        ;	if DOPUSH=1 : ply : endif
            rts
        endproc

/*
;   A = loword
;   X = hiword
proc16 PrintHexDWord
	if DOPUSH=1 : phy : endif
    pha
    txa
    setaxs
    xba
	jsr HexByteToASCII
	sty TempZ
    sta TempZ+1
    xba
	jsr HexByteToASCII
	sty TempZ+2
    sta TempZ+3
    setal
    pla
    setas
    xba
	jsr HexByteToASCII
	sty TempZ+4
    sta TempZ+5
    xba
	jsr HexByteToASCII
	sty TempZ+6
    sta TempZ+7
	stz TempZ+8
    setaxl
	Print_Text(#TempZ)
	if DOPUSH=1 : ply : endif
    rts
endproc
*/
        macro Print_HexByte(avalue)
            if DOPUSH=1 : pha : endif
[]            ConvertParamToA(avalue)
            jsr display.PrintHexByte
            if DOPUSH=1 : pla : endif
        endmacro
        
        macro Print_HexWord(avalue)
            if DOPUSH=1 : pha : endif
[]            ConvertParamToA(avalue)
[]            ConvertParamToY(avalue+1)
            jsr display.PrintHexWord
            if DOPUSH=1 : pla : endif
        endmacro
        
        macro Print_HexLong('avalue')
            if DOPUSH=1 : pha : endif
[]            ConvertParamToA(avalue)
[]            ConvertParamToY(avalue+1)
[]            ConvertParamToX(avalue+2)
            jsr display.PrintHexLong
            if DOPUSH=1 : pla : endif
        endmacro
/*
macro Print_HexDWord('avalue')
	if DOPUSH=1 : pha : phx : endif
    if leftstr('avalue',1)='#'
        lda #loword({{copy('avalue',2)}})
        ldx #hiword({{copy('avalue',2)}})
    else
        lda avalue
        ldx avalue+2
    endif
    jsr display.PrintHexDWord
	if DOPUSH=1 : plx : pla : endif
endmacro
*/


    endsection
endnamespace
