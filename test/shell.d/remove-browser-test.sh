#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-remove-browser finds a browser's processes by the binaries its
# package owns. These run real processes from copies of system binaries laid
# out like the Brave and Brave Origin packages, both named "brave", with
# removal, sudo and the package database stubbed so nothing real is touched.
test_tmp=$(mktemp -d)
fake_pids=()
# Kills the fakes still running from this test's directory, never a process
# that has since taken over a fake's PID.
kill_fakes() {
  local pid exe
  for pid in "${fake_pids[@]}"; do
    exe=$(readlink "/proc/$pid/exe" 2>/dev/null) || continue
    [[ $exe != "$test_tmp"/* ]] || kill -KILL "$pid" 2>/dev/null || true
  done
}
cleanup() {
  kill_fakes
  rm -rf "$test_tmp"
}
trap cleanup EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/home" "$test_tmp/opt/brave-bin" "$test_tmp/opt/brave-origin-bin"
log="$test_tmp/drop.log"

# Each package owns its own "brave".
cat >"$stub_bin/pacman" <<SH
#!/bin/bash
[[ \$1 == "-Qlq" ]] || exit 1
echo "$test_tmp/opt/\$2/"
echo "$test_tmp/opt/\$2/brave"
SH
# Removal records which fake browsers were still alive at that moment. A killed
# fake this test hasn't reaped yet is a zombie, which counts as gone.
cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
alive=()
for pid in $(cat "$REMOVE_TEST_PIDS"); do
  state=$(awk '{print $3}' "/proc/$pid/stat" 2>/dev/null) || continue
  [[ -n $state && $state != "Z" ]] && alive+=("$pid")
done
echo "drop $1 alive=${alive[*]}" >>"$REMOVE_TEST_LOG"
SH
printf '#!/bin/bash\necho "sudo $*" >>"$REMOVE_TEST_LOG"\n' >"$stub_bin/sudo"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-pkg-present"
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/omarchy-pkg-missing"
printf '#!/bin/bash\necho none.desktop\n' >"$stub_bin/omarchy-cmd-default-browser"
# The wait between SIGTERM and SIGKILL is not what is under test.
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/sleep"
chmod +x "$stub_bin"/*

# Starts $1's "brave" from a copy of $2 with arguments $3..., recording its PID.
start_fake() {
  local package=$1 binary=$2 pid
  shift 2
  cp "$binary" "$test_tmp/opt/$package/brave"
  "$test_tmp/opt/$package/brave" "$@" &
  fake_pids+=("$!")
  # Keep bash from reporting the fakes this test kills.
  disown "$!"
  printf '%s\n' "${fake_pids[@]}" >"$test_tmp/pids"

  pid=${fake_pids[-1]}
  for _ in {1..100}; do
    [[ $(readlink "/proc/$pid/exe" 2>/dev/null) == "$test_tmp/opt/$package/brave" ]] && return
    /usr/bin/sleep 0.01
  done
  fail "the fake browser starts from its package's binary"
}

remove() {
  : >"$log"
  HOME="$test_tmp/home" REMOVE_TEST_LOG="$log" REMOVE_TEST_PIDS="$test_tmp/pids" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-remove-browser" "$1" >"$test_tmp/out" 2>&1 ||
    fail "removing $1 succeeds" "$(cat "$test_tmp/out" "$log")"
}

stop_fakes() {
  kill_fakes
  fake_pids=()
  : >"$test_tmp/pids"
}

# Brave running: removing Brave Origin leaves it alone, removing Brave closes
# it before the package goes.
start_fake brave-bin /usr/bin/sleep 300
brave_pid=${fake_pids[0]}
remove brave-origin
grep -Fx "drop brave-origin-bin alive=$brave_pid" "$log" >/dev/null ||
  fail "removing Brave Origin leaves a running Brave alone" "$(cat "$log")"
remove brave
grep -Fx "drop brave-bin alive=" "$log" >/dev/null ||
  fail "removing Brave closes it before the package goes" "$(cat "$log")"
pass "a running browser is closed before its package is removed, and only that package's"
stop_fakes

# A browser still running from a replaced install reports "<path> (deleted)".
start_fake brave-bin /usr/bin/sleep 300
rm "$test_tmp/opt/brave-bin/brave"
cp /usr/bin/sleep "$test_tmp/opt/brave-bin/brave"
[[ $(readlink "/proc/${fake_pids[0]}/exe") == "$test_tmp/opt/brave-bin/brave (deleted)" ]] ||
  fail "the fake browser is running from a deleted binary"
remove brave
grep -Fx "drop brave-bin alive=" "$log" >/dev/null ||
  fail "a browser running from a deleted binary is closed" "$(cat "$log")"
pass "a browser running from a deleted binary is closed"
stop_fakes

# One that handles SIGTERM without exiting is killed after receiving it.
start_fake brave-bin /usr/bin/bash -c 'trap '\''echo term >"$2"'\'' TERM; : >"$1"; while :; do :; done' bash "$test_tmp/term-ready" "$test_tmp/term-seen"
for _ in {1..100}; do
  [[ -f $test_tmp/term-ready ]] && break
  /usr/bin/sleep 0.01
done
[[ -f $test_tmp/term-ready ]] || fail "the fake browser installs its SIGTERM trap"
remove brave
[[ -f $test_tmp/term-seen ]] || fail "the fake browser receives SIGTERM before it is killed"
grep -Fx "drop brave-bin alive=" "$log" >/dev/null ||
  fail "a browser that ignores SIGTERM is killed" "$(cat "$log")"
pass "a browser that ignores SIGTERM is killed before removal"
stop_fakes
