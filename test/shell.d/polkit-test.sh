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
  request("Authentication is needed to run `/usr/bin/\u202egpj-evil -x' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/\\u202egpj-evil', args: '-x' }),
  'polkit shows bidi controls in the program token as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id -u\u061c' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/id', args: '-u\\u061c' }),
  'polkit shows the Arabic letter mark as an escape'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/printf \n' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/printf', args: '\\n' }),
  'polkit shows a trailing line break in the pkexec command as an escape'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/printf \n\tx' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/printf', args: '\\n\\tx' }),
  'polkit shows controls before the first argument as escapes'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/printf' as the super user"),
  JSON.stringify({ title: 'Run as root', program: '/usr/bin/printf', args: '' }),
  'polkit leaves the arguments empty when there are none'
)
assertEqual(
  request("Authentication is needed to run `/usr/bin/id' as user \u202etoor (mallory)"),
  JSON.stringify({ title: 'Run as \\u202etoor (mallory)', program: '/usr/bin/id', args: '' }),
  'polkit shows bidi controls in the target user as escapes'
)
assertEqual(
  polkit.authorizationRequest("Authentication is needed to run `/usr/bin/id' as user a$&b", (key, english) => english).title,
  'Run as a$&b',
  'polkit does not expand replacement patterns in the target user'
)
assertEqual(
  request('Authentication is required to change system settings'),
  JSON.stringify({ title: 'Authentication is required to change system settings', program: '', args: '' }),
  'polkit preserves custom authorization messages'
)
assertEqual(
  request(''),
  JSON.stringify({ title: 'Authentication is needed...', program: '', args: '' }),
  'polkit titles an empty message with the generic prompt'
)

const translated = polkit.authorizationRequest(
  "Authentication is needed to run `/usr/bin/id -u' as user jane",
  key => ({ 'polkit.runAsUser': 'Ausführen als %1' })[key]
)
assertEqual(translated.title, 'Ausführen als jane', 'polkit translates the run-as title and fills the user')
assertEqual(
  polkit.authorizationRequest("Authentication is needed to run `/usr/bin/true' as the super user", (key, english) => 'T:' + english).title,
  'T:Run as root',
  'polkit routes the root title through the translator'
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
// Page Up and Page Down scroll the header from both places that can hold focus,
// so a keyboard-only user can read a command the short screen has clipped.
const pageKeysQml = require('fs').readFileSync(path.join(root, 'shell/plugins/polkit/PolkitAgent.qml'), 'utf8')
assert(
  pageKeysQml.includes('function scrollHeader(pages)') &&
    (pageKeysQml.match(/Key_PageDown\) \? 1 : -1|event\.key === Qt\.Key_PageDown \? 1 : -1/g) || []).length === 2,
  'polkit scrolls the header with Page Up and Page Down from the field and from the key catcher'
)

JS
