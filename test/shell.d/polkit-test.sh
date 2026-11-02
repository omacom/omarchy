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
JS

agent_qml="$ROOT/shell/plugins/polkit/PolkitAgent.qml"
qml_matches() {
  local file=$1
  local pattern=$2
  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

qml_matches "$agent_qml" 'id: *agentLoader' ||
  fail "polkit agent is not hosted in a Loader for re-registration"
qml_matches "$agent_qml" 'function +recreateAgent\(' ||
  fail "polkit agent has no recreate path after failed registration"
qml_matches "$agent_qml" 'maxRegisterAttempts' ||
  fail "polkit agent registration recovery is not bounded"
qml_matches "$agent_qml" 'id: *startupRegisterTimer' ||
  fail "polkit agent does not poll for a silent registration failure"
pass "polkit agent recovers from stale registration"