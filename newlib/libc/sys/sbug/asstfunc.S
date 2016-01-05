;      .title C-callable wrappers for SBUG functions
;      .sbttl David's 6309-6829 SBC
       .module asstfunc

; SBUG vectors
SBUGVECS =    0xF000
NEXTCMD  =    SBUGVECS+0x02
INCH     =    SBUGVECS+0x04
INCHEK   =    SBUGVECS+0x08
OUTCH    =    SBUGVECS+0x0A

       .area  .text

; void _exit(int status)
       .globl __exit
__exit:
       tfr    x,d
       jmp    [NEXTCMD]

; void seroutb(const unsigned char c)
       .globl _seroutb
_seroutb:
       tfr    b,a
       jmp    [OUTCH]

; unsigned char serinb(void)
       .globl _serinb
_serinb:
       jsr    [INCH]
       tfr    a,b
       rts

; unsigned char serinst(void)
       .globl _serinst
_serinst:
       clrb
       jsr    [INCHEK]
       beq    1$
       decb
1$:    rts

; unsigned char seroust(void)
; SBUG doesn't provide console output status, assume free
       .globl _seroust
_seroust:
       clrb
       decb
       rts
