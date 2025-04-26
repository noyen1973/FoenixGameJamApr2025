.opt nodotdirectives-

.namespace FNX
        
.struct BITMAP_TYPE(actrl,aaddr)
	CONTROL .byte actrl
	ADDRESS .long aaddr
.endstruct

.struct TILESET_TYPE(aaddr,aconfig)
	ADDRESS .long aaddr
	CONFIG .byte aconfig
.endstruct

.struct TILEMAP_TYPE(actrl,aaddr,awidth,aheight,axpos,aypos)
	CONTROL .byte actrl
	ADDRESS .long aaddr
	WIDTH .word awidth
	HEIGHT .word aheight
	XPOS .word axpos
	YPOS .word aypos
.endstruct

.struct SPRITE_TYPE(actrl,aaddr,axpos,aypos)
	CONTROL .byte actrl
	ADDRESS .long aaddr
	XPOS .word axpos
	YPOS .word aypos
.endstruct

.struct COLOR_TYPE(ablue,agreen,ared,aalpha)
	BLUE .byte ablue
	GREEN .byte agreen
	RED .byte ared
	ALPHA .byte aalpha
.endstruct

.struct CLUT_TYPE(ablue,agreen,ared,aalpha)
    COLOR_TYPE(ablue,agreen,ared,aalpha) dup 256
.endstruct

.struct TIMER_TYPET(actrl,acharge,acompattr,acmpup)
    CTRL .byte actrl
    CHARGE .long acharge
    CMPATTR .byte acompattr
    CMPUP .long acmpup
.endstruct

; foenix machine id numbers
.namespace MID
    FOENIX_MACHINE_ID = $D6A7
    C256_FMX                = %000000
	C256_U                  = %000001
	F256JR                  = %000010
    F256JRe                 = %000011
	F256JRJR                = %100010
	F256K                   = %010010
	F256K2                  = %010001
    F256Ke                  = %010011  ;$13
    F256K2e                 = %010100  ;$14
    F256P                   = %010000  ;$10 (future portable)
    A2560_DEV               = %000011
	GEN_X                   = %000100  ; 8bit side
	C256_UP                 = %000101
	A2560_X                 = %001000
	A2560_U                 = %001001
	A2560_M                 = %001010
	A2560_K                 = %001011  ; classic
    A2560_K40               = %001100  ;$0C
    A2560_K60               = %001101  ;$0D
;Not Defined = $06
;Not Defined = $07
;Not Defined = $0E
;Not Defined = $0F
.endnamespace

; joystick/gamepad direction values
.namespace JOY
    UP					= $01
    DWN					= $02
    LFT					= $04
    RGT					= $08
    BUT0				= $10
    BUT1				= $20
    BUT2				= $40
.endnamespace

.namespace MMU
    MEM_CTRL                = $0000            ; MMU Memory Control Register
        EDIT_EN         = $80
    IO_CTRL                 = $0001             ; MMU I/O Control Register
        IO_PAGE_0       = $00
        IO_PAGE_1       = $01
        IO_TEXT         = $02
        IO_COLOR        = $03
    MEM_BANK_0              = $0008          ; MMU Edit Register for bank 0 ($0000 - $1FFF)
    MEM_BANK_1              = $0009          ; MMU Edit Register for bank 1 ($2000 - $3FFF)
    MEM_BANK_2              = $000A          ; MMU Edit Register for bank 2 ($4000 - $5FFF)
    MEM_BANK_3              = $000B          ; MMU Edit Register for bank 3 ($6000 - $7FFF)
    MEM_BANK_4              = $000C          ; MMU Edit Register for bank 4 ($8000 - $9FFF)
    MEM_BANK_5              = $000D          ; MMU Edit Register for bank 5 ($A000 - $BFFF)
    MEM_BANK_6              = $000E          ; MMU Edit Register for bank 6 ($C000 - $DFFF)
    MEM_BANK_7              = $000F          ; MMU Edit Register for bank 7 ($E000 - $FFFF)
.endnamespace

