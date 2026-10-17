#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "monitor panel lazy content runtime test"
require_command quickshell
require_command python3
require_command lua5.1

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/config/monitor" "$stage/bin" "$stage/xdg"
# Keep the production popup invisible; its lazy Loader still follows open.
sed '/    open: root.opened/a\    visible: false' "$ROOT/shell/plugins/panels/monitor/Panel.qml" >"$stage/config/monitor/Panel.qml"
for file in Arrangement.qml ArrangementModel.js Model.js ScreenIdentifiers.qml; do
  ln -s "$ROOT/shell/plugins/panels/monitor/$file" "$stage/config/monitor/$file"
done
ln -s "$ROOT/shell/Ui" "$stage/config/Ui"
ln -s "$ROOT/shell/Commons" "$stage/config/Commons"
cp "$SHELL_TEST_DIR/fixtures/monitor-panel-lazy/shell.qml" "$stage/config/shell.qml"
cat >"$stage/bin/hyprctl" <<'STUB'
#!/bin/bash
exec python3 "$ARRANGEMENT_TEST_DIR/fake-hyprctl.py" "$@"
STUB
cat >"$stage/bin/omarchy-monitor-state" <<'STUB'
#!/bin/bash
printf '50\neDP-1\nDP-3\n1\n\neDP-1\n1\n'
python3 -c 'import json,os; print(json.dumps([dict(m, enabled=True, focused=m["name"]=="eDP-1") for m in json.load(open(os.environ["ARRANGEMENT_TEST_STATE"]))["monitors"]]))'
STUB
chmod +x "$stage/bin/"*
export ARRANGEMENT_TEST_DIR="$SHELL_TEST_DIR/monitor-arrangement" ARRANGEMENT_TEST_STATE="$stage/monitors.json"
export MONITOR_PANEL_SOURCE="$stage/config/monitor/Panel.qml"
export XDG_CONFIG_HOME="$stage/xdg/config" XDG_STATE_HOME="$stage/xdg/state" XDG_CACHE_HOME="$stage/xdg/cache" OMARCHY_PATH="$ROOT"
python3 "$ARRANGEMENT_TEST_DIR/fake-hyprctl.py" --control '{"reset":true}'
output=$(env QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software PATH="$stage/bin:$PATH" timeout 15 quickshell -p "$stage/config" --no-color 2>&1) || fail "lazy monitor panel fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "lazy monitor panel assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "lazy monitor panel has no QML errors" "$output"
fi
pass "monitor panel state, lazy content and closing during Apply"
