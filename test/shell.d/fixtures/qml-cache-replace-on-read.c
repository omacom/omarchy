#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <stdatomic.h>

static _Atomic int watched_fd = -1;
static _Atomic int replaced = 0;
static _Atomic int reads = 0;
static void watch(int fd, const char *path, int flags) {
  const char *target = getenv("O16126_TARGET");
  if (fd >= 0 && target && path && strcmp(target, path) == 0 && (flags & O_ACCMODE) == O_RDONLY && !atomic_load(&replaced))
    atomic_store(&watched_fd, fd);
}
int open64(const char *path, int flags, ...) {
  static int (*real_open)(const char *, int, ...);
  if (!real_open) real_open = dlsym(RTLD_NEXT, "open64");
  mode_t mode = 0;
  if ((flags & O_CREAT) || ((flags & O_TMPFILE) == O_TMPFILE)) { va_list args; va_start(args, flags); mode = va_arg(args, int); va_end(args); }
  int fd = real_open(path, flags, mode);
  watch(fd, path, flags);
  return fd;
}
int open(const char *path, int flags, ...) {
  static int (*real_open)(const char *, int, ...);
  if (!real_open) real_open = dlsym(RTLD_NEXT, "open");
  mode_t mode = 0;
  if ((flags & O_CREAT) || ((flags & O_TMPFILE) == O_TMPFILE)) { va_list args; va_start(args, flags); mode = va_arg(args, int); va_end(args); }
  int fd = real_open(path, flags, mode);
  watch(fd, path, flags);
  return fd;
}
int close(int fd) {
  static int (*real_close)(int);
  if (!real_close) real_close = dlsym(RTLD_NEXT, "close");
  int expected = fd;
  if (fd >= 0 && atomic_compare_exchange_strong(&watched_fd, &expected, -1) && atomic_fetch_add(&reads, 1) >= atoi(getenv("O16126_SKIP_READS") ?: "0") && !atomic_exchange(&replaced, 1)) {
    const char *target = getenv("O16126_TARGET");
    const char *replacement = getenv("O16126_REPLACEMENT");
    const char *marker = getenv("O16126_MARKER");
    long status = syscall(SYS_renameat, AT_FDCWD, replacement, AT_FDCWD, target);
    if (marker) {
      int mark = syscall(SYS_openat, AT_FDCWD, marker, O_WRONLY|O_CREAT|O_TRUNC, 0600);
      if (mark >= 0) {
        const char *message = status == 0 ? "replaced after source read\n" : "replacement failed\n";
        syscall(SYS_write, mark, message, strlen(message));
        syscall(SYS_close, mark);
      }
    }
  }
  return real_close(fd);
}
