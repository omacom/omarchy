#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const polkit = requireFromRoot('shell/plugins/polkit/PolkitModel.js')

assert(polkit.promptLooksFingerprint('Swipe your finger'), 'polkit detects fingerprint prompts')
assert(polkit.promptLooksFingerprint('fprintd verification'), 'polkit detects fprint prompts')
assert(!polkit.promptLooksFingerprint('Password:'), 'polkit ignores password prompts')

assertEqual(
  polkit.authorizationLabel("Authentication is needed to run `/usr/bin/true' as the super user"),
  'Authorize running command',
  'polkit uses a heading for standard pkexec prompts while the command goes on line two'
)
assertEqual(
  polkit.authorizationLabel("Authentication is needed to run `/usr/bin/true' as the super user", undefined, 'Claude'),
  'Authorize Claude to run command',
  'polkit names the agent in the heading for pkexec prompts'
)
assertEqual(
  polkit.authorizationLabel("Authentication is needed to run `/usr/bin/true' as the super user", undefined, ''),
  'Authorize running command',
  'polkit falls back when no agent name is given'
)
assertEqual(
  polkit.authorizationLabel('Authentication is required to format Crucial X10 Pro (/dev/sda)'),
  'Authorize formatting of Crucial X10 Pro (/dev/sda)',
  'polkit says which drive udisks is formatting'
)
assertEqual(
  polkit.authorizationLabel('Authentication is required to change system settings'),
  'Authentication is required to change system settings',
  'polkit preserves custom authorization messages'
)
const multilineSh = "Authentication is needed to run `/usr/bin/sh -c\nfor f in /sys/device ... [ -w \"$f\" ] && echo 1 > \"$f\"\ndone\n' as the super user"
assertEqual(
  polkit.authorizationLabel(multilineSh),
  'Authorize running command',
  'polkit keeps a single-line heading for multi-line pkexec commands'
)
assertEqual(
  polkit.authorizationLabel(multilineSh, undefined, 'Antigravity'),
  'Authorize Antigravity to run command',
  'polkit names the agent in the heading for multi-line pkexec commands'
)
assertEqual(
  polkit.authorizationLabel("Authentication is required\nto update\tfirmware\n"),
  'Authentication is required to update firmware',
  'polkit collapses embedded newlines in custom authorization messages'
)
assertEqual(
  polkit.promptProgram(multilineSh),
  "/usr/bin/sh -c\nfor f in /sys/device ... [ -w \"$f\" ] && echo 1 > \"$f\"\ndone\n",
  'promptProgram preserves raw newlines so requester matching stays exact'
)

