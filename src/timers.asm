
const COOKIES=enum(SOF=1)

namespace Timers

    
    section 'CODE'
        ; parameters:
        ;   A = number of frames
        ;   X = timer cookie
        proc SetFrames
            section 'BSS'
                timerframes resb 1
                timercookie resb 1
            endsection
            sta timerframes
            stx timercookie
            
            lda #(kernel.args.timer.FRAMES|kernel.args.timer.QUERY)
            sta kernel.args.timer.units
            jsr kernel.Clock.SetTimer
            clc
            adc timerframes
            sta kernel.args.timer.absolute
            lda #kernel.args.timer.FRAMES
            sta kernel.args.timer.units
            lda timercookie
            sta kernel.args.timer.cookie
            jsr kernel.Clock.SetTimer
            rts
        endproc
        
        proc ResetSOF
            lda #1
            ldx #COOKIES.SOF
            jsr SetFrames
            rts
        endproc

    endsection
endnamespace
