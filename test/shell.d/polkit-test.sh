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

assertEqual(
  JSON.stringify(polkit.passiveAuthModules(`
auth [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2
# auth sufficient pam_fprintd.so
auth sufficient pam_fprintd.so max-tries=3 timeout=10
auth required pam_unix.so
`)),
  JSON.stringify(['security-key', 'fingerprint']),
  'polkit lists the hardware auth modules in stack order'
)
assert(
  polkit.securityKeyConfiguredFromPamConfig('auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2'),
  'polkit detects a security key in a PAM config'
)
assert(
  !polkit.securityKeyConfiguredFromPamConfig('# auth sufficient pam_u2f.so\nauth required pam_unix.so'),
  'polkit ignores a commented-out pam_u2f'
)
assertEqual(
  JSON.stringify(polkit.securityKeyCuesFromPamConfig(`
auth sufficient pam_u2f.so cue [cue_prompt=Tap the [token\\]] authfile=/etc/fido2/fido2
auth sufficient pam_u2f.so cue cue_prompt=Tap!
# auth sufficient pam_u2f.so cue cue_prompt=Ignored
auth required pam_unix.so
`)),
  JSON.stringify(['Tap the [token]', 'Tap!']),
  "polkit reads pam_u2f's cue_prompt, bare or in brackets"
)
assertEqual(
  JSON.stringify(polkit.securityKeyCuesFromPamConfig('auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2')),
  JSON.stringify([]),
  'polkit reads no cue_prompt when pam_u2f uses its default cue'
)
assertEqual(
  JSON.stringify(polkit.securityKeyCuesFromPamConfig(`
auth [success=done default=ignore] pam_u2f.so cue [cue_prompt=Tap\\\\] now] [prompt=Insert it cue_prompt=Nope] # cue_prompt=Comment
auth sufficient pam_u2f.so cue cue_prompt=Tap\u00a0it
`)),
  JSON.stringify(['Tap\\] now', 'Tap\u00a0it']),
  'polkit splits pam_u2f arguments the way Linux-PAM does'
)

assert(polkit.messageLooksSecurityKey('Please touch the device.'), 'polkit detects the pam_u2f cue')
assert(polkit.messageLooksSecurityKey('Please touch the FIDO authenticator.'), 'polkit detects the newer pam_u2f cue')
assert(!polkit.messageLooksSecurityKey('Touch the fingerprint sensor'), 'polkit keeps fingerprint cues out of security key mode')

assertEqual(polkit.passwordPlaceholder('Password: '), 'Enter password', 'polkit keeps its own label for the password')
assertEqual(polkit.passwordPlaceholder('Please enter the PIN:'), 'Please enter the PIN', "polkit shows PAM's PIN prompt")
assertEqual(
  polkit.passwordPlaceholder('Password:', (key, english) => key === 'polkit.enterPassword' ? 'Passwort eingeben' : english),
  'Passwort eingeben',
  'polkit translates its password label'
)

// Every combination of the dialog's flags against a range of PAM messages.
const flags = ['dialogVisible', 'responseRequired', 'submitted', 'errorFlash', 'securityKeyConfigured', 'securityKeyFirst', 'fingerprintConfigured', 'laptopClosed']
const messages = ['', 'Please touch the device.', 'Please touch the FIDO authenticator.', 'Place your finger on the reader', 'Swipe your finger', 'Password:', 'Please enter the PIN:']
const states = []
for (let bits = 0; bits < 1 << flags.length; bits++) {
  const s = {}
  flags.forEach((flag, i) => { s[flag] = !!(bits & (1 << i)) })
  for (const supplementary of messages) states.push({ ...s, supplementary })
}
const firstState = (predicate) => JSON.stringify(states.find(predicate))

