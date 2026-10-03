#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill timeout; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"
pass "system lock waits for ttfx before closing its terminal"

lock_src="$ROOT/bin/omarchy-system-lock"
if grep -Fq '${XDG_RUNTIME_DIR:-/tmp}/omarchy-1password-lock.lock' "$lock_src"; then
  fail "1Password flock must not fall back to world-writable /tmp"
fi
grep -Fq '${XDG_RUNTIME_DIR:-/tmp/omarchy-$UID}' "$lock_src" ||
  fail "1Password flock falls back to a 0700 /tmp/omarchy-\$UID directory"
grep -Fq 'flock -n 9 || exit 0' "$lock_src" ||
  fail "1Password flock still dedupes an in-progress lock"
grep -Fq 'timeout --kill-after=1s 3s 1password --lock' "$lock_src" ||
  fail "system lock still issues 1password --lock"
pass "1Password lock file is not in world-writable /tmp"

runtime_dir="$tmpdir/runtime"
mkdir -m 700 -p "$runtime_dir"
: >"$call_log"

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $1 == -x && $2 == 1password ]]
SH
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == 1password ]]
SH
cat >"$mock_bin/1password" <<'SH'
#!/bin/bash
printf '1password %s\n' "$*" >>"$CALL_LOG"
SH
# Arch has util-linux flock; this suite also runs where it is not on PATH.
cat >"$mock_bin/flock" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" XDG_RUNTIME_DIR="$runtime_dir" \
  "$ROOT/bin/omarchy-system-lock"

for _ in {1..40}; do
  grep -Fq 'timeout --kill-after=1s 3s 1password --lock' "$call_log" && break
  sleep 0.05
done

grep -Fq 'timeout --kill-after=1s 3s 1password --lock' "$call_log" ||
  fail "system lock still calls 1password --lock when 1Password is running" "$(cat "$call_log")"
[[ -e $runtime_dir/omarchy-1password-lock.lock ]] ||
  fail "1Password flock is created under XDG_RUNTIME_DIR"
pass "1Password flock lives in the runtime directory"