VKY_BASE		= $D000
;TV .enum TV_MASTER_BASE
.namespace VKY

    .const  MAX_BITMAPS = 3 ,
            MAX_TILEMAPS = 3 ,
            MAX_TILESETS = 8 ,
            MAX_SPRITES = 64 ,
            MAX_CLUTS = 4

	MSTR_CTRL				= $D000		; 16 bit
	MSTR_CTRL0				= $D000
		TEXT_MODE_EN			= $01	; Enable the Text Mode
		TEXT_OVERLAY			= $02	; Enable the Overlay of the text mode on top of Graphic Mode (the Background Color is ignored)
		GRAPH_EN				= $04	; Enable the Graphic Mode
		BITMAP_EN				= $08	; Enable the Bitmap Module In Vicky
		TILE_EN					= $10	; Enable the Tile Module in Vicky
		SPRITE_EN				= $20	; Enable the Sprite Module in Vicky
		GAMMA_EN				= $40	; this Enable the GAMMA correction - The Analog and DVI have different color value, the GAMMA is great to correct the difference
		DISABLE_VID				= $80	; This will disable the Scanning of the Video hence giving 100% bandwith to the CPU
	MSTR_CTRL1				= $D001  
		VIDEO_MODE				= $01	; 0 - 640x480@60Hz : 1 - 640x400@70hz (text mode) // 0 - 320x240@60hz : 1 - 320x200@70Hz (Graphic Mode & Text mode when Doubling = 1)
		TEXT_XDOUBLE			= $02	; X Pixel Doubling
		TEXT_YDOUBLE			= $04	; Y Pixel Doubling
		TURN_SYNC_OFF			= $08   ;	1 = Turn off Sync
		SHOW_BG_INOVERLAY		= $10	; 1 = Allow the Background color to show up in Overlay mode
		FONT_BANK_SET			= $20	; 0 =(default) FONT Set 0, 1 = FONT Set 1
	LAYER_CTRL			= $D002		; 16 bit
	LAYER_CTRL0			= $D002
	LAYER_CTRL1			= $D003
	BRDR_CTRL			= $D004		; Bit[0] - Enable (1 by default)  Bit[4..6]: X Scroll Offset ( Will scroll Left) (Acceptable Value: 0..7)
	BRDR_BGR            = $D005
    BRDR_BLUE			= $D005
	BRDR_GREEN			= $D006
	BRDR_RED			= $D007
	BRDR_WIDTH		    = $D008
	BRDR_HEIGHT		    = $D009
    BKGND_BGR           = $D00D
	BKGND_BLUE		    = $D00D
	BKGND_GREEN		    = $D00E
	BKGND_RED		    = $D00F
    PIXEL_XPOS          = $D018     ; [READ]This is Where on the video line is the Pixel
    PIXEL_XPOS_LO       = $D018     ; [READ]This is Where on the video line is the Pixel
    PIXEL_XPOS_HI       = $D019     ; [READ]Or what pixel is being displayed when the register is read
    LINE_YPOS           = $D01A     ; [READ]This is the Line Value of the Raster
    LINE_YPOS_LO        = $D01A     ; [READ]This is the Line Value of the Raster
    LINE_YPOS_HI        = $D01B     ; [READ]
	LINE_CMP_CTRL	    = $D018		; [WRITE] [0] - Enable Line 0
	LINE_CMP		    = $D019		; [WRITE] 16 bit value, [11:0]
	LINE_CMP_LO         = $D019		; [WRITE] low byte, Write Only [7:0]
	LINE_CMP_HI         = $D01A		; [WRITE] high byte, Write Only [3:0]
    
    FONT_MEM            = $C000     ; IO Page 1
	FONT0				= $C000     ; IO Page 1
	FONT1				= $C800     ; IO Page 1
	MOUSE_PTR			= $CC00     ; IO Page 1

	TEXT_MEM			= $C000     ; IO Page 2
	COLOR_MEM			= $C000     ; IO Page 3

//	GAMMA_BLUE			= $F00000
//	GAMMA_GREEN			= $F00400
//	GAMMA_RED			= $F00800

	BITMAP_BASE			= $D100
    TILEMAP_BASE        = $D200
	TILESET_BASE		= $D280
	SPRITE_BASE			= $D900
	LUT_BASE			= $D000     ; IO Page 1
[+]
	.virtual BITMAP_BASE
		BITMAPS BITMAP_TYPE() dup MAX_BITMAPS
	.endvirtual
    .virtual TILEMAP_BASE
        TILEMAPS TILEMAP_TYPE() dup MAX_TILEMAPS
    .endvirtual
	.virtual TILESET_BASE
		TILESETS TILESET_TYPE() dup MAX_TILESETS
	.endvirtual
	.virtual SPRITE_BASE
		SPRITES SPRITE_TYPE() dup MAX_SPRITES
	.endvirtual
	.virtual LUT_BASE
        CLUTS COLOR_TYPE() dup 256*4    ; IO Page 1
	.endvirtual
	.virtual LUT_BASE+0*$400
		CLUT0 COLOR_TYPE() dup 256      ; IO Page 1
	.endvirtual
	.virtual LUT_BASE+1*$400
		CLUT1 COLOR_TYPE() dup 256      ; IO Page 1
	.endvirtual
	.virtual LUT_BASE+2*$400
		CLUT2 COLOR_TYPE() dup 256      ; IO Page 1
	.endvirtual
	.virtual LUT_BASE+3*$400            
		CLUT3 COLOR_TYPE() dup 256      ; IO Page 1
	.endvirtual
	.virtual $D800
		TCLUT_FG COLOR_TYPE() dup 16    ; IO Page 0
	.endvirtual
	.virtual $D840
		TCLUT_BG COLOR_TYPE() dup 16    ; IO Page 0
	.endvirtual