// A command that knows what its pkexec is for labels the prompt for that
// program once, within its minute; any other prompt keeps its own.
const pacman = "Authentication is needed to run `/usr/bin/pacman' as the super user"
const expected = { program: '/usr/bin/pacman', label: 'Authorize installing ChatGPT Desktop', until: 1000 }
assertEqual(polkit.expectedLabel(pacman, expected, 500), 'Authorize installing ChatGPT Desktop', 'a prompt for the program a command expected says what it asked')
assertEqual(polkit.expectedLabel("Authentication is needed to run `/usr/bin/true' as the super user", expected, 500), '', 'a prompt for another program keeps its own label')
assertEqual(polkit.expectedLabel('Authentication is required to change system settings', expected, 500), '', 'a prompt that names no program keeps its own label')
assertEqual(polkit.expectedLabel(pacman, expected, 1001), '', 'a label not used within its minute is dropped')
assertEqual(polkit.expectedLabel(pacman, null, 500), '', 'with nothing expected a prompt keeps its own label')
const longLine = '/usr/bin/pacman -S --noconfirm valkey redis-cli sidekiq-dashboard postgresql-libs'
const cutPrompt = "Authentication is needed to run `" + longLine.slice(0, 38) + ' ... ' + longLine.slice(-37) + "' as the super user"
assertEqual(polkit.expectedLabel(cutPrompt, { program: longLine, label: 'Claude needs to install Valkey', until: 1000 }, 500), 'Claude needs to install Valkey', 'a long command line expected whole matches the prompt that cuts it')
assertEqual(polkit.expectedLabel("Authentication is needed to run `/usr/bin/pacman -S valkey' as the super user", { program: 'pacman -S valkey', label: 'Install Valkey', until: 1000 }, 500), 'Install Valkey', 'a bare program name matches the resolved path in the prompt')
assertEqual(polkit.expectedLabel("Authentication is needed to run `/usr/bin/unpacman -S valkey' as the super user", { program: 'pacman -S valkey', label: 'Install Valkey', until: 1000 }, 500), '', 'a bare program name does not match a different program suffix')
assertEqual(polkit.expectedLabel("Authentication is needed to run `/usr/bin/echo /usr/bin/pacman -S valkey' as the super user", { program: 'pacman -S valkey', label: 'Install Valkey', until: 1000 }, 500), '', 'a bare program name does not match when appearing inside arguments')
assertEqual(polkit.promptProgram(pacman), '/usr/bin/pacman', 'a pkexec prompt names the program it runs, which a label never hides')
assertEqual(polkit.promptProgram("Authentication is needed to run `/usr/bin/sh -c echo it's' as the super user"), "/usr/bin/sh -c echo it's", 'a command line holding a quote is read up to the quote that closes it')
assertEqual(JSON.stringify(polkit.parseRequester('claude\tClaude\t0\n')), JSON.stringify({ mark: 'claude', name: 'Claude', light: false }), 'parseRequester reads mark, display name, and light flag')
assertEqual(JSON.stringify(polkit.parseRequester('codex\tCodex\t1\n')), JSON.stringify({ mark: 'codex', name: 'Codex', light: true }), 'parseRequester preserves the light-variant flag')
assertEqual(polkit.parseRequester('../../x\tBad\t0'), null, 'a mark is a file name in the agents plugin, never a path')
assertEqual(polkit.parseRequester(''), null, 'empty requester output yields null')

assert(
  polkit.fingerprintConfiguredFromPamConfig(`
# comment
auth sufficient pam_fprintd.so
auth include system-auth
`),
  'polkit detects fingerprint in a PAM config'
)
assert(
  polkit.fingerprintConfiguredFromPamConfig(`
auth [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth sufficient pam_fprintd.so
auth required pam_unix.so
`),
  'polkit detects fingerprint even behind a clamshell gate'
)
assert(
  !polkit.fingerprintConfiguredFromPamConfig(`
account include system-auth
auth include system-auth
auth required pam_unix.so
`),
  'polkit reports no fingerprint when pam_fprintd is absent'
)

// Auth completion, drive unlock completion, and Escape must drop the
// exclusive-focus overlay immediately instead of holding it behind a timer.
const fs = require('fs')
const vm = require('vm')
const agentSource = fs.readFileSync(path.join(root, 'shell/plugins/polkit/PolkitAgent.qml'), 'utf8')
const dialogExpr = agentSource.match(/readonly property bool dialogVisible:\s*([^\n]+)/)[1]
const labelProgramExpr = agentSource.match(/readonly property string labelProgram:\s*([^\n]+)/)[1]
const extractFn = (name, required = true) => {
  const m = agentSource.match(new RegExp(`^( *)function ${name}\\([^)]*\\)\\s*\\{([\\s\\S]*?)\\n\\1\\}`, 'm'))
  if (!m) {
    if (required) throw new Error('missing function ' + name)
    return ''
  }
  return m[0]
}
const activeHandler = agentSource.match(/onIsActiveChanged:\s*\{([\s\S]*?)\n    \}/)[1]
const succeededBody = agentSource.match(/function onAuthenticationSucceeded\(\)\s*\{([\s\S]*?)\n    \}/)[0]
const cancelledBody = agentSource.match(/function onAuthenticationRequestCancelled\(\)\s*\{([\s\S]*?)\n    \}/)[0]

