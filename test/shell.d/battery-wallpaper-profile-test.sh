#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command quickshell
require_command python3
require_command timeout

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
fixture="$SHELL_TEST_DIR/fixtures/battery-wallpaper-profile"
mkdir -p "$stage/battery" "$stage/background" "$stage/Ui" "$stage/Commons" "$stage/bin" "$stage/home" "$stage/runtime"
chmod 700 "$stage/runtime"
cp -r "$fixture/mocks" "$stage/mocks"
cp "$fixture/shell.qml" "$stage/shell.qml"
cp "$ROOT/shell/plugins/services/battery/BatteryModel.js" "$stage/battery/"
cp "$ROOT/shell/Ui/BackgroundMedia.qml" "$ROOT/shell/Ui/ScreenMoveRemap.qml" "$stage/Ui/"
cp "$ROOT/shell/Commons/Util.qml" "$stage/Commons/"
printf 'singleton Util 1.0 Util.qml\n' >"$stage/Commons/qmldir"

# Run the production components, changing only their external boundaries in
# disposable copies. Preserve the profile, source, visibility and play/pause
# bindings and handlers: they are the behavior this fixture must exercise.
python3 - "$ROOT" "$stage" <<'PY'
from pathlib import Path
import sys
root, stage = map(Path, sys.argv[1:])

def replace(source, before, after):
  assert before in source, f"fixture boundary not found: {before}"
  return source.replace(before, after)

source = (root / 'shell/plugins/services/battery/Service.qml').read_text()
source = replace(source, 'import "BatteryModel.js"', 'import "../mocks"\nimport "BatteryModel.js"')
source = replace(source, 'UPower.', 'UPowerMock.')
source = replace(source, 'target: UPower', 'target: UPowerMock')
source = replace(source, 'PowerProfiles.profile', 'PowerProfilesMock.profile')
(stage / 'battery/Service.qml').write_text(source)

source = (root / 'shell/plugins/background/Background.qml').read_text()
source = replace(source, 'import Quickshell.Hyprland\n', '')
source = replace(source, 'import Quickshell.Wayland\n', '')
source = replace(source, 'import qs.Ui', 'import qs.Ui\nimport "../mocks"')
source = replace(source, '  id: root', '  id: root\n  property var testMedia: null')
source = replace(source, 'Quickshell.screens', 'DisplayMock.screens')
source = replace(source, 'Hyprland.monitorFor', 'DisplayMock.monitorFor')
source = replace(source, 'PanelWindow {', 'MockPanelWindow {\n      Component.onCompleted: root.testMedia = base')
source = replace(source, '      anchors { top: true; bottom: true; left: true; right: true }', '      width: 64; height: 64')
for line in ['      WlrLayershell.namespace: "omarchy-background"',
             '      WlrLayershell.layer: WlrLayer.Background',
             '      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None',
             '      exclusionMode: ExclusionMode.Ignore']:
  source = replace(source, line, '')
(stage / 'background/Background.qml').write_text(source)

source = (root / 'shell/Ui/BackgroundVideo.qml').read_text()
source = replace(source, 'import QtMultimedia', 'import QtMultimedia\nimport "../mocks"')
source = replace(source, '  id: root', '  id: root\n  property alias testPlayer: player')
for native in ['VideoOutput', 'AudioOutput', 'MediaPlayer']:
  source = replace(source, native + ' {', 'Mock' + native + ' {')
(stage / 'Ui/BackgroundVideo.qml').write_text(source)
PY

# Source transitions may request the user's configured profile. Intercept that
# process too, so only the fixture's explicit native profile changes take effect.
printf '#!/bin/bash\nexit 0\n' >"$stage/bin/omarchy-powerprofiles-set"
chmod +x "$stage/bin/omarchy-powerprofiles-set"

ulimit -c 0
output=$(env -u WAYLAND_DISPLAY -u DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE \
  HOME="$stage/home" XDG_RUNTIME_DIR="$stage/runtime" OMARCHY_PATH="$ROOT" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=$stage/no-session-bus" DBUS_SYSTEM_BUS_ADDRESS="unix:path=$stage/no-system-bus" \
  PATH="$stage/bin:$PATH" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=basic QT_QUICK_BACKEND=software \
  timeout 20 quickshell -p "$stage" --no-color 2>&1) || fail "battery wallpaper QML fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "native profile/source transitions reach wallpaper playback" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "battery wallpaper fixture has no QML errors" "$output"
fi
pass "native profile and AC/battery transitions pause and resume the real wallpaper bindings offscreen"
