#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const polkit = requireFromRoot('shell/plugins/polkit/PolkitModel.js')

assert(polkit.promptLooksFingerprint('Swipe your finger'), 'polkit detects fingerprint prompts')
assert(polkit.promptLooksFingerprint('fprintd verification'), 'polkit detects fprint prompts')
assert(!polkit.promptLooksFingerprint('Password:'), 'polkit ignores password prompts')

const request = message => JSON.stringify(polkit.authorizationRequest(message))

assertEqual(
  request("Authentication is needed to run `/usr/bin/true' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/true', args: '' }),
  'polkit extracts a bare pkexec command'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/bash -c echo 'it works' > /dev/null' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/bash', args: "-c echo 'it works' > /dev/null" }),
  'polkit keeps quotes inside the pkexec command line'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id -u' as user Jane Doe (jane)"),
  JSON.stringify({ title: 'Run as Jane Doe (jane)', program: '/usr/bin/id', args: '-u' }),
  'polkit names the target user for pkexec --user'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/sh -c true\n\n\n\nrm -rf /etc' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/sh', args: '-c true\\n\\n\\n\\nrm -rf /etc' }),
  'polkit shows line breaks in the pkexec command as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/sh -c echo \u202ecte/ fr- mr' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/sh', args: '-c echo \\u202ecte/ fr- mr' }),
  'polkit shows bidi controls in the pkexec command as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id' as user \u202etoor (mallory)"),
  JSON.stringify({ title: 'Run as \\u202etoor (mallory)', program: '/usr/bin/id', args: '' }),
  'polkit shows bidi controls in the target user as escapes'
)
assertEqual(
  request('Authentication is required to change system settings'),
  JSON.stringify({ title: 'Authentication is required to change system settings', program: '', args: '' }),
  'polkit preserves custom authorization messages'
)
assertEqual(
  request(''),
  JSON.stringify({ title: '', program: '', args: '' }),
  'polkit handles an empty message'
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
