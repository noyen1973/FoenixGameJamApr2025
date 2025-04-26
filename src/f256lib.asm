
const FOENIXMODELS = enum(	C256FMX,
							C256U,
							F256JR,
							A2560DEV,
							GENX,
							C256UP,
							RES1,
							RES2,
							A2560X,
							A2560U,
							A2560M,
							A2560K)
ifndef FNX_SCREEN_WIDTH
	const FNX_SCREEN_WIDTH = 320 ,
			FNX_SCREEN_HEIGHT = 240 ,
			FNX_BORDER_WIDTH = 0 ,
			FNX_BORDER_HEIGHT = 0 ,
			FNX_SCREEN_COLUMNS = (FNX_SCREEN_WIDTH-FNX_BORDER_WIDTH) / 8 ,
			FNX_SCREEN_LINES = (FNX_SCREEN_HEIGHT-FNX_BORDER_HEIGHT) / 8
endif


VKY_SCREEN_MEMORY = $C000	; character memory in io page 2, color memory in io page 3
VKY_FONT_MEMORY   = $C000	; address of screen font memory in io page 1
VKY_TEXT_MEMORY   = $C000	; address of screen text memory in io page 2
VKY_COLOR_MEMORY  = $C000	; address of screen color memory in io page 3

define jeq(aaddr) 'bne ~pcnext2 : jmp aaddr'
define jne(aaddr) 'beq ~pcnext2 : jmp aaddr'
define jlt(aaddr) 'bge ~pcnext2 : jmp aaddr'
define jge(aaddr) 'blt ~pcnext2 : jmp aaddr'
define jcc(aaddr) 'bcs ~pcnext2 : jmp aaddr'
define jcs(aaddr) 'bcc ~pcnext2 : jmp aaddr'
define jmi(aaddr) 'bpl ~pcnext2 : jmp aaddr'
define jpl(aaddr) 'bmi ~pcnext2 : jmp aaddr'
define jvc(aaddr) 'bvs ~pcnext2 : jmp aaddr'
define jvs(aaddr) 'bvc ~pcnext2 : jmp aaddr'

define proc8 proc

const C64 = enum(	BLACK,WHITE,RED,CYAN,
                    PURPLE,GREEN,BLUE,YELLOW,
                    ORANGE,BROWN,LTRED,DKGREY,
                    MDGREY,LTGREEN,LTBLUE,LTGREY)
define DoC64COLOR(aforeground,abackground) (C64.aforeground<<4) | C64.abackground
define PushAXY 'pha : phx : phy'
define PullYXA 'ply : plx : pla'
define '.MMUEDIT' 'lda FNX.MMU.MEM_CTRL : ora #FNX.MMU.EDIT_EN : sta FNX.MMU.MEM_CTRL'
define '.MMULOCK' 'lda FNX.MMU.MEM_CTRL : and #~(FNX.MMU.EDIT_EN) : sta FNX.MMU.MEM_CTRL'

define '.IO_MAIN' 'stz FNX.MMU.IO_CTRL'
define '.IO_0' 'stz FNX.MMU.IO_CTRL'
; use accumulator
define '.IO_GFX' 'lda #FNX.MMU.IO_PAGE_1 : sta FNX.MMU.IO_CTRL'
define '.IO_TEXT' 'lda #FNX.MMU.IO_TEXT : sta FNX.MMU.IO_CTRL'
define '.IO_COLOR' 'lda #FNX.MMU.IO_COLOR : sta FNX.MMU.IO_CTRL'
define '.IO_1' 'lda #FNX.MMU.IO_PAGE_1 : sta FNX.MMU.IO_CTRL'
define '.IO_2' 'lda #FNX.MMU.IO_TEXT : sta FNX.MMU.IO_CTRL'
define '.IO_3' 'lda #FNX.MMU.IO_COLOR : sta FNX.MMU.IO_CTRL'
; use index x
define '.IOX_GFX' 'ldx #FNX.MMU.IO_PAGE_1 : stx FNX.MMU.IO_CTRL'
define '.IOX_TEXT' 'ldx #FNX.MMU.IO_TEXT : stx FNX.MMU.IO_CTRL'
define '.IOX_COLOR' 'ldx #FNX.MMU.IO_COLOR : stx FNX.MMU.IO_CTRL'
define '.IOX_0' 'ldx #FNX.MMU.IO_PAGE_1 : stx FNX.MMU.IO_CTRL'
define '.IOX_1' 'ldx #FNX.MMU.IO_TEXT : stx FNX.MMU.IO_CTRL'
define '.IOX_2' 'ldx #FNX.MMU.IO_COLOR : stx FNX.MMU.IO_CTRL'
; use index y
define '.IOY_GFX' 'ldy #FNX.MMU.IO_PAGE_1 : sty FNX.MMU.IO_CTRL'
define '.IOY_TEXT' 'ldy #FNX.MMU.IO_TEXT : sty FNX.MMU.IO_CTRL'
define '.IOY_COLOR' 'ldy #FNX.MMU.IO_COLOR : sty FNX.MMU.IO_CTRL'
define '.IOY_1' 'ldy #FNX.MMU.IO_PAGE_1 : sty FNX.MMU.IO_CTRL'
define '.IOY_2' 'ldy #FNX.MMU.IO_TEXT : sty FNX.MMU.IO_CTRL'
define '.IOY_3' 'ldy #FNX.MMU.IO_COLOR : sty FNX.MMU.IO_CTRL'
define SetMMUIO 'stz FNX.MMU.IO_CTRL'
define SetMMUGFX 'lda #FNX.MMU.IO_PAGE_1 : sta FNX.MMU.IO_CTRL'
define SetMMUTEXT 'lda #FNX.MMU.IO_TEXT : sta FNX.MMU.IO_CTRL'
define SetMMUCOLOR 'lda #FNX.MMU.IO_COLOR : sta FNX.MMU.IO_CTRL'
define PushMMUIO 'lda FNX.MMU.IO_CTRL : pha'
define PushXMMUIO 'ldx FNX.MMU.IO_CTRL : phx'
define PushYMMUIO 'ldy FNX.MMU.IO_CTRL : phy'
define PullMMUIO 'pla : sta FNX.MMU.IO_CTRL'
define PullXMMUIO 'plx : stx FNX.MMU.IO_CTRL'
define PullYMMUIO 'ply : sty FNX.MMU.IO_CTRL'
define PushMMUCTRL 'lda FNX.MMU.MEM_CTRL : pha'
define PullMMUCTRL 'pla : sta FNX.MMU.MEM_CTRL'
define Set_MMUBank(abank,aaddr) 'lda #((aaddr)/$2000) : sta FNX.MMU.MEM_Bank_0+abank'

;=====================================================================================


macro Spinner(acolumn,arow)
    {
        .IO_TEXT
        inc FNX.VKY.TEXT_MEM+(acolumn+arow*40)
        .IO_COLOR
        inc FNX.VKY.COLOR_MEM+(acolumn+arow*40)
        .IO_MAIN
    }
endmacro

macro F256Test()
	-
		.IO_TEXT
		inc TEXT_MEM
		.IO_COLOR
		inc COLOR_MEM
		.IO_MAIN
		inc BACKGROUND_COLOR_B
		inc BORDER_COLOR_B
	bra -
endmacro

macro F256Line0(achar,acolumn,acolor)
	.IO_TEXT
	lda #achar 
	sta TEXT_MEM+acolumn
	.IO_COLOR
	lda #acolor
	sta  COLOR_MEM+acolumn
	.IO_MAIN
endmacro


section 'F256LIB'

macro push('aparam')
	if upcase('aparam')='AXY'
		pha : phx : phy
	elseif upcase('aparam')='MMUIO'
		lda MMU_IO_CTRL : pha
	elseif upcase('aparam')='MMUCTRL'
		lda MMU_MEM_CTRL : pha
	endif
endmacro

macro pop('aparam')
	if upcase('aparam')='YXA'
		ply : plx : pla
	elseif upcase('aparam')='MMUIO'
		pla : sta MMU_IO_CTRL
	elseif upcase('aparam')='MMUCTRL'
		pla : sta MMU_MEM_CTRL
	endif
endmacro

macro ConvertParamToA('aparam')
	if upcase('aparam')='A'
	elseif upcase('aparam')='X'
		txa
	elseif upcase('aparam')='Y'
		tya
	elseif upcase('aparam')='YA'
	else
		if leftstr('aparam',1)='#'
			if copy('aparam',2,1) in ['"',"'"]
				lda aparam
			else
				lda #{{copy('aparam',2)}}
			endif
		else
			lda aparam
		endif
	endif
endmacro

macro ConvertParamToX('aparam')
	if upcase('aparam')='A'
		tax
	elseif upcase('aparam')='X'
	elseif upcase('aparam')='Y'
		pha
		tya
		tax
		pla
	elseif upcase('aparam')='YA'
	else
		if leftstr('aparam',1)='#'
			ldx #{{copy('aparam',2)}}
		else
			ldx aparam
		endif
	endif
endmacro

macro ConvertParamToY('aparam')
	if 'aparam'='A'
		tay
	elseif 'aparam'='X'
		txy
	elseif 'aparam'='Y'
	elseif leftstr('aparam',1)='#'
		ldy aparam
	else
		pha
		lda aparam
		tay
		pla
	endif
endmacro

macro cwbeq('aop1','aop2',abeqaddr)
    if leftstr('aop2',1)='#'
        lda aop1
        cmp #<( {{ copy('aop2',2) }} )
        bne ~pcnext4
            lda 1+aop1
            cmp #>( {{ copy('aop2',2) }} )
            beq abeqaddr
    else
        lda aop1
        cmp aop2
        bne ~pcnext4
            lda 1+aop1
            cmp 1+aop2
            beq abeqaddr
    endif
endmacro

macro cwbne('aop1','aop2',abneaddr)
    if leftstr('aop2',1)='#'
        lda aop1
        cmp #<( {{ copy('aop2',2) }} )
        bne abneaddr
        lda 1+aop1
        cmp #>( {{ copy('aop2',2) }} )
        bne abneaddr
    else
        lda aop1
        cmp aop2
        bne abneaddr
        lda 1+aop1
        cmp 1+aop2
        bne abneaddr
    endif
endmacro

macro cwblt('aop1','aop2',abltaddr)
    if leftstr('aop2',1)='#'
        lda aop1
        cmp #<( {{ copy('aop2',2) }} )
        lda 1+aop1
        sbc #>( {{ copy('aop2',2) }} )
        blt abltaddr
    else
        lda aop1
        cmp aop2
        lda 1+aop1
        sbc 1+aop2
        blt abltaddr
    endif
endmacro

macro cwbge('aop1','aop2',abgeaddr)
    if leftstr('aop2',1)='#'
        lda aop1
        cmp #<( {{ copy('aop2',2) }} )
        lda 1+aop1
        sbc #>( {{ copy('aop2',2) }} )
        bge abgeaddr
    else
        lda aop1
        cmp aop2
        lda 1+aop1
        sbc 1+aop2
        bge abgeaddr
    endif
endmacro

