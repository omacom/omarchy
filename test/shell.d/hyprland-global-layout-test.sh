#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command flock
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/state/omarchy/workspace-layouts"
cat >"$scratch/bin/hyprctl" <<'STUB'
#!/bin/bash
case "$1" in
  workspaces)
    if [[ -n ${TEST_WORKSPACES:-} ]]; then
      printf '%s\n' "$TEST_WORKSPACES"
    else
      printf '%s\n' '[{"id":1,"windows":3},{"id":2,"windows":0},{"id":-99}]'
    fi
    ;;
  reload)
    echo reload >>"$TEST_LOG"
    if [[ ${TEST_INTERRUPT:-0} == 1 ]] && [[ $(grep -c '^reload$' "$TEST_LOG") == 1 ]]; then
      kill -TERM "$PPID"
    fi
    [[ ${TEST_RELOAD_FAIL:-0} == 0 ]]
    ;;
  configerrors) printf '%s' "${TEST_CONFIG_ERROR:-}" ;;
esac
STUB
cat >"$scratch/bin/omarchy-hyprland-workspace-layout-current" <<'STUB'
#!/bin/bash
if [[ ${TEST_CURRENT:-} == state ]]; then
  sed -n 's/.*default = "\([a-z]*\)".*/\1/p' "$XDG_STATE_HOME/omarchy/workspace-layouts/default.lua"
else
  printf '%s\n' "${TEST_CURRENT:-dwindle}"
fi
STUB
for command in omarchy-shell omarchy-notification-send; do
  cat >"$scratch/bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
STUB
 done
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH" XDG_STATE_HOME="$scratch/state" TEST_LOG="$scratch/log"
modes="$XDG_STATE_HOME/omarchy/workspace-layouts"
printf 'original mode\n' >"$modes/7.lua"
printf 'scratchpad\n' >"$modes/-99.lua"
"$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"
for file in default.lua 1.lua 2.lua 7.lua; do
  grep -q '"scrolling"' "$modes/$file" || fail "global switch reaches occupied, empty, saved, and future workspaces"
done
[[ $(cat "$modes/-99.lua") == scratchpad ]] || fail "global switch preserves special workspaces"
[[ $(find "$XDG_STATE_HOME/omarchy/workspace-layout-backups" -name 7.lua -exec cat {} \;) == "original mode" ]] || fail "previous choices are backed up"
pass "global scrolling reaches all numbered workspaces and preserves a backup"
TEST_CURRENT=scrolling "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"
for file in default.lua 1.lua 2.lua 7.lua; do
  grep -q '"dwindle"' "$modes/$file" || fail "global switch returns every workspace to dwindle"
done
pass "scrolling switches globally back to dwindle"
cp -a "$modes" "$scratch/before"
if TEST_RELOAD_FAIL=1 "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
  fail "failed reload must fail the command"
fi
diff -r "$scratch/before" "$modes" || fail "failed reload restores previous choices"
pass "failed reload restores previous workspace choices"
if TEST_CONFIG_ERROR='bad config' "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
  fail "configuration errors must fail the command"
fi
diff -r "$scratch/before" "$modes" || fail "configuration errors restore previous choices"
pass "configuration errors restore previous workspace choices"
if TEST_WORKSPACES='{}' "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
  fail "broken workspace query must fail the command"
fi
diff -r "$scratch/before" "$modes" || fail "broken query must leave previous choices untouched"
pass "broken workspace query leaves previous choices untouched"

for payload in '[{"id":"oops"}]' '[{}]' '[{"id":1.5}]'; do
  if TEST_WORKSPACES="$payload" "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
    fail "malformed workspace identifiers must fail the command"
  fi
  diff -r "$scratch/before" "$modes" || fail "malformed identifiers leave choices untouched"
done
pass "malformed workspace identifiers leave choices untouched"
if TEST_CURRENT=unknown "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
  fail "unknown layout must fail the command"
fi
diff -r "$scratch/before" "$modes" || fail "unknown layout leaves choices untouched"
pass "unknown current layout leaves choices untouched"
: >"$TEST_LOG"
if TEST_INTERRUPT=1 "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"; then
  fail "interrupted apply must fail the command"
fi
diff -r "$scratch/before" "$modes" || fail "interrupted apply restores previous choices"
pass "interrupted apply restores previous choices"
TEST_WORKSPACES='[]' TEST_CURRENT=floating "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"
grep -q '"scrolling"' "$modes/default.lua" || fail "empty session still sets the future default"
pass "floating and empty sessions switch to the scrolling default"

TEST_CURRENT=scrolling "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global"
TEST_CURRENT=state "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global" &
first=$!
TEST_CURRENT=state "$ROOT/bin/omarchy-hyprland-workspace-layout-toggle-global" &
second=$!
wait "$first"
wait "$second"
grep -q '"dwindle"' "$modes/default.lua" || fail "concurrent global presses must be serialized"
pass "concurrent global presses are serialized and read the committed state"
