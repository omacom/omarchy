#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar startup test"
  exit 0
fi

ulimit -c 0 2>/dev/null || true

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
config="$work/config"
mkdir -p "$config"
ln -s "$ROOT/shell/services" "$config/services"
ln -s "$ROOT/shell/Commons" "$config/Commons"

python3 - "$ROOT/shell/shell.qml" "$config/shell.qml" <<'PY'
import sys

source, target = sys.argv[1], sys.argv[2]
text = open(source).read()
text = text[:text.index("  // ------------------------------------------------------------- services\n")]
for old, new in [
    ('import "plugins/bar"\n', ''),
    ('  property BarWidgetRegistry barWidgetRegistry: BarWidgetRegistry { }\n'
     '  property AppLibrary appLibrary: AppLibrary { }\n'
     '  property BrightnessKeys brightnessKeys: BrightnessKeys { host: shell }\n'
     '  property BackgroundIntro bootIntro: BackgroundIntro { host: shell }\n', ''),
    ('    Bar {\n      omarchyPath: shell.omarchyPath\n      barWidgetRegistry: shell.barWidgetRegistry\n'
     '      barConfig: shell.barConfig\n      shell: shell\n      manifest: shell.barManifestFor(shell.defaultBarId)\n    }\n',
     '    StockBarProbe { }\n'),
]:
    assert text.count(old) == 1, old
    text = text.replace(old, new)
text += '''
  function _syncServices() {}
  Connections {
    target: userConfigFile
    function onLoaded() { console.log("PROBE shell.json loaded, bar.id=" + shell.selectedBarId) }
  }
  Connections {
    target: shell.pluginRegistry
    function onScanFinished() { console.log("PROBE plugin scan finished, active bar=" + shell.activeBarId) }
  }
  Timer { interval: 2000; running: true; onTriggered: Qt.quit() }
}
'''
open(target, "w").write(text)
PY

cat >"$config/StockBarProbe.qml" <<'QML'
import QtQuick

Item {
  id: root
  function pluginBarApiFor(pluginId) { return pluginId }
  Item {
    id: slot
    function injectProps() { root.pluginBarApiFor("probe") }
  }
  Component.onCompleted: {
    console.log("PROBE stock bar constructed")
    Qt.callLater(slot.injectProps)
  }
  Component.onDestruction: console.log("PROBE stock bar destroyed")
}
QML

run_case() {
  local name="$1" configured_bar="$2" plugin_state="$3"
  local home="$work/$name/home" runtime="$work/$name/run" output

  mkdir -p "$home/.config/omarchy" "$runtime"
  chmod 700 "$runtime"
  cat >"$home/.config/omarchy/shell.json" <<JSON
{ "version": 1, "bar": { "id": "$configured_bar", "layout": { "left": [], "center": [], "right": [] } }, "plugins": [] }
JSON

  if [[ $plugin_state != "absent" ]]; then
    mkdir -p "$home/.config/omarchy/plugins/tester.bar"
    cat >"$home/.config/omarchy/plugins/tester.bar/manifest.json" <<'JSON'
{ "schemaVersion": 1, "id": "tester.bar", "name": "Tester Bar", "version": "1.0.0", "kinds": ["bar"], "entryPoints": { "bar": "Bar.qml" } }
JSON
    if [[ $plugin_state == "valid" ]]; then
      cat >"$home/.config/omarchy/plugins/tester.bar/Bar.qml" <<'QML'
import QtQuick
Item { Component.onCompleted: console.log("PROBE replacement bar constructed") }
QML
    else
      cat >"$home/.config/omarchy/plugins/tester.bar/Bar.qml" <<'QML'
import QtQuick
Item { this is not valid QML }
QML
    fi
  fi

  output=$(env -i PATH="$PATH" LANG=C.UTF-8 HOME="$home" XDG_CONFIG_HOME="$home/.config" \
    XDG_CACHE_HOME="$home/.cache" XDG_STATE_HOME="$home/.local/state" XDG_DATA_HOME="$home/.local/share" \
    XDG_RUNTIME_DIR="$runtime" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen \
    timeout 30 quickshell -p "$config" --no-color 2>&1) || fail "$name fixture exits cleanly" "$output"
  printf '%s' "$output"
}

assert_count() {
  local output="$1" pattern="$2" expected="$3" description="$4" actual
  actual=$(grep -cF "$pattern" <<<"$output" || true)
  (( actual == expected )) || fail "$description" "expected $expected, got $actual"
}

output=$(run_case replacement-present tester.bar valid)
assert_count "$output" "PROBE stock bar constructed" 0 "a present replacement does not construct the stock bar"
assert_count "$output" "PROBE replacement bar constructed" 1 "a present replacement bar is constructed once"
pass "a present replacement starts without constructing the stock bar"

output=$(run_case stock-configured omarchy.bar absent)
assert_count "$output" "PROBE stock bar constructed" 1 "the configured stock bar is constructed once"
pass "the configured stock bar starts once"

output=$(run_case replacement-missing tester.bar absent)
assert_count "$output" "PROBE stock bar constructed" 1 "a missing replacement falls back to the stock bar once"
pass "a missing replacement falls back to the stock bar"

output=$(run_case replacement-failed tester.bar invalid)
assert_count "$output" "PROBE stock bar constructed" 1 "a failed replacement falls back to the stock bar once"
pass "a failed replacement falls back to the stock bar"
