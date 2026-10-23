#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""
CYCLE_LOG=""
CLI_HOME=""
CLI_STUBS=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
  if [[ -n $CLI_HOME && -d $CLI_HOME ]]; then
    rm -rf "$CLI_HOME"
  fi
  if [[ -n $CLI_STUBS && -d $CLI_STUBS ]]; then
    rm -rf "$CLI_STUBS"
  fi
}
trap cleanup EXIT

# The two gates: both cycles default on, only an explicit false in the user's
# shell.json turns one off, and the layout gate leaves plain workspace presses
# alone.
run_node_test <<'JS'
const fs = require('fs')

const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')
assert(/property bool cycleBackgroundOnClick: true/.test(barSource), 'the double-click background cycle starts on')
assert(/property bool cycleLayoutOnClick: true/.test(barSource), 'the workspace-press layout cycle starts on')
assert(/cycleBackgroundOnClick = clicks\.background !== false/.test(barSource), 'only an explicit false in shell.json turns the background cycle off')
assert(/cycleLayoutOnClick = clicks\.layout !== false/.test(barSource), 'only an explicit false in shell.json turns the layout cycle off')
assert(/if \(mouse\.button === Qt\.LeftButton && root\.cycleBackgroundOnClick\)/.test(barSource), 'the empty-space double-click cycles the background only while the click is on')

// Cloned widgets talk to the bar through PluginBarApi, so the switch has to
// reach that facade as well or their workspace presses go dead.
const apiSource = fs.readFileSync(root + '/shell/Ui/PluginBarApi.qml', 'utf8')
assert(/property bool cycleLayoutOnClick: true/.test(apiSource), 'installed widgets see the layout click switch')
assert(/api\.cycleLayoutOnClick = Qt\.binding\(function\(\) \{ return root\.cycleLayoutOnClick \}\)/.test(barSource), 'the bar mirrors the layout click switch into the widget API')

const workspacesSource = fs.readFileSync(root + '/shell/plugins/bar/widgets/Workspaces.qml', 'utf8')
assert(/if \(shown && root\.bar && root\.bar\.cycleLayoutOnClick\) root\.cycleLayout\(\)/.test(workspacesSource), 'the workspaces widget cycles the layout only while the click is on')
assert(/else if \(!shown\) root\.focusWorkspace\(modelData\)/.test(workspacesSource), 'a press on another workspace still focuses it')

const readmeSource = fs.readFileSync(root + '/shell/plugins/bar/README.md', 'utf8')
assert(/omarchy bar clicks/.test(readmeSource), 'the bar README documents the clicks command')

const manualSource = fs.readFileSync(root + '/manual/05-the-top-bar.md', 'utf8')
assert(/omarchy bar clicks/.test(manualSource), 'the manual documents the clicks command')
JS

# The clicks command reads and writes bar.clicks through the shared shell.json
# plumbing. A stubbed omarchy-shell keeps the refresh away from a real session.
require_command jq

CLI_HOME=$(mktemp -d)
CLI_STUBS=$(mktemp -d)
mkdir -p "$CLI_HOME/.config/omarchy"
printf '#!/bin/bash\nexit 0\n' >"$CLI_STUBS/omarchy-shell"
chmod +x "$CLI_STUBS/omarchy-shell"

run_bar_cli() {
  (
    export HOME="$CLI_HOME"
    export XDG_CONFIG_HOME="$CLI_HOME/.config"
    export OMARCHY_PATH="$ROOT"
    export PATH="$CLI_STUBS:$ROOT/bin:$PATH"
    bash "$ROOT/bin/omarchy-bar" "$@"
  )
}

# With no user shell.json both cycles read on.
state=$(run_bar_cli clicks)
[[ $state == $'background on\nlayout on' ]] || fail "bar clicks prints both on by default, got: $state"
pass "bar clicks prints both clicks on while the user config carries nothing"

# Turning one off writes its key and keeps the user's other settings.
printf '%s\n' '{"version":1,"idle":{"screensaver":10,"lock":20},"bar":{"position":"top","background":"glassy"}}' >"$CLI_HOME/.config/omarchy/shell.json"
run_bar_cli clicks background off >/dev/null
config=$(cat "$CLI_HOME/.config/omarchy/shell.json")
echo "$config" | jq -e '.bar.clicks.background == false' >/dev/null || fail "clicks background off writes bar.clicks.background false"
echo "$config" | jq -e '.bar.position == "top"' >/dev/null || fail "clicks background off keeps the bar position"
echo "$config" | jq -e '.bar.background == "glassy"' >/dev/null || fail "clicks background off keeps the bar background"
echo "$config" | jq -e '.idle.lock == 20' >/dev/null || fail "clicks background off keeps the idle block"
state=$(run_bar_cli clicks)
[[ $state == $'background off\nlayout on' ]] || fail "bar clicks prints background off and layout on, got: $state"
pass "bar clicks background off writes its key and keeps the rest of shell.json"

