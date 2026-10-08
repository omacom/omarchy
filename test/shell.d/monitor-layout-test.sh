#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const layout = requireFromRoot('shell/plugins/panels/display-settings/LayoutModel.js')
const monitors = [{name: 'DP-1', width: 1920, height: 1080, refreshRate: 59.999,
  scale: 1, transform: 1, x: -1080, y: 0, availableModes: ['1920x1080@60.00Hz', '1920x1080@60.00Hz']}]
const displays = layout.fromMonitors(monitors)
assertEqual(displays[0].mode, '1920x1080@60.00', 'selects nearest advertised refresh rate')
assertEqual(displays[0].modes.length, 1, 'deduplicates driver modes')
assertDeepEqual(layout.size(displays[0]), {width: 1080, height: 1920}, 'portrait swaps logical dimensions')
assertDeepEqual(layout.bounds(displays), {x: -1080, y: 0, width: 1080, height: 1920}, 'canvas handles negative coordinates')
const owned = [{id: 2, monitor: 'eDP-1'}, {id: 1, monitor: 'DP-1'}]
for (const operation of [() => layout.assignments('3 3', 'DP-1', owned),
  () => layout.assignments('2', 'DP-1', owned),
  () => layout.assignWorkspace(owned, 2, 'DP-1', false),
  () => layout.owner([{id: 1, monitor: 'DP-1'}, {id: 1, monitor: 'DP-2'}], 1)]) {
  let rejected = false
  try { operation() } catch (_) { rejected = true }
  assertEqual(rejected, true, 'rejects duplicate ownership or unconfirmed transfer')
}
assertDeepEqual(layout.assignWorkspace(owned, 2, 'DP-1', true),
  [{id: 1, monitor: 'DP-1'}, {id: 2, monitor: 'DP-1'}], 'confirmed transfer retains exactly one owner')
assertDeepEqual(layout.workspaceIds([{id: 12, monitor: 'DP-1'}], [12, 11]),
  [1,2,3,4,5,6,7,8,9,10,11,12], 'one row per workspace')
const pair = displays.concat([{name: 'eDP-1', mode: '1920x1080@60', scale: 1.5, transform: 0, x: 0, y: 0}])
assertDeepEqual(layout.place(pair, 'DP-1', 'eDP-1', 'right')[0].x, 1280, 'relative placement uses scaled logical dimensions')
assertDeepEqual(layout.snapPosition(pair, 'DP-1', 1275, 100, 10), {x: 1280, y: 100}, 'drag snaps to neighboring edge')
assertDeepEqual(layout.move(pair, 'DP-1', 123.4, -200.6)[0].y, -201, 'both coordinates commit together')
assertDeepEqual(layout.request(displays, [{id: 1, monitor: 'DP-1'}, {id: 2, monitor: 'offline'}]).workspaces,
  [{id: 1, monitor: 'DP-1'}], 'preview only sends active monitor assignments while model retains disconnected ownership')
const snapDisplays = [{name: 'moving', mode: '10x10@60', scale: 1, transform: 0, x: 0, y: 0},
  {name: 'far', mode: '10x10@60', scale: 1, transform: 0, x: 100, y: 100},
  {name: 'near', mode: '10x10@60', scale: 1, transform: 0, x: 95, y: 100}]
assertEqual(layout.snapPosition(snapDisplays, 'moving', 94, 0, 10).x, 95, 'nearest edge wins without chained snapping')
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
  if [[ $1 == "eval" || $1 == "reload" ]]; then
    python3 - "$1" "${2:-}" "$TEST_LAYOUT_LOG.monitors" "$XDG_CONFIG_HOME/hypr/monitors.lua" <<'PY_STUB'
import json, os, re, sys
verb, code, runtime, config = sys.argv[1:]
monitors = json.load(open(runtime)) if os.path.exists(runtime) else [dict(name='DP-1', width=1920, height=1080, refreshRate=60, x=0, y=0, scale=1, transform=0, mirrorOf='none', availableModes=['1920x1080@60.00Hz'])]
if verb == 'reload':
  code = open(config).read()
for match in re.finditer(r'output = "([^"\n]+)", mode = "([^"\n]+)", position = "(-?\d+)x(-?\d+)", scale = ([\d.]+), transform = (\d+)', code):
  name, mode, x, y, scale, transform = match.groups()
  width, height, rate = re.split(r'[x@]', mode)
  for monitor in monitors:
    if monitor['name'] == name:
      monitor.update(width=int(width), height=int(height), refreshRate=float(rate), x=int(x), y=int(y), scale=float(scale), transform=int(transform))
