#!/bin/bash
# omarchy:exclusive

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# --- The pages are a lens over the shipped menu, and the tour's plan follows it ---

run_node_test <<'JS'
const fs = require('fs')
const MenuModel = requireFromRoot('shell/plugins/menu/MenuModel.js')
const Setup = requireFromRoot('shell/plugins/setup/SetupModel.js')

const shippedRows = MenuModel.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const withRows = (rows) => MenuModel.mergeMenuSources(shippedRows, MenuModel.parseMenuJsonc(JSON.stringify(rows)), '')
const shipped = withRows({})
const pagesFor = (guards, offer, menu = shipped) => Setup.pages(menu.items, menu.itemOrder, guards, offer, null, MenuModel.resolveRoute)
const options = (pages, id) => Setup.flatOptions(pages.find((page) => page.id === id))
const nothing = { when: {}, checked: {}, disabled: {} }

// A row added to one of these menus with a command the tour cannot sequence
// would be offered on the pages and silently missing from the tour.
const fresh = pagesFor(nothing, null)
for (const id of ['layout', 'agent', 'dictation', 'tailscale']) {
  const stranded = options(fresh, id).filter((option) => !option.args).map((option) => option.id)
  assert(options(fresh, id).length > 0 && stranded.length === 0, `the tour can set up every shipped ${id} row`, JSON.stringify(stranded))
}

assert(!fresh.some((page) => page.id === 'setup.welcome'), 'the row that opens Setup is not one of its pages')
assert(!fresh.find((page) => page.id === 'setup.default').groups.some((group) => group.id === 'setup.default.dictation'),
  'Defaults leaves Dictation to the page that already shows it')
assertEqual(options(fresh, 'setup.region').find((option) => option.id === 'setup.region.language').route, 'setup.region.language',
  'a list the menu builds at runtime opens in the menu')
assertEqual(Setup.handoffKind(shipped.items['setup.git'].action), 'terminal', 'a row that opens a terminal wizard is previewed as one')
assertEqual(Setup.handoffKind(shipped.items['setup.default.browser.firefox'].action), '', 'a row that opens nothing is previewed as itself')
assertEqual(Setup.editorFile(shipped.items['setup.config.hyprland'].action), 'hyprland.lua', 'an editor row names the file it opens')
assertEqual(Setup.editorFile(shipped.items['setup.config.xcompose'].action), '.XCompose', 'an editor row names its file ahead of what runs after it')

// Rows are found, hidden and switched off the way the menu does it.
const guarded = pagesFor({ when: { 'setup.input': false, 'setup.security.fingerprint': false }, checked: {}, disabled: {} }, null)
assert(!guarded.some((page) => page.id === 'setup.input'), 'a row its guard hides is not a page')
assert(!options(guarded, 'setup.security').some((option) => option.id === 'setup.security.fingerprint'), 'a row its guard hides is not an option')

const lab = withRows({
  'setup.lab': { label: 'Lab' },
  'setup.lab.bench': { label: 'Bench', when: 'false', action: 'bench' },
  'elsewhere.vpn': { label: 'VPN', parent: 'setup.security', when: 'true', action: 'vpn-setup' },
  'setup.security.quick': { label: 'Quick', alt: 'setup.security.slow', action: 'quick' },
  'setup.security.slow': { label: 'Slow', action: 'slow' }
})
assert(pagesFor(nothing, null, lab).some((page) => page.id === 'setup.lab'), 'a submenu a menu extension adds under Setup is a page')
assert(!pagesFor({ when: { 'setup.lab.bench': false }, checked: {}, disabled: {} }, null, lab).some((page) => page.id === 'setup.lab'),
  'a submenu with every row hidden is not a page')
const security = options(pagesFor(nothing, null, lab), 'setup.security').map((option) => option.id)
assert(security.includes('elsewhere.vpn'), 'a row placed under a submenu by its parent is one of its options', JSON.stringify(security))
assert(security.includes('setup.security.quick') && !security.includes('setup.security.slow'),
  'a row that stands in for another while Alt is held is not listed', JSON.stringify(security))
assert('elsewhere.vpn' in Setup.guardEntries(lab.items, lab.itemOrder), 'the guard batch asks about a row placed by its parent')

