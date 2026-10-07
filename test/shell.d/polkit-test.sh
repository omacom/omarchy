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
const pam = `
# auth sufficient pam_u2f.so cue
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (3 prompt tries left)]
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (2 prompt tries left)]
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (1 prompt try left)]
auth required pam_unix.so
`
const cues = polkit.securityKeyCuesFromPamConfig(pam)
assertEqual(cues.length, 3, 'only active authentication cues are detected')
let state = { active: false, remaining: 0 }
for (const remaining of [3, 2, 1]) {
  const message = `Touch your security key (${remaining} prompt ${remaining === 1 ? 'try' : 'tries'} left)`
  const cue = polkit.securityKeyCue(message, cues)
  assert(cue.biometric, 'explicit user verification uses a fingerprint glyph')
  state = polkit.securityKeyProgress(state, cue)
  assertEqual(state.remaining, remaining, 'the current PAM cue supplies the prompt budget')
  assertEqual(state.failed, remaining < 3, 'advancing to the next attempt reports a miss')
  const repeated = polkit.securityKeyProgress(state, cue)
  assert(!repeated.failed, 'repeated state notifications do not report another failure')
}
state = polkit.securityKeyProgress(state, { biometric: true, remaining: 3 })
assert(!state.failed, 'a fresh PAM pass is not another scan failure')
assertEqual(polkit.securityKeyCue('Password:', cues), null, 'password prompts are not key cues')
assertEqual(polkit.securityKeyCue('Touch your security key (9 prompt tries left)', cues), null, 'unconfigured messages cannot invent a counter')
const generic = polkit.securityKeyCuesFromPamConfig('auth sufficient pam_u2f.so cue')
const genericCue = polkit.securityKeyCue('Please touch the FIDO authenticator.', generic)
assert(genericCue && !genericCue.biometric, 'ordinary FIDO keys use a key glyph')
assertEqual(genericCue.remaining, 0, 'unreported retry budgets stay unknown')
assertEqual(polkit.securityKeyCuesFromPamConfig('auth sufficient pam_u2f.so cue nodetect').length, 0, 'nodetect cannot claim a registered key is present')
assertEqual(polkit.securityKeyCuesFromPamConfig('auth sufficient pam_u2f.so').length, 0, 'configuration alone is not key presence')
assertEqual(polkit.securityKeyCuesFromPamConfig('account sufficient pam_u2f.so cue').length, 0, 'account modules do not create scan cues')
JS
