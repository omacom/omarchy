#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The panel draws from lines a root helper prints, so nothing reaches it that
# it doesn't know how to draw.
run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/panels/fingerprint/EnrollmentModel.js')

assertEqual(JSON.stringify(model.parseEvent('stage 4')), '{"kind":"stage","value":4}', 'a touch is a count')
assertEqual(model.parseEvent('stage 4000'), null, 'a count beyond any reader is dropped')
assertEqual(model.parseEvent('stage -1'), null, 'a negative count is dropped')
assertEqual(model.parseEvent('stages 12abc'), null, 'a count with trailing text is dropped')
assertEqual(model.parseEvent('step <img src=x>'), null, 'an unknown step is dropped')
assertEqual(model.parseEvent('finger nose'), null, 'an unknown finger is dropped')
assertEqual(model.parseEvent('Using device /net/reactivated/Fprint/Device/0'), null, 'tool chatter is dropped')
assertEqual(model.parseEvent('stage 4 5'), null, 'an event with more than its one value is dropped')
assertEqual(model.parseEvent('done already'), null, 'a bare event with a value is dropped')
assertEqual(model.parseEvent('fail'), null, 'a failure with no reason is dropped')
assertEqual(model.parseEvent('fail <b>'), null, 'a failure reason that is not a code is dropped')
assertEqual(model.parseEvent('retry sideways').value, 'again', 'an unknown retry reason reads as a plain retry')
assertEqual(model.parseEvent('scan sideways').value, '', 'an unknown scan type names neither touch nor swipe')

// Only failures with a sentence of their own stay on the panel.
assertEqual(model.failureKind('no-match'), 'line', 'a failed verify is explained on the panel')
assertEqual(model.failureKind('packages'), 'log', 'a failed install opens the log')
assertEqual(model.failureKind('stopped'), 'log', 'an unexpected stop opens the log')
assertEqual(model.failureKind('something-new'), 'log', 'a failure the panel has no sentence for opens the log')
assertEqual(model.failureKind('platform'), 'terminal', 'a reader its platform keeps off goes to the terminal setup')

assertEqual(model.progress('enroll', 6, 12), 0.5, 'the print fills with the touches')
assert(model.progress('enroll', 12, 12) < 1, 'the print is only full once enrollment completes')
assert(model.progress('enroll', 3, 0) > model.progress('enroll', 2, 0) && model.progress('enroll', 50, 0) < 1,
  'a reader that gives no count still fills, without ever reading as done')
assertEqual(model.progress('verify', 0, 0), 1, 'the print is full while verifying')

assertEqual(model.suggestFinger([]), 'right-index-finger', 'the first finger is the right index')
assertEqual(model.suggestFinger(['right-index-finger']), 'left-index-finger', 'an enrolled finger is passed over')
assertEqual(model.suggestFinger(model.FINGERS), '', 'ten enrolled fingers leave none to register')
JS

pass "fingerprint panel event model"
