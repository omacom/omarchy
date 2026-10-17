#!/bin/bash

# #15346: a custom "command" module whose JSON has an empty text was showing the whole JSON on the bar,
# because `data.text || raw` reads "" as "no text". The rule lives in BarModel.js so it can be tested
# without a compositor.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const bar = requireFromRoot('shell/plugins/bar/BarModel.js')
const barSource = fs.readFileSync(root + '/shell/plugins/bar/Bar.qml', 'utf8')

// The parsed output arrives from Util.parseModuleJson: a JSON object, or { text: <raw> } when the
// output is not JSON at all.
assertEqual(bar.customCommandLabel('{"text":"","class":"ok"}', { text: '', class: 'ok' }), '',
  'an empty text renders nothing, not the module\'s own JSON')
assertEqual(bar.customCommandLabel('{"text":"42%","class":"ok"}', { text: '42%', class: 'ok' }), '42%',
  'the JSON text is the label')
assertEqual(bar.customCommandLabel('plain text', { text: 'plain text' }), 'plain text',
  'output that did not parse shows as it came')
assertEqual(bar.customCommandLabel('', {}), '',
  'no output renders nothing')

// Unchanged on purpose: a JSON object with no text field, and a JSON scalar, have no label to use.
assertEqual(bar.customCommandLabel('{"class":"ok"}', { class: 'ok' }), '{"class":"ok"}',
  'JSON without a text field still shows the raw output')
assertEqual(bar.customCommandLabel('123', 123), '123',
  'a JSON scalar still shows the raw output')
assertEqual(bar.customCommandLabel('{"text":null}', { text: null }), '{"text":null}',
  'a null text still shows the raw output')

assert(
  /outputText = BarModel\.customCommandLabel\(raw, data\)/.test(barSource),
  'the bar uses the shared label, so the rule cannot drift back into the QML'
)
JS
