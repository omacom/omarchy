#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
#include <linux/memfd.h>
#include <limits.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef OMARCHY_DEBUG_COLLECTOR_PATH
#define OMARCHY_DEBUG_COLLECTOR_PATH "/usr/lib/omarchy/omarchy-debug-collector"
#endif

#ifndef OMARCHY_SUDO_PATH
#define OMARCHY_SUDO_PATH "/usr/bin/sudo"
#endif

#ifndef OMARCHY_DEBUG_TRUST_ROOT
#define OMARCHY_DEBUG_TRUST_ROOT "/"
#endif

#define OMARCHY_BASH_PATH "/usr/bin/bash"
#define OMARCHY_DMESG_PATH "/usr/bin/dmesg"
#define OMARCHY_BOUNDARY_MARKER "--omarchy-debug-native-boundary-v1"
#ifndef DMESG_LIMIT
#define DMESG_LIMIT (8U * 1024U * 1024U)
#endif
#ifndef HELP_LIMIT
#define HELP_LIMIT (64U * 1024U)
#endif

extern char **environ;

enum child_phase {
  CHILD_IDLE,
  CHILD_WORKER,
  CHILD_REVOKE,
};

static volatile sig_atomic_t caught_signal;
static volatile sig_atomic_t child_phase = CHILD_IDLE;
static volatile sig_atomic_t active_child = -1;

static void handle_signal(int signo) {
  pid_t child = active_child;

  if (!caught_signal) caught_signal = signo;
  if (child_phase == CHILD_WORKER && child > 0) kill(child, signo);
}

static int install_signal_handlers(void) {
  struct sigaction action = {
    .sa_handler = handle_signal,
  };

  sigemptyset(&action.sa_mask);
  if (sigaction(SIGHUP, &action, NULL) || sigaction(SIGINT, &action, NULL) ||
      sigaction(SIGTERM, &action, NULL)) {
    return -1;
  }
  return 0;
}

static int restore_signal_defaults(void) {
  struct sigaction action = {
    .sa_handler = SIG_DFL,
  };

  sigemptyset(&action.sa_mask);
  if (sigaction(SIGHUP, &action, NULL) || sigaction(SIGINT, &action, NULL) ||
      sigaction(SIGTERM, &action, NULL)) {
    return -1;
  }
  return 0;
}

static int prepare_exec_signals(void) {
  sigset_t blocked;
  sigset_t previous;

  sigemptyset(&blocked);
  sigaddset(&blocked, SIGHUP);
  sigaddset(&blocked, SIGINT);
  sigaddset(&blocked, SIGTERM);
  if (sigprocmask(SIG_BLOCK, &blocked, &previous)) return -1;
  if (caught_signal) {
    sigprocmask(SIG_SETMASK, &previous, NULL);
    return -1;
  }
  if (restore_signal_defaults()) {
    sigprocmask(SIG_SETMASK, &previous, NULL);
    return -1;
  }
  return sigprocmask(SIG_SETMASK, &previous, NULL);
}

static int raw_execve(const char *path, char *const argv[], char *const envp[]) {
  return (int)syscall(SYS_execve, path, argv, envp);
}

static bool environment_name_is(const char *entry, const char *name) {
  size_t length = strlen(name);

  return !strncmp(entry, name, length) && entry[length] == '=';
}

static bool environment_is_dangerous(const char *entry) {
  static const char *const names[] = {
    "BASHOPTS",       "BASH_ENV",       "BASH_XTRACEFD", "CDPATH",
    "ENV",            "GCONV_PATH",     "GLOBIGNORE",    "LD_AUDIT",
    "IFS",            "LOCPATH",        "OMARCHY_DEBUG_NATIVE_BOUNDARY",
    "POSIXLY_CORRECT", "PS4",           "SHELLOPTS",
  };
  size_t index;

  if (!strncmp(entry, "BASH_", strlen("BASH_"))) return true;
  if (!strncmp(entry, "LD_", strlen("LD_"))) return true;
#ifndef OMARCHY_DEBUG_TESTING
  if (environment_name_is(entry, "PATH")) return true;
#endif
  for (index = 0; index < sizeof(names) / sizeof(names[0]); index++) {
    if (environment_name_is(entry, names[index])) return true;
  }
  return false;
}

