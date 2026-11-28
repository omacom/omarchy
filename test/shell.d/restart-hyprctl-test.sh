#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

log="$test_tmp/hyprctl.log"
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HYPRCTL_LOG"
echo ok
exit "${HYPRCTL_EXIT:-0}"
SH
chmod +x "$test_tmp/bin/hyprctl"

reload() {
  : >"$log"
  env PATH="$test_tmp/bin:$PATH" HYPRCTL_LOG="$log" "$@" "$ROOT/bin/omarchy-restart-hyprctl"
}

reload env HYPRLAND_INSTANCE_SIGNATURE=abc_1_1
[[ $(<"$log") == "reload" ]] || fail "reloads the session's own instance" "$(<"$log")"
pass "reloads the session's own instance"

reload env -u HYPRLAND_INSTANCE_SIGNATURE
[[ $(<"$log") == "--instance 0 reload" ]] || fail "reaches Hyprland outside the session" "$(<"$log")"
pass "reaches the running Hyprland outside the session"

# Migrations save config from outside the session, sometimes with no Hyprland running.
reload env -u HYPRLAND_INSTANCE_SIGNATURE HYPRCTL_EXIT=1 || fail "no running Hyprland does not fail the caller"
pass "no running Hyprland does not fail the caller"
