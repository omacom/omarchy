#!/bin/bash
# omarchy:exclusive

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# --- The Welcome tour model: steps, guards, local AI hardware filter, and Finish plan ---

run_node_test <<'JS'
const fs = require('fs')
const MenuModel = requireFromRoot('shell/plugins/menu/MenuModel.js')
const Setup = requireFromRoot('shell/plugins/setup/SetupModel.js')

const shippedRows = MenuModel.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const withRows = (rows) => MenuModel.mergeMenuSources(shippedRows, MenuModel.parseMenuJsonc(JSON.stringify(rows)), '')
const shipped = withRows({})
const stepsFor = (guards, offer, menu = shipped, chosen = '', panel = true) =>
  Setup.tourSteps(menu.items, menu.itemOrder, guards, offer, { panel, chosen }, null)
const nothing = { when: {}, checked: {}, disabled: {} }

const recipes = [
  { id: 'small-8b', kind: 'text', name: 'Small 8B', best: false, available: true, installed: false, memory_gib: 8, context: 65536, decode_tok_s: 88.2 },
  { id: 'big-27b', kind: 'text', name: 'Big 27B', best: true, available: true, installed: false, memory_gib: 24, context: 131072, decode_tok_s: 41.6 }
]
const offered = (change) => Setup.localOffers(JSON.stringify(recipes.map((recipe) => recipe.best ? { ...recipe, ...change } : recipe)))
const singleOffer = (change) => Setup.localOffers(JSON.stringify([{ ...recipes[1], ...change }]))

// Exact step ordering and shipped menu coverage.
const full = stepsFor(nothing, singleOffer({}))
assertDeepEqual(full.map((step) => step.id), ['layout', 'dictation', 'agent', 'local-ai', 'tailscale'],
  'tour steps follow Layout -> Dictation -> Agent -> Local AI -> Tailscale')
assert(full[0].kind === 'choice' && full[0].options.length === 3, 'layout offers all three shipped modes')
assert(full[0].options.every((option) => option.pictogram !== '' && option.detail !== ''), 'layout cards carry pictograms and subtitles')
assert(full[1].kind === 'choice' && full[1].options.length >= 3, 'dictation offers shipped backends')
assert(full[1].options.every((option) => option.detail !== ''), 'dictation cards carry subtitles')
assert(full[2].kind === 'toggle' && full[3].kind === 'toggle' && full[4].kind === 'toggle', 'agent, single-model local-ai, and tailscale are toggle steps')

const multiLocal = stepsFor(nothing, offered({})).find((step) => step.id === 'local-ai')
assert(multiLocal.kind === 'choice' && multiLocal.optional === true, 'multiple compatible local blueprints render as an optional choice step')
assertDeepEqual(multiLocal.options.map((option) => option.id), ['local-ai.big-27b', 'local-ai.small-8b'],
  'compatible local blueprints sort recommended (best) first')
assert(multiLocal.options[0].recommended && !multiLocal.options[1].recommended, 'best local blueprint carries the recommended badge')
assertEqual(Setup.pick(multiLocal, {}), null, 'multi-blueprint local-ai starts unstaged so nothing downloads by default')
assertDeepEqual(Setup.tourPlan([multiLocal], { 'local-ai': 'local-ai.small-8b' }).argv, ['omarchy-setup-essentials', '--local-ai', 'small-8b'],
  'picking any compatible local blueprint passes its exact recipe id')

// Guards: only tour entries and their ancestors are requested.
const asked = Setup.guardEntries(shipped.items, shipped.itemOrder)
assert(['appearance', 'appearance.workspace-layout', 'appearance.workspace-layout.dwindle', 'setup', 'setup.default', 'setup.default.dictation', 'install', 'install.service', 'install.service.tailscale'].every((id) => id in asked),
  'guard batch covers layout, dictation, Tailscale and their ancestor chains')
assert(!('setup.security' in asked) && !('setup.network' in asked), 'unrelated Setup menu entries are not queried')