macro cxwbeq('aop1','aop2',abeqaddr)
    if leftstr('aop2',1)='#'
        ldx aop1
        cpx #<( {{ copy('aop2',2) }} )
        bne ~pcnext4
            ldx 1+aop1
            cpx #>( {{ copy('aop2',2) }} )
            beq abeqaddr
    else
        ldx aop1
        cpx aop2
        bne ~pcnext4
            ldx 1+aop1
            cpx 1+aop2
            beq abeqaddr
    endif
endmacro

macro cxwbne('aop1','aop2',abneaddr)
    if leftstr('aop2',1)='#'
        ldx aop1
        cpx #<( {{ copy('aop2',2) }} )
        bne abneaddr
        ldx 1+aop1
        cpx #>( {{ copy('aop2',2) }} )
        bne abneaddr
    else
        ldx aop1
        cpx aop2
        bne abneaddr
        ldx 1+aop1
        cpx 1+aop2
        bne abneaddr
    endif
endmacro

macro cywbeq('aop1','aop2',abeqaddr)
    if leftstr('aop2',1)='#'
        ldy aop1
        cpy #<( {{ copy('aop2',2) }} )
        bne ~pcnext4
            ldy 1+aop1
            cpy #>( {{ copy('aop2',2) }} )
            beq abeqaddr
    else
        ldy aop1
        cpy aop2
        bne ~pcnext4
            ldy 1+aop1
            cpy 1+aop2
            beq abeqaddr
    endif
endmacro

macro cywbne('aop1','aop2',abneaddr)
    if leftstr('aop2',1)='#'
        ldy aop1
        cpy #<( {{ copy('aop2',2) }} )
        bne abneaddr
        ldy 1+aop1
        cpy #>( {{ copy('aop2',2) }} )
        bne abneaddr
    else
        ldy aop1
        cpy aop2
        bne abneaddr
        ldy 1+aop1
        cpy 1+aop2
        bne abneaddr
    endif
endmacro

macro incw(aaddr)
	inc aaddr
	bne ~pcnext2
		inc 1+aaddr
    ;~pcnext
endmacro

macro decw(aaddr)
	pha
	lda aaddr
	bne ~pcnext2
		dec 1+aaddr
	;~pcnext2
	dec aaddr
	pla
endmacro

define IsImmed(aoperand) 'leftstr(aoperand,1)='#''
define IsAbs(aoperand) '( (length(aoperand)>0) and (leftstr(aoperand,1)<>'#') and (leftstr(aoperand,1)<>'(') and (upcase(rightstr(aoperand,2))<>'+X') and (upcase(rightstr(aoperand,2))<>'+Y') and (upcase(rightstr(aoperand,3))<>'+X)') )'
define IsAbsX(aoperand) '( (upcase(rightstr(aoperand,2))='+X') )'
define IsAbsY(aoperand) '( (upcase(rightstr(aoperand,2))='+Y') and (upcase(rightstr(aoperand,3))<>')+Y') )'
define IsInd(aoperand) '( (leftstr(aoperand,1)='(') and (rightstr(aoperand,1)=')') and (upcase(rightstr(aoperand,3))<>'+X)') )'
define IsIndX(aoperand) '( (leftstr(aoperand,1)='(') and (upcase(rightstr(aoperand,3))='+X)') )'
define IsIndY(aoperand) '( (leftstr(aoperand,1)='(') and (upcase(rightstr(aoperand,3))=')+Y') )'
define GetImmed(aoperand) 'copy(aoperand,2)'
define GetAbsXY(aoperand) 'leftstr(aoperand,length(aoperand)-2)'
define GetIndXY(aoperand) 'copy(aoperand,2,length(aoperand)-4)'
define HasPreIncX(aoperand) 'pos('++X',upcase(aoperand))>0'
define HasPreIncY(aoperand) 'pos('++Y',upcase(aoperand))>0'
define HasPostIncX(aoperand) 'pos('X++',upcase(aoperand))>0'
define HasPostIncY(aoperand) 'pos('Y++',upcase(aoperand))>0'

macro mv_all('areg','asrc','adest','aop3','aop4')
[]  @reg:='areg'
[]  @op1:='asrc'
[]  @op2:='adest'
[]  @op3:='aop3'
[]  @op4:='aop4'
[]
    if (HasPreIncX(@op2)) or (HasPreIncX(@op3)) or (HasPreIncX(@op4)) then inx
    if (HasPreIncY(@op2)) or (HasPreIncY(@op3)) or (HasPreIncY(@op4)) then iny
[]
    if IsImmed(@op1) then ld{{@reg}} #{{GetImmed(@op1)}}
    if IsAbs(@op1) then ld{{@reg}} {{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},y
    if IsInd(@op1) then ld{{@reg}} {{@op1}}
    if IsIndX(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}},x)
    if IsIndY(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}}),y
[]
    if IsImmed(@op2) then st{{@reg}} #{{GetImmed(@op2)}}
    if IsAbs(@op2) then st{{@reg}} {{@op2}}
    if IsAbsX(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},y
    if IsInd(@op2) then st{{@reg}} {{@op2}}
    if IsIndX(@op2) then st{{@reg}} ({{GetIndXY(@op2)}},x)
    if IsIndY(@op2) then st{{@reg}} ({{GetIndXY(@op2)}}),y
[]
    if (HasPostIncX(@op2)) or (HasPostIncX(@op3)) or (HasPostIncX(@op4)) then inx
    if (HasPostIncY(@op2)) or (HasPostIncY(@op3)) or (HasPostIncY(@op4)) then iny
endmacro

macro mw_all('areg','asrc','adest','aop3','aop4')
[]  @reg:='areg'
[]  @op1:='asrc'
[]  @op2:='adest'
[]  @op3:='aop3'
[]  @op4:='aop4'
[]
    if (HasPreIncX(@op2)) or (HasPreIncX(@op3)) or (HasPreIncX(@op4)) then inx
    if (HasPreIncY(@op2)) or (HasPreIncY(@op3)) or (HasPreIncY(@op4)) then iny
[];lo
    if IsImmed(@op1) then ld{{@reg}} #<({{GetImmed(@op1)}})
    if IsAbs(@op1) then ld{{@reg}} {{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},y
    if IsInd(@op1) then ld{{@reg}} {{@op1}}
    if IsIndX(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}},x)
    if IsIndY(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}}),y
[]
    if IsImmed(@op2) then st{{@reg}} #<({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} {{@op2}}
    if IsAbsX(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},y
    if IsInd(@op2) then st{{@reg}} {{@op2}}
    if IsIndX(@op2) then st{{@reg}} ({{GetIndXY(@op2)}},x)
    if IsIndY(@op2) then st{{@reg}} ({{GetIndXY(@op2)}}),y
[];hi
[];    if IsImmed(@op1) then ld{{@reg}} #>({{GetImmed(@op1)}})
[];    if IsImmed(@op1) and (<({{GetImmed(@op1)}}) != >({{GetImmed(@op1)}})) then ld{{@reg}} #>({{GetImmed(@op1)}})
    if IsImmed(@op1)
        if (<({{GetImmed(@op1)}}) != >({{GetImmed(@op1)}}))
            ld{{@reg}} #>({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 1+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
    endif
    if IsIndY(@op1)
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #>{{GetImmed(@op2)}}
    if IsAbs(@op2) then st{{@reg}} 1+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
    endif
    if IsIndY(@op2)
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
    endif
[]
    if (HasPostIncX(@op2)) or (HasPostIncX(@op3)) or (HasPostIncX(@op4)) then inx
    if (HasPostIncY(@op2)) or (HasPostIncY(@op3)) or (HasPostIncY(@op4)) then iny
endmacro

macro ml_all('areg','asrc','adest','aop3','aop4')
[]  @reg:='areg'
[]  @op1:='asrc'
[]  @op2:='adest'
[]  @op3:='aop3'
[]  @op4:='aop4'
[]
    if (HasPreIncX(@op2)) or (HasPreIncX(@op3)) or (HasPreIncX(@op4)) then inx
    if (HasPreIncY(@op2)) or (HasPreIncY(@op3)) or (HasPreIncY(@op4)) then iny
[];lo
    if IsImmed(@op1) then ld{{@reg}} #<({{GetImmed(@op1)}})
    if IsAbs(@op1) then ld{{@reg}} {{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},y
    if IsInd(@op1) then ld{{@reg}} {{@op1}}
    if IsIndX(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}},x)
    if IsIndY(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}}),y
[]
    if IsImmed(@op2) then st{{@reg}} #<({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} {{@op2}}
    if IsAbsX(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},y
    if IsInd(@op2) then st{{@reg}} {{@op2}}
    if IsIndX(@op2) then st{{@reg}} ({{GetIndXY(@op2)}},x)
    if IsIndY(@op2) then st{{@reg}} ({{GetIndXY(@op2)}}),y
[];hi
[];    if IsImmed(@op1) then ld{{@reg}} #>({{GetImmed(@op1)}})
    if IsImmed(@op1)
        if (<({{GetImmed(@op1)}}) != >({{GetImmed(@op1)}}))
            ld{{@reg}} #>({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 1+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
    endif
    if IsIndY(@op1)
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #>({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} 1+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
    endif
    if IsIndY(@op2)
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
    endif
[];bank lo
[];    if IsImmed(@op1) then ld{{@reg}} #`({{GetImmed(@op1)}})
    if IsImmed(@op1)
        if (>({{GetImmed(@op1)}}) != `({{GetImmed(@op1)}}))
            ld{{@reg}} #`({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 2+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 2+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 2+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
        dex
    endif
    if IsIndY(@op1)
        iny
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #`({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} 2+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 2+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 2+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
        dex
    endif
    if IsIndY(@op2)
        iny
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
        dey
    endif
[]
    if (HasPostIncX(@op2)) or (HasPostIncX(@op3)) or (HasPostIncX(@op4)) then inx
    if (HasPostIncY(@op2)) or (HasPostIncY(@op3)) or (HasPostIncY(@op4)) then iny
endmacro

macro md_all('areg','asrc','adest','aop3','aop4')
[]  @reg:='areg'
[]  @op1:='asrc'
[]  @op2:='adest'
[]  @op3:='aop3'
[]  @op4:='aop4'
[]
    if (HasPreIncX(@op2)) or (HasPreIncX(@op3)) or (HasPreIncX(@op4)) then inx
    if (HasPreIncY(@op2)) or (HasPreIncY(@op3)) or (HasPreIncY(@op4)) then iny
[];lo
    if IsImmed(@op1) then ld{{@reg}} #<({{GetImmed(@op1)}})
    if IsAbs(@op1) then ld{{@reg}} {{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},y
    if IsInd(@op1) then ld{{@reg}} {{@op1}}
    if IsIndX(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}},x)
    if IsIndY(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}}),y
[]
    if IsImmed(@op2) then st{{@reg}} #<({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} {{@op2}}
    if IsAbsX(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} {{GetAbsXY(@op2)}},y
    if IsInd(@op2) then st{{@reg}} {{@op2}}
    if IsIndX(@op2) then st{{@reg}} ({{GetIndXY(@op2)}},x)
    if IsIndY(@op2) then st{{@reg}} ({{GetIndXY(@op2)}}),y
