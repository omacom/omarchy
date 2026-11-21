#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const polkit = requireFromRoot('shell/plugins/polkit/PolkitModel.js')

assert(polkit.promptLooksFingerprint('Swipe your finger'), 'polkit detects fingerprint prompts')
assert(polkit.promptLooksFingerprint('fprintd verification'), 'polkit detects fprint prompts')
assert(!polkit.promptLooksFingerprint('Password:'), 'polkit ignores password prompts')

assertEqual(
  polkit.promptLabel('Please enter the PIN: '),
  'Enter PIN',
  'polkit asks for the PIN when pam_u2f does'
)
assertEqual(
  polkit.promptLabel('Please enter the PIN: ', (key, english) => key === 'polkit.enterPin' ? 'Indtast pinkode' : english),
  'Indtast pinkode',
  'polkit asks for the PIN in the Omarchy language'
)
assertEqual(
  polkit.promptLabel('Verification code: '),
  'Verification code',
  'polkit shows a prompt it does not recognise as PAM sent it'
)
assertEqual(
  polkit.promptLabel(''),
  'Enter password',
  'polkit falls back to its own label when PAM sends no prompt'
)
assertEqual(
  polkit.promptLabel('Password: '),
  'Enter password',
  'polkit normalizes the stock password prompt'
)
assertEqual(
  polkit.promptLabel('UNIX password:'),
  'Enter password',
  'polkit normalizes the pam_unix password prompt'
)
assertEqual(
  polkit.promptLabel('   :  '),
  'Enter password',
  'polkit falls back when the prompt is only punctuation'
)
assertEqual(
  polkit.promptLabel("julianduque's password:"),
  "julianduque's password",
  'polkit passes a qualified password prompt through'
)
assertEqual(
  polkit.promptLabel('Password: ', (key, english) => key === 'polkit.enterPassword' ? 'Indtast adgangskode' : english),
  'Indtast adgangskode',
  'polkit labels the stock password prompt in the Omarchy language'
)

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
JS
