#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The plugin's JS modules, plus Service.qml's admission, close and replay
# functions run against a fake ListModel and fake senders.
require_command node

if output=$(node "$SHELL_TEST_DIR/notifications/logic.cjs" 2>&1); then
  pass "notification logic holds its policies"
else
  fail "notification logic holds its policies" "$output"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

service="$ROOT/shell/plugins/notifications/Service.qml"

# The startup step that makes the state directory, run as the service runs
# it, on a scratch HOME. It must keep the current files, replace a symlinked
# one rather than write through it, and leave the directory and the files the
# shell writes private.
prepare=$(node -e '
  const source = require("node:fs").readFileSync(process.argv[1], "utf8")
  const m = source.match(/id: storePrepare\s+command: \["bash", "-c",([^]*?),\s*"omarchy-notifications-state"/)
  process.stdout.write(require("node:vm").runInNewContext(m[1]))
' "$service")
state="$tmp/.local/state/omarchy/notifications"
mkdir -p "$state" "$tmp/outside"
touch "$tmp/outside/keep.json"
echo '[{"key":"n2"}]' >"$state/history.json"
chmod 644 "$state/history.json"
ln -s "$tmp/outside/keep.json" "$state/quiet.json"
bash -c "$prepare" omarchy-notifications-state "$state" || fail "the state directory is prepared"
left=$(cd "$state" && find . | sort | tr '\n' ' ')
[[ $left == ". ./history.json ./live.json ./quiet.json " ]] || fail "the state files are made" "$left"
[[ -f $tmp/outside/keep.json && $(cat "$state/history.json") == '[{"key":"n2"}]' && ! -L $state/quiet.json && ! -s $state/quiet.json ]] ||
  fail "current state is kept and a symlinked state file replaced"
[[ $(stat -c %a "$state" "$state/live.json" "$state/history.json" "$state/quiet.json" | tr '\n' ' ') == "700 600 600 600 " ]] ||
  fail "the state directory and its files are private"
pass "the state directory is prepared"

# 4.0's leftovers go by migration: everything it kept, never through a
# symlink, and its Do Not Disturb carried into quiet.json.
migration=$(grep -l "the 4.0 notification engine left behind" "$ROOT"/migrations/*.sh)
old="$tmp/old"
state="$old/.local/state/omarchy/notifications"
mkdir -p "$state/history" "$state/images" "$old/outside"
touch "$state/history/1-n1.json" "$state/1776000000000-7.json" "$old/outside/keep.json" "$old/outside/1-2.json"
echo '[{"key":"n2"}]' >"$state/history.json"
: >"$state/quiet.json"
echo '{"version":3,"dnd":true}' >"$old/.local/state/omarchy/notifications.json"
ln -s "$old/outside" "$state/1-linked.json"
ln -s "$old/outside" "$state/images/outside"
for run in first again; do
  HOME="$old" bash -euo pipefail "$migration" >/dev/null || fail "the leftover migration runs ($run)"
done
left=$(cd "$state" && find . | sort | tr '\n' ' ')
[[ $left == ". ./1-linked.json ./history.json ./quiet.json " ]] ||
  fail "4.0's leftovers are cleared and nothing else" "$left"
[[ -f $old/outside/keep.json && -f $old/outside/1-2.json ]] ||
  fail "leftover cleanup never reaches through a symlink"
[[ $(jq -c '[.dnd, .codesBypassQuiet]' "$state/quiet.json") == "[true,true]" && ! -e $old/.local/state/omarchy/notifications.json ]] ||
  fail "4.0's Do Not Disturb carries over" "$(cat "$state/quiet.json")"
pass "a migration clears 4.0's leftovers and carries its Do Not Disturb"

# Keybindings and commands call the notifications IPC target by method name.
# Every name they use must be one the service declares, or the key fires into
# "target not found".
declared=$(sed -n '/target: "notifications"/,/^  }/p' "$service" | grep -oE '^    function [A-Za-z]+' | awk '{print $2}' | sort -u)
used=$(
  {
    sed -nE 's/^ipc notifications\.([A-Za-z]+)$/\1/p' "$ROOT/default/omarchy/shortcuts"
    grep -rhoE 'ipc = "notifications\.[A-Za-z]+"' "$ROOT/default/hypr" | sed -E 's/.*notifications\.([A-Za-z]+)"/\1/'
    grep -rhoE 'omarchy-shell( -q)? notifications [A-Za-z]+' "$ROOT/bin" "$ROOT/install" "$ROOT/migrations" | awk '{print $NF}'
  } | sort -u
)
missing=$(comm -13 <(echo "$declared") <(echo "$used"))
[[ -z $missing ]] || fail "every notifications IPC method callers use is declared" "missing: $missing"
pass "every notifications IPC method callers use is declared"

# The surface keeps the namespace the glassy-window layer rule matches.
grep -q 'WlrLayershell.namespace: "omarchy-notifications"' "$service" ||
  fail "notification surface keeps the omarchy-notifications layer namespace"
grep -q 'omarchy-notifications' "$ROOT/default/hypr/toggles/window-glassy.lua" ||
  fail "glassy toggle still matches the notification layer namespace"
pass "notification surface keeps the omarchy-notifications layer namespace"

# Font commands run with isolated config and IPC; do not affect later checks.
(
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  # Stub the shell IPC: commit() refreshes the running shell, which does not
  # exist under test. Record calls and succeed silently.
  printf '%s\n' '#!/bin/bash' 'echo "$@" >>"$OMARCHY_TEST_SHELL_ARGS"' 'exit 0' >"$tmpdir/omarchy-shell"
  chmod +x "$tmpdir/omarchy-shell"
  touch "$tmpdir/shell-args"

  export OMARCHY_TEST_SHELL_ARGS="$tmpdir/shell-args"

  # Isolate shell.json writes: omarchy-shell-config resolves the user config
  # from $HOME, so point HOME at the scratch dir.
  export HOME="$tmpdir"
  export OMARCHY_PATH="$ROOT"
  export PATH="$tmpdir:$ROOT/bin:$PATH"

  font() {
    omarchy-notification-font "$@"
  }

  mode() {
    jq -r '.notifications.font // "default"' "$HOME/.config/omarchy/shell.json"
  }

  # ------------------------------------------------------------------ CLI

  out=$(font show)
  [[ $out == *"mode: default"* ]] || fail "notification font show defaults to default mode" "$out"
  [[ $out == *"Liberation Sans"* ]] || fail "notification font show resolves the default family" "$out"
  pass "notification font show defaults to default mode"

  font default >/dev/null
  [[ $(mode) == "default" ]] || fail "notification font default persists default mode"
  pass "notification font default persists default mode"

  font system >/dev/null
  [[ $(mode) == "system" ]] || fail "notification font system persists system mode"
  pass "notification font system persists system mode"

  out=$(font show)
  [[ $out == *"mode: system"* ]] || fail "notification font show reports system mode" "$out"
  pass "notification font show reports system mode"

  mapfile -t installed_families < <(fc-list -f '%{family[0]}\n' | sort -u)
  custom_family=${installed_families[0]}
  [[ -n $custom_family ]] || fail "custom font test needs an installed family"
  font set "$custom_family" >/dev/null
  [[ $(mode) == "$custom_family" ]] || fail "notification font set persists a custom family"
  pass "notification font set persists a custom family"

  if font set "No Such Font XYZ-123" >"$tmpdir/font-error" 2>&1; then
    fail "notification font set rejects unknown families"
  fi
  [[ $(mode) == "$custom_family" ]] || fail "notification font set leaves the stored mode alone on rejection"
  pass "notification font set rejects unknown families"
  grep -Fq "Font 'No Such Font XYZ-123' not found." "$tmpdir/font-error" || fail "unknown family has an explanatory error"
  pass "unknown family has an explanatory error"

  # Fixed font database catches partial-family, style and empty-string matches
  # independently of whichever font packages the test machine has installed.
  cat >"$tmpdir/fc-list" <<'FONTS'
#!/bin/bash
printf '%s\n' 'Fixture Sans,Fixture Sans Alias' 'Fixture Mono'
FONTS
  chmod +x "$tmpdir/fc-list"
  for invalid_family in "" "Fixture" "Regular"; do
    if font set "$invalid_family" >"$tmpdir/font-error" 2>&1; then
      fail "reject empty, partial and style names" "$invalid_family"
    fi
    [[ $(mode) == "$custom_family" ]] || fail "invalid family must preserve config"
  done
  pass "empty, partial and style names are rejected without changing config"
  font set "fixture sans alias" >/dev/null
  [[ $(mode) == "fixture sans alias" ]] || fail "full aliases are accepted case-insensitively"
  pass "full aliases are accepted case-insensitively"
  font list | grep -Fx 'Fixture Sans' >/dev/null || fail "proportional families appear in the list"
  pass "proportional families appear in the list"
  rm "$tmpdir/fc-list"

  if font bogus 2>/dev/null; then
    fail "notification font rejects unknown subcommands"
  fi
  pass "notification font rejects unknown subcommands"

  [[ -n $(font list) ]] || fail "notification font list prints families"
  pass "notification font list prints families"
)

# Exercise live QML precedence using the production font bindings.
(
  require_command quickshell
  test_tmp=$(mktemp -d)
  trap 'rm -rf "$test_tmp"' EXIT
  export FONT_TEST_STAGE="$test_tmp"
  export HOME="$test_tmp"
  ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"
  # Compile the production bindings in a small host, without starting another
  # notification server. Test actual QML reactivity and render the resolved font.
  node <<'JS'
const fs = require('fs')
const source = fs.readFileSync(process.env.ROOT + '/shell/plugins/notifications/Service.qml', 'utf8')
const start = source.indexOf('  readonly property string notificationFontSetting:')
const end = source.indexOf('\n  // ------------------------------------------------------------- displays', start)
if (start < 0 || end < 0) throw Error('missing font bindings')
fs.writeFileSync(process.env.FONT_TEST_STAGE + '/shell.qml', `
import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
ShellRoot {
  id: service
  property var shell: ({ shellConfig: {}, bar: { fontFamily: "monospace" } })
${source.slice(start, end)}
  FloatingWindow {
    width: 480; height: 160; visible: true
    color: "#202030"
    Text { anchors.centerIn: parent; text: "Notification theme font\\nSummary and body preview"; color: "white"; font.pixelSize: 22; font.family: service.notificationTextFontFamily }
  }
  function check(expected) {
    if (notificationTextFontFamily !== expected) throw Error("font: " + notificationTextFontFamily + " expected " + expected)
  }
  Component.onCompleted: Qt.callLater(function() {
    check("Liberation Sans")
    Commons.Color.shellValues = ({ "notifications.font-family": "serif" })
    check("serif")
    shell = ({ shellConfig: { notifications: { font: "sans-serif" } }, bar: { fontFamily: "monospace" } })
    check("sans-serif")
    Commons.Color.shellValues = ({ "notifications.font-family": "monospace" })
    check("sans-serif")
    shell = ({ shellConfig: { notifications: { font: "default" } } })
    check("monospace")
    shell = ({ shellConfig: { notifications: { font: "system" } }, bar: { fontFamily: "serif" } })
    check("serif")
    console.log("RESULT pass")
    if (Quickshell.env("FONT_TEST_VISUAL") !== "1") Qt.quit()
  })
}
`)
JS
  if [[ ${FONT_TEST_VISUAL:-0} == 1 ]]; then
    quickshell -p "$test_tmp" --no-color
  else
    output=$(QT_QPA_PLATFORM=offscreen timeout 15 quickshell -p "$test_tmp" --no-color 2>&1)
    [[ $output == *"RESULT pass"* ]] || fail "notification font precedence reacts live" "$output"
    pass "notification theme default and user overrides react live"
  fi
)