const installed = options(pagesFor({ when: {}, checked: {}, disabled: { 'install.service.tailscale': true } }, null), 'tailscale')[0]
assert(installed.installed && installed.action === '' && installed.args === null, 'a row the menu switches off has nothing to run', JSON.stringify(installed))

// A submenu the menu hides takes with it everything that is reached through it.
const fenced = withRows({ 'setup': { label: 'Setup', when: 'false' }, 'install.service': { label: 'Service', when: 'false' } })
assertDeepEqual(pagesFor({ when: { 'setup': false, 'install.service': false }, checked: {}, disabled: {} }, null, fenced).map((page) => page.id), ['layout', 'agent'],
  'a row is not offered past a submenu the menu hides')
const asked = Setup.guardEntries(shipped.items, shipped.itemOrder)
assert(['setup', 'install', 'install.service', 'agent', 'appearance'].every((id) => id in asked), 'the guard batch asks about the submenus above each row')
const nested = withRows({ 'setup': { label: 'Setup', parent: 'appearance.workspace-layout' } })
assert('appearance.workspace-layout.dwindle' in Setup.guardEntries(nested.items, nested.itemOrder),
  'a submenu noted for being above one row still has its own rows asked about')

// A batch that broke off has answered only some rows, and says so.
const broken = pagesFor({ when: { 'setup.input': true }, checked: {}, disabled: {}, partial: true }, null)
assert(broken.some((page) => page.id === 'setup.input'), 'a row whose guard was answered stands, though the batch broke off')
assert(!broken.some((page) => page.id === 'tailscale') && !options(broken, 'setup.security').some((option) => option.id === 'setup.security.fingerprint'),
  'a row whose guard went unanswered is left out rather than guessed at')

// A batch that ended early without an error has not answered everything either.
const some = { when: Object.fromEntries(Object.keys(asked).filter((id) => asked[id].when).map((id) => [id, true])), checked: {}, disabled: {} }
assert(!Setup.answeredAll(asked, some), 'a batch that left a disabled: guard unanswered is not taken for a whole one')
some.disabled = Object.fromEntries(Object.keys(asked).filter((id) => asked[id].disabled).map((id) => [id, false]))
assert(Setup.answeredAll(asked, some), 'a batch that answered every when: and disabled: guard is whole')

// The menu's route is for typing: it folds case and underscores, keeps a few
// words for itself, and runs an action it lands on.
const typed = withRows({
  'setup.region.zones_extra': { label: 'Zones', provider: 'languages' },
  'setup.region.zones-extra': { label: 'Run me', action: 'not-this' },
  'setup.elsewhere': { label: 'Elsewhere', target: 'menu' },
  'menu': { label: 'Menu' },
  'menu.row': { label: 'Row', action: 'row' }
})
const reached = pagesFor(nothing, null, typed)
assert(!options(reached, 'setup.region').some((option) => option.id === 'setup.region.zones_extra'),
  'a submenu whose route the menu would take to another row is not offered')
assert(options(reached, 'setup.region').some((option) => option.route === 'setup.region.language'), 'while one it opens as written still is')
assert(!reached.some((page) => page.id === 'setup.elsewhere'), 'a link to a name the menu keeps for itself is not a page')

assertDeepEqual(Setup.parseGuards('setup.input:w:0\nsetup.a:b:c:1\ngarbage\ninstall.service.tailscale:d:1\n'),
  { when: { 'setup.input': false }, checked: { 'setup.a:b': true }, disabled: { 'install.service.tailscale': true } },
  'guard answers are read from the end of the line, past a colon in an id')

// The tour: what it offers, and what Finish runs.
const settled = { when: {}, checked: { 'appearance.workspace-layout.dwindle': true }, disabled: { 'install.service.tailscale': true } }
const steps = Setup.tourSteps(pagesFor(settled, null))
assertDeepEqual(steps.map((step) => step.id), ['layout', 'agent', 'dictation'],
  'the tour leaves out Tailscale once installed, and a local model where none fits')