if verb == 'reload' and os.environ.get('TEST_LAYOUT_RELOAD_MISMATCH') == '1':
  monitors[0]['x'] += 10
with open(runtime, 'w') as f:
  json.dump(monitors, f)
PY_STUB
  fi
  echo ok
  ;;
esac
SH
chmod +x "$sandbox/bin/hyprctl"
printf '#!/bin/bash\nexit "${TEST_LAYOUT_TIMER_FAIL:-0}"\n' >"$sandbox/bin/systemd-run"
chmod +x "$sandbox/bin/systemd-run"
export PATH="$sandbox/bin:$PATH" OMARCHY_PATH="$ROOT"
printf '%s\n' '-- personal settings' 'hl.env("GDK_SCALE", "1")' >"$XDG_CONFIG_HOME/hypr/monitors.lua"
original=$(cat "$XDG_CONFIG_HOME/hypr/monitors.lua")
request='{"displays":[{"name":"DP-1","mode":"1920x1080@60.00","x":-1080,"y":0,"scale":1,"transform":1}],"workspaces":[{"id":1,"monitor":"DP-1"},{"id":2,"monitor":"DP-1"}]}'
cli="$ROOT/bin/omarchy-monitor-layout"
token=$("$cli" preview "$request" | jq -r .token)
[[ $(cat "$XDG_CONFIG_HOME/hypr/monitors.lua") == "$original" ]] || fail 'preview leaves config untouched'
"$cli" state | jq -e --argjson expected "$request" '.preview == $expected and .pending != null' >/dev/null || fail 'reopened editor recovers preview assignments'
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
  "$(jq '.workspaces += [.workspaces[0]]' <<<"$request")" \
  "$(jq '.displays = []' <<<"$request")"; do
  if "$cli" preview "$invalid" >/dev/null 2>&1; then fail 'rejects invalid layout'; fi
done
pass 'rejects injection, unsupported rates, invalid workspaces and empty layouts'

# The saved file is not enough: a successful reload must reproduce runtime geometry.
before=$(cat "$XDG_CONFIG_HOME/hypr/monitors.lua")
token=$("$cli" preview "$request" | jq -r .token)
if TEST_LAYOUT_RELOAD_MISMATCH=1 "$cli" keep "$token" >/dev/null 2>&1; then fail 'detects reload geometry mismatch'; fi
[[ $(cat "$XDG_CONFIG_HOME/hypr/monitors.lua") == "$before" ]] || fail 'reload mismatch restores file'
pass 'reload geometry mismatch restores file and runtime'

sed -i '/^-- END OMARCHY DISPLAY LAYOUT$/i hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.00", position = "4000x0", scale = 1, transform = 0, disabled = false })' "$XDG_CONFIG_HOME/hypr/monitors.lua"
"$cli" scale DP-1 2
rg -q 'output = "DP-1".*position = "-1080x0".*scale = 2.*transform = 1' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'scale retains portrait and position'
rg -q 'output = "HDMI-A-1".*position = "4000x0"' "$XDG_CONFIG_HOME/hypr/monitors.lua" || fail 'retains unplugged monitor rule'
"$cli" state | jq -e '.monitors[0].scale == 2 and .monitors[0].transform == 1 and .monitors[0].x == -1080 and .pending == null' >/dev/null || fail 'scale survives reload'
pass 'focused scale persists explicit geometry and disconnected rules'

# Preview and scale share a single pending transaction.
token=$("$cli" preview "$request" | jq -r .token)
if "$cli" scale DP-1 1.25 >/dev/null 2>&1; then fail 'scale rejects concurrent preview'; fi
"$cli" revert "$token"
pass 'scale cannot overwrite an active preview'

# Exercise the actual scale -> resize -> preview -> keep -> reload pipeline with
# three outputs. The stub reload reads the persisted file, not the request.
python3 - "$TEST_LAYOUT_LOG.monitors" <<'PY_FIXTURE'
import json, sys
monitors = [dict(name=name, width=1920, height=1080, refreshRate=60, x=x, y=0, scale=1, transform=0, mirrorOf='none', availableModes=['1920x1080@60.00Hz']) for name, x in [('eDP-1', 0), ('DP-1', 1920), ('DP-2', 3840)]]
json.dump(monitors, open(sys.argv[1], 'w'))
PY_FIXTURE
"$cli" scale DP-1 2
"$cli" state | jq -e '.monitors | any(.name == "eDP-1" and .x == 0 and .scale == 1) and any(.name == "DP-1" and .x == 1920 and .scale == 2) and any(.name == "DP-2" and .x == 2880)' >/dev/null || fail 'chain resize survives actual file reload'
pass 'three-output resize preserves anchor and chain across saved-file reload'