[-]
.endnamespace


SID_BASE			= $D400
.namespace SID
	LEFT				= $D400
	BOTH				= $D480
	RIGHT				= $D500
.endnamespace

PSG_BASE			= $D600
.namespace PSG
	LEFT				= $D600
	BOTH				= $D608
	RIGHT				= $D610
.endnamespace

OPL3_BASE			= $D580
.namespace OPL3
	ADDR_LO				= $D580
	ADDR_HI				= $D582
	DATA				= $D581
.endnamespace

CODEC_BASE			= $D620
.namespace CODEC
    LO                  = FNX.CODEC_BASE
    HI                  = FNX.CODEC_BASE+1
    CTRL                = FNX.CODEC_BASE+2
.endnamespace

UART_BASE			= $D630
PS2_BASE			= $D640
.namespace PS2
	CTRL				= $D640
		WSTROBE0			= $02
		WSTROBE1			= $08
		FIFO_CLEAR0			= $10		; dump entire FIFO keyboard/port 0, set to 1 and then back to 0
		FIFO_CLEAR1			= $20		; dump entire FIFO mouse/port 1, set to 1 and then back to 0
	WDATA				= $D641		    ; data to send to keyboard or mouse
	RDATA0				= $D642		    ; data from keyboard FIFO/port 0
	RDATA1				= $D643		    ; data from mouse FIFO/port 1
.endnamespace

TIMER_BASE   		= $D650
.namespace TIMER
    ; Pending Interrupt (Read and Write Back to Clear)
    ; TIMER0
    .virtual $D650
        T0 TIMER_TYPET()
        T1 TIMER_TYPET()
    .endvirtual
    
    T0_CTRL             = $D650
        T0_EN               = $01
        T0_SCLR             = $02
        T0_SLOAD            = $04   ; Use SLOAD is
        T0_UPDWN            = $08
    ; Control Register Definitions
    T0_CHARGE_L         = $D651	    ; Use if you want to Precharge and countdown
    T0_CHARGE_M         = $D652	    ;
    T0_CHARGE_H         = $D653	    ;
    ; Compare Block
    T0_CMP_REG          = $D654     ;
        T0_CMP_RECLR        = $01   ; set to one for it to cycle when Counting up
        T0_CMP_RELOAD       = $02   ; Set to one for it to reload when Counting Down

    T0_CMP_L            = $D655	    ; Load this Value for Countup
    T0_CMP_M            = $D656	    ;
    T0_CMP_H            = $D657	    ;
    ; Pending Interrupt (Read and Write Back to Clear)
    ; TIMER1
    T1_CTRL_REG         = $D658	    ;
        T1_EN               = $01
        T1_SCLR             = $02
        T1_SLOAD            = $04
        T1_UPDWN            = $08   ; 1 = Up, 0 = Down
    T1_CHARGE_L         = $D659	    ; Use if you want to Precharge and countdown
    T1_CHARGE_M         = $D65A	    ;
    T1_CHARGE_H         = $D65B	    ;
    ; Compare Block
    T1_CMP_REG          = $D65C	    ;
    T1_CMP_RECLR            = $01   ; set to one for it to cycle when Counting up
    T1_CMP_RELOAD           = $02   ; Set to one for it to reload when Counting Down
    T1_CMP_L            = $D65D	    ;
    T1_CMP_M            = $D65E	    ;
    T1_CMP_H            = $D65F	    ;
.endnamespace
/*
Interrupts
Group 0
00 - SOF (VICKY) INT0
01 - LINE INT (VICKY) INT1
02 - KEYBOARD (PS2)
03 - MOUSE (PS2)
04 - TIMER0 
05 - TIMER1 
06 - DMA0_INT 
07 - CARTRIDGE
Group 1
08 - UART INT 
09 - COLLISION INT2 (VICKY) (Not implemented)
0A - COLLISION INT3 (VICKY) (Not implemented)
0B - COLLISION INT4 (VICKY) (Not implemented)
0C - RTC INT (EXT_RTC)
0D - VIA0 INT (EXT VIA0)
0E - VIA1 INT (EXT VIA1)
0F - SDCARD INSERT
Group 2
10 - IEC DATA
11 - IEC CLK
12 - IEC ATN
13 - IEC SREQ
14 - WizNET Copper (Future Expansion)
15 - WizFi360 (Future Expansion)
16 - Optical Keyboard Interrupt (logic created Interrupt) (Future Expansion)
17 - TBD
*/
IRQ_BASE			= $D660
.namespace IRQ
	PEND0   			= $D660		; init $ff
	PEND1   			= $D661		; init $ff
	PEND2   			= $D662		; init $ff
	PEND3   			= $D663		; init $ff
	POL0				= $D664
	POL1				= $D665
	POL2				= $D666
	POL3				= $D667
	EDGE0				= $D668
	EDGE1				= $D669
	EDGE2				= $D66A
	EDGE3				= $D66B
	MASK0				= $D66C
		R00_SOF				= $01		; Start of Frame @ 60FPS
		R01_SOL				= $02		; Start of Line (Programmable)
		R02_KBD				= $04		;
		R03_MOUSE			= $08		;
		R04_TMR0			= $10		;
		R05_TMR1			= $20		; Real-Time Clock Interrupt
		R06_DMA			= $40		; RESERVED
		R07_CART			= $80		; cartridge
	MASK1				= $D66D
		R10_UART			= $01		; Keyboard Interrupt