assertEqual(Setup.flatOptions(steps[1])[0].id, '', 'a step with nothing chosen yet opens on Not now')
assert(Setup.flatOptions(steps[0]).every((option) => option.id !== ''), 'a step with a current choice offers no Not now')

const recipes = [
  { id: 'small', name: 'Small', best: false, available: true, installed: false },
  { id: 'big-27b', name: 'Big', best: true, available: true, installed: false, memory_gib: 24, context: 131072, decode_tok_s: 41.6 }
]
const offered = (change) => Setup.localOffer(JSON.stringify(recipes.map((recipe) => recipe.best ? { ...recipe, ...change } : recipe)))
assertEqual(offered({}).id, 'big-27b', 'the local model on offer is the one the engine recommends')
assertEqual(offered({ installed: true }), null, 'a recommended model already set up is not offered again')
assertEqual(offered({ id: 'big; touch owned' }), null, 'a recipe whose id could not go on a command line is not offered')
assertEqual(Setup.localOffer('not json'), null, 'an unreadable listing offers nothing')

// Each flag with its value, whatever order the steps come in. A flag given
// twice, a stray word, or two words in one argument shows up as itself.
const flags = (argv) => {
  const out = []
  for (let i = 1; i < argv.length; i++) {
    const valued = argv[i].startsWith('--') && i + 1 < argv.length && !argv[i + 1].startsWith('--')
    out.push(valued ? [argv[i], argv[++i]] : [argv[i]])
  }
  return out.sort((a, b) => a[0].localeCompare(b[0]))
}

const current = { when: {}, checked: { 'appearance.workspace-layout.dwindle': true, 'setup.default.dictation.superwhisper': true }, disabled: {} }
const tour = Setup.tourSteps(pagesFor(current, offered({})))
assertDeepEqual(Setup.tourPlan(tour, {}).argv, [], 'a tour that picks nothing runs nothing')
assertDeepEqual(Setup.tourPlan(tour, { layout: 'appearance.workspace-layout.dwindle', agent: '', dictation: 'setup.default.dictation.superwhisper' }).argv, [],
  'picking what the machine already has runs nothing')
const plan = Setup.tourPlan(tour, { layout: 'appearance.workspace-layout.scrolling', agent: 'agent.harness.claude',
  dictation: 'setup.default.dictation.voxtype', 'local-ai': 'local-ai.big-27b', tailscale: 'install.service.tailscale' })
assertEqual(plan.argv[0], 'omarchy-setup-essentials', 'Finish runs one command')
assertDeepEqual(flags(plan.argv), [['--agent', 'claude'], ['--dictation', 'voxtype'], ['--layout', 'scrolling'], ['--local-ai', 'big-27b'], ['--tailscale']],
  'the command names each change, and the model by the recipe that was shown')
assertDeepEqual(plan.changes.map((change) => change.page).sort(), ['agent', 'dictation', 'layout', 'local-ai', 'tailscale'],
  'and the plan says which steps those were')

// A row from a menu extension with a command of its own.
const extended = withRows({ 'agent.harness.mine': { label: 'Mine', action: 'my-agent --start; echo done' } })
assert(options(pagesFor(nothing, null, extended), 'agent').some((option) => option.id === 'agent.harness.mine'), 'an extension row is offered on the pages')
assert(!Setup.flatOptions(Setup.tourSteps(pagesFor(nothing, null, extended))[1]).some((option) => option.id === 'agent.harness.mine'),
  'the tour leaves out a row whose command it cannot sequence')

// The keyboard cursor on a page of two groups, three columns wide.
const grid = { groups: [{ options: [{}, {}, {}, {}] }, { options: [{}, {}] }] }
assertEqual(Setup.moveCursor(grid, 3, 2, 1, 0), 2, 'the cursor stops at the end of a row')
assertEqual(Setup.moveCursor(grid, 3, 2, 0, 1), 3, 'moving down lands on the nearest option of a shorter row')
assertEqual(Setup.moveCursor(grid, 3, 3, 0, 1), 4, 'moving down crosses into the next group')
assertEqual(Setup.moveCursor(grid, 3, 5, 0, 1), 5, 'the cursor stops at the last row')

