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
  "Authorize running '/usr/bin/true'",
  'polkit shortens the standard pkexec message'
)
assertEqual(
  polkit.authorizationLabel('Authentication is required to change system settings'),
  'Authentication is required to change system settings',
  'polkit preserves custom authorization messages'
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
assertEqual(polkit.promptProgram(pacman), '/usr/bin/pacman', 'a pkexec prompt names the program it runs, which a label never hides')

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
    polkitAgent: { isActive: true, flow: { cancelAuthenticationRequest: () => { cancelled += 1 } } },
    closing: false,
    dismissed: false,
    closeTimer: { stop: () => {}, restart: () => {} },
    driveDevice: '',
    driveLabel: '',
    driveQueue: [],
    submitted: true,
    currentMessage: 'auth',
    currentLabel: 'label',
    currentPrompt: 'Password:',
    currentSupplementary: '',
    responseRequired: true,
    responseVisible: false,
    failed: false,
    errorFlash: false,
    passwordInput: { text: 'secret' },
    I18n: { t: key => key === 'polkit.unlockDrive' ? 'Unlock %1' : key },
    refreshLidState: () => {},
    syncFromFlow: () => {},
    triggerFailureFeedback: () => {},
    refocus: () => {},
    Qt: { callLater: () => {} },
    get cancelledCount() { return cancelled },
  }
  scope.root = scope
  vm.createContext(scope)
  vm.runInContext([
    extractFn('resetSnapshot'),
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
JS
