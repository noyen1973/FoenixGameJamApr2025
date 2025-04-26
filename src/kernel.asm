; need to disable no dot directives because of label 'EXPORT','ERROR'
include 'f256kernal_api.asm'

const KEvent = $e0   ; .resb 8 export

namespace Kernel
    
    section 'CODE'

        proc Init
            ; init kernel event buffer
            movw #KEvent,kernel.arg
            rts
;            KEvent .resb 8 export
        endproc
        
//        proc GetKey
//            lda kernel.event.pending
//            bpl +
//                jsr kernel.NextEvent
//                lda Event[kernel.event.type]
//                cmp #kernel.event.key.pressed
//                bne +
//                    lda Event[kernel.results.key_type.ascii]
//                    rts
//            +
//            lda #0
//            rts
//        endproc
    
    endsection

endnamespace
