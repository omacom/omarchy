#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_quickshell "background video handoff test"

# A video replacing a video: OWE holds the desktop throughout, so the shell's
# background never turns ready. The cover must stay while OWE still shows the
# outgoing video, and open once it shows the new one, paused on frame zero.
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
printf 'P6\n1 1\n255\n\377\377\377' >"$stage/cover.ppm"
printf '{"path":"/media/old.mp4","kind":"video","ready":true,"has_transition":false,"time_pos":4.2}\n' >"$stage/shown"
printf '{"path":"/media/new.mp4","kind":"video","ready":true,"has_transition":false,"time_pos":0}\n' >"$stage/new"
printf '#!/bin/bash\ncat "$VIDEO_TEST_DIR/shown"\n' >"$stage/bin/owe"
printf '#!/bin/bash\necho %s\n' "'{\"bool\":true}'" >"$stage/bin/hyprctl"
chmod +x "$stage/bin/"*

cat >"$stage/shell.qml" <<'QML'
import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: test
  property var services: ({})
  readonly property string dir: Quickshell.env("VIDEO_TEST_DIR")
  function firstPartyServiceFor(id) { return services[id] || null }

  QtObject { id: background; property bool suspended: true; property bool ready: true }
  BackgroundIntro { id: intro; host: test }
  Process { id: showNew; command: ["cp", test.dir + "/new", test.dir + "/shown"] }

  Timer { interval: 100; running: true; onTriggered: {
    test.services = ({ "omarchy.background": background })
    intro.prepareTheme(test.dir + "/cover.ppm", "switch", "", "")
    intro.finishTheme("switch", true, "/media/new.mp4")
    held.start()
  } }
  Timer { id: held; interval: 500; onTriggered: {
    console.log("HELD " + (intro.themeToken === "switch"))
    showNew.running = true
    opened.start()
  } }
  Timer { id: opened; interval: 600; onTriggered: {
    console.log("OPENED " + (intro.themeToken === ""))
    Qt.quit()
  } }
}
QML

output=$(PATH="$stage/bin:$PATH" HOME="$stage" VIDEO_TEST_DIR="$stage" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "video handoff fixture exits cleanly" "$output"
if rg -q 'ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "video handoff fixture has no QML errors" "$output"
fi
[[ $output == *"HELD true"* ]] || fail "the cover stays while OWE still shows the outgoing video" "$output"
[[ $output == *"OPENED true"* ]] || fail "the cover opens once OWE shows the new video, paused on its first frame" "$output"
pass "a video-to-video switch lifts its cover once OWE shows the new video"
