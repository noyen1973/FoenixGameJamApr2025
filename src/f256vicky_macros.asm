[+]
include 'f256registers.asm'

namespace vky

    MC_Text_Mode_En  = $01       ; Enable the Text Mode
    MC_Text_Overlay  = $02       ; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
    MC_Graph_Mode_En = $04       ; Enable the Graphic Mode
    MC_Bitmap_En     = $08       ; Enable the Bitmap Module In Vicky
    MC_TileMap_En    = $10       ; Enable the Tile Module in Vicky
    MC_Sprite_En     = $20       ; Enable the Sprite Module in Vicky
    MC_GAMMA_En      = $40       ; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
    MC_Disable_Vid   = $80       ; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU
    
    MC_Video_Mode    = $01       ; 0 - 640x480@60Hz : 1 - 640x400@70hz (text mode) // 0 - 320x240@60hz : 1 - 320x200@70Hz (Graphic Mode & Text mode when Doubling = 1)
    MC_Text_XDouble   = $02       ; X Pixel Doubling
    MC_Text_YDouble   = $04       ; Y Pixel Doubling
    MC_Turn_Sync_Off  = $08      ; 1 = Turn off Sync
    MC_Show_BG_InOverlay = $10   ; 1 = Allow the Background color to show up in Overlay mode
    MC_FONT_Bank_Set = $20  ; 0 =(default) FONT Set 0, 1 = FONT Set 1

Border_Ctrl_Enable      = $01

Vky_Cursor_Enable       = $01
Vky_Cursor_Flash_Rate0  = $02
Vky_Cursor_Flash_Rate1  = $04

BITMAP_Ctrl_Enable        = $01
//BITMAP_LUT0             = $02
//BITMAP_LUT1             = $04

//TILE_Enable             = $01
//TILE_LUT0               = $02
//TILE_LUT1               = $04
//TILE_LUT2               = $08
//TILE_SIZE               = $10   ; 0 -> 16x16, 1 -> 8x8

//SPRITE_Ctrl_Enable = $01
//SPRITE_LUT0        = $02
//SPRITE_LUT1        = $04
//SPRITE_DEPTH0      = $08    ; 00 = Total Front - 01 = In between L0 and L1, 10 = In between L1 and L2, 11 = Total Back
//SPRITE_DEPTH1      = $10
//SPRITE_SIZE0       = $20    ; 00 = 32x32 - 01 = 24x24 - 10 = 16x16 - 11 = 8x8
//SPRITE_SIZE1       = $40

define MACRO_ERROR error "invalid macro parameter"

const MAX_SPRITES   = 64
const MAX_BITMAPS   = 3
const MAX_TILESETS  = 8
const MAX_TILEMAPS  = 3
const MAX_COLORLUTS = 4

define BM0 $0
define BM1 $1
define BM2 $2
define TL0 $4
define TL1 $5
define TL2 $6

define BITMAP_ENABLE %1<<0
define BITMAP_DISABLE %0<<0

define TILE_SQUARE %1<<3
define TILE_VERTICAL %0<<3
define TILE_ENABLE %1<<0
define TILE_DISABLE %0<<0
define TILE_SZ8 %1<<4
define TILE_SZ16 %0<<4

define SPRITE_ENABLE %1<<0
define SPRITE_DISABLE %0<<0
define SPRITE_SZ8 %11<<5
define SPRITE_SZ16 %10<<5
define SPRITE_SZ24 %01<<5
define SPRITE_SZ32 %00<<5
define SPRITE_LYFRONT %00<<3
define SPRITE_LYIN01 %01<<3
define SPRITE_LYIN12 %10<<3
define SPRITE_LYBACK %11<<3
define SPRITE_LUT0 %00<<1
define SPRITE_LUT1 %01<<1
define SPRITE_LUT2 %10<<1
define SPRITE_LUT3 %11<<1
;define ON %1
;define OFF %0

macro Layer_Set(alayer,amode)
	if DOPUSH=1 : pha : endif
	if alayer=0
		lda FNX.VKY.LAYER_CTRL0
		and #~(%00000111)
		ora #amode
		sta FNX.VKY.LAYER_CTRL0
	elseif alayer=1
		lda FNX.VKY.LAYER_CTRL0
		and #~(%01110000)
		ora #(amode<<4)
		sta FNX.VKY.LAYER_CTRL0
	elseif alayer=2
		lda FNX.VKY.LAYER_CTRL1
		and #~(%00000111)
		ora #amode
		sta FNX.VKY.LAYER_CTRL1
	else
		MACRO_ERROR
	endif
	if DOPUSH=1 : pla : endif
endmacro