;		R11_COL0			= $02		; TYVKY Collision TBD
;		R12_COL1			= $04		; TYVKY Collision TBD
;		R13_COL2			= $08		; TYVKY Collision TBD
		R14_RTC				= $10		; Serial Port 1
		R15_VIA0			= $20		; 65c22
		R16_VIA1			= $40		; f256k only, for local keyboard 65c22
		R17_SDCARD			= $80		; SDCard Insert
	MASK2				= $D66E
		R20_IEC_DATA_I		= $01
		R21_IEC_CLK_I		= $02
		R22_IEC_ATN_I		= $04
		R23_IEC_SREQ_I		= $08
;        R24                             ;14 - WizNET Copper (Future Expansion)
;        R25                             ;15 - WizFi360 (Future Expansion)
;        R26                             ;16 - Optical Keyboard Interrupt (logic created Interrupt) (Future Expansion)
	MASK3				= $D66F
        R30_WIFI_Rx_FIFO    = $01        ;So, in position IRQ#24 - NEW_Rx_FIFO_WIFI_Sync (IRQ Generated by Rx FIFO not empty anymore) Will retrigger every time you empty the FIFO
        R31_MIDI_Rx_FIFO    = $02        ;So, in position IRQ#25 - NEW_Rx_FIFO_MIDI_Sync (IRQ Generated by Rx FIFO not empty anymore) Will retrigger every time you empty the FIFO
.endnamespace

DIP_SW_BASE		    = $D670
IEC_CTRL_BASE		= $D680
RTC_BASE			= $D690

SYS_BASE			= $D6A0
.namespace SYS
    SYS                 = $D6A0
	SYS0				= $D6A0
	SYS1				= $D6A1		; bit[2]: 0 = 2xPSG in Mono Mode with 6 Voices for both sides
                                    ;         1 = PSG Stereo Mode with 3 left + 3 right
                                    ; bit[3]: 0 = 2xSID in Mono Mode with 6 Voices for both sides
                                    ;         1 = SID Stereo Mode with 3 left + 3 right
    RST                 = $D6A2
    RST0                = $D6A2     ; Set to 0xDE to enable reset
    RST1                = $D6A3     ; Set to 0xAD to enable reset
	MID 				= $D6A7     ; Machine ID
    PCBID0              = $D6A8     ; ASCII character 0: "B"
    PCBID1              = $D6A9     ; ASCII character 1: "0"
    CHSV0               = $D6AA     ; TinyVicky subversion in BCD (low)
    CHSV1               = $D6AB     ; TinyVicky subversion in BCD (high)
    CHV0                = $D6AC     ; TinyVicky version in BCD (low)
    CHV1                = $D6AD     ; TinyVicky version in BCD (high)
    CHN0                = $D6AE     ; TinyVicky number in BCD (low)
    CHN1                = $D6AF     ; TinyVicky number in BCD (high)
    PCBMA               = $D6EB     ; PCB Major Rev (ASCII)
    PCBMI               = $D6EC     ; PCB Minor Rev (ASCII)
    PCBMD               = $D6ED     ; PCB Day (BCD)
    PCBMM               = $D6EE     ; PCB Month (BCD)
    PCBMY               = $D6EF     ; PCB Year (BCD)
.endnamespace

.namespace RNG
	DAT					= $D6A4 ; R 16 bit
	DAT_LO				= $D6A4 ; R Low Part of 16Bit RNG Generator
	DAT_HI				= $D6A5 ; R Hi Part of 16Bit RNG Generator
	SEED				= $D6A4 ; W 16 bit
	SEED_LO				= $D6A4 ; W Low Part of 16Bit RNG Generator
	SEED_HI				= $D6A5 ; W Hi Part of 16Bit RNG Generator
	CTRL				= $D6A6 ; W
		EN					= $01
		SEED_LD				= $02
	STAT				= $D6A6 ; R
		LFSR_DONE			= $80 ; ???indicates that Output = SEED Database
.endnamespace



MOUSE_BASE			= $D6E0
.namespace MOUSE
    CTRL                = $D6E0
    XPOS                = $D6E2
    YPOS                = $D6E4
    PS2_BYTE0           = $D6E6
    PS2_BYTE1           = $D6E7
    PS2_BYTE2           = $D6E8
