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
  framePoll: timer(), themeFade: timer(), themeCutReveal: timer(), themeFallback: timer(), startupFade: timer(),
  themeToken: '', transitionToken: '', themeBackground: '', themeColors: '', themeShell: '',
  themePaletteReady: false, themeNativeSize: null, themeOpacity: 1, backgroundService: null, backgroundReady: true, cover: false, startupPending: false,
  Commons: { Color: { loadColors: value => loads.push(['colors', value]), loadShell: value => loads.push(['shell', value]) } },
  Style: { scheduleRefresh: () => loads.push(['refresh']) },
  Util: { decodeBase64: value => value }
}
vm.createContext(state)
for (const name of ['prepareThemeCover', 'prepareTheme', 'cancelTheme', 'revealTheme', 'finishTheme', 'themeStatus']) {
  const method = service.match(new RegExp('  function ' + name + '\\([^]*?\\n  }'))
  assert(method, 'service exposes ' + name)
  vm.runInContext(method[0], state)
}
const cancel = ipc.match(/    function cancelThemeIntro\(token: string\): void {([^]*?)\n    }/)
assert(cancel, 'shell exposes cancellation IPC')
state.shell = { bootIntro: state }
vm.runInContext('function cancelThemeIntro(token) {' + cancel[1] + '\n}', state)
const prepareCover = ipc.match(/    function prepareThemeIntroCover\(fromPath: string, token: string\): void {([^]*?)\n    }/)
assert(prepareCover, 'shell exposes cover-only preparation IPC')
vm.runInContext('function prepareThemeIntroCover(fromPath, token) {' + prepareCover[1] + '\n}', state)
state.prepareThemeIntroCover('old-video-frame', 'failed')
state.framePoll.running = true
state.cancelThemeIntro('failed')
assertEqual(state.themeBackground, '', 'cancel removes the prepared still so the active background is visible')
assertEqual(state.themeToken, '', 'cancel clears the prepared token')
assertEqual(state.transitionToken, '', 'cancel clears pending transition status')
assert(!state.framePoll.running && !state.themeFallback.running && !state.themeFade.running, 'cancel stops polling, fallback, and fade')
state.finishTheme('failed')
state.revealTheme() // A queued fallback cannot apply cleared payloads.
assertDeepEqual(loads, [], 'failure cleanup and late callbacks never change active colors or shell overrides')
// Simulate the ten-second fallback firing before a slow renderer/publication
// returns. Both late failure and successful retry must retain their semantics.
state.prepareThemeIntroCover('slow-cover', 'slow-failure')
state.revealTheme()
assertDeepEqual(loads, [], 'prepublication fallback preserves active colors, muted color, and shell overrides')
assertEqual(state.themeBackground, '', 'prepublication fallback releases the still over the active background')
assert(!state.themeFallback.running && !state.themeFade.running, 'prepublication fallback fully cancels the cover')
state.cancelThemeIntro('slow-failure')
state.finishTheme('slow-failure')
assertDeepEqual(loads, [], 'late failure after fallback cannot apply a palette')
state.prepareThemeIntroCover('retry-cover', 'retry')
state.revealTheme()
assertDeepEqual(loads, [], 'a slow successful activation also waits for publication before applying a palette')
state.prepareTheme('new-cover', 'retry', 'new-colors', 'new-shell')
for (const token of ['failed', '', 'unknown']) state.cancelThemeIntro(token)
assertEqual(state.themeToken, 'retry', 'stale and empty cancellation tokens preserve the new activation')
assertEqual(state.themeBackground, 'new-cover', 'stale cancellation retains the new cover')
assert(state.themeFallback.running, 'stale cancellation retains the new fallback timer')
assertDeepEqual(loads, [], 'stale cancellation does not apply the newer palette early')
state.finishTheme('retry')
assertDeepEqual(loads, [['colors', 'new-colors'], ['shell', 'new-shell'], ['refresh']], 'a successful retry applies its own palette')
state.cancelThemeIntro('retry')
assertEqual(state.revealDelayFrames, 2, 'cancellation after reveal does not interrupt the scheduled fade')
state.prepareTheme('manual-cover', 'manual', '', '')
state.finishTheme('manual')
assertDeepEqual(loads, [['colors', 'new-colors'], ['shell', 'new-shell'], ['refresh']], 'a background-only handoff preserves the active palette')
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
if [[ -n ${INTRO_TEST_POLLS:-} ]]; then
  if [[ -f $INTRO_TEST_MARK ]]; then
    printf 'released\n' >>"$INTRO_TEST_POLLS"
  else
    printf 'covered\n' >>"$INTRO_TEST_POLLS"
  fi
  printf '{"kind":"still","ready":true,"has_transition":false,"time_pos":-1}\n'
elif [[ -f $INTRO_TEST_FRAME_READY ]]; then
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

