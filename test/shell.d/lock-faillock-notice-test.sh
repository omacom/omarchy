#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The lock screen must say why a password was refused when pam_faillock has
# locked the account. Its notice arrives as PAM messages that ask for no
# response, before the password prompt, and the refusal that follows has to
# show them instead of "Authentication failed", which reads as a typo.
run_node_test <<'JS'
const notice = requireFromRoot('shell/plugins/lock/PamNotice.js')

assertEqual(notice.append('', 'Password: ', true), '', 'a prompt that wants a response is not a notice')
assertEqual(notice.append('', '   ', false), '', 'a blank message adds nothing')

let kept = notice.append('', 'The account is locked due to 10 failed logins.\n', false)
kept = notice.append(kept, '(2 minutes left to unlock)', false)
kept = notice.append(kept, 'Password: ', true)
assertEqual(kept, 'The account is locked due to 10 failed logins. (2 minutes left to unlock)',
  'faillock messages before the prompt are kept together, trimmed')

assertEqual(notice.failureText(kept, 'Authentication failed (3)'), 'The account is locked due to 10 failed logins. (2 minutes left to unlock)',
  'a refusal with a notice shows the notice')
assertEqual(notice.failureText('', 'Authentication failed (3)'), 'Authentication failed (3)',
  'a refusal without a notice keeps the translated attempt counter')
JS