const hiddenSubmenu = withRows({ 'install.service': { label: 'Service', when: 'false' } })
assert(!stepsFor({ when: { 'install.service': false }, checked: {}, disabled: {} }, null, hiddenSubmenu).some((s) => s.id === 'tailscale'),
  'a hidden ancestor submenu omits Tailscale')

const altMenu = withRows({
  'setup.default.dictation.quick': { label: 'Quick', alt: 'setup.default.dictation.slow', action: 'omarchy-default-dictation quick' },
  'setup.default.dictation.slow': { label: 'Slow', action: 'omarchy-default-dictation slow' },
  'setup.default.dictation.custom': { label: 'Custom', action: 'my-dictation --start; echo done' }
})
const dictIds = stepsFor(nothing, null, altMenu).find((s) => s.id === 'dictation').options.map((o) => o.id)
assert(dictIds.includes('setup.default.dictation.quick') && !dictIds.includes('setup.default.dictation.slow'), 'Alt stand-ins are excluded')
assert(!dictIds.includes('setup.default.dictation.custom'), 'menu rows whose action cannot be sequenced are excluded')

// Partial guard batch: unanswered when/disabled hides rows; unanswered checked stays unknown.
const partial = stepsFor({ when: {}, checked: {}, disabled: {}, partial: true }, null)
assert(!partial.some((s) => s.id === 'tailscale'), 'unanswered disabled guard omits Tailscale on a partial batch')
assertEqual(Setup.currentOption(partial.find((s) => s.id === 'layout')), null, 'unanswered checked guard stays unknown')

const some = { when: Object.fromEntries(Object.keys(asked).filter((id) => asked[id].when).map((id) => [id, true])), checked: {}, disabled: {} }
assert(!Setup.answeredAll(asked, some), 'missing disabled guard marks batch incomplete')
some.disabled = Object.fromEntries(Object.keys(asked).filter((id) => asked[id].disabled).map((id) => [id, false]))
assert(Setup.answeredAll(asked, some), 'answering every when and disabled guard completes the batch')

assertDeepEqual(Setup.parseGuards('setup.input:w:0\nsetup.a:b:c:1\ngarbage\ninstall.service.tailscale:d:1\n'),
  { when: { 'setup.input': false }, checked: { 'setup.a:b': true }, disabled: { 'install.service.tailscale': true } },
  'guard answers parse from the end of each line')

// Conditional step omission.
const settled = { when: {}, checked: { 'appearance.workspace-layout.dwindle': true }, disabled: { 'install.service.tailscale': true } }
assertDeepEqual(stepsFor(settled, null).map((s) => s.id), ['layout', 'dictation', 'agent'],
  'Tailscale omitted when installed, Local AI omitted when no model fits')
assert(!stepsFor(settled, null, shipped, 'claude', true).some((s) => s.id === 'agent'), 'Agent omitted when a default agent is already set')
assert(!stepsFor(settled, null, shipped, '', false).some((s) => s.id === 'agent'), 'Agent omitted when no agents panel handler exists')

// Local AI blueprint filter (matches Agents panel's available uninstalled text recipes, best first).
assertDeepEqual(offered({}).map((item) => item.id), ['big-27b', 'small-8b'], 'all compatible text blueprints are offered with best first')
assertDeepEqual(singleOffer({ installed: true }), [], 'installed model is not offered')
assertDeepEqual(singleOffer({ available: false }), [], 'unsupported hardware model is not offered')
assertDeepEqual(singleOffer({ id: 'big; touch owned' }), [], 'invalid recipe id is refused')
assertDeepEqual(singleOffer({ kind: 'image' }), [], 'non-text model is not offered')
assertDeepEqual(singleOffer({ kind: undefined }), [], 'untyped model is not offered')
assertDeepEqual(Setup.localOffers('not json'), [], 'malformed listing offers nothing')

// Pick semantics, unmatched current setting, and Finish plan.
const current = { when: {}, checked: { 'appearance.workspace-layout.dwindle': true, 'setup.default.dictation.superwhisper': true }, disabled: {} }
const tour = stepsFor(current, singleOffer({}))
assertDeepEqual(Setup.tourPlan(tour, {}).argv, [], 'an untouched tour runs nothing')
assertDeepEqual(Setup.tourPlan(tour, { layout: 'appearance.workspace-layout.dwindle', dictation: 'setup.default.dictation.superwhisper', agent: false }).argv, [],
  'picking current settings and leaving toggles off runs nothing')

