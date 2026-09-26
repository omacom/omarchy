#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command unshare
require_command setpriv
require_command cc
require_command readelf
require_command script

if [[ ${OMARCHY_DEBUG_SUDO_SECURITY_NS:-0} != 1 ]]; then
  outer_uid=$(id -u)
  outer_gid=$(id -g)
  subuid=$(awk -F: -v user="$(id -un)" '$1 == user { print $2; exit }' /etc/subuid)
  subgid=$(awk -F: -v user="$(id -un)" '$1 == user { print $2; exit }' /etc/subgid)
  if [[ -z $subuid || -z $subgid ]]; then
    pass "no subordinate uid/gid range; skipping debug sudo proof"
    exit 0
  fi
  namespace=(unshare --user --mount
    --map-users "0:$outer_uid:1" --map-users "1:$subuid:65536"
    --map-groups "0:$outer_gid:1" --map-groups "1:$subgid:65536")
  if "${namespace[@]}" true 2>/dev/null; then
    exec "${namespace[@]}" env OMARCHY_DEBUG_SUDO_SECURITY_NS=1 bash "$0"
  else
    pass "requested user/mount namespace unavailable; skipping debug sudo proof"
    exit 0
  fi
fi

[[ $(id -u) == 0 ]] || fail "debug proof did not enter its root namespace"

test_tmp=$(mktemp -d)
mount -t tmpfs -o mode=0755,suid tmpfs "$test_tmp"
stub_bin="$test_tmp/bin"
collector="$test_tmp/lib/omarchy/omarchy-debug-collector"
test_home="$test_tmp/home"
root_dir="$test_tmp/root"
event_log="$test_tmp/events"
token="$test_tmp/sudo-token"
victim="$root_dir/published"
armed="$test_tmp/waiter-armed"
staging_marker="$test_home/staging-command-ran"
launcher="$test_tmp/omarchy-debug"
mkdir -p "$stub_bin" "$test_home/runtime" "$root_dir" "$test_tmp/lib/omarchy"
touch "$event_log"
chown -R 1000:1000 "$test_home" "$event_log"
chmod 0700 "$test_home" "$test_home/runtime"
chmod 0755 "$test_tmp" "$stub_bin" "$root_dir"
chmod 0600 "$event_log"

