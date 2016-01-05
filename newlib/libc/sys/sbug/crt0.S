;      .title CRT0 for newlib on SBUG/ASSIST09
;      .sbttl David's 6309-6829 SBC
       .module crt0
       ; Based on the one in gcc6809
       ; Tries to be position-independent, but not quite

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
bsslp:
       clr    ,x+
       leay   -1,y
       bne    bsslp

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

       ;; If main returns, then invoke exit() to stop the program
       ;; The C library doesn't support -mdret yet, so move the
       ;; argument first.
#ifdef __DRET__
       tfr    d,x
#endif
       lbsr   _exit

       .area  .data
; char *argv[0]
argv0: .strz  "crt0"
       .area  .bss
; char *argv[]
argv:  .ds    2*2
; char **environ / char *envp[]
       .globl _environ
_environ:
       .ds    1*2

; Don't emit vectors, this is a "user mode" program
       .area  vector

       .end   __start
