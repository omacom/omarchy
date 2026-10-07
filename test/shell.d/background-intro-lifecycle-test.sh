#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
# Exercise the actual service and IPC bodies without requiring a compositor.
run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const service = fs.readFileSync(path.join(root, 'shell/services/BackgroundIntro.qml'), 'utf8')
const ipc = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const loads = []
const timer = () => ({ running: false, stop() { this.running = false }, restart() { this.running = true } })
const state = {
  framePoll: timer(), themeFade: timer(), themeFallback: timer(), startupFade: timer(),
  themeToken: '', transitionToken: '', themeBackground: '', themeColors: '', themeShell: '',
  themeNativeSize: null, themeOpacity: 1, backgroundService: null, cover: false, startupPending: false,
  Color: { loadColors: value => loads.push(['colors', value]), loadShell: value => loads.push(['shell', value]) },
  Style: { scheduleRefresh: () => loads.push(['refresh']) },
  Util: { decodeBase64: value => value }
}
vm.createContext(state)
for (const name of ['prepareTheme', 'cancelTheme', 'revealTheme', 'finishTheme', 'themeStatus']) {
  const method = service.match(new RegExp('  function ' + name + '\\([^]*?\\n  }'))
  assert(method, 'service exposes ' + name)
  vm.runInContext(method[0], state)
}
const cancel = ipc.match(/    function cancelThemeIntro\(token: string\): void {([^]*?)\n    }/)
assert(cancel, 'shell exposes cancellation IPC')
state.shell = { bootIntro: state }
vm.runInContext('function cancelThemeIntro(token) {' + cancel[1] + '\n}', state)
state.prepareTheme('old-video-frame', 'failed', '', '')
state.framePoll.running = true
state.cancelThemeIntro('failed')
assertEqual(state.themeBackground, '', 'cancel removes the prepared still so the active background is visible')
assertEqual(state.themeToken, '', 'cancel clears the prepared token')
assertEqual(state.transitionToken, '', 'cancel clears pending transition status')
assert(!state.framePoll.running && !state.themeFallback.running && !state.themeFade.running, 'cancel stops polling, fallback, and fade')
state.finishTheme('failed')
state.revealTheme() // A queued fallback cannot apply cleared payloads.
assertDeepEqual(loads, [], 'failure cleanup and late callbacks never change active colors or shell overrides')
state.prepareTheme('new-cover', 'retry', 'new-colors', 'new-shell')
for (const token of ['failed', '', 'unknown']) state.cancelThemeIntro(token)
assertEqual(state.themeToken, 'retry', 'stale and empty cancellation tokens preserve the new activation')
assertEqual(state.themeBackground, 'new-cover', 'stale cancellation retains the new cover')
assert(state.themeFallback.running, 'stale cancellation retains the new fallback timer')
assertDeepEqual(loads, [], 'stale cancellation does not apply the newer palette early')
state.finishTheme('retry')
assertDeepEqual(loads, [['colors', 'new-colors'], ['shell', 'new-shell'], ['refresh']], 'a successful retry applies its own palette')
state.cancelThemeIntro('retry')
assert(state.themeFade.running, 'cancellation after reveal does not interrupt the successful fade')
pass('prepared intro cancellation preserves the active palette and rejects stale tokens')
JS

require_compositor "background intro lifecycle test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin" "$stage/home"
printf 'P6\n1 1\n255\n\377\377\377' >"$stage/cover.ppm"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
printf 'intro\n' >>"$INTRO_TEST_LOG"
sleep 2
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"
cat >"$stage/bin/owe" <<'SH'
#!/bin/bash
if [[ -f $INTRO_TEST_FRAME_READY ]]; then
  sleep 0.25
  printf '{"kind":"video","ready":true,"has_transition":false,"time_pos":0.05}\n'
else
  printf '{"kind":"video","ready":true,"has_transition":true,"time_pos":0}\n'
fi
SH
chmod +x "$stage/bin/owe"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" INTRO_TEST_LOG="$stage/starts" INTRO_TEST_COVER="$stage/cover.ppm" INTRO_TEST_FRAME_READY="$stage/video-ready" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "background intro fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "background intro lifecycle assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background intro fixture has no QML errors" "$output"
fi
[[ $(wc -l <"$stage/starts") == 1 ]] || fail "recreating the background service does not run another launcher"
pass "the cover stays while waiting and remains off when OWE recreates the background service"
