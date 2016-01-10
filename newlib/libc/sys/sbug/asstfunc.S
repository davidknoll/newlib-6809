;      .title C-callable wrappers for SBUG functions
;      .sbttl David's 6309-6829 SBC
       .module asstfunc

; SBUG vectors
SBUGVECS =    0xF000
MONITOR  =    SBUGVECS+0x00 ; Re-enter the monitor and initialize memory.
NEXTCMD  =    SBUGVECS+0x02 ; Re-enter monitor and prompt for command.
INCH     =    SBUGVECS+0x04 ; Get input character from terminal device.
INCHE    =    SBUGVECS+0x06 ; Get input character from terminal and echo.
INCHEK   =    SBUGVECS+0x08 ; Check for input character.
OUTCH    =    SBUGVECS+0x0A ; Output character to terminal device.
PDATA    =    SBUGVECS+0x0C ; Mikbug(R) compatible print data string.
PCRLF    =    SBUGVECS+0x0E ; Print carriage return, line feed, nulls.
PSTRNG   =    SBUGVECS+0x10 ; Call PCRLF, then print data string.
LRA      =    SBUGVECS+0x12 ; Load real address of memory byte.

       .area  .text

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