.endnamespace

PCB_VER_BASE		= $D6EB

N4S4_ADAPTER_BASE	= $D880
.namespace N4S4
    .namespace NES
        RGT					= $01		; 8 bit
        LFT					= $02		; 8 bit
        DWN					= $04		; 8 bit
        UP 					= $08		; 8 bit
        START 				= $10		; 8 bit
        SELECT				= $20		; 8 bit
        B					= $40		; 8 bit
        A					= $80		; 8 bit
    .endnamespace
    .namespace SNES
        RGT					= $0001		; 16 bit
        LFT					= $0002		; 16 bit
        DWN					= $0004		; 16 bit
        UP					= $0008		; 16 bit
        START				= $0010		; 16 bit
        SELECT				= $0020		; 16 bit
        Y					= $0040		; 16 bit
        B					= $0080		; 16 bit
        R					= $0100		; 16 bit
        L					= $0200		; 16 bit
        X					= $0400		; 16 bit
        A					= $0800		; 16 bit
    .endnamespace
	CTRL				= $D880
	STAT				= $D880
		EN					= $01       ; Set to enable NES/SNES controller support
		MODE				= $04       ; 0 = nes, 1 = snes
		DONE				= $40       ; Poll to see if the Deserializer is done
		TRIG				= $80       ; Set to start the DeSerializer
	PAD0				= $D884
	PAD0_LO				= $D884
	PAD0_HI				= $D885
	PAD1				= $D886
	PAD1_LO				= $D886
	PAD1_HI				= $D887
	PAD2				= $D888
	PAD2_LO				= $D888
	PAD2_HI				= $D889
	PAD3				= $D88A
	PAD3_LO				= $D88A
	PAD3_HI				= $D88B
.endnamespace

VIA0_BASE			= $DC00		    	; both f256jr and f256k for game ports
.namespace VIA0
	DATAB				= $DC00		    ; input/ouput data port b / joy port 0
	DATAA				= $DC01		    ; input/ouput data port a / joy port 1
	DDRB				= $DC02		    ; data direction port b
	DDRA				= $DC03		    ; data direction port a
.endnamespace

VIA1_BASE			= $DB00	    		; only on the f256k for internal keyboard
.namespace VIA1
	DATAB				= $DB00		    ; input/ouput data port b
	DATAA				= $DB01		    ; input/ouput data port a
	DDRB				= $DB02		    ; data direction port b
	DDRA				= $DB03		    ; data direction port a
    PCR                 = $DB0C
    IFR                 = $DB0D
    IER                 = $DB0E
.endnamespace

/*
SPI_CTRL_REG      = $DD00  
SPI_CTRL_SELECT_SDCARD = $01   ; Read/Write - this Controls the CS of the SDCARD  1 = CS is Enable (i.e. CSn = 1'b0) , when 0 CS is disabled (CSn = 1'b1)
                                ; You need to set for the SDCard to accept the transfer
SPI_CTRL_SLOWCLK       = $02   ; read/write - When 1 = SPI Clk is 400Khz, When 0 = SPI Clk is 25Mhz
SPI_CTRL_BUSY          = $80   ; Read Only

SPI_DATA_REG         = $DD01    ; SPI Tx and Rx - Wait for BUSY to == 0 before reading back or to send something new
                                ; There is NO FIFO in this controller, so you need to wait for the BUSY before sending or Receiving.

CS_EN This bit controls the chip select input on the SD card. If clear (0), the SD card is disabled.
If set (1), the SD card is enabled.
SPI_CLK This bit controls the clock speed for the SPI interface to the SD card. If set (1), the clock
speed is 400 kHz. If clear (0), the clock speed is 12.5 MHz.
SPI_BUSY This read only bit indicates if the SPI bus is busy exchanging bits with the SD card.
The SPI_DATA register will not be ready for access while SPI_BUSY is set (1).
SPI_DATA this register is for the data to exchange with the SD card. A byte written to this register
will be send to the SD card. The data read from this register are the bits received from the
SD card. If SPI_BUSY is set, the program must way until SPI_BUSY is clear before reading
or writing data to this register

*/                                
SDC_CTRL_BASE		= $DD00
.namespace SDC
    CS_EN           = $01       ; rw This bit controls the chip select input on the SD card.
                                ;   If clear (0), the SD card is disabled.
                                ;   If set (1), the SD card is enabled.
    SPI_CLK         = $02       ; rw This bit controls the clock speed for the SPI interface to the SD card.
                                ;   If set (1), the clock speed is 400 kHz.
                                ;   If clear (0), the clock speed is 12.5 MHz.
    SPI_BUSY        = $80       ; r This read only bit indicates if the SPI bus is busy exchanging bits with the SD card.
                                ;   The SPI_DATA register will not be ready for access while SPI_BUSY is set (1).
    .namespace DEV0
        CTRL        = $DD00
        DATA        = $DD01
    .endnamespace
    .namespace DEV1
        CTRL        = $DD20
        DATA        = $DD21
    .endnamespace