static char **sanitized_environment(void) {
  size_t count = 0;
  size_t kept = 0;
  char **clean;

  while (environ[count]) count++;
  clean = calloc(count + 4, sizeof(*clean));
  if (!clean) return NULL;

  for (size_t index = 0; index < count; index++) {
    if (!environment_is_dangerous(environ[index])) clean[kept++] = environ[index];
  }
  clean[kept++] = "IFS= \t\n";
#ifndef OMARCHY_DEBUG_TESTING
  clean[kept++] = "PATH=/usr/bin:/usr/sbin:/bin:/sbin";
#endif
  clean[kept++] = "OMARCHY_DEBUG_NATIVE_BOUNDARY=1";
  clean[kept] = NULL;
  return clean;
}

static char **sudo_environment(void) {
#ifdef OMARCHY_DEBUG_TESTING
  static const char *const test_names[] = {
    "TEST_DELAY_INVALIDATE_MARKER", "TEST_DMESG_BYTES", "TEST_DMESG_DELAY_MARKER",
    "TEST_DMESG_STATUS", "TEST_EVENT_LOG", "TEST_SUDO_NO_N", "TEST_SUDO_TOKEN",
    "TEST_PROMPT_MARKER", "TEST_WAITER_ARMED",
  };
  static char *clean[sizeof(test_names) / sizeof(test_names[0]) + 3];
  size_t kept = 0;

  clean[kept++] = "PATH=/usr/bin:/usr/sbin:/bin:/sbin";
  clean[kept++] = "LC_ALL=C";
  for (size_t index = 0; index < sizeof(test_names) / sizeof(test_names[0]); index++) {
    for (size_t item = 0; environ[item]; item++) {
      if (environment_name_is(environ[item], test_names[index])) {
        clean[kept++] = environ[item];
        break;
      }
    }
  }
  clean[kept] = NULL;
  return clean;
#else
  static char *clean[] = {
    "PATH=/usr/bin:/usr/sbin:/bin:/sbin",
    "LC_ALL=C",
    NULL,
  };
  return clean;
#endif
}

static int wait_for_child(pid_t child, int *status) {
  pid_t result;

  do {
    result = waitpid(child, status, 0);
  } while (result < 0 && errno == EINTR);
  active_child = -1;
  child_phase = CHILD_IDLE;
  return result == child ? 0 : -1;
}

static int command_status(int status) {
  if (WIFEXITED(status)) return WEXITSTATUS(status);
  if (WIFSIGNALED(status)) return 128 + WTERMSIG(status);
  return 125;
}

