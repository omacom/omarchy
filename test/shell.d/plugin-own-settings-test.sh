#!/bin/bash
# omarchy:exclusive - starts the full shell, as runtime-smoke-test.sh does

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "plugin own settings test"
require_command jq

setup_scratch_shell
test_home=$SCRATCH_HOME
log=$SCRATCH_LOG

# A third-party plugin that stores a setting on its own bar entry, then reports
# what its scoped barConfig says about that entry.
plugin_id="acme.own-settings"
plugin_dir="$test_home/.config/omarchy/plugins/$plugin_id"
mkdir -p "$plugin_dir"
cat >"$plugin_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$plugin_id",
  "name": "Own Settings",
  "version": "1.0.0",
  "author": "Acme",
  "description": "Writes its own setting",
  "kinds": ["service", "bar-widget"],
  "entryPoints": { "service": "Service.qml", "barWidget": "BarWidget.qml" },
  "barWidget": { "displayName": "Own Settings", "description": "Own settings", "category": "Test", "allowMultiple": false }
}
JSON
cat >"$plugin_dir/BarWidget.qml" <<'QML'
import QtQuick
Item { implicitWidth: 1; implicitHeight: 1 }
QML
cat >"$plugin_dir/Service.qml" <<QML
import QtQuick

Item {
  id: root
  property var shell: null

  function storedValue() {
    var layout = root.shell && root.shell.barConfig && root.shell.barConfig.layout
    var right = (layout && layout.right) || []
    for (var i = 0; i < right.length; i++)
      if (right[i] && right[i].id === "$plugin_id") return String(right[i].value)
    return "missing"
  }

  onShellChanged: if (shell && !write.ran) write.start()

  // Read back as soon as the write returns: a later shellConfig reassignment
  // would deliver it anyway and hide a write published one behind.
  Timer {
    id: write
    property bool ran: false
    interval: 500
    onTriggered: {
      ran = true
      root.shell.updateEntryInline("$plugin_id", { value: "written" })
      console.log("own-settings-result=" + root.storedValue())
    }
  }
}
QML

cat >"$test_home/.config/omarchy/shell.json" <<JSON
{
  "version": 1,
  "bar": { "layout": { "left": [], "center": [], "right": [{ "id": "$plugin_id", "value": "initial" }] } },
  "plugins": []
}
JSON

start_scratch_shell

result=""
for _ in {1..150}; do
  result=$(grep -o 'own-settings-result=[a-z]*' "$log" | tail -1 || true)
  [[ -n $result ]] && break
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    sed -n '1,240p' "$log" >&2
    fail "test shell exited before the plugin reported its settings"
  fi
  sleep 0.1
done

[[ -n $result ]] || {
  sed -n '1,240p' "$log" >&2
  fail "plugin reported its settings before the timeout"
}

written_to_disk() {
  jq -e --arg id "$plugin_id" '.bar.layout.right[] | select(.id == $id) | .value == "written"' \
    "$test_home/.config/omarchy/shell.json" >/dev/null 2>&1
}

for _ in {1..50}; do
  written_to_disk && break
  sleep 0.1
done
written_to_disk ||
  fail "plugin settings write reaches shell.json" "$(cat "$test_home/.config/omarchy/shell.json")"

[[ $result == "own-settings-result=written" ]] ||
  fail "plugin receives its own settings write in barConfig" "$result"
pass "plugin receives its own settings write in barConfig"
