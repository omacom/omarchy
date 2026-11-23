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
JS
