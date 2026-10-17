#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command quickshell
require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/config" "$test_tmp/home" "$test_tmp/bin"
cp "$SHELL_TEST_DIR/fixtures/agents-reset/shell.qml" "$test_tmp/config/shell.qml"
ln -s "$ROOT/shell/plugins/agents" "$test_tmp/config/Agents"
ln -s "$ROOT/shell/Commons" "$test_tmp/config/Commons"
ln -s "$ROOT/shell/Ui" "$test_tmp/config/Ui"
cat >"$test_tmp/bin/omarchy-agent-usage-update" <<'SCRIPT'
#!/bin/bash
exit 0
SCRIPT
cat >"$test_tmp/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
SCRIPT
chmod +x "$test_tmp/bin"/*

# No desktop surfaces or provider requests: execute the real QML offscreen.
ulimit -c 0
HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" \
  XDG_CACHE_HOME="$test_tmp/home/.cache" XDG_STATE_HOME="$test_tmp/home/.local/state" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  PATH="$test_tmp/bin:$PATH" NOTIFICATION_LOG="$test_tmp/notifications" \
  env -u WAYLAND_DISPLAY -u DISPLAY -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE timeout 15 quickshell -p "$test_tmp/config" --no-color >"$test_tmp/log" 2>&1 || {
    cat "$test_tmp/log" >&2
    fail "agent reset QML fixture loads and completes"
  }
result=$(sed -n 's/.*RESULT //p' "$test_tmp/log" | tail -n1)
jq -e '.ok == true' <<<"$result" >/dev/null || {
  cat "$test_tmp/log" >&2
  fail "agent reset QML ownership and settings checks pass"
}
for _ in {1..50}; do
  [[ -s $test_tmp/notifications ]] && break
  sleep 0.02
done
[[ $(wc -l <"$test_tmp/notifications") == "1" ]] || fail "two widgets emit a single reset notification"
grep -F -- '--app-name Omarchy Agents' "$test_tmp/notifications" >/dev/null || fail "reset toast uses a DND-respecting app name"
pass "real QML shares one reset owner, reconciles settings, and emits one DND-respecting notification"

# Exercise discovery and FileView transitions with real local usage records.
usage_dir="$test_tmp/home/.local/state/omarchy/agents/usage"
mkdir -p "$usage_dir"
reset_at=$(date -u -d '+1 hour' '+%Y-%m-%dT%H:%M:%SZ')
for provider in codex codex-team; do
  jq -n --arg id "$provider" --arg reset "$reset_at" \
    '{id: $id, name: $id, limits: [{label: "Session", resetsAt: $reset}]}' >"$usage_dir/$provider.json"
done
cp "$SHELL_TEST_DIR/fixtures/agents-reset/inventory.qml" "$test_tmp/config/shell.qml"
rm "$test_tmp/notifications"
HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/home/.config" \
  XDG_CACHE_HOME="$test_tmp/home/.cache" XDG_STATE_HOME="$test_tmp/home/.local/state" \
  OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
  PATH="$test_tmp/bin:$PATH" NOTIFICATION_LOG="$test_tmp/notifications" \
  env -u WAYLAND_DISPLAY -u DISPLAY -u QT_QPA_PLATFORMTHEME -u QT_STYLE_OVERRIDE timeout 15 quickshell -p "$test_tmp/config" --no-color >"$test_tmp/log" 2>&1 || {
    cat "$test_tmp/log" >&2
    fail "agent reset inventory fixture loads and completes"
  }
result=$(sed -n 's/.*RESULT //p' "$test_tmp/log" | tail -n1)
jq -e '.ok == true' <<<"$result" >/dev/null || {
  cat "$test_tmp/log" >&2
  fail "agent reset inventory lifecycle checks pass"
}
[[ ! -e $test_tmp/notifications ]] || fail "removed provider produces no reset notification at announce time"
pass "real QML prunes removed records while retaining unreadable, loading and empty-limit providers"