const makeScope = () => {
  let cancelled = 0
  const scope = {
    polkitAgent: { isActive: true, flow: { message: '', cancelAuthenticationRequest: () => { cancelled += 1 } } },
    closing: false,
    dismissed: false,
    closeTimer: { stop: () => {}, restart: () => {} },
    requesterTimeout: { stop: () => {}, restart: () => {} },
    driveDevice: '',
    driveLabel: '',
    driveQueue: [],
    submitted: true,
    cancelRevealed: false,
    pointerGate: { reset: () => {} },
    currentMessage: 'auth',
    currentLabel: 'label',
    currentAgent: { mark: 'claude', name: 'Claude', light: false },
    requesterPending: false,
    requestSerial: 0,
    expected: null,
    PolkitModel: polkit,
    findRequester: () => {},
    currentPrompt: 'Password:',
    currentSupplementary: '',
    responseRequired: true,
    responseVisible: false,
    failed: false,
    errorFlash: false,
    passwordInput: { text: 'secret' },
    I18n: { t: key => key === 'polkit.unlockDrive' ? 'Unlock %1' : key },
    refreshLidState: () => {},
    triggerFailureFeedback: () => {},
    refocus: () => {},
    Qt: { callLater: () => {} },
    get cancelledCount() { return cancelled },
  }
  scope.root = scope
  vm.createContext(scope)
  vm.runInContext([
    extractFn('authorizationLabel'),
    extractFn('hideCancel'),
    extractFn('clearRequester'),
    extractFn('resetSnapshot'),
    extractFn('syncFromFlow'),
    extractFn('nextDrive'),
    extractFn('beginDrive'),
    extractFn('driveChecked'),
    extractFn('dismissPolkit', false),
    extractFn('beginFlow'),
    extractFn('cancelRequest'),
    succeededBody,
    cancelledBody,
    `function onAgentActiveChanged(isActive) { ${activeHandler} }`,
  ].filter(Boolean).join('\n'), scope)
  scope.isDialogVisible = () => vm.runInContext(`(${dialogExpr})`, scope)
  scope.getLabelProgram = () => vm.runInContext(`(${labelProgramExpr})`, scope)
  return scope
}

