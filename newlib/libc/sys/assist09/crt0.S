;      .title CRT0 for newlib on ASSIST09
;      .sbttl David's 6309-6829 SBC
       .module crt0
       ; Based on the one in gcc6809
       ; Tries to be position-independent, but not quite

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

; Declare linker sections
       .bank  prog
       .area  init     (BANK=prog)
       lbra   __start
       .area  .text    (BANK=prog)
       .area  .data    (BANK=prog)
       .area  .ctors   (BANK=prog)
       .word  0
       .area  .dtors   (BANK=prog)
       .word  0
       .area  .bss     (BANK=prog)

       .area  .text
; extern int main(int argc, char *argv[])
       .globl _main
; extern void exit(int status)
       .globl _exit
; extern void _init_signal(void)
;      .globl __init_signal

; void _start(void)
       .globl __start
__start:
#ifdef HAVE_DIRECT
       ;; Initialize the direct page pointer
       leax   s_.direct,pcr
       tfr    x,d
       tfr    a,dp
#endif

       ;; Zero the BSS
       leax   s_.bss,pcr
       ldy    #l_.bss
bsslp: clr    ,x+
       leay   -1,y
       bne    bsslp
       sts    entsp,pcr

       ;; Call any "initializer" functions
       leau   s_.ctors,pcr
__ctors_loop:
       ldy    ,u++
       cmpy   #0
       beq    __ctors_done
       jsr    ,y
       bra    __ctors_loop
__ctors_done:

       ;; Initialise newlib signal handling emulation
;      lbsr   __init_signal

       ;; Set up argc/argv/envp arrays
       leau   _environ,pcr
       pshs   u
       leau   argv,pcr
       pshs   u
       leax   argv0,pcr
       stx    ,u
       ;; Count argv entries
       ldx    #0
arglp: ldy    ,u++
       beq    argdn
       leax   1,x
       bra    arglp
argdn:
       ;; Call the main function.
       lbsr   _main
       leas   4,s

       ;; If main returns, then invoke exit() to stop the program
       ;; The C library doesn't support -mdret yet, so move the
       ;; argument first.
#ifdef __DRET__
       tfr    d,x
#endif
       lbra   _exit

; void __attribute__((noreturn)) _exit(int status)
       .globl __exit
__exit:
       ;; Call any finalizer functions
       leau   s_.dtors,pcr
       pshs   x,d
__dtors_loop:
       ldy    ,u++
       cmpy   #0
       beq    __dtors_done
       jsr    ,y
       bra    __dtors_loop
__dtors_done:
       puls   d,x

       ;; Exit to ASSIST09
       lds    entsp,pcr
       lda    #1
       swi
       .db    MONITR
       ;; Halt, in case the monitor tries to continue
       bra    .

       .area  .data
; char *argv[0]
argv0: .strz  "crt0"

       .area  .bss
entsp: .ds    1*2

; char *argv[]
argv:  .ds    2*2
; char **environ / char *envp[]
       .globl _environ
_environ:
       .ds    1*2

; Don't emit vectors, this isn't a ROM-based program
       .area  vector

       .end   __start
