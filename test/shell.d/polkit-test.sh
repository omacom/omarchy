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
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/true', args: '', command: '/usr/bin/true' }),
  'polkit extracts a bare pkexec command'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/bash -c echo 'it works' > /dev/null' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/bash', args: "-c echo 'it works' > /dev/null", command: "/usr/bin/bash -c echo 'it works' > /dev/null" }),
  'polkit keeps quotes inside the pkexec command line'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id -u' as user Jane Doe (jane)"),
  JSON.stringify({ title: 'Run as Jane Doe (jane)', program: '/usr/bin/id', args: '-u', command: '/usr/bin/id -u' }),
  'polkit names the target user for pkexec --user'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/sh -c true\n\n\n\nrm -rf /etc' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/sh', args: '-c true\\n\\n\\n\\nrm -rf /etc', command: '/usr/bin/sh -c true\n\n\n\nrm -rf /etc' }),
  'polkit shows line breaks in the pkexec command as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/sh -c echo \u202ecte/ fr- mr' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/sh', args: '-c echo \\u202ecte/ fr- mr', command: '/usr/bin/sh -c echo \u202ecte/ fr- mr' }),
  'polkit shows bidi controls in the pkexec command as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id' as user \u202etoor (mallory)"),
  JSON.stringify({ title: 'Run as \\u202etoor (mallory)', program: '/usr/bin/id', args: '', command: '/usr/bin/id' }),
  'polkit shows bidi controls in the target user as escapes'
)
assertEqual(
  request('Authentication is required to change system settings'),
  JSON.stringify({ title: 'Authentication is required to change system settings', program: '', args: '', command: '' }),
  'polkit preserves custom authorization messages'
)
assertEqual(
  request(''),
  JSON.stringify({ title: '', program: '', args: '', command: '' }),
  'polkit handles an empty message'
)

assertEqual(
  polkit.authorizationRequest("Authentication is needed to run `/usr/bin/printf  x ' as the super user").command,
  '/usr/bin/printf  x ',
  'polkit keeps the command text exactly, empty and space-padded arguments included'
)

const caller = (exitCode, output) => JSON.stringify(polkit.callerFromOutput(exitCode, output))
const nobody = JSON.stringify({ requestedBy: '', command: '', shortened: false })

assertEqual(
  caller(0, JSON.stringify({ requestedBy: 'omarchy-update ← bash', command: "/usr/bin/bash -c 'rm -rf ~'", shortened: true })),
  JSON.stringify({ requestedBy: 'omarchy-update ← bash', command: "/usr/bin/bash -c 'rm -rf ~'", shortened: true }),
  'polkit reads who started pkexec and its full command'
)
assertEqual(caller(1, '{"requestedBy":"foot","command":"true"}'), nobody, 'polkit ignores a failed caller lookup')
for (const output of ['', 'null', '42', '{not json', '{}', '{"requestedBy":42,"command":["true"],"shortened":"yes"}']) {
  assertEqual(caller(0, output), nobody, `polkit ignores caller output ${JSON.stringify(output)}`)
}

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
