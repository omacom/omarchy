#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const layout = requireFromRoot('shell/plugins/panels/monitor/LayoutModel.js')
const monitors = [{name: 'DP-1', width: 1920, height: 1080, refreshRate: 59.999,
  scale: 1, transform: 1, x: -1080, y: 0, availableModes: ['1920x1080@60.00Hz', '1920x1080@60.00Hz']}]
const displays = layout.fromMonitors(monitors)
assertEqual(displays[0].mode, '1920x1080@60.00', 'selects nearest advertised refresh rate')
assertEqual(displays[0].modes.length, 1, 'deduplicates driver modes')
assertDeepEqual(layout.size(displays[0]), {width: 1080, height: 1920}, 'portrait swaps logical dimensions')
assertDeepEqual(layout.bounds(displays), {x: -1080, y: 0, width: 1080, height: 1920}, 'canvas handles negative coordinates')
assertDeepEqual(layout.assignments('2 3 3', 'DP-1', [{id: 2, monitor: 'eDP-1'}, {id: 1, monitor: 'DP-1'}]),
  [{id: 2, monitor: 'DP-1'}, {id: 3, monitor: 'DP-1'}], 'reassigns workspaces without duplicate ownership')
for (const value of ['0', '100', '1.5', 'nope', '1;exec']) {
  let rejected = false
  try { layout.assignments(value, 'DP-1', []) } catch (_) { rejected = true }
  assertEqual(rejected, true, 'rejects invalid workspace input ' + value)
}
JS

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
mkdir -p "$sandbox/bin" "$sandbox/config/hypr"
export XDG_CONFIG_HOME="$sandbox/config" XDG_STATE_HOME="$sandbox/state" TEST_LAYOUT_LOG="$sandbox/log"
cat >"$sandbox/bin/hyprctl" <<'SH'
#!/bin/bash
case "$*" in
'-j monitors all')
  if [[ -f $TEST_LAYOUT_LOG.monitors ]]; then cat "$TEST_LAYOUT_LOG.monitors"
  else echo '[{"name":"DP-1","width":1920,"height":1080,"refreshRate":60,"x":0,"y":0,"scale":1,"transform":0,"mirrorOf":"none","availableModes":["1920x1080@60.00Hz"]}]'; fi
  ;;
'-j workspaces') echo '[{"id":1,"monitor":"DP-1"}]' ;;
configerrors) [[ ${TEST_LAYOUT_ERROR:-0} == 0 ]] || echo 'invalid config' ;;
*)
  printf '%s\n' "$*" >>"$TEST_LAYOUT_LOG"
  if [[ $1 == "eval" && $2 == *'hl.monitor('* ]]; then
    python3 - "$2" "$TEST_LAYOUT_LOG.monitors" <<'PY'
import json, re, sys
match = re.search(r'output = "([^"]+)", mode = "([^"]+)", position = "(-?\d+)x(-?\d+)", scale = ([\d.]+), transform = (\d+)', sys.argv[1])
if match:
  name, mode, x, y, scale, transform = match.groups()
  width, height, rate = re.split(r'[x@]', mode)
  with open(sys.argv[2], 'w') as f:
    json.dump([dict(name=name, width=int(width), height=int(height), refreshRate=float(rate), x=int(x), y=int(y), scale=float(scale), transform=int(transform), mirrorOf='none', availableModes=['1920x1080@60.00Hz'])], f)
PY
  fi
  echo ok
  ;;
esac
SH
chmod +x "$sandbox/bin/hyprctl"
printf '#!/bin/bash\nexit "${TEST_LAYOUT_TIMER_FAIL:-0}"\n' >"$sandbox/bin/systemd-run"
chmod +x "$sandbox/bin/systemd-run"
export PATH="$sandbox/bin:$PATH"
printf '%s\n' '-- personal settings' 'hl.env("GDK_SCALE", "1")' >"$XDG_CONFIG_HOME/hypr/monitors.lua"
original=$(cat "$XDG_CONFIG_HOME/hypr/monitors.lua")
request='{"displays":[{"name":"DP-1","mode":"1920x1080@60.00","x":-1080,"y":0,"scale":1,"transform":1}],"workspaces":[{"id":1,"monitor":"DP-1"},{"id":2,"monitor":"DP-1"}]}'
cli="$ROOT/bin/omarchy-monitor-layout"
token=$("$cli" preview "$request" | jq -r .token)
[[ $(cat "$XDG_CONFIG_HOME/hypr/monitors.lua") == "$original" ]] || fail 'preview leaves config untouched'
if "$cli" keep wrong-token >/dev/null 2>&1; then fail 'rejects stale token'; fi
"$cli" revert "$token"
[[ ! -f $XDG_STATE_HOME/omarchy/monitor-layout/pending.json ]] || fail 'revert clears pending state'
pass 'preview/revert preserves personal config and checks token'

