#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const scope = vm.createContext({})
vm.runInContext(fs.readFileSync(path.join(root, 'shell/ward-runtime/Ward/RequestFeedback.js'), 'utf8'), scope)
assert(scope.linkError('denied').includes('not approved'), 'only a denial suggests reviewing access')
assert(scope.linkError('rate_limited').includes('in a moment'), 'burst limiting explains the short wait')
assert(scope.linkError('busy').includes('already opening'), 'busy reports an in-flight launch')
assert(scope.linkError('invalid').includes('HTTP'), 'invalid reports the allowed address format')
assert(scope.linkError('failed').includes('default browser'), 'launch failures do not blame grants')
for (const status of ['timed_out', 'unavailable', 'unknown', '', undefined]) {
  assert(scope.linkError(status).includes('could not be confirmed'), 'unknown outcomes do not promise safe retries')
}
for (const position of ['top', 'bottom', 'left', 'right']) {
  const placement = scope.placement({position, visible: true, size: 26}, 12, 26)
  assertEqual(placement.top, position === 'top' ? 38 : 12, position + ' clears only a top bar')
  assertEqual(placement.right, position === 'right' ? 38 : 12, position + ' clears only a right bar')
  assertEqual(scope.placement({position, visible: false, size: 26}, 12, 26).top, 12, 'hidden bar needs no clearance')
}
assertEqual(scope.placement(null, 12, 26).top, 38, 'default placement clears the stock bar')
pass('Ward link error classification and top-right placement')
JS
