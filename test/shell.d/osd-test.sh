#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const osd = requireFromRoot('shell/plugins/osd/OsdModel.js')

assertEqual(osd.iconFor('', 0), osd.iconFor('muted', 50), 'osd falls back to muted icon at zero percent')
assertEqual(osd.iconFor('volume-high', 1), osd.iconFor('', 100), 'osd maps high volume aliases')
assertEqual(osd.iconFor('logout', 50), '󰍃', 'osd maps logout icon')
assertEqual(osd.iconFor('custom-symbol', 50), 'custom-symbol', 'osd preserves unknown explicit icons')
assertEqual(osd.widestIcon, osd.iconFor('volume-high', 100), 'osd sizes the icon column to a glyph it can show')

assertDeepEqual(
  osd.stateForShow('volume', '', '75', '100', '', '800'),
  {
    iconKey: 'volume',
    maxValue: 100,
    hasProgress: true,
    value: 75,
    message: '75%',
    icon: osd.iconFor('volume', 75),
    duration: 800
  },
  'osd builds progress state'
)

assertDeepEqual(
  osd.stateForShow('media-pause', 'Paused', '', '100', '', 'nope'),
  {
    iconKey: 'media-pause',
    maxValue: 100,
    hasProgress: false,
    value: 0,
    message: 'Paused',
    icon: osd.iconFor('media-pause', -1),
    duration: 1200
  },
  'osd builds message state'
)
JS

# The launch-feedback OSD is serial-tagged so its close wins however the show
# and close IPC calls arrive (#16808). Extract Osd.qml's own open/close and the
# ShellIpc closeLaunch handler and run them against a bare stand-in object.
run_node_test <<'JS'
const fs = require('fs')
const osdQml = fs.readFileSync(root + '/shell/plugins/osd/Osd.qml', 'utf8')

function extract(signature) {
  const from = osdQml.indexOf(signature)
  if (from === -1) throw new Error('not found in Osd.qml: ' + signature)
  const start = osdQml.indexOf('{', from)
  let depth = 0
  for (let i = start; i < osdQml.length; i++) {
    if (osdQml[i] === '{') depth++
    else if (osdQml[i] === '}') { depth--; if (depth === 0) return osdQml.slice(start + 1, i) }
  }
  throw new Error('unbalanced braces for ' + signature)
}

// QML functions resolve properties on their component scope, so run each body
// with `with (self)` over a stand-in carrying the state the functions touch.
function bind(self, body, params = []) {
  return new Function('self', `with (self) { return function (${params.join(', ')}) {\n${body}\n} }`)(self)
}

function makeOsd() {
  const self = {
    opened: false, launch: 0, closedLaunch: 0, duration: 1200, message: '',
    hideTimer: { running: false, restart() { this.running = true }, stop() { this.running = false } },
    show(icon, msg, value, max, progressText, dur) {
      this.message = msg
      this.duration = Number(dur)
      this.opened = true
      if (this.duration > 0) this.hideTimer.restart()
      else this.hideTimer.stop()
    }
  }
  // closeLaunch lives inside the ShellIpc block, where the component is
  // `root`; open/close use the unqualified component scope. Point both at
  // the same stand-in.
  self.root = self
  self.open = bind(self, extract('function open(payloadJson)'), ['payloadJson'])
  self.close = bind(self, extract('function close()'), [])
  self.closeLaunch = bind(self, extract('function closeLaunch(serial: string): string'), ['serial'])
  return self
}

const showPayload = (launch) => JSON.stringify({ icon: 'launch', message: 'Launching Chromium…', duration: 0, launch })

// Close lands before its own show: the late show must be dropped, not open
// with duration 0 where hideTimer.stop() leaves it on screen forever.
{
  const osd = makeOsd()
  osd.closeLaunch('7')
  osd.open(showPayload(7))
  assert(!osd.opened, 'a show for an already-closed launch is dropped')
}

// Normal order: the sticky duration-0 OSD only closeLaunch takes down.
{
  const osd = makeOsd()
  osd.open(showPayload(7))
  assert(osd.opened, 'the launch show opens')
  assert(!osd.hideTimer.running, 'a duration-0 launch show never auto-hides')
  osd.closeLaunch('7')
  assert(!osd.opened, 'closeLaunch closes the launch show')
}

// A manual close also closes the launch it shows, so the in-flight show of
// that launch cannot reopen the OSD behind it.
{
  const osd = makeOsd()
  osd.open(showPayload(3))
  osd.close()
  osd.open(showPayload(3))
  assert(!osd.opened, 'a manual close drops the same launch late show')
}

// A launch-less show replaces the launch OSD on screen; the launch's
// closeLaunch must not take the replacement down with it.
{
  const osd = makeOsd()
  osd.open(showPayload(1))
  osd.open(JSON.stringify({ icon: 'volume-high', message: '50%', duration: 800 }))
  assertEqual(osd.launch, 0, 'a launch-less show clears the launch serial')
  osd.closeLaunch('1')
  assert(osd.opened, 'closeLaunch for an old launch leaves a generic OSD open')
}

// The next launch after a closed one still opens.
{
  const osd = makeOsd()
  osd.closeLaunch('1')
  osd.open(showPayload(2))
  assert(osd.opened, 'a newer launch serial still opens after a close')
}
JS
