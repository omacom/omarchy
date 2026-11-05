#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const calc = requireFromRoot('shell/plugins/menu/Calc.js')

const answers = [
  ['2+3', '5'], ['2 + 3 * 4', '14'], ['(2+3)*4', '20'], ['10/4', '2.5'], ['0.1+0.2', '0.3'],
  ['-2+5', '3'], ['2*-3', '-6'], ['3x4', '12'], ['6÷2', '3'], ['2×3', '6'], ['.5+.5', '1'],
  ['1000000*1000000', '1000000000000']
]
for (const [text, answer] of answers) {
  assertEqual(calc.evaluate(text), answer, `calculator answers "${text}"`)
}

for (const text of ['', '5', '-5', '(5)', '2+', '2+3)', '(2+3', '1/0', '0/0', 'zen', '7-zip', 'x', '1.2.3', '2 3', 'firefox 2+2', '$(id)+1', '2+2;ls']) {
  assertEqual(calc.evaluate(text), '', `calculator leaves "${text}" to search`)
}
JS
