#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/panels/monitor/Panel.qml', 'utf8')

const exited = panelSource.slice(panelSource.indexOf('onExited: function(exitCode)'))
const exitedBody = exited.slice(0, exited.indexOf('\n    }'))
const wheel = panelSource.slice(panelSource.indexOf('onWheelMoved: function(delta)'))
const wheelBody = wheel.slice(0, wheel.indexOf('\n    }'))

// External brightness writes are verified, so a rejected one has to reach the
// panel. It snaps the slider back locally: refreshing here races the read path,
// and an empty read clears brightnessAvailable and hides the slider.
assert(/root\.brightnessPercent = root\.confirmedBrightnessPercent/.test(exitedBody), 'a rejected brightness write snaps the slider back')
assert(!/refresh\(/.test(exitedBody), 'a finished brightness write never re-reads state')

// The OSD is a claim that the brightness changed, so it waits for the write to
// verify rather than appearing on the keypress.
assert(!/showBrightnessOsd/.test(wheelBody), 'the wheel does not show the OSD before the write is verified')
assert(/root\.brightnessOsdPending = false[\s\S]*root\.showBrightnessOsd/.test(exitedBody), 'a verified brightness write shows the pending OSD')
JS