{
  const s = makeScope()
  assert(s.isDialogVisible(), 'polkit dialog is visible while active')
  s.cancelRequest()
  assert(!s.isDialogVisible(), 'cancelling polkit hides the overlay immediately even while polkitd is still active')
  assertEqual(s.cancelledCount, 1, 'cancelling polkit forwards cancellation to the flow')
  s.beginFlow()
  assert(s.isDialogVisible(), 'a subsequent polkit request shows the dialog again')
}
{
  // Quickshell sets isActive before emitting authenticationRequestStarted;
  // syncing on isActive must not consume expected before beginFlow takes it.
  const s = makeScope()
  s.currentLabel = ''
  s.polkitAgent.flow.message = pacman
  s.expected = { program: '/usr/bin/pacman', label: 'Install Valkey', until: Date.now() + 60000 }
  s.onAgentActiveChanged(true)
  s.beginFlow()
  assertEqual(s.currentLabel, 'Install Valkey', 'beginFlow preserves an expected label even after isActive fires first')
  assertEqual(s.expected, null, 'consuming an expected label clears it for subsequent requests')
}
{
  const s = makeScope()
  s.onAuthenticationSucceeded()
  assert(!s.isDialogVisible(), 'successful polkit auth hides the overlay immediately')
}
{
  const s = makeScope()
  s.onAuthenticationRequestCancelled()
  assert(!s.isDialogVisible(), 'remote polkit cancellation hides the overlay immediately')
}
{
  // Completing polkit with a queued drive advances to the drive prompt right
  // away and keeps it intact when polkitd finishes tearing down its flow.
  const s = makeScope()
  s.driveQueue = [{ device: '/dev/sdb1', label: 'Backup' }]
  s.cancelRequest()
  assert(s.isDialogVisible(), 'queued drive takes over immediately after polkit is cancelled')
  assertEqual(s.driveDevice, '/dev/sdb1', 'queued drive becomes active right away')
  s.onAuthenticationRequestCancelled()
  s.polkitAgent.isActive = false
  s.onAgentActiveChanged(false)
  assertEqual(s.driveDevice, '/dev/sdb1', 'delayed polkit teardown does not clear the active drive prompt')
  assertEqual(s.currentLabel, 'Unlock Backup', 'delayed polkit teardown preserves the drive label')
  s.driveChecked('/dev/sdb1', 0, '')
  assert(!s.isDialogVisible(), 'successful drive unlock hides the overlay immediately')
}
{
  // Multi-line labels and commands collapse to a single line in the pill,
  // and whitespace-only messages fall back to the default prompt.
  const s = makeScope()
  s.currentLabel = 'Apply\nGPU   workaround'
  s.currentMessage = multilineSh
  assertEqual(s.authorizationLabel(multilineSh), 'Apply GPU workaround', 'agent authorizationLabel flattens multi-line custom labels')
  assertEqual(
    s.getLabelProgram(),
    '/usr/bin/sh -c for f in /sys/device ... [ -w "$f" ] && echo 1 > "$f" done',
    'agent labelProgram flattens multi-line commands for display'
  )
  s.currentLabel = ''
  assertEqual(
    s.getLabelProgram(),
    '/usr/bin/sh -c for f in /sys/device ... [ -w "$f" ] && echo 1 > "$f" done',
    'unlabelled pkexec prompt still shows its command on the second line'
  )
  s.currentMessage = 'Authentication is required to format Crucial X10 Pro (/dev/sda)'
  assertEqual(s.getLabelProgram(), '', 'non-pkexec prompts leave the second line empty')
  s.currentLabel = '   \n  '
  assertEqual(s.authorizationLabel('  \n\t '), 'polkit.authenticationNeeded', 'whitespace-only label and message fall back to default authentication prompt')
}
{
  // Revealing the Cancel pill on one prompt never leaks into the next prompt
  // (whether advancing to a queued drive or preempting a drive with polkit).
  const s = makeScope()
  s.cancelRevealed = true
  s.driveQueue = [{ device: '/dev/sdb1', label: 'Backup' }]
  s.cancelRequest()
  assertEqual(s.cancelRevealed, false, 'cancelling polkit resets cancelRevealed before advancing to a queued drive')
  s.cancelRevealed = true
  s.beginFlow()
  assertEqual(s.cancelRevealed, false, 'preempting an active drive prompt with polkit resets cancelRevealed')
}
JS

# requester.py finds the agent a pkexec prompt comes from in OMARCHY_PROC_ROOT:
# this user's pkexec running the prompt's command line, then up its parents.
uid=$(id -u)
proc_dir=$(mktemp -d)
trap 'rm -rf "$proc_dir"' EXIT

fake_process() { # pid ppid comm uid [arguments...]
  local pid=$1 ppid=$2 comm=$3 owner=$4
  shift 4
  mkdir -p "$proc_dir/$pid"
  printf '%s\n' "$comm" >"$proc_dir/$pid/comm"
  printf '%s (%s) S %s 0 0\n' "$pid" "$comm" "$ppid" >"$proc_dir/$pid/stat"
  printf 'Name:\t%s\nUid:\t%s\t0\t0\t0\n' "$comm" "$owner" >"$proc_dir/$pid/status"
  printf '%s\0' "$comm" "$@" >"$proc_dir/$pid/cmdline"
  : >"$proc_dir/$pid/environ"
}

requester() {
  OMARCHY_PROC_ROOT="$proc_dir" python3 "$ROOT/shell/plugins/polkit/requester.py" "$1"
}

