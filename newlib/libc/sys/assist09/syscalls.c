/*
 * System calls for newlib on SBUG/ASSIST09 on David's 6309-6829 SBC
 * Prototypes mostly as listed at http://wiki.osdev.org/Porting_Newlib
 */

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/times.h>
#include <sys/errno.h>
#include <sys/time.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include "asstfunc.h"

#include <errno.h>
#undef errno
extern int errno;

int close(int file);
extern char **environ;
int execve(const char *name, char * const argv[], char * const env[]);
int fork(void);
int fstat(int file, struct stat *st);
int getpid(void);
int isatty(int file);
int kill(int pid, int sig);
int link(const char *old, const char *new);
off_t lseek(int file, off_t ptr, int dir);
int open(const char *name, int flags, ...);
int read(int file, void *ptr, size_t len);
void *sbrk(ptrdiff_t incr);
int stat(const char *file, struct stat *st);
clock_t times(struct tms *buf);
int unlink(const char *name);
int wait(int *status);
int write(int file, const void *ptr, size_t len);
int gettimeofday(struct timeval *p, struct timezone *z);

int close(int file)
{
  errno = EIO;
  return -1;
}

int execve(const char *name, char * const argv[], char * const env[])
{
  errno = ENOMEM;
  return -1;
}

int fork(void)
{
  errno = EAGAIN;
  return -1;
}

int fstat(int file, struct stat *st)
{
  if (file < 0 || file > 2) {
    errno = EBADF;
    return -1;
  }

  st->st_mode = S_IFCHR;
  return 0;
}

int getpid(void)
{
  return 1;
}

int isatty(int file)
{
  if (file < 0 || file > 2) {
    errno = EBADF;
    return 0;
  }

  return 1;
}

int kill(int pid, int sig)
{
  if (pid == getpid()) exit(sig);

  errno = ESRCH;
  return -1;
}

int link(const char *old, const char *new)
{
  errno = EMLINK;
  return -1;
}

off_t lseek(int file, off_t ptr, int dir)
{
  errno = (file < 0 || file > 2) ? EBADF : ESPIPE;
  return -1;
}

int open(const char *name, int flags, ...)
{
  errno = ENOENT;
  return -1;
}

int read(int file, void *ptr, size_t len)
{
  static unsigned char lastinc;
  unsigned char *cptr = ptr;
  int i;

  if (file != 0) {
    errno = EBADF;
    return -1;
  }

  for (i = 0; i < len; i++) {
    if (!serinst()) break;
    *cptr = serinb();
    // On a terminal, translate CR and CR-LF to LF
    if (lastinc == '\r' && *cptr == '\n' && isatty(file)) {
      ;
    } else {
      if (*cptr == '\r' && isatty(file)) *cptr = '\n';
      write(file, *cptr, 1); // Echo it
      lastinc = *cptr++;
    }
  }
  return i;
}

void *sbrk(ptrdiff_t incr)
{
  // Program segments
  extern void _data_start asm ("s_.data");
  extern void _data_len asm ("l_.data");
  extern void _bss_start asm ("s_.bss");
  extern void _bss_len asm ("l_.bss");

  static void *heap_end = NULL;
  void *prev_heap_end;
  void *sp;

  // Get current stack pointer
  asm volatile (
    "sts %0"
    : "=m" (sp)
  );

  // Heap begins after the initialised data and BSS (whichever is later)
  if (heap_end == NULL) {
    if (&_data_start > &_bss_start) {
      heap_end = &_data_start + (ptrdiff_t) &_data_len;
    } else {
      heap_end = &_bss_start + (ptrdiff_t) &_bss_len;
    }
  }
  prev_heap_end = heap_end;

  // Would this request risk smashing the stack?
  // (Leave space for a full register save, in case of interrupt, plus a bit more)
  if (heap_end + incr > sp - 32) {
    errno = ENOMEM;
    return (void *) -1;
  } else {
    heap_end += incr;
    return (void *) prev_heap_end;
  }
}

int stat(const char *file, struct stat *st)
{
  errno = ENOENT;
  return -1;
}

clock_t times(struct tms *buf)
{
  errno = EINVAL;
  return -1;
}

int unlink(const char *name)
{
  errno = ENOENT;
  return -1;
}

int wait(int *status)
{
  errno = ECHILD;
  return -1;
}

int write(int file, const void *ptr, size_t len)
{
  unsigned char *cptr = ptr;
  int i;
  if (file < 1 || file > 2) {
    errno = EBADF;
    return -1;
  }

  for (i = 0; i < len; i++) {
    if (!seroust()) break;
    // CR before LF on terminals
    if (*cptr == '\n' && isatty(file)) seroutb('\r');
    seroutb(*cptr++);
  }
  return i;
}

int gettimeofday(struct timeval *p, struct timezone *z)
{
  errno = EINVAL;
  return -1;
}