[];hi
[];    if IsImmed(@op1) then ld{{@reg}} #>({{GetImmed(@op1)}})
    if (IsImmed(@op1))
        if (<({{GetImmed(@op1)}}) != >({{GetImmed(@op1)}}))
            ld{{@reg}} #>({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 1+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 1+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
    endif
    if IsIndY(@op1)
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #>({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} 1+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 1+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
    endif
    if IsIndY(@op2)
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
    endif
[];bank lo
[];    if IsImmed(@op1) then ld{{@reg}} #`({{GetImmed(@op1)}})
    if IsImmed(@op1)
        if (>({{GetImmed(@op1)}}) != `({{GetImmed(@op1)}}))
            ld{{@reg}} #`({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 2+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 2+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 2+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
        dex
    endif
    if IsIndY(@op1)
        iny
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #`({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} 2+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 2+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 2+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
        dex
    endif
    if IsIndY(@op2)
        iny
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
        dey
    endif
[];bank hi
[];    if IsImmed(@op1) then ld{{@reg}} #>hiword({{GetImmed(@op1)}})
    if IsImmed(@op1)
        if (`({{GetImmed(@op1)}}) != >hiword({{GetImmed(@op1)}}))
            ld{{@reg}} #>hiword({{GetImmed(@op1)}})
        endif
    endif
    if IsAbs(@op1) then ld{{@reg}} 3+{{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} 3+{{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} 3+{{GetAbsXY(@op1)}},y
    if IsInd(@op1)
        inc {{@op1}}
        inc {{@op1}}
        inc {{@op1}}
        ld{{@reg}} {{@op1}}
        dec {{@op1}}
        dec {{@op1}}
        dec {{@op1}}
    endif
    if IsIndX(@op1)
        inx
        inx
        inx
        ld{{@reg}} ({{GetIndXY(@op1)}},x)
        dex
        dex
        dex
    endif
    if IsIndY(@op1)
        iny
        iny
        iny
        ld{{@reg}} ({{GetIndXY(@op1)}}),y
        dey
        dey
        dey
    endif
[]
    if IsImmed(@op2) then st{{@reg}} #>hiword({{GetImmed(@op2)}})
    if IsAbs(@op2) then st{{@reg}} 3+{{@op2}}
    if IsAbsX(@op2) then st{{@reg}} 3+{{GetAbsXY(@op2)}},x
    if IsAbsY(@op2) then st{{@reg}} 3+{{GetAbsXY(@op2)}},y
    if IsInd(@op2)
        inc {{@op2}}
        inc {{@op2}}
        inc {{@op2}}
        st{{@reg}} {{@op2}}
        dec {{@op2}}
        dec {{@op2}}
        dec {{@op2}}
    endif
    if IsIndX(@op2)
        inx
        inx
        inx
        st{{@reg}} ({{GetIndXY(@op2)}},x)
        dex
        dex
        dex
    endif
    if IsIndY(@op2)
        iny
        iny
        iny
        st{{@reg}} ({{GetIndXY(@op2)}}),y
        dey
        dey
        dey
    endif
[]
    if (HasPostIncX(@op2)) or (HasPostIncX(@op3)) or (HasPostIncX(@op4)) then inx
    if (HasPostIncY(@op2)) or (HasPostIncY(@op3)) or (HasPostIncY(@op4)) then iny
endmacro

macro mva('asrc','adest','aop3','aop4')
[]    mv_all(a,asrc,adest,aop3,aop4)
endmacro
macro mwa('asrc','adest','aop3','aop4')
[]    mw_all(a,asrc,adest,aop3,aop4)
endmacro
macro mla('asrc','adest','aop3','aop4')
[]    ml_all(a,asrc,adest,aop3,aop4)
endmacro
macro mda('asrc','adest','aop3','aop4')
[]    md_all(a,asrc,adest,aop3,aop4)
endmacro

macro mvx('asrc','adest','aop3','aop4')
[]    mv_all(x,asrc,adest,aop3,aop4)
endmacro
macro mwx('asrc','adest','aop3','aop4')
[]    mw_all(x,asrc,adest,aop3,aop4)
endmacro
macro mlx('asrc','adest','aop3','aop4')
[]    ml_all(x,asrc,adest,aop3,aop4)
endmacro
macro mdx('asrc','adest','aop3','aop4')
[]    md_all(x,asrc,adest,aop3,aop4)
endmacro

macro mvy('asrc','adest','aop3','aop4')
[]    mv_all(y,asrc,adest,aop3,aop4)
endmacro
macro mwy('asrc','adest','aop3','aop4')
[]    mw_all(y,asrc,adest,aop3,aop4)
endmacro
macro mly('asrc','adest','aop3','aop4')
[]    ml_all(y,asrc,adest,aop3,aop4)
endmacro
macro mdy('asrc','adest','aop3','aop4')
[]    md_all(y,asrc,adest,aop3,aop4)
endmacro
/*
macro movb('asrc','adest','aop3','aop4')
    mv_all(a,asrc,adest,aop3,aop4)
endmacro
macro movw('asrc','adest','aop3','aop4')
    mw_all(a,asrc,adest,aop3,aop4)
endmacro
macro movl('asrc','adest','aop3','aop4')
    ml_all(a,asrc,adest,aop3,aop4)
endmacro
macro movd('asrc','adest','aop3','aop4')
    md_all(a,asrc,adest,aop3,aop4)
endmacro
macro movbx('asrc','adest','aop3','aop4')
    mv_all(x,asrc,adest,aop3,aop4)
endmacro
macro movwx('asrc','adest','aop3','aop4')
    mw_all(x,asrc,adest,aop3,aop4)
endmacro
macro movlx('asrc','adest','aop3','aop4')
    ml_all(x,asrc,adest,aop3,aop4)
endmacro
macro movdx('asrc','adest','aop3','aop4')
    md_all(x,asrc,adest,aop3,aop4)
endmacro
macro movby('asrc','adest','aop3','aop4')
    mv_all(y,asrc,adest,aop3,aop4)
endmacro
macro movbw('asrc','adest','aop3','aop4')
    mw_all(y,asrc,adest,aop3,aop4)
endmacro
macro movly('asrc','adest','aop3','aop4')
    ml_all(y,asrc,adest,aop3,aop4)
endmacro
macro movdy('asrc','adest','aop3','aop4')
    md_all(y,asrc,adest,aop3,aop4)
endmacro
*/

/* REMOVED, not very useful
macro cm_all('areg','asrc','acomp','aop3','aop4')
[]  @reg:='areg'
[]  @op1:='asrc'
[]  @op2:='acomp'
[]  @op3:='aop3'
[]  @op4:='aop4'
[]
    if (HasPreIncX(@op2)) or (HasPreIncX(@op3)) or (HasPreIncX(@op4)) then inx
    if (HasPreIncY(@op2)) or (HasPreIncY(@op3)) or (HasPreIncY(@op4)) then iny
[]
    if IsImmed(@op1) then ld{{@reg}} #{{GetImmed(@op1)}}
    if IsAbs(@op1) then ld{{@reg}} {{@op1}}
    if IsAbsX(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},x
    if IsAbsY(@op1) then ld{{@reg}} {{GetAbsXY(@op1)}},y
    if IsInd(@op1) then ld{{@reg}} {{@op1}}
    if IsIndX(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}},x)
    if IsIndY(@op1) then ld{{@reg}} ({{GetIndXY(@op1)}}),y
[]
    if 'areg'='a'
        if IsImmed(@op2) then cmp #{{GetImmed(@op2)}}
        if IsAbs(@op2) then cmp {{@op2}}
        if IsAbsX(@op2) then cmp {{GetAbsXY(@op2)}},x
        if IsAbsY(@op2) then cmp {{GetAbsXY(@op2)}},y
        if IsInd(@op2) then cmp {{@op2}}
        if IsIndX(@op2) then cmp ({{GetIndXY(@op2)}},x)
        if IsIndY(@op2) then cmp ({{GetIndXY(@op2)}}),y
    endif
    if 'areg'='X'
        if IsImmed(@op2) then cpx #{{GetImmed(@op2)}}
        if IsAbs(@op2) then cpx {{@op2}}
        if IsAbsX(@op2) then cpx {{GetAbsXY(@op2)}},x
        if IsAbsY(@op2) then cpx {{GetAbsXY(@op2)}},y
        if IsInd(@op2) then cpx {{@op2}}
        if IsIndX(@op2) then cpx ({{GetIndXY(@op2)}},x)
        if IsIndY(@op2) then cpx ({{GetIndXY(@op2)}}),y
    endif
    if 'areg'='Y'
        if IsImmed(@op2) then cpy #{{GetImmed(@op2)}}
        if IsAbs(@op2) then cpy {{@op2}}
        if IsAbsX(@op2) then cpy {{GetAbsXY(@op2)}},x
        if IsAbsY(@op2) then cpy {{GetAbsXY(@op2)}},y
        if IsInd(@op2) then cpy {{@op2}}
        if IsIndX(@op2) then cpy ({{GetIndXY(@op2)}},x)
        if IsIndY(@op2) then cpy ({{GetIndXY(@op2)}}),y
    endif
[]
    if (HasPostIncX(@op2)) or (HasPostIncX(@op3)) or (HasPostIncX(@op4)) then inx
    if (HasPostIncY(@op2)) or (HasPostIncY(@op3)) or (HasPostIncY(@op4)) then iny
endmacro

macro cma('asrc','acomp','aop3','aop4')
[]    cm_all(a,asrc,acomp,aop3,aop4)
endmacro
*/


macro ldax('arega','aregx')
    if ~argcount=2
[]      @oprega:='arega'
[]      @opregx:='aregx'
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
    else
        error 'expecting two arguments'
    endif
endmacro

macro ldxa('aregx','arega')
    if ~argcount=2
[]      @oprega:='arega'
[]      @opregx:='aregx'
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
    else
        error 'expecting two arguments'
    endif
endmacro

macro lday('arega','aregy')
    if ~argcount=2
[]      @oprega:='arega'
[]      @opregy:='aregy'
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
    else
        error 'expecting two arguments'
    endif
endmacro

macro ldya('aregy','arega')
    if ~argcount=2
[]      @oprega:='arega'
[]      @opregy:='aregy'
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
    else
        error 'expecting two arguments'
    endif
endmacro

macro ldxy('aregx','aregy')
    if ~argcount=2
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
    else
        error 'expecting two arguments'
    endif
endmacro

macro ldyx('aregy','aregx')
    if ~argcount=2
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
    else
        error 'expecting two arguments'
    endif
endmacro

macro ldaxy('arega','aregx','aregy')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
    else
        error 'expecting three arguments'
    endif
endmacro

macro ldayx('arega','aregy','aregx')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
    else
        error 'expecting three arguments'
    endif
endmacro

macro ldxay('aregx','arega','aregy')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
    else
        error 'expecting three arguments'
    endif
endmacro

macro ldxya('aregx','aregy','arega')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
    else
        error 'expecting three arguments'
    endif
endmacro

macro ldyax('aregy','arega','aregx')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
    else
        error 'expecting three arguments'
    endif
endmacro

macro ldyxa('aregy','aregx','arega')
    if ~argcount=3
[]      @oprega:='arega'
[]      @opregx:='aregx'
[]      @opregy:='aregy'
        if IsImmed(@opregy) then ldy #{{ copy(@opregy,2) }} else ldy aregy
        if IsImmed(@opregx) then ldx #{{ copy(@opregx,2) }} else ldx aregx
        if IsImmed(@oprega) then lda #{{ copy(@oprega,2) }} else lda arega
    else
        error 'expecting three arguments'
    endif
endmacro

macro stax('arega','aregx')
    if ~argcount=2
        sta arega
        stx aregx
    else
        error 'expecting two arguments'
    endif
endmacro

macro stxa('aregx','arega')
    if ~argcount=2
        stx aregx
        sta arega
    else
        error 'expecting two arguments'
    endif
endmacro

macro stay('arega','aregy')
    if ~argcount=2
        sta arega
        sty aregy
    else
        error 'expecting two arguments'
    endif
endmacro

macro stya('aregy','arega')
    if ~argcount=2
        sty aregy
        sta arega
    else
        error 'expecting two arguments'
    endif
endmacro

macro stxy('aregx','aregy')
    if ~argcount=2
        stx aregx
        sty aregy
    else
        error 'expecting two arguments'
    endif
endmacro

macro styx('aregy','aregx')
    if ~argcount=2
        sty aregy
        stx aregx
    else
        error 'expecting two arguments'
    endif
endmacro

macro staxy('arega','aregx','aregy')
    if ~argcount=3
        sta arega
        stx aregx
        sty aregy
    else
        error 'expecting three arguments'
    endif
endmacro

macro stayx('arega','aregy','aregx')
    if ~argcount=3
        sta arega
        sty aregy
        stx aregx
    else
        error 'expecting three arguments'
    endif
endmacro

macro stxay('aregx','arega','aregy')
    if ~argcount=3
        stx aregx
        sta arega
        sty aregy
    else
        error 'expecting three arguments'
    endif
endmacro

macro stxya('aregx','aregy','arega')
    if ~argcount=3
        stx aregx
        sty aregy
        sta arega
    else
        error 'expecting three arguments'
    endif
endmacro

macro styax('aregy','arega','aregx')
    if ~argcount=3
        sty aregy
        sta arega
        stx aregx
    else
        error 'expecting three arguments'
    endif
endmacro

macro styxa('aregy','aregx','arega')
    if ~argcount=3
        sty aregy
        stx aregx
        sta arega
    else
        error 'expecting three arguments'
    endif
endmacro

macro ConvertAddressingPlusToComma('aop1','aout')
            if (upcase(rightstr('aop1',2))='+X') or (upcase(rightstr('aop1',2))='+Y')
[]              aout:=leftstr('aop1',length('aop1')-2)+','+rightstr('aop1',1)
            elseif (leftstr('aop1',1)='(') and (upcase(rightstr('aop1',3))='+X)')
[]              aout:=leftstr('aop1',length('aop1')-3)+','+rightstr('aop1',2)
            elseif (leftstr('aop1',1)='(') and (upcase(rightstr('aop1',3))=')+Y')
[]              aout:=leftstr('aop1',length('aop1')-2)+','+rightstr('aop1',1)
            else
[]              aout:='aop1'
            endif
endmacro

macro adcw('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda #<(..@op1..)
            adc .. @op2 ..
            sta ..@op2..
            lda #>(..@op1..)
            adc 1+..@op2..
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op2 ..
            lda 1+.. @op1 ..
            adc 1+.. @op2 ..
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(..@op1..)
            adc ..@op2..
            sta ..@op3..
            lda #>(..@op1..)
            adc 1+..@op2..
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            adc #<(..@op2..)
            sta ..@op3..
            lda 1+..@op1..
            adc #>(..@op2..)
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op3 ..
            lda 1+.. @op1 ..
            adc 1+.. @op2 ..
            sta 1+.. @op3 ..
        endif
    endif
endmacro

macro adcbw('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda #<(..@op1..)
            adc .. @op2 ..
            sta ..@op2..
            lda #0
            adc 1+..@op2..
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op2 ..
            lda #0
            adc 1+.. @op2 ..
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(.. @op1 ..)
            adc ..@op2..
            sta ..@op3..
            lda #0
            adc 1+..@op2..
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            adc #<(..@op2..)
            sta ..@op3..
            lda #0
            adc #>(..@op2..)
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op3 ..
            lda #0
            adc 1+.. @op2 ..
            sta 1+.. @op3 ..
        endif
    endif
endmacro

macro adcwb('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda #<(..@op1..)
            adc .. @op2 ..
            sta ..@op2..
            lda #>(..@op1..)
            adc #0
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op2 ..
            lda 1+.. @op1 ..
            adc #0
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(..@op1..)
            adc ..@op2..
            sta ..@op3..
            lda #>(..@op1..)
            adc #0
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            adc #<(..@op2..)
            sta ..@op3..
            lda 1+..@op1..
            adc #0
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            adc .. @op2 ..
            sta .. @op3 ..
            lda 1+.. @op1 ..
            adc #0
            sta 1+.. @op3 ..
        endif
    endif
endmacro

macro sbcw('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda .. @op2 ..
            sbc #<(..@op1..)
            sta ..@op2..
            lda 1+..@op2..
            sbc #>..@op1..
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op2 ..
            sbc .. @op1 ..
            sta .. @op2 ..
            lda 1+.. @op2 ..
            sbc 1+.. @op1 ..
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(.. @op1 ..)
            sbc ..@op2..
            sta ..@op3..
            lda #>..@op1..
            sbc 1+..@op2..
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            sbc #<(..@op2..)
            sta ..@op3..
            lda 1+..@op1..
            sbc #>..@op2..
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            sbc .. @op2 ..
            sta .. @op3 ..
            lda 1+.. @op1 ..
            sbc 1+.. @op2 ..
            sta 1+.. @op3 ..
        endif
    endif
endmacro

macro sbcbw('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda .. @op2 ..
            sbc #<(..@op1..)
            sta ..@op2..
            lda 1+..@op2..
            sbc #0
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op2 ..
            sbc .. @op1 ..
            sta .. @op2 ..
            lda 1+.. @op2 ..
            sbc #0
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(.. @op1 ..)
            sbc ..@op2..
            sta ..@op3..
            lda #0
            sbc 1+..@op2..
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            sbc #<(..@op2..)
            sta ..@op3..
            lda #0
            sbc #>..@op2..
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            sbc .. @op2 ..
            sta .. @op3 ..
            lda #0
            sbc 1+.. @op2 ..
            sta 1+.. @op3 ..
        endif
    endif
endmacro

macro sbcwb('aop1','aop2','aop3')
    if ~argcount=2
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
            lda .. @op2 ..
            sbc #<(..@op1..)
            sta ..@op2..
            lda 1+..@op2..
            sbc #0
            sta 1+..@op2..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
            lda .. @op2 ..
            sbc .. @op1 ..
            sta .. @op2 ..
            lda 1+.. @op2 ..
            sbc #0
            sta 1+.. @op2 ..
        endif
    elseif ~argcount=3
        if IsImmed('aop1')
[]          @op1:=copy('aop1',2)
[]          @op2:='aop2'
[]          @op3:='aop3'
            lda #<(.. @op1 ..)
            sbc ..@op2..
            sta ..@op3..
            lda #>..@op1..
            sbc #0
            sta 1+..@op3..
        elseif IsImmed('aop2')
[]          @op1:='aop1'
[]          @op2:=copy('aop2',2)
[]          @op3:='aop3'
            lda .. @op1 ..
            sbc #<(..@op2..)
            sta ..@op3..
            lda 1+..@op1..
            sbc #0
            sta 1+..@op3..
        else
[]          ConvertAddressingPlusToComma([aop1],@op1)
[]          ConvertAddressingPlusToComma([aop2],@op2)
[]          ConvertAddressingPlusToComma([aop3],@op3)
            lda .. @op1 ..
            sbc .. @op2 ..
            sta .. @op3 ..
            lda 1+.. @op1 ..
            sbc #0
            sta 1+.. @op3 ..
        endif
    endif
endmacro

;.comment *** removed

macro movb('asrc','adest','adelta1','adelta2')
[]  @ssrc='asrc'
[]  @sdest='adest'
    if (upcase('adelta1')='++X') or (upcase('adelta2')='++X') then inx
    if (upcase('adelta1')='--X') or (upcase('adelta2')='--X') then dex
    if (upcase('adelta1')='++Y') or (upcase('adelta2')='++Y') then iny
    if (upcase('adelta1')='--Y') or (upcase('adelta2')='--Y') then dey
	if leftstr(@ssrc,1)='#'
[]		@oplda=copy(@ssrc,2)
[]		; source immediate
		if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
[]			; destination indirect x
[]			@opsta=copy(@sdest,2,length(@sdest)-4)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
		elseif upcase(rightstr(@sdest,2))='+X'
[]			; destination absolute x
[]			@opsta=leftstr(@sdest,length(@sdest)-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
		elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]			; destination indirect y
[]			@opsta=copy(@sdest,2,length(@sdest)-4)
			lda #<({{ @oplda }})
			sta ({{ @opsta }}),y
		elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]			; destination indirect
[]			@opsta=copy(@sdest,2,length(@sdest)-2)
			lda #<({{ @oplda }})
			sta ({{ @opsta }})
		elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]			; destination absolute y
[]			@opsta=leftstr(@sdest,length(@sdest)-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},y
		else
[]			; destination absolute
			lda #<({{ @oplda }})
			sta adest
		endif
	else
		if (leftstr(@ssrc,1)='(') and (upcase(rightstr(@ssrc,3))='+X)')
[]			@oplda=copy(@ssrc,2,length(@ssrc)-4)
[]			; source indirect x
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda ({{ @oplda }},x)
				sta adest
			endif
		elseif (leftstr(@ssrc,1)='(') and (upcase(rightstr(@ssrc,1))=')')
[]			@oplda=copy(@ssrc,2,length(@ssrc)-2)
[]			; source indirect
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }})
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }})
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }})
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda ({{ @oplda }})
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }})
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda ({{ @oplda }})
				sta adest
			endif
		elseif upcase(rightstr(@ssrc,2))='+X'
[]			; source absolute x
[]			@oplda=leftstr(@ssrc,length(@ssrc)-2)
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
[]				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda {{ @oplda }},x
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},x
				sta adest
			endif
		elseif (leftstr(@ssrc,1)='(') and (upcase(rightstr(@ssrc,3))=')+Y')
[]			; source indirect y
[]			@oplda=copy(@ssrc,2,length(@ssrc)-4)
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
[]				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda ({{ @oplda }}),y
				sta adest
			endif
		elseif (leftstr(@ssrc,1)<>'(') and (upcase(rightstr(@ssrc,2))='+Y')
[]			; source absolute y
[]			@oplda=leftstr(@ssrc,length(@ssrc)-2)
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
[]				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda {{ @oplda }},y
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},y
				sta adest
			endif
		else
[]			; source absolute
[]			@oplda=asrc
			if (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))='+X)')
[]				; destination indirect x
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda @oplda
				sta ({{ @opsta }},x)
			elseif upcase(rightstr(@sdest,2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda @oplda
				sta {{ @opsta }},x
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy(@sdest,2,length(@sdest)-4)
				lda @oplda
				sta ({{ @opsta }}),y
			elseif (leftstr(@sdest,1)='(') and (upcase(rightstr(@sdest,1))=')')
[]				; destination indirect
[]				@opsta=copy(@sdest,2,length(@sdest)-2)
				lda @oplda
				sta ({{ @opsta }})
			elseif (leftstr(@sdest,1)<>'(') and (upcase(rightstr(@sdest,2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr(@sdest,length(@sdest)-2)
				lda @oplda
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda @oplda
				sta adest
			endif
		endif
	endif
    if (upcase('adelta1')='X++') or (upcase('adelta2')='X++') then inx
    if (upcase('adelta1')='X--') or (upcase('adelta2')='X--') then dex
    if (upcase('adelta1')='Y++') or (upcase('adelta2')='Y++') then iny
    if (upcase('adelta1')='Y--') or (upcase('adelta2')='Y--') then dey
endmacro

/*
macro movb('asrc','adest','adelta1','adelta2')
	if leftstr('asrc',1)='#'
[]		@oplda=copy('asrc',2)
[]		; source immediate
		if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]			; destination indirect x
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
		elseif upcase(rightstr('adest',2))='+X'
[]			; destination absolute x
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
		elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]			; destination indirect y
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta ({{ @opsta }}),y
		elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]			; destination indirect
[]			@opsta=copy('adest',2,length('adest')-2)
			lda #<({{ @oplda }})
			sta ({{ @opsta }})
		elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]			; destination absolute y
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},y
		else
[]			; destination absolute
			lda #<({{ @oplda }})
			sta adest
		endif
	else
		if (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))='+X)')
[]			@oplda=copy('asrc',2,length('asrc')-4)
[]			; source indirect x
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]				; destination indirect
[]				@opsta=copy('adest',2,length('adest')-2)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }})
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda ({{ @oplda }},x)
				sta adest
			endif
		elseif upcase(rightstr('asrc',2))='+X'
[]			; source absolute x
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }}),y
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]				; destination indirect
[]				@opsta=copy('adest',2,length('adest')-2)
				lda {{ @oplda }},x
				sta ({{ @opsta }})
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},x
				sta adest
			endif
		elseif (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))=')+Y')
[]			; source indirect y
[]			@oplda=copy('asrc',2,length('asrc')-4)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]				; destination indirect
[]				@opsta=copy('adest',2,length('adest')-2)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }})
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda ({{ @oplda }}),y
				sta adest
			endif
		elseif (leftstr('asrc',1)<>'(') and (upcase(rightstr('asrc',2))='+Y')
[]			; source absolute y
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }},x)
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]				; destination indirect
[]				@opsta=copy('adest',2,length('adest')-2)
				lda {{ @oplda }},y
				sta ({{ @opsta }})
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},y
				sta adest
			endif
		else
[]			; source absolute
[]			@oplda=asrc
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }},x)
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }}),y
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',1))=')')
[]				; destination indirect
[]				@opsta=copy('adest',2,length('adest')-2)
				lda @oplda
				sta ({{ @opsta }})
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},y
			else
[]				; destination absolute
				lda @oplda
				sta adest
			endif
		endif
	endif
endmacro
*/

macro movw('asrc','adest')
	if leftstr('asrc',1)='#'
[]		@oplda=copy('asrc',2)
[]		; source immediate
		if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]			; destination indirect x
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			inx
			if <{{ @oplda }} != >{{ @oplda }}
				lda #>({{ @oplda }})
			endif
			sta ({{ @opsta }},x)
			dex
		elseif upcase(rightstr('adest',2))='+X'
[]			; destination absolute x
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			if <({{ @oplda }}) != >({{ @oplda }})
				lda #>({{ @oplda }})
			endif
			sta 1+{{ @opsta }},x
		elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]			; destination indirect y
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			if <({{ @oplda }}) != >({{ @oplda }})
				lda #>({{ @oplda }})
			endif
			sta ({{ @opsta }}),y
			dey
		elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]			; destination absolute y
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},y
			if <({{ @oplda }}) != >({{ @oplda }})
				lda #>({{ @oplda }})
			endif
			sta 1+{{ @opsta }},y
		else
[]			; destination absolute
			lda #<({{ @oplda }})
			sta adest
			if <({{ @oplda }}) != >({{ @oplda }})
				lda #>({{ @oplda }})
			endif
			sta 1+adest
		endif
	else
		if (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))='+X)')
[]			@oplda=copy('asrc',2,length('asrc')-4)
[]			; source indirect x
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				dex
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				dex
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},y
				inx
				lda ({{ @oplda }},x)
				sta 1+{{ @opsta }},y
				dex
			else
[]				; destination absolute
				lda ({{ @oplda }},x)
				sta adest
				inx
				lda ({{ @oplda }},x)
				sta 1+adest
				dex
			endif
		elseif upcase(rightstr('asrc',2))='+X'
[]			; source absolute x
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 1+{{ @oplda }},x
				sta ({{ @opsta }}),y
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},x
				sta adest
				lda 1+{{ @oplda }},x
				sta 1+adest
			endif
		elseif (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))=')+Y')
[]			; source indirect y
[]			@oplda=copy('asrc',2,length('asrc')-4)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				dex
				dey
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 1+{{ @opsta }},x
				dey
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				dey
			else
[]				; destination absolute
				lda ({{ @oplda }}),y
				sta adest
				iny
				lda ({{ @oplda }}),y
				sta 1+adest
				dey
			endif
		elseif (leftstr('asrc',1)<>'(') and (upcase(rightstr('asrc',2))='+Y')
[]			; source absolute y
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 1+{{ @oplda }},y
				sta ({{ @opsta }},x)
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},y
				sta adest
				lda 1+{{ @oplda }},y
				sta 1+adest
			endif
		else
[]			; source absolute
[]			@oplda=asrc
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }},x)
				inx
				lda 1+@oplda
				sta ({{ @opsta }},x)
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},x
				lda 1+@oplda
				sta 1+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }}),y
				iny
				lda 1+@oplda
				sta ({{ @opsta }}),y
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},y
				lda 1+@oplda
				sta 1+{{ @opsta }},y
			else
[]				; destination absolute
				lda @oplda
				sta adest
				lda 1+@oplda
				sta 1+adest
			endif
		endif
	endif
endmacro

macro movl('asrc','adest')
	if leftstr('asrc',1)='#'
[]		@oplda=copy('asrc',2)
[]		; source immediate
		if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]			; destination indirect x
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			inx
			lda #>({{ @oplda }})
			sta ({{ @opsta }},x)
			inx
			lda #`({{ @oplda }})
			sta ({{ @opsta }},x)
			dex
			dex
		elseif upcase(rightstr('adest',2))='+X'
[]			; destination absolute x
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			lda #>({{ @oplda }})
			sta 1+{{ @opsta }},x
			lda #`({{ @oplda }})
			sta 2+{{ @opsta }},x
		elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]			; destination indirect y
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			lda #>({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			lda #`({{ @oplda }})
			sta ({{ @opsta }}),y
			dey
			dey
		elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]			; destination absolute y
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},y
			lda #>({{ @oplda }})
			sta 1+{{ @opsta }},y
			lda #`({{ @oplda }})
			sta 2+{{ @opsta }},y
		else
[]			; destination absolute
			lda #<({{ @oplda }})
			sta adest
			lda #>({{ @oplda }})
			sta 1+adest
			lda #`({{ @oplda }})
			sta 2+adest
		endif
	else
		if (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))='+X)')