const found = (name) => (fresh[Setup.pageIndex(fresh, name)] || {}).id
assertEqual(found('security'), 'setup.security', 'a page is found by the last part of its id')
assertEqual(found('Defaults'), 'setup.default', 'a page is found by the name the rail shows')
assertEqual(Setup.pageIndex(fresh, 'nowhere'), -1, 'an unknown page is not found')
JS

# --- omarchy-setup-essentials sets the choices up in order ---

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
stubs="$work/bin"
calls="$work/calls"
mkdir -p "$stubs" "$work/home" "$work/run"

stub() {
  printf '#!/bin/bash\necho "%s $*" >>"$OMARCHY_TEST_CALLS"\nexit ${%s:-0}\n' "$1" "${2:-OMARCHY_TEST_NO_FAILURE}" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

for name in omarchy-done omarchy-notification-dismiss nm-online omarchy-install-dictation-voxtype omarchy-agent-local; do
  stub "$name"
done
stub omarchy-hyprland-workspace-layout-default OMARCHY_TEST_LAYOUT_STATUS
stub omarchy-install-service-tailscale OMARCHY_TEST_TAILSCALE_STATUS
printf '#!/bin/bash\necho "$1"\n' >"$stubs/omarchy-i18n"
printf '#!/bin/bash\necho "${OMARCHY_TEST_DICTATION:-voxtype}"\n' >"$stubs/omarchy-default-dictation"

# The terminal runs what it is handed, as the real one does.
cat >"$stubs/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
echo "terminal: $*" >>"$OMARCHY_TEST_CALLS"
bash -c "$*"
SH

# Installing an agent ends however the agent's own session did.
cat >"$stubs/omarchy-default-agent" <<'SH'
#!/bin/bash
echo "omarchy-default-agent $*" >>"$OMARCHY_TEST_CALLS"
case "$1" in
  --install) exit "${OMARCHY_TEST_AGENT_SESSION:-0}" ;;
  --installed) exit "${OMARCHY_TEST_AGENT_MISSING:-0}" ;;