.endnamespace

MATH_COP_BASE		= $DE00
.namespace MATH
    UMUL_A      = $DE00     ; 16bit
    UMUL_B      = $DE02     ; 16bit
    UMUL_PROD   = $DE10     ; 32bit
    UMUL_A_LO   = $DE00
    UMUL_A_HI   = $DE01
    UMUL_B_LO   = $DE02
    UMUL_B_HI   = $DE03
    UMUL_AL_LO  = $DE10
    UMUL_AL_HI  = $DE11
    UMUL_AH_LO  = $DE12
    UMUL_AH_HI  = $DE13
    
    ; Unsigned Divide Denominator A (16Bits), Numerator B (16Bits),
    ; Quotient (16Bits), Remainder (16Bits)
    UDIV_DEM    = $DE04     ; 16bit
    UDIV_NUM    = $DE06     ; 16bit
    UDIV_QUO    = $DE14     ; 16bit
    UDIV_REM    = $DE16     ; 16bit
    UDIV_DEM_LO = $DE04
    UDIV_DEM_HI = $DE05
    UDIV_NUM_LO = $DE06
    UDIV_NUM_HI = $DE07
    UDIV_QUO_LO = $DE14
    UDIV_QUO_HI = $DE15
    UDIV_REM_LO = $DE16
    UDIV_REM_HI = $DE17
    
    UADD_A      = $DE08     ; 32bit
    UADD_B      = $DE0C     ; 32bit
    UADD_SUM    = $DE18     ; 32bit
    UADD_AL_LO  = $DE08
    UADD_AL_HI  = $DE09
    UADD_AH_LO  = $DE0A
    UADD_AH_HI  = $DE0B
    UADD_BL_LO  = $DE0C
    UADD_BL_HI  = $DE0D
    UADD_BH_LO  = $DE0E
    UADD_BH_HI  = $DE0F
    USUM_AL_LO  = $DE18
    USUM_AL_HI  = $DE19
    USUM_AH_LO  = $DE1A
    USUM_AH_HI  = $DE1B
.endnamespace

DMA_BASE			= $DF00
.namespace DMA
	CTRL				= $DF00
		EN					= $01
		MODE				= $02		; 0=1D, 1=2D
		FILL         		= $04		; 1=fill byte
		INT_EN				= $08		; 1=trigger interrupt
		START_TRF			= $80		; 1=start transfer
	DATA_2_WRITE		= $DF01	        ; Write Only
	STATUS				= $DF01 		; Read Only
		TRF_IP				= $80		; Transfer in Progress
	SRC					= $DF04		    ; 24 bit
	SRC_LO  			= $DF04		    ; 8 bit
	SRC_HI				= $DF05		    ; 8 bit
	SRC_BANK			= $DF06		    ; 8 bit
	DEST				= $DF08		    ; 24 bit
	DEST_LO				= $DF08		    ; 8 bit
	DEST_HI 			= $DF09		    ; 8 bit
	DEST_BANK			= $DF0A		    ; 8 bit
	SIZE  				= $DF0C		    ; 24 bit, 1D transfer/fill
	SIZE_LO				= $DF0C		    ; 1D transfer/fill
	SIZE_HI 			= $DF0D
	SIZE_BANK			= $DF0E
	SIZE_X				= $DF0C		    ; 16 bit, 2D transfer/fill
	SIZE_X_LO			= $DF0C		    ; 2D transfer/fill
	SIZE_X_HI			= $DF0D
	SIZE_Y				= $DF0E		    ; 16 bit, 2D transfer/fill
	SIZE_Y_LO			= $DF0E		    ; 2D transfer/fill
	SIZE_Y_HI			= $DF0F
	SRC_STRIDE_X		= $DF10		    ; 16 bit, 2D
	SRC_STRIDE_X_LO		= $DF10		    ; 2D transfer/fill
	SRC_STRIDE_X_HI		= $DF11
	DST_STRIDE_X		= $DF12		    ; 16 bit, 2D
	DST_STRIDE_X_LO		= $DF12		    ; 2D transfer/fill
	DST_STRIDE_X_HI		= $DF13
.endnamespace

