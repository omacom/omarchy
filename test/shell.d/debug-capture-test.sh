#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command cc
require_command setpriv

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Exercise capture with an ordinary printf child, without sudo or namespaces.
cat >"$test_tmp/capture-test.c" <<'C'
#define _GNU_SOURCE
#include <errno.h>
#include <signal.h>
#include <sys/prctl.h>
#include <sys/wait.h>
#include <unistd.h>

static int read_error;
static int query_error;
static int wait_error;
static int reap_error;
static int fork_calls;
static int wait_checks;
static int reap_checks;
static int wait_contract_failed;

static int capture_waitid(idtype_t type, id_t id, siginfo_t *info, int options);
static pid_t capture_waitpid(pid_t child, int *status, int options);

static ssize_t capture_read(int fd, void *buffer, size_t size) {
  if (read_error) {
    errno = read_error;
    read_error = 0;
    return -1;
  }
  return read(fd, buffer, size);
}

#define read capture_read
#define waitid capture_waitid
#define waitpid capture_waitpid
#define fork() (fork_calls++, fork())
#define prctl(option, ...) \
  ((option) == PR_GET_NO_NEW_PRIVS && query_error ? (errno = EIO, -1) : prctl(option, __VA_ARGS__))
#define main omarchy_debug_main
#define OMARCHY_SUDO_PATH "/usr/bin/printf"
#include "omarchy-debug-launcher.c"
#undef main
#undef read
#undef waitid
#undef waitpid
#undef fork
#undef prctl

static int check_signal_mask(int blocked) {
  sigset_t current;
  if (sigprocmask(SIG_SETMASK, NULL, &current)) return 1;
  return sigismember(&current, SIGHUP) != blocked ||
         sigismember(&current, SIGINT) != blocked ||
         sigismember(&current, SIGTERM) != blocked;
}

static int capture_waitid(idtype_t type, id_t id, siginfo_t *info, int options) {
  wait_checks++;
  if (type != P_PID || options != (WEXITED | WNOWAIT) ||
      active_child != (pid_t)id || child_phase == CHILD_IDLE || check_signal_mask(0)) {
    wait_contract_failed = 1;
  }
  if (wait_error) {
    errno = wait_error;
    wait_error = 0;
    return -1;
  }
  return waitid(type, id, info, options);
}

static pid_t capture_waitpid(pid_t child, int *status, int options) {
  reap_checks++;
  if (active_child != -1 || child_phase != CHILD_IDLE || options != 0 || check_signal_mask(1)) {
    wait_contract_failed = 1;
  }
  if (reap_error) {
    errno = reap_error;
    reap_error = 0;
    return -1;
  }
  return waitpid(child, status, options);
}

static int check_capture(int fd, size_t limit, int error, int expected) {
  char *const argv[] = {"printf", "hello", NULL};
  bool overflowed = false;
  int status;

  read_error = error;
  status = capture_command(argv, fd, limit, false, &overflowed);
  if (status != expected || overflowed != (expected == 124)) return 1;
  if (wait_contract_failed || check_signal_mask(0)) return 1;
  errno = 0;
  if (waitpid(-1, NULL, WNOHANG) != -1 || errno != ECHILD) return 1;
  return 0;
}

// Observe bookkeeping and mask restoration on errors, without sending signals.
static int check_wait_failure(bool fail_reap) {
  int status;
  int result;
  int error;
  pid_t reaped;
  pid_t child = fork();
  if (child < 0) return 1;
  if (!child) _exit(0);
  active_child = child;
  child_phase = CHILD_WORKER;
  if (fail_reap) reap_error = EIO;
  else wait_error = EIO;
  result = wait_for_child(child, &status);
  error = errno;
  do {
    reaped = waitpid(child, &status, 0);
  } while (reaped < 0 && errno == EINTR);
  return result != -1 || error != EIO || reaped != child || active_child != -1 ||
         child_phase != CHILD_IDLE || wait_contract_failed || check_signal_mask(0);
}

int main(int argc, char **argv) {
  char bytes[5];
  sigset_t unblocked;
  if (argc == 2 && !strcmp(argv[1], "--inherited-nnp")) {
    if (prctl(PR_GET_NO_NEW_PRIVS, 0, 0, 0, 0) != 1) return 1;
    if (revoke_timestamp() != 0 || fork_calls != 0) return 1;
    query_error = 1;
    return revoke_timestamp() != 125 || fork_calls != 0;
  }
  if (argc != 1) return 1;
  query_error = 1;
  if (revoke_timestamp() != 125 || fork_calls != 0) return 1;
  query_error = 0;
  sigemptyset(&unblocked);
  if (sigprocmask(SIG_SETMASK, &unblocked, NULL)) return 1;
  int memory = create_memfd("capture-test");
  int full = open("/dev/full", O_WRONLY | O_CLOEXEC);
  if (memory < 0 || full < 0 || install_signal_handlers()) return 1;

  if (check_capture(memory, 5, 0, 0) || lseek(memory, 0, SEEK_SET) < 0 ||
      read(memory, bytes, sizeof(bytes)) != sizeof(bytes) || memcmp(bytes, "hello", 5)) return 1;
  if (check_capture(full, 5, 0, 125)) return 1;
  if (check_capture(memory, 5, EIO, 125)) return 1;
  if (check_capture(memory, 5, EINTR, 0)) return 1;
  if (check_capture(memory, 2, 0, 124)) return 1;
  wait_error = EINTR;
  if (check_capture(memory, 5, 0, 0)) return 1;
  reap_error = EINTR;
  if (check_capture(memory, 5, 0, 0)) return 1;
  if (check_wait_failure(false) || check_wait_failure(true)) return 1;
  if (!wait_checks || !reap_checks) return 1;
  close(full);
  close(memory);
  return 0;
}
C

cc -std=c11 -O2 -Wall -Wextra -Werror \
  -I "$ROOT/default/omarchy/security" "$test_tmp/capture-test.c" -o "$test_tmp/capture-test"
"$test_tmp/capture-test" || fail "debug capture preserves failures and clears child bookkeeping before reaping"
pass "debug capture handles I/O failures and wait interruptions; child bookkeeping and signal masks are correct before reaping"
setpriv --no-new-privs "$test_tmp/capture-test" --inherited-nnp || fail "inherited no_new_privs skips revocation without a child; query errors fail closed"
pass "revocation reads inherited no_new_privs without spawning sudo; query errors fail closed"
