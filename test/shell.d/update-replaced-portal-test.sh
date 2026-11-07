#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

log="$test_tmp/systemctl.log"
proc_root="$test_tmp/proc"
home="$test_tmp/home"
bin="$test_tmp/bin"
mkdir -p "$proc_root/77" "$proc_root/78" "$home/.local/state/omarchy" "$bin"

touch "$test_tmp/xdg-desktop-portal-hyprland (deleted)"
ln -s "$test_tmp/xdg-desktop-portal-hyprland (deleted)" "$proc_root/77/exe"
touch "$test_tmp/xdg-desktop-portal"
ln -s "$test_tmp/xdg-desktop-portal" "$proc_root/78/exe"

cat >"$bin/systemctl" <<'BASH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
case "$*" in
  *'xdg-desktop-portal-hyprland.service')
    [[ $* == *restart* ]] || printf '77\n'
    ;;
  *'xdg-desktop-portal.service')
    [[ $* == *restart* ]] || printf '78\n'
    ;;
esac
exit 0
BASH
cat >"$bin/omarchy-restart-shell" <<'BASH'
#!/bin/bash
printf 'restarted shell\n' >>"$SYSTEMCTL_LOG"
exit 0
BASH
chmod 0755 "$bin/systemctl" "$bin/omarchy-restart-shell"

HOME="$home" \
  PATH="$bin:$PATH" \
  SYSTEMCTL="$bin/systemctl" \
  SYSTEMCTL_LOG="$log" \
  OMARCHY_PROC_ROOT="$proc_root" \
  "$ROOT/bin/omarchy-update-restart" --services-only >"$test_tmp/output" 2>&1

grep -F 'restart xdg-desktop-portal-hyprland.service' "$log" >/dev/null ||
  fail "update did not restart a portal whose executable was replaced" "$(cat "$log")"
if grep -F 'restart xdg-desktop-portal.service' "$log"; then
  fail "update restarted a portal that is still the installed binary" "$(cat "$log")"
fi
grep -F 'restarted shell' "$log" >/dev/null || fail "update did not restart the shell after the portal"
pass "update restarts a replaced desktop portal before the shell"
