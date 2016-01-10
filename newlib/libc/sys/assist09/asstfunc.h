/*
 * C-callable wrappers for SBUG/ASSIST09 functions for David's 6309-6829 SBC
 */

extern void __attribute__((noreturn)) _exit(int status);
extern void seroutb(const unsigned char c);
extern unsigned char serinb(void);
extern unsigned char serinst(void);
extern unsigned char seroust(void);
