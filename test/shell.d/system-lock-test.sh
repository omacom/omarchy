#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

# A screensaver that does not exit within its second.
cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
exit 124
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock stops the native screensaver" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock waits for the native screensaver to clean up" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -KILL -f [/]usr/lib/omarchy-screensaver/omarchy-screensaver" ]] ||
  fail "system lock force-stops a stuck native screensaver" "calls: ${shutdown[*]}"
rg -A1 '^pkill -KILL ' "$call_log" | rg -q 'invisible = false' ||
  fail "system lock shows the cursor a killed screensaver left hidden" "$(<"$call_log")"
pass "system lock gives the screensaver a second to restore the cursor before killing it, then restores it itself"

# With 1Password running, lock it unless its own "Lock 1Password when computer
# locks" setting is off.
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

home="$tmpdir/home"
settings="$home/.config/1Password/settings/settings.json"
mkdir -p "$(dirname "$settings")"

locks_1password() {
  : >"$call_log"
  # The 1Password lock runs in the background; capturing stdout waits for it.
  : "$(env -u XDG_CONFIG_HOME HOME="$home" "$@" XDG_RUNTIME_DIR="$tmpdir" PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock")"
  rg -q '^timeout .* 1password --lock$' "$call_log"
}

rm -f "$settings"
locks_1password || fail "system lock locks 1Password when it has no settings file"

printf '{"security.autolock.onDeviceLock": true}\n' >"$settings"
locks_1password || fail "system lock locks 1Password when lock on device lock is on"

printf '{"security.autolock.onDeviceLock": false}\n' >"$settings"
! locks_1password || fail "system lock leaves 1Password unlocked when lock on device lock is off"

printf '{"security.autolock.onDeviceLock": false}garbage\n' >"$settings"
locks_1password || fail "system lock locks 1Password when its settings file is malformed"
printf '{"security.autolock.onDeviceLock": false}\n' >"$settings"

mkdir -p "$tmpdir/xdg/1Password/settings"
mv "$settings" "$tmpdir/xdg/1Password/settings/settings.json"
! locks_1password XDG_CONFIG_HOME="$tmpdir/xdg" || fail "system lock reads 1Password's settings from XDG_CONFIG_HOME"
pass "system lock respects 1Password's lock on device lock setting"