static pid_t spawn_command(char *const argv[], int stdout_fd, bool merge_stderr,
                           enum child_phase phase) {
  sigset_t blocked;
  sigset_t previous;
  pid_t child;

  sigemptyset(&blocked);
  sigaddset(&blocked, SIGHUP);
  sigaddset(&blocked, SIGINT);
  sigaddset(&blocked, SIGTERM);
  if (sigprocmask(SIG_BLOCK, &blocked, &previous)) return -1;
  child = fork();
  if (child < 0) {
    sigprocmask(SIG_SETMASK, &previous, NULL);
    return -1;
  }
  if (!child) {
    if (phase == CHILD_WORKER) {
      if (prctl(PR_SET_PDEATHSIG, SIGKILL) || getppid() == 1) _exit(127);
    }
    if (restore_signal_defaults()) _exit(127);
    if (sigprocmask(SIG_SETMASK, &previous, NULL)) _exit(127);
    if (stdout_fd >= 0 && dup2(stdout_fd, STDOUT_FILENO) < 0) _exit(127);
    if (merge_stderr && dup2(STDOUT_FILENO, STDERR_FILENO) < 0) _exit(127);
    raw_execve(OMARCHY_SUDO_PATH, argv, sudo_environment());
    _exit(127);
  }

#ifdef OMARCHY_DEBUG_TESTING
  {
    const char *marker = getenv("TEST_POST_FORK_DELAY_MARKER");
    if (marker && *marker && phase == CHILD_WORKER) {
      int fd = open(marker, O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (fd >= 0) close(fd);
      usleep(500000);
    }
  }
#endif
  active_child = child;
  child_phase = phase;
  if (caught_signal && phase == CHILD_WORKER) kill(child, caught_signal);
  sigprocmask(SIG_SETMASK, &previous, NULL);
  return child;
}

static int revoke_timestamp(void) {
  char *const argv[] = {OMARCHY_SUDO_PATH, "-k", NULL};
  int status;
  pid_t child = spawn_command(argv, -1, false, CHILD_REVOKE);

  if (child < 0 || wait_for_child(child, &status)) return 125;
  return command_status(status);
}

static int write_all(int fd, const void *buffer, size_t length) {
  const unsigned char *cursor = buffer;

  while (length) {
    ssize_t written = write(fd, cursor, length);
    if (written < 0 && errno == EINTR) continue;
    if (written <= 0) return -1;
    cursor += written;
    length -= (size_t)written;
  }
  return 0;
}

static int capture_command(char *const argv[], int output_fd, size_t limit,
                           bool merge_stderr, bool *overflowed) {
  unsigned char buffer[16384];
  size_t total = 0;
  bool capture_failed = false;
  int pipefd[2];
  int status = 0;
  pid_t child;

  *overflowed = false;
  if (pipe2(pipefd, O_CLOEXEC)) return 125;
  child = spawn_command(argv, pipefd[1], merge_stderr, CHILD_WORKER);
  close(pipefd[1]);
  if (child < 0) {
    close(pipefd[0]);
    return 125;
  }

  while (true) {
    ssize_t received = read(pipefd[0], buffer, sizeof(buffer));
    if (received < 0 && errno == EINTR) continue;
    if (received < 0) {
      capture_failed = true;
      kill(child, SIGKILL);
      break;
    }
    if (!received) break;
    if (total > limit || (size_t)received > limit - total) {
      *overflowed = true;
      kill(child, SIGKILL);
      break;
    }
    if (write_all(output_fd, buffer, (size_t)received)) {
      capture_failed = true;
      kill(child, SIGKILL);
      break;
    }
    total += (size_t)received;
  }
  close(pipefd[0]);
  if (wait_for_child(child, &status)) return 125;
  if (capture_failed) return 125;
  if (*overflowed) return 124;
  return command_status(status);
}

static bool sudo_help_supports_no_update(int help_fd) {
  char buffer[HELP_LIMIT + 1];
  ssize_t length;

  if (lseek(help_fd, 0, SEEK_SET) < 0) return false;
  length = read(help_fd, buffer, HELP_LIMIT);
  if (length < 0) return false;
  buffer[length] = '\0';

  for (ssize_t index = 0; index < length; index++) {
    if (buffer[index] == '-' && index + 1 < length && buffer[index + 1] == 'N') {
      char before = index ? buffer[index - 1] : ' ';
      char after = index + 2 < length ? buffer[index + 2] : ' ';
      if (before == ' ' || before == '\t' || before == '\n' || before == '[' ||
          before == ',') {
        if (after == ' ' || after == '\t' || after == '\n' || after == ']' ||
            after == ',') {
          return true;
        }
      }
    }
    if (buffer[index] == '[') {
      for (ssize_t end = index + 1; end < length && buffer[end] != ']'; end++) {
        if (buffer[end] == 'N') return true;
      }
    }
  }
  return false;
}

static int create_memfd(const char *name) {
  return (int)syscall(SYS_memfd_create, name, MFD_CLOEXEC | MFD_ALLOW_SEALING);
}

static int seal_and_rewind(int fd) {
  if (fcntl(fd, F_ADD_SEALS,
            F_SEAL_SEAL | F_SEAL_SHRINK | F_SEAL_GROW | F_SEAL_WRITE)) {
    return -1;
  }
  return lseek(fd, 0, SEEK_SET) < 0 ? -1 : 0;
}

static bool trusted_metadata(const struct stat *metadata, bool directory) {
  if (metadata->st_uid != 0 || (metadata->st_mode & (S_IWGRP | S_IWOTH))) return false;
  return directory ? S_ISDIR(metadata->st_mode) : S_ISREG(metadata->st_mode);
}

static int pin_script(void) {
  char path[PATH_MAX];
  char *component;
  char *next;
  char *save = NULL;
  const char *relative;
  size_t root_length = strlen(OMARCHY_DEBUG_TRUST_ROOT);
  struct stat metadata;
  int parent;
  int fd;

  if (!root_length || root_length >= sizeof(path) ||
      strncmp(OMARCHY_DEBUG_COLLECTOR_PATH, OMARCHY_DEBUG_TRUST_ROOT, root_length)) {
    return -1;
  }
  relative = OMARCHY_DEBUG_COLLECTOR_PATH + root_length;
  if (root_length > 1 && *relative != '/') return -1;
  while (*relative == '/') relative++;
  if (!*relative || strlen(relative) >= sizeof(path)) return -1;
  memcpy(path, relative, strlen(relative) + 1);

  parent = open(OMARCHY_DEBUG_TRUST_ROOT, O_PATH | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
  if (parent < 0 || fstat(parent, &metadata) || !trusted_metadata(&metadata, true)) {
    if (parent >= 0) close(parent);
    return -1;
  }

  component = strtok_r(path, "/", &save);
  while (component) {
    next = strtok_r(NULL, "/", &save);
    if (!strcmp(component, ".") || !strcmp(component, "..")) {
      close(parent);
      return -1;
    }
    if (next) {
      fd = openat(parent, component, O_PATH | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
      close(parent);
      if (fd < 0 || fstat(fd, &metadata) || !trusted_metadata(&metadata, true)) {
        if (fd >= 0) close(fd);
        return -1;
      }
      parent = fd;
    } else {
      fd = openat(parent, component, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
      close(parent);
      if (fd < 0 || fstat(fd, &metadata) || !trusted_metadata(&metadata, false)) {
        if (fd >= 0) close(fd);
        return -1;
      }
      return fd;
    }
    component = next;
  }
  close(parent);
  return -1;
}

static int pin_descriptors(int dmesg_fd, int script_fd) {
  int high_dmesg = fcntl(dmesg_fd, F_DUPFD_CLOEXEC, 10);
  int high_script;

  if (high_dmesg < 0) return -1;
  high_script = fcntl(script_fd, F_DUPFD_CLOEXEC, high_dmesg + 1);
  if (high_script < 0) {
    close(high_dmesg);
    return -1;
  }
  close(dmesg_fd);
  close(script_fd);
  if (dup3(high_dmesg, 3, 0) < 0) {
    close(high_script);
    close(high_dmesg);
    return -1;
  }
  if (dup3(high_script, 4, 0) < 0) {
    close(3);
    close(high_script);
    close(high_dmesg);
    return -1;
  }
  close(high_script);
  close(high_dmesg);
  return 0;
}

static int interrupted_status(void) {
  return caught_signal ? 128 + caught_signal : 1;
}

static void revoke_and_exit(const char *message, int status) {
  int revoke_status = revoke_timestamp();

  if (revoke_status) fprintf(stderr, "Could not invalidate cached sudo authorization.\n");
  if (message) fprintf(stderr, "%s\n", message);
  exit(caught_signal ? interrupted_status() : status);
}

int main(int argc, char **argv) {
  bool no_sudo = false;
  bool overflowed = false;
  int script_fd;
  int dmesg_fd;
  int help_fd = -1;
  int status;
  int first_option = 1;
  char **bash_environment;
  char **bash_argv;
  size_t bash_argc;

  script_fd = pin_script();
  if (script_fd < 0) {
    fprintf(stderr, "Refusing an untrusted omarchy-debug payload.\n");
    return 126;
  }
#ifdef OMARCHY_DEBUG_TESTING
  {
    const char *marker = getenv("TEST_AFTER_PIN_DELAY_MARKER");
    if (marker && *marker) {
      int fd = open(marker, O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (fd >= 0) close(fd);
      usleep(500000);
    }
  }
#endif

  for (int index = first_option; index < argc; index++) {
    if (!strcmp(argv[index], "--no-sudo")) {
      no_sudo = true;
    } else if (strcmp(argv[index], "--print")) {
      fprintf(stderr, "Unknown option: %s\n", argv[index]);
      fprintf(stderr, "Usage: omarchy-debug [--no-sudo] [--print]\n");
      close(script_fd);
      return 1;
    }
  }

  if (install_signal_handlers()) {
    fprintf(stderr, "Could not establish the debug signal boundary.\n");
    close(script_fd);
    return 1;
  }
  if (revoke_timestamp()) {
    fprintf(stderr, "Could not invalidate cached sudo authorization.\n");
    close(script_fd);
    return 1;
  }
  if (caught_signal) revoke_and_exit(NULL, interrupted_status());

  dmesg_fd = create_memfd("omarchy-debug-dmesg");
  if (dmesg_fd < 0) revoke_and_exit("Could not create private debug staging memory.", 1);

  if (no_sudo) {
    static const char skipped[] = "(skipped - --no-sudo flag used)\n";
    if (write_all(dmesg_fd, skipped, sizeof(skipped) - 1)) {
      revoke_and_exit("Could not stage the kernel log status.", 1);
    }
  } else {
    char *const help_argv[] = {OMARCHY_SUDO_PATH, "-h", NULL};
    char *const dmesg_argv[] = {
      OMARCHY_SUDO_PATH, "-N", "--", OMARCHY_DMESG_PATH, NULL,
    };

    help_fd = create_memfd("omarchy-debug-sudo-help");
    if (help_fd < 0) revoke_and_exit("Could not verify sudo --no-update support.", 1);
    status = capture_command(help_argv, help_fd, HELP_LIMIT, true, &overflowed);
    if (caught_signal) revoke_and_exit(NULL, interrupted_status());
    if (status || overflowed || !sudo_help_supports_no_update(help_fd)) {
      revoke_and_exit("This sudo does not support --no-update; refusing privileged debug collection.", 1);
    }
    close(help_fd);
    help_fd = -1;

    status = capture_command(dmesg_argv, dmesg_fd, DMESG_LIMIT, false, &overflowed);
    if (caught_signal) revoke_and_exit(NULL, interrupted_status());
    if (overflowed) {
      revoke_and_exit("Kernel log exceeds the safe debug collection limit.", 1);
    }
    if (status) {
      revoke_and_exit("Could not collect the kernel log through command-scoped sudo.", 1);
    }
  }

  if (seal_and_rewind(dmesg_fd)) revoke_and_exit("Could not seal private debug staging memory.", 1);
  if (revoke_timestamp()) {
    fprintf(stderr, "Could not invalidate cached sudo authorization.\n");
    return 1;
  }
  if (caught_signal) revoke_and_exit(NULL, interrupted_status());

  bash_environment = sanitized_environment();
  if (!bash_environment) {
    fprintf(stderr, "Could not sanitize the debug collector environment.\n");
    return 1;
  }
  bash_argc = (size_t)argc + 4;
  bash_argv = calloc(bash_argc, sizeof(*bash_argv));
  if (!bash_argv) {
    fprintf(stderr, "Could not prepare the debug collector.\n");
    return 1;
  }
  bash_argv[0] = OMARCHY_BASH_PATH;
  bash_argv[1] = "-p";
  bash_argv[2] = "/proc/self/fd/4";
  bash_argv[3] = OMARCHY_BOUNDARY_MARKER;
  for (int index = first_option; index < argc; index++) bash_argv[index + 3] = argv[index];
  bash_argv[argc + 3] = NULL;

  if (pin_descriptors(dmesg_fd, script_fd)) {
    fprintf(stderr, "Could not pin private debug descriptors.\n");
    return 1;
  }
  if (prepare_exec_signals()) return interrupted_status();
  raw_execve(OMARCHY_BASH_PATH, bash_argv, bash_environment);
  fprintf(stderr, "Could not start the debug collector.\n");
  return 126;
}