macro Border_RGB('ared',agreen,ablue)
	if DOPUSH=1 : pha : endif
    if ~argcount=3
        lda ablue
        sta FNX.VKY.BRDR_BLUE
        lda agreen
        sta FNX.VKY.BRDR_GREEN
        lda ared
        sta FNX.VKY.BRDR_RED
    endif
    if (~argcount=1) and (leftstr('ared',1)='#')
        lda #{{copy('ared',2)}} & $ff
        sta FNX.VKY.BRDR_BLUE
        lda #({{copy('ared',2)}}>>8) & $ff
        sta FNX.VKY.BRDR_GREEN
        lda #({{copy('ared',2)}}>>16) & $ff
        sta FNX.VKY.BRDR_RED
    endif
	if DOPUSH=1 : pla : endif
endmacro

macro Border_Enable
	if DOPUSH=1 : pha : endif
	lda FNX.VKY.BRDR_CTRL
	ora #1
	sta FNX.VKY.BRDR_CTRL
	if DOPUSH=1 : pla : endif
endmacro

macro Border_Disable
	if DOPUSH=1 : pha : endif
	lda FNX.VKY.BRDR_CTRL
	and #~(1)
	sta FNX.VKY.BRDR_CTRL
	if DOPUSH=1 : pla : endif
endmacro

macro Border_Height(aheight)
	if DOPUSH=1 : pha : endif
	movb aheight , FNX.VKY.BRDR_HEIGHT
	if DOPUSH=1 : pla : endif
endmacro

macro Border_Width(awidth)
	if DOPUSH=1 : pha : endif
	movb awidth , FNX.VKY.BRDR_WIDTH
	if DOPUSH=1 : pla : endif
endmacro

macro Background_RGB('ared',agreen,ablue)
	if DOPUSH=1 : pha : endif
    if ~argcount=3
        lda ablue
        sta FNX.VKY.BKGND_BLUE
        lda agreen
        sta FNX.VKY.BKGND_GREEN
        lda ared
        sta FNX.VKY.BKGND_RED
    endif
    if (~argcount=1) and (leftstr('ared',1)='#')
        lda #{{copy('ared',2)}} & $ff
        sta FNX.VKY.BKGND_BLUE
        lda #({{copy('ared',2)}}>>8) & $ff
        sta FNX.VKY.BKGND_GREEN
        lda #({{copy('ared',2)}}>>16) & $ff
        sta FNX.VKY.BKGND_RED
    endif
	if DOPUSH=1 : pla : endif
endmacro