# A login whose intro ends on a still never reports a video frame, so the
# frame poll has to stop once the cover is released.
cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/still-handoff.qml" "$stage/shell.qml"
touch "$stage/polls"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" INTRO_TEST_LOG="$stage/starts" INTRO_TEST_POLLS="$stage/polls" INTRO_TEST_MARK="$stage/mark" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "still intro fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "still intro assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "still intro fixture has no QML errors" "$output"
fi
[[ -f $stage/mark ]] || fail "the still intro fixture marks the cover release"
covered=$(grep -c '^covered$' "$stage/polls" || true)
released=$(grep -c '^released$' "$stage/polls" || true)
(( covered >= 10 )) || fail "the frame poll runs while the intro covers the background ($covered owe render-status runs)"
(( released <= 1 )) || fail "the frame poll stops once nothing waits for the intro ($released owe render-status runs in the second after the cover was released)"
pass "the cover stays while waiting, remains off when OWE recreates the background service, and stops polling after a still intro"

cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/finish-handoff.qml" "$stage/shell.qml"
mkdir -p "$stage/home/.local/state/omarchy"
printf 'finish-session\n' >"$stage/home/.local/state/omarchy/background-intro.session-id"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" OMARCHY_SESSION_ID=finish-session INTRO_TEST_LOG="$stage/starts" INTRO_TEST_COVER="$stage/cover.ppm" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "finish handoff fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "finish handoff assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "finish handoff fixture has no QML errors" "$output"
fi
pass "a finished switch keeps its cover until OWE hands back a decoded still"

# BackgroundSwitch with the real intro lookup, a fake OWE and a fake Hyprland.
require_command magick
switch="$stage/switch"
mkdir -p "$switch/services" "$switch/bin" "$switch/home/.local/state/omarchy/current" "$switch/media/intros"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$ROOT/shell/services/BackgroundSwitch.qml" "$switch/services/"
ln -s "$ROOT/shell/Commons" "$switch/Commons"
cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/switch-sequence.qml" "$switch/shell.qml"
for name in old new plain other frame; do
  magick -size 16x10 "xc:#$(printf '%06x' $((RANDOM * 512)))" "$switch/media/$name.png"
done
printf 'clip\n' >"$switch/media/intros/new.mp4"
ln -s "$switch/media/old.png" "$switch/home/.local/state/omarchy/current/background"
printf 'switch-session\n' >"$switch/home/.local/state/omarchy/background-intro.session-id"
cat >"$switch/bin/owe" <<'SH'
#!/bin/bash
[[ $1 == render-status ]] && { echo '{"kind":"still","ready":true,"has_transition":false,"time_pos":-1}'; exit 0; }
printf 'owe %s\n' "$*" >>"$SWITCH_LOG"
case $1 in
  intro) sleep 0.6; printf 'owe intro done\n' >>"$SWITCH_LOG" ;;
  render) cp "$SWITCH_STAGE/frame.png" "$(jq -r .path <<<"$2")" ;;
esac
SH
cat >"$switch/bin/hyprctl" <<'SH'
#!/bin/bash
echo '{"bool":true}'
SH
cat >"$switch/bin/omarchy-restart-hyprctl" <<'SH'
#!/bin/bash
printf 'reload\n' >>"$SWITCH_LOG"
SH
chmod +x "$switch/bin/"*
touch "$switch/log"
output=$(HOME="$switch/home" PATH="$switch/bin:$ROOT/bin:$PATH" OMARCHY_SESSION_ID=switch-session \
  SWITCH_STAGE="$switch/media" SWITCH_LOG="$switch/log" timeout 15 quickshell -p "$switch" --no-color 2>&1) || fail "background switch fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "background switch assertions pass" "$output$(printf '\n--- log\n')$(cat "$switch/log")"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background switch fixture has no QML errors" "$output"
fi
log=$(<"$switch/log")
clip="$switch/media/intros/new.mp4"
# A background change's clip starts once OWE has re-read the moved link.
[[ $log == "owe refresh"$'\n'"owe intro --start first-frame $clip"$'\n'* ]] || fail "a background change plays its intro" "$log"
# Nothing plays for a still without an intro of its own.
(( $(grep -c "^owe intro --start" <<<"$log") == 2 )) || fail "only the two intros play" "$log"
# A theme's prepared clip resumes, and Hyprland reloads only once it has ended.
[[ $log == *"owe intro --start first-frame --refresh $clip"$'\n'"owe intro done"$'\n'"reload"* ]] || fail "a theme switch reloads Hyprland after its intro" "$log"
(( $(grep -c '^reload$' <<<"$log") == 1 )) || fail "Hyprland reloads once, for the theme switch" "$log"
snapshot=$(sed -n 's/.*SNAPSHOT //p' <<<"$output")
[[ -n $snapshot && ! -e $snapshot ]] || fail "the playing frame's snapshot is removed once the cut has finished" "$snapshot"
pass "background changes play intros, cut from a playing one, and reload Hyprland after a theme's intro"