[]			@oplda=copy('asrc',2,length('asrc')-4)
[]			; source indirect x
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				dex
				dex
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				dex
				dey
				dex
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
				lda ({{ @oplda }},x)
				sta adest,y
				inx
				lda ({{ @oplda }},x)
				sta 1+adest,y
				inx
				lda ({{ @oplda }},x)
				sta 2+adest,y
				dex
				dex
			else
[]				; destination absolute
				lda ({{ @oplda }},x)
				sta adest
				inx
				lda ({{ @oplda }},x)
				sta 1+adest
				inx
				lda ({{ @oplda }},x)
				sta 2+adest
				dex
				dex
			endif
		elseif upcase(rightstr('asrc',2))='+X'
[]			; source absolute x
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},x
				lda 2+{{ @oplda }},x
				sta 2+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 1+{{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 2+{{ @oplda }},x
				sta ({{ @opsta }}),y
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},y
				lda 2+{{ @oplda }},x
				sta 2+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},x
				sta adest
				lda 1+{{ @oplda }},x
				sta 1+adest
				lda 2+{{ @oplda }},x
				sta 2+adest
			endif
		elseif (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))=')+Y')
[]			; source indirect y
[]			@oplda=copy('asrc',2,length('asrc')-4)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				dex
				dey
				dex
				dey
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 1+{{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 2+{{ @opsta }},x
				dey
				dey
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				dey
				dey
			else
[]				; destination absolute
				lda ({{ @oplda }}),y
				sta adest
				iny
				lda ({{ @oplda }}),y
				sta 1+adest
				iny
				lda ({{ @oplda }}),y
				sta 2+adest
				dey
				dey
			endif
		elseif (leftstr('asrc',1)<>'(') and (upcase(rightstr('asrc',2))='+Y')
[]			; source absolute y
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 1+{{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 2+{{ @oplda }},y
				sta ({{ @opsta }},x)
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},x
				lda 2+{{ @oplda }},y
				sta 2+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},y
				lda 2+{{ @oplda }},y
				sta 2+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},y
				sta adest
				lda 1+{{ @oplda }},y
				sta 1+adest
				lda 2+{{ @oplda }},y
				sta 2+adest
			endif
		else
[]			; source absolute
[]			@oplda=asrc
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }},x)
				inx
				lda 1+@oplda
				sta ({{ @opsta }},x)
				inx
				lda 2+@oplda
				sta ({{ @opsta }},x)
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},x
				lda 1+@oplda
				sta 1+{{ @opsta }},x
				lda 2+@oplda
				sta 2+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }}),y
				iny
				lda 1+@oplda
				sta ({{ @opsta }}),y
				iny
				lda 2+@oplda
				sta ({{ @opsta }}),y
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},y
				lda 1+@oplda
				sta 1+{{ @opsta }},y
				lda 2+@oplda
				sta 2+{{ @opsta }},y
			else