token=$("$cli" preview "$request" | jq -r .token)
"$cli" keep "$token"
rg -q '^-- personal settings$' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'keep preserves personal settings'
rg -q 'workspace = "2", monitor = "DP-1"' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'keep persists unused workspace rule'
pass 'keep persists monitor and workspace rules'

token=$("$cli" preview "$request" | jq -r .token)
echo '-- concurrent edit' >>"$XDG_CONFIG_HOME/hypr/monitors.lua"
if "$cli" keep "$token" >/dev/null 2>&1; then fail 'rejects concurrent edit'; fi
rg -q '^-- concurrent edit$' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'preserves concurrent edit'
pass 'concurrent config edits are not overwritten'

before=$(cat "$XDG_CONFIG_HOME/hypr/monitors.lua")
token=$("$cli" preview "$request" | jq -r .token)
if TEST_LAYOUT_ERROR=1 "$cli" keep "$token" >/dev/null 2>&1; then fail 'rolls back invalid persisted config'; fi
[[ $(cat "$XDG_CONFIG_HOME/hypr/monitors.lua") == "$before" ]] || fail 'restores config after reload error'
pass 'reload errors restore personal config'

if TEST_LAYOUT_TIMER_FAIL=1 "$cli" preview "$request" >/dev/null 2>&1; then fail 'requires watchdog before changing layout'; fi
[[ ! -f $XDG_STATE_HOME/omarchy/monitor-layout/pending.json ]] || fail 'failed watchdog leaves no pending state'
pass 'watchdog launch failure cancels preview'

token=$("$cli" preview "$request" | jq -r .token)
pending="$XDG_STATE_HOME/omarchy/monitor-layout/pending.json"
jq '.expires = 0' "$pending" >"$sandbox/expired.json"
cp "$sandbox/expired.json" "$pending"
if "$cli" keep "$token" >/dev/null 2>&1; then fail 'rejects expired preview'; fi
[[ ! -f $pending ]] || fail 'expired keep reverts preview'
pass 'expired preview cannot be persisted'

# Managed assignments for unplugged displays remain available next time that
# display returns. Editing the connected screen must not delete them.
sed -i '/^-- END OMARCHY DISPLAY LAYOUT$/i hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1" })' "$XDG_CONFIG_HOME/hypr/monitors.lua"
token=$("$cli" preview "$request" | jq -r .token)
"$cli" keep "$token"
rg -q 'workspace = "9", monitor = "HDMI-A-1"' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'retains disconnected assignments'
"$cli" state | jq -e '.assignments | any(.id == 9 and .monitor == "HDMI-A-1")' >/dev/null || fail 'reports disconnected assignment'
pass 'disconnected workspace assignments survive edits'

token=$("$cli" preview "$request" | jq -r .token)
jq '.[0].refreshRate = 50' "$TEST_LAYOUT_LOG.monitors" >"$sandbox/changed-monitor.json"
cp "$sandbox/changed-monitor.json" "$TEST_LAYOUT_LOG.monitors"
if "$cli" keep "$token" >/dev/null 2>&1; then fail 'rejects changed runtime settings'; fi
pass 'external monitor changes cannot be silently kept'

before=$(cat "$XDG_CONFIG_HOME/hypr/monitors.lua")
token=$("$cli" preview "$request" | jq -r .token)
state="$XDG_STATE_HOME/omarchy/monitor-layout"
cp -p "$XDG_CONFIG_HOME/hypr/monitors.lua" "$state/monitors.lua.backup"
echo '-- interrupted Keep candidate' >>"$XDG_CONFIG_HOME/hypr/monitors.lua"
sha256sum "$XDG_CONFIG_HOME/hypr/monitors.lua" >"$state/candidate.sha256"
touch "$state/config.changed"
"$cli" revert "$token"
[[ $(cat "$XDG_CONFIG_HOME/hypr/monitors.lua") == "$before" ]] || fail 'restores interrupted keep'
pass 'watchdog rollback restores an interrupted Keep file'

for invalid in \
  "$(jq '.displays[0].name = "DP-1\"; os.execute(\"bad\")"' <<<"$request")" \
  "$(jq '.displays[0].mode = "1920x1080@144"' <<<"$request")" \
  "$(jq '.workspaces[0].id = 0' <<<"$request")" \
  "$(jq '.displays = []' <<<"$request")"; do
  if "$cli" preview "$invalid" >/dev/null 2>&1; then fail 'rejects invalid layout'; fi
done
pass 'rejects injection, unsupported rates, invalid workspaces and empty layouts'