; color lut#, source address, size
;	VKY_Set_Color_LUT(1,PAL_LUT1,sizeof(PAL_LUT1))
macro ColorLUT_Set(alut,asrc,asize)
	if (alut>=0) and (alut<=3)
		if DOPUSH=1 : pha : phy : endif
		.IO_GFX
		CopyMemSmall(asrc,#(FNX.VKY.CLUT0+$400*alut),asize)
		.IO_MAIN
		if DOPUSH=1 : ply : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro ColorRGB_Set('ared',agreen,ablue,aaddress)
	if DOPUSH=1 : pha : endif
    .IO_GFX
    if ~argcount=3
        lda ablue
        sta aaddress+0
        lda agreen
        sta aaddress+1
        lda ared
        sta aaddress+2
    endif
    if (~argcount=2) and (leftstr('ared',1)='#')
        lda #{{copy('ared',2)}} & $ff
        sta agreen+0
        lda #({{copy('ared',2)}}>>8) & $ff
        sta agreen+1
        lda #({{copy('ared',2)}}>>16) & $ff
        sta agreen+2
    endif
	.IO_MAIN
	if DOPUSH=1 : pla : endif
endmacro

; bitmap layer#, source address, color lut#, state (0=off,1=on)
macro Bitmap_Set(abitmap,asrc,alut,astate)
	if (abitmap>=0) and (abitmap<VKY.MAX_BITMAPS) and (alut>=0) and (alut<VKY.MAX_COLORLUTS) and (astate>=0) and (astate<=1)
		if DOPUSH=1 : pha : endif
		lda #( (alut<<1) | (astate) )
		sta FNX.VKY.BITMAPS.CONTROL+(abitmap*sizeof(FNX.BITMAP_TYPE))
		movl asrc , FNX.VKY.BITMAPS.ADDRESS+(abitmap*sizeof(FNX.BITMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Bitmap_Address(abitmap,asrc)
	if (abitmap>=0) and (abitmap<VKY.MAX_BITMAPS)
		if DOPUSH=1 : pha : endif
		movl asrc , FNX.VKY.BITMAPS.ADDRESS+(abitmap*sizeof(FNX.BITMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Bitmap_Enable(abitmap)
	if (abitmap>=0) and (abitmap<VKY.MAX_BITMAPS)
		if DOPUSH=1 : pha : endif
		lda FNX.VKY.BITMAPS.CONTROL+(abitmap*sizeof(FNX.BITMAP_TYPE))
		ora #BITMAP_ENABLE
		sta FNX.VKY.BITMAPS.CONTROL+(abitmap*sizeof(FNX.BITMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Bitmap_Disable(abitmap)
	if (abitmap>=0) and (abitmap<VKY.MAX_BITMAPS)
		if DOPUSH=1 : pha : endif
		lda FNX.VKY.BITMAPS.CONTROL+(abitmap*sizeof(FNX.BITMAP_TYPE))
		and #~(BITMAP_ENABLE)
		sta FNX.VKY.BITMAPS.CONTROL+(abitmap*sizeof(FNX.BITMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tileset_Set(atileset,asrc,aconfig)
	if (atileset>=0) and (atileset<VKY.MAX_TILESETS) and ((aconfig=0) or (aconfig=8))
		if DOPUSH=1 : pha : endif
		movl asrc , FNX.VKY.TILESETS.ADDRESS+(atileset*sizeof(FNX.TILESET_TYPE))
		lda #aconfig
		sta FNX.VKY.TILESETS.CONFIG+(atileset*sizeof(FNX.TILESET_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tileset_Address(atileset,asrc)
	if (atileset>=0) and (atileset<VKY.MAX_TILESETS)
		if DOPUSH=1 : pha : endif
		movl asrc , FNX.VKY.TILESETS.ADDRESS+(atileset*sizeof(FNX.TILESET_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

; tile map#, map source address, tile size (8=8x8,16=16x16)
macro Tilemap_Set(atilemap,asrc,atilesize,awidth,aheight,axpos,aypos,astate)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movl asrc , FNX.VKY.TILEMAPS.ADDRESS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		lda #( (atilesize) | (astate) )
		sta FNX.VKY.TILEMAPS.CONTROL+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw awidth , FNX.VKY.TILEMAPS.WIDTH+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw aheight , FNX.VKY.TILEMAPS.HEIGHT+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw axpos , FNX.VKY.TILEMAPS.XPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw aypos , FNX.VKY.TILEMAPS.YPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Address(atilemap,asrc)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movl asrc , FNX.VKY.TILEMAPS.ADDRESS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Pos(atilemap,axpos,aypos)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw axpos , FNX.VKY.TILEMAPS.XPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw aypos , FNX.VKY.TILEMAPS.YPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_XPos(atilemap,axpos)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw axpos , FNX.VKY.TILEMAPS.XPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_YPos(atilemap,aypos)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw aypos , FNX.VKY.TILEMAPS.YPOS+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Size(atilemap,awidth,aheight)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw awidth , FNX.VKY.TILEMAPS.WIDTH+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		movw aheight , FNX.VKY.TILEMAPS.HEIGHT+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Width(atilemap,awidth)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw awidth , FNX.VKY.TILEMAPS.WIDTH+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Height(atilemap,aheight)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		movw aheight , FNX.VKY.TILEMAPS.HEIGHT+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Enable(atilemap)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		lda FNX.VKY.TILEMAPS.CONTROL+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		ora #TILE_ENABLE
		sta FNX.VKY.TILEMAPS.CONTROL+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Tilemap_Disable(atilemap)
	if (atilemap>=0) and (atilemap<VKY.MAX_TILEMAPS)
		if DOPUSH=1 : pha : endif
		lda FNX.VKY.TILEMAPS.CONTROL+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		and #~(TILE_ENABLE)
		sta FNX.VKY.TILEMAPS.CONTROL+(atilemap*sizeof(FNX.TILEMAP_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_Set(asprite,asrc,alut,adepth,aspritesize,axpos,aypos,astate)
;	if (asprite>=0) and (asprite<VKY.MAX_SPRITES) and (alut>=0) and (alut<VKY.MAX_COLORLUTS) and (adepth>=0) and (adepth<=3) and (astate>=0) and (astate<=1)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES) and (astate>=0) and (astate<=1)
		if DOPUSH=1 : pha : endif
		lda #( (aspritesize) | (adepth) | (alut) | (astate) )
		sta SPRITES.CONTROL+(asprite*sizeof(SPRITE_TYPE))
		movl asrc , SPRITES.ADDRESS+(asprite*sizeof(SPRITE_TYPE))
		movw axpos , SPRITES.XPOS+(asprite*sizeof(SPRITE_TYPE))
		movw aypos , SPRITES.YPOS+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_Address(asprite,asrc)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		movl asrc , SPRITES.ADDRESS+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_Pos(asprite,axpos,aypos)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		movw axpos , SPRITES.XPOS+(asprite*sizeof(SPRITE_TYPE))
		movw aypos , SPRITES.YPOS+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_XPos(asprite,axpos)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		movw axpos , SPRITES.XPOS+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_YPos(asprite,aypos)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		movw aypos , SPRITES.YPOS+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_Enable(asprite)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		lda SPRITES.CONTROL+(asprite*sizeof(SPRITE_TYPE))
		ora #SPRITE_Ctrl_Enable
		sta SPRITES.CONTROL+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Sprite_Disable(asprite)
	if (asprite>=0) and (asprite<VKY.MAX_SPRITES)
		if DOPUSH=1 : pha : endif
		lda SPRITES.CONTROL+(asprite*sizeof(SPRITE_TYPE))
		and #~(SPRITE_Ctrl_Enable)
		sta SPRITES.CONTROL+(asprite*sizeof(SPRITE_TYPE))
		if DOPUSH=1 : pla : endif
	else
		MACRO_ERROR
	endif
endmacro

macro Mode_Set()
[+]
	@paramcount = ~argcount
	@params = ~argline
	@low = 0	; default is video on
	@high = 0	; default is 480p, font0, sync on
	for @i = 1 to @paramcount
		; get parameter
		@s = upcase(trimbrackets(getparam(@params,@i)))

		; mode / low byte of master control
		if @s = 'TEXT' : @low |= VKY.MC_Text_Mode_En : endif
		if @s = 'TEXTOVERLAY' : @low |= VKY.MC_Text_Overlay : endif
		if @s = 'GRAPHICS' : @low |= VKY.MC_Graph_Mode_En : endif
		if @s = 'BITMAPS' : @low |= VKY.MC_Graph_Mode_En + VKY.MC_Bitmap_En : endif
		if @s = 'TILES' : @low |= VKY.MC_Graph_Mode_En + VKY.MC_TileMap_En : endif
		if @s = 'SPRITES' : @low |= VKY.MC_Graph_Mode_En + VKY.MC_Sprite_En : endif
		if @s = 'GAMMA' : @low |= VKY.MC_GAMMA_En : endif

		if @s = 'ENABLE' : @low &= ~(VKY.MC_Disable_Vid) : endif
		if @s = 'DISABLE' : @low |= VKY.MC_Disable_Vid : endif

		; if both text and graphics enabled then enable text overlay
		if @low and (VKY.MC_Text_Mode_En + VKY.MC_Graph_Mode_En) = (VKY.MC_Text_Mode_En + VKY.MC_Graph_Mode_En)
			@low |= VKY.MC_Text_Overlay
		endif
		
		; attributes / high byte of master control
		if @s = '480P' : @high &= ~(VKY.MC_Video_Mode) : endif
		if @s = '400P' : @high |= VKY.MC_Video_Mode : endif
		if @s = 'DOUBLEX' : @high |= VKY.MC_Text_XDouble : endif
		if @s = 'DOUBLEY' : @high |= VKY.MC_Text_YDouble : endif
		if @s = 'BGOVERLAY' : @high |= VKY.MC_Show_BG_InOverlay : endif
		if @s = 'FONT0' : @high &= ~(VKY.MC_FONT_Bank_Set) : endif
		if @s = 'FONT1' : @high |= VKY.MC_FONT_Bank_Set : endif
		if @s = 'SYNCOFF' : @high |= VKY.MC_Turn_Sync_Off : endif
	next
[-]	
	if DOPUSH=1 : pha : endif
	lda #@low
	sta FNX.VKY.MSTR_CTRL0
	lda #@high
	sta FNX.VKY.MSTR_CTRL1
	if DOPUSH=1 : pla : endif
endmacro

macro Clear_Registers()
    ; sprite registers
    ldx #0
    -
        stz FNX.VKY.SPRITES+$000,x
        stz FNX.VKY.SPRITES+$100,x
        inx
        bne -

    ; bitmap registers
    ldx #0
    -
        stz FNX.VKY.BITMAPS,x
        inx
        cpx #sizeof(FNX.BITMAP_TYPE)*vky.MAX_BITMAPS
        bne -
        
    ; tilemap registers
    ldx #0
    -
        stz FNX.VKY.TILEMAPS,x
        inx
        cpx #sizeof(FNX.TILEMAP_TYPE)*vky.MAX_TILEMAPS

    ; set tile layers
    vky.Layer_Set(0,BM0)
    vky.Layer_Set(1,BM0)
    vky.Layer_Set(2,BM0)
endmacro

endnamespace
[-]