/*
#define MIDI_STATUS         0xDDA0 (Read: Bit[1] = Rx_FIFO_empty, Bit[2] = Tx_FIFO_empty) - Sorry I just remembered that I did add something here. Read Only
#define MIDI_FIFO_DATA_PORT 0xDDA1 (read and write) Data Port
#define MIDI_RXD_COUNT_LOW  0xDDA2 (Rx FIFO Data Count LOW)
#define MIDI_RXD_COUNT_HI   0xDDA3 (Rx FIFO Data Count Hi) Only the 4 first bit are valid
#define MIDI_TXD_COUNT_LOW  0xDDA4 (Tx FIFO Data Count LOW)
#define MIDI_TXD_COUNT_HI   0xDDA5 (Tx FIFO Data Count Hi) Only the 4 first bit are valid
//SAM2695 midi
#define MIDI_CTRL        0xDDA0
#define MIDI_FIFO        0xDDA1
#define MIDI_RXD        0xDDA2
#define MIDI_RXD_COUNT 0xDDA3
#define MIDI_TXD       0xDDA4
#define MIDI_TXD_COUNT 0xDDA5
*/
SAM_BASE            = $DDA0
.namespace SAM
    MIDI_CTRL           = $DDA0
    MIDI_FIFO           = $DDA1
    FIFO_RXD            = $DDA2
    FIFO_RXD_COUNT      = $DDA3
    FIFO_TXD            = $DDA4
    FIFO_TXD_COUNT      = $DDA5
.endnamespace

OPTKBD_BASE         = $DDC0
.namespace OPTKBD
    DATA                = $DDC0         ;FIFO queue for mechanical keyboard. Each event takes 2 bytes (2 reads)
    STATUS              = $DDC1         ;read-only, indicates if buffer is empty, and whether the machine has an optical keyboard or not
        QUE_EMPTY           = $01           ;if set, keyboard queue is empty (optical keyboard only)
        MECHANICAL          = $80           ;if set, keyboard is mechanical, not optical (i.e., an F256K with upgraded mobo)         
    COUNT               = $DDC2         ;number of bytes in the optical keyboard FIFO queue - 2 byte value
    COUNT_LO            = $DDC2
    COUNT_HI            = $DDC3
.endnamespace


.namespace IRQVEC
    COP                 = $00FFF4
    ABORT               = $00FFF8
    NMI                 = $00FFFA
    ESET                = $00FFFC
    IRQBRK              = $00FFFE
.endnamespace


/*
Here is the Register File Details for the VS1053 interface:
$D700..$D707
always @ (*) begin
    case( CPU_A_i[2:0] )
        3'b000: begin CPU_D_o = {Busy, VS1053B_Registers[0][6:0]}; end 
        3'b001: begin CPU_D_o = VS1053B_Registers[1]; end 
        3'b010: begin CPU_D_o = VS1053B_Command_Read[7:0]; end 
        3'b011: begin CPU_D_o = VS1053B_Command_Read[15:8]; end 
        3'b100: begin CPU_D_o = Data_FIFO_Count[7:0]; end
        3'b101: begin CPU_D_o = {VS1053B_FIFO_Empty, VS1053B_FIFO_Full, 3'b000, Data_FIFO_Count[10:8]}; end
        3'b110: begin CPU_D_o = 8'h00; end 
        3'b111: begin CPU_D_o = 8'h00; end
    endcase
end 
 
// VS1053B_Registers[0] - Bit Fields: ($D700..$D703)
// [0] 1: Start Transfer
// [1] 1: Read Register, 0: Write Register
// [7] 1: SPI Transfer in Progress [Busy]
// VS1053B_Registers[1] 
// [3:0]  Register to Access

// VS1053B_Registers[2] Data Access Low
// VS1053B_Registers[3] Data Access Hi
 
There are 2 Accessible Area for the VS1053
The Control/Register Section with 16bits wide Data and 16 Addresses (See specs)
The Other is the Data(Stream) Port, there is no Address and it is 8bits
 
Foenix — Yesterday at 5:40 PM
When one wants to control the chip, one need to setup the address and data (for write) and address for read, one needs to setup the direction and when everything is ready, one needs to trigger the transaction.
When one needs to write file data for playback, one needs only to write data to FIFO port @ $D704 and monitor FIFO @ $D705/$D706 
Here is a piece of code, not the best, prolly not the most kosher either, but that ought to get you started.
I am simply playing back a very tiny sound effect (small enough to fit in the memory so not much to play back)
MP3_Playing: 

                lda #$42
                sta $d702   ; Set the Stream mode
                lda #$48
                sta $d703
                lda #$21    ; Start Transaction
                sta $d700
                lda #$20    ; Return to Zero
                sta $d700 

;                lda #$00
;                sta $d702
;                sta $d703
;                lda #$23    ; Go read the Command Register
;                sta $d700 
;                lda $d702 
;                lda $d703

                ldx #$00
VS_Pause:                
                inx 
                cpx #$80
                bne VS_Pause

                lda #$80
                sta $00     ; Let's enable the MMU Edit, keep the MMU 00 in play
                lda #$08    ; Bring about the first 8K 
                sta $0D     ; It starts @ $08 == page 0

                setaxl 

                ldx #$0000
                ldy #$0000
; Go Fill the FIFO
                setas
MP3_Fill_FIFO:  ;lda @l MP3_Music,x 
                lda $A000,x
                sta VS1053_STREAM_DATA      ; THere is 2K FIFO
                inx 
                iny 
                cpy #$0800                  ; Fill 2K
                bne MP3_Fill_FIFO

MP3_Fill_FIFO_Wait:
                ldy #$0000
                lda VS1053_FIFO_COUNT_HI    ; Load High Portion is monitor for 
                and #$80
                cmp #$80
                bne MP3_Fill_FIFO_Wait

                cpx #$2000
                bne MP3_Fill_FIFO
                ldx #$0000

                lda $0D
                inc A
                sta $0D 
                cmp #$0c 
                bne MP3_Fill_FIFO

                lda #$05
                sta $0D
MP3_We_are_Done:
                setaxs 
                rts 
*/


