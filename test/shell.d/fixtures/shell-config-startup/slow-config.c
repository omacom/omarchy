#define _GNU_SOURCE

#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

static void delay_config(const char *path) {
  const char *target = getenv("OMARCHY_TEST_SLOW_CONFIG");
  if (!target || !path || strcmp(target, path) != 0) return;

  const char note[] = "TEST: delayed configuration read\n";
  write(STDERR_FILENO, note, sizeof(note) - 1);
  struct timespec remaining = { .tv_sec = 1, .tv_nsec = 0 };
  while (nanosleep(&remaining, &remaining) != 0) {}
}

#define WRAP_OPEN(name) \
int name(const char *path, int flags, ...) { \
  mode_t mode = 0; \
  if ((flags & O_CREAT) || ((flags & O_TMPFILE) == O_TMPFILE)) { \
    va_list ap; \
    va_start(ap, flags); \
    mode = va_arg(ap, int); \
    va_end(ap); \
  } \
  int (*real_open)(const char *, int, ...) = dlsym(RTLD_NEXT, #name); \
  delay_config(path); \
  return real_open(path, flags, mode); \
}

WRAP_OPEN(open)
WRAP_OPEN(open64)