long=(/usr/bin/pacman -S --noconfirm valkey redis-cli sidekiq-dashboard postgresql-libs)
fake_process 100 1 claude "$uid"
fake_process 101 100 bash "$uid"
fake_process 102 101 pkexec "$uid" --disable-internal-agent "${long[@]}"
shown="${long[*]}"
shown="${shown:0:38} ... ${shown: -37}"
[[ $(requester "$shown") == $'claude\tClaude\t0' ]] || fail "polkit names the agent a pkexec runs under, its command line cut as the prompt cuts it"
pass "polkit names the agent a pkexec runs under, its command line cut as the prompt cuts it"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 foot "$uid"
fake_process 101 100 bash "$uid"
fake_process 102 101 pkexec "$uid" /usr/bin/true
[[ -z $(requester /usr/bin/true) ]] || fail "polkit names no agent for a pkexec from a terminal"
pass "polkit names no agent for a pkexec from a terminal"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 claude "$uid"
fake_process 101 100 pkexec "$uid" /usr/bin/pacman -Syu
[[ -z $(requester "/usr/bin/rm -rf /srv") ]] || fail "polkit names no agent when no pkexec runs the prompt's command line"
pass "polkit names no agent when no pkexec runs the prompt's command line"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 node "$uid"
fake_process 101 100 bash "$uid"
printf 'PATH=/usr/bin\0CLAUDECODE=1\0' >"$proc_dir/101/environ"
fake_process 102 101 pkexec "$uid" true
[[ $(requester /usr/local/bin/true) == $'claude\tClaude\t0' ]] || fail "polkit knows Claude Code by its environment, and a program given by name by the end of the line"
pass "polkit knows Claude Code by its environment, and a program given by name by the end of the line"
[[ -z $(requester "/usr/bin/echo /usr/local/bin/true") ]] || fail "polkit does not match a bare program name when it appears in arguments"
pass "polkit does not match a bare program name when it appears in arguments"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 node "$uid" /usr/bin/copilot --stdio
fake_process 101 100 pkexec "$uid" -- /usr/bin/true
[[ $(requester /usr/bin/true) == $'copilot\tCopilot\t1' ]] || fail "polkit recognizes interpreter-wrapped agents and pkexec -- separator"
pass "polkit recognizes interpreter-wrapped agents and pkexec -- separator"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 bash "$uid"
printf 'ANTIGRAVITY_AGENT=1\0' >"$proc_dir/100/environ"
fake_process 101 100 pkexec "$uid" /usr/bin/true
[[ $(requester /usr/bin/true) == $'agy\tAntigravity\t1' ]] || fail "polkit recognizes Antigravity from its environment"
pass "polkit recognizes Antigravity from its environment"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 claude "$uid"
fake_process 101 100 pkexec "$uid" /usr/bin/true
fake_process 200 1 codex "$uid"
fake_process 201 200 pkexec "$uid" /usr/bin/pacman -Syu
fake_process 300 1 grok 4242
fake_process 301 300 pkexec 4242 /usr/bin/pacman -Syu
[[ $(requester "/usr/bin/pacman -Syu") == $'codex\tCodex\t1' ]] || fail "polkit picks the pkexec that runs the prompt's command line, of this user"
pass "polkit picks the pkexec that runs the prompt's command line, of this user"

rm -rf "${proc_dir:?}"/*
fake_process 100 1 claude "$uid"
fake_process 101 100 pkexec "$uid" /usr/bin/true
fake_process 200 1 foot "$uid"
fake_process 201 200 pkexec "$uid" /usr/bin/true
[[ -z $(requester /usr/bin/true) ]] || fail "polkit names no agent when two waiting pkexecs disagree"
pass "polkit names no agent when two waiting pkexecs disagree"

rm -rf "${proc_dir:?}"/*
multiline_script=$'for f in /sys/devices/system/cpu/cpu*/cpufreq/boost; do\n  [ -w "$f" ] && echo 1 > "$f"\ndone'
fake_process 100 1 agy "$uid"
fake_process 101 100 pkexec "$uid" /usr/bin/sh -c "$multiline_script"
multiline_raw="/usr/bin/sh -c $multiline_script"
multiline_shown="${multiline_raw:0:38} ... ${multiline_raw: -37}"
[[ $(requester "$multiline_shown") == $'agy\tAntigravity\t1' ]] || fail "polkit still recognizes the agent behind a multi-line pkexec command"
pass "polkit still recognizes the agent behind a multi-line pkexec command"