[]				; destination absolute
				lda @oplda
				sta adest
				lda 1+@oplda
				sta 1+adest
				lda 2+@oplda
				sta 2+adest
			endif
		endif
	endif
endmacro

macro movdw('asrc','adest')
	if leftstr('asrc',1)='#'
[]		@oplda=copy('asrc',2)
[]		; source immediate
		if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]			; destination indirect x
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			inx
			lda #>({{ @oplda }})
			sta ({{ @opsta }},x)
			inx
			lda #`({{ @oplda }})
			sta ({{ @opsta }},x)
			inx
			lda #>hiword({{ @oplda }})
			sta ({{ @opsta }},x)
			dex
			dex
			dex
		elseif upcase(rightstr('adest',2))='+X'
[]			; destination absolute x
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},x
			lda #>({{ @oplda }})
			sta 1+{{ @opsta }},x
			lda #`({{ @oplda }})
			sta 2+{{ @opsta }},x
			lda #>hiword({{ @oplda }})
			sta 3+{{ @opsta }},x
		elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]			; destination indirect y
[]			@opsta=copy('adest',2,length('adest')-4)
			lda #<({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			lda #>({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			lda #`({{ @oplda }})
			sta ({{ @opsta }}),y
			iny
			lda #>hiword({{ @oplda }})
			sta ({{ @opsta }}),y
			dey
			dey
			dey
		elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]			; destination absolute y