# The other one, then both at once.
run_bar_cli clicks layout off >/dev/null
state=$(run_bar_cli clicks)
[[ $state == $'background off\nlayout off' ]] || fail "bar clicks prints both off, got: $state"
run_bar_cli clicks on >/dev/null
config=$(cat "$CLI_HOME/.config/omarchy/shell.json")
echo "$config" | jq -e '.bar.clicks.background == true and .bar.clicks.layout == true' >/dev/null || fail "bare clicks on writes both true"
run_bar_cli clicks off >/dev/null
config=$(cat "$CLI_HOME/.config/omarchy/shell.json")
echo "$config" | jq -e '.bar.clicks.background == false and .bar.clicks.layout == false' >/dev/null || fail "bare clicks off writes both false"
pass "bare clicks on and off write both keys"

if run_bar_cli clicks banana >/dev/null 2>&1; then
  fail "clicks rejects a word that is neither background, layout, nor on/off"
fi
if run_bar_cli clicks background >/dev/null 2>&1; then
  fail "clicks background without on or off is refused"
fi
if run_bar_cli clicks background banana >/dev/null 2>&1; then
  fail "clicks background rejects a value that is neither on nor off"
fi
if run_bar_cli clicks on extra >/dev/null 2>&1; then
  fail "clicks on takes no further values"
fi
pass "bar clicks validates its arguments"

require_compositor "bar clicks test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar clicks test"
  exit 0
fi

TMPDIR=$(mktemp -d)
CYCLE_LOG="$TMPDIR/omarchy-bar-calls.log"
mkdir -p "$TMPDIR/home" "$TMPDIR/bin"
# The empty-space double-click cycles the background through omarchy-bar, and
# the bar syncs the compositor's blur through it as it starts. Log every call;
# the final count tells the cycles apart from the rest.
{
  echo '#!/bin/bash'
  echo 'echo "$*" >>"$OMARCHY_CYCLE_LOG"'
  echo 'exit 0'
} >"$TMPDIR/bin/omarchy-bar"
chmod +x "$TMPDIR/bin/omarchy-bar"
# The workspaces widget reads the active layout when it starts. Answer it
# without reaching the session's own layout script.
printf '#!/bin/bash\necho dwindle\n' >"$TMPDIR/bin/omarchy-hyprland-workspace-layout-current"
chmod +x "$TMPDIR/bin/omarchy-hyprland-workspace-layout-current"

# Run one fixture shell against the live compositor and wait for its result.
run_fixture() {
  local fixture="$1"
  local name="$2"
  local config_dir="$TMPDIR/$name"
  local result="$TMPDIR/$name-result.json"
  local log="$TMPDIR/$name.log"

  mkdir -p "$config_dir"
  cp "$SHELL_TEST_DIR/fixtures/bar-clicks/$fixture" "$config_dir/shell.qml"
  ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
  ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

  OMARCHY_PATH="$ROOT" \
  OMARCHY_QML_TEST_RESULT="$result" \
  OMARCHY_CYCLE_LOG="$CYCLE_LOG" \
  HOME="$TMPDIR/home" \
  XDG_CONFIG_HOME="$TMPDIR/home/.config" \
  XDG_CACHE_HOME="$TMPDIR/home/.cache" \
  XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
  QS_PID=$!

  local i
  for i in {1..200}; do
    [[ -s $result ]] && break
    if ! kill -0 "$QS_PID" 2>/dev/null; then
      sed -n '1,160p' "$log" >&2
      fail "$name quickshell exited before writing result"
    fi
    sleep 0.1
  done

  [[ -s $result ]] || {
    sed -n '1,160p' "$log" >&2
    fail "$name test timed out"
  }

  if ! jq -e '.ok == true' "$result" >/dev/null; then
    printf '%s result:\n' "$name" >&2
    jq . "$result" >&2
    printf '%s log:\n' "$name" >&2
    sed -n '1,160p' "$log" >&2
    fail "$name test failed"
  fi

  wait "$QS_PID" 2>/dev/null || true
  QS_PID=""
}

run_fixture shell.qml bar-clicks
pass "the click cycles answer bar.clicks in shell.json"

# The fixture double-clicks the empty space once with the click on and once
# with it off, so exactly one cycle may have reached omarchy-bar.
count=$(grep -cx 'background cycle' "$CYCLE_LOG" || true)
if [[ $count != 1 ]]; then
  printf 'omarchy-bar calls (%s background cycles):\n' "$count" >&2
  cat "$CYCLE_LOG" >&2
  fail "exactly one background cycle: from the double-click with the click on alone"
fi
pass "the double-click cycles the background with the click on and stays put with it off"

run_fixture workspaces.qml workspace-presses
pass "the active workspace cycles the layout only while the click is on, and other presses still focus"