cleanup() {
  local status=$?
  trap - EXIT
  rm -f "$armed"
  [[ ! -s $test_home/waiter.pid ]] || kill "$(<"$test_home/waiter.pid")" 2>/dev/null || true
  rm -rf "$test_tmp"/* 2>/dev/null || true
  umount -l "$test_tmp" 2>/dev/null || true
  rmdir "$test_tmp" 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT

cat >"$test_tmp/sudo.c" <<'C'
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *need(const char *name) {
  const char *value = getenv(name);
  if (!value || !*value) exit(125);
  return value;
}

static void event(const char *message) {
  int fd = open(need("TEST_EVENT_LOG"), O_WRONLY | O_APPEND);
  if (fd < 0 || dprintf(fd, "%s\n", message) < 0) exit(125);
  close(fd);
}

int main(int argc, char **argv) {
  const char *token = need("TEST_SUDO_TOKEN");
  const char *prompt_marker;
  int index = 1, no_update = 0, noninteractive = 0, fd;

  if (argc == 2 && !strcmp(argv[1], "-h")) {
    if (getenv("TEST_SUDO_NO_N")) puts("usage: sudo [-ABbEHknPS] command");
    else puts("usage: sudo [-ABbEHkNnPS] command");
    return 0;
  }
  if (argc == 2 && !strcmp(argv[1], "-k")) {
    event("invalidate");
    const char *delay_marker = getenv("TEST_DELAY_INVALIDATE_MARKER");
    if (delay_marker && *delay_marker) {
      fd = open(delay_marker, O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (fd < 0) return 120;
      close(fd);
      usleep(500000);
    }
    if (unlink(token) && errno != ENOENT) return 121;
    fd = open(need("TEST_WAITER_ARMED"), O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (fd < 0) return 122;
    close(fd);
    return 0;
  }
  if (index < argc && !strcmp(argv[index], "-N")) { no_update = 1; index++; }
  if (index < argc && !strcmp(argv[index], "-n")) { noninteractive = 1; index++; }
  if (index < argc && !strcmp(argv[index], "--")) index++;
  if (noninteractive && access(token, F_OK)) return 1;
  if (no_update) {
    event("grant-no-update");
  } else if (!noninteractive) {
    event("publish-token");
    fd = open(token, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (fd < 0) return 123;
    close(fd);
    usleep(200000);
  }
  prompt_marker = getenv("TEST_PROMPT_MARKER");
  if (prompt_marker && *prompt_marker) {
    char response[64];
    int tty;

    fd = open(prompt_marker, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (fd < 0 || dprintf(fd, "%ld %ld\n", (long)getppid(), (long)getpid()) < 0) return 118;
    close(fd);
    tty = open("/dev/tty", O_RDWR);
    if (tty < 0 || dprintf(tty, "Password: ") < 0 || read(tty, response, sizeof(response)) <= 0) {
      return 117;
    }
    close(tty);
    event("prompt-complete");
  }
  if (index >= argc || setgid(0) || setuid(0)) return 124;
  if (!strcmp(argv[index], "/usr/bin/dmesg")) {
    const char *delay_marker = getenv("TEST_DMESG_DELAY_MARKER");
    const char *bytes_value = getenv("TEST_DMESG_BYTES");
    const char *status_value = getenv("TEST_DMESG_STATUS");
    if (delay_marker && *delay_marker) {
      fd = open(delay_marker, O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (fd < 0) return 119;
      close(fd);
      sleep(5);
    }
    if (bytes_value && *bytes_value) {
      size_t bytes = strtoul(bytes_value, NULL, 10);
      while (bytes--) putchar('K');
    } else {
      puts("modeled kernel log");
    }
    return status_value ? atoi(status_value) : 0;
  }
  execv(argv[index], &argv[index]);
  return 126;
}
C
cc -O2 -Wall -Wextra -Werror -o "$stub_bin/sudo" "$test_tmp/sudo.c"
chown 0:0 "$stub_bin/sudo"
chmod 4755 "$stub_bin/sudo"

cat >"$stub_bin/inxi" <<'STUB'
#!/bin/bash
: >"$TEST_COLLECTOR_RAN"
printf 'collector\n' >>"$TEST_EVENT_LOG"
printf 'harmless inxi output\n'
STUB
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
case "$*" in
  '-Q omarchy-dev') printf 'omarchy-dev audit\n' ;;
  '-Qqe'|'-Sql') : ;;
  *) exit 1 ;;
esac
STUB
for command in journalctl expac; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
for command in mkdir install; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
: >"$TEST_STAGING_MARKER"
"$TEST_REAL_SUDO" -n -- /usr/bin/install -o 0 -g 0 -m 0600 "$TEST_PAYLOAD" "$TEST_VICTIM" 2>/dev/null || :
exit 99
STUB
done
chmod 0755 "$stub_bin/inxi" "$stub_bin/pacman" "$stub_bin/journalctl" "$stub_bin/expac" \
  "$stub_bin/mkdir" "$stub_bin/install"

build_launcher() {
  local output=$1
  local payload=$2
  local source=${3:-$ROOT/default/omarchy/security/omarchy-debug-launcher.c}

  cc -static-pie -O2 -Wall -Wextra -Werror -DOMARCHY_DEBUG_TESTING=1 -DDMESG_LIMIT=4096 \
    "-DOMARCHY_DEBUG_COLLECTOR_PATH=\"$payload\"" "-DOMARCHY_SUDO_PATH=\"$stub_bin/sudo\"" \
    "-DOMARCHY_DEBUG_TRUST_ROOT=\"$test_tmp\"" \
    -o "$output" "$source"
}

cp "$ROOT/bin/omarchy-debug" "$collector"
build_launcher "$launcher" "$collector"
chmod 0755 "$launcher" "$collector"
chown 0:0 "$launcher" "$collector"
readelf -l "$launcher" | grep -q 'INTERP' && fail "debug launcher unexpectedly has a dynamic interpreter"
readelf -d "$launcher" | grep -q 'NEEDED' && fail "debug launcher unexpectedly needs a shared library"
readelf -W -l "$launcher" |
  awk '$1 == "GNU_STACK" { found = 1; if ($NF ~ /E/) bad = 1 } END { exit !(found && !bad) }' ||
  fail "debug launcher has a missing or executable GNU stack"
ldd_output=$(ldd "$launcher" 2>&1 || true)
[[ $ldd_output == *"statically linked"* || $ldd_output == *"not a dynamic executable"* ]] ||
  fail "ldd did not recognize the debug launcher as static"
[[ $(stat -c '%u:%a' "$launcher") == 0:755 && $(stat -c '%u:%a' "$collector") == 0:755 ]] ||
  fail "debug boundary artifacts are not root-owned 0755"
pass "debug uses a root-owned non-setuid static launcher and pinned collector"

metadata="$ROOT/default/omarchy/command-metadata/omarchy-debug"
for key in summary args examples requires-sudo; do
  metadata_line=$(grep -F "# omarchy:$key=" "$metadata")
  collector_line=$(grep -F "# omarchy:$key=" "$collector")
  [[ $metadata_line == "$collector_line" ]] ||
    fail "installed debug metadata drifted for $key"
done
installed="$test_tmp/installed"
mkdir -p "$installed/usr/bin" "$installed/usr/share/omarchy/command-metadata"
cp "$ROOT/bin/omarchy" "$installed/usr/bin/omarchy"
cp "$launcher" "$installed/usr/bin/omarchy-debug"
cp "$metadata" "$installed/usr/share/omarchy/command-metadata/omarchy-debug"
installed_help=$("$installed/usr/bin/omarchy" debug --help)
[[ $installed_help == *"omarchy debug [--no-sudo] [--print]"* &&
  $installed_help == *"Print debugging information"* ]] ||
  fail "installed ELF layout lost debug CLI metadata"
"$installed/usr/bin/omarchy" commands --json |
  jq -e '.commands[] | select(.binary == "omarchy-debug" and .requires_sudo == true)' >/dev/null ||
  fail "installed ELF layout lost debug sudo metadata"
pass "installed ELF entrypoint retains sidecar CLI help and sudo metadata"

printf 'debug-payload\n' >"$test_home/payload"
chown 1000:1000 "$test_home/payload"
chmod 0600 "$test_home/payload"

start_waiter() {
  rm -f "$victim" "$test_home/reused" "$test_home/waiter.pid"
  setpriv --reuid=1000 --regid=1000 --clear-groups \
    env -i HOME="$test_home" TEST_SUDO="$stub_bin/sudo" \
      TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
      TEST_PAYLOAD="$test_home/payload" TEST_VICTIM="$victim" \
      bash -c '
        echo $$ >"$HOME/waiter.pid"
        while [[ ! -e $TEST_WAITER_ARMED ]]; do /usr/bin/sleep 0.005; done
        while [[ -e $TEST_WAITER_ARMED ]]; do
          if "$TEST_SUDO" -n -- /usr/bin/install -o 0 -g 0 -m 0600 "$TEST_PAYLOAD" "$TEST_VICTIM" 2>/dev/null; then
            : >"$HOME/reused"
            exit 0
          fi
          /usr/bin/sleep 0.005
        done
      ' &
}

run_debug() {
  local command=$1
  shift
  setpriv --reuid=1000 --regid=1000 --clear-groups \
    env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime" \
      PATH="$stub_bin:/usr/bin:/bin" VIRTUAL_ENV="$test_home/venv" TEST_SUDO_TOKEN="$token" \
      TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
      TEST_COLLECTOR_RAN="$test_home/collector" TEST_STAGING_MARKER="$staging_marker" \
      TEST_REAL_SUDO="$stub_bin/sudo" TEST_PAYLOAD="$test_home/payload" TEST_VICTIM="$victim" \
      "$@" "$command" --print >/dev/null
}

pty_debug_command() {
  local prompt_marker=$1
  local -a command=(
    setpriv --reuid=1000 --regid=1000 --clear-groups
    env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime"
    PATH="$stub_bin:/usr/bin:/bin" VIRTUAL_ENV="$test_home/venv"
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed"
    TEST_PROMPT_MARKER="$prompt_marker" TEST_COLLECTOR_RAN="$test_home/collector"
    TEST_STAGING_MARKER="$staging_marker" TEST_REAL_SUDO="$stub_bin/sudo"
    TEST_PAYLOAD="$test_home/payload" TEST_VICTIM="$victim" "$launcher" --print
  )

  printf '%q ' "${command[@]}"
}

prompt_marker="$test_home/prompt-ready"
: >"$event_log"
rm -f "$armed" "$prompt_marker" "$test_home/collector" "$token"
prompt_command=$(pty_debug_command "$prompt_marker")
if ! printf 'test password\n' | /usr/bin/timeout 5 /usr/bin/script -qefc "$prompt_command" /dev/null \
  >/dev/null; then
  fail "cold sudo authentication could not complete through the foreground PTY"
fi
[[ -e $prompt_marker && -e $test_home/collector && ! -e $token ]] ||
  fail "PTY authentication did not reach collection or retained authorization"
grep -qxF prompt-complete "$event_log" || fail "PTY authentication did not read its password"
pass "cold sudo authentication reads and completes in the foreground PTY"

: >"$event_log"
rm -f "$armed" "$prompt_marker" "$test_home/collector" "$token"
prompt_command=$(pty_debug_command "$prompt_marker")
pty_input="$test_home/prompt-input"
mkfifo "$pty_input"
exec 9<>"$pty_input"
/usr/bin/timeout 5 /usr/bin/script -qefc "$prompt_command" /dev/null \
  <"$pty_input" >/dev/null &
pty_supervisor=$!
for attempt in {1..200}; do
  [[ ! -s $prompt_marker ]] || break
  sleep 0.005
done
[[ -s $prompt_marker ]] || fail "sudo did not begin its foreground PTY prompt"
read -r prompt_launcher_pid prompt_worker_pid <"$prompt_marker"
kill -TERM "$prompt_launcher_pid"
kill -TERM "$prompt_launcher_pid"
set +e
wait "$pty_supervisor"
prompt_status=$?
set -e
exec 9>&-
[[ $prompt_status == 143 && ! -e $test_home/collector && $(tail -n 1 "$event_log") == invalidate ]] ||
  fail "termination during the password prompt did not reap and revoke" "status=$prompt_status"
if kill -0 "$prompt_worker_pid" 2>/dev/null; then
  fail "password-prompting sudo worker survived launcher termination"
fi
pass "termination during a foreground sudo prompt reaps and revokes"

: >"$event_log"
: >"$token"
chown 1000:1000 "$token"
rm -f "$armed" "$test_home/collector" "$staging_marker"
start_waiter
run_debug "$launcher"
rm -f "$armed"
wait "$(<"$test_home/waiter.pid")" 2>/dev/null || true
[[ -e $test_home/collector && ! -e $victim && ! -e $test_home/reused && ! -e $token ]] ||
  fail "debug collector reused or retained sudo authorization"
[[ ! -e $staging_marker ]] || fail "debug resolved a staging command through hostile PATH"
[[ $(head -n 1 "$event_log") == invalidate ]] || fail "debug ran a collector before cold invalidation"
grep -qxF grant-no-update "$event_log" || fail "debug dmesg did not use sudo --no-update"
[[ $(grep -c '^invalidate$' "$event_log") -ge 2 ]] || fail "debug did not invalidate at entry and after dmesg"
pass "debug starts cold, pins staging, and keeps collectors outside fixed dmesg authorization"

: >"$event_log"
rm -f "$token" "$armed" "$test_home/collector"
mutant_source="$test_tmp/launcher-without-no-update.c"
mutant_collector="$test_tmp/omarchy-debug-mutant-collector"
mutant_launcher="$test_tmp/omarchy-debug-mutant"
sed 's/OMARCHY_SUDO_PATH, "-N", "--"/OMARCHY_SUDO_PATH, "--"/' \
  "$ROOT/default/omarchy/security/omarchy-debug-launcher.c" >"$mutant_source"
cp "$ROOT/bin/omarchy-debug" "$mutant_collector"
build_launcher "$mutant_launcher" "$mutant_collector" "$mutant_source"
chmod 0755 "$mutant_launcher" "$mutant_collector"
chown 0:0 "$mutant_launcher" "$mutant_collector"
start_waiter
run_debug "$mutant_launcher"
rm -f "$armed"
wait "$(<"$test_home/waiter.pid")" 2>/dev/null || true
[[ -e $test_home/reused && -e $victim ]] || fail "removing -N did not restore the modeled credential race"
pass "sudo --no-update is mutation-tested as the load-bearing worker guard"

: >"$event_log"
rm -f "$token" "$armed" "$test_home/collector" "$victim"
if run_debug "$launcher" TEST_SUDO_NO_N=1; then
  fail "debug accepted sudo without --no-update support"
fi
[[ ! -e $test_home/collector && ! -e $token && ! -e $victim ]] ||
  fail "unsupported sudo reached user-resolved collectors"
pass "unsupported sudo fails before user-resolved collection"

: >"$event_log"
: >"$token"
chown 1000:1000 "$token"
rm -f "$armed" "$test_home/collector" "$victim"
no_sudo_output=$(setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime" \
    PATH="$stub_bin:/usr/bin:/bin" MY_BASH_ENV=/dev/null VIRTUAL_ENV="$test_home/venv" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_COLLECTOR_RAN="$test_home/collector" TEST_STAGING_MARKER="$staging_marker" \
    TEST_REAL_SUDO="$stub_bin/sudo" TEST_PAYLOAD="$test_home/payload" TEST_VICTIM="$victim" \
    "$launcher" --no-sudo --print)
[[ $no_sudo_output == *"(skipped - --no-sudo flag used)"* && -e $test_home/collector && ! -e $token ]] ||
  fail "--no-sudo no longer skips dmesg while collecting the user report"
! grep -q '^grant-no-update$' "$event_log" || fail "--no-sudo invoked privileged dmesg"
[[ $(grep -c '^invalidate$' "$event_log") -ge 2 ]] || fail "--no-sudo did not protect collectors from a cached token"
[[ $(stat -c '%a' "$test_home/runtime/omarchy-debug.log") == 600 ]] || fail "debug log is not private"
pass "--no-sudo preserves benign environment, revokes credentials, and writes a private report"

bash_env="$test_home/bash-env"
startup_marker="$test_home/bash-env-ran"
constructor_marker="$test_home/constructor-ran"
interpose_marker="$test_home/interposed-exec"
startup_padding=$(printf '%65536s' '')
cat >"$bash_env" <<'BASH_ENV'
: >"$TEST_STARTUP_MARKER"
set -o privileged
shift || :
function /usr/bin/env { return 0; }
function /usr/bin/readlink { printf '/usr/bin/bash\n'; }
function /usr/bin/sudo { "$TEST_REAL_SUDO" "${@/-N/}"; }
trap 'set +o privileged' DEBUG
BASH_ENV
cat >"$test_tmp/preload.c" <<'C'
#define _GNU_SOURCE
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

static char *real_sudo;
static char *interpose_marker;

static void mark(const char *path) {
  int fd;
  if (!path || !*path) return;
  fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0600);
  if (fd >= 0) close(fd);
}

__attribute__((constructor)) static void attack_startup(void) {
  const char *value = getenv("TEST_REAL_SUDO");
  if (value) real_sudo = strdup(value);
  value = getenv("TEST_INTERPOSE_MARKER");
  if (value) interpose_marker = strdup(value);
  mark(getenv("TEST_CONSTRUCTOR_MARKER"));
  value = getenv("TEST_ATTACK_BASH_ENV");
  if (value) setenv("BASH_ENV", value, 1);
  unsetenv("LD_PRELOAD");
}

int execve(const char *path, char *const argv[], char *const envp[]) {
  char *forwarded[64];
  int source = 0, target = 0;
  if (real_sudo && !strcmp(path, real_sudo)) {
    mark(interpose_marker);
    while (argv[source] && target < 63) {
      if (strcmp(argv[source], "-N")) forwarded[target++] = argv[source];
      source++;
    }
    forwarded[target] = NULL;
    return syscall(SYS_execve, path, forwarded, envp);
  }
  return syscall(SYS_execve, path, argv, envp);
}
C
cc -shared -fPIC -O2 -Wall -Wextra -Werror -o "$test_tmp/preload.so" "$test_tmp/preload.c"

: >"$event_log"
: >"$token"
chown 1000:1000 "$token"
rm -f "$armed" "$startup_marker" "$constructor_marker" "$interpose_marker" "$victim" "$test_home/collector"
start_waiter
run_debug "$launcher" LD_PRELOAD="$test_tmp/preload.so" TEST_ATTACK_BASH_ENV="$bash_env" \
  TEST_STARTUP_MARKER="$startup_marker" TEST_CONSTRUCTOR_MARKER="$constructor_marker" \
  TEST_INTERPOSE_MARKER="$interpose_marker" BASH_ENV="$bash_env" BASH_COMPAT=42 \
  BASH_LOADABLES_PATH="$test_home/loadables" POSIXLY_CORRECT=1 \
  TEST_STARTUP_PADDING="$startup_padding"
rm -f "$armed"
wait "$(<"$test_home/waiter.pid")" 2>/dev/null || true
[[ ! -e $constructor_marker && ! -e $startup_marker && ! -e $interpose_marker ]] ||
  fail "hostile pre-main code entered the static or sanitized debug boundary"
[[ ! -e $token && ! -e $victim && ! -e $test_home/reused ]] ||
  fail "constructor erasure or execve interposition reused authorization"
grep -qxF grant-no-update "$event_log" || fail "native entry lost fixed sudo -N under LD_PRELOAD"
pass "static entry defeats constructor erasure and execve/-N interposition"

: >"$event_log"
: >"$token"
chown 1000:1000 "$token"
rm -f "$startup_marker" "$constructor_marker" "$interpose_marker" "$test_home/collector"
set +e
setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" PATH="$stub_bin:/usr/bin:/bin" LD_PRELOAD="$test_tmp/preload.so" \
    TEST_ATTACK_BASH_ENV="$bash_env" TEST_STARTUP_MARKER="$startup_marker" \
    TEST_CONSTRUCTOR_MARKER="$constructor_marker" TEST_INTERPOSE_MARKER="$interpose_marker" \
    TEST_REAL_SUDO="$stub_bin/sudo" TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" \
    TEST_WAITER_ARMED="$armed" TEST_COLLECTOR_RAN="$test_home/collector" \
    /usr/bin/bash "$collector" -p --print >/dev/null 2>&1
ordinary_status=$?
set -e
[[ $ordinary_status != 0 && -e $constructor_marker && -e $startup_marker && -e $token ]] ||
  fail "ordinary Bash constructor regression did not exercise and reject hostile startup"
[[ ! -s $event_log && ! -e $interpose_marker && ! -e $test_home/collector ]] ||
  fail "ordinary hostile Bash reached a launcher-owned sudo operation"
pass "ordinary Bash startup cannot enter the native authorization boundary"

: >"$event_log"
: >"$token"
chown 1000:1000 "$token"
rm -f "$test_home/collector" "$victim"
if setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" PATH="$stub_bin:/usr/bin:/bin" TARGET="$collector" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_REAL_SUDO="$stub_bin/sudo" TEST_COLLECTOR_RAN="$test_home/collector" \
    /usr/bin/bash -c '
      set -o privileged
      function /usr/bin/env { return 0; }
      function /usr/bin/sudo { "$TEST_REAL_SUDO" "$@"; }
      BASH_ARGV0=$TARGET
      source "$TARGET" --print
    ' "$collector" >/dev/null 2>&1; then
  fail "collector accepted a forged same-shell source launch"
fi
[[ -e $token && ! -s $event_log && ! -e $victim && ! -e $test_home/collector ]] ||
  fail "forged same-shell source reached collection or sudo"
pass "forged same-shell startup cannot reach the collector or native sudo boundary"

interactive_continued="$test_home/interactive-continued"
: >"$event_log"
rm -f "$interactive_continued" "$test_home/collector" "$victim"
set +e
setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" PATH="$stub_bin:/usr/bin:/bin" TARGET="$collector" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_REAL_SUDO="$stub_bin/sudo" TEST_COLLECTOR_RAN="$test_home/collector" \
    TEST_INTERACTIVE_CONTINUED="$interactive_continued" \
    /usr/bin/bash --noprofile --norc -i >/dev/null 2>&1 <<'INTERACTIVE'
set -o privileged
function /usr/bin/sudo { "$TEST_REAL_SUDO" "$@"; }
BASH_ARGV0=$TARGET
source "$TARGET" --print
: >"$TEST_INTERACTIVE_CONTINUED"
exit
INTERACTIVE
set -e
[[ -e $interactive_continued && -e $token && ! -s $event_log && ! -e $victim && ! -e $test_home/collector ]] ||
  fail "interactive source did not return safely without entering the collector"
pass "interactive source returns without collection or native sudo activity"

! grep -q '/proc/\$\$/environ' "$ROOT/bin/omarchy-debug" ||
  fail "debug still trusts an in-process /proc environment startup proof"
pass "native authorization no longer depends on readable or bounded proc environment text"

: >"$event_log"
wrong_script="$test_tmp/not-omarchy-debug"
cp "$collector" "$wrong_script"
chmod 0755 "$wrong_script"
for forged in "$wrong_script" "$collector" /dev/null; do
  if setpriv --reuid=1000 --regid=1000 --clear-groups env -i "$launcher" "$forged" --print \
    >/dev/null 2>&1; then
    fail "launcher accepted caller-selected payload $forged"
  fi
done
[[ ! -s $event_log ]] || fail "rejected payload selection reached sudo"
chmod 0775 "$collector"
if run_debug "$launcher" 2>/dev/null; then
  fail "launcher accepted a group-writable packaged collector"
fi
chmod 0755 "$collector"
[[ ! -s $event_log ]] || fail "wrong-mode collector reached sudo"
chmod 0775 "$test_tmp/lib/omarchy"
run_debug "$launcher" 2>/dev/null && fail "launcher accepted a writable collector ancestor"
chmod 0755 "$test_tmp/lib/omarchy"
chown 1000:1000 "$test_tmp/lib"
run_debug "$launcher" 2>/dev/null && fail "launcher accepted a caller-owned collector ancestor"
chown 0:0 "$test_tmp/lib"
mv "$test_tmp/lib/omarchy" "$test_tmp/lib/omarchy-real"
ln -s omarchy-real "$test_tmp/lib/omarchy"
run_debug "$launcher" 2>/dev/null && fail "launcher followed a collector ancestor symlink"
unlink "$test_tmp/lib/omarchy"
mv "$test_tmp/lib/omarchy-real" "$test_tmp/lib/omarchy"
[[ ! -s $event_log ]] || fail "untrusted collector ancestry reached sudo"
pass "forged argv and untrusted collector file or ancestry fail before sudo"

after_pin="$test_home/after-pin"
replacement_ran="$test_home/replacement-ran"
original_collector="$test_tmp/original-collector"
: >"$event_log"
rm -f "$after_pin" "$replacement_ran" "$test_home/collector"
setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime" PATH="$stub_bin:/usr/bin:/bin" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_AFTER_PIN_DELAY_MARKER="$after_pin" TEST_REPLACEMENT_RAN="$replacement_ran" \
    TEST_COLLECTOR_RAN="$test_home/collector" "$launcher" --no-sudo --print >/dev/null &
replace_pid=$!
for attempt in {1..200}; do
  [[ ! -e $after_pin ]] || break
  sleep 0.005
done
[[ -e $after_pin ]] || fail "collector pin race did not become ready"
mv "$collector" "$original_collector"
cat >"$collector" <<'REPLACEMENT'
#!/bin/bash -p
: >"$TEST_REPLACEMENT_RAN"
REPLACEMENT
chmod 0755 "$collector"
wait "$replace_pid"
[[ -e $test_home/collector && ! -e $replacement_ran ]] ||
  fail "post-validation collector replacement changed the executed payload"
mv "$original_collector" "$collector"
pass "collector execution stays pinned to the validated inode across replacement"

: >"$event_log"
rm -f "$test_home/collector"
if run_debug "$launcher" TEST_DMESG_BYTES=4097 2>"$test_home/oversized-error"; then
  fail "debug accepted an oversized kernel log"
fi
grep -q 'exceeds the safe debug collection limit' "$test_home/oversized-error" ||
  fail "oversized kernel log did not report its bounded failure"
[[ ! -e $test_home/collector && $(tail -n 1 "$event_log") == invalidate ]] ||
  fail "oversized kernel log was published or not followed by revocation"
pass "oversized kernel output fails closed before Bash collection"

: >"$event_log"
rm -f "$test_home/collector"
if run_debug "$launcher" TEST_DMESG_STATUS=9 2>/dev/null; then
  fail "debug accepted a failed privileged dmesg worker"
fi
[[ ! -e $test_home/collector && $(tail -n 1 "$event_log") == invalidate ]] ||
  fail "failed dmesg reached collection or skipped final revocation"
pass "privileged worker failure is reaped and revoked before collection"

revoke_armed="$test_home/revoke-armed"
: >"$token"
chown 1000:1000 "$token"
rm -f "$revoke_armed" "$test_home/collector"
setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime" PATH="$stub_bin:/usr/bin:/bin" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_DELAY_INVALIDATE_MARKER="$revoke_armed" TEST_COLLECTOR_RAN="$test_home/collector" \
    "$launcher" --no-sudo --print >/dev/null 2>&1 &
signal_pid=$!
for attempt in {1..200}; do
  [[ ! -e $revoke_armed ]] || break
  sleep 0.005
done
[[ -e $revoke_armed ]] || fail "native signal cleanup did not begin blocking revocation"
kill -TERM "$signal_pid"
kill -TERM "$signal_pid"
set +e
wait "$signal_pid"
signal_status=$?
set -e
[[ $signal_status == 143 && ! -e $token && ! -e $test_home/collector ]] ||
  fail "a second TERM interrupted native sudo revocation" "status=$signal_status"
pass "native cleanup ignores repeated TERM until cached authorization is revoked"

post_fork="$test_home/post-fork"
dmesg_ready="$test_home/dmesg-ready"
: >"$token"
chown 1000:1000 "$token"
rm -f "$post_fork" "$dmesg_ready" "$test_home/collector"
setpriv --reuid=1000 --regid=1000 --clear-groups \
  env -i HOME="$test_home" XDG_RUNTIME_DIR="$test_home/runtime" PATH="$stub_bin:/usr/bin:/bin" \
    TEST_SUDO_TOKEN="$token" TEST_EVENT_LOG="$event_log" TEST_WAITER_ARMED="$armed" \
    TEST_DMESG_DELAY_MARKER="$dmesg_ready" TEST_POST_FORK_DELAY_MARKER="$post_fork" \
    TEST_COLLECTOR_RAN="$test_home/collector" "$launcher" --print >/dev/null 2>&1 &
worker_pid=$!
for attempt in {1..200}; do
  [[ ! -e $post_fork ]] || break
  sleep 0.005
done
[[ -e $post_fork ]] || fail "post-fork signal race window did not become ready"
kill -TERM "$worker_pid"
kill -TERM "$worker_pid"
set +e
wait "$worker_pid"
worker_status=$?
set -e
[[ $worker_status == 143 && ! -e $token && ! -e $test_home/collector ]] ||
  fail "post-fork signals were lost before child publication" "status=$worker_status"
pass "blocked post-fork signals publish, terminate, reap, and revoke the fixed worker"
