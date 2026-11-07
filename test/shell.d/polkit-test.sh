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

assertEqual(polkit.keypadDigit(0x01000006), "0", "keypad 0 arrives as Insert when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000011), "1", "keypad 1 arrives as End when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000015), "2", "keypad 2 arrives as Down when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000017), "3", "keypad 3 arrives as PageDown when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000012), "4", "keypad 4 arrives as Left when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x0100000b), "5", "keypad 5 arrives as Clear when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x35), "5", "keypad 5 can arrive as Key_5 with KeypadModifier")
assertEqual(polkit.keypadDigit(0x01000014), "6", "keypad 6 arrives as Right when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000010), "7", "keypad 7 arrives as Home when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000013), "8", "keypad 8 arrives as Up when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000016), "9", "keypad 9 arrives as PageUp when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x01000007), ".", "keypad decimal arrives as Delete when NumLock is desynced")
assertEqual(polkit.keypadDigit(0x34), "", "top-row 4 is not remapped")
assertEqual(polkit.keypadDigit(0x01000004), "", "Return is not remapped as a keypad digit")
JS