[]			@opsta=leftstr('adest',length('adest')-2)
			lda #<({{ @oplda }})
			sta {{ @opsta }},y
			lda #>({{ @oplda }})
			sta 1+{{ @opsta }},y
			lda #`({{ @oplda }})
			sta 2+{{ @opsta }},y
			lda #>hiword({{ @oplda }})
			sta 3+{{ @opsta }},y
		else
[]			; destination absolute
			lda #<({{ @oplda }})
			sta adest
			lda #>({{ @oplda }})
			sta 1+adest
			lda #`({{ @oplda }})
			sta 2+adest
			lda #>hiword({{ @oplda }})
			sta 3+adest
		endif
	else
		if (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))='+X)')
[]			@oplda=copy('asrc',2,length('asrc')-4)
[]			; source indirect x
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				inx
				lda ({{ @oplda }},x)
				sta ({{ @opsta }},x)
				dex
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				inx
				lda ({{ @oplda }},x)
				sta {{ @opsta }},x
				dex
				dex
				dex
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				inx
				iny
				lda ({{ @oplda }},x)
				sta ({{ @opsta }}),y
				dex
				dey
				dex
				dey
				dex
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }},x)
				sta {{ @opsta }},y
				inx
				lda ({{ @oplda }},x)
				sta 1+{{ @opsta }},y
				inx
				lda ({{ @oplda }},x)
				sta 2+{{ @opsta }},y
				inx
				lda ({{ @oplda }},x)
				sta 3+{{ @opsta }},y
				dex
				dex
				dex
			else
[]				; destination absolute
				lda ({{ @oplda }},x)
				sta adest
				inx
				lda ({{ @oplda }},x)
				sta 1+adest
				inx
				lda ({{ @oplda }},x)
				sta 2+adest
				inx
				lda ({{ @oplda }},x)
				sta 3+adest
				dex
				dex
				dex
			endif
		elseif upcase(rightstr('asrc',2))='+X'
[]			; source absolute x
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				inx
				lda {{ @oplda }},x
				sta ({{ @opsta }},x)
				dex
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},x
				lda 2+{{ @oplda }},x
				sta 2+{{ @opsta }},x
				lda 3+{{ @oplda }},x
				sta 3+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 1+{{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 2+{{ @oplda }},x
				sta ({{ @opsta }}),y
				iny
				lda 3+{{ @oplda }},x
				sta ({{ @opsta }}),y
				dey
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},x
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},x
				sta 1+{{ @opsta }},y
				lda 2+{{ @oplda }},x
				sta 2+{{ @opsta }},y
				lda 3+{{ @oplda }},x
				sta 3+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},x
				sta adest
				lda 1+{{ @oplda }},x
				sta 1+adest
				lda 2+{{ @oplda }},x
				sta 2+adest
				lda 3+{{ @oplda }},x
				sta 3+adest
			endif
		elseif (leftstr('asrc',1)='(') and (upcase(rightstr('asrc',3))=')+Y')
[]			; source indirect y
[]			@oplda=copy('asrc',2,length('asrc')-4)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				inx
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }},x)
				dex
				dey
				dex
				dey
				dex
				dey
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 1+{{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 2+{{ @opsta }},x
				iny
				lda ({{ @oplda }}),y
				sta 3+{{ @opsta }},x
				dey
				dey
				dey
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				iny
				lda ({{ @oplda }}),y
				sta ({{ @opsta }}),y
				dey
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				iny
				lda ({{ @oplda }}),y
				sta {{ @opsta }},y
				dey
				dey
				dey
			else
[]				; destination absolute
				lda ({{ @oplda }}),y
				sta adest
				iny
				lda ({{ @oplda }}),y
				sta 1+adest
				iny
				lda ({{ @oplda }}),y
				sta 2+adest
				iny
				lda ({{ @oplda }}),y
				sta 3+adest
				dey
				dey
				dey
			endif
		elseif (leftstr('asrc',1)<>'(') and (upcase(rightstr('asrc',2))='+Y')
[]			; source absolute y
[]			@oplda=leftstr('asrc',length('asrc')-2)
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 1+{{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 2+{{ @oplda }},y
				sta ({{ @opsta }},x)
				inx
				lda 3+{{ @oplda }},y
				sta ({{ @opsta }},x)
				dex
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},x
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},x
				lda 2+{{ @oplda }},y
				sta 2+{{ @opsta }},x
				lda 3+{{ @oplda }},y
				sta 3+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				iny
				lda {{ @oplda }},y
				sta ({{ @opsta }}),y
				dey
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda {{ @oplda }},y
				sta {{ @opsta }},y
				lda 1+{{ @oplda }},y
				sta 1+{{ @opsta }},y
				lda 2+{{ @oplda }},y
				sta 2+{{ @opsta }},y
				lda 3+{{ @oplda }},y
				sta 3+{{ @opsta }},y
			else
[]				; destination absolute
				lda {{ @oplda }},y
				sta adest
				lda 1+{{ @oplda }},y
				sta 1+adest
				lda 2+{{ @oplda }},y
				sta 2+adest
				lda 3+{{ @oplda }},y
				sta 3+adest
			endif
		else
[]			; source absolute
[]			@oplda=asrc
			if (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))='+X)')
[]				; destination indirect x
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }},x)
				inx
				lda 1+@oplda
				sta ({{ @opsta }},x)
				inx
				lda 2+@oplda
				sta ({{ @opsta }},x)
				inx
				lda 3+@oplda
				sta ({{ @opsta }},x)
				dex
				dex
				dex
			elseif upcase(rightstr('adest',2))='+X'
[]				; destination absolute x
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},x
				lda 1+@oplda
				sta 1+{{ @opsta }},x
				lda 2+@oplda
				sta 2+{{ @opsta }},x
				lda 3+@oplda
				sta 3+{{ @opsta }},x
			elseif (leftstr('adest',1)='(') and (upcase(rightstr('adest',3))=')+Y')
[]				; destination indirect y
[]				@opsta=copy('adest',2,length('adest')-4)
				lda @oplda
				sta ({{ @opsta }}),y
				iny
				lda 1+@oplda
				sta ({{ @opsta }}),y
				iny
				lda 2+@oplda
				sta ({{ @opsta }}),y
				iny
				lda 3+@oplda
				sta ({{ @opsta }}),y
				dey
				dey
				dey
			elseif (leftstr('adest',1)<>'(') and (upcase(rightstr('adest',2))='+Y')
[]				; destination absolute y
[]				@opsta=leftstr('adest',length('adest')-2)
				lda @oplda
				sta {{ @opsta }},y
				lda 1+@oplda
				sta 1+{{ @opsta }},y
				lda 2+@oplda
				sta 2+{{ @opsta }},y
				lda 3+@oplda
				sta 3+{{ @opsta }},y
			else
[]				; destination absolute
				lda @oplda
				sta adest
				lda 1+@oplda
				sta 1+adest
				lda 2+@oplda
				sta 2+adest
				lda 3+@oplda
				sta 3+adest
			endif
		endif
	endif
endmacro

;.endcomment

macro ldaw('aparam')
	if leftstr('aparam',1)='#'
		lda #>(loword(val(copy('aparam',2))))
		pha
		lda #<(loword(val(copy('aparam',2))))
	elseif upcase(rightstr('aparam',2)=',X')
		lda 1+val(leftstr('aparam',length('aparam')-2)),x
		pha
		lda val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2)=',Y')
		lda 1+val(leftstr('aparam',length('aparam')-2)),y
		pha
		lda val(leftstr('aparam',length('aparam')-2)),y
	else
		lda 1+aparam
		pha
		lda aparam
	endif
endmacro

macro staw(aparam)
	if upcase(rightstr('aparam',2))=',X'
		sta val(copy('aparam',1,length('aparam')-2)),x
		pla
		lda 1+val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2))=',Y'
		sta val(leftstr('aparam',length('aparam')-2)),y
		pla
		lda 1+val(leftstr('aparam',length('aparam')-2)),y
	else
		sta aparam
		pla
		sta 1+aparam
	endif
endmacro

macro ldxw('aparam')
	if leftstr('aparam',1)='#'
		ldx #>(loword(val(copy('aparam',2))))
		phx
		ldx #<(loword(val(copy('aparam',2))))
	elseif upcase(rightstr('aparam',2)=',X')
		ldx 1+val(leftstr('aparam',length('aparam')-2)),x
		phx
		ldx val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2)=',Y')
		ldx 1+val(leftstr('aparam',length('aparam')-2)),y
		phx
		ldx val(leftstr('aparam',length('aparam')-2)),y
	else
		ldx 1+aparam
		phx
		ldx aparam
	endif
endmacro

macro stxw(aparam)
	if upcase(rightstr('aparam',2))=',X'
		stx val(copy('aparam',1,length('aparam')-2)),x
		plx
		ldx 1+val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2))=',Y'
		stx val(leftstr('aparam',length('aparam')-2)),y
		plx
		ldx 1+val(leftstr('aparam',length('aparam')-2)),y
	else
		stx aparam
		plx
		stx 1+aparam
	endif
endmacro

macro ldyw('aparam')
	if leftstr('aparam',1)='#'
		ldy #>(loword(val(copy('aparam',2))))
		phy
		ldy #<(loword(val(copy('aparam',2))))
	elseif upcase(rightstr('aparam',2)=',X')
		ldy 1+val(leftstr('aparam',length('aparam')-2)),x
		phy
		ldy val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2)=',Y')
		ldy 1+val(leftstr('aparam',length('aparam')-2)),y
		phy
		ldy val(leftstr('aparam',length('aparam')-2)),y
	else
		ldy 1+aparam
		phy
		ldy aparam
	endif
endmacro

macro styw(aparam)
	if upcase(rightstr('aparam',2))=',X'
		sty val(copy('aparam',1,length('aparam')-2)),x
		ply
		ldy 1+val(leftstr('aparam',length('aparam')-2)),x
	elseif upcase(rightstr('aparam',2))=',Y'
		sty val(leftstr('aparam',length('aparam')-2)),y
		ply
		ldy 1+val(leftstr('aparam',length('aparam')-2)),y
	else
		sty aparam
		ply
		sty 1+aparam
	endif
endmacro

macro SetMMUBlock(acontrol)
	if (~argcount=0) or (acontrol=0)
		stz MMU_IO_CTRL
	else
		ConvertParamToA(acontrol)
		sta MMU_IO_CTRL
	endif
endmacro


