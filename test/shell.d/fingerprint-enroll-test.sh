#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The overlay's model turns fprintd-enroll's output into steps and hints.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/fingerprint-enroll/EnrollModel.js', 'utf8')
eval(source.replace('.pragma library', ''))

assertEqual(stepForLine('Enroll result: enroll-stage-passed').kind, 'passed', 'a passed stage is a passed step')
assertEqual(stepForLine('Enroll result: enroll-completed').kind, 'done', 'completion ends the enrolment')
assertEqual(stepForLine('Enroll result: enroll-swipe-too-short').kind, 'retry', 'a short press asks for a retry')
assertEqual(stepForLine('Enroll result: enroll-unknown-error').kind, 'failed', 'an unknown error fails the enrolment')
assertEqual(stepForLine('failed to claim device: busy').kind, 'failed', 'a busy reader fails the enrolment')
assertEqual(stepForLine('Using device /net/reactivated/Fprint/Device/0'), null, 'chatter is ignored')

assert(validFinger('right-thumb') && validFinger('left-little-finger') && !validFinger('right-toe'), 'finger names follow fprintd')
assertEqual(fingerId(1, 0), 'right-thumb', 'thumbs have no -finger suffix')
assertEqual(fingerId(0, 4), 'left-little-finger', 'other fingers do')
assertEqual(fingerLabel('right-index-finger'), 'Right index', 'labels read naturally')

assertDeepEqual(
  enrolledFromList('Fingerprints for user u on Reader (press):\n - #0: right-index-finger\n - #1: left-thumb\n'),
  ['right-index-finger', 'left-thumb'],
  'enrolled fingers are read from fprintd-list'
)

const hints = new Set()
for (let i = 0; i < 9; i++) hints.add(placementHint(i, 20))
assertEqual(hints.size, 9, 'the first nine presses each get a different placement')
assertEqual(placementHint(0, 20), placementHint(9, 20), 'then the spiral repeats')
JS
