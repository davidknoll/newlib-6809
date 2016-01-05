;      .title C-callable wrappers for ASSIST09 functions
;      .sbttl David's 6309-6829 SBC
       .module asstfunc

; ASSIST09 function numbers
INCHP  =      0        ; Obtain input character
OUTCH  =      1        ; Output a character
PDATA1 =      2        ; Send string
PDATA  =      3        ; Send new line and string
OUT2HS =      4        ; Convert byte to hex
OUT4HS =      5        ; Convert word to hex
PCRLF  =      6        ; Output to next line
SPACE  =      7        ; Send space
MONITR =      8        ; Fireup ASSIST09
VCTRSW =      9        ; Vector swap
BRKPT  =      10       ; User breakpoint
PAUSE  =      11       ; Program break and check

       .area  .text

; void _exit(int status)
       .globl __exit
__exit:
       tfr    x,d
       swi
       .db    BRKPT
       bra    __exit

; void seroutb(const unsigned char c)
       .globl _seroutb
_seroutb:
       tfr    b,a
       swi
       .db    OUTCH
       rts

; unsigned char serinb(void)
       .globl _serinb
_serinb:
       swi
       .db    INCHP
       tfr    a,b
       rts

; ASSIST09 doesn't provide console input/output status, assume free
; unsigned char serinst(void)
; unsigned char seroust(void)
       .globl _serinst
       .globl _seroust
_serinst:
_seroust:
       clrb
       decb
       rts