/*
macro SetCursorColor(acolor)
	ConvertParamToA(acolor)
	sta CursorColor
endmacro

; parameters:
;   [CursorColumn]  = column
;   [CursorLine]    = line
proc Update_Cursor_Pointer
    if DOPUSH then pha

    lda CursorLine
    sta UNSIGNED_MULT_A
    stz UNSIGNED_MULT_A+1
    lda #FNX_SCREEN_COLUMNS
    sta UNSIGNED_MULT_B
    stz UNSIGNED_MULT_B+1
    clc
    lda UNSIGNED_PRODUCT
    adc #<TEXT_MEM
    sta CursorPointer
    lda UNSIGNED_PRODUCT+1
    adc #>TEXT_MEM
    sta CursorPointer+1

    if DOPUSH then pla
    rts
endproc

; hard coded for 80 columns
macro SetCursorPointer('acolumn','aline')
    if DOPUSH then pha

	ConvertParamToA(acolumn)
	sta CursorColumn
	ConvertParamToA(aline)
	sta CursorLine
	
	if (leftstr('acolumn',1)='#') and (leftstr('aline',1)='#')
		lda #<(VKY_TEXT_MEMORY+val(copy('aline',2))*FNX_SCREEN_COLUMNS)
		sta CursorPointer
		lda #>(VKY_TEXT_MEMORY+val(copy('aline',2))*FNX_SCREEN_COLUMNS)
		sta CursorPointer+1
	else
        jsr Update_Cursor_Pointer
	endif

    if DOPUSH then pla
endmacro

macro Set_Cursor_Color(acolor)
	lda #acolor
	sta CursorColor
endmacro
macro Set_Cursor_Position(acolumn,aline)
	lda #acolumn
	sta CursorColumn
	lda #aline
	sta CursorLine
	lda #<(VKY_TEXT_MEMORY+aline*FNX_SCREEN_COLUMNS)
	sta CursorPointer
	lda #>(VKY_TEXT_MEMORY+aline*FNX_SCREEN_COLUMNS)
	sta CursorPointer+1
endmacro

macro Increase_SOF_Counter()
{
	inc SOFCounter
	bne +
		inc SOFCounter+1
		bne +
			inc SOFCounter+2
			bne +
				inc SOFCounter+3
	+
}
endmacro

; Parameters:
;	TempZ	=	numerator (word)
;	TempZ+2	=	denominator (word)
; Returns:
;	TempZ	=	quotient (word)
;	TempZ+4	=	remainder (word)
proc Divide16
	virtual TempZ
		NUM1 resw 1
		NUM2 resw 1
		REM resw 1
	endvirtual

	pha
	phx
	phy
					;lda #0      ;Initialize REM to 0
        stz REM		;sta REM
        stz REM+1	;sta REM+1
        ldx #16     ;There are 16 bits in NUM1
L1      asl NUM1    ;Shift hi bit of NUM1 into REM
        rol NUM1+1  ;(vacating the lo bit, which will be used for the quotient)
        rol REM
        rol REM+1
        lda REM
        sec         ;Trial subtraction
        sbc NUM2
        tay
        lda REM+1
        sbc NUM2+1
        bcc L2      ;Did subtraction succeed?
        sta REM+1   ;If yes, save it
        sty REM
        inc NUM1    ;and record a 1 in the quotient
L2      dex
        bne L1
		
	ply
	plx
	pla
	rts
endproc

proc ChrOut
	pha
	phy
	PushYMMUIO
    .IOY_TEXT
	; check if return
	cmp #13
	beq .IncreaseLine

	ldy CursorColumn
	sta (CursorPointer),y
	inc MMU_IO_CTRL
	lda CursorColor
	sta (CursorPointer),y
	iny
	cpy #FNX_SCREEN_COLUMNS
	bne +

		.IncreaseLine:
		clc
		lda CursorPointer
		adc #FNX_SCREEN_COLUMNS
		sta CursorPointer
		bcc ~pcnext2
			inc CursorPointer+1
		lda CursorLine
		inc
		cmp #FNX_SCREEN_LINES
		bne ++
			; end of screen only wraps back to the top of screen
			lda #>VKY_TEXT_MEMORY
			sta CursorPointer+1
			lda #<VKY_TEXT_MEMORY	; always equals 0
			sta CursorPointer
		++
		sta CursorLine
		ldy #0
	+
	sty CursorColumn
	PullYMMUIO
	ply
	pla
	rts
endproc

macro PrintChar(achar)
	ConvertParamToA(achar)
	jsr ChrOut
endmacro
*/

/*
; call with X=clear screen text character
; kills AXY
proc ClearScreen
    PushAXY
	PushMMUIO

    .IO_TEXT
    jsr .FillScreen
    inc MMU_IO_CTRL
    ldx CursorColor
    jsr .FillScreen

    movw #TEXT_MEM,CursorPointer
	stz CursorColumn
	stz CursorLine
    
    PullMMUIO
    PullYXA
    rts
    .FillScreen:
        movw #TEXT_MEM,CursorPointer
        txa
        ldy #0
        -
            cpy #<(TEXT_MEM+FNX_SCREEN_COLUMNS*FNX_SCREEN_LINES)
            bne +
                ldx CursorPointer+1
                cpx #>(TEXT_MEM+FNX_SCREEN_COLUMNS*FNX_SCREEN_LINES)
                beq ++
            +    
            sta (CursorPointer),y
            iny
            bne -
            inc CursorPointer+1
            bra -
        ++
        rts
endproc
*/
/*
proc8 ClearScreen
	pha
	phx
	
	stz CursorPointer	;sta CursorPointer
	stz WriteAddress	;lda #<TEXT_MEM
	lda #>TEXT_MEM
	sta WriteAddress+1
	sta CursorPointer+1
	.IO_TEXT
	ldx #' '
	jsr WriteLoop
	stz WriteAddress	;lda #<TEXT_MEM
	lda #>TEXT_MEM
	sta WriteAddress+1
	.IO_COLOR
	ldx CursorColor
	jsr WriteLoop
	stz CursorColumn
	stz CursorLine
	
	PullMMUIO
	plx
	pla
	rts

	WriteLoop:
;		txa
	WriteAddress=*+1
		stx $1234
		inc WriteAddress
		bne +
			inc WriteAddress+1
		+
		lda WriteAddress
		cmp #<(TEXT_MEM+FNX_SCREEN_COLUMNS*FNX_SCREEN_LINES)
		bne WriteLoop
			lda WriteAddress+1
			cmp #>(TEXT_MEM+FNX_SCREEN_COLUMNS*FNX_SCREEN_LINES)
			bne WriteLoop
		rts
endproc
*/
/*
macro Clear_Screen(achar)
    ldx achar
	jsr ClearScreen
endmacro
*/
/*
; parameters:
;	<TempWOp1>	=	word address of string to print
;	<CursorPointer>	=	word address of screen character/color memory
proc PrintTextString
{
;	PushAXY

	ldy #0
	bra Print20
	Print10:
		cmp #27
		blt CheckControlCodes
	JustPrintIt:
		jsr ChrOut
	NextByte:
		iny
		bne Print20
			inc TempWOp1+1
	Print20:
		lda (TempWOp1),y
		bne Print10
;	PullYXA
	rts

	CheckControlCodes:
		cmp #2	; ctrl-b/set cursor background color
		bne +
			lda CursorColor
			and #$f0
			sta CursorColor
			jsr GetNextByte
			ora CursorColor
			sta CursorColor
			bra NextByte
		+
		cmp #3	; ctrl-c/set cursor color
		bne +
			jsr GetNextByte
			sta CursorColor
			bra NextByte
		+
		cmp #6	; ctrl-f/set cursor foreground color
		bne +
			lda CursorColor
			and #$0f
			sta CursorColor
			jsr GetNextByte
			asl : asl : asl : asl
			ora CursorColor
			sta CursorColor
			bra NextByte
		+
		cmp #12	; ctrl-l/clear screen
		bne +
			jsr ClearScreen
			bra NextByte
		+
		jmp JustPrintIt
		temp byte 0
	GetNextByte:
		iny
		bne +
			inc TempWOp1+1
		+
		lda (TempWOp1),y
		rts
}
endproc

macro PrintString('astring','acolumn','aline','acolor')
	if DOPUSH
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if (leftstr('astring',1)="'") or (leftstr('astring',1)='"') or (leftstr('astring',1)='(') or (leftstr('astring',1)='[')
		section TEXT_BANK
			var @newtext = *
			bytez astring
		endsection
		
		lda #<(@newtext) : sta TempWOp1
		lda #>(@newtext) : sta TempWOp1+1
	else
		lda #<astring : sta TempWOp1
		lda #>astring : sta TempWOp1+1
	endif
	jsr PrintTextString
	if DOPUSH
		PullYXA
	endif
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
	HEXTABLE byte '0123456789ABCDEF'
endproc

macro PrintHexByte('avalue','acolumn','aline','acolor')
	if DOPUSH
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0)
		SetCursorPointer(acolumn,aline)
	endif
	if length('acolor')>0
		SetCursorColor(acolor)
	endif
	if DOPUSH
		PullYXA
	endif
	if DOPUSH
		PushAXY
	endif
	ConvertParamToA(avalue)
	jsr HexByteToASCII
	sty TempResult : sta TempResult+1
	stz TempResult+2
	PrintString(TempResult)
	if DOPUSH
		PullYXA
	endif
endmacro

macro PrintHexWord('avalue','acolumn','aline','acolor')
	if DOPUSH
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0) and (upcase('acolumn')<>'BCD')
		SetCursorPointer(acolumn,aline)
	endif
	if (length('acolor')>0) and (upcase('acolor')<>'BCD')
		SetCursorColor(acolor)
	endif
	if leftstr('avalue',1)='#'
		lda #>(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempResult : sta TempResult+1
		lda #<(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		stz TempResult+4
	else
		lda avalue+1
		jsr HexByteToASCII
		sty TempResult : sta TempResult+1
		lda avalue
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		stz TempResult+4
	endif
	if (upcase('@2')='BCD') || (upcase('@3')='BCD') || (upcase('@4')='BCD') || (upcase('@5')='BCD')
		{
			ldy #<TempResult
			-
				lda 0,y
				cmp #'0'
				bne +
				iny
				cpy #TempResult+3
				bne -
			+
		}
	else
		ldy #TempResult
	endif
	sty TempWOp1
	stz TempWOp1+1
	jsr PrintTextString
;	PrintString(TempResult)
	if DOPUSH
		PullYXA
	endif
endmacro

macro PrintHexLong('avalue','acolumn','aline','acolor')
	if DOPUSH
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0) and (upcase('acolumn')<>'BCD')
		SetCursorPointer(acolumn,aline)
	endif
	if (length('acolor')>0) and (upcase('acolor')<>'BCD')
		SetCursorColor(acolor)
	endif
	if leftstr('avalue',1)='#'
		lda #<(val(copy('avalue',2)) shr 16)
		jsr HexByteToASCII
		sty TempResult+0 : sta TempResult+1
		lda #<(val(copy('avalue',2)) shr 8)
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		lda #<(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempResult+4 : sta TempResult+5
		stz TempResult+6
	else
		lda avalue+2
		jsr HexByteToASCII
		sty TempResult+0 : sta TempResult+1
		lda avalue+1
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		lda avalue
		jsr HexByteToASCII
		sty TempResult+4 : sta TempResult+5
		stz TempResult+6
	endif
	if (upcase('@2')='BCD') || (upcase('@3')='BCD') || (upcase('@4')='BCD') || (upcase('@5')='BCD')
		{
			ldy #<TempResult
			-
				lda 0,y
				cmp #'0'
				bne +
				iny
				cpy #TempResult+3
				bne -
			+
		}
	else
		ldy #TempResult
	endif
	sty TempWOp1
	stz TempWOp1+1
	jsr PrintTextString
;	PrintString(TempResult)
	if DOPUSH
		PullYXA
	endif
endmacro

macro PrintHexDWord('avalue','acolumn','aline','acolor')
	if DOPUSH
		PushAXY
	endif
	if (length('acolumn')>0) and (length('aline')>0) and (upcase('acolumn')<>'BCD')
		SetCursorPointer(acolumn,aline)
	endif
	if (length('acolor')>0) and (upcase('acolor')<>'BCD')
		SetCursorColor(acolor)
	endif
	if leftstr('avalue',1)='#'
		lda #<(val(copy('avalue',2)) shr 24)
		jsr HexByteToASCII
		sty TempResult : sta TempResult+1
		lda #<(val(copy('avalue',2)) shr 16)
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		lda #<(val(copy('avalue',2)) shr 8)
		jsr HexByteToASCII
		sty TempResult+4 : sta TempResult+5
		lda #<(val(copy('avalue',2)))
		jsr HexByteToASCII
		sty TempResult+6 : sta TempResult+7
		stz TempResult+8
	else
		lda avalue+3
		jsr HexByteToASCII
		sty TempResult : sta TempResult+1
		lda avalue+2
		jsr HexByteToASCII
		sty TempResult+2 : sta TempResult+3
		lda avalue+1
		jsr HexByteToASCII
		sty TempResult+4 : sta TempResult+5
		lda avalue
		jsr HexByteToASCII
		sty TempResult+6 : sta TempResult+7
		stz TempResult+8
	endif
	if (upcase('@2')='BCD') || (upcase('@3')='BCD') || (upcase('@4')='BCD') || (upcase('@5')='BCD')
		{
			ldy #<TempResult
			-
				lda 0,y
				cmp #'0'
				bne +
				iny
				cpy #TempResult+3
				bne -
			+
		}
	else
		ldy #TempResult
	endif
	sty TempWOp1
	stz TempWOp1+1
	jsr PrintTextString
;	PrintString(TempResult)
	if DOPUSH
		PullYXA
	endif
endmacro

;	TempSrc		=	address to dump
;	TempDest	=	screen address to dump
;	TempZ+0		=	number of bytes
proc HexDump
	ldy #0
	-
		phy

		lda (TempSrc),y
		jsr HexByteToASCII
		pha
		.IO_TEXT
		tya
		sta (TempDest)
		.IO_COLOR
		lda TempZ+1
		sta (TempDest)
		.IO_TEXT
		incw TempDest
		pla
		sta (TempDest)
		.IO_COLOR
		lda TempZ+1
		sta (TempDest)
		.IO_MAIN
		incw TempDest
		
		ply
		iny
		cpy TempZ
		bne -
	rts
endproc

macro DumpHexToScreen(asrc,adest,acount,acolor)
	movw #(asrc),TempSrc
	movw #(adest),TempDest
	movb #acount,TempZ
	movb #acolor,TempZ+1
	jsr HexDump
endmacro

; Reads joystick port A and normalize, 0=no action
;	1=up
;	2=down
;	4=left
;	8=right
;	16=button0
;	32=button1
;	64=button2
proc ReadJoystick0
	lda VIA0_ORA_IRA
	and #(JOY_UP|JOY_DWN|JOY_LFT|JOY_RGT|JOY_BUT0|JOY_BUT1|JOY_BUT2)
	eor #(JOY_UP|JOY_DWN|JOY_LFT|JOY_RGT|JOY_BUT0|JOY_BUT1|JOY_BUT2)
	rts
endproc

; Reads joystick port B and normalize, 0=no action
proc ReadJoystick1
	lda VIA0_ORB_IRB
	and #(JOY_UP|JOY_DWN|JOY_LFT|JOY_RGT|JOY_BUT0|JOY_BUT1|JOY_BUT2)
	eor #(JOY_UP|JOY_DWN|JOY_LFT|JOY_RGT|JOY_BUT0|JOY_BUT1|JOY_BUT2)
	rts
endproc

; assume SetMMUIO
proc WaitForDMAReset
	lda #DMA_STATUS_TRF_IP
	-
		bit DMA_STATUS_REG
		bne -
	stz DMA_CTRL_REG
	rts
endproc

; assume SetMMUIO
macro DMA_1D_Copy(asource,adest,asize)
	movb #(DMA_CTRL_Enable),DMA_CTRL_REG
	movl asource,DMA_SOURCE_ADDY_L
	movl adest,DMA_DEST_ADDY_L
	movl asize,DMA_SIZE_1D_L
	movb #(DMA_CTRL_Enable|DMA_CTRL_Start_Trf),DMA_CTRL_REG
endmacro

; assume SetMMUIO
macro DMA_1D_Fill(adest,asize,afillbyte)
	movb #(DMA_CTRL_Enable|DMA_CTRL_Fill),DMA_CTRL_REG
	movl adest,DMA_DEST_ADDY_L
	movb afillbyte,DMA_DATA_2_WRITE
	movl asize,DMA_SIZE_1D_L
	movb #(DMA_CTRL_Enable|DMA_CTRL_Fill|DMA_CTRL_Start_Trf),DMA_CTRL_REG
endmacro

; 8-bit
macro CopyMemTiny(asource,adest,asize)
	{
		ldx #0
		-
			lda asource,x
			sta adest,x
			inx
			cpx asize
			bne -
	}
endmacro
*/


