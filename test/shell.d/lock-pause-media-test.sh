#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')

// Pausing media is opt-in and only follows a secure lock transition.
const vm = require('vm')
const source = serviceQml
function bodyAfter(marker) {
  const start = source.indexOf(marker)
  if (start < 0) throw new Error('Missing ' + marker)
  const open = source.indexOf('{', start)
  let depth = 1, end = open + 1
  while (depth && end < source.length) {
    if (source[end] === '{') depth++
    if (source[end] === '}') depth--
    end++
  }
  return source.slice(open + 1, end - 1)
}
const pauseBody = bodyAfter('function pauseMedia()')
const secureBody = bodyAfter('onSecureStateChanged:')
let pauses = []
const player = (name, isPlaying = true, canPause = true) => ({
  isPlaying, canPause, pause() { pauses.push(name) }
})
const context = {
  shell: null,
  Mpris: { players: { values: [] } },
  secure: true,
  sessionLockStabilizeTimer: { stop() {} },
  pendingSessionLockTimer: { stop() {} },
  root: { logEvent() {}, startFingerprint() {} }
}
vm.createContext(context)
context.root.pauseMedia = () => vm.runInContext('(function() {' + pauseBody + '})()', context)
const secureChanged = () => vm.runInContext(secureBody, context)

context.Mpris.players.values = [player('music'), player('video'), player('paused', false), player('unsupported', true, false)]
for (const config of [null, {}, { lock: {} }, { lock: { pauseMedia: false } }, { lock: { pauseMedia: 'true' } }]) {
  context.shell = config === null ? null : { shellConfig: config }
  secureChanged()
}
assertEqual(pauses.length, 0, 'media is untouched unless explicitly enabled')
context.shell = { shellConfig: { lock: { pauseMedia: true } } }
secureChanged()
assertEqual(JSON.stringify(pauses), JSON.stringify(['music', 'video']), 'secure lock pauses all playing players that support pause')
context.secure = false
secureChanged()
assertEqual(pauses.length, 2, 'unlock does not send a media command')
context.secure = true
context.Mpris.players.values = []
secureChanged()
assertEqual(pauses.length, 2, 'locking without players succeeds')
context.Mpris.players = null
secureChanged()
assertEqual(pauses.length, 2, 'locking before the media list is available succeeds')
JS
