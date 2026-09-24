#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const lockSource = fs.readFileSync(root + '/shell/plugins/lock/LockView.qml', 'utf8')
const polkitSource = fs.readFileSync(root + '/shell/plugins/polkit/PolkitAgent.qml', 'utf8')
const textFieldSource = fs.readFileSync(root + '/shell/Ui/TextField.qml', 'utf8')
const networkSource = fs.readFileSync(root + '/shell/plugins/panels/network/Panel.qml', 'utf8')

// Scope every assertion to the password input itself: a hint on any other
// field must not satisfy them.
function passwordBlock(source, id, description) {
  const start = source.indexOf('id: ' + id)
  assert(start !== -1, description + ' declares its password input')
  return source.slice(start, start + 2000)
}

function assertMaskedHints(block, description) {
  assert(/inputMethodHints:[^\n]*Qt\.ImhSensitiveData/.test(block), description + ' tells the IME the text is sensitive data')
  assert(/inputMethodHints:[^\n]*Qt\.ImhHiddenText/.test(block), description + ' tells the IME the text stays hidden')
  assert(/inputMethodHints:[^\n]*Qt\.ImhNoPredictiveText/.test(block), description + ' tells the IME to skip prediction')
}

// echoMode masks committed text only; an active IME draws its preedit buffer
// in plaintext regardless, so every password field opts out of composition,
// prediction, and learned text.
const lockInput = passwordBlock(lockSource, 'passwordInput', 'lock screen')
assert(/echoMode: TextInput\.Password/.test(lockInput), 'lock screen masks committed text')
assertMaskedHints(lockInput, 'lock screen password input')

const polkitInput = passwordBlock(polkitSource, 'passwordInput', 'polkit prompt')
assert(/echoMode: root\.responseVisible \? TextInput\.Normal : TextInput\.Password/.test(polkitInput), 'polkit prompt masks committed text unless the response is shown')
assert(/inputMethodHints: root\.responseVisible \? Qt\.ImhNone :/.test(polkitInput), 'polkit prompt keeps the IME only while the response is shown')
assertMaskedHints(polkitInput, 'polkit password input')

assert(/echoMode: password \? TextInput\.Password : TextInput\.Normal/.test(textFieldSource), 'shared text field masks committed text in password mode')
assert(/inputMethodHints: password \? \([^)]*\) : Qt\.ImhNone/.test(textFieldSource), 'shared text field keeps the IME for plain entry')
assertMaskedHints(textFieldSource, 'shared text field in password mode')

assert(/password: true/.test(networkSource), 'wifi passphrase uses the shared field in password mode')
JS
