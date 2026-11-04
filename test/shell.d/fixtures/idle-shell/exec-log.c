// Preloaded into the shell under test and inherited by everything it starts,
// so every program any descendant runs is logged, however briefly it lives.
// Sampling the process tree instead misses the short-lived probes polling
// spawns. One line per exec: the pid that runs the program and its parent's,
// then argv joined by spaces. A fork logs the same line without a command, so
// a reader can follow ancestry through a subshell that never execs.
//
// Known gap: system() and popen() spawn their /bin/sh from inside libc, past
// these wrappers, so that sh is not logged itself. What it runs is, since the
// preload is inherited, under a parent the log has never seen.
//
// The exec family can run in a vfork child, which shares the parent's memory,
// so the logging path takes no locks and never touches the allocator: raw
// syscalls, with errno left as the caller had it. The real functions are
// resolved once, at load.
//
// Nor may it take much stack. Qt 6.12 runs a QProcess child on a stack carved
// out of the parent's own, SIGSTKSZ bytes above the parent's frame in clone():
// glibc sizes that for the CPU at run time, 8KB on many, and a line buffer there
// runs over the return address the parent resumes on. The line is built in
// pages mapped for the one call instead.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <spawn.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define MAX_LIST_ARGS 256
#define LINE_SIZE 8192

typedef int (*execve_fn)(const char *, char *const[], char *const[]);
typedef int (*execv_fn)(const char *, char *const[]);
typedef int (*fexecve_fn)(int, char *const[], char *const[]);
typedef pid_t (*fork_fn)(void);
typedef int (*spawn_fn)(pid_t *, const char *, const posix_spawn_file_actions_t *,
                        const posix_spawnattr_t *, char *const[], char *const[]);
typedef int (*pidfd_spawn_fn)(int *, const char *, const posix_spawn_file_actions_t *,
                              const posix_spawnattr_t *, char *const[], char *const[]);
typedef pid_t (*pidfd_getpid_fn)(int);

static execve_fn real_execve;
static execv_fn real_execv;
static execv_fn real_execvp;
static execve_fn real_execvpe;
static fexecve_fn real_fexecve;
static fork_fn real_fork;
static spawn_fn real_posix_spawn;
static spawn_fn real_posix_spawnp;
static pidfd_spawn_fn real_pidfd_spawn;
static pidfd_spawn_fn real_pidfd_spawnp;
static pidfd_getpid_fn real_pidfd_getpid;
static char log_path[4096];

__attribute__((constructor)) static void init(void) {
  real_execve = (execve_fn)dlsym(RTLD_NEXT, "execve");
  real_execv = (execv_fn)dlsym(RTLD_NEXT, "execv");
  real_execvp = (execv_fn)dlsym(RTLD_NEXT, "execvp");
  real_execvpe = (execve_fn)dlsym(RTLD_NEXT, "execvpe");
  real_fexecve = (fexecve_fn)dlsym(RTLD_NEXT, "fexecve");
  real_fork = (fork_fn)dlsym(RTLD_NEXT, "fork");
  real_posix_spawn = (spawn_fn)dlsym(RTLD_NEXT, "posix_spawn");
  real_posix_spawnp = (spawn_fn)dlsym(RTLD_NEXT, "posix_spawnp");
  // glibc 2.39 and later; absent before, and then nothing calls them.
  real_pidfd_spawn = (pidfd_spawn_fn)dlsym(RTLD_NEXT, "pidfd_spawn");
  real_pidfd_spawnp = (pidfd_spawn_fn)dlsym(RTLD_NEXT, "pidfd_spawnp");
  real_pidfd_getpid = (pidfd_getpid_fn)dlsym(RTLD_NEXT, "pidfd_getpid");

  const char *path = getenv("OMARCHY_EXEC_LOG");
  if (path && strlen(path) < sizeof(log_path)) strcpy(log_path, path);
}

static size_t put_number(char *buf, size_t at, size_t cap, long value) {
  char digits[24];
  int count = 0;

  if (value < 0) value = 0;
  do {
    digits[count++] = (char)('0' + value % 10);
    value /= 10;
  } while (value > 0 && count < (int)sizeof(digits));
  while (count > 0 && at < cap) buf[at++] = digits[--count];
  return at;
}

