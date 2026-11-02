#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

/usr/bin/python "$ROOT/test/shell.d/fixtures/slack-pipe.py"

# Slack's module runtime with or without the actions theme.js looks for: each
# look over the exports is counted, and the clock and DOM observer are ours.
run_node_test <<'JS'
const vm = require('vm')
const fs = require('fs')
const source = fs.readFileSync(path.join(root, 'default/slack/theme.js'), 'utf8')

function slack(withActions) {
  const sandbox = { looks: 0, now: 0, dispatched: [], observing: false, ready: withActions }
  const store = { dispatch: action => sandbox.dispatched.push(action) }
  const actions = {
    a: Object.assign(() => ({ T1: store }), { meta: { key: 'getStoreInstanceMap' } }),
    b: Object.assign(() => store, { meta: { key: 'tryGetClientStoreInstance' } }),
    c: Object.assign(action => ({ pref: action }), { meta: { key: 'createActionSetUserPref' } }),
    d: Object.assign(scheme => ({ mode: scheme }), { meta: { key: 'createActionSetClientThemeInternal' } })
  }
  const runtime = { c: { module: { get exports() { sandbox.looks++; return sandbox.ready ? actions : { a: () => {} } } } } }
  sandbox.window = { rspackChunkGantryV2: { push: chunk => chunk[2](runtime) } }
  sandbox.document = {}
  sandbox.Date = { now: () => sandbox.now }
  sandbox.setTimeout = callback => { sandbox.timer = callback }
  sandbox.clearTimeout = () => { sandbox.timer = undefined }
  sandbox.MutationObserver = class {
    constructor(callback) { sandbox.mutate = callback }
    observe() { sandbox.observing = true }
    disconnect() { sandbox.observing = false }
  }
  vm.createContext(sandbox)
  sandbox.theme = vm.runInContext(source, sandbox)
  return sandbox
}

const colors = { mode: 'dark', background: '#111111', accent: '#222222', green: '#333333', red: '#444444' }

const unknown = slack(false)
unknown.theme(colors)
for (let i = 0; i < 100; i++) unknown.mutate()
assertEqual(unknown.looks, 1, 'a Slack build without the actions is searched at most once a second')
unknown.now = 61000
unknown.mutate()
assert(!unknown.observing, 'theme.js stops watching a Slack build without the actions after a minute')

const late = slack(false)
late.theme(colors)
late.now = 500
late.ready = true
late.mutate()
late.now = 1000
late.timer()
assertEqual(late.dispatched.length, 3, 'actions that load inside the skipped second still get themed once Slack goes quiet')

const known = slack(true)
known.theme(colors)
known.theme({ ...colors, mode: 'light', background: '#eeeeee' })
assertEqual(known.looks, 1, 'theme changes reuse the actions found on the first look')
assertEqual(known.dispatched.at(-3).pref.value.primary.custom, '#eeeeee', 'a theme change dispatches its own colors')
JS

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch"
state="$HOME/.local/state/omarchy/slack"
theme="$HOME/.local/state/omarchy/current/theme/slack.json"
override="$HOME/.local/share/applications/slack.desktop"

"$ROOT/bin/omarchy-theme-set-slack"
[[ ! -e $HOME/.local ]] || fail "theme sync leaves unconfigured machines alone"
pass "theme sync leaves unconfigured machines alone"

mkdir -p "$state" "${theme%/*}"
touch "$state/enabled"
printf '%s\n' '{"mode":"light","background":"#eff1f5","accent":"#1e66f5","green":"#40a02b","red":"#d20f39"}' >"$theme"
"$ROOT/bin/omarchy-theme-set-slack"
jq -se '.[0] == .[1]' "$theme" "$state/theme.json" >/dev/null || fail "theme sync publishes the staged colors"
pass "theme sync publishes the staged colors"

jq '.background = "#112233" | .green = "#445566" | .red = "#778899"' "$state/theme.json" >"$scratch/rgb.json"
jq 'with_entries(if .key == "mode" then . else .value += "80" end)' "$scratch/rgb.json" >"$theme"
"$ROOT/bin/omarchy-theme-set-slack"
jq -se '.[0] == .[1]' "$scratch/rgb.json" "$state/theme.json" >/dev/null || fail "RGBA colors publish their RGB values"
pass "RGBA colors publish their RGB values"

cp "$state/theme.json" "$scratch/before.json"
jq '.background = "invalid"' "$state/theme.json" >"$theme"
"$ROOT/bin/omarchy-theme-set-slack" 2>"$scratch/skip.log"
cmp -s "$scratch/before.json" "$state/theme.json" || fail "invalid colors leave the previous theme intact"
pass "invalid colors leave the previous theme intact"

mkdir "$scratch/bin"
cat >"$scratch/bin/stub" <<'STUB'
#!/bin/bash
case ${0##*/} in
  omarchy-pkg-*)
    [[ $* == "slack-desktop" ]] || exit 1
    exit "${TEST_PACKAGE_EXIT:-0}"
    ;;
  omarchy-setup-slack) exit 1 ;;
  uwsm-app) timeout 3 bash -c 'printf "%s\n" "$*" >"$HOME/launch"' bash "$@" ;;
esac
STUB
chmod +x "$scratch/bin/stub"
for command in omarchy-pkg-add omarchy-pkg-drop omarchy-setup-slack uwsm-app update-desktop-database; do
  ln -s stub "$scratch/bin/$command"
done
export PATH="$scratch/bin:$PATH"
mkfifo "$HOME/launch"

"$ROOT/bin/omarchy-install-service-slack" 2>"$scratch/install.log"
[[ $(timeout 3 cat "$HOME/launch") == "-- gio launch /usr/share/applications/slack.desktop" ]] || fail "failed theme setup opens packaged Slack"
pass "failed theme setup opens packaged Slack"
if TEST_PACKAGE_EXIT=1 "$ROOT/bin/omarchy-install-service-slack"; then
  fail "failed package installation stops the installer"
fi
pass "failed package installation stops the installer"

mkdir -p "${override%/*}" "$HOME/.config/Slack"
printf 'Exec=omarchy-launch-slack %%U\n' >"$override"
printf 'original launcher\n' >"$override.before-omarchy"
touch "$HOME/.config/Slack/keep"
if TEST_PACKAGE_EXIT=1 "$ROOT/bin/omarchy-remove-service-slack"; then
  fail "canceled package removal preserves the integration"
fi
[[ -f $override && -f $state/enabled ]] || fail "canceled package removal preserves the integration"
pass "canceled package removal preserves the integration"

"$ROOT/bin/omarchy-remove-service-slack"
[[ ! -e $override && ! -e $state ]] || fail "successful removal cleans the integration"
[[ -f $HOME/.config/Slack/keep && -f $override.before-omarchy ]] || fail "removal keeps the profile and original launcher backup"
pass "successful removal cleans the integration and keeps user data"

printf 'Exec=custom-slack\n' >"$override"
"$ROOT/bin/omarchy-remove-service-slack"
[[ $(<"$override") == "Exec=custom-slack" ]] || fail "removal keeps custom launchers"
pass "removal keeps custom launchers"