VS1053_BASE         = $D700
.namespace VS1053
    CTRL0               = $D700
        START               = $01
    CTRL1               = $D701
    REG0                = $D702
    REG1                = $D703
    DATA                = $D704     ; stream data
    COUNT_LO            = $D705     ; FIFO count lo
    COUNT_HI            = $D706     ; FIFO count hi
        BUSY                = $80

/*
Instantiation of the UART for the VS1053B (it is exactly like the SAM2695 UART, same code)
The overall Load will need to be tested but the new thing is the UART for the VS1053B that is located @ $DDB0

//VS1053b midi
#define MIDI_CTRL_ALT         0xDDB0
#define MIDI_FIFO_ALT         0xDDB1
#define MIDI_RXD_ALT        0xDDB2
#define MIDI_RXD_COUNT_ALT  0xDDB3
#define MIDI_TXD_ALT        0xDDB4
#define MIDI_TXD_COUNT_ALT  0xDDB5
*/
    MIDI_CTRL           = $DDB0
    MIDI_FIFO           = $DDB1
    FIFO_RXD            = $DDB2
    FIFO_RXD_COUNT      = $DDB3
    FIFO_TXD            = $DDB4
    FIFO_TXD_COUNT      = $DDB5
.endnamespace


.comment
- F256K2c
$DD00 - $DD1F - SDCARD0
$DD20 - $DD3F - SDCARD1 *** This one has moved ***
$DD40 - $DD5F - SPLASH LCD (SPI Port)
$DD60 - $DD7F - Wiznet Copper SPI Interface
$DD80 - $DD9F - Wiznet WIFI UART interface (115K or 2M)
$DDA0 - $DDBF - MIDI UART (Fixed @ 31,250Baud)
$DDC0 - $DDDF - Master SPI Interface to Supervisor (RP2040)*

- F256K2e
$F0_1D00 - $F0_1D1F - SDCARD0
$F0_1D20 - $F0_1D3F - SDCARD1 *** This one has moved ***
$F0_1D40 - $F0_1D5F - SPLASH LCD (SPI Port)
$F0_1D60 - $F0_1D7F - Wiznet Copper SPI Interface
$F0_1D80 - $F0_1D9F - Wiznet WIFI UART interface (115K or 2M)
$F0_1DA0 - $F0_1DBF - MIDI UART (Fixed @ 31,250Baud)
$F0_1DC0 - $F0_1DDF - Master SPI Interface to Supervisor (RP2040)*

= Not implemented yet, but will give access to fetch the A/D Sampling from the Joystick port and also remotely get the RP2040 to load a new FPGA load.
$F0_1D00 - $F0_1D1F - SDCARD0
$F0_1D20 - $F0_1D3F - SDCARD1 *** This one has moved ***
$F0_1D20 - $F0_1D3F - SPLASH LCD (SPI Port)
$F0_1D60 - $F0_1D7F - Wiznet Copper SPI Interface
$F0_1D80 - $F0_1D9F - Wiznet WIFI UART interface (115K or 2M)
    #define WIZNET_BASE                        0xf01d80        // starting point of WizNet-related registers
    #define WIZNET_CTRL                        (WIZNET_BASE + 0)    // RW - WizNet Control Register
    #define WIZNET_DATA                        (WIZNET_BASE + 1)    // RW - WizNet DATA Register
    #define WIZNET_FIFO_CNT                    (WIZNET_BASE + 2)    // RO - WizNet FIFO Rx Count (16bit access)
    #define WIZNET_FIFO_CNT_LO                (WIZNET_BASE + 2)    // RO - WizNet FIFO Rx Count low byte (8bit access)
    #define WIZNET_FIFO_CNT_HI                (WIZNET_BASE + 3)    // RO - WizNet FIFO Rx Count hi byte (8bit access) 
$F0_1DA0 - $F0_1DBF - MIDI UART (Fixed @ 31,500Baud)
$F0_1DC0 - $F0_1DDF - Master SPI Interface to Supervisor (RP2040)*
.endcomment

.endnamespace

.opt nodotdirectives+
