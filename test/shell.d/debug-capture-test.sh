#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command cc

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Exercise capture with an ordinary printf child, without sudo or namespaces.
cat >"$test_tmp/capture-test.c" <<'C'
#define _GNU_SOURCE
#include <errno.h>
#include <unistd.h>

static int read_error;
static ssize_t capture_read(int fd, void *buffer, size_t size) {
  if (read_error) {
    errno = read_error;
    read_error = 0;
    return -1;
  }
  return read(fd, buffer, size);
}

#define read capture_read
#define main omarchy_debug_main
#define OMARCHY_SUDO_PATH "/usr/bin/printf"
#include "omarchy-debug-launcher.c"
#undef main
#undef read

static int check_capture(int fd, size_t limit, int error, int expected) {
  char *const argv[] = {"printf", "hello", NULL};
  bool overflowed = false;
  int status;

  read_error = error;
  status = capture_command(argv, fd, limit, false, &overflowed);
  if (status != expected || overflowed != (expected == 124)) return 1;
  errno = 0;
  if (waitpid(-1, NULL, WNOHANG) != -1 || errno != ECHILD) return 1;
  return 0;
}

int main(void) {
  char bytes[5];
  int memory = create_memfd("capture-test");
  int full = open("/dev/full", O_WRONLY | O_CLOEXEC);
  if (memory < 0 || full < 0 || install_signal_handlers()) return 1;

  if (check_capture(memory, 5, 0, 0) || lseek(memory, 0, SEEK_SET) < 0 ||
      read(memory, bytes, sizeof(bytes)) != sizeof(bytes) || memcmp(bytes, "hello", 5)) return 1;
  if (check_capture(full, 5, 0, 125)) return 1;
  if (check_capture(memory, 5, EIO, 125)) return 1;
  if (check_capture(memory, 5, EINTR, 0)) return 1;
  if (check_capture(memory, 2, 0, 124)) return 1;
  close(full);
  close(memory);
  return 0;
}
C

cc -std=c11 -O2 -Wall -Wextra -Werror \
  -I "$ROOT/default/omarchy/security" "$test_tmp/capture-test.c" -o "$test_tmp/capture-test"
"$test_tmp/capture-test" || fail "debug capture preserves I/O errors, retries interruption and reaps its child"
pass "debug capture handles exact output, full destination, read failure, interrupted read and overflow"
