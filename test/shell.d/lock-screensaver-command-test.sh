#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin" "$tmpdir/home"

# The lock IPC answers with $LOCK_RESULT.
cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf 'omarchy-shell %s\n' "$*" >>"$CALL_LOG"
echo "$LOCK_RESULT"
SH
cat >"$mock_bin/omarchy-screensaver" <<'SH'
#!/bin/bash
printf 'native %s\n' "$*" >>"$CALL_LOG"
SH
for command in hyprctl pkill timeout; do
  printf '#!/bin/bash\nprintf "%%s %%s\\n" "$(basename "$0")" "$*" >>"$CALL_LOG"\n' >"$mock_bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$mock_bin/pgrep"
chmod +x "$mock_bin"/*

# The launcher names the native screensaver by its packaged path.
sed "s|/usr/lib/omarchy-screensaver/omarchy-screensaver|$mock_bin/omarchy-screensaver|" "$ROOT/bin/omarchy-launch-screensaver" >"$mock_bin/omarchy-launch-screensaver"
chmod +x "$mock_bin/omarchy-launch-screensaver"

run() {
  : >"$call_log"
  HOME="$tmpdir/home" PATH="$mock_bin:$ROOT/bin:$PATH" CALL_LOG="$call_log" LOCK_RESULT="${LOCK_RESULT-ok}" "$@"
}

run "$ROOT/bin/omarchy-system-lock" --screensaver ||
  fail "system lock --screensaver succeeds when the lock IPC answers ok"
[[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] ||
  fail "system lock --screensaver asks the lock for screensaver mode" "$(<"$call_log")"
rg -q '^hyprctl switchxkblayout' "$call_log" ||
  fail "system lock --screensaver resets the keyboard layout like a normal lock" "$(<"$call_log")"
pass "system lock --screensaver takes the lock in screensaver mode"

for result in already-locked failed missing-pam ""; do
  if LOCK_RESULT=$result run "$ROOT/bin/omarchy-system-lock" --screensaver 2>/dev/null; then
    fail "system lock --screensaver reports a lock that answered '$result'"
  fi
  ! rg -q '^hyprctl ' "$call_log" || fail "a failed screensaver lock stops before the lock cleanup"
done
pass "a screensaver lock that fails exits 1 before the lock cleanup"

run "$ROOT/bin/omarchy-system-lock"
[[ $(head -1 "$call_log") == "omarchy-shell lock lock" ]] ||
  fail "system lock without arguments keeps the normal lock" "$(<"$call_log")"
pass "system lock without arguments keeps the normal lock"

run omarchy-launch-screensaver force
[[ $(<"$call_log") == "native force" ]] ||
  fail "the launcher starts the native screensaver by default" "$(<"$call_log")"
pass "the launcher starts the native screensaver by default"

toggles="$tmpdir/home/.local/state/omarchy/toggles"
mkdir -p "$toggles"
touch "$toggles/screensaver-locked"
run omarchy-launch-screensaver
[[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] && ! rg -q '^native' "$call_log" ||
  fail "with screensaver-locked on, the launcher locks in screensaver mode" "$(<"$call_log")"
pass "with screensaver-locked on, the launcher locks in screensaver mode"

touch "$toggles/screensaver-off"
if run omarchy-launch-screensaver; then fail "screensaver-off still stops the idle screensaver lock"; fi
[[ ! -s $call_log ]] || fail "screensaver-off takes no lock" "$(<"$call_log")"
run omarchy-launch-screensaver force
[[ $(head -1 "$call_log") == "omarchy-shell lock screensaver" ]] ||
  fail "force starts the screensaver lock with screensaver-off on" "$(<"$call_log")"
pass "screensaver-off and force apply to the screensaver lock"
