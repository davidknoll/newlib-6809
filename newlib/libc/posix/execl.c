/* execl.c */

/* This and the other exec*.c files in this directory require 
   the target to provide the _execve syscall.  */

#include <_ansi.h>
#include <unistd.h>

/* Only deal with a pointer to environ, to work around subtle bugs with shared
   libraries and/or small data systems where the user declares his own
   'environ'.  */
static char ***p_environ = &environ;

#ifdef _HAVE_STDC

#include <stdarg.h>

int
_DEFUN(execl, (path, arg0, ...), 
      _CONST char *path _AND
      _CONST char *arg0 _DOTS)

#else

#include <varargs.h>

int
_DEFUN(execl, (path, arg0, va_alist),
     _CONST char *path _AND
     _CONST char *arg0 _AND
     va_dcl)

#endif

{
  int i;
  va_list args;
  _CONST char *argv[256];

  va_start (args, arg0);
  argv[0] = arg0;
  i = 1;
  do
      argv[i] = va_arg (args, _CONST char *);
  while (argv[i++] != NULL);
  va_end (args);

  return _execve (path, (char * _CONST  *) argv, *p_environ);
}