esac
SH
chmod +x "$stubs"/*

# In a session of its own: essentials waits for a key on the terminal before
# an agent takes it over, and must find none here rather than the one the suite
# was started from.
essentials() {
  : >"$calls"
  HOME="$work/home" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_TEST_CALLS="$calls" setsid -w "$@" >"$work/output" 2>&1
}

installs() {
  grep -E '^(omarchy-install-dictation-voxtype|omarchy-install-service-tailscale|omarchy-agent-local|omarchy-default-agent --install)( |$)' "$calls" | tr '\n' '|'
}

essentials omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai big-27b --agent claude ||
  fail "what the tour picked is set up" "$(<"$work/output")"
[[ $(grep -c '^omarchy-hyprland-workspace-layout-default scrolling$' "$calls") == "1" ]] || fail "the layout is set once" "$(<"$calls")"
[[ $(sed -n '1p' "$calls") == "omarchy-hyprland-workspace-layout-default scrolling" ]] || fail "the layout is set before any terminal opens" "$(<"$calls")"
[[ $(grep -c '^terminal: ' "$calls") == "1" ]] || fail "the installs share one terminal" "$(<"$calls")"
[[ $(installs) == "omarchy-install-dictation-voxtype |omarchy-install-service-tailscale |omarchy-agent-local use --detach big-27b|omarchy-default-agent --install claude|" ]] ||
  fail "the installs run one after another, the agent last, and the model by its recipe" "$(installs)"
grep -Fxq 'omarchy-done mark agent-setup-invitation' "$calls" || fail "a tour that picked an agent answers first run's invitation to" "$(<"$calls")"
pass "the layout is set at once, and the installs run in one terminal with the agent last"

essentials omarchy-setup-essentials --layout floating || fail "a layout alone is set" "$(<"$work/output")"
if grep -q '^terminal: ' "$calls"; then
  fail "a layout alone opens no terminal" "$(<"$calls")"
fi
pass "a layout alone opens no terminal"

if OMARCHY_TEST_TAILSCALE_STATUS=1 essentials omarchy-setup-essentials --tailscale --agent claude; then
  fail "a failed install fails the run" "$(<"$work/output")"
fi
grep -Fxq 'omarchy-default-agent --install claude' "$calls" || fail "one failed install does not stop the ones after it" "$(<"$calls")"
[[ $(grep -c 'Could not set up: Tailscale$' "$work/output") == "2" ]] ||
  fail "a failed install is named before the agent takes the terminal, and again at the end" "$(<"$work/output")"
pass "one failed install is named and does not stop the others"

OMARCHY_TEST_DICTATION=superwhisper essentials omarchy-setup-essentials --dictation voxtype ||
  fail "an install that was turned down is not a failure" "$(<"$work/output")"
grep -Fq 'Left as it was: dictation' "$work/output" || fail "but it is not passed off as set up" "$(<"$work/output")"
pass "a dictation install that was turned down is reported as left alone"

OMARCHY_TEST_AGENT_SESSION=130 essentials omarchy-setup-essentials --agent claude ||
  fail "an agent left with Ctrl+C was still set up" "$(<"$work/output")"
if OMARCHY_TEST_AGENT_MISSING=1 essentials omarchy-setup-essentials --agent claude; then
  fail "an agent that is not there afterwards was not set up" "$(<"$work/output")"
fi
grep -Fq 'Could not set up: claude' "$work/output" || fail "an agent that did not install is named" "$(<"$work/output")"
pass "an agent's install is judged by the agent being there, not by how its session ended"

if OMARCHY_TEST_LAYOUT_STATUS=1 essentials omarchy-setup-essentials --layout scrolling --tailscale; then
  fail "a layout that could not be set fails the run" "$(<"$work/output")"
fi
[[ $(grep -c '^omarchy-hyprland-workspace-layout-default scrolling$' "$calls") == "2" ]] ||
  fail "a layout that could not be set is tried again in the terminal" "$(<"$calls")"
grep -Fq 'Could not set up: the workspace layout' "$work/output" || fail "and is named there" "$(<"$work/output")"
pass "a layout that could not be set is carried into the terminal, where it shows"

refused() {
  if essentials omarchy-setup-essentials "$@"; then
    fail "a value that is not one is refused: $*"
  fi
  [[ ! -s $calls ]] || fail "a refused value runs nothing: $*" "$(<"$calls")"
}

refused --agent 'claude; touch owned'
refused --local-ai 'big; touch owned'
refused --layout sideways
pass "a name, a recipe or a layout that is not one is refused before anything runs"

# --- omarchy-launch-setup --wait answers for its own request, and only when it was closed ---

# The live test below covers a tour that opens and is closed. These are the
# turns a real shell cannot be asked to take. The stub is a Setup that answers
# for one request from a script: each line is said once and the last from then
# on, `silence` says nothing, and `closed` leaves the steps named after it and
# the marker, as Setup does when it closes, then is gone.
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
# Every pause the launcher takes is a second on its clock, so its deadlines
# come round without anyone waiting for them.
printf 'sleep() { SECONDS=$((SECONDS + 1)); }\n' >"$work/clock"

launch() {
  printf '%s\n' "$@" >"$work/answers"
  rm -f "$work/cancelled"
  # Under a limit of its own: a wait that never ends must fail, not hang the suite.
  BASH_ENV="$work/clock" XDG_RUNTIME_DIR="$work/run" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_TEST_DIR="$work" \
    timeout 20 omarchy-launch-setup welcome --wait >"$work/picked" 2>"$work/output"
}

launch opening shown shown "closed layout agent" || fail "--wait returns once its Setup has been closed" "$(<"$work/output")"
[[ $(tr '\n' ' ' <"$work/picked") == "agent layout " ]] || fail "--wait says which steps the tour set off" "$(<"$work/picked")"
(( $(<"$work/expires") > EPOCHSECONDS )) || fail "a wait says when it will stop waiting" "$(<"$work/expires")"
launch opening shown silence silence closed || fail "a question the shell did not answer is asked again" "$(<"$work/output")"
[[ ! -s $work/picked ]] || fail "a tour that picked nothing says nothing" "$(<"$work/picked")"
if launch opening shown unknown; then
  fail "a Setup that went away without being closed is not one that was closed"
fi
if launch opening other; then
  fail "a Setup opened again for someone else is not this request's"
fi
[[ ! -e $work/cancelled ]] || fail "and is left open for whoever it is for" "$(<"$work/cancelled")"
if launch opening; then
  fail "a Setup that never reached the screen fails"
fi
[[ $(<"$work/cancelled") == "$(<"$work/reply")" ]] || fail "a Setup that never reached the screen is closed again, by its request"
if OMARCHY_TEST_SUMMON=unknown launch opening shown closed; then
  fail "a Setup the shell could not open fails"
fi
[[ -z $(ls -A "$work/run") ]] || fail "--wait leaves nothing behind" "$(ls -A "$work/run")"
pass "--wait answers for its own request: closed, never shown, gone, replaced or refused"

# --- Setup opens in a running shell ---

require_quickshell "Setup opening in a running shell"

# The scratch shell brings its own cleanup, which takes the place of the one above.
rm -rf "$work"
setup_scratch_shell
# Nothing the tour could run may reach the real session.
for name in omarchy-setup-essentials omarchy-launch-floating-terminal-with-presentation omarchy-agent-local; do
  printf '#!/bin/bash\nexit 0\n' >"$SCRATCH_BIN/$name"
  chmod +x "$SCRATCH_BIN/$name"
done
start_scratch_shell
wait_scratch_shell

# Waits for a tour, and until whichever Setup is open says it is on screen:
# mapped is not yet shown, since the window waits for its scale to reveal.
open_tour() {
  local shown=""

  (scratch_exec timeout 30 "$ROOT/bin/omarchy-launch-setup" welcome --wait) >"$SCRATCH_DIR/wait.log" 2>&1 &
  waiter=$!
  if ! wait_scratch_layer omarchy-setup mapped; then
    sed -n '1,120p' "$SCRATCH_LOG" >&2
    fail "the welcome tour opens in a running shell"
  fi
  for _ in {1..100}; do
    shown=$(scratch_ipc shell call omarchy.setup state "{}" 2>/dev/null || true)
    [[ $shown != "shown" ]] || break
    sleep 0.05
  done
  [[ $shown == "shown" ]] || fail "the tour says so once it is on screen" "$shown"
  kill -0 "$waiter" 2>/dev/null || fail "--wait holds on while the tour is open" "$(<"$SCRATCH_DIR/wait.log")"
}

open_tour
scratch_ipc shell hide omarchy.setup >/dev/null
wait_scratch_layer omarchy-setup absent || fail "hiding Setup unmaps it"
wait "$waiter" || fail "--wait returns once the tour is closed" "$(<"$SCRATCH_DIR/wait.log")"
pass "the welcome tour opens in a running shell, and --wait returns when it is closed"

# Setup opened again while a tour is waited on: the tour was seen and is over,
# and the wait must not carry on for a Setup that is no longer its own.
open_tour
scratch_ipc shell summon omarchy.setup '{"page":"security"}' >/dev/null
wait "$waiter" || fail "--wait returns once its tour has given way to another opening" "$(<"$SCRATCH_DIR/wait.log")"
[[ $(scratch_layer_state omarchy-setup) == "mapped" ]] || fail "the Setup opened in its place stays open"
scratch_ipc shell hide omarchy.setup >/dev/null
wait_scratch_layer omarchy-setup absent || fail "hiding Setup unmaps it"
pass "a tour that gives way to another opening answers its own wait and no other"

# A request can sit queued while the plugin loads. One that arrives after its
# caller has stopped waiting is dropped rather than shown to nobody.
scratch_ipc shell summon omarchy.setup '{"mode":"tour","expires":1}' >/dev/null
sleep 0.5
[[ $(scratch_layer_state omarchy-setup) == "absent" ]] || fail "a request whose caller has stopped waiting is not opened"
[[ $(scratch_ipc shell call omarchy.setup state "{}" 2>/dev/null || true) != "shown" ]] || fail "and leaves nothing open behind it"
pass "a request that has outlived its caller is dropped"

problems=$(grep -F 'plugins/setup' "$SCRATCH_LOG" || true)
[[ -z $problems ]] || fail "Setup opens without QML warnings" "$problems"
pass "Setup opens without QML warnings"
