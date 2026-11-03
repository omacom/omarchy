#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

runtime="$test_tmp/runtime"
log="$test_tmp/hyprctl.log"
mkdir -p "$test_tmp/bin" "$runtime/hypr"

# Record which instance each reload reached; fail like hyprctl does (on stdout).
cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s %s\n' "$HYPRLAND_INSTANCE_SIGNATURE" "$*" >>"$HYPRCTL_LOG"
if [[ -n ${HYPRCTL_FAIL:-} ]]; then
  echo "$HYPRCTL_FAIL"
  exit 1
fi
echo ok
SH
chmod +x "$test_tmp/bin/hyprctl"

live_instance() {
  local dir="$runtime/hypr/$1"
  mkdir -p "$dir"
  python3 -c 'import socket, sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$dir/.socket.sock"
  touch -d "$2" "$dir"
}

reload() {
  : >"$log"
  env PATH="$test_tmp/bin:$PATH" HYPRCTL_LOG="$log" XDG_RUNTIME_DIR="$runtime" "$@" \
    "$ROOT/bin/omarchy-restart-hyprctl"
}

reload env -u HYPRLAND_INSTANCE_SIGNATURE ||
  fail "succeeds with no Hyprland running"
[[ ! -s $log ]] || fail "does not call hyprctl with no Hyprland running" "$(<"$log")"
pass "nothing to reload without a running Hyprland"

live_instance old_1_1 "2026-01-01 00:00"
live_instance new_2_2 "2026-01-02 00:00"
mkdir -p "$runtime/hypr/dead_3_3"
touch -d "2026-01-03 00:00" "$runtime/hypr/dead_3_3"

reload env -u HYPRLAND_INSTANCE_SIGNATURE || fail "reloads without a signature"
[[ $(<"$log") == "new_2_2 reload" ]] || fail "reloads the newest live instance" "$(<"$log")"
pass "finds the newest live instance outside the session"

reload env HYPRLAND_INSTANCE_SIGNATURE=gone_9_9 || fail "reloads with a stale signature"
[[ $(<"$log") == "new_2_2 reload" ]] || fail "replaces a stale signature" "$(<"$log")"
pass "replaces a signature whose Hyprland has exited"

reload env HYPRLAND_INSTANCE_SIGNATURE=old_1_1 || fail "reloads the session's own instance"
[[ $(<"$log") == "old_1_1 reload" ]] || fail "keeps a live signature" "$(<"$log")"
pass "keeps the session's own live instance"

if stderr=$(reload env HYPRLAND_INSTANCE_SIGNATURE=old_1_1 HYPRCTL_FAIL="config error" 2>&1 >/dev/null); then
  fail "reports a failed reload"
fi
[[ $stderr == *"config error"* ]] || fail "puts hyprctl's failure on stderr" "$stderr"
pass "a failed reload is reported on stderr"