assert(
  !states.some(s => s.responseRequired && (polkit.securityKeyMode(s) || polkit.fingerprintMode(s))),
  'polkit never hides a prompt PAM is waiting on',
  firstState(s => s.responseRequired && (polkit.securityKeyMode(s) || polkit.fingerprintMode(s)))
)
assert(
  !states.some(s => polkit.securityKeyMode(s) && polkit.fingerprintMode(s)),
  'polkit never shows the security key and the fingerprint together',
  firstState(s => polkit.securityKeyMode(s) && polkit.fingerprintMode(s))
)
const fingerprintBefore = s => s.fingerprintConfigured && !s.laptopClosed && s.dialogVisible && !s.responseRequired && !s.submitted && !s.errorFlash
const withoutKey = s => !s.securityKeyConfigured && !polkit.messageLooksSecurityKey(s.supplementary)
assert(
  states.filter(withoutKey).every(s => !polkit.securityKeyMode(s) && polkit.fingerprintMode(s) === fingerprintBefore(s)),
  'polkit keeps the fingerprint behavior unchanged without a security key',
  firstState(s => withoutKey(s) && (polkit.securityKeyMode(s) || polkit.fingerprintMode(s) !== fingerprintBefore(s)))
)
assert(
  states.filter(s => polkit.waitingOnHardware(s) && polkit.messageLooksSecurityKey(s.supplementary)).every(polkit.securityKeyMode),
  'polkit shows the security key while pam_u2f cues a touch'
)
assert(
  polkit.securityKeyMode({ dialogVisible: true, securityKeyConfigured: true, securityKeyFirst: true, fingerprintConfigured: true }),
  'polkit shows the security key before its cue when pam_u2f comes first'
)
assert(
  polkit.fingerprintMode({ dialogVisible: true, securityKeyConfigured: true, fingerprintConfigured: true }),
  'polkit shows the fingerprint while pam_fprintd comes first'
)
assert(
  polkit.securityKeyMode({ dialogVisible: true, securityKeyConfigured: true, fingerprintConfigured: true, laptopClosed: true }),
  'polkit shows the security key when the lid gate skips pam_fprintd'
)
const french = { dialogVisible: true, securityKeyConfigured: true, securityKeyFirst: true, fingerprintConfigured: true, supplementary: "Placez votre doigt sur le lecteur d'empreintes digitales" }
assert(
  polkit.fingerprintMode(french) && !polkit.securityKeyMode(french),
  'polkit shows the fingerprint when pam_fprintd speaks after pam_u2f, in any language'
)
assert(
  polkit.securityKeyMode({ dialogVisible: true, securityKeyConfigured: true, supplementary: 'Tap the token' }),
  'polkit shows the security key for a custom cue when there is no reader'
)
const customCue = { dialogVisible: true, securityKeyConfigured: true, securityKeyFirst: true, fingerprintConfigured: true, securityKeyCues: ['Tap the token'], supplementary: 'Tap the token' }
assert(
  polkit.securityKeyMode(customCue) && !polkit.fingerprintMode(customCue),
  'polkit shows the security key for its configured cue_prompt while the reader is reachable'
)
assert(
  polkit.fingerprintMode({ ...french, securityKeyCues: ['Tap the token'] }),
  'polkit still shows the fingerprint for other messages when a cue_prompt is configured'
)
// What PolkitAgent.qml's syncFromFlow() does with `submitted` when PAM's flow changes.
const sync = (s, flow) => {
  const next = { ...s, ...flow }
  next.submitted = polkit.stillSubmitted({ ...next, messageChanged: flow.supplementary !== s.supplementary })
  return next
}
// pam_u2f with pinverification and cue: PIN prompt, PIN sent, then the cue.
let pin = { dialogVisible: true, securityKeyConfigured: true, fingerprintConfigured: true, supplementary: '' }
pin = sync(pin, { responseRequired: true, supplementary: '' })
pin = sync({ ...pin, submitted: true }, { responseRequired: false, supplementary: '' })
assert(pin.submitted && !polkit.securityKeyMode(pin), 'polkit checks the PIN after it is sent')
pin = sync(pin, { responseRequired: false, supplementary: 'Please touch the device.' })
assert(!pin.submitted && polkit.securityKeyMode(pin), 'polkit shows the security key when pam_u2f cues a touch after the PIN')
assert(
  polkit.stillSubmitted({ submitted: true, supplementary: 'Please touch the device.' }),
  'polkit keeps checking a password sent after an earlier touch cue'
)
assert(
  !polkit.stillSubmitted({ submitted: true, responseRequired: true }),
  'polkit stops checking when PAM asks again'
)
assert(
  polkit.stillSubmitted({ submitted: true, messageChanged: true, supplementary: 'Place your finger on the reader' }),
  'polkit keeps checking when PAM sends a message that is not a touch cue'
)
// The same flow with a cue_prompt the keywords don't recognize.
let customPin = { dialogVisible: true, securityKeyConfigured: true, securityKeyCues: ['Tap the token'], supplementary: '' }
customPin = sync({ ...customPin, submitted: true }, { responseRequired: false, supplementary: '' })
customPin = sync(customPin, { responseRequired: false, supplementary: 'Tap the token' })
assert(!customPin.submitted && polkit.securityKeyMode(customPin), 'polkit shows the security key when its cue_prompt follows the PIN')
JS