static void record_as(pid_t pid, pid_t parent, char *const argv[]) {
  if (!log_path[0]) return;

  int saved_errno = errno;
  char *line = mmap(NULL, LINE_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (line == MAP_FAILED) {
    errno = saved_errno;
    return;
  }
  size_t cap = LINE_SIZE - 1, at = 0;

  at = put_number(line, at, cap, (long)pid);
  if (at < cap) line[at++] = ' ';
  at = put_number(line, at, cap, (long)parent);
  for (int i = 0; argv && argv[i]; i++) {
    if (at < cap) line[at++] = ' ';
    for (const char *c = argv[i]; *c && at < cap; c++) line[at++] = *c == '\n' ? ' ' : *c;
  }
  line[at++] = '\n';

  int fd = open(log_path, O_WRONLY | O_APPEND | O_CREAT | O_CLOEXEC, 0600);
  if (fd >= 0) {
    ssize_t written = write(fd, line, at);
    (void)written;
    close(fd);
  }
  munmap(line, LINE_SIZE);
  errno = saved_errno;
}

static void record(char *const argv[]) {
  record_as(getpid(), getppid(), argv);
}

int execve(const char *path, char *const argv[], char *const envp[]) {
  record(argv);
  return real_execve(path, argv, envp);
}

int execv(const char *path, char *const argv[]) {
  record(argv);
  return real_execv(path, argv);
}

int execvp(const char *file, char *const argv[]) {
  record(argv);
  return real_execvp(file, argv);
}

int execvpe(const char *file, char *const argv[], char *const envp[]) {
  record(argv);
  return real_execvpe(file, argv, envp);
}

int fexecve(int fd, char *const argv[], char *const envp[]) {
  record(argv);
  return real_fexecve(fd, argv, envp);
}

// The list forms call the vector ones from inside libc, past the wrappers above,
// so collect their arguments here and go through the wrappers instead.
static int collect(const char *first, va_list *args, char *argv[]) {
  int count = 0;

  argv[count++] = (char *)first;
  while (argv[count - 1]) {
    if (count == MAX_LIST_ARGS) {
      errno = E2BIG;
      return -1;
    }
    argv[count++] = va_arg(*args, char *);
  }
  return 0;
}

int execl(const char *path, const char *arg, ...) {
  char *argv[MAX_LIST_ARGS];
  va_list args;

  va_start(args, arg);
  int status = collect(arg, &args, argv);
  va_end(args);
  return status < 0 ? -1 : execv(path, argv);
}

int execlp(const char *file, const char *arg, ...) {
  char *argv[MAX_LIST_ARGS];
  va_list args;

  va_start(args, arg);
  int status = collect(arg, &args, argv);
  va_end(args);
  return status < 0 ? -1 : execvp(file, argv);
}

int execle(const char *path, const char *arg, ...) {
  char *argv[MAX_LIST_ARGS];
  va_list args;

  va_start(args, arg);
  int status = collect(arg, &args, argv);
  char *const *envp = va_arg(args, char *const *);
  va_end(args);
  return status < 0 ? -1 : execve(path, argv, envp);
}

pid_t fork(void) {
  pid_t pid = real_fork();
  if (pid == 0) record(NULL);
  return pid;
}

// A vfork cannot be wrapped: the child would return through this frame and
// tear down the stack its suspended parent still needs. POSIX lets vfork be a
// fork, so make it one, and log it the same way.
pid_t vfork(void) {
  return fork();
}

// A spawned child runs its program from inside libc, past these wrappers, so
// it is logged from the parent, under the child's pid, once it exists.
int posix_spawn(pid_t *pid, const char *path, const posix_spawn_file_actions_t *actions,
                const posix_spawnattr_t *attr, char *const argv[], char *const envp[]) {
  pid_t child = 0;
  int status = real_posix_spawn(&child, path, actions, attr, argv, envp);
  if (status == 0) record_as(child, getpid(), argv);
  if (pid) *pid = child;
  return status;
}

int posix_spawnp(pid_t *pid, const char *file, const posix_spawn_file_actions_t *actions,
                 const posix_spawnattr_t *attr, char *const argv[], char *const envp[]) {
  pid_t child = 0;
  int status = real_posix_spawnp(&child, file, actions, attr, argv, envp);
  if (status == 0) record_as(child, getpid(), argv);
  if (pid) *pid = child;
  return status;
}

// The caller may pass no pidfd slot, which glibc allows though its header
// says otherwise, so spawn through a local one (read through a volatile copy,
// past the nonnull the declaration promises) and hand it over or close it.
static void finish_pidfd(int pidfd, int *volatile out, char *const argv[]) {
  pid_t child = real_pidfd_getpid ? real_pidfd_getpid(pidfd) : 0;
  record_as(child > 0 ? child : 0, getpid(), argv);
  if (out) {
    *out = pidfd;
  } else {
    int saved_errno = errno;
    close(pidfd);
    errno = saved_errno;
  }
}

int pidfd_spawn(int *pidfd, const char *path, const posix_spawn_file_actions_t *actions,
                const posix_spawnattr_t *attr, char *const argv[], char *const envp[]) {
  if (!real_pidfd_spawn) return ENOSYS;
  int *volatile out = pidfd;
  int child = -1;
  int status = real_pidfd_spawn(&child, path, actions, attr, argv, envp);
  if (status == 0) finish_pidfd(child, out, argv);
  return status;
}

int pidfd_spawnp(int *pidfd, const char *file, const posix_spawn_file_actions_t *actions,
                 const posix_spawnattr_t *attr, char *const argv[], char *const envp[]) {
  if (!real_pidfd_spawnp) return ENOSYS;
  int *volatile out = pidfd;
  int child = -1;
  int status = real_pidfd_spawnp(&child, file, actions, attr, argv, envp);
  if (status == 0) finish_pidfd(child, out, argv);
  return status;
}