; [TempSrc]		=	16 bit source address
; [TempDest]	=	16 bit destination address
;	A	=	size low byte
;	Y	=	size high byte
proc CopyMem16
	clc
	adc TempSrc
	sta TempEnd
	tya
	adc TempSrc+1
	sta TempEnd+1
	{
		ldy #0
		-
			lda (TempSrc),y
			sta (TempDest),y
			iny
			bne +
				inc TempDest+1
				inc TempSrc+1
			+
			cpy TempEnd
			bne -
			lda TempSrc+1
			cmp TempEnd+1
			bne -
	}
	rts
	TempEnd word 0
endproc

; 16-bit
macro CopyMemSmall('asource','adest','asize')
	if (leftstr('asource',1)='#')
		lda #<{{ copy('asource',2) }}
		ldy #>{{ copy('asource',2) }}
	else
		lda asource
		ldy (asource)+1
	endif
	sta TempSrc
	sty TempSrc+1
	if (leftstr('adest',1)='#')
		lda #<{{ copy('adest',2) }}
		ldy #>{{ copy('adest',2) }}
	else
		lda adest
		ldy (adest)+1
	endif
	sta TempDest
	sty TempDest+1
	if (leftstr('asize',1)='#')
		lda #<{{ copy('asize',2) }}
		ldy #>{{ copy('asize',2) }}
	else
		lda asize
		ldy (asize)+1
	endif
	jsr CopyMem16
endmacro

/*
proc dzx0_standard_tolong
	sei
	; preserve mmu slot states
	lda MMU_MEM_BANK_2 : pha
	lda MMU_MEM_BANK_3 : pha
	lda MMU_MEM_BANK_4 : pha
	lda MMU_MEM_BANK_5 : pha
	; realign destination to mmu slot 2/3/4/5 @ $4000-$BFFF, max. 32768 bytes
	.MMUEDIT
	lda TempDest+1
	lsr TempDest+2 : ror
	lsr TempDest+2 : ror
	lsr TempDest+2 : ror
	lsr TempDest+2 : ror
	lsr TempDest+2 : ror
	sta MMU_MEM_BANK_2
	inc : sta MMU_MEM_BANK_3
	inc : sta MMU_MEM_BANK_4
	inc : sta MMU_MEM_BANK_5
	
	lda TempDest+1
	and #$1f	; TempDest := TempDest mod $2000
	ora #$40	; TempDest := TempDest + $4000
	sta TempDest+1
	jsr dzx0_standard

	; restore mmu to normal
	pla : sta MMU_MEM_BANK_5
	pla : sta MMU_MEM_BANK_4
	pla : sta MMU_MEM_BANK_3
	pla : sta MMU_MEM_BANK_2
	.MMULOCK
	cli
	rts
endproc

macro ZX0_Decompress_ToLong(apackeddata,adestination)
	movw apackeddata,TempSrc
	movl adestination,TempDest
	jsr dzx0_standard_tolong
endmacro
*/

//proc Start_Of_Frame_IRQ
//	START_OF_FRAME_SUBROUTINE()
//	rts
//endproc

//proc Init_IRQHandler
//	sei
//	; initialize SOF variables
//	stz SOFCounter
//	stz SOFCounter+1
//	stz SOFCounter+2
//	stz SOFCounter+3
//
//	movw #IRQ_Handler,VECTOR_IRQ
//	lda INT_MASK_REG0
//	and #~(JR0_INT00_SOF)
//	sta INT_MASK_REG0
//	cli
//	rts
//endproc
//
//proc IRQ_Handler
//	PushAXY
//	PushMMUIO
//	.IO_MAIN	; use i/o registers
//
//;	lda #JR0_INT01_SOL
//;	bit INT_PENDING_REG0
//;	beq +
//;		sta INT_PENDING_REG0	; clear irq
//;		jsr SOLIRQ ;Increase_SOFCounter
//;	+
//	lda #JR0_INT00_SOF
//	bit INT_PENDING_REG0
//	beq +
//		sta INT_PENDING_REG0	; clear irq
//		jsr Start_Of_Frame_IRQ ;Increase_SOFCounter
//;		jmp Exit
//	+
//;	jmp Exit
//
//
//	lda #JR0_INT02_KBD
//	bit INT_PENDING_REG0
//	beq +
//		sta INT_PENDING_REG0	; clear irq
//;		.IO_TEXT
//;		inc TEXT_MEM+37
//;		.IO_COLOR
//;		inc COLOR_MEM+37
//;		.IO_MAIN
//;		jsr PS2_Port0_IRQ
//;		jmp Exit
//	+
//	lda #JR0_INT03_MOUSE
//	bit INT_PENDING_REG0
//	beq +
//		sta INT_PENDING_REG0	; clear irq
//;		.IO_TEXT
//;		inc TEXT_MEM+36
//;		.IO_COLOR
//;		inc COLOR_MEM+36
//;		.IO_MAIN
//;		jsr PS2_Port1_IRQ
//;		jmp Exit
//	+
//;	lda #JR0_INT04_TMR0
//;	bit INT_PENDING_REG0
//;	beq +
//;		sta INT_PENDING_REG0	; clear irq
//;		jsr SIDPlay
//;	+
//
//	Exit:
//	PullMMUIO
//	PullYXA
//	rti
//endproc


;proc F256_RESET	
;	jsr Init_Sound
;	jsr Init_Graphics
;	jsr Init_Keyboard
;	jsr Init_IRQHandler
;	cli
;	jmp Main
;endproc


endsection
