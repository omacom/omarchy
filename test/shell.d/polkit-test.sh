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
  'polkit detects fingerprint even behind a leftover lid-closed clamshell gate'
)
assert(
  polkit.fingerprintConfiguredFromPamConfig(`
auth [success=ignore default=1] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-open
auth sufficient pam_fprintd.so
auth required pam_unix.so
`),
  'polkit detects fingerprint behind the silent lid-open clamshell gate'
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