const layoutOnly = Setup.tourPlan(tour, { layout: 'appearance.workspace-layout.floating', agent: true })
assert(!layoutOnly.hasInstalls && layoutOnly.hasAgent, 'layout + agent has no terminal installs')

const flags = (argv) => {
  const out = []
  for (let i = 1; i < argv.length; i++) {
    const valued = argv[i].startsWith('--') && i + 1 < argv.length && !argv[i + 1].startsWith('--')
    out.push(valued ? [argv[i], argv[++i]] : [argv[i]])
  }
  return out.sort((a, b) => a[0].localeCompare(b[0]))
}

const allChanges = Setup.tourPlan(tour, {
  layout: 'appearance.workspace-layout.scrolling',
  dictation: 'setup.default.dictation.voxtype',
  agent: true,
  'local-ai': true,
  tailscale: true
})
assertEqual(allChanges.argv[0], 'omarchy-setup-essentials', 'Finish runs one command')
assert(allChanges.hasInstalls && allChanges.hasAgent, 'installs and agent flags are reported')
assertDeepEqual(flags(allChanges.argv), [['--agent'], ['--dictation', 'voxtype'], ['--layout', 'scrolling'], ['--local-ai', 'big-27b'], ['--tailscale']],
  'command carries every staged change and the exact local recipe')

// Superwhisper Cloud vs On-device sub-options and current-mode detection.
assertEqual(Setup.parseSuperwhisperMode('{"processing":"cloud"}'), 'cloud', 'parses cloud processing mode')
assertEqual(Setup.parseSuperwhisperMode('{"processing":"offline_lite"}'), 'offline', 'normalizes offline_lite to offline')
assertEqual(Setup.parseSuperwhisperMode('{"processing":"offline"}'), 'offline', 'parses offline processing mode')
assertEqual(Setup.parseSuperwhisperMode('not json'), '', 'invalid superwhisper json falls back to empty')

const swCloudToLocal = Setup.tourPlan(tour, {}, { dictation: 'offline' })
assertDeepEqual(swCloudToLocal.argv, ['omarchy-setup-essentials', '--dictation', 'superwhisper', '--dictation-mode', 'offline'],
  'switching current Superwhisper from Cloud to On-device stages --dictation-mode offline')
assertEqual(swCloudToLocal.changes[0].label, 'Superwhisper \u00b7 On-device', 'summary shows Superwhisper sub-option label')
assertDeepEqual(Setup.tourPlan(tour, {}, { dictation: 'cloud' }).argv, [],
  'selecting Superwhisper current Cloud sub-option stays a no-op')

const swAlreadyOffline = Setup.tourSteps(shipped.items, shipped.itemOrder, current, null, { panel: true, chosen: '' }, null, 'offline')
assertEqual(Setup.pickSubOption(Setup.pick(swAlreadyOffline[1], {}), '').id, 'offline',
  'current offline mode selects On-device sub-option by default')
assertDeepEqual(Setup.tourPlan(swAlreadyOffline, {}, {}).argv, [],
  'untouched offline Superwhisper stays a no-op')
assertDeepEqual(Setup.tourPlan(swAlreadyOffline, {}, { dictation: 'cloud' }).argv,
  ['omarchy-setup-essentials', '--dictation', 'superwhisper', '--dictation-mode', 'cloud'],
  'switching offline Superwhisper back to Cloud stages --dictation-mode cloud')

// Unmatched saved choice starts unstaged and supports returning to "" (keep current).
const unmatched = stepsFor(nothing, null)
assertEqual(Setup.pick(unmatched[0], {}), null, 'choice step with no matched current starts unstaged')
assertDeepEqual(Setup.tourPlan(unmatched, {}).argv, [], 'unstaged choice step runs nothing')
assertEqual(Setup.pick(unmatched[0], { layout: 'appearance.workspace-layout.floating' }).id, 'appearance.workspace-layout.floating', 'staging a choice picks it')
assertEqual(Setup.pick(unmatched[0], { layout: '' }), null, 'keeping current clears back to unstaged')
assertEqual(Setup.pick(tour[0], { layout: 'appearance.workspace-layout.gone' }).id, 'appearance.workspace-layout.dwindle', 'stale id falls back to current')
JS

# --- Off-screen QML tour card interactions ---

if command -v quickshell >/dev/null 2>&1; then
  require_command jq
  (
    unset WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE DISPLAY
    qml_fixture_scratch
    mkdir -m 700 "$QML_FIXTURE_TMP/runtime"
    XDG_RUNTIME_DIR="$QML_FIXTURE_TMP/runtime" QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME= \
      run_qml_fixture setup-tour "Welcome card handles Splash, choice cards, toggle cards, Tab focus, stepViewed, and scroll stability" Ui Commons plugins
  )
else
  skip "quickshell not installed; skipping Welcome card fixture"
fi

# --- omarchy-setup-essentials executes choices in order and hands off to Agents cleanly ---

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
stubs="$work/bin"
calls="$work/calls"
mkdir -p "$stubs" "$work/home" "$work/run"

stub() {
  printf '#!/bin/bash\necho "%s $*" >>"$OMARCHY_TEST_CALLS"\nexit ${%s:-0}\n' "$1" "${2:-OMARCHY_TEST_NO_FAILURE}" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

for name in omarchy-done omarchy-notification-dismiss nm-online omarchy-install-dictation-voxtype omarchy-models omarchy-show-logo; do
  stub "$name"
done
stub omarchy-hyprland-workspace-layout-default OMARCHY_TEST_LAYOUT_STATUS
stub omarchy-install-service-tailscale OMARCHY_TEST_TAILSCALE_STATUS
stub omarchy-shell OMARCHY_TEST_PANEL_STATUS
stub omarchy-show-done OMARCHY_TEST_DONE_STATUS
printf '#!/bin/bash\n:\n' >"$stubs/omarchy-restart-gum"
printf '#!/bin/bash\necho "$1"\n' >"$stubs/omarchy-i18n"
printf '#!/bin/bash\necho "${OMARCHY_TEST_DICTATION:-voxtype}"\n' >"$stubs/omarchy-default-dictation"

cat >"$stubs/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
echo "terminal: $*" >>"$OMARCHY_TEST_CALLS"
bash -c "$*"
SH

# Emulates uwsm-app -- xdg-terminal-exec ... -e bash -c "<script>" in a child bash
# so $$ exits cleanly before the detached post-terminal agent waiter fires.
cat >"$stubs/uwsm-app" <<'SH'
#!/bin/bash
echo "uwsm-terminal" >>"$OMARCHY_TEST_CALLS"
while (($#)); do
  if [[ $1 == "-c" ]]; then
    shift
    bash -c "$1"
    exit $?
  fi
  shift
done
exit 1
SH

chmod +x "$stubs"/*

essentials() {
  : >"$calls"
  HOME="$work/home" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_TEST_CALLS="$calls" "$@" >"$work/output" 2>&1
}

wait_for_call() {
  local pattern="$1" i
  for ((i = 0; i < 60; i++)); do
    grep -Fxq "$pattern" "$calls" && return 0
    sleep 0.05
  done
  return 1
}

answered() {
  grep -Fxq 'omarchy-done mark agent-setup-invitation' "$calls" && grep -Fxq 'omarchy-notification-dismiss firstRun.agentTitle' "$calls"
}

# Installs without --agent share one presentation terminal.
essentials omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai big-27b ||
  fail "installs without agent succeed" "$(<"$work/output")"
[[ $(sed -n '1p' "$calls") == "omarchy-hyprland-workspace-layout-default scrolling" ]] || fail "layout changes before terminal opens" "$(<"$calls")"
[[ $(grep -c '^terminal: ' "$calls") == "1" ]] || fail "installs share one presentation terminal" "$(<"$calls")"
grep -Fxq 'omarchy-models use --detach big-27b' "$calls" || fail "local model uses exact recipe" "$(<"$calls")"
pass "layout applies immediately and installs share one presentation terminal"

# Installs WITH --agent run presentation terminal, prompt via omarchy-show-done, and open Agents after terminal exits.
essentials omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai big-27b --agent ||
  fail "installs with agent succeed" "$(<"$work/output")"
wait_for_call 'omarchy-shell omarchy.agents open' || fail "Agents opens after terminal exits" "$(<"$calls")"
wait_for_call 'omarchy-notification-dismiss firstRun.agentTitle' || fail "agent invitation is marked and dismissed" "$(<"$calls")"
grep -Fxq 'omarchy-show-done 0' "$calls" || fail "terminal waits on omarchy-show-done before handing off" "$(<"$calls")"
done_line=$(grep -n '^omarchy-show-done 0$' "$calls" | head -n1 | cut -d: -f1)
agent_line=$(grep -n '^omarchy-shell omarchy.agents open$' "$calls" | head -n1 | cut -d: -f1)
(( agent_line > done_line )) || fail "Agents opens strictly after omarchy-show-done" "$(<"$calls")"
pass "installs + agent opens Agents cleanly after terminal acknowledgement"

# Failed install with --agent still lets the user acknowledge and open Agents.
if OMARCHY_TEST_TAILSCALE_STATUS=1 essentials omarchy-setup-essentials --tailscale --agent; then
  fail "failed install exits non-zero" "$(<"$work/output")"
fi
wait_for_call 'omarchy-shell omarchy.agents open' || fail "failed install still opens Agents after acknowledgement" "$(<"$calls")"
grep -Fxq 'omarchy-show-done 1' "$calls" || fail "omarchy-show-done receives failure code" "$(<"$calls")"
pass "failed install reports failure and still allows Agents handoff after acknowledgement"

# Ctrl-C (exit 130) or closed terminal (omarchy-show-done fails) must NOT open Agents.
if OMARCHY_TEST_TAILSCALE_STATUS=130 essentials omarchy-setup-essentials --tailscale --agent; then
  :
fi
sleep 0.2
if grep -Fq 'omarchy-shell omarchy.agents open' "$calls"; then
  fail "Ctrl-C during install must not open Agents" "$(<"$calls")"
fi
if OMARCHY_TEST_DONE_STATUS=1 essentials omarchy-setup-essentials --tailscale --agent; then
  :
fi
sleep 0.2
if grep -Fq 'omarchy-shell omarchy.agents open' "$calls"; then
  fail "closing terminal before acknowledgement must not open Agents" "$(<"$calls")"
fi
pass "cancelling or closing the terminal before acknowledgement leaves Agents closed"

# Direct paths without installs.
essentials omarchy-setup-essentials --layout floating || fail "layout alone succeeds" "$(<"$work/output")"
[[ $(<"$calls") == "omarchy-hyprland-workspace-layout-default floating" ]] || fail "layout alone opens no terminal" "$(<"$calls")"

essentials omarchy-setup-essentials --agent || fail "agent alone succeeds" "$(<"$work/output")"
[[ $(grep -v '^omarchy-done \|^omarchy-notification-dismiss ' "$calls") == "omarchy-shell omarchy.agents open" ]] ||
  fail "agent alone opens Agents directly with no terminal" "$(<"$calls")"
answered || fail "direct agent open marks and dismisses invitation" "$(<"$calls")"
if OMARCHY_TEST_PANEL_STATUS=1 essentials omarchy-setup-essentials --agent; then
  fail "agent open failure exits non-zero" "$(<"$work/output")"
fi
if grep -q '^omarchy-done \|^omarchy-notification-dismiss ' "$calls"; then
  fail "failed agent open leaves invitation untouched" "$(<"$calls")"
fi
pass "layout-only and agent-only paths run directly with no terminal"

OMARCHY_TEST_DICTATION=superwhisper essentials omarchy-setup-essentials --dictation voxtype ||
  fail "declined dictation is not an error" "$(<"$work/output")"
grep -Fq 'Left as it was: dictation' "$work/output" || fail "declined dictation is reported" "$(<"$work/output")"
pass "declined dictation is reported as left alone"

if OMARCHY_TEST_LAYOUT_STATUS=1 essentials omarchy-setup-essentials --layout scrolling --tailscale; then
  fail "layout failure fails the run" "$(<"$work/output")"
fi
[[ $(grep -c '^omarchy-hyprland-workspace-layout-default scrolling$' "$calls") == "2" ]] ||
  fail "failed layout is retried in the terminal so the reason shows" "$(<"$calls")"
pass "failed layout carries into the terminal"

refused() {
  if essentials omarchy-setup-essentials "$@"; then
    fail "invalid argument is refused: $*"
  fi
  [[ ! -s $calls ]] || fail "refused value runs nothing: $*" "$(<"$calls")"
}
refused --dictation 'voxtype; touch owned'
refused --dictation superwhisper --dictation-mode turbo
refused --dictation voxtype --dictation-mode offline
refused --dictation-mode offline
refused --local-ai 'big; touch owned'
refused --layout sideways
pass "invalid values are refused before anything runs"

# Superwhisper mode switch when already default selects mode and queues missing offline models without reinstalling.
cat >"$stubs/superwhisper" <<'SH'
#!/bin/bash
echo "superwhisper $*" >>"$OMARCHY_TEST_CALLS"
if [[ $1 == "models" && $2 == "show" ]]; then
  echo '{"processing":"offline_lite","processingModes":[{"value":"offline_lite","missing":["parakeet-v3-int8"]}]}'
fi
SH
chmod +x "$stubs/superwhisper"
stub omarchy-install-dictation-superwhisper

OMARCHY_TEST_DICTATION=superwhisper essentials omarchy-setup-essentials --dictation superwhisper --dictation-mode offline ||
  fail "superwhisper mode switch succeeds" "$(<"$work/output")"
if grep -Fq 'omarchy-install-dictation-superwhisper' "$calls"; then
  fail "already-default superwhisper mode switch skips installer" "$(<"$calls")"
fi
grep -Fxq 'superwhisper models select offline' "$calls" || fail "superwhisper mode is selected" "$(<"$calls")"
grep -Fxq 'superwhisper models download parakeet-v3-int8' "$calls" || fail "missing offline model download is queued" "$(<"$calls")"
pass "superwhisper mode switch configures mode and queues missing offline models"

# --- omarchy-launch-setup CLI validation and --wait request ownership ---

cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
[[ $1 == "-q" ]] && shift
case "$1 $2 $3 $4" in
  "shell summon omarchy.setup "*)
    jq -r '.reply' <<<"$4" >"$OMARCHY_TEST_DIR/reply"
    jq -r '.expires' <<<"$4" >"$OMARCHY_TEST_DIR/expires"
    echo "${OMARCHY_TEST_SUMMON:-ok}"
    ;;
  "shell call omarchy.setup state")
    if [[ $5 != "$(<"$OMARCHY_TEST_DIR/reply")" ]]; then
      echo other
      exit 0
    fi
    mapfile -t answers <"$OMARCHY_TEST_DIR/answers"
    (( ${#answers[@]} < 2 )) || printf '%s\n' "${answers[@]:1}" >"$OMARCHY_TEST_DIR/answers"
    answer=${answers[0]}
    if [[ $answer == closed* ]]; then
      for step in ${answer#closed} closed; do
        touch "$5/$step"
      done
      answer=unknown
    fi
    [[ $answer == "silence" ]] || echo "$answer"
    ;;
  "shell call omarchy.setup cancel") echo "$5" >>"$OMARCHY_TEST_DIR/cancelled" ;;
esac
SH
chmod +x "$stubs/omarchy-shell"
printf 'sleep() { SECONDS=$((SECONDS + 1)); }\n' >"$work/clock"

launch() {
  local extra=()
  if [[ ${1:-} == "--args" ]]; then
    shift
    while [[ ${1:-} != "--" ]]; do extra+=("$1"); shift; done
    shift
  fi
  printf '%s\n' "$@" >"$work/answers"
  rm -f "$work/cancelled"
  BASH_ENV="$work/clock" XDG_RUNTIME_DIR="$work/run" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_TEST_DIR="$work" \
    timeout 20 omarchy-launch-setup "${extra[@]}" --wait >"$work/picked" 2>"$work/output"
}

if PATH="$stubs:$ROOT/bin:$PATH" omarchy-launch-setup security >"$work/output" 2>&1; then
  fail "unknown page names are rejected"
fi
if PATH="$stubs:$ROOT/bin:$PATH" omarchy-launch-setup welcome extra >"$work/output" 2>&1; then
  fail "extra operands are rejected"
fi
launch --args welcome -- opening shown closed || fail "optional welcome operand still works" "$(<"$work/output")"
launch opening shown shown "closed layout agent seen-agent seen-ready" || fail "--wait returns once closed" "$(<"$work/output")"
[[ $(tr '\n' ' ' <"$work/picked") == "agent layout seen-agent seen-ready " ]] || fail "--wait prints outcome markers" "$(<"$work/picked")"
(( $(<"$work/expires") > EPOCHSECONDS )) || fail "--wait sets an expiry deadline" "$(<"$work/expires")"
launch opening shown silence silence closed || fail "transient IPC silence retries" "$(<"$work/output")"
[[ ! -s $work/picked ]] || fail "closed without picks prints nothing" "$(<"$work/picked")"
if launch opening shown unknown; then fail "gone without closed fails"; fi
if launch opening other; then fail "replaced before shown fails"; fi
[[ ! -e $work/cancelled ]] || fail "replacement is left open" "$(<"$work/cancelled")"
if launch opening; then fail "never shown fails"; fi
[[ $(<"$work/cancelled") == "$(<"$work/reply")" ]] || fail "timed-out request cancels only itself"
if OMARCHY_TEST_SUMMON=unknown launch opening shown closed; then fail "summon error fails"; fi
[[ -z $(ls -A "$work/run") ]] || fail "--wait cleans up its runtime dir" "$(ls -A "$work/run")"
pass "omarchy-launch-setup validates args and honors --wait request ownership"

# --- First run marks welcome-tour and suppresses duplicate toasts only when seen ---

cat >"$stubs/omarchy-launch-setup" <<'SH'
#!/bin/bash
echo "omarchy-launch-setup $*" >>"$OMARCHY_TEST_CALLS"
[[ -z ${OMARCHY_TEST_TOUR_PICKED:-} ]] || printf '%s\n' $OMARCHY_TEST_TOUR_PICKED
exit ${OMARCHY_TEST_TOUR_STATUS:-0}
SH
chmod +x "$stubs/omarchy-launch-setup"
rm -f "$stubs/omarchy-done"
marker="$work/home/.local/state/omarchy/done"

tour() {
  essentials "$@" bash "$ROOT/install/user/first-run/welcome-tour.sh"
}

tour env OMARCHY_TEST_TOUR_STATUS=1 OMARCHY_TEST_TOUR_PICKED="agent seen-agent seen-ready" || fail "unshown tour does not fail first run" "$(<"$work/output")"
[[ ! -e $marker/welcome-tour && ! -e $marker/agent-setup-invitation && ! -e $marker/welcome-keybindings ]] || fail "unshown tour marks nothing"

# Skipping on Splash produces empty reply: marks welcome-tour only, leaving fallback toasts eligible.
tour env || fail "skipped tour passes"
grep -Fxq 'omarchy-launch-setup --wait' "$calls" || fail "first run calls omarchy-launch-setup --wait" "$(<"$calls")"
[[ -e $marker/welcome-tour && ! -e $marker/agent-setup-invitation && ! -e $marker/welcome-keybindings ]] ||
  fail "skipping on Splash leaves agent and keybindings fallback toasts eligible"
tour env || fail "already-taken tour is a no-op"
[[ ! -s $calls ]] || fail "first run shows the tour once" "$(<"$calls")"

# Seeing Agent (even left off) and reaching Ready suppresses both duplicate toasts.
rm -rf "$work/home"
tour env OMARCHY_TEST_TOUR_PICKED="seen-agent seen-ready" || fail "completed tour passes"
[[ -e $marker/agent-setup-invitation && -e $marker/welcome-keybindings ]] ||
  fail "seeing Agent and Ready suppresses duplicate agent and keybindings toasts"

stub omarchy-notification-send
essentials bash "$ROOT/install/user/first-run/welcome.sh" || fail "welcome.sh succeeds when suppressed"
[[ ! -s $calls ]] || fail "welcome.sh sends no duplicate keybindings toast when welcome-keybindings is marked" "$(<"$calls")"
pass "first run shows Welcome once and suppresses duplicate toasts only when seen"

# --- Live shell check ---

require_quickshell "Welcome opening in a running shell"

rm -rf "$work"
setup_scratch_shell
for name in omarchy-setup-essentials omarchy-launch-floating-terminal-with-presentation omarchy-models; do
  printf '#!/bin/bash\nexit 0\n' >"$SCRATCH_BIN/$name"
  chmod +x "$SCRATCH_BIN/$name"
done
start_scratch_shell
wait_scratch_shell

open_tour() {
  local shown=""

  (scratch_exec timeout 30 "$ROOT/bin/omarchy-launch-setup" --wait) >"$SCRATCH_DIR/wait.log" 2>&1 &
  waiter=$!
  if ! wait_scratch_layer omarchy-setup mapped; then
    sed -n '1,120p' "$SCRATCH_LOG" >&2
    fail "Welcome opens in a running shell"
  fi
  for _ in {1..100}; do
    shown=$(scratch_ipc shell call omarchy.setup state "{}" 2>/dev/null || true)
    [[ $shown != "shown" ]] || break
    sleep 0.05
  done
  [[ $shown == "shown" ]] || fail "Welcome reports shown once revealed" "$shown"
  kill -0 "$waiter" 2>/dev/null || fail "--wait holds while Welcome is open" "$(<"$SCRATCH_DIR/wait.log")"
}

open_tour
scratch_ipc shell hide omarchy.setup >/dev/null
wait_scratch_layer omarchy-setup absent || fail "hiding Welcome unmaps it"
wait "$waiter" || fail "--wait returns when Welcome closes" "$(<"$SCRATCH_DIR/wait.log")"
pass "Welcome opens in a running shell and --wait returns on close"

# A second Welcome summon replaces the first request cleanly and reports `replaced`.
open_tour
scratch_ipc shell summon omarchy.setup '{}' >/dev/null
wait "$waiter" || fail "--wait returns once replaced by another Welcome opening" "$(<"$SCRATCH_DIR/wait.log")"
grep -Fxq replaced "$SCRATCH_DIR/wait.log" || fail "replaced wait emits the replaced marker" "$(<"$SCRATCH_DIR/wait.log")"
[[ $(scratch_layer_state omarchy-setup) == "mapped" ]] || fail "replacement Welcome stays open"
scratch_ipc shell hide omarchy.setup >/dev/null
wait_scratch_layer omarchy-setup absent || fail "hiding replacement Welcome unmaps it"
pass "a second Welcome opening replaces an earlier wait cleanly"

scratch_ipc shell summon omarchy.setup '{"expires":1}' >/dev/null
sleep 0.5
[[ $(scratch_layer_state omarchy-setup) == "absent" ]] || fail "expired request is dropped"
[[ $(scratch_ipc shell call omarchy.setup state "{}" 2>/dev/null || true) != "shown" ]] || fail "expired request leaves nothing open"
# Expired request followed immediately by a valid request leaves the valid one open.
scratch_ipc shell summon omarchy.setup '{"expires":1}' >/dev/null
scratch_ipc shell summon omarchy.setup '{}' >/dev/null
wait_scratch_layer omarchy-setup mapped || fail "valid request after expired request stays open"
scratch_ipc shell hide omarchy.setup >/dev/null
wait_scratch_layer omarchy-setup absent || fail "hiding Welcome after expired+valid pair unmaps it"
pass "expired Welcome request is dropped without closing a valid replacement"

problems=$(grep -F 'plugins/setup' "$SCRATCH_LOG" || true)
[[ -z $problems ]] || fail "Welcome opens without QML warnings" "$problems"
pass "Welcome opens without QML warnings"
